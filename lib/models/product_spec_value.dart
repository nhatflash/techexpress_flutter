
class ProductSpecValue {
  final String specDefinitionId;
  final String specName;
  final String unit;
  final String code;
  final String dataType;
  final String value;

  ProductSpecValue({
    required this.specDefinitionId,
    required this.specName,
    required this.unit,
    required this.code,
    required this.dataType,
    required this.value
  });

  factory ProductSpecValue.fromJson(Map<String, dynamic> json) {
    return ProductSpecValue(
      specDefinitionId: json['specDefinitionId'], 
      specName: json['specName'], 
      unit: json['unit'], 
      code: json['code'], 
      dataType: json['dataType'],
      value: json['value']
    );
  }
}