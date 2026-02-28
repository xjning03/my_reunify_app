import 'package:my_reunify_app/domain/entities/memory_clue.dart';

enum CaseType { parent, child }

enum CaseStatus { open, matched, closed, inactive }

/// Represents a missing child or parent case with demographic and geographic data.
/// This is the primary entity in the case matching system.
class Case {
  final String id;
  final String userId;
  final CaseType type;
  final CaseStatus status;
  final String description;
  final String? photoUrl;
  final String? lastKnownLocation;
  final List<MemoryClue> memoryClues;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Demographic information (for inference matching)
  final String? childName;
  final String? childAge;
  final String? childRace;
  final String? childLanguage;
  final double? lastKnownLatitude;
  final double? lastKnownLongitude;
  final String? region; // Inferred or known region

  // Parent case fields
  final String? parentGuessedName;
  final List<String>? knownLanguages;
  final DateTime? estimatedMissingDate;

  Case({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.description,
    this.photoUrl,
    this.lastKnownLocation,
    required this.memoryClues,
    required this.createdAt,
    required this.updatedAt,
    this.childName,
    this.childAge,
    this.childRace,
    this.childLanguage,
    this.lastKnownLatitude,
    this.lastKnownLongitude,
    this.region,
    this.parentGuessedName,
    this.knownLanguages,
    this.estimatedMissingDate,
  });

  Case copyWith({
    String? id,
    String? userId,
    CaseType? type,
    CaseStatus? status,
    String? description,
    String? photoUrl,
    String? lastKnownLocation,
    List<MemoryClue>? memoryClues,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? childName,
    String? childAge,
    String? childRace,
    String? childLanguage,
    double? lastKnownLatitude,
    double? lastKnownLongitude,
    String? region,
    String? parentGuessedName,
    List<String>? knownLanguages,
    DateTime? estimatedMissingDate,
  }) {
    return Case(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      memoryClues: memoryClues ?? this.memoryClues,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      childName: childName ?? this.childName,
      childAge: childAge ?? this.childAge,
      childRace: childRace ?? this.childRace,
      childLanguage: childLanguage ?? this.childLanguage,
      lastKnownLatitude: lastKnownLatitude ?? this.lastKnownLatitude,
      lastKnownLongitude: lastKnownLongitude ?? this.lastKnownLongitude,
      region: region ?? this.region,
      parentGuessedName: parentGuessedName ?? this.parentGuessedName,
      knownLanguages: knownLanguages ?? this.knownLanguages,
      estimatedMissingDate: estimatedMissingDate ?? this.estimatedMissingDate,
    );
  }

  @override
  String toString() => 'Case(id: $id, type: $type, status: $status)';
}
