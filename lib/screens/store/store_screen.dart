import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/product_service.dart';
import '../../theme.dart';
import '../../widgets/product_card.dart';
import 'checkout_screen.dart';

class StoreScreen extends StatefulWidget {
  final Function(Product) onAddToCart;
  final Function(String) onRemoveFromCart;
  final Function(String, int) onQuantityChanged;
  final VoidCallback onClearCart;
  final List<CartItem> cart;

  const StoreScreen({
    Key? key,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onQuantityChanged,
    required this.onClearCart,
    required this.cart,
  }) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<Product> _products = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final cachedProducts = await ProductService().loadCachedProducts();
    if (mounted && cachedProducts.isNotEmpty) {
      setState(() {
        _products = cachedProducts;
        _isLoading = false;
      });
    }
    try {
      final remoteProducts = await ProductService().loadProducts();
      if (!mounted) return;
      setState(() {
        _products = remoteProducts;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to refresh products. Showing saved products.';
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    final queryLower = _searchQuery.trim().toLowerCase();
    final filtered = _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final searchableText = [
        product.name,
        product.category,
        product.description,
        ...product.diseases,
      ].join(' ').toLowerCase();
      return matchesCategory && searchableText.contains(queryLower);
    }).toList();
    filtered.sort((a, b) {
      if (a.isActive == b.isActive) return 0;
      return a.isActive ? -1 : 1;
    });
    return filtered;
  }

  List<String> get _categories {
    final values = _products.map((product) => product.category).toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Store'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    cartItems: widget.cart,
                    onRemoveFromCart: widget.onRemoveFromCart,
                    onQuantityChanged: widget.onQuantityChanged,
                    onClearCart: widget.onClearCart,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loadError != null)
            MaterialBanner(
              content: Text(_loadError!),
              actions: [
                TextButton(
                  onPressed: _loadProducts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          // Category Filter
          _buildCategoryFilter(),

          // Products Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 390,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCardWithActions(
                        product: product,
                        quantity: _quantityFor(product.id),
                        onIncrease: () => widget.onAddToCart(product),
                        onDecrease: () => widget.onQuantityChanged(
                          product.id,
                          _quantityFor(product.id) - 1,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  int _quantityFor(String productId) {
    final matchingItems = widget.cart.where(
      (item) => item.product.id == productId,
    );
    return matchingItems.isEmpty ? 0 : matchingItems.first.qty;
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategory = category;
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
              backgroundColor: AppColors.chip,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.muted),
          SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(fontSize: 16, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _searchQuery);
    final query = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Products'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products, categories, or skin concerns',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.of(context).pop(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Search'),
          ),
        ],
      ),
    );

    if (query != null && mounted) {
      setState(() {
        _searchQuery = query;
      });
    }
    controller.dispose();
  }
}

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(String) onRemoveFromCart;
  final Function(String, int) onQuantityChanged;
  final VoidCallback onClearCart;

  const CartScreen({
    Key? key,
    required this.cartItems,
    required this.onRemoveFromCart,
    required this.onQuantityChanged,
    required this.onClearCart,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.cartItems
        .map((item) => CartItem(product: item.product, qty: item.qty))
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unavailableItems = _items
          .where((item) => !item.product.isActive)
          .toList();
      if (unavailableItems.isEmpty || !mounted) return;

      for (final item in unavailableItems) {
        widget.onRemoveFromCart(item.product.id);
      }
      setState(() {
        _items.removeWhere((item) => !item.product.isActive);
      });
      final names = unavailableItems
          .map((item) => item.product.name)
          .join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$names ${unavailableItems.length == 1 ? 'is' : 'are'} out of stock and ${unavailableItems.length == 1 ? 'was' : 'were'} removed from your cart.',
          ),
        ),
      );
    });
  }

  double get _totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  void _remove(String productId) {
    widget.onRemoveFromCart(productId);
    setState(() => _items.removeWhere((item) => item.product.id == productId));
  }

  void _changeQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _remove(productId);
      return;
    }
    widget.onQuantityChanged(productId, quantity);
    setState(() {
      final item = _items.firstWhere((item) => item.product.id == productId);
      item.qty = quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                widget.onClearCart();
                setState(() => _items.clear());
              },
            ),
        ],
      ),
      body: _items.isEmpty ? _buildEmptyCart() : _buildCartBody(),
    );
  }

  Widget _buildCartBody() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return CartItemCard(
                cartItem: item,
                onRemove: () => _remove(item.product.id),
                onQuantityChanged: (newQty) =>
                    _changeQuantity(item.product.id, newQty),
              );
            },
          ),
        ),
        _buildSummary(),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.chip, width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Text(
                '₹${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      items: _items,
                      onOrderPlaced: widget.onClearCart,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Proceed to Buy'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.muted),
          SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/*
class CartScreenOld extends StatelessWidget {

  double get _totalAmount {
    return cartItems.fold(
        0.0, (sum, item) => sum + (item.product.price * item.qty));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              // Clear cart - would be handled by parent in real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        cartItem: item,
                        onRemove: () => onRemoveFromCart(item.product.id),
                        onQuantityChanged: (newQty) {
                          // In a real app, this would update the cart
                          // For demo, we'll just show a message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Quantity updated to $newQty'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: const Border(
                      top: BorderSide(color: AppColors.chip, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            '₹${_totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Proceed to checkout - would navigate to payment screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proceeding to checkout...'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.muted,
          ),
          SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Add some products to your cart to get started!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
*/

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    required this.onRemove,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.chip, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.chip,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: cartItem.product.imagePath != null
                ? _cartProductImage(cartItem.product)
                : Icon(
                    cartItem.product.icon ?? Icons.image_not_supported,
                    size: 24,
                    color: AppColors.muted,
                  ),
          ),
        ),
        title: Text(
          cartItem.product.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        subtitle: Text(
          '₹${cartItem.product.price.toStringAsFixed(0)} x ${cartItem.qty}',
          style: TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (cartItem.qty > 1) {
                  onQuantityChanged(cartItem.qty - 1);
                } else {
                  onRemove();
                }
              },
            ),
            Text(
              '${cartItem.qty}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onQuantityChanged(cartItem.qty + 1),
            ),
            IconButton(icon: const Icon(Icons.delete), onPressed: onRemove),
          ],
        ),
      ),
    );
  }

  Widget _cartProductImage(Product product) {
    final path = product.imagePath!;
    final image = path.startsWith('http')
        ? Image.network(path, fit: BoxFit.contain)
        : Image.asset(path, fit: BoxFit.contain);
    return Image(
      image: image.image,
      width: 60,
      height: 60,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        product.icon ?? Icons.image_not_supported,
        size: 24,
        color: AppColors.muted,
      ),
    );
  }
}

class ProductCardWithActions extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const ProductCardWithActions({
    Key? key,
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!product.isActive) {
      return Column(
        children: [
          Expanded(child: ProductCard(product: product)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: null,
              child: const Text('Out of stock'),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(child: ProductCard(product: product)),
        const SizedBox(height: 8),
        if (quantity == 0)
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onIncrease,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecrease,
                    child: const Icon(Icons.remove),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onIncrease,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
