import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';

import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/network/result.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:core/features/payment/data/saved_cards_store.dart';
import 'package:core/features/payment/domain/entities/saved_card_entity.dart';

class AddSavedCardScreen extends StatefulWidget {
  const AddSavedCardScreen({super.key});

  @override
  State<AddSavedCardScreen> createState() => _AddSavedCardScreenState();
}

class _AddSavedCardScreenState extends State<AddSavedCardScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SavedCardsStore _savedCardsStore = SavedCardsStore();
  final PaymentRemoteDatasource _paymentDatasource =
      sl<PaymentRemoteDatasource>();
  final CardFormEditController _cardController = CardFormEditController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  CardFieldInputDetails _cardDetails = const CardFieldInputDetails(
    complete: false,
  );
  bool _isSaving = false;
  bool _isDefault = true;

  @override
  void dispose() {
    _cardController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewBrand = _cardDetails.brand?.trim().isNotEmpty == true
        ? _cardDetails.brand!.trim()
        : 'Stripe card';
    final previewLast4 = _cardDetails.last4?.trim().isNotEmpty == true
        ? '•••• ${_cardDetails.last4!.trim()}'
        : '•••• •••• •••• ••••';
    final previewExpiry =
        _cardDetails.expiryMonth != null && _cardDetails.expiryYear != null
        ? '${_cardDetails.expiryMonth!.toString().padLeft(2, '0')}/${(_cardDetails.expiryYear! % 100).toString().padLeft(2, '0')}'
        : 'MM/YY';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Credit Card')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.credit_card_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Stripe card form',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This screen uses Stripe’s native card-details widget inside our app UI.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _previewChip(previewBrand),
                        _previewChip(previewLast4),
                        _previewChip(previewExpiry),
                        if (_isDefault) _previewChip('Default card'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cardholder details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cardholder name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Cardholder name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Billing email optional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nicknameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nickname optional',
                  hintText: 'Personal card, Work card',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Stripe card details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: CardFormField(
                  controller: _cardController,
                  autofocus: true,
                  enablePostalCode: false,
                  numberHintText: 'Card number',
                  expirationHintText: 'MM/YY',
                  cvcHintText: 'CVC',
                  onCardChanged: (details) {
                    setState(() {
                      _cardDetails =
                          details ??
                          const CardFieldInputDetails(complete: false);
                    });
                  },
                  style: CardFormStyle(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    borderColor: theme.dividerColor,
                    borderWidth: 1,
                    borderRadius: 16,
                    cursorColor: theme.colorScheme.primary,
                    placeholderColor: theme.hintColor,
                    textColor: theme.colorScheme.onSurface,
                    textErrorColor: theme.colorScheme.error,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                title: const Text('Make this the default card'),
                subtitle: const Text(
                  'The first saved card becomes default automatically.',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving || !_cardDetails.complete
                      ? null
                      : _saveCard,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Card with Stripe',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () => context.go(AppRoutes.savedCardsLocation()),
                child: const Text('View saved cards'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCard() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_cardDetails.complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the Stripe card details first.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final result = await _paymentDatasource.createStripeSetupIntent();
      if (result is! Success<Map<String, dynamic>>) {
        throw Exception('Failed to create Stripe setup intent');
      }

      final intentData = Map<String, dynamic>.from(result.data);
      final clientSecret = _extractValue(intentData, const [
        'client_secret',
        'clientSecret',
      ]);
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Stripe setup intent did not return a client secret');
      }

      final setupIntent = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: _nameController.text.trim(),
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
            ),
          ),
        ),
      );

      final savedCard = SavedCardEntity(
        id: setupIntent.id.isNotEmpty
            ? setupIntent.id
            : DateTime.now().microsecondsSinceEpoch.toString(),
        cardholderName: _nameController.text.trim(),
        brand: _cardDetails.brand?.trim().isNotEmpty == true
            ? _cardDetails.brand!.trim()
            : 'Card',
        last4: _cardDetails.last4?.trim().isNotEmpty == true
            ? _cardDetails.last4!.trim()
            : '0000',
        expiryMonth: _cardDetails.expiryMonth ?? DateTime.now().month,
        expiryYear: _cardDetails.expiryYear ?? DateTime.now().year,
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
        isDefault: _isDefault,
        createdAt: DateTime.now(),
      );

      await _savedCardsStore.saveCard(savedCard);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stripe card saved successfully.')),
      );
      context.go(AppRoutes.savedCardsLocation());
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save card: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _previewChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String? _extractValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        return value.toString();
      }
    }
    return null;
  }
}
