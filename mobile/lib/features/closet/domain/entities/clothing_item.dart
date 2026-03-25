class ClothingItem {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String? brand;
  final String? color;
  final String? colorHex;
  final String? fabric;
  final String? season;
  final String imageUrl;
  final String? thumbnailUrl;
  final String status; // available, in_use, in_laundry, stored
  final double? purchasePrice;
  final DateTime? purchaseDate;
  final int wearCount;
  final DateTime? lastWornDate;
  final List<String> tags;
  final List<String> occasions;
  final Map<String, dynamic>? mlMetadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClothingItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.brand,
    this.color,
    this.colorHex,
    this.fabric,
    this.season,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.status,
    this.purchasePrice,
    this.purchaseDate,
    this.wearCount = 0,
    this.lastWornDate,
    this.tags = const [],
    this.occasions = const [],
    this.mlMetadata,
    required this.createdAt,
    required this.updatedAt,
  });

  double get costPerWear {
    if (purchasePrice == null || wearCount == 0) return 0;
    return purchasePrice! / wearCount;
  }

  bool get isAvailable => status == 'available';
  bool get isInUse => status == 'in_use';
  bool get isInLaundry => status == 'in_laundry';
  bool get isStored => status == 'stored';

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      colorHex: json['color_hex'] as String?,
      fabric: json['fabric'] as String?,
      season: json['season'] as String?,
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      status: json['status'] as String? ?? 'available',
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : null,
      wearCount: json['wear_count'] as int? ?? 0,
      lastWornDate: json['last_worn_date'] != null
          ? DateTime.parse(json['last_worn_date'] as String)
          : null,
      tags: List<String>.from(json['tags'] as List? ?? []),
      occasions: List<String>.from(json['occasions'] as List? ?? []),
      mlMetadata: json['ml_metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'category': category,
        'brand': brand,
        'color': color,
        'color_hex': colorHex,
        'fabric': fabric,
        'season': season,
        'image_url': imageUrl,
        'thumbnail_url': thumbnailUrl,
        'status': status,
        'purchase_price': purchasePrice,
        'purchase_date': purchaseDate?.toIso8601String(),
        'wear_count': wearCount,
        'last_worn_date': lastWornDate?.toIso8601String(),
        'tags': tags,
        'occasions': occasions,
        'ml_metadata': mlMetadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ClothingItem copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? brand,
    String? color,
    String? colorHex,
    String? fabric,
    String? season,
    String? imageUrl,
    String? thumbnailUrl,
    String? status,
    double? purchasePrice,
    DateTime? purchaseDate,
    int? wearCount,
    DateTime? lastWornDate,
    List<String>? tags,
    List<String>? occasions,
    Map<String, dynamic>? mlMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      colorHex: colorHex ?? this.colorHex,
      fabric: fabric ?? this.fabric,
      season: season ?? this.season,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      wearCount: wearCount ?? this.wearCount,
      lastWornDate: lastWornDate ?? this.lastWornDate,
      tags: tags ?? this.tags,
      occasions: occasions ?? this.occasions,
      mlMetadata: mlMetadata ?? this.mlMetadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PaginatedCloset {
  final List<ClothingItem> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedCloset({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory PaginatedCloset.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PaginatedCloset(
      items: (data['items'] as List)
          .map((e) => ClothingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['page_size'] as int,
      hasMore: data['has_more'] as bool,
    );
  }
}