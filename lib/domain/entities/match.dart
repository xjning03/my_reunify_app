class Match {
  final String id;
  final String parentCaseId;
  final String childCaseId;
  final double confidenceScore;
  final List<String> matchingReasons;
  final Map<String, double> scoringDetails;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final bool isConfirmed;

  Match({
    required this.id,
    required this.parentCaseId,
    required this.childCaseId,
    required this.confidenceScore,
    required this.matchingReasons,
    required this.scoringDetails,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    required this.isConfirmed,
  });

  Match copyWith({
    String? id,
    String? parentCaseId,
    String? childCaseId,
    double? confidenceScore,
    List<String>? matchingReasons,
    Map<String, double>? scoringDetails,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    bool? isConfirmed,
  }) {
    return Match(
      id: id ?? this.id,
      parentCaseId: parentCaseId ?? this.parentCaseId,
      childCaseId: childCaseId ?? this.childCaseId,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      matchingReasons: matchingReasons ?? this.matchingReasons,
      scoringDetails: scoringDetails ?? this.scoringDetails,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  @override
  String toString() =>
      'Match(parent: $parentCaseId, child: $childCaseId, score: $confidenceScore)';
}
