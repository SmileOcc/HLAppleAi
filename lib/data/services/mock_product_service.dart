import '../models/product.dart';
import 'product_service.dart';

class MockProductService implements ProductService {
  @override
  Future<List<Product>> getRecommendProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.generate(20, (index) {
      return Product(
        id: index + 1000,
        name: _getRecommendProductName(index),
        price: 99.0 + (index * 15),
        originalPrice: 199.0 + (index * 30),
        image: 'https://picsum.photos/300/400?random=${index + 30}',
        sales: 80 + index * 30,
        rating: 4.0 + (index % 10) * 0.1,
        description: '优质商品，性价比高',
        categoryId: (index % 8) + 1,
        stock: 50 + index * 5,
        colors: _getProductColors(index),
        sizes: _getProductSizes(index),
      );
    });
  }

  @override
  Future<List<Product>> getHotProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.generate(20, (index) {
      return Product(
        id: index + 2000,
        name: _getHotProductName(index),
        price: 199.0 + (index * 20),
        originalPrice: 399.0 + (index * 40),
        image: 'https://picsum.photos/300/350?random=${index + 50}',
        sales: 200 + index * 50,
        rating: 4.5 + (index % 5) * 0.1,
        description: '热门爆款，限时特惠',
        categoryId: (index % 6) + 1,
        stock: 20 + index * 3,
        colors: _getProductColors(index),
        sizes: _getProductSizes(index),
      );
    });
  }

  @override
  Future<List<Product>> getProductByCategory(int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List.generate(12, (index) {
      return Product(
        id: categoryId * 100 + index,
        name: _getCategoryProductName(categoryId, index),
        price: 79.0 + (index * 12),
        originalPrice: 159.0 + (index * 25),
        image:
            'https://picsum.photos/300/380?random=${categoryId * 10 + index}',
        sales: 100 + index * 40,
        rating: 4.2 + (index % 8) * 0.1,
        description: '精选商品，品质保证',
        categoryId: categoryId,
        stock: 30 + index * 10,
        colors: _getProductColors(index),
        sizes: _getProductSizes(index),
      );
    });
  }

  String _getRecommendProductName(int index) {
    final names = [
      'AirPods Pro 2 无线耳机',
      'Apple Watch 磁吸充电底座',
      'iPhone 15 液态硅胶保护壳',
      'MacBook Pro 拓展坞',
      'iPad 钢化膜套装',
      'Apple Pencil 笔尖套装',
      'Magic Mouse 无线鼠标',
      'Magic Keyboard 键盘膜',
      'MagSafe 磁吸卡包',
      'AirTag 皮革保护套',
      'HomePod mini 音响支架',
      'iPhone 镜头膜',
      'Apple Watch 表带',
      'iPad Pro 保护套',
      'MacBook Air 内胆包',
      'AirPods Max 头戴式耳机',
      'Apple TV 遥控器套',
      'iPhone 数据线',
      'Apple Watch 充电器',
      'iPad mini 保护壳',
    ];
    return names[index % names.length];
  }

  String _getHotProductName(int index) {
    final names = [
      'iPhone 15 Pro Max 旗舰手机',
      'MacBook Pro M3 Max 笔记本电脑',
      'iPad Pro 12.9英寸 平板电脑',
      'AirPods Pro 2 主动降噪耳机',
      'Apple Watch S9 智能手表',
      'iMac 24英寸 一体机',
      'HomePod 智能音响',
      'Apple Vision Pro 头显',
      'Mac Studio 专业工作站',
      'Mac Mini 小巧主机',
      'AirPods Max 头戴耳机',
      'Apple TV 4K 机顶盒',
      'Magic Keyboard 触控板',
      'Pro Display XDR 显示器',
      'iPad Air 轻薄平板',
      'iPhone 15 时尚手机',
      'MacBook Air 超薄笔记本',
      'iPad mini 便携平板',
      'Apple Watch Ultra 运动手表',
      'Beats Studio 头戴耳机',
    ];
    return names[index % names.length];
  }

  String _getCategoryProductName(int categoryId, int index) {
    final names = {
      1: [
        'iPhone 手机',
        '三星手机',
        '小米手机',
        '华为手机',
        'OPPO手机',
        'vivo手机',
        '荣耀手机',
        '一加手机',
        '真我手机',
        'iQOO手机',
        '魅族手机',
        '联想手机',
      ],
      2: [
        'MacBook Pro',
        'ThinkPad',
        'Dell XPS',
        'HP Spectre',
        'Surface Laptop',
        'ROG 玩家国度',
        '拯救者 Y9000P',
        'MacBook Air',
        '华为 MateBook',
        '小米笔记本',
        '华硕灵耀',
        '联想小新',
      ],
      3: [
        'iPad Pro',
        'iPad Air',
        'iPad mini',
        '华为 MatePad',
        '小米平板',
        '三星 Tab S',
        'Surface Pro',
        '联想 Pad',
        'OPPO Pad',
        'vivo Pad',
        '荣耀平板',
        '亚马逊 Fire',
      ],
      4: [
        'AirPods Pro',
        'Sony WH-1000XM5',
        'Bose QC45',
        'Beats Studio3',
        '华为 FreeBuds',
        '小米 Buds',
        '三星 Galaxy Buds',
        '森海塞尔',
        'JBL 耳机',
        '铁三角耳机',
        '漫步者耳机',
        'B&O 耳机',
      ],
      5: [
        'Apple Watch',
        '华为 Watch',
        '小米手环',
        '三星 Watch',
        'OPPO Watch',
        'vivo Watch',
        '荣耀手表',
        '佳明手表',
        '颂拓手表',
        'fitbit 手环',
        '小米手表',
        '华为手环',
      ],
      6: [
        'Canon 相机',
        'Sony 微单',
        '尼康相机',
        '富士相机',
        '松下相机',
        'GoPro 运动相机',
        '大疆 无人机',
        'Osmo 云台',
        'Insta360 全景相机',
        '理光相机',
        '徕卡相机',
        '奥林巴斯相机',
      ],
      7: [
        'Switch 游戏机',
        'PS5 游戏机',
        'Xbox 游戏机',
        'Steam Deck',
        'ROG Ally',
        '游戏手柄',
        '游戏耳机',
        '机械键盘',
        '游戏鼠标',
        '显示器',
        '电竞椅',
        '手柄支架',
      ],
      8: [
        '智能家居',
        '扫地机器人',
        '空气净化器',
        '加湿器',
        '除湿机',
        '吸尘器',
        '吹风机',
        '挂烫机',
        '电暖器',
        '空调扇',
        '饮水机',
        '净水器',
      ],
    };
    final categoryNames = names[categoryId] ?? names[1]!;
    return categoryNames[index % categoryNames.length];
  }

  List<String> _getProductColors(int index) {
    final colorOptions = [
      ['深空黑', '银色', '金色'],
      ['黑色', '白色'],
      ['灰色', '蓝色', '粉色'],
      ['午夜色', '星光色', '银色', '绿色'],
      ['经典黑', '米白色'],
      ['深空灰', '金色', '银色'],
    ];
    return colorOptions[index % colorOptions.length];
  }

  List<List<String>> _getSizeOptions() {
    return [
      [],
      ['128GB', '256GB', '512GB', '1TB'],
      ['64GB', '256GB', '512GB'],
      ['S', 'M', 'L', 'XL'],
      ['40mm', '44mm', '45mm'],
      ['标准版', '专业版'],
      ['0.5m', '1m', '2m'],
      ['USB-C', 'Lightning', 'Type-C'],
    ];
  }

  List<String> _getProductSizes(int index) {
    return _getSizeOptions()[index % _getSizeOptions().length];
  }
}
