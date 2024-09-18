import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LazyLoadedBackgroundImage extends StatelessWidget {
  final String imageUrl;

  LazyLoadedBackgroundImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
      ), // Placeholder widget while loading
      errorWidget: (context, url, error) =>
          Icon(Icons.error), // Error widget if loading fails
    );
  }
}
