part of my_reunify_app;

/// ===============================================
/// MODERN MATCH RESULTS PAGE
/// ===============================================

class ModernMatchResultsPage extends StatelessWidget {
  final List<MatchResult> results;
  final EnhancedMockDataRepository repository;

  const ModernMatchResultsPage({
    super.key,
    required this.results,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${results.length} Match${results.length == 1 ? '' : 'es'} Found',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body:
          results.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No matches yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep sharing details to find matches',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final r = results[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ModernMatchCard(
                      result: r,
                      rank: index + 1,
                      repository: repository,
                    ),
                  );
                },
              ),
    );
  }
}

class ModernMatchCard extends StatelessWidget {
  final MatchResult result;
  final int rank;
  final EnhancedMockDataRepository repository;

  const ModernMatchCard({
    super.key,
    required this.result,
    required this.rank,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return SmartCard(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ModernCaseDetailPage(
                    case_: result.parentCase,
                    repository: repository,
                  ),
            ),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.parentCase.childName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Age ${result.parentCase.childAge}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(result.score).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getScoreColor(result.score),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${result.score.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _getScoreColor(result.score),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConfidenceMeter(
            confidence: result.score / 100,
            label: 'Match Confidence',
          ),
          const SizedBox(height: 16),
          const Text(
            'Why this match?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...result.explanations
              .take(3)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (result.explanations.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${result.explanations.length - 3} more reasons',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ModernCaseDetailPage(
                            case_: result.parentCase,
                            repository: repository,
                          ),
                    ),
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('View Full Case'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
