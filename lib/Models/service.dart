class Service {
  int id;
  final String name;
  final double startingPrice;
  final double promo;
  final String startingTime;
  final String image; // Add the image property
  final bool news;
  Service(this.name, this.startingPrice, this.startingTime, this.image,
      this.news, this.id, this.promo);
}
