part of my_reunify_app;

/// ===============================================
/// MODERN CHILD MEMORY FORM PAGE
/// ===============================================

class ModernChildMemoryFormPage extends StatefulWidget {
  final EnhancedMockDataRepository repository;
  final EnhancedMatchingService matchingService;

  const ModernChildMemoryFormPage({
    super.key,
    required this.repository,
    required this.matchingService,
  });

  @override
  State<ModernChildMemoryFormPage> createState() =>
      _ModernChildMemoryFormPageState();
}

class _ModernChildMemoryFormPageState extends State<ModernChildMemoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _memoryController = TextEditingController();
  final _childNameController = TextEditingController();
  String _selectedLanguage = 'en';
  String _selectedCaseStatus = 'ongoing'; // 'ongoing' or 'past'
  final List<String> _selectedEmotions = [];
  int _confidenceLevel = 3;
  bool _isMatching = false;

  static const List<String> _caseStatusOptions = [
    'Ongoing Case - Recently Missing',
    'Past Case - Missing for Years',
  ];

  final List<Map<String, dynamic>> _emotions = [
    {
      'name': 'Happy',
      'icon': Icons.sentiment_satisfied,
      'color': AppColors.success,
    },
    {
      'name': 'Scared',
      'icon': Icons.sentiment_dissatisfied,
      'color': AppColors.error,
    },
    {'name': 'Confused', 'icon': Icons.help, 'color': AppColors.warning},
    {
      'name': 'Excited',
      'icon': Icons.sentiment_very_satisfied,
      'color': AppColors.primary,
    },
    {
      'name': 'Calm',
      'icon': Icons.sentiment_neutral,
      'color': AppColors.secondary,
    },
    {'name': 'Peaceful', 'icon': Icons.spa, 'color': AppColors.success},
  ];

  @override
  void dispose() {
    _memoryController.dispose();
    super.dispose();
  }

  Future<void> _findMatches() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isMatching = true);

    // Memory text with case status information
    final caseStatusText =
        _selectedCaseStatus == 'ongoing'
            ? 'On-going Case (recently missing)'
            : 'Past Case (missing for years)';
    final memoryText = '''Case Status: $caseStatusText

Memory:
${_memoryController.text.trim()}''';

    final memory = ChildMemory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: memoryText,
      language: _selectedLanguage,
      rememberedAt: DateTime.now(),
      latitude: 3.1390 + (math.Random().nextDouble() - 0.5) * 0.01,
      longitude: 101.6869 + (math.Random().nextDouble() - 0.5) * 0.01,
      childIdentifier: 'child_${DateTime.now().millisecondsSinceEpoch}',
      emotions: _selectedEmotions.map((e) => e.toLowerCase()).toList(),
      confidenceLevel: _confidenceLevel,
    );

    await widget.repository.addMemory(memory);
    final cases = await widget.repository.getAllCases();
    final results = await widget.matchingService.matchMemoryToCases(
      memory,
      cases,
    );

    if (!mounted) return;
    setState(() => _isMatching = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ModernMatchResultsPage(
              results: results,
              repository: widget.repository,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Share Your Memory',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SmartCard(
                    color: AppColors.secondary.withOpacity(0.05),
                    child: Row(
                      children: [
                        Icon(Icons.psychology, color: AppColors.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Help us identify who you are and what you remember. Every detail counts!',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SmartCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Case Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Is this an active search or a case from years ago?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCaseStatus,
                          decoration: InputDecoration(
                            labelText: 'Case Type',
                            prefixIcon: const Icon(
                              Icons.access_time,
                              color: AppColors.secondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'ongoing',
                              child: Text('Ongoing Case - Recently Missing'),
                            ),
                            DropdownMenuItem(
                              value: 'past',
                              child: Text('Past Case - Missing for Years'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedCaseStatus = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SmartCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Memory',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _memoryController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'What do you remember?',
                            hintText:
                                'Describe places, sounds, languages, how you felt...',
                            prefixIcon: const Icon(
                              Icons.edit_note,
                              color: AppColors.secondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          validator:
                              (v) =>
                                  v?.isEmpty == true
                                      ? 'Please share what you remember'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedLanguage,
                          decoration: InputDecoration(
                            labelText: 'Language',
                            prefixIcon: const Icon(
                              Icons.language,
                              color: AppColors.secondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(value: 'ms', child: Text('Malay')),
                            DropdownMenuItem(
                              value: 'zh',
                              child: Text('Mandarin'),
                            ),
                            DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                          ],
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedLanguage = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SmartCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Child Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _childNameController,
                          decoration: InputDecoration(
                            labelText: 'Child\'s Name',
                            hintText:
                                'Enter the child\'s name if you remember it',
                            prefixIcon: const Icon(
                              Icons.person,
                              color: AppColors.secondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
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
                        const Text(
                          'How certain are you?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _confidenceLevel.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          activeColor: AppColors.secondary,
                          inactiveColor: AppColors.divider,
                          label:
                              [
                                'Very Vague',
                                'Vague',
                                'Moderate',
                                'Clear',
                                'Very Clear',
                              ][_confidenceLevel - 1],
                          onChanged:
                              (val) => setState(
                                () => _confidenceLevel = val.toInt(),
                              ),
                        ),
                        Center(
                          child: Text(
                            [
                              'Very Vague',
                              'Vague',
                              'Moderate',
                              'Clear',
                              'Very Clear',
                            ][_confidenceLevel - 1],
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
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
                        const Text(
                          'How did you feel?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _emotions.map((emotion) {
                                final isSelected = _selectedEmotions.contains(
                                  emotion['name'],
                                );
                                return ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        emotion['icon'],
                                        size: 16,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : emotion['color'],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(emotion['name']),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected)
                                        _selectedEmotions.add(emotion['name']);
                                      else
                                        _selectedEmotions.remove(
                                          emotion['name'],
                                        );
                                    });
                                  },
                                  backgroundColor: AppColors.background,
                                  selectedColor: emotion['color'],
                                  labelStyle: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Find Matches',
                    isLoading: _isMatching,
                    onPressed: _findMatches,
                    colors: const [AppColors.secondary, AppColors.primary],
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
