class Address {
  final int id;
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    this.isDefault = false,
  });

  String get fullAddress => '$province $city $district $detail';

  Address copyWith({
    int? id,
    String? name,
    String? phone,
    String? province,
    String? city,
    String? district,
    String? detail,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static List<Address> get mockAddresses => [
    const Address(
      id: 1,
      name: '张三',
      phone: '138****8888',
      province: '广东省',
      city: '深圳市',
      district: '南山区',
      detail: '科技园南路88号创新大厦A座1001室',
      isDefault: true,
    ),
    const Address(
      id: 2,
      name: '李四',
      phone: '139****9999',
      province: '北京市',
      city: '北京市',
      district: '海淀区',
      detail: '中关村大街1号',
      isDefault: false,
    ),
    const Address(
      id: 3,
      name: '王五',
      phone: '137****7777',
      province: '上海市',
      city: '上海市',
      district: '浦东新区',
      detail: '世纪大道100号环球金融中心',
      isDefault: false,
    ),
  ];
}
