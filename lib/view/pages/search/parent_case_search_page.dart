part of my_reunify_app;

/// ===============================================
/// PARENT CASE SEARCH PAGE
/// ===============================================

class ModernParentCaseSearchPage extends StatefulWidget {
  final EnhancedMockDataRepository repository;
  final String userEmail;

  const ModernParentCaseSearchPage({
    super.key,
    required this.repository,
    required this.userEmail,
  });

  @override
  State<ModernParentCaseSearchPage> createState() =>
      _ModernParentCaseSearchPageState();
}

class _ModernParentCaseSearchPageState extends State<ModernParentCaseSearchPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<ParentCase> _allCases = [];
  List<ParentCase> _filteredCases = [];
  bool _isLoading = true;
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
      _filterCases();
    });
    _loadCases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCases() async {
    final cases = await widget.repository.getAllCases();
    if (mounted) {
      setState(() {
        _allCases = cases;
        _filteredCases = cases;
        _isLoading = false;
      });
    }
  }

  void _filterCases() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCases =
          _allCases.where((c) {
            final matchesQuery =
                c.childName.toLowerCase().contains(query) ||
                c.description.toLowerCase().contains(query) ||
                c.lastKnownLocationText.toLowerCase().contains(query);

            final statusFilter =
                [
                  'ongoing', // Tab 0
                  'past', // Tab 1
                  'resolved', // Tab 2
                ][_selectedTab];

            final matchesStatus = c.status == statusFilter;

            return matchesQuery && matchesStatus;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Cases'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => _filterCases(),
                          decoration: InputDecoration(
                            hintText: 'Search by name, location...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.schedule, size: 18),
                                  SizedBox(width: 8),
                                  Text('Ongoing'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history, size: 18),
                                  SizedBox(width: 8),
                                  Text('Past'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 18),
                                  SizedBox(width: 8),
                                  Text('Resolved'),
                                ],
                              ),
                            ),
                          ],
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Case list
                  Expanded(
                    child:
                        _filteredCases.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: AppColors.textSecondary.withOpacity(
                                      0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No cases found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your filters',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: _filteredCases.length,
                              itemBuilder: (context, index) {
                                final c = _filteredCases[index];
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
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              c.childName[0],
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
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
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      c.lastKnownLocationText,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            AppColors
                                                                .textSecondary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _statusColor(
                                                    c.status,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  c.status.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _statusColor(
                                                      c.status,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
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
}
