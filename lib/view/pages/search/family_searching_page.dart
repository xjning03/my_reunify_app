part of my_reunify_app;

/// ===============================================
/// FAMILY SEARCHING PAGE
/// ===============================================

class ModernFamilySearchingPage extends StatefulWidget {
  final EnhancedMockDataRepository repository;
  final String childIdentifier;

  const ModernFamilySearchingPage({
    super.key,
    required this.repository,
    required this.childIdentifier,
  });

  @override
  State<ModernFamilySearchingPage> createState() =>
      _ModernFamilySearchingPageState();
}

class _ModernFamilySearchingPageState extends State<ModernFamilySearchingPage> {
  List<ParentCase> _allCases = [];
  List<ParentCase> _highlightedCases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    final cases = await widget.repository.getAllCases();
    if (mounted) {
      setState(() {
        _allCases = cases;
        _highlightedCases = cases;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Families'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (_highlightedCases.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Most Urgent Cases',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._highlightedCases.take(2).map((c) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: SmartCard(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: AppColors.warning,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: AppColors.warning
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                c.childName[0],
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.warning,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.childName,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  c.lastKnownLocationText,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                            ],
                          ),
                        const Text(
                          'All Cases',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final c = _allCases[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SmartCard(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ModernCaseDetailPage(
                                          case_: c,
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
                                    color: AppColors.secondary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      c.childName[0],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.childName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Age ${c.childAge} • ${c.lastKnownLocationText}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: _allCases.length),
                    ),
                  ),
                  SliverPadding(padding: const EdgeInsets.all(24)),
                ],
              ),
    );
  }
}
