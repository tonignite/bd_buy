import 'package:flutter/material.dart';

/// Un supermercado donde se compran productos.
///
/// Ya no es un enum fijo: es un dato editable, por lo que se pueden añadir,
/// renombrar o borrar supermercados desde la pantalla de gestión.
class Supermarket {
  Supermarket({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  final String id;
  String name;
  int colorValue;

  Color get color => Color(colorValue);

  Supermarket copyWith({String? name, int? colorValue}) => Supermarket(
        id: id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': colorValue,
      };

  factory Supermarket.fromJson(Map<String, dynamic> json) => Supermarket(
        id: json['id'] as String,
        name: json['name'] as String,
        colorValue: (json['color'] as num).toInt(),
      );

  /// Colores disponibles al crear un supermercado nuevo.
  static const List<int> palette = [
    0xFF546E7A,
    0xFF7B3FA0,
    0xFF00A650,
    0xFF004E9F,
    0xFFE30613,
    0xFFFFB300,
    0xFF1E4B9B,
    0xFFF07D00,
    0xFF00897B,
    0xFFD81B60,
    0xFF3949AB,
    0xFF6D4C41,
  ];
}
