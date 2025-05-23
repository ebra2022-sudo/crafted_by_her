import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/data/prefference_keys.dart';
import 'package:crafted_by_her/presentation/reusable_components/avatar.dart';
import 'package:crafted_by_her/presentation/reusable_components/section_item_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:crafted_by_her/presentation/reusable_components/product_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/api_service.dart';

typedef ShowDialogCallback = void Function({required Offset tapPosition});

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  late PageController _pageController;
  bool _hasFetched = false;
  bool _showAllReviews = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.80);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasFetched) {
        _hasFetched = true;
        loadAllProducts();
        Provider.of<AuthViewModel>(context, listen: false)
            .getProductDetail(widget.productId);
      }
    });
  }

  void _showReviewDialog({required Offset tapPosition}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 1000),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return ReviewDialog(productId: widget.productId);
      },
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        // Use the navigator's context for correct positioning
        final RenderBox? renderBox = (context as Element)
            .findRootAncestorStateOfType<NavigatorState>()
            ?.context
            .findRenderObject() as RenderBox?;
        final screenSize = MediaQuery.of(context).size;
        final tapOffset = renderBox?.globalToLocal(tapPosition) ?? Offset.zero;
        final normalizedPosition = Offset(
          tapOffset.dx / screenSize.width,
          tapOffset.dy / screenSize.height,
        );

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );

        return Transform.translate(
          offset: Offset(
            (0.5 - normalizedPosition.dx) *
                screenSize.width *
                (1.0 - curvedAnimation.value),
            (0.5 - normalizedPosition.dy) *
                screenSize.height *
                (1.0 - curvedAnimation.value),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.1, end: 1.0).animate(curvedAnimation),
            child: FadeTransition(
              opacity:
                  Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
                elevation: 8.0, // Subtle shadow for bubble effect
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  void loadAllProducts() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.fetchProductsByCategory('All');
  }

  Future<bool> _checkAuthentication(
      BuildContext context, ShowDialogCallback onAuthenticated,
      {required Offset tapPosition}) async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.user == null) {
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to log in to comment and rate.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Login'),
            ),
          ],
        ),
      );

      if (shouldLogin == true && context.mounted) {
        final loginSuccess =
            await Navigator.pushNamed(context, '/login') as bool?;
        if (loginSuccess == true) {
          onAuthenticated(tapPosition: tapPosition);
          return true;
        }
      }
      return false;
    }
    onAuthenticated(tapPosition: tapPosition);
    return true;
  }

  void _showContactDialog(BuildContext context) {
    final userViewModel = Provider.of<AuthViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Contact Seller'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Full Name: ${userViewModel.user?.firstName} ${userViewModel.user?.lastName}'),
            const SizedBox(height: 8),
            Text('Phone Number: ${userViewModel.user?.phoneNumber}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Network error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.getProductDetail(widget.productId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final product = viewModel.productDetail;
        if (product == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Product not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.getProductDetail(widget.productId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final reviews = product.ratings.map((rating) {
          final isCurrentUser = rating.userId == viewModel.user?.id;
          return {
            'id': rating.userId,
            'user':
                isCurrentUser ? viewModel.currentUserFullName : rating.fullName,
            'rating': rating.score,
            'comment': rating.comment,
            'date': rating.createdAt,
            'avatarUrl': isCurrentUser
                ? (viewModel.user?.profilePhoto?.isNotEmpty == true
                    ? viewModel.user!.profilePhoto
                    : rating.profilePhoto?.isNotEmpty == true
                        ? rating.profilePhoto
                        : null)
                : (rating.profilePhoto?.isNotEmpty == true
                    ? rating.profilePhoto
                    : null),
          };
        }).toList()
          ..sort((a, b) =>
              (b['date'] as DateTime).compareTo(a['date'] as DateTime));

        final visibleReviews =
            _showAllReviews ? reviews : reviews.take(2).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Product Detail',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              icon: SvgPicture.asset('assets/icon/arrow-back.svg'),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 220,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: product.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            double screenWidth =
                                MediaQuery.of(context).size.width;
                            double cardWidth = screenWidth * 0.80;
                            double sidePadding = screenWidth * 0.02;

                            return Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: sidePadding),
                              child: AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, child) {
                                  double value = 1.0;
                                  if (_pageController.position.haveDimensions) {
                                    value =
                                        (_pageController.page! - index).abs();
                                    value = (1 - (value * 0.3)).clamp(0.7, 1.0);
                                  }
                                  return Center(
                                    child: SizedBox(
                                      height: 200 * value,
                                      width: cardWidth,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      product.images[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        'assets/images/sample_product_image.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 90,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_left,
                              size: 30, color: Colors.black),
                          onPressed: () {
                            if (_currentImageIndex > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 90,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_right,
                              size: 30, color: Colors.black),
                          onPressed: () {
                            if (_currentImageIndex <
                                product.images.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            product.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontFamily: 'Roboto', fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crafted by: ${product.userId.firstName} ${product.userId.lastName}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.ratingCount} reviews',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (TapDownDetails details) async {
                          final tapPosition = details.globalPosition;
                          await _checkAuthentication(
                            context,
                            ({required Offset tapPosition}) {
                              _showReviewDialog(tapPosition: tapPosition);
                            },
                            tapPosition: tapPosition,
                          );
                        },
                        child: ElevatedButton(
                          onPressed: () async {
                            await _checkAuthentication(
                              context,
                              ({required Offset tapPosition}) {
                                _showReviewDialog(tapPosition: tapPosition);
                              },
                              tapPosition:
                                  Offset.zero, // Fallback for onPressed
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Rate & Review',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 600),
                    curve:
                        _showAllReviews ? Curves.elasticOut : Curves.easeInOut,
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: visibleReviews.length,
                          itemBuilder: (context, index) {
                            final review = visibleReviews[index];
                            return Consumer<AuthViewModel>(
                              builder: (context, vm, child) {
                                final isCurrentUser =
                                    review['id'] == vm.user?.id;
                                final updatedUser = isCurrentUser
                                    ? '${vm.user?.firstName ?? 'Unknown'} ${vm.user?.lastName ?? ''}'
                                    : review['user'] as String;
                                final profilePhoto = isCurrentUser
                                    ? vm.user?.profilePhoto
                                    : review['avatarUrl'] as String?;
                                final updatedAvatarUrl = profilePhoto
                                            ?.isNotEmpty ==
                                        true
                                    ? (profilePhoto!.startsWith('http')
                                        ? profilePhoto
                                        : '${ApiService.baseUrl}/$profilePhoto')
                                    : null;
                                return ReviewCard(
                                  user: updatedUser,
                                  rating: review['rating'] as double,
                                  comment: review['comment'] as String,
                                  date: review['date'] as DateTime,
                                  avatarUrl: updatedAvatarUrl,
                                );
                              },
                            );
                          },
                        ),
                        if (reviews.length > 2)
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showAllReviews = !_showAllReviews;
                                });
                              },
                              child: Text(
                                _showAllReviews ? 'Show Less' : 'Show More',
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SellerContactButton(
                      onContactPressed: () => _showContactDialog(context)),
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (viewModel.errorMessage != null)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Network Error',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              setState(() {
                                viewModel.setErrorMessage(null);
                                viewModel.setLoading(true);
                              });
                              await viewModel.fetchProductsByCategory('All');
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6200),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    sectionItemGrid(
                      title: 'For you',
                      items: viewModel.currentProducts
                          .where((p) => p.category == product.category)
                          .toList(),
                      itemBuilder: (context, index) {
                        final currentProduct = viewModel.currentProducts
                            .where((p) => p.category == product.category)
                            .toList()[index];
                        return ProductCard(
                          imageId: currentProduct.id,
                          imageUrl: currentProduct.images.isNotEmpty
                              ? currentProduct.images[0]
                              : 'assets/images/sample_product_image.png',
                          title: currentProduct.title,
                          description: currentProduct.description,
                          rating: currentProduct.averageRating,
                          price: currentProduct.price,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReviewDialog extends StatefulWidget {
  final String productId;

  const ReviewDialog({super.key, required this.productId});

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productViewModel = context.read<AuthViewModel>();
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final reviewerName =
            '${authViewModel.user?.firstName ?? 'Unknown'} ${authViewModel.user?.lastName ?? ''}';
        final profilePhoto = authViewModel.user?.profilePhoto;
        final avatarUrl = profilePhoto?.isNotEmpty == true
            ? (profilePhoto!.startsWith('http')
                ? profilePhoto
                : '${ApiService.baseUrl}/$profilePhoto')
            : null;

        debugPrint("Commentator avatar URL: $avatarUrl");
        debugPrint('User profile photo: ${authViewModel.user?.profilePhoto}');

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productViewModel.productDetail?.title ?? 'Product',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  AvatarProfile(
                    avatarUrl: avatarUrl,
                    fallback: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    reviewerName,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                maxRating: 5,
                allowHalfRating: true,
                itemSize: 30,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Share details of your experience',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed:
                        _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (widget.productId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid product ID'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            final prefs = await SharedPreferences.getInstance();
                            final isLoggedIn =
                                prefs.getBool(PreferencesKeys.isLoggedInKey) ??
                                    false;
                            if (!isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please log in to submit a review'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            if (_rating < 1 ||
                                _commentController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please provide a rating and comment'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            if (_rating > 5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Rating must be between 1 and 5'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isSubmitting = true;
                            });

                            try {
                              debugPrint(
                                  '[ReviewDialog] Adding rating: $_rating, comment: ${_commentController.text}, productId: ${widget.productId}');
                              await productViewModel.addRating(
                                productId: widget.productId,
                                score: _rating,
                                comment: _commentController.text.trim(),
                              );
                              debugPrint(
                                  '[ReviewDialog] Rating added successfully');

                              // Refresh product details
                              await productViewModel
                                  .getProductDetail(widget.productId);

                              if (context.mounted) {
                                Navigator.pop(context); // Close review dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Review posted successfully'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e, stackTrace) {
                              debugPrint(
                                  '[ReviewDialog] Error adding rating: $e');
                              debugPrint(stackTrace.toString());
                              String errorMessage =
                                  e.toString().replaceFirst('Exception: ', '');
                              if (errorMessage.contains(
                                  'User has already rated this product')) {
                                errorMessage =
                                    'You have already rated this product.';
                              } else if (errorMessage
                                      .contains('Unauthorized') ||
                                  errorMessage.contains('User not logged in') ||
                                  errorMessage
                                      .contains('User data unavailable')) {
                                errorMessage =
                                    'Please log in to rate this product.';
                              } else if (errorMessage
                                  .contains('User ID not found')) {
                                errorMessage =
                                    'User ID not found. Please log in again.';
                              } else if (errorMessage
                                  .toLowerCase()
                                  .contains('region')) {
                                errorMessage =
                                    'Invalid region. Please update your profile or contact support.';
                              } else if (errorMessage.contains('not found')) {
                                errorMessage =
                                    'Product or user not found. Please try again.';
                              } else {
                                errorMessage =
                                    'Failed to add review: $errorMessage';
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() {
                                  _isSubmitting = false;
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Post',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String user;
  final double rating;
  final String comment;
  final DateTime date;
  final String? avatarUrl;

  const ReviewCard({
    super.key,
    required this.user,
    required this.rating,
    required this.comment,
    required this.date,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final dateString = difference.inDays < 7
        ? timeago.format(date, locale: 'en_short')
        : DateFormat('dd MMM yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarProfile(
                avatarUrl: avatarUrl,
                avatarSize: 40.0,
                fallback: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateString,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class SellerContactButton extends StatelessWidget {
  final VoidCallback? onContactPressed;

  const SellerContactButton({super.key, this.onContactPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'To the Seller please click button',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onContactPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6200),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Contact Her',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
