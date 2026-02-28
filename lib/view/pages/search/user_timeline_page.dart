part of my_reunify_app;

/// ===============================================
/// USER TIMELINE PAGE
/// ===============================================

class ModernUserTimelinePage extends StatefulWidget {
  final EnhancedMockDataRepository repository;
  final UserRole role;
  final String? userEmail;
  final String? childIdentifier;
  final EnhancedMatchingService? matchingService;

  const ModernUserTimelinePage({
    super.key,
    required this.repository,
    required this.role,
    this.userEmail,
    this.childIdentifier,
    this.matchingService,
  });

  @override
  State<ModernUserTimelinePage> createState() => _ModernUserTimelinePageState();
}

class _ModernUserTimelinePageState extends State<ModernUserTimelinePage> {
  List<ParentCase> _parentCases = [];
  List<ChildReportItem> _childReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void didUpdateWidget(ModernUserTimelinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.userEmail != widget.userEmail ||
        oldWidget.childIdentifier != widget.childIdentifier) {
      _loadReports();
    }
  }

  Future<void> _loadReports() async {
    final isParent = widget.role == UserRole.parent;

    if (isParent && widget.userEmail != null) {
      final cases = await widget.repository.getCasesByReporterEmail(
        widget.userEmail!,
      );
      if (mounted) {
        setState(() {
          _parentCases = cases;
          _childReports = [];
          _isLoading = false;
        });
      }
      return;
    }

    if (!isParent &&
        widget.childIdentifier != null &&
        widget.matchingService != null) {
      final memories = await widget.repository.getMemoriesByChildIdentifier(
        widget.childIdentifier!,
      );
      final allCases = await widget.repository.getAllCases();
      final reports = <ChildReportItem>[];
      for (final m in memories) {
        final results = await widget.matchingService!.matchMemoryToCases(
          m,
          allCases,
        );
        reports.add(ChildReportItem(memory: m, matchResults: results));
      }
      reports.sort(
        (a, b) => b.memory.rememberedAt.compareTo(a.memory.rememberedAt),
      );
      if (mounted) {
        setState(() {
          _parentCases = [];
          _childReports = reports;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted)
      setState(() {
        _parentCases = [];
        _childReports = [];
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final isParent = widget.role == UserRole.parent;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : isParent
              ? _parentCases.isEmpty
                  ? _buildEmptyState(true)
                  : _buildParentReportList()
              : _childReports.isEmpty
              ? _buildEmptyState(false)
              : _buildChildReportList(),
    );
  }

  Widget _buildEmptyState(bool isParent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isParent
                ? 'Report a case to see it here'
                : 'Share memories to help families find you',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildParentReportList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _parentCases.length,
      itemBuilder: (context, index) {
        final c = _parentCases[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SmartCard(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ParentCaseReportDetailPage(
                          caseItem: c,
                          repository: widget.repository,
                        ),
                  ),
                ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_search,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Case: ${c.childName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.lastKnownLocationText,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDetailedTime(c.reportedAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(c.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              c.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: _statusColor(c.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChildReportList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _childReports.length,
      itemBuilder: (context, index) {
        final item = _childReports[index];
        final preview =
            item.memory.text.length > 60
                ? '${item.memory.text.substring(0, 60)}...'
                : item.memory.text;
        final matchCount = item.matchResults.length;
        final topScore = matchCount > 0 ? item.matchResults.first.score : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SmartCard(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChildMemoryReportDetailPage(
                          memory: item.memory,
                          matchResults: item.matchResults,
                          repository: widget.repository,
                          matchingService: widget.matchingService!,
                        ),
                  ),
                ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My memory',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Confidence level chips row
                      Row(
                        children: [
                          _confidenceChip(item.memory.confidenceLevel),
                          const SizedBox(width: 8),
                          if (matchCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _scoreColor(topScore).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$matchCount match${matchCount != 1 ? 'es' : ''} · top ${topScore.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _scoreColor(topScore),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Text(
                              'No matches yet',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDetailedTime(item.memory.rememberedAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _confidenceChip(int level) {
    final labels = ['Very Vague', 'Vague', 'Moderate', 'Clear', 'Very Clear'];
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.warning,
      AppColors.success,
      AppColors.success,
    ];
    final label = labels[level - 1];
    final color = colors[level - 1];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ongoing':
        return AppColors.warning;
      case 'past':
        return AppColors.secondary;
      case 'resolved':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _scoreColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDetailedTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0)
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0)
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes > 0)
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }
}

class ChildReportItem {
  final ChildMemory memory;
  final List<MatchResult> matchResults;

  ChildReportItem({required this.memory, required this.matchResults});
}
