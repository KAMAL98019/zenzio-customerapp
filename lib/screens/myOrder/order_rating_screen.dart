import 'package:flutter/material.dart';
import 'package:zenzio/services/ratingService.dart';

class OrderRatingScreen extends StatefulWidget {
  final String? orderId;
  
  const OrderRatingScreen({
    super.key,
    this.orderId,
  });

  @override
  State<OrderRatingScreen> createState() => _OrderRatingScreenState();
}

class _OrderRatingScreenState extends State<OrderRatingScreen> {
  int _restaurantRating = 0;
  int _deliveryRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Future<void> _submitRating() async {
  //   if (_restaurantRating == 0 || _deliveryRating == 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please rate both restaurant and delivery experience'),
  //         backgroundColor: Colors.orange,
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() => _isSubmitting = true);

  //   try {
  //     // TODO: Call your API to submit rating
  //     // await ApiService().submitRating({
  //     //   'orderId': widget.orderId,
  //     //   'restaurantRating': _restaurantRating,
  //     //   'deliveryRating': _deliveryRating,
  //     //   'comment': _commentController.text,
  //     // });

  //     // Simulate API call
  //     await Future.delayed(const Duration(seconds: 1));

  //     if (!mounted) return;

  //     // Show success and navigate back
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Thank you for your feedback!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );

  //     Navigator.pop(context);
  //   } catch (e) {
  //     if (!mounted) return;
      
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error submitting rating: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isSubmitting = false);
  //     }
  //   }
  // }
Future<void> _submitRating() async {
  if (_restaurantRating == 0 || _deliveryRating == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please rate both restaurant and delivery experience'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    await RatingService().submitBothRatings(
      groupId: widget.orderId ?? "",
      restaurantRating: _restaurantRating,
      deliveryRating: _deliveryRating,
      description: _commentController.text.isEmpty 
          ? "No Comments" 
          : _commentController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error submitting rating: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _isSubmitting = false);
  }
}


  void _skipRating() {
    // Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/main-navigation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  'Order Delivered!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                const Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Restaurant Rating
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rate your restaurant experience',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildStarRating(
                  rating: _restaurantRating,
                  onRatingChanged: (rating) {
                    setState(() => _restaurantRating = rating);
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Delivery Rating
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rate your delivery experience',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildStarRating(
                  rating: _deliveryRating,
                  onRatingChanged: (rating) {
                    setState(() => _deliveryRating = rating);
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Comment TextField
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Leave a comment for the restaurant/\ndelivery partner',
                      hintStyle: TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Rating',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Skip Button
                TextButton(
                  onPressed: _isSubmitting ? null : _skipRating,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating({
    required int rating,
    required Function(int) onRatingChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;
        
        return GestureDetector(
          onTap: () => onRatingChanged(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: 48,
              color: isFilled ? const Color(0xFFE53935) : const Color(0xFFBDBDBD),
            ),
          ),
        );
      }),
    );
  }
}