part of my_reunify_app;

/// ===============================================
/// CHILD MEMORY REPORT DETAIL PAGE
/// ===============================================

class ChildMemoryReportDetailPage extends StatelessWidget {
  final ChildMemory memory;
  final List<MatchResult> matchResults;
  final EnhancedMockDataRepository repository;
  final EnhancedMatchingService matchingService;

  const ChildMemoryReportDetailPage({
    super.key,
    required this.memory,
    required this.matchResults,
    required this.repository,
    required this.matchingService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Memory & Matches'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Memory card
            SmartCard(
              color: AppColors.secondary.withOpacity(0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'My Memory',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(memory.rememberedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    memory.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Confidence + emotions
            Row(
              children: [
                Expanded(
                  child: SmartCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Certainty',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            'Very Vague',
                            'Vague',
                            'Moderate',
                            'Clear',
                            'Very Clear',
                          ][memory.confidenceLevel - 1],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                memory.confidenceLevel >= 4
                                    ? AppColors.success
                                    : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: memory.confidenceLevel / 5,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            memory.confidenceLevel >= 4
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SmartCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Language',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          memory.language.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (memory.latitude != null)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: AppColors.success,
                              ),
                              Text(
                                ' GPS recorded',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Emotions
            if (memory.emotions.isNotEmpty)
              SmartCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How I felt',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children:
                          memory.emotions
                              .map(
                                (e) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _emotionColor(e).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _emotionColor(e).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _emotionColor(e),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            Text(
              'Potential Matches (${matchResults.length})',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            if (matchResults.isEmpty)
              SmartCard(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 40,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No matches found yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        'Try sharing more details',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...matchResults.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final r = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMatchCard(context, r, rank),
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchResult r, int rank) {
    final color =
        r.score >= 70
            ? AppColors.success
            : r.score >= 40
            ? AppColors.warning
            : AppColors.error;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border:
            rank == 1
                ? Border.all(color: color.withOpacity(0.5), width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
        color: AppColors.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.parentCase.childName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        r.parentCase.lastKnownLocationText,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Text(
                    '${r.score.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConfidenceMeter(
              confidence: r.score / 100,
              label: 'Match Confidence',
            ),
            if (r.explanations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Why this match?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              ...r.explanations
                  .take(3)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 13,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 6),
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
            ],
            if (r.contributingFactors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Score breakdown',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children:
                    r.contributingFactors.entries
                        .where((e) => e.value > 0)
                        .map(
                          (e) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${e.key}: +${e.value.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ModernCaseDetailPage(
                                  case_: r.parentCase,
                                  repository: repository,
                                ),
                          ),
                        ),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Case'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChatPage(
                                  conversationId:
                                      'case_${r.parentCase.id}_mem_${memory.id}',
                                  otherPartyLabel: r.parentCase.reporterName,
                                  repository: repository,
                                  isParent: false,
                                ),
                          ),
                        ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _emotionColor(String e) {
    switch (e.toLowerCase()) {
      case 'happy':
      case 'excited':
        return AppColors.success;
      case 'scared':
      case 'anxious':
      case 'worried':
        return AppColors.error;
      case 'confused':
        return AppColors.warning;
      case 'calm':
      case 'peaceful':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
