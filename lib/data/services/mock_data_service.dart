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
          Category(
            id: 11,
            name: '手机类型',
            icon: 'smartphone',
            children: [
              Category(id: 111, name: '智能手机', icon: 'smartphone'),
              Category(id: 112, name: '老人手机', icon: 'phone_android'),
              Category(id: 113, name: '游戏手机', icon: 'sports_esports'),
              Category(id: 114, name: '5G手机', icon: 'signal_cellular_alt'),
            ],
          ),
          Category(
            id: 12,
            name: '手机配件',
            icon: 'headphones',
            children: [
              Category(id: 121, name: '手机壳', icon: 'phone_iphone'),
              Category(id: 122, name: '充电器', icon: 'battery_full'),
              Category(id: 123, name: '数据线', icon: 'cable'),
              Category(id: 124, name: '贴膜', icon: 'crop_square'),
            ],
          ),
        ],
      ),
      Category(
        id: 2,
        name: '电脑办公',
        icon: 'computer',
        children: [
          Category(
            id: 21,
            name: '电脑类型',
            icon: 'computer',
            children: [
              Category(id: 211, name: '笔记本电脑', icon: 'laptop'),
              Category(id: 212, name: '台式电脑', icon: 'desktop_windows'),
              Category(id: 213, name: '平板电脑', icon: 'tablet_mac'),
              Category(id: 214, name: '一体机', icon: 'computer'),
            ],
          ),
          Category(
            id: 22,
            name: '电脑配件',
            icon: 'memory',
            children: [
              Category(id: 221, name: '内存条', icon: 'memory'),
              Category(id: 222, name: '硬盘', icon: 'storage'),
              Category(id: 223, name: '显卡', icon: 'developer_board'),
              Category(id: 224, name: '显示器', icon: 'desktop_mac'),
            ],
          ),
        ],
      ),
      Category(
        id: 3,
        name: '数码影音',
        icon: 'headphones',
        children: [
          Category(
            id: 31,
            name: '耳机音箱',
            icon: 'headphones',
            children: [
              Category(id: 311, name: '有线耳机', icon: 'headset'),
              Category(id: 312, name: '蓝牙耳机', icon: 'bluetooth_audio'),
              Category(id: 313, name: '蓝牙音箱', icon: 'speaker'),
            ],
          ),
          Category(
            id: 32,
            name: '影音设备',
            icon: 'music_note',
            children: [
              Category(id: 321, name: '播放器', icon: 'music_note'),
              Category(id: 322, name: '麦克风', icon: 'mic'),
              Category(id: 323, name: '录音笔', icon: 'graphic_eq'),
            ],
          ),
        ],
      ),
      Category(
        id: 4,
        name: '智能穿戴',
        icon: 'watch',
        children: [
          Category(
            id: 41,
            name: '智能手表',
            icon: 'watch',
            children: [
              Category(id: 411, name: '运动手表', icon: 'fitness_center'),
              Category(id: 412, name: '时尚手表', icon: 'watch_later'),
            ],
          ),
          Category(
            id: 42,
            name: '智能设备',
            icon: 'devices',
            children: [
              Category(id: 421, name: '智能手环', icon: 'watch'),
              Category(id: 422, name: 'VR设备', icon: 'view_in_ar'),
            ],
          ),
        ],
      ),
      Category(
        id: 5,
        name: '摄像摄影',
        icon: 'camera_alt',
        children: [
          Category(
            id: 51,
            name: '相机设备',
            icon: 'photo_camera',
            children: [
              Category(id: 511, name: '数码相机', icon: 'photo_camera'),
              Category(id: 512, name: '运动相机', icon: 'videocam'),
            ],
          ),
          Category(
            id: 52,
            name: '摄影配件',
            icon: 'camera_enhance',
            children: [
              Category(id: 521, name: '三脚架', icon: 'straighten'),
              Category(id: 522, name: '存储卡', icon: 'sd_storage'),
              Category(id: 523, name: '相机包', icon: 'bag'),
            ],
          ),
        ],
      ),
      Category(
        id: 6,
        name: '游戏设备',
        icon: 'sports_esports',
        children: [
          Category(
            id: 61,
            name: '主机设备',
            icon: 'sports_esports',
            children: [
              Category(id: 611, name: '游戏主机', icon: 'sports_esports'),
              Category(id: 612, name: '掌机', icon: 'gamepad'),
            ],
          ),
          Category(
            id: 62,
            name: '游戏配件',
            icon: 'keyboard',
            children: [
              Category(id: 621, name: '游戏手柄', icon: 'gamepad'),
              Category(id: 622, name: '游戏键盘', icon: 'keyboard'),
              Category(id: 623, name: '游戏鼠标', icon: 'mouse'),
            ],
          ),
        ],
      ),
      Category(
        id: 7,
        name: '智能家居',
        icon: 'home',
        children: [
          Category(
            id: 71,
            name: '智能音箱',
            icon: 'speaker',
            children: [
              Category(id: 711, name: '智能音箱', icon: 'speaker'),
              Category(id: 712, name: '智能屏', icon: 'tablet'),
            ],
          ),
          Category(
            id: 72,
            name: '智能安防',
            icon: 'lock',
            children: [
              Category(id: 721, name: '智能门锁', icon: 'lock'),
              Category(id: 722, name: '监控摄像头', icon: 'videocam'),
              Category(id: 723, name: '智能门铃', icon: 'doorbell'),
            ],
          ),
          Category(
            id: 73,
            name: '智能照明',
            icon: 'lightbulb',
            children: [
              Category(id: 731, name: '智能灯泡', icon: 'lightbulb'),
              Category(id: 732, name: '智能灯带', icon: 'light_mode'),
            ],
          ),
        ],
      ),
      Category(
        id: 8,
        name: '配件办公',
        icon: 'cable',
        children: [
          Category(
            id: 81,
            name: '线缆配件',
            icon: 'cable',
            children: [
              Category(id: 811, name: '数据线', icon: 'cable'),
              Category(id: 812, name: '转接头', icon: 'usb'),
              Category(id: 813, name: '扩展坞', icon: 'hub'),
            ],
          ),
          Category(
            id: 82,
            name: '办公设备',
            icon: 'print',
            children: [
              Category(id: 821, name: '打印机', icon: 'print'),
              Category(id: 822, name: '扫描仪', icon: 'scanner'),
              Category(id: 823, name: '投影仪', icon: 'tv'),
            ],
          ),
        ],
      ),
    ];
  }

  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final productNames = <int, List<String>>{
      111: ['iPhone 15 Pro', 'iPhone 15', 'iPhone 14', 'iPhone SE'],
      112: ['诺基亚 老人机', '飞利浦 老人手机', '守护宝 老人手机'],
      113: ['红米 K70', '黑鲨 5 Pro', 'ROG 游戏手机'],
      114: ['华为 Mate 60 Pro', '小米 14', 'OPPO Find X7'],
      121: ['硅胶手机壳', '透明防摔壳', '磁吸手机壳'],
      122: ['20W 快充头', '65W 氮化镓充电器', '100W 超级快充'],
      123: ['Type-C 数据线', 'Lightning 数据线', '编织快充线'],
      124: ['钢化膜', '防窥膜', '磨砂保护膜'],
      211: ['MacBook Air M3', 'ThinkPad X1 Carbon', '华为 MateBook'],
      212: ['iMac 24寸', '联想 拯救者台式', 'DIY 游戏主机'],
      213: ['iPad Pro 12.9', '华为 MatePad Pro', '小米平板 6'],
      214: ['惠普 一体机', '苹果 iMac', '联想 AIO'],
      221: ['DDR5 16GB', 'DDR4 32GB', '笔记本内存条'],
      222: ['三星 1TB SSD', '西数 2TB 机械硬盘', '希捷 4TB'],
      223: ['RTX 4070', 'RTX 4090', 'AMD RX 7800 XT'],
      224: ['27寸 4K 显示器', '32寸 带鱼屏', '电竞 144Hz'],
      311: ['索尼 WH-1000XM5', 'Bose QC45', '森海塞尔 HD600'],
      312: ['AirPods Pro 2', '索尼 WF-1000XM5', '华为 FreeBuds Pro'],
      313: ['JBL Flip 6', 'Bose SoundLink', 'Marshall Emberton'],
      321: ['索尼 Walkman', '海贝 R6 Pro', '飞傲 M11'],
      322: ['Blue Yeti 麦克风', '铁桶 AT2020', '舒尔 SM7B'],
      323: ['索尼录音笔', '科大讯飞录音笔', '飞利浦录音笔'],
      411: ['Garmin Fenix 7', '颂拓 9 Peak', '佳明 Forerunner'],
      412: ['Apple Watch Ultra', '卡西欧 G-SHOCK', '华为 Watch GT4'],
      421: ['小米手环 8', '华为手环 8', '荣耀手环 7'],
      422: ['Meta Quest 3', 'PICO 4', 'PSVR 2'],
      511: ['索尼 A7M4', '佳能 R6 Mark II', '尼康 Z8'],
      512: ['GoPro Hero 12', '大疆 Action 4', 'Insta360'],
      521: ['碳纤维三脚架', '液压云台', '便携三脚架'],
      522: ['SDXC 128GB', 'CFexpress 卡', 'TF 卡 256GB'],
      523: ['单反相机包', '双肩摄影包', '防水内胆包'],
      611: ['PS5 光驱版', 'Xbox Series X', 'Switch OLED'],
      612: ['Steam Deck', '华硕 ROG Ally', '联想 Legion Go'],
      621: ['Xbox 手柄', 'PS5 DualSense', 'Switch Pro 手柄'],
      622: ['Cherry MX 机械键盘', '罗技 G915', '雷蛇黑寡妇'],
      623: ['罗技 GPW', '雷蛇毒蝰', '赛睿 Rival'],
      711: ['HomePod mini', '小爱音箱 Pro', '天猫精灵'],
      712: ['小度在家', '天猫精灵 CC', 'Home Hub'],
      721: ['小米智能门锁', '鹿客密码锁', '凯迪仕指纹锁'],
      722: ['小米摄像头', '萤石云摄像头', '360 智能摄像机'],
      723: ['小米门铃', 'Ring 门铃', '萤石可视门铃'],
      731: ['Philips Hue 灯泡', 'Yeelight 智能灯', '小米智能灯泡'],
      732: ['RGB 灯带', '氛围灯带', '小米灯带'],
      811: ['Type-C 编织线', 'Lightning 线', '三合一数据线'],
      812: ['Type-C 转 HDMI', 'USB 转接头', 'OTG 转换器'],
      813: ['贝尔金扩展坞', '绿联 10 合 1', 'CalDigit TS4'],
      821: ['惠普 LaserJet', '兄弟 彩色打印机', '佳能喷墨打印机'],
      822: ['惠普扫描仪', '富士通 馈纸式', '爱普生 平板扫描'],
      823: ['极米投影仪', '爱普生投影仪', '明基家用投影'],
    };

    final names =
        productNames[categoryId] ??
        [
          '商品 ${categoryId * 100 + 1}',
          '商品 ${categoryId * 100 + 2}',
          '商品 ${categoryId * 100 + 3}',
          '商品 ${categoryId * 100 + 4}',
        ];

    return List.generate(names.length, (index) {
      return Product(
        id: categoryId * 100 + index + 1,
        name: names[index],
        price: (59 + index * 150 + categoryId * 10).toDouble(),
        originalPrice: (99 + index * 200 + categoryId * 20).toDouble(),
        image:
            'https://picsum.photos/300/300?random=${categoryId * 10 + index}',
        sales: 50 + index * 120,
        rating: 4.0 + (index % 5) * 0.2,
        description: '高品质${names[index]}，性价比超高',
        categoryId: categoryId,
        stock: 50 + index * 10,
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
