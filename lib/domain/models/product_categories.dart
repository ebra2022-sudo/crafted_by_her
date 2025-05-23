



enum ProductCategory {
  Clothes, Shoes, Jewelries, Beauties, Bags, Arts;

  static ProductCategory? fromString(String? value) {
    try {
      if (value != null) {
        return ProductCategory.values.firstWhere(
                (e) => e.name.toLowerCase() == value.toLowerCase());
      }
    } catch (e) {
      return null;
    }
  }
}


