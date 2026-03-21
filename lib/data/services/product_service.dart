import '../models/product.dart';

abstract class ProductService {
  Future<List<Product>> getRecommendProducts();
  Future<List<Product>> getHotProducts();
  Future<List<Product>> getProductByCategory(int categoryId);
}
