import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/constants/firestore_constants.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/navigation/app_router.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/notification/bloc/navigation_bloc.dart';
import 'package:core/core/notification/bloc/navigation_event.dart';
import 'package:core/core/utils/firebase_initializer.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:core/features/splash/presentation/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'notification_codes_data.dart';

class NotificationService {
  factory NotificationService() => _instance;

  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();
  final Logger _logger = Logger();
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _androidChannelId = 'default_channel';
  static const String _androidChannelName = 'Notifications';
  static const String _androidCallChannelId = 'incoming_call_channel';
  static const String _androidCallChannelName = 'Incoming Calls';
  static const int _maxInboxItems = 100;

  static const String _videoCallInviteType = 'video_call_invite';
  static const String _videoCallMissedType = 'video_call_missed';
  static const String _videoCallWsInviteType = 'video_call_ws_invite';
  static const String _videoCallWsMissedType = 'video_call_ws_missed';
  static const String _callActionAnswer = 'call_answer';
  static const String _callActionDecline = 'call_decline';
  static const String _callActionCallBack = 'call_back';
  static const String _iosCallCategory = 'video_call_actions';
  static const String _iosIncomingCallSubtitle =
      'Swipe down for Answer or Decline';

  NotificationNavigationBloc? _navigationBloc;
  final Map<int, Timer> _incomingCallDismissTimers = <int, Timer>{};
  final Map<int, Map<String, String>> _incomingCallMeta =
      <int, Map<String, String>>{};
  final Map<int, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
  _incomingCallRoomSubscriptions =
      <int, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};
  StreamSubscription<CallEvent?>? _callKitEventSubscription;

  static const Duration _incomingCallTimeout = Duration(seconds: 30);

  Future<void> init([NotificationNavigationBloc? navBloc]) async {
    _navigationBloc = navBloc;
    _logger.i('NotificationService.init() start');
    await _initLocalNotifications();
    _setupCallKitListeners();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _logger.i('Foreground presentation options set (iOS).');

    if (Platform.isIOS) {
      try {
        String? apnsToken;
        int retryCount = 0;
        while (apnsToken == null && retryCount < 5) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            await Future.delayed(const Duration(seconds: 1));
            retryCount++;
          }
        }
      } catch (e) {
        _logger.w('APNS token not available yet: $e');
      }
    }

    await getFCMToken();
    await _setupFCMListeners();
    _logger.i('NotificationService.init() done');

    final launchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    final NotificationResponse? response = launchDetails?.notificationResponse;
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      if (response != null) {
        await _handleNotificationResponse(response);
        return;
      }

      final payload = response?.payload;
      if (payload != null) {
        await handleTerminatedNotification(json.decode(payload));
      }
    }
  }

  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission();
    _logger.i('FCM permission: ');
    return settings;
  }

  Future<NotificationSettings?> requestPermissionWithRationaleIfNeeded(
    BuildContext context,
  ) async {
    final NotificationSettings settings = await _messaging
        .getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      return settings;
    }

    if (!context.mounted) {
      return settings;
    }

    final bool? accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enable notifications?'),
        content: const Text(
          'We use notifications for incoming calls and important updates.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (accepted != true) {
      return settings;
    }

    return requestPermission();
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinNotificationCategory iosCallCategory =
        DarwinNotificationCategory(
          _iosCallCategory,
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.customDismissAction,
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(
              _callActionAnswer,
              'Accept',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              _callActionDecline,
              'Decline',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
          ],
        );

    final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      notificationCategories: <DarwinNotificationCategory>[iosCallCategory],
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _logger.i(
          'Local notification response (foreground): '
          'actionId=${response.actionId}, payload=${response.payload}',
        );
        unawaited(_handleNotificationResponse(response));
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    const AndroidNotificationChannel defaultChannel =
        AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.max,
        );

    const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
      _androidCallChannelId,
      _androidCallChannelName,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(defaultChannel);
    await androidPlugin?.createNotificationChannel(callChannel);

    if (Platform.isAndroid) {
      await androidPlugin?.requestFullScreenIntentPermission();
    }

    _logger.i(
      'Android notification channels ensured: '
      'default=$_androidChannelId, call=$_androidCallChannelId',
    );
  }

  Future<void> _setupFCMListeners() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _logger.i('FCM token refreshed: $token');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _logger.i(
        'FCM onMessage: messageId=${message.messageId}, '
        'from=${message.from}, '
        'dataKeys=${message.data.keys.toList()}',
      );
      if (message.notification != null) {
        _logger.i(
          'FCM notification: title="${message.notification?.title}", '
          'body="${message.notification?.body}"',
        );
      }
      await _storeNotificationInboxItem(message, source: 'onMessage');
      final String type = (message.data['type'] as String? ?? '').trim();
      if (type == _videoCallInviteType || type == _videoCallWsInviteType) {
        final String roomId = (message.data['roomId'] as String? ?? '').trim();
        final String callerUserId =
            (message.data['callerUserId'] as String? ?? '').trim();
        final String targetUserId =
            (message.data['targetUserId'] as String? ?? '').trim();

        if (roomId.isNotEmpty) {
          await showIncomingCallNotification(
            roomId: roomId,
            callerUserId: callerUserId,
            targetUserId: targetUserId,
            type: type,
          );
          return;
        }
      }

      if (type == _videoCallMissedType || type == _videoCallWsMissedType) {
        final String roomId = (message.data['roomId'] as String? ?? '').trim();
        final String callerUserId =
            (message.data['callerUserId'] as String? ?? '').trim();
        final String targetUserId =
            (message.data['targetUserId'] as String? ?? '').trim();

        if (roomId.isNotEmpty) {
          await showMissedCallNotification(
            roomId: roomId,
            callerUserId: callerUserId,
            targetUserId: targetUserId,
            type: type,
          );
          return;
        }
      }

      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _logger.i(
        'FCM onMessageOpenedApp: messageId=${message.messageId}, '
        'dataKeys=${message.data.keys.toList()}',
      );
      await _storeNotificationInboxItem(message, source: 'onMessageOpenedApp');
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _logger.i(
        'FCM getInitialMessage: messageId=${initialMessage.messageId}, '
        'dataKeys=${initialMessage.data.keys.toList()}',
      );
      await _storeNotificationInboxItem(
        initialMessage,
        source: 'getInitialMessage',
      );
    }
  }

  void _setupCallKitListeners() {
    if (!Platform.isIOS) return;
    _callKitEventSubscription?.cancel();
    _callKitEventSubscription = FlutterCallkitIncoming.onEvent.listen((
      CallEvent? event,
    ) {
      if (event == null) return;
      unawaited(_handleCallKitEvent(event));
    });
  }

  Future<void> _handleCallKitEvent(CallEvent event) async {
    final Event name = event.event;
    final Map<String, dynamic>? data = _extractCallKitPayload(event.body);
    if (data == null) return;
    if (name == Event.actionCallAccept) {
      await _handleVideoCallInviteAction(data, actionId: _callActionAnswer);
      return;
    }
    if (name == Event.actionCallDecline ||
        name == Event.actionCallEnded ||
        name == Event.actionCallTimeout) {
      await _handleVideoCallInviteAction(data, actionId: _callActionDecline);
      return;
    }
  }

  Map<String, dynamic>? _extractCallKitPayload(dynamic body) {
    if (body is! Map) return null;
    final dynamic extra = body['extra'];
    if (extra is Map<String, dynamic>) {
      return Map<String, dynamic>.from(extra);
    }
    if (extra is Map) {
      return extra.map((dynamic key, dynamic value) {
        return MapEntry(key.toString(), value);
      });
    }
    final String roomId = (body['id'] as String? ?? '').trim();
    if (roomId.isEmpty) return null;
    return <String, dynamic>{
      'type': _videoCallInviteType,
      'roomId': roomId,
      'callerUserId': (body['nameCaller'] as String? ?? '').trim(),
      'targetUserId': (FirebaseAuth.instance.currentUser?.uid ?? '').trim(),
    };
  }

  Future<void> _showIncomingCallKitUi({
    required String roomId,
    required String callerUserId,
    required String targetUserId,
    required String type,
  }) async {
    final String callKitId = _callKitUuidForRoomId(roomId);
    final CallKitParams params = CallKitParams(
      id: callKitId,
      nameCaller: callerUserId.isEmpty ? 'Incoming call' : callerUserId,
      appName: 'Common Module',
      avatar: '',
      handle: 'Video call',
      type: 1,
      duration: _incomingCallTimeout.inMilliseconds,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{
        'type': type,
        'roomId': roomId,
        'callerUserId': callerUserId,
        'targetUserId': targetUserId,
      },
      ios: IOSParams(
        iconName: 'AppIcon',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        audioSessionMode: 'default',
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> showIncomingCallNotification({
    required String roomId,
    required String callerUserId,
    required String targetUserId,
    String type = _videoCallInviteType,
  }) async {
    final String normalizedRoomId = roomId.trim();
    if (normalizedRoomId.isEmpty) return;
    final payloadMap = <String, dynamic>{
      'type': type,
      'roomId': normalizedRoomId,
      'callerUserId': callerUserId.trim(),
      'targetUserId': targetUserId.trim(),
    };
    final int notificationId = normalizedRoomId.hashCode;
    if (Platform.isIOS) {
      await _showIncomingCallKitUi(
        roomId: normalizedRoomId,
        callerUserId: callerUserId.trim(),
        targetUserId: targetUserId.trim(),
        type: type,
      );
    } else {
      final String title = 'Incoming video call';
      final String body = callerUserId.trim().isEmpty
          ? 'Someone is calling you.'
          : '$callerUserId is calling you.';
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _androidCallChannelId,
            _androidCallChannelName,
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.call,
            fullScreenIntent: true,
            autoCancel: false,
            ongoing: true,
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                _callActionAnswer,
                'Answer',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                _callActionDecline,
                'Decline',
                cancelNotification: true,
              ),
            ],
          );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        categoryIdentifier: _iosCallCategory,
        interruptionLevel: InterruptionLevel.timeSensitive,
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        subtitle: _iosIncomingCallSubtitle,
        threadIdentifier: _iosCallCategory,
      );
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: jsonEncode(payloadMap),
      );
    }
    _incomingCallMeta[notificationId] = <String, String>{
      'roomId': normalizedRoomId,
      'callerUserId': callerUserId.trim(),
      'targetUserId': targetUserId.trim(),
    };
    if (type == _videoCallInviteType) {
      _watchIncomingCallRoomStatus(
        roomId: normalizedRoomId,
        notificationId: notificationId,
      );
    }
    _scheduleIncomingCallTimeout(notificationId: notificationId);
  }

  Future<void> showMissedCallNotification({
    required String roomId,
    required String callerUserId,
    required String targetUserId,
    String type = _videoCallMissedType,
  }) async {
    final String normalizedRoomId = roomId.trim();
    if (normalizedRoomId.isEmpty) return;

    final payloadMap = <String, dynamic>{
      'type': type,
      'roomId': normalizedRoomId,
      'callerUserId': callerUserId.trim(),
      'targetUserId': targetUserId.trim(),
    };

    final String normalizedCaller = callerUserId.trim();
    final String title = 'Missed video call';
    final String body = normalizedCaller.isEmpty
        ? 'You missed a video call.'
        : 'You missed a video call from .';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.missedCall,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              _callActionCallBack,
              'Call back',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final int notificationId = _missedCallNotificationId(normalizedRoomId);

    await _flutterLocalNotificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(payloadMap),
    );
  }

  int _missedCallNotificationId(String roomId) {
    return '_missed'.hashCode;
  }

  Future<void> _clearMissedCallNotification(String roomId) async {
    await _flutterLocalNotificationsPlugin.cancel(
      id: _missedCallNotificationId(roomId),
    );
  }

  void _watchIncomingCallRoomStatus({
    required String roomId,
    required int notificationId,
  }) {
    _incomingCallRoomSubscriptions.remove(notificationId)?.cancel();

    _incomingCallRoomSubscriptions[notificationId] = FirebaseFirestore.instance
        .collection(FirestoreCollections.webrtcRooms)
        .doc(roomId)
        .snapshots()
        .listen(
          (snapshot) {
            final Map<String, dynamic>? data = snapshot.data();
            final String status =
                (data?[FirestoreWebRtcRoomFields.status] as String? ?? '')
                    .trim()
                    .toLowerCase();

            // Clear incoming notification immediately when call leaves ringing state.
            if (status == 'accepted' ||
                status == 'connected' ||
                status == 'declined' ||
                status == 'rejected' ||
                status == 'ended' ||
                status == 'timeout' ||
                status == 'failed') {
              unawaited(_clearIncomingCallNotification(roomId));
            }
          },
          onError: (_) {
            // Keep timer fallback if Firestore listener fails.
          },
        );
  }

  void _scheduleIncomingCallTimeout({required int notificationId}) {
    _incomingCallDismissTimers.remove(notificationId)?.cancel();
    _incomingCallDismissTimers[notificationId] = Timer(
      _incomingCallTimeout,
      () {
        _incomingCallDismissTimers.remove(notificationId);
        _incomingCallRoomSubscriptions.remove(notificationId)?.cancel();
        final Map<String, String>? meta = _incomingCallMeta.remove(
          notificationId,
        );
        if (Platform.isIOS) {
          final String room = (meta?['roomId'] ?? '').trim();
          if (room.isNotEmpty) {
            unawaited(
              FlutterCallkitIncoming.endCall(_callKitUuidForRoomId(room)),
            );
          }
        } else {
          unawaited(
            _flutterLocalNotificationsPlugin.cancel(id: notificationId),
          );
        }

        if (meta == null) return;
        final String roomId = (meta['roomId'] ?? '').trim();
        final String callerUserId = (meta['callerUserId'] ?? '').trim();
        final String targetUserId = (meta['targetUserId'] ?? '').trim();
        if (roomId.isEmpty) return;

        unawaited(
          showMissedCallNotification(
            roomId: roomId,
            callerUserId: callerUserId,
            targetUserId: targetUserId,
          ),
        );
      },
    );
  }

  Future<void> _clearIncomingCallNotification(String roomId) async {
    final int notificationId = roomId.hashCode;
    _incomingCallDismissTimers.remove(notificationId)?.cancel();
    _incomingCallRoomSubscriptions.remove(notificationId)?.cancel();
    _incomingCallMeta.remove(notificationId);
    if (Platform.isIOS) {
      await FlutterCallkitIncoming.endCall(_callKitUuidForRoomId(roomId));
    } else {
      await _flutterLocalNotificationsPlugin.cancel(id: notificationId);
    }
  }

  String _callKitUuidForRoomId(String roomId) {
    final String normalized = roomId.trim();
    if (normalized.isEmpty) return normalized;

    final RegExp uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-'
      r'[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    if (uuidPattern.hasMatch(normalized)) {
      return normalized.toLowerCase();
    }

    final List<int> bytes = utf8.encode(normalized);
    final BigInt hash1 = _fnv1a64(bytes, 0xcbf29ce484222325);
    final BigInt hash2 = _fnv1a64(bytes, 0x84222325cbf29ce4);
    final String hex = '${_hex64(hash1)}${_hex64(hash2)}';

    final List<String> chars = hex.split('');
    chars[12] = '4';

    final int variantNibble = int.parse(chars[16], radix: 16);
    chars[16] = ((variantNibble & 0x3) | 0x8).toRadixString(16);

    return '${chars.take(8).join()}-${chars.skip(8).take(4).join()}-'
        '${chars.skip(12).take(4).join()}-${chars.skip(16).take(4).join()}-'
        '${chars.skip(20).take(12).join()}';
  }

  BigInt _fnv1a64(List<int> bytes, int offsetBasis) {
    final BigInt prime = BigInt.from(0x100000001b3);
    final BigInt mask = BigInt.from(0xFFFFFFFFFFFFFFFF);
    BigInt hash = BigInt.from(offsetBasis) & mask;

    for (final int byte in bytes) {
      hash = (hash ^ BigInt.from(byte)) * prime;
      hash &= mask;
    }

    return hash;
  }

  String _hex64(BigInt value) {
    return value.toRadixString(16).padLeft(16, '0');
  }

  Future<void> clearIncomingCallNotificationByRoom(String roomId) async {
    await _clearIncomingCallNotification(roomId);
  }

  void _showLocalNotification(RemoteMessage message) async {
    _logger.d(
      'Show local notification: messageId=${message.messageId}, '
      'hasCode=${message.data['code'] != null}',
    );
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final code = message.data['code'];
    if (code != null) {
      final notificationData = await getNotificationData(code);
      _logger.i('Local notification (code=$code): ${notificationData.title}');
      await flutterLocalNotificationsPlugin.show(
        id: message.hashCode,
        title: notificationData.title,
        body: notificationData.body,
        notificationDetails: details,
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      );
      return;
    }

    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    _logger.i('Local notification (fallback): $title');
    await flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    final Map<String, dynamic>? data = _decodePayload(response.payload);
    if (data == null) {
      _onSelectNotification(response.payload);
      return;
    }

    final String type = (data['type'] as String? ?? '').trim();

    if (type == _videoCallInviteType || type == _videoCallWsInviteType) {
      await _handleVideoCallInviteAction(data, actionId: response.actionId);
      return;
    }

    if (type == _videoCallMissedType || type == _videoCallWsMissedType) {
      await _handleVideoCallMissedAction(data, actionId: response.actionId);
      return;
    }

    _onSelectNotification(response.payload);
  }

  Map<String, dynamic>? _decodePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleVideoCallInviteAction(
    Map<String, dynamic> data, {
    String? actionId,
  }) async {
    final String roomId = (data['roomId'] as String? ?? '').trim();
    if (roomId.isEmpty) return;

    await _clearIncomingCallNotification(roomId);

    final String callerUserId = (data['callerUserId'] as String? ?? '').trim();
    final String targetUserId = (data['targetUserId'] as String? ?? '').trim();
    final String currentUserId = (FirebaseAuth.instance.currentUser?.uid ?? '')
        .trim();
    final String receiverId = targetUserId.isNotEmpty
        ? targetUserId
        : currentUserId;
    final String type = (data['type'] as String? ?? '').trim();
    final bool isWs = type == _videoCallWsInviteType;

    if (actionId == _callActionDecline) {
      if (isWs) {
        // For WS signaling in background/terminated there is no live socket.
        // Decline action only dismisses notification; caller timeout handles no-answer.
        return;
      }
      _logger.i(
        '[CallDecline][foreground] roomId=$roomId receiverId=$receiverId',
      );
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.webrtcRooms)
          .doc(roomId)
          .set(<String, dynamic>{
            FirestoreWebRtcRoomFields.status: 'declined',
            FirestoreWebRtcRoomFields.declinedBy: receiverId,
            FirestoreWebRtcRoomFields.declinedAt: FieldValue.serverTimestamp(),
            FirestoreWebRtcRoomFields.endedReason: 'declined',
            FirestoreWebRtcRoomFields.endedBy: receiverId,
            FirestoreWebRtcRoomFields.endedAt: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return;
    }

    final String location = isWs
        ? AppRoutes.videoCallWsLocation(
            roomId: roomId,
            callerUserId: callerUserId.isEmpty ? null : callerUserId,
            targetUserId: receiverId.isEmpty ? null : receiverId,
            autoJoin: true,
          )
        : AppRoutes.videoCallLocation(
            roomId: roomId,
            callerUserId: callerUserId.isEmpty ? null : callerUserId,
            targetUserId: receiverId.isEmpty ? null : receiverId,
            autoJoin: true,
          );
    AppRouter.router.go(location);
  }

  Future<void> _handleVideoCallMissedAction(
    Map<String, dynamic> data, {
    String? actionId,
  }) async {
    if (actionId != null &&
        actionId.isNotEmpty &&
        actionId != _callActionCallBack) {
      return;
    }

    final String roomId = (data['roomId'] as String? ?? '').trim();
    if (roomId.isNotEmpty) {
      await _clearMissedCallNotification(roomId);
    }

    final String callerUserId = (data['callerUserId'] as String? ?? '').trim();
    final String targetUserId = (data['targetUserId'] as String? ?? '').trim();
    final String currentUserId = (FirebaseAuth.instance.currentUser?.uid ?? '')
        .trim();
    final String callbackCallerId = targetUserId.isNotEmpty
        ? targetUserId
        : currentUserId;

    if (callbackCallerId.isEmpty || callerUserId.isEmpty) {
      return;
    }

    final List<String> ids = <String>[callbackCallerId, callerUserId]..sort();
    final String callbackRoomId = 'vc_direct_${ids[0]}_${ids[1]}';
    final String type = (data['type'] as String? ?? '').trim();
    final bool isWs = type == _videoCallWsMissedType;

    final String wsCallbackRoomId = 'vcws_direct_${ids[0]}_${ids[1]}';
    final String location = isWs
        ? AppRoutes.videoCallWsLocation(
            roomId: wsCallbackRoomId,
            callerUserId: callbackCallerId,
            targetUserId: callerUserId,
            autoStart: true,
          )
        : AppRoutes.videoCallLocation(
            roomId: callbackRoomId,
            callerUserId: callbackCallerId,
            targetUserId: callerUserId,
            autoStart: true,
          );
    AppRouter.router.go(location);
  }

  void _onSelectNotification(String? payload) {
    _logger.i('Local notification tapped. payload=$payload');
    if (payload == null) return;
    final data = json.decode(payload) as Map<String, dynamic>;
    _logger.i('Decoded payload: $data');
    _navigationBloc?.add(SetNavigationFromPayload(data));

    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      _logger.i('fcm token: $token');
      return token;
    } catch (e) {
      _logger.w(
        'FCM token not available yet (likely iOS simulator or APNS not set): $e',
      );
      return null;
    }
  }

  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    const serverKey = 'service-key.json';
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(<String, dynamic>{
          'to': token,
          'notification': <String, dynamic>{'title': title, 'body': body},
        }),
      );
    } catch (e) {
      _logger.e(e);
    }
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _storeNotificationInboxItem(
  RemoteMessage message, {
  required String source,
}) async {
  final String existingRaw =
      await SharedPref().read(PrefKeys.notificationInbox) ?? '[]';

  List<dynamic> decoded;
  try {
    decoded = jsonDecode(existingRaw) as List<dynamic>;
  } catch (_) {
    decoded = <dynamic>[];
  }

  final List<Map<String, dynamic>> items = decoded
      .whereType<Map>()
      .map((dynamic e) => Map<String, dynamic>.from(e as Map))
      .toList();

  final Map<String, dynamic> nextItem = <String, dynamic>{
    'messageId': message.messageId,
    'title': message.notification?.title ?? 'Notification',
    'body': message.notification?.body ?? '',
    'data': message.data,
    'source': source,
    'sentTime': message.sentTime?.toIso8601String(),
    'receivedAt': DateTime.now().toIso8601String(),
    'signature': _notificationSignature(message),
  };

  final String signature = nextItem['signature'] as String;
  final bool alreadyExists = items.any((Map<String, dynamic> item) {
    return item['signature'] == signature;
  });

  if (alreadyExists) {
    return;
  }

  items.insert(0, nextItem);

  if (items.length > NotificationService._maxInboxItems) {
    items.removeRange(NotificationService._maxInboxItems, items.length);
  }

  await SharedPref().write(PrefKeys.notificationInbox, jsonEncode(items));
}

String _notificationSignature(RemoteMessage message) {
  return jsonEncode(<String, dynamic>{
    'id': message.messageId,
    'title': message.notification?.title,
    'body': message.notification?.body,
    'data': message.data,
    'sentTime': message.sentTime?.toIso8601String(),
  });
}

bool _backgroundLocalNotificationsInitialized = false;

Future<void> _ensureBackgroundLocalNotificationsInitialized() async {
  if (_backgroundLocalNotificationsInitialized) {
    return;
  }

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
    'default_channel',
    'Notifications',
    importance: Importance.max,
  );

  const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
    'incoming_call_channel',
    'Incoming Calls',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  await androidPlugin?.createNotificationChannel(defaultChannel);
  await androidPlugin?.createNotificationChannel(callChannel);

  _backgroundLocalNotificationsInitialized = true;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger().i(
    'FCM background: messageId=${message.messageId}, '
    'dataKeys=${message.data.keys.toList()}',
  );
  await FirebaseInitializer.ensureInitialized();
  await _ensureBackgroundLocalNotificationsInitialized();
  await _storeNotificationInboxItem(message, source: 'onBackgroundMessage');

  final String type = (message.data['type'] as String? ?? '').trim();
  if (type == 'video_call_invite') {
    final String roomId = (message.data['roomId'] as String? ?? '').trim();
    final String callerUserId = (message.data['callerUserId'] as String? ?? '')
        .trim();
    final String targetUserId = (message.data['targetUserId'] as String? ?? '')
        .trim();

    Logger().i(
      '[BackgroundInvite] roomId=$roomId caller=$callerUserId target=$targetUserId',
    );

    if (roomId.isNotEmpty) {
      await NotificationService().showIncomingCallNotification(
        roomId: roomId,
        callerUserId: callerUserId,
        targetUserId: targetUserId,
      );
      return;
    }
  }

  if (type == 'video_call_ws_invite') {
    final String roomId = (message.data['roomId'] as String? ?? '').trim();
    final String callerUserId = (message.data['callerUserId'] as String? ?? '')
        .trim();
    final String targetUserId = (message.data['targetUserId'] as String? ?? '')
        .trim();

    if (roomId.isNotEmpty) {
      await NotificationService().showIncomingCallNotification(
        roomId: roomId,
        callerUserId: callerUserId,
        targetUserId: targetUserId,
        type: 'video_call_ws_invite',
      );
      return;
    }
  }

  if (type == 'video_call_missed') {
    final String roomId = (message.data['roomId'] as String? ?? '').trim();
    final String callerUserId = (message.data['callerUserId'] as String? ?? '')
        .trim();
    final String targetUserId = (message.data['targetUserId'] as String? ?? '')
        .trim();

    Logger().i(
      '[BackgroundMissed] roomId=$roomId caller=$callerUserId target=$targetUserId',
    );

    if (roomId.isNotEmpty) {
      await NotificationService().showMissedCallNotification(
        roomId: roomId,
        callerUserId: callerUserId,
        targetUserId: targetUserId,
      );
      return;
    }
  }

  if (type == 'video_call_ws_missed') {
    final String roomId = (message.data['roomId'] as String? ?? '').trim();
    final String callerUserId = (message.data['callerUserId'] as String? ?? '')
        .trim();
    final String targetUserId = (message.data['targetUserId'] as String? ?? '')
        .trim();

    if (roomId.isNotEmpty) {
      await NotificationService().showMissedCallNotification(
        roomId: roomId,
        callerUserId: callerUserId,
        targetUserId: targetUserId,
        type: 'video_call_ws_missed',
      );
      return;
    }
  }

  final code = message.data['code'];
  if (code == null) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    Logger().i('Background notification (fallback): $title');

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
    return;
  }

  final notificationData = await getNotificationData(code);
  const androidDetails = AndroidNotificationDetails(
    'default_channel',
    'Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );
  const details = NotificationDetails(android: androidDetails);

  Logger().i('Background notification (code=$code): ${notificationData.title}');
  await flutterLocalNotificationsPlugin.show(
    id: message.hashCode,
    title: notificationData.title,
    body: notificationData.body,
    notificationDetails: details,
    payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
  );
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  Logger().i(
    'Local notification tap (background). actionId=${response.actionId}, payload=${response.payload}',
  );
  final payload = response.payload;
  if (payload == null) return;

  Map<String, dynamic>? data;
  try {
    final dynamic decoded = json.decode(payload);
    if (decoded is Map<String, dynamic>) {
      data = decoded;
    } else if (decoded is Map) {
      data = decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {}

  if (data == null) return;

  final String type = (data['type'] as String? ?? '').trim();

  if (type == 'video_call_invite' || type == 'video_call_ws_invite') {
    final String roomId = (data['roomId'] as String? ?? '').trim();
    if (roomId.isNotEmpty) {
      await NotificationService()._clearIncomingCallNotification(roomId);
    }
    if (roomId.isNotEmpty &&
        response.actionId == 'call_decline' &&
        type == 'video_call_invite') {
      Logger().i('[CallDecline][backgroundTap] roomId=');
      await FirebaseInitializer.ensureInitialized();
      final String receiverId = (data['targetUserId'] as String? ?? '').trim();
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.webrtcRooms)
          .doc(roomId)
          .set(<String, dynamic>{
            FirestoreWebRtcRoomFields.status: 'declined',
            FirestoreWebRtcRoomFields.declinedBy: receiverId,
            FirestoreWebRtcRoomFields.declinedAt: FieldValue.serverTimestamp(),
            FirestoreWebRtcRoomFields.endedReason: 'declined',
            FirestoreWebRtcRoomFields.endedBy: receiverId,
            FirestoreWebRtcRoomFields.endedAt: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      Logger().i('[CallDecline][backgroundTap] room updated -> declined');
      return;
    }

    await handleTerminatedNotification(data, actionId: response.actionId);
    return;
  }

  await handleTerminatedNotification(data, actionId: response.actionId);
}

Future<void> handleTerminatedNotification(
  Map<String, dynamic> data, {
  String? actionId,
}) async {
  final logger = Logger();
  try {
    logger.i(
      'Handling terminated state notification: data=$data actionId=$actionId',
    );

    final String type = (data['type'] as String? ?? '').trim();

    if (type == 'video_call_invite' || type == 'video_call_ws_invite') {
      if (actionId == 'call_decline' && type == 'video_call_invite') {
        final String roomId = (data['roomId'] as String? ?? '').trim();
        logger.i('[CallDecline][terminated] roomId=');
        if (roomId.isNotEmpty) {
          await NotificationService()._clearIncomingCallNotification(roomId);
          await FirebaseInitializer.ensureInitialized();
          final String receiverId = (data['targetUserId'] as String? ?? '')
              .trim();
          await FirebaseFirestore.instance
              .collection(FirestoreCollections.webrtcRooms)
              .doc(roomId)
              .set(<String, dynamic>{
                FirestoreWebRtcRoomFields.status: 'declined',
                FirestoreWebRtcRoomFields.declinedBy: receiverId,
                FirestoreWebRtcRoomFields.declinedAt:
                    FieldValue.serverTimestamp(),
                FirestoreWebRtcRoomFields.endedReason: 'declined',
                FirestoreWebRtcRoomFields.endedBy: receiverId,
                FirestoreWebRtcRoomFields.endedAt: FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
          logger.i('[CallDecline][terminated] room updated -> declined');
        }
        return;
      }

      final String roomId = (data['roomId'] as String? ?? '').trim();
      if (roomId.isNotEmpty) {
        await NotificationService()._clearIncomingCallNotification(roomId);
      }
      final String callerUserId = (data['callerUserId'] as String? ?? '')
          .trim();
      final String targetUserId = (data['targetUserId'] as String? ?? '')
          .trim();

      if (roomId.isNotEmpty) {
        final String location = type == 'video_call_ws_invite'
            ? AppRoutes.videoCallWsLocation(
                roomId: roomId,
                callerUserId: callerUserId.isEmpty ? null : callerUserId,
                targetUserId: targetUserId.isEmpty ? null : targetUserId,
                autoJoin: true,
              )
            : AppRoutes.videoCallLocation(
                roomId: roomId,
                callerUserId: callerUserId.isEmpty ? null : callerUserId,
                targetUserId: targetUserId.isEmpty ? null : targetUserId,
                autoJoin: true,
              );
        AppRouter.router.go(location);
        return;
      }
    }

    if (type == 'video_call_missed' || type == 'video_call_ws_missed') {
      await NotificationService()._handleVideoCallMissedAction(
        data,
        actionId: actionId,
      );
      return;
    }

    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  } catch (e, stack) {
    logger.e('Error handling terminated state notification: $e\n$stack');
    FirebaseCrashlytics.instance.recordError(e, stack);
  }
}
