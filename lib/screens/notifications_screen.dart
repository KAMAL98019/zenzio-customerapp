import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Your order has been delivered!',
      'message': 'Your order from Burger Kingdom has been delivered. Enjoy your meal!',
      'time': '10:30 AM',
      'date': 'Today',
      'isToday': true,
    },
    {
      'title': 'Order confirmed',
      'message': 'Your order #ORD-33704 has been confirmed and is being prepared.',
      'time': '09:15 AM',
      'date': 'Today',
      'isToday': true,
    },
    {
      'title': 'Special offer for you!',
      'message': 'Get 20% OFF on your next order from Pizza Paradise. Valid today only!',
      'time': '08:22 AM',
      'date': 'Today',
      'isToday': true,
    },
    {
      'title': 'Your reservation is confirmed',
      'message': 'Your table at Italian Bistro has been reserved for tomorrow at 7:00 PM.',
      'time': '10:45 AM',
      'date': 'Yesterday',
      'isToday': false,
    },
    {
      'title': 'Rate your experience',
      'message': 'How was your food from Sushi Master? Rate your experience.',
      'time': '08:30 AM',
      'date': 'Yesterday',
      'isToday': false,
    },
    {
      'title': 'Delivery person assigned',
      'message': 'Rahul S. will be delivering your order from Taco Fiesta.',
      'time': '09:00 AM',
      'date': 'Earlier This Week',
      'isToday': false,
    },
    {
      'title': 'Payment successful',
      'message': 'Your payment of \$42.71 for order #ORD-67654 was successful.',
      'time': '06:15 PM',
      'date': 'Earlier This Week',
      'isToday': false,
    },
    {
      'title': 'New restaurant in your area!',
      'message': 'Discover Noodle House, now available for delivery in your area.',
      'time': '02:30 PM',
      'date': 'Earlier This Week',
      'isToday': false,
    },
    {
      'title': 'Weekend special offers',
      'message': 'Check out amazing deals this weekend from your favorite restaurants.',
      'time': '11:00 AM',
      'date': 'Earlier This Week',
      'isToday': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Group notifications by date
    Map<String, List<Map<String, dynamic>>> groupedNotifications = {};
    for (var notification in _notifications) {
      String date = notification['date'];
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      groupedNotifications[date]!.add(notification);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          String date = groupedNotifications.keys.elementAt(index);
          List<Map<String, dynamic>> notifications = groupedNotifications[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ),
              ...notifications.map((notification) {
                return _buildNotificationItem(
                  notification['title'],
                  notification['message'],
                  notification['time'],
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDeleteDialog(context);
        },
        backgroundColor: const Color(0xFFE53935),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, String time) {
    return Dismissible(
      key: Key('$title-$time'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((n) => n['title'] == title && n['time'] == time);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Clear All Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete all notifications?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete All',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}