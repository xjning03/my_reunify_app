part of my_reunify_app;

/// ===============================================
/// PARENT CASE REPORT DETAIL PAGE
/// ===============================================

class ParentCaseReportDetailPage extends StatelessWidget {
  final ParentCase caseItem;
  final EnhancedMockDataRepository repository;

  const ParentCaseReportDetailPage({
    super.key,
    required this.caseItem,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            SmartCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    caseItem.childName[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                caseItem.childName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Age ${caseItem.childAge}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _statBox(
                          'Views',
                          '${caseItem.viewCount}',
                          Icons.visibility,
                        ),
                        const SizedBox(width: 8),
                        _statBox(
                          'Matches',
                          '${caseItem.matchIds.length}',
                          Icons.link,
                        ),
                        const SizedBox(width: 8),
                        _statBox(
                          'Status',
                          caseItem.status
                              .split('_')
                              .map(
                                (w) => '${w[0].toUpperCase()}${w.substring(1)}',
                              )
                              .join(' '),
                          Icons.info_outline,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmartCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.timeline, 'Case Timeline'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          caseItem.getTimelineStatus() == 'ongoing'
                              ? AppColors.warning.withOpacity(0.05)
                              : AppColors.secondary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            caseItem.getTimelineStatus() == 'ongoing'
                                ? AppColors.warning.withOpacity(0.3)
                                : AppColors.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              caseItem.getTimelineStatus() == 'ongoing'
                                  ? Icons.schedule
                                  : Icons.history,
                              color:
                                  caseItem.getTimelineStatus() == 'ongoing'
                                      ? AppColors.warning
                                      : AppColors.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                caseItem.getTimelineStatus() == 'ongoing'
                                    ? 'Ongoing Case'
                                    : 'Past Case',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      caseItem.getTimelineStatus() == 'ongoing'
                                          ? AppColors.warning
                                          : AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          caseItem.getTimelineSummary(),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reported: ${_formatDate(caseItem.reportedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmartCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.description, 'Description'),
                  const SizedBox(height: 10),
                  Text(
                    caseItem.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmartCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.location_on, 'Last Known Location'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.place,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          caseItem.lastKnownLocationText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 36,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          Text(
                            'Map view',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmartCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.label, 'Tags'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        caseItem.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
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
            SmartCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.person, 'Reporter'),
                  const SizedBox(height: 12),
                  _infoRow(Icons.badge, caseItem.reporterName),
                  const SizedBox(height: 8),
                  _infoRow(Icons.email, caseItem.reporterEmail),
                  const SizedBox(height: 8),
                  _infoRow(Icons.phone, caseItem.reporterContact),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SmartCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.timeline, 'Case Timeline'),
                  const SizedBox(height: 12),
                  _timelineItem(
                    Icons.add_circle,
                    'Case reported',
                    caseItem.reportedAt,
                    AppColors.primary,
                  ),
                  if (caseItem.lastUpdated != null)
                    _timelineItem(
                      Icons.update,
                      'Last updated',
                      caseItem.lastUpdated!,
                      AppColors.warning,
                    ),
                  _timelineItem(
                    Icons.visibility,
                    '${caseItem.viewCount} people viewed this case',
                    caseItem.reportedAt,
                    AppColors.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ChatPage(
                              conversationId: 'case_${caseItem.id}',
                              otherPartyLabel: 'Matched contacts',
                              repository: repository,
                              isParent: true,
                            ),
                      ),
                    ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Open Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem(IconData icon, String text, DateTime time, Color color) {
    final diff = DateTime.now().difference(time);
    String ago;
    if (diff.inDays > 0)
      ago = '${diff.inDays}d ago';
    else if (diff.inHours > 0)
      ago = '${diff.inHours}h ago';
    else
      ago = '${diff.inMinutes}m ago';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            ago,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
