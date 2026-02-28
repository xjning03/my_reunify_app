part of my_reunify_app;

/// Domain models shared across the app (MVC: Model layer).
class ParentCase {
  final String id;
  final String childName;
  final int childAge;
  final String description;
  final String lastKnownLocationText;
  final double latitude;
  final double longitude;
  final DateTime reportedAt;
  final DateTime? lastUpdated;
  final String status; // 'ongoing', 'past', 'resolved'
  final List<String> photos;
  final String reporterName;
  final String reporterEmail;
  final String reporterContact;
  final List<String> tags;
  final int viewCount;
  final List<String> matchIds;
  final String? caseImageUrl;

  ParentCase({
    required this.id,
    required this.childName,
    required this.childAge,
    required this.description,
    required this.lastKnownLocationText,
    required this.latitude,
    required this.longitude,
    required this.reportedAt,
    this.lastUpdated,
    required this.status,
    required this.photos,
    required this.reporterName,
    required this.reporterEmail,
    required this.reporterContact,
    required this.tags,
    this.viewCount = 0,
    this.matchIds = const [],
    this.caseImageUrl,
  });

  /// Determine if case is ongoing (< 3 months) or past (>= 3 months)
  /// Returns 'ongoing', 'past', or the current status if 'resolved'
  String getTimelineStatus() {
    if (status == 'resolved') return 'resolved';

    final daysMissing = DateTime.now().difference(reportedAt).inDays;
    if (daysMissing < 90) {
      return 'ongoing'; // Less than 3 months
    } else {
      return 'past'; // 3 months or more
    }
  }

  /// Get formatted timeline for display
  String getTimelineSummary() {
    final daysMissing = DateTime.now().difference(reportedAt).inDays;
    if (daysMissing < 1) return 'Missing today';
    if (daysMissing == 1) return 'Missing for 1 day';
    if (daysMissing < 7) return 'Missing for $daysMissing days';

    final weeksMissing = (daysMissing / 7).floor();
    if (weeksMissing < 4) return 'Missing for $weeksMissing weeks';

    final monthsMissing = (daysMissing / 30).floor();
    if (monthsMissing < 12) return 'Missing for $monthsMissing months';

    final yearsMissing = (daysMissing / 365).floor();
    return 'Missing for $yearsMissing year${yearsMissing > 1 ? 's' : ''}';
  }
}

class ChildMemory {
  final String id;
  final String text;
  final String language;
  final DateTime rememberedAt;
  final double? latitude;
  final double? longitude;
  final String childIdentifier;
  final List<String> emotions;
  final int confidenceLevel; // 1-5 scale
  final List<String> mediaUrls;
  final String? childName;
  final String? childRace;

  ChildMemory({
    required this.id,
    required this.text,
    required this.language,
    required this.rememberedAt,
    this.latitude,
    this.longitude,
    required this.childIdentifier,
    required this.emotions,
    this.confidenceLevel = 3,
    this.mediaUrls = const [],
    this.childName,
    this.childRace,
  });
}

enum KeywordType { placeType, nature, language, sound, emotion, timeOfDay }

class Keyword {
  final String value;
  final KeywordType type;
  final double weight;
  final double confidence;

  Keyword({
    required this.value,
    required this.type,
    required this.weight,
    this.confidence = 1.0,
  });
}

class POI {
  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final double popularity;
  final List<String> languages;
  final Map<String, dynamic> metadata;
  final String? description;

  POI({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.popularity,
    required this.languages,
    required this.metadata,
    this.description,
  });
}

class MatchResult {
  final ParentCase parentCase;
  final double score;
  final List<String> explanations;
  final Map<String, double> contributingFactors;
  final List<POI> matchedPois;
  final double proximityScore;
  final double timeRelevanceScore;
  final DateTime matchedAt;
  final String matchId;

  MatchResult({
    required this.parentCase,
    required this.score,
    required this.explanations,
    required this.contributingFactors,
    required this.matchedPois,
    required this.proximityScore,
    required this.timeRelevanceScore,
    DateTime? matchedAt,
    String? matchId,
  }) : matchedAt = matchedAt ?? DateTime.now(),
       matchId = matchId ?? DateTime.now().millisecondsSinceEpoch.toString();
}

class TimelineEvent {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final String? actionUrl;

  TimelineEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.actionUrl,
  });
}

class NotificationMessage {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'match', 'update', 'urgent'
  final bool isRead;
  final String? relatedCaseId;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.relatedCaseId,
  });
}

/// Chat between parent and child (e.g. about a case / memory match).
class ChatMessage {
  final String id;
  final String conversationId;
  final bool isFromParent;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.isFromParent,
    required this.text,
    required this.timestamp,
  });
}

/// A conversation thread summary shown in the inbox list.
class ConversationThread {
  final String conversationId;
  final String title;
  final String subtitle;
  final String? caseId;
  final DateTime lastActivity;
  final bool hasUnread;

  ConversationThread({
    required this.conversationId,
    required this.title,
    required this.subtitle,
    this.caseId,
    required this.lastActivity,
    this.hasUnread = false,
  });
}
