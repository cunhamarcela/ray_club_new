// Package imports:
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_category.g.dart';

/// Modelo que representa uma categoria de treino
@JsonSerializable()
class WorkoutCategory extends Equatable {
  /// Identificador único da categoria
  final String id;
  
  /// Nome da categoria
  final String name;
  
  /// Descrição da categoria
  final String? description;
  
  /// URL da imagem da categoria
  final String imageUrl;
  
  /// Número de treinos nesta categoria
  final int workoutsCount;
  
  /// Ordem de exibição da categoria
  final int? order;
  
  /// Cor associada à categoria (em formato hexadecimal)
  final String? colorHex;

  /// Construtor
  const WorkoutCategory({
    required this.id,
    required this.name,
    this.description,
    required this.imageUrl,
    this.workoutsCount = 0,
    this.order,
    this.colorHex,
  });

  /// Cria um WorkoutCategory a partir de um Map JSON
  factory WorkoutCategory.fromJson(Map<String, dynamic> json) => _$WorkoutCategoryFromJson(json);

  /// Converte o WorkoutCategory para um Map JSON
  Map<String, dynamic> toJson() => _$WorkoutCategoryToJson(this);

  @override
  List<Object?> get props => [
    id, 
    name, 
    description, 
    imageUrl, 
    workoutsCount, 
    order, 
    colorHex
  ];

  /// Cria uma cópia desta categoria com os campos especificados atualizados
  WorkoutCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? workoutsCount,
    int? order,
    String? colorHex,
  }) {
    return WorkoutCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      workoutsCount: workoutsCount ?? this.workoutsCount,
      order: order ?? this.order,
      colorHex: colorHex ?? this.colorHex,
    );
  }
} 