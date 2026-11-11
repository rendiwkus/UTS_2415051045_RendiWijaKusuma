class OrderModel {
  final String? id;
  final String customerName;
  final String? customerPhone;
  final String productName;
  final String category;
  final int quantity;
  final String orderType; // 'pre_order' atau 'direct'
  final String deliveryAddress;
  final DateTime deliveryDate;
  final String? notes;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;

  OrderModel({
    this.id,
    required this.customerName,
    this.customerPhone,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.orderType,
    required this.deliveryAddress,
    required this.deliveryDate,
    this.notes,
    required this.totalPrice,
    this.status = 'Pending',
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String?,
      customerName: json['customer_name'] as String? ?? '',
      customerPhone: json['customer_phone'] as String?,
      productName: json['product_name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      orderType: json['order_type'] as String? ?? 'direct',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'product_name': productName,
      'category': category,
      'quantity': quantity,
      'order_type': orderType,
      'delivery_address': deliveryAddress,
      'delivery_date':
          "${deliveryDate.year.toString().padLeft(4, '0')}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}",
      'notes': notes,
      'total_price': totalPrice,
      'status': status,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    return map;
  }

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? productName,
    String? category,
    int? quantity,
    String? orderType,
    String? deliveryAddress,
    DateTime? deliveryDate,
    String? notes,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      orderType: orderType ?? this.orderType,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      notes: notes ?? this.notes,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

