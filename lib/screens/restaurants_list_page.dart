import 'package:customer_app/core/constants/appcolors.dart';
import 'package:flutter/material.dart';

class RestaurantsListPage extends StatelessWidget {
  const RestaurantsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Restaurants"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text("List of all restaurants will be displayed here."),
      ),
    );
  }
}