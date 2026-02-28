part of my_reunify_app;

/// ===============================================
/// ROLE SELECTION PAGE
/// ===============================================

class ModernRoleSelectionPage extends StatelessWidget {
  final EnhancedMockDataRepository repository;
  final EnhancedMatchingService matchingService;
  final AITagAnalysisService? tagAnalysisService;

  const ModernRoleSelectionPage({
    super.key,
    required this.repository,
    required this.matchingService,
    this.tagAnalysisService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.family_restroom,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Reunify',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connecting Families Through Memories',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SmartCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: AppColors.warning,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI-powered matching connects child memories with missing person cases using keywords and environmental clues.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'I am a...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRoleButton(
                    context,
                    icon: Icons.person,
                    title: 'Parent/Guardian',
                    description: 'Report a missing child case',
                    color: AppColors.primary,
                    onTap:
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ModernHomePage(
                                  repository: repository,
                                  matchingService: matchingService,
                                  role: UserRole.parent,
                                  tagAnalysisService: tagAnalysisService,
                                ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildRoleButton(
                    context,
                    icon: Icons.child_care,
                    title: 'Child',
                    description: 'Share a memory you remember',
                    color: AppColors.secondary,
                    onTap:
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ModernHomePage(
                                  repository: repository,
                                  matchingService: matchingService,
                                  role: UserRole.child,
                                  tagAnalysisService: tagAnalysisService,
                                ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Your privacy is protected. All data is encrypted.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SmartCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    );
  }
}
