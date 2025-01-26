import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final Function(String) onSearchChanged;

  SearchWidget({required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search items...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
