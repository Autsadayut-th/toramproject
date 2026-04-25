class CustomEquipmentStat {
  const CustomEquipmentStat({
    required this.statKey,
    required this.value,
    this.valueType = 'flat',
  });

  final String statKey;
  final num value;
  final String valueType;

  factory CustomEquipmentStat.fromJson(Map<String, dynamic> json) {
    return CustomEquipmentStat(
      statKey: json['statKey']?.toString().trim() ?? '',
      value: _readNum(json['value']),
      valueType: json['valueType']?.toString().trim() ?? 'flat',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'statKey': statKey,
      'value': value,
      'valueType': valueType,
    };
  }

  CustomEquipmentStat copyWith({
    String? statKey,
    num? value,
    String? valueType,
  }) {
    return CustomEquipmentStat(
      statKey: statKey ?? this.statKey,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
    );
  }

  bool get isValid => statKey.trim().isNotEmpty;

  static num _readNum(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}
