import 'package:flutter/material.dart';
import 'package:dermalens/theme.dart';

import 'screens/scan/scan_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';
import 'screens/store/store_screen.dart';
import 'screens/doctors/doctors_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/profile_service.dart';
import 'services/cart_service.dart';
import 'models.dart';

void main() {
  runApp(const DermalensApp());
}

class DermalensApp extends StatelessWidget {
  const DermalensApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DermaLens',
      theme: buildTheme(),
      home: const DermalensHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DermalensHomePage extends StatefulWidget {
  const DermalensHomePage({super.key});

  @override
  State<DermalensHomePage> createState() => _DermalensHomePageState();
}

class _DermalensHomePageState extends State<DermalensHomePage> {
  int _selectedIndex = 0;
  int _historyRefreshToken = 0;
  List<CartItem> _cart = [];
  Patient? _patient;
  bool _isProfileLoaded = false;
  bool _isCartLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final results = await Future.wait([
      ProfileService().loadProfile(),
      CartService().loadCart(),
    ]);
    if (mounted) {
      setState(() {
        _patient = results[0] as Patient?;
        _cart = results[1] as List<CartItem>;
        _isProfileLoaded = true;
        _isCartLoaded = true;
      });
    }
  }

  Future<void> _saveCart() => CartService().saveCart(_cart);

  void _onProfileSaved(Patient patient) {
    setState(() => _patient = patient);
  }

  void _onScanSaved() {
    setState(() => _historyRefreshToken++);
  }

  void _onAddToCart(Product product) {
    setState(() {
      final existingIndex = _cart.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingIndex != -1) {
        _cart = _cart
            .map(
              (item) => item.product.id == product.id
                  ? CartItem(product: item.product, qty: item.qty + 1)
                  : CartItem(product: item.product, qty: item.qty),
            )
            .toList();
      } else {
        _cart = [..._cart, CartItem(product: product)];
      }
    });
    _saveCart();
  }

  void _onRemoveFromCart(String productId) {
    setState(() {
      _cart = _cart.where((item) => item.product.id != productId).toList();
    });
    _saveCart();
  }

  void _onQuantityChanged(String productId, int quantity) {
    if (quantity <= 0) {
      _onRemoveFromCart(productId);
      return;
    }
    setState(() {
      _cart = _cart
          .map(
            (item) => item.product.id == productId
                ? CartItem(product: item.product, qty: quantity)
                : CartItem(product: item.product, qty: item.qty),
          )
          .toList();
    });
    _saveCart();
  }

  void _onClearCart() {
    setState(() => _cart = []);
    _saveCart();
  }

  List<Widget> _buildPages() {
    return [
      ScanScreen(onScanSaved: _onScanSaved),
      ChatbotScreen(),
      StoreScreen(
        onAddToCart: _onAddToCart,
        onRemoveFromCart: _onRemoveFromCart,
        onQuantityChanged: _onQuantityChanged,
        onClearCart: _onClearCart,
        cart: _cart,
      ),
      DoctorsScreen(patient: _patient),
      HistoryScreen(refreshToken: _historyRefreshToken),
      SettingsScreen(
        patient: _patient,
        isFirstRun: false,
        onSaved: _onProfileSaved,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isProfileLoaded || !_isCartLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_patient == null) {
      return SettingsScreen(
        patient: null,
        isFirstRun: true,
        onSaved: _onProfileSaved,
      );
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _buildPages()),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.image_search),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital_outlined),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
