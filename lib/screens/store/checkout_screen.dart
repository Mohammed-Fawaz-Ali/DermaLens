import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models.dart';
import '../../theme.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  final VoidCallback onOrderPlaced;

  const CheckoutScreen({
    Key? key,
    required this.items,
    required this.onOrderPlaced,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _billingController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  String _payment = 'Cash on delivery';
  bool _billingMatchesShipping = true;
  bool _placed = false;
  String? _orderId;
  DateTime? _orderedAt;

  @override
  void initState() {
    super.initState();
    _loadSavedDeliveryDetails();
  }

  Future<void> _loadSavedDeliveryDetails() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    _addressController.text = preferences.getString('delivery_address') ?? '';
    _cityController.text = preferences.getString('delivery_city') ?? '';
    _postalController.text = preferences.getString('delivery_postal') ?? '';
    _billingController.text = preferences.getString('billing_address') ?? '';
  }

  double get _subtotal =>
      widget.items.fold(0, (sum, item) => sum + item.lineTotal);
  double get _deliveryFee => _subtotal >= 500 ? 0 : 40;
  double get _total => _subtotal + _deliveryFee;

  @override
  void dispose() {
    _addressController.dispose();
    _billingController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;
    _saveDeliveryDetails();
    widget.onOrderPlaced();
    setState(() {
      _placed = true;
      _orderId =
          'DL-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      _orderedAt = DateTime.now();
    });
  }

  Future<void> _saveDeliveryDetails() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'delivery_address',
      _addressController.text.trim(),
    );
    await preferences.setString('delivery_city', _cityController.text.trim());
    await preferences.setString(
      'delivery_postal',
      _postalController.text.trim(),
    );
    await preferences.setString(
      'billing_address',
      _billingController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_placed) return _buildOrderConfirmation();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Order summary'),
            ...widget.items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.product.name),
                subtitle: Text(
                  '${item.qty} x ₹${item.product.price.toStringAsFixed(2)}',
                ),
                trailing: Text('₹${item.lineTotal.toStringAsFixed(2)}'),
              ),
            ),
            const Divider(),
            _amountRow('Subtotal', _subtotal),
            _amountRow('Delivery', _deliveryFee),
            _amountRow('Total bill', _total, emphasized: true),
            const SizedBox(height: 20),
            _sectionTitle('Delivery address'),
            _field(_addressController, 'Street address', Icons.home_outlined),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _cityController,
                    'City',
                    Icons.location_city_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _postalController,
                    'Postal code',
                    Icons.markunread_mailbox_outlined,
                    numeric: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('Billing address'),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _billingMatchesShipping,
              title: const Text('Same as delivery address'),
              onChanged: (value) =>
                  setState(() => _billingMatchesShipping = value ?? true),
            ),
            if (!_billingMatchesShipping)
              _field(
                _billingController,
                'Billing address',
                Icons.receipt_long_outlined,
              ),
            const SizedBox(height: 20),
            _sectionTitle('Payment method'),
            DropdownButtonFormField<String>(
              value: _payment,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.payment),
                labelText: 'Payment option',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Cash on delivery',
                  child: Text('Cash on delivery'),
                ),
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                DropdownMenuItem(
                  value: 'Card',
                  child: Text('Credit or debit card'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _payment = value ?? _payment),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _placeOrder,
                icon: const Icon(Icons.lock_outline),
                label: Text('Place order - ₹${_total.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderConfirmation() {
    return Scaffold(
      appBar: AppBar(title: const Text('Order confirmed')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 72,
          ),
          const SizedBox(height: 12),
          const Text(
            'Thank you for your order',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order $_orderId\nPlaced: ${_formatDateTime(_orderedAt!)}\nPayment: $_payment\nTotal: ₹${_total.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 28),
          _sectionTitle('Items in your order'),
          ...widget.items.map(
            (item) => Card(
              color: AppColors.surface,
              child: ListTile(
                title: Text(item.product.name),
                subtitle: Text(
                  '${item.qty} x ₹${item.product.price.toStringAsFixed(2)}',
                ),
                trailing: Text(
                  '₹${item.lineTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.store_outlined),
            label: const Text('Return to store'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} $hour:$minute $period';
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      ),
    ),
  );

  Widget _amountRow(String label, double amount, {bool emphasized = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: emphasized ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: emphasized ? FontWeight.bold : FontWeight.normal,
                color: emphasized ? AppColors.primary : AppColors.text,
              ),
            ),
          ],
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool numeric = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: numeric
          ? TextInputType.number
          : TextInputType.streetAddress,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required' : null,
    );
  }
}
