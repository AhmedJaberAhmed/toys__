import 'package:flutter/material.dart';
import 'package:nyoba/models/categories_model.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';

class ItemDrawerCategories extends StatelessWidget {
  final AllCategoriesModel? category;
  const ItemDrawerCategories({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Transparent for ripple effect
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.2), // Subtle ripple effect
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BrandProducts(
                categoryId: category!.id.toString(),
                brandName: category!.title,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0), // Vertical spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  category!.title!,
                  style: TextStyle(
                    fontSize: 16, // Professional, readable font size
                    fontWeight: FontWeight.w600, // Medium weight for a balanced look
                    color: Colors.cyan, // Neutral, professional text color
                    fontFamily: 'Roboto', // Modern and professional font
                  ),
                ),
              ),
              SizedBox(height: 8), // Vertical spacing between text and divider
              Divider(
                thickness: 1, // Subtle divider thickness
                color: Colors.grey[300], // Light grey for a clean, modern look
              ),
            ],
          ),
        ),
      ),
    );
  }
}
