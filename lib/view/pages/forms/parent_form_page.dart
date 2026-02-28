part of my_reunify_app;

/// ===============================================
/// MODERN PARENT FORM PAGE
/// ===============================================

class ModernParentFormPage extends StatefulWidget {
  final EnhancedMockDataRepository repository;
  final AITagAnalysisService? tagAnalysisService;

  const ModernParentFormPage({
    super.key,
    required this.repository,
    this.tagAnalysisService,
  });

  @override
  State<ModernParentFormPage> createState() => _ModernParentFormPageState();
}

class _ModernParentFormPageState extends State<ModernParentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _reporterNameController = TextEditingController();
  final _reporterEmailController = TextEditingController();
  final _reporterContactController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<String> _suggestedTags = [];
  bool _isSaving = false;
  bool _isAnalyzing = false;
  int _currentStep = 1;
  bool _tagsAnalyzed = false;

  final List<String> _availableTags = [
    'mall',
    'temple',
    'park',
    'market',
    'beach',
    'school',
    'hokkien',
    'mandarin',
    'malay',
    'tamil',
    'english',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    // Enable analyze button when description has content
    setState(() {});
  }

  Future<void> _analyzeDescription() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final tagService =
          widget.tagAnalysisService ??
          AITagAnalysisService(textProcessing: EnhancedTextProcessingService());

      final generatedTags = await tagService.generateTagsFromDescription(
        _descriptionController.text,
      );

      setState(() {
        _suggestedTags
          ..clear()
          ..addAll(generatedTags);
        _tagsAnalyzed = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Analysis complete! Found ${generatedTags.length} relevant tags',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing description: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showDescriptionTemplate() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Description Template'),
            content: SingleChildScrollView(
              child: Text(
                AITagAnalysisService.getDescriptionTemplate(),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  _descriptionController.text =
                      AITagAnalysisService.getDescriptionTemplate();
                  Navigator.pop(context);
                },
                child: const Text('Use Template'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _childAgeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _reporterNameController.dispose();
    _reporterEmailController.dispose();
    _reporterContactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final newCase = ParentCase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childName: _childNameController.text.trim(),
      childAge: int.parse(_childAgeController.text.trim()),
      description: _descriptionController.text.trim(),
      lastKnownLocationText: _locationController.text.trim(),
      latitude: 3.1390 + (math.Random().nextDouble() - 0.5) * 0.01,
      longitude: 101.6869 + (math.Random().nextDouble() - 0.5) * 0.01,
      reportedAt: DateTime.now(),
      status: 'ongoing',
      photos: [],
      reporterName: _reporterNameController.text.trim(),
      reporterEmail: _reporterEmailController.text.trim(),
      reporterContact: _reporterContactController.text.trim(),
      tags: List.from(_selectedTags),
    );

    await widget.repository.addCase(newCase);
    if (!mounted) return;
    setState(() => _isSaving = false);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Case Submitted',
              style: TextStyle(color: AppColors.success),
            ),
            content: const Text(
              'Your case has been submitted successfully. The Reunify community will help find your child.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Missing Child',
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStepIndicator(
                              1,
                              'Child Info',
                              _currentStep >= 1,
                            ),
                            _buildStepConnector(_currentStep > 1),
                            _buildStepIndicator(
                              2,
                              'Case Details',
                              _currentStep >= 2,
                            ),
                            _buildStepConnector(_currentStep > 2),
                            _buildStepIndicator(
                              3,
                              'Your Info',
                              _currentStep >= 3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _currentStep / 3,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currentStep == 1)
                    SmartCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Child Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _childNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(
                                Icons.person,
                                color: AppColors.primary,
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
                                        ? 'Please enter child\'s name'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _childAgeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              prefixIcon: const Icon(
                                Icons.cake,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                            validator: (v) {
                              if (v?.isEmpty == true) return 'Please enter age';
                              if (int.tryParse(v!) == null)
                                return 'Enter a valid number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => setState(() => _currentStep = 2),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Next Step',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_currentStep == 2)
                    SmartCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Case Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Case Description',
                              hintText:
                                  'Where were they last seen? What were they wearing? Who were they with?',
                              prefixIcon: const Icon(
                                Icons.description,
                                color: AppColors.primary,
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Tooltip(
                                  message: 'View description template',
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.help_outline,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: _showDescriptionTemplate,
                                  ),
                                ),
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
                                        ? 'Please provide a description'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Last Known Location',
                              prefixIcon: const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
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
                                        ? 'Please enter last known location'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isAnalyzing
                                      ? null
                                      : (_descriptionController.text.isEmpty
                                          ? null
                                          : _analyzeDescription),
                              icon:
                                  _isAnalyzing
                                      ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Icon(Icons.auto_awesome),
                              label: Text(
                                _isAnalyzing
                                    ? 'Analyzing...'
                                    : 'Analyze & Generate Tags',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                disabledBackgroundColor: AppColors.divider,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_tagsAnalyzed)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        size: 18,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'AI-Generated Tags',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_suggestedTags.isEmpty)
                                    const Text(
                                      'No tags suggested. Try providing more details.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  else
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children:
                                          _suggestedTags.map((tag) {
                                            final isSelected = _selectedTags
                                                .contains(tag);
                                            return FilterChip(
                                              label: Text(
                                                '#$tag',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                setState(() {
                                                  if (selected)
                                                    _selectedTags.add(tag);
                                                  else
                                                    _selectedTags.remove(tag);
                                                });
                                              },
                                              backgroundColor:
                                                  AppColors.background,
                                              selectedColor: AppColors.secondary
                                                  .withOpacity(0.2),
                                              checkmarkColor:
                                                  AppColors.secondary,
                                              side: BorderSide(
                                                color:
                                                    isSelected
                                                        ? AppColors.secondary
                                                        : Colors.transparent,
                                                width: 1.5,
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Click "Analyze & Generate Tags" to auto-tag',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Selected Tags',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_selectedTags.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'No tags selected. Generate or click tags above.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children:
                                  _selectedTags.map((tag) {
                                    return Chip(
                                      label: Text(
                                        '#$tag',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: AppColors.primary,
                                      onDeleted: () {
                                        setState(
                                          () => _selectedTags.remove(tag),
                                        );
                                      },
                                    );
                                  }).toList(),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                      () => setState(() => _currentStep = 1),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    side: BorderSide(color: AppColors.primary),
                                  ),
                                  child: const Text('Previous'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_descriptionController
                                            .text
                                            .isNotEmpty &&
                                        _locationController.text.isNotEmpty) {
                                      setState(() => _currentStep = 3);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text('Next Step'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (_currentStep == 3)
                    SmartCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _reporterNameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: AppColors.primary,
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
                                        ? 'Please enter your name'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _reporterEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(
                                Icons.email,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                            validator: (v) {
                              if (v?.isEmpty == true)
                                return 'Please enter your email';
                              if (!(v?.contains('@') ?? false))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _reporterContactController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Contact Number',
                              prefixIcon: const Icon(
                                Icons.phone,
                                color: AppColors.primary,
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
                                        ? 'Please enter your contact number'
                                        : null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                      () => setState(() => _currentStep = 2),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    side: BorderSide(color: AppColors.primary),
                                  ),
                                  child: const Text('Previous'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GradientButton(
                                  label: 'Submit Case',
                                  isLoading: _isSaving,
                                  onPressed: _submit,
                                  colors: const [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.divider,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppColors.primary : AppColors.divider,
    );
  }
}
