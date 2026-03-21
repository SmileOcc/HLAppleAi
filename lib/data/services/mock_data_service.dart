import '../models/product.dart';
import '../models/category.dart';
import '../models/post.dart';

class MockDataService {
  static Future<List<Map<String, dynamic>>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 1,
        'image': 'https://picsum.photos/750/300?random=1',
        'title': '春季特惠',
        'url': 'spring-sale',
      },
      {
        'id': 2,
        'image': 'https://picsum.photos/750/300?random=2',
        'title': '新品上市',
        'url': 'new-arrival',
      },
      {
        'id': 3,
        'image': 'https://picsum.photos/750/300?random=3',
        'title': '限时抢购',
        'url': 'flash-sale',
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> getQuickCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'id': 1, 'name': '手机', 'icon': 'phone_iphone'},
      {'id': 2, 'name': '电脑', 'icon': 'computer'},
      {'id': 3, 'name': '平板', 'icon': 'tablet_mac'},
      {'id': 4, 'name': '耳机', 'icon': 'headphones'},
      {'id': 5, 'name': '手表', 'icon': 'watch'},
      {'id': 6, 'name': '相机', 'icon': 'camera_alt'},
      {'id': 7, 'name': '智能', 'icon': 'devices'},
      {'id': 8, 'name': '配件', 'icon': 'cable'},
    ];
  }

  static Future<List<Product>> getRecommendProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.generate(20, (index) {
      return Product(
        id: index + 1,
        name: _getProductName(index),
        price: 99.0 + (index * 10),
        originalPrice: 199.0 + (index * 20),
        image: 'https://picsum.photos/300/300?random=${index + 10}',
        sales: 100 + index * 50,
        rating: 4.0 + (index % 10) * 0.1,
        description: '优质商品，性价比高，限时优惠中',
        categoryId: (index % 8) + 1,
        stock: 100,
        colors: _getProductColors(index),
        sizes: _getSizeOptions()[index % _getSizeOptions().length],
      );
    });
  }

  static String _getProductName(int index) {
    final names = [
      'iPhone 15 Pro Max',
      'MacBook Pro M3',
      'iPad Pro 12.9',
      'AirPods Pro 2',
      'Apple Watch S9',
      'iMac 24英寸',
      'AirPods Max',
      'iPhone 15',
      'MacBook Air M2',
      'iPad Air',
      'Apple Pencil',
      'Magic Keyboard',
      'MagSafe充电器',
      '数据线套装',
      '保护壳',
      '膜套装',
      '移动电源',
      '蓝牙音箱',
      '智能手环',
      '无线鼠标',
    ];
    return names[index % names.length];
  }

  static List<String> _getProductColors(int index) {
    final colorOptions = [
      ['深空黑', '银色', '金色', '暗紫色'],
      ['深空灰', '银色', '金色'],
      ['深空灰', '银色', '金色', '蓝色'],
      ['白色'],
      ['午夜色', '星光色', '银色', '绿色', '蓝色'],
      ['蓝色', '绿色', '粉色', '银色', '黄色', '橙色', '紫色'],
      ['银色', '深空灰', '绿色', '蓝色', '粉色'],
      ['黑色', '白色'],
      ['深空灰', '银色', '金色', '蓝色', '紫色'],
      ['深空灰', '银色', '金色', '蓝色', '紫色'],
    ];
    return colorOptions[index % colorOptions.length];
  }

  static List<List<String>> _getSizeOptions() {
    return [
      ['128GB', '256GB', '512GB', '1TB'],
      ['14英寸', '16英寸'],
      ['11英寸', '12.9英寸'],
      [],
      ['41mm', '45mm'],
      ['M3芯片', 'M3 Pro芯片', 'M3 Max芯片'],
      ['银色', '深空灰'],
      ['128GB', '256GB', '512GB'],
      ['8GB+256GB', '8GB+512GB', '16GB+512GB'],
      ['64GB', '256GB', '512GB'],
      ['标准版', 'Pro版'],
      ['有线', '无线'],
      ['USB-C', 'Lightning', 'Type-C'],
      ['0.5m', '1m', '2m'],
      ['透明', '黑色', '白色'],
      ['钢化膜', '水凝膜'],
      ['10000mAh', '20000mAh'],
      ['便携版', '家用版'],
      ['S', 'M', 'L'],
      ['蓝牙5.0', '蓝牙3.0'],
    ];
  }

  static Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return [
      Category(
        id: 1,
        name: '手机通讯',
        icon: 'phone_iphone',
        children: [
          Category(id: 11, name: '智能手机', icon: 'smartphone'),
          Category(id: 12, name: '老人手机', icon: 'phone_android'),
          Category(id: 13, name: '手机配件', icon: 'headphones'),
        ],
      ),
      Category(
        id: 2,
        name: '电脑办公',
        icon: 'computer',
        children: [
          Category(id: 21, name: '笔记本电脑', icon: 'laptop'),
          Category(id: 22, name: '台式电脑', icon: 'desktop_windows'),
          Category(id: 23, name: '电脑配件', icon: 'memory'),
        ],
      ),
      Category(
        id: 3,
        name: '数码影音',
        icon: 'headphones',
        children: [
          Category(id: 31, name: '耳机耳塞', icon: 'headset'),
          Category(id: 32, name: '蓝牙音箱', icon: 'speaker'),
          Category(id: 33, name: '播放器', icon: 'music_note'),
        ],
      ),
      Category(
        id: 4,
        name: '智能穿戴',
        icon: 'watch',
        children: [
          Category(id: 41, name: '智能手表', icon: 'smartwatch'),
          Category(id: 42, name: '智能手环', icon: 'fitness_center'),
          Category(id: 43, name: 'VR设备', icon: 'vr_viewer'),
        ],
      ),
      Category(
        id: 5,
        name: '摄像摄影',
        icon: 'camera_alt',
        children: [
          Category(id: 51, name: '数码相机', icon: 'photo_camera'),
          Category(id: 52, name: '运动相机', icon: 'videocam'),
          Category(id: 53, name: '监控摄像头', icon: 'videocam_off'),
        ],
      ),
      Category(
        id: 6,
        name: '游戏设备',
        icon: 'sports_esports',
        children: [
          Category(id: 61, name: '游戏主机', icon: 'sports_esports'),
          Category(id: 62, name: '游戏手柄', icon: 'gamepad'),
          Category(id: 63, name: '游戏周边', icon: 'keyboard'),
        ],
      ),
      Category(
        id: 7,
        name: '智能家居',
        icon: 'home',
        children: [
          Category(id: 71, name: '智能音箱', icon: 'speaker'),
          Category(id: 72, name: '智能门锁', icon: 'lock'),
          Category(id: 73, name: '智能灯泡', icon: 'lightbulb'),
        ],
      ),
      Category(
        id: 8,
        name: '配件办公',
        icon: 'cable',
        children: [
          Category(id: 81, name: '数据线', icon: 'cable'),
          Category(id: 82, name: '充电器', icon: 'power'),
          Category(id: 83, name: '移动电源', icon: 'battery_full'),
        ],
      ),
    ];
  }

  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List.generate(10, (index) {
      return Product(
        id: categoryId * 100 + index + 1,
        name: '商品 ${categoryId * 100 + index + 1}',
        price: 59.0 + (index * 20),
        originalPrice: 99.0 + (index * 30),
        image:
            'https://picsum.photos/300/300?random=${categoryId * 10 + index}',
        sales: 50 + index * 20,
        rating: 4.0 + (index % 5) * 0.2,
        description: '高品质商品，性价比超高',
        categoryId: categoryId,
        stock: 50,
      );
    });
  }

  static Future<List<Post>> getPosts({String type = 'recommend'}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final userNames = ['科技小王', '数码达人', '生活家', '极客青年', '评测师'];
    final titles = [
      '分享一款超好用的无线耳机',
      '最近入手的平板电脑体验分享',
      '智能手表日常使用感受',
      '手机配件推荐清单',
      '数码产品开箱分享',
      '我的数码装备升级之路',
      '性价比高的电子产品推荐',
      '新手入坑数码必看指南',
    ];
    final contents = [
      '这款产品真的太好用了，强烈推荐给大家！性价比超高，体验感满分。',
      '使用了一段时间，感觉非常棒。续航能力强，充电速度快，很满意。',
      '外观设计漂亮，性能也很强大。适合日常使用，值得购买。',
      '经过多方对比，最终选择了这款。确实没有让我失望，好评！',
      '质量很好，材质环保，用起来很放心。会推荐给朋友。',
    ];

    return List.generate(15, (index) {
      final imageCount = (index % 3) + 1;
      return Post(
        id: index + 1,
        title: titles[index % titles.length],
        content: contents[index % contents.length],
        images: List.generate(
          imageCount,
          (i) => 'https://picsum.photos/400/300?random=${index * 10 + i}',
        ),
        author: User(
          id: index + 1,
          name: userNames[index % userNames.length],
          avatar: 'https://picsum.photos/100/100?random=${index + 50}',
        ),
        likes: 100 + index * 30,
        comments: 10 + index * 5,
        createTime: DateTime.now().subtract(Duration(hours: index * 2)),
        isLiked: index % 3 == 0,
        isCollected: index % 4 == 0,
      );
    });
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'id': 1,
      'name': '用户12345',
      'avatar': 'https://picsum.photos/200/200?random=100',
      'phone': '138****8888',
      'level': 3,
      'points': 1250,
    };
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return [
      {'id': 1, 'status': 'pending', 'count': 2, 'total': 2999.0},
      {'id': 2, 'status': 'shipped', 'count': 1, 'total': 1599.0},
      {'id': 3, 'status': 'completed', 'count': 3, 'total': 4599.0},
      {'id': 4, 'status': 'completed', 'count': 1, 'total': 899.0},
    ];
  }
}
