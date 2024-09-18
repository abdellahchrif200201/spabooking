import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spa/screens/Details_salon.dart';
import 'package:spa/screens/List_salon.dart';

class ExpandableListWidget extends StatefulWidget {
  final String title;
  final bool isNew;
  final List<PLaces2> places;

  const ExpandableListWidget({
    required this.title,
    required this.isNew,
    required this.places,
  });

  @override
  _ExpandableListWidgetState createState() => _ExpandableListWidgetState();
}

class _ExpandableListWidgetState extends State<ExpandableListWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isListVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 1, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleListVisibility() {
    setState(() {
      isListVisible = !isListVisible;
      isListVisible ? _controller.reverse() : _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: toggleListVisibility,
          child: Container(
            // padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: Colors.black.withOpacity(0.5), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.isNew ? Icons.new_releases : Icons.star,
                      color: const Color(0xFFD91A5B),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Icon(
                  isListVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 30,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _animation,
          child: Container(
            height: 205,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.places.length,
              itemBuilder: (context, index) {
                final place = widget.places[index];
                return _buildPlaceCard(place, widget.isNew);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPlaceCard(PLaces2 place, bool a) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SalonDetails(
                    id: place.id.toString(),
                  )),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: CachedNetworkImage(
                          width: 200,
                          imageUrl: place.mainImage,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              CachedNetworkImage(
                                width: 200,
                                imageUrl:
                                    "https://spabooking.pro/assets/no-image-18732f44.png",
                                fit: BoxFit.cover,
                              ))),
                ),
                /* const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: place.sideImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              place.mainImage = place.sideImages[index];
                            });
                          },
                          child: Image.network(
                            place.sideImages[index],
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),*/
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              place.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFFD91A5B),
                              ),
                              maxLines: 1, // Set the maximum number of lines
                              softWrap:
                                  true, // Allow the text to wrap to the next line
                              overflow: TextOverflow
                                  .ellipsis, // Display ellipsis (...) if the text overflows
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                place.stars.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 120,
                        child: Text(
                          place.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 3, // Set the maximum number of lines
                          softWrap:
                              true, // Allow the text to wrap to the next line
                          overflow: TextOverflow
                              .ellipsis, // Display ellipsis (...) if the text overflows
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.type,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            /*   Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: a
                    ? Row(
                        children: [
                          Icon(
                            Icons.new_releases,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Nouveaux',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Plus recommandé',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
