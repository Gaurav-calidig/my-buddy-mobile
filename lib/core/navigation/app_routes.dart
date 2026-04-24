/// Defines canonical route names and deep-link helpers used by GoRouter.
class AppRoutes {
  // Deep-link URI config (template defaults).
  static const String deepLinkScheme = 'commonmodule';
  static const String deepLinkHost = 'app';

  // Authentication and onboarding routes
  static const String splash = '/';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String signUp = '/sign-up';
  static const String updateRequired = '/update-required';
  static const String phoneAuthTest = '/phone-auth-test';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String projectDetail = '/project-detail';
  static const String taskHub = '/task-hub';
  static const String myDsr = '/my-dsr';
  static const String capacityPlanner = '/capacity-planner';
  static const String attendance = '/attendance';
  static const String cart = '/cart';
  static const String chat = '/chat';
  static const String chatRooms = '/chat/rooms';
  static const String chatRoom = '/chat/room';
  static const String notificationInbox = '/notification-inbox';
  static const String settings = '/settings';
  static const String brandingLab = '/branding-lab';

  // Payment routes
  static const String payment = '/payment';
  static const String savedCards = '/payment/saved-cards';
  static const String addCreditCard = '/payment/add-card';
  static const String paymentConfirmation = '/payment/confirmation';
  static const String paymentTest = '/payment-test';
  static const String screenshotProtectionTest = '/screenshot-protection-test';

  // Subscription routes
  static const String subscription = '/subscription';

  /// Builds the payment route with query params, facilitating deep-link reuse.
  static String paymentLocation({
    required String amount,
    required String currency,
    required String email,
    String gateway = 'stripe',
    String? description,
  }) {
    final queryParameters = <String, String>{
      'amount': amount,
      'currency': currency,
      'email': email,
      'gateway': gateway,
    };
    if (description != null && description.isNotEmpty) {
      queryParameters['description'] = description;
    }

    return Uri(path: payment, queryParameters: queryParameters).toString();
  }

  /// Builds the payment confirmation route with query params.
  static String paymentConfirmationLocation({
    required String status,
    required String message,
    required String amount,
    required String currency,
    required String gateway,
    String? email,
    String? referenceId,
  }) {
    final queryParameters = <String, String>{
      'status': status,
      'message': message,
      'amount': amount,
      'currency': currency,
      'gateway': gateway,
    };
    if (email != null && email.isNotEmpty) {
      queryParameters['email'] = email;
    }
    if (referenceId != null && referenceId.isNotEmpty) {
      queryParameters['referenceId'] = referenceId;
    }

    return Uri(
      path: paymentConfirmation,
      queryParameters: queryParameters,
    ).toString();
  }

  /// Builds a custom-scheme deep-link URL from an in-app location.
  ///
  /// Example:
  /// location: /payment?amount=10.00&currency=USD
  /// returns: commonmodule://app/payment?amount=10.00&currency=USD
  static String toDeepLink(String location) {
    final Uri parsed = Uri.parse(location);
    final String normalizedPath = parsed.path == splash ? '' : parsed.path;
    return Uri(
      scheme: deepLinkScheme,
      host: deepLinkHost,
      path: normalizedPath,
      queryParameters: parsed.queryParameters.isEmpty
          ? null
          : parsed.queryParameters,
    ).toString();
  }

  static String loginDeepLink() => toDeepLink(login);

  static String paymentDeepLink({
    required String amount,
    required String currency,
    required String email,
    String gateway = 'stripe',
    String? description,
  }) {
    return toDeepLink(
      paymentLocation(
        amount: amount,
        currency: currency,
        email: email,
        gateway: gateway,
        description: description,
      ),
    );
  }

  static String paymentConfirmationDeepLink({
    required String status,
    required String message,
    required String amount,
    required String currency,
    required String gateway,
    String? email,
    String? referenceId,
  }) {
    return toDeepLink(
      paymentConfirmationLocation(
        status: status,
        message: message,
        amount: amount,
        currency: currency,
        gateway: gateway,
        email: email,
        referenceId: referenceId,
      ),
    );
  }

  static String addCreditCardLocation() => addCreditCard;

  static String savedCardsLocation() => savedCards;

  static String subscriptionLocation() => subscription;

  static String notificationInboxLocation() => notificationInbox;

  static String brandingLabLocation() => brandingLab;

  static String addCreditCardDeepLink() => toDeepLink(addCreditCardLocation());

  static String savedCardsDeepLink() => toDeepLink(savedCardsLocation());

  static String subscriptionDeepLink() => toDeepLink(subscriptionLocation());

  static String notificationInboxDeepLink() =>
      toDeepLink(notificationInboxLocation());

  static String brandingLabDeepLink() => toDeepLink(brandingLabLocation());

  static String chatRoomsDeepLink() => toDeepLink(chatRooms);

  static String chatRoomDeepLink({required String roomId, String? roomName}) {
    return toDeepLink(
      chatRoomLocation(roomId: roomId, roomName: roomName ?? 'Chat'),
    );
  }

  static String videoCallCallbackLocation({
    required String myUserId,
    required String targetUserId,
  }) {
    return Uri(
      path: videoCallCallback,
      queryParameters: <String, String>{
        'myUserId': myUserId,
        'targetUserId': targetUserId,
      },
    ).toString();
  }

  static String videoCallWsCallbackLocation({
    required String myUserId,
    required String targetUserId,
  }) {
    return Uri(
      path: videoCallWsCallback,
      queryParameters: <String, String>{
        'myUserId': myUserId,
        'targetUserId': targetUserId,
      },
    ).toString();
  }

  static String videoCallWsUsersLocation({String? myUserId}) {
    final Map<String, String> queryParameters = <String, String>{};
    if (myUserId != null && myUserId.isNotEmpty) {
      queryParameters['myUserId'] = myUserId;
    }
    return Uri(
      path: videoCallWsUsers,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String videoCallWsLocation({
    required String roomId,
    String? callerUserId,
    String? targetUserId,
    bool autoJoin = false,
    bool autoStart = false,
  }) {
    final Map<String, String> queryParameters = <String, String>{
      'roomId': roomId,
      'autoJoin': autoJoin ? '1' : '0',
      'autoStart': autoStart ? '1' : '0',
    };

    if (callerUserId != null && callerUserId.isNotEmpty) {
      queryParameters['callerUserId'] = callerUserId;
    }
    if (targetUserId != null && targetUserId.isNotEmpty) {
      queryParameters['targetUserId'] = targetUserId;
    }

    return Uri(
      path: videoCallWsTest,
      queryParameters: queryParameters,
    ).toString();
  }

  static String videoCallUsersLocation({String? myUserId}) {
    final Map<String, String> queryParameters = <String, String>{};
    if (myUserId != null && myUserId.isNotEmpty) {
      queryParameters['myUserId'] = myUserId;
    }
    return Uri(
      path: videoCallUsers,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  /// Builds the video call route with query params.
  static String videoCallLocation({
    required String roomId,
    String? callerUserId,
    String? targetUserId,
    bool autoJoin = false,
    bool autoStart = false,
  }) {
    final queryParameters = <String, String>{
      'roomId': roomId,
      'autoJoin': autoJoin ? '1' : '0',
      'autoStart': autoStart ? '1' : '0',
    };

    if (callerUserId != null && callerUserId.isNotEmpty) {
      queryParameters['callerUserId'] = callerUserId;
    }
    if (targetUserId != null && targetUserId.isNotEmpty) {
      queryParameters['targetUserId'] = targetUserId;
    }

    return Uri(
      path: videoCallTest,
      queryParameters: queryParameters,
    ).toString();
  }

  /// Builds a deep link URL to join or create a video call room.
  static String videoCallDeepLink({
    required String roomId,
    String? callerUserId,
    String? targetUserId,
    bool autoJoin = true,
    bool autoStart = false,
  }) {
    return toDeepLink(
      videoCallLocation(
        roomId: roomId,
        callerUserId: callerUserId,
        targetUserId: targetUserId,
        autoJoin: autoJoin,
        autoStart: autoStart,
      ),
    );
  }

  /// Builds the chat room route with query params.
  static String chatRoomLocation({
    required String roomId,
    required String roomName,
  }) {
    return Uri(
      path: chatRoom,
      queryParameters: <String, String>{'roomId': roomId, 'roomName': roomName},
    ).toString();
  }

  static const String shareTest = '/share-test';
  static const String offlineApiSyncTest = '/offline-api-sync-test';
  static const String workmanagerTest = '/workmanager-test';
  static const String cachedImageTest = '/cached-image-test';
  static const String localizationTest = '/localization-test';
  static const String imageCompress = '/image-compress';
  static const String screenUtilTest = '/screen-util-test';
  static const String typographyTest = '/typography-test';
  static const String calendarTest = '/calendar-test';
  static const String mediaUploader = '/media-uploader';
  static const String showcaseTest = '/showcase-test';
  static const String onboardingTest = '/onboarding-test';
  static const String flutterOnboardingSliderTest =
      '/flutter-onboarding-slider-test';
  static String onboardingLocation({String? next}) {
    if (next == null || next.trim().isEmpty) return onboardingTest;
    return Uri(
      path: onboardingTest,
      queryParameters: <String, String>{'next': next},
    ).toString();
  }

  static const String videoCallUsers = '/video-call-users';
  static const String videoCallTest = '/video-call-test';
  static const String videoCallCallback = '/video-call-callback';
  static const String videoCallWsUsers = '/video-call-ws-users';
  static const String videoCallWsTest = '/video-call-ws-test';
  static const String videoCallWsCallback = '/video-call-ws-callback';
  static const String locationPicker = '/location-picker';
}
