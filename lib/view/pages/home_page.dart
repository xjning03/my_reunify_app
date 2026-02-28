part of my_reunify_app;

/// ===============================================
/// REDESIGNED HOME PAGE
/// ===============================================

class ModernHomePage extends StatefulWidget {
  final EnhancedMockDataRepository repository;
  final EnhancedMatchingService matchingService;
  final AITagAnalysisService? tagAnalysisService;
  final UserRole role;

  const ModernHomePage({
    super.key,
    required this.repository,
    required this.matchingService,
    required this.role,
    this.tagAnalysisService,
  });

  @override
  State<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  int _reportRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder:
            (context) => ModernRoleSelectionPage(
              repository: widget.repository,
              matchingService: widget.matchingService,
            ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isParent = widget.role == UserRole.parent;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeView(),
          _buildCasesView(),
          _buildTimelineView(),
          // TAB 3: Chat Inbox (replaces Alerts/Notifications)
          ChatInboxPage(repository: widget.repository, isParent: isParent),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(isParent ? Icons.search : Icons.family_restroom),
              label: isParent ? 'Cases' : 'Families',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'My Report',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (isParent) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ModernParentFormPage(
                      repository: widget.repository,
                      tagAnalysisService: widget.tagAnalysisService,
                    ),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ModernChildMemoryFormPage(
                      repository: widget.repository,
                      matchingService: widget.matchingService,
                    ),
              ),
            );
          }
          if (!mounted) return;
          setState(() => _reportRefreshKey++);
        },
        icon: Icon(isParent ? Icons.add_circle : Icons.edit_note),
        label: Text(isParent ? 'Report Case' : 'Share Memory'),
        backgroundColor: AppColors.background,
      ),
    );
  }

  Widget _buildCasesView() {
    final isParent = widget.role == UserRole.parent;
    if (isParent) {
      return ModernParentCaseSearchPage(
        repository: widget.repository,
        userEmail: 'parent@example.com',
      );
    } else {
      return ModernFamilySearchingPage(
        repository: widget.repository,
        childIdentifier: 'child123',
      );
    }
  }

  Widget _buildTimelineView() {
    return ModernUserTimelinePage(
      key: ValueKey('report_$_reportRefreshKey'),
      repository: widget.repository,
      role: widget.role,
      userEmail: widget.role == UserRole.parent ? 'parent@example.com' : null,
      childIdentifier: widget.role == UserRole.child ? 'child123' : null,
      matchingService: widget.matchingService,
    );
  }

  Widget _buildHomeView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Reunify',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.settings, color: AppColors.primary),
                onSelected: (value) {
                  if (value == 'logout') _logout();
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeroSection(),
              const SizedBox(height: 24),
              _buildRecentActivitySection(),
              const SizedBox(height: 24),
              _buildFeaturedCasesSection(),
              const SizedBox(height: 24),
              _buildSuccessStoriesSection(),
              const SizedBox(height: 24),
              _buildHowItWorksSection(),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    final isParent = widget.role == UserRole.parent;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isParent
                  ? [AppColors.warning, AppColors.error]
                  : [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isParent ? AppColors.warning : AppColors.secondary)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isParent ? Icons.family_restroom : Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isParent
                      ? 'Your voice matters. Report a case and rally the community.'
                      : 'Every memory is a clue. Share what you remember.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community Active',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              Text(
                '24/7 Support',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return FutureBuilder<List<TimelineEvent>>(
      future: widget.repository.getTimeline(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const SizedBox.shrink();
        final recentEvents = snapshot.data!.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Report',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 2),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: event.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(event.icon, color: event.color, size: 20),
                    ),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      event.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTimeAgo(event.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedCasesSection() {
    return FutureBuilder<List<ParentCase>>(
      future: widget.repository.getCasesByStatus('ongoing'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final cases = snapshot.data!.take(3).toList();
        if (cases.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Featured Cases',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cases.length,
                itemBuilder: (context, index) {
                  final c = cases[index];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 12),
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
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                c.childName[0],
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c.childName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Age ${c.childAge}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        c.lastKnownLocationText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
        );
      },
    );
  }

  Widget _buildSuccessStoriesSection() {
    final List<Map<String, dynamic>> successStories = [
      {
        'name': 'Ahmad',
        'age': 7,
        'location': 'Sunshine Mall',
        'story':
            'Found playing in the playground area after community members shared memories of seeing him there.',
        'daysToFind': 2,
        'image': Icons.child_care,
      },
      {
        'name': 'Wei Ling',
        'age': 5,
        'location': 'Hokkien Temple',
        'story':
            'Reunited with grandmother after someone remembered seeing her at the temple festival.',
        'daysToFind': 1,
        'image': Icons.elderly,
      },
      {
        'name': 'Muthu',
        'age': 9,
        'location': 'Central Market',
        'story':
            'Found safe at a nearby vegetable stall after memories described the market sounds.',
        'daysToFind': 3,
        'image': Icons.store,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Success Stories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...successStories.map(
          (story) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SmartCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      story['image'],
                      color: AppColors.success,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              story['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${story['daysToFind']} ${story['daysToFind'] == 1 ? 'day' : 'days'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Age ${story['age']} • ${story['location']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          story['story'],
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How It Works',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              _buildHowItWorksStep(
                number: 1,
                title:
                    widget.role == UserRole.parent
                        ? 'Report a Case'
                        : 'Share a Memory',
                description:
                    widget.role == UserRole.parent
                        ? 'Provide details about the missing child including location, appearance, and any identifying features.'
                        : 'Describe what you remember - places, sounds, languages, or how you felt.',
                icon:
                    widget.role == UserRole.parent
                        ? Icons.add_circle
                        : Icons.edit_note,
                color: AppColors.primary,
                isLast: false,
              ),
              _buildHowItWorksStep(
                number: 2,
                title: 'AI Matching',
                description:
                    'Our advanced AI analyzes memories and compares them with ongoing and past cases to find potential matches.',
                icon: Icons.auto_awesome,
                color: AppColors.secondary,
                isLast: false,
              ),
              _buildHowItWorksStep(
                number: 3,
                title: 'Community Review',
                description:
                    'Matches are reviewed by our community and verified before being reported to authorities.',
                icon: Icons.people,
                color: AppColors.success,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
