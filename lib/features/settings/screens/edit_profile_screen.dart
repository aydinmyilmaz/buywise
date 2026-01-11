import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/content/onboarding_questions.dart';
import '../../../config/content/countries.dart';
import '../../../config/theme/spacing_tokens.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/user_provider.dart';
import '../../decision/widgets/select_option.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/atmosphere_background.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;
    if (profile != null) {
      _answers['ageGroup'] = profile.ageGroup;
      _answers['country'] = profile.country;
      _answers['monthlyIncome'] = profile.monthlyIncome;
      _answers['primaryGoal'] = profile.primaryGoal;
      _answers['spendingStyle'] = profile.spendingStyle;
      _answers['hasFunBudget'] = profile.hasFunBudget;
      _answers['spendingGuilt'] = profile.spendingGuilt;
      _answers['lastSelfPurchase'] = profile.lastSelfPurchase;
      _answers['decisionStyle'] = profile.decisionStyle;
      _answers['preferredWaitTime'] = profile.preferredWaitTime;
      
      _controllers['country'] = TextEditingController(text: profile.country);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setAnswer(String id, dynamic value) {
    setState(() {
      _answers[id] = value;
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    final currentProfile = context.read<UserProvider>().profile;
    if (currentProfile == null) return;

    // Get country name from text field - accept any value (open-ended)
    final countryName = (_answers['country'] as String? ?? currentProfile.country).trim();
    
    // Try to find currency from predefined list, but don't require it
    final countryData = Countries.getByName(countryName);
    final currency = countryData?['currency'] ?? 'USD'; // Default to USD if not found
    
    final updatedProfile = UserProfile(
      gender: currentProfile.gender,
      country: countryName, // Save whatever the user typed
      currency: currency,
      ageGroup: _answers['ageGroup'] ?? currentProfile.ageGroup,
      monthlyIncome: _answers['monthlyIncome'] ?? currentProfile.monthlyIncome,
      primaryGoal: _answers['primaryGoal'] ?? currentProfile.primaryGoal,
      spendingStyle: _answers['spendingStyle'] ?? currentProfile.spendingStyle,
      hasFunBudget: _answers['hasFunBudget'] ?? currentProfile.hasFunBudget,
      spendingGuilt: _answers['spendingGuilt'] ?? currentProfile.spendingGuilt,
      lastSelfPurchase: _answers['lastSelfPurchase'] ?? currentProfile.lastSelfPurchase,
      decisionStyle: _answers['decisionStyle'] ?? currentProfile.decisionStyle,
      preferredWaitTime: _answers['preferredWaitTime'] ?? currentProfile.preferredWaitTime,
    );

    await context.read<UserProvider>().save(updatedProfile);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Scaffold(
      body: AtmosphereBackground(
        accents: [accent, theme.colorScheme.secondary],
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    Expanded(
                      child: Text(
                        'Edit Profile',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Build each question field
                      for (final question in OnboardingQuestions.questions)
                        _buildQuestionField(question, theme, accent),
                      
                      const SizedBox(height: SpacingTokens.xl),
                    ],
                  ),
                ),
              ),
              
              // Save button
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: AppButton(
                  label: 'Save Changes',
                  onPressed: _hasChanges ? _save : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionField(Map<String, dynamic> question, ThemeData theme, Color accent) {
    final id = question['id'] as String;
    final type = question['type'] as String;
    final title = question['title'] as String;
    final icon = question['icon'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.lg),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withOpacity(0.15),
                      accent.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: SpacingTokens.md),
          
          // Input field
          if (type == 'single_select')
            Wrap(
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: (question['options'] as List<dynamic>)
                  .map(
                    (option) => SelectOption(
                      label: option.toString(),
                      selected: _answers[id] == option,
                      onTap: () => _setAnswer(id, option),
                    ),
                  )
                  .toList(),
            )
          else if (type == 'text')
            TextField(
              controller: _controllers.putIfAbsent(
                id,
                () => TextEditingController(text: _answers[id]?.toString() ?? ''),
              ),
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Enter your answer...',
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.8),
                contentPadding: const EdgeInsets.all(SpacingTokens.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accent, width: 2),
                ),
              ),
              onChanged: (val) => _setAnswer(id, val),
            ),
        ],
      ),
    );
  }
}
