part of my_reunify_app;

/// ===============================================
/// CASE DETAIL PAGE (legacy, kept for compat)
/// ===============================================

class CaseDetailPage extends StatelessWidget {
  final ParentCase caseItem;
  final EnhancedMockDataRepository repository;

  const CaseDetailPage({
    super.key,
    required this.caseItem,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return ParentCaseReportDetailPage(
      caseItem: caseItem,
      repository: repository,
    );
  }
}

/// ===============================================
/// MEMORY MATCH DETAIL PAGE (legacy compat)
/// ===============================================

class MemoryMatchDetailPage extends StatelessWidget {
  final ChildMemory memory;
  final List<MatchResult> matchResults;
  final EnhancedMockDataRepository repository;
  final EnhancedMatchingService matchingService;

  const MemoryMatchDetailPage({
    super.key,
    required this.memory,
    required this.matchResults,
    required this.repository,
    required this.matchingService,
  });

  @override
  Widget build(BuildContext context) {
    return ChildMemoryReportDetailPage(
      memory: memory,
      matchResults: matchResults,
      repository: repository,
      matchingService: matchingService,
    );
  }
}
