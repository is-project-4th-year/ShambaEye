import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../services/auth_service.dart'; 
import 'auth/login_screen.dart';
import 'package:shamba_eye/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmSizeController = TextEditingController();
  
  String _selectedLanguage = 'English';
  
  // Map language codes to display names
  final Map<String, String> _languageMap = {
    'en': 'English',
    'sw': 'Swahili',
    'fr': 'French',
    'es': 'Spanish',
    'pt': 'Portuguese'
  };
  
  // Get display names for dropdown
  List<String> get _languageDisplayNames => _languageMap.values.toList();
  
  // Convert display name to code
  String _getLanguageCode(String displayName) {
    return _languageMap.entries
        .firstWhere((entry) => entry.value == displayName,
            orElse: () => const MapEntry('en', 'English'))
        .key;
  }
  
  // Convert code to display name
  String _getLanguageDisplayName(String? code) {
    if (code == null || code.isEmpty) return 'English';
    return _languageMap[code] ?? 'English';
  }

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final userProfile = authProvider.userProfile;
    
    if (userProfile != null) {
      _fullNameController.text = userProfile.fullName;
      _locationController.text = userProfile.location;
      _farmSizeController.text = userProfile.farmSize.toString();
      
      // Convert language code to display name
      _selectedLanguage = _getLanguageDisplayName(userProfile.preferredLanguage);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _locationController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
        final currentUser = authProvider.userProfile;

        if (currentUser != null) {
          // Convert display name back to language code for storage
          final languageCode = _getLanguageCode(_selectedLanguage);
          
          final updatedProfile = UserProfile(
            uid: currentUser.uid,
            email: currentUser.email,
            fullName: _fullNameController.text.trim(),
            location: _locationController.text.trim(),
            farmSize: double.tryParse(_farmSizeController.text.trim()) ?? 0.0,
            preferredLanguage: languageCode, // Store the code, not display name
          );

          await authProvider.createProfile(updatedProfile);
          
          setState(() {
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.profile_updated_successfully),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.failed_to_update_profile}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    _loadUserProfile(); // Reset to original values
    setState(() {
      _isEditing = false;
    });
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, authProvider, locale),
              const SizedBox(height: 32),
              
              // Profile Card
              _buildProfileCard(authProvider, locale),
              const SizedBox(height: 24),
              
              // Stats Section - Only show when logged in
              if (authProvider.isLoggedIn) ...[
                _buildStatsSection(locale),
                const SizedBox(height: 32),
              ],
              
              // Profile Details - Only show when logged in
              if (authProvider.isLoggedIn) ...[
                _buildProfileDetails(context, authProvider, locale),
                const SizedBox(height: 40),
              ],
              
              // Login/Logout Button
              _buildAuthButton(context, authProvider, locale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppAuthProvider authProvider, AppLocalizations locale) {
    return Row(
      children: [
        const SizedBox(width: 48), // Placeholder for alignment
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.profile,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                locale.manage_your_account_and_preferences,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (authProvider.isLoggedIn && !_isEditing)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD2EFDA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_rounded, 
                  color: Color(0xFF2E7D32), size: 20),
              onPressed: _startEditing,
              tooltip: locale.edit_profile,
            ),
          ),
      ],
    );
  }

  Widget _buildProfileCard(AppAuthProvider authProvider, AppLocalizations locale) {
    if (!authProvider.isLoggedIn || authProvider.userProfile == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFD2EFDA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFA8D5BA),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.person_off_rounded, size: 48, color: Color(0xFF2E7D32)),
            const SizedBox(height: 12),
            Text(
              locale.no_profile_found,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              locale.please_log_in_to_view_your_profile,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1B5E20),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final userProfile = authProvider.userProfile!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFD2EFDA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFA8D5BA),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile Avatar and Name
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2E7D32),
              border: Border.all(
                color: const Color(0xFFA8D5BA),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userProfile.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userProfile.email,
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (userProfile.location.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, 
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    userProfile.location,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppLocalizations locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8F5E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.farm_overview,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                locale.farm_size,
                '${_farmSizeController.text.isEmpty ? '0' : _farmSizeController.text} ${locale.acres}',
                Icons.agriculture_rounded,
              ),
              _buildStatItem(
                locale.language,
                _selectedLanguage,
                Icons.language_rounded,
              ),
              _buildStatItem(
                locale.status,
                locale.active,
                Icons.verified_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFD2EFDA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1B5E20),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(BuildContext context, AppAuthProvider authProvider, AppLocalizations locale) {
    if (!authProvider.isLoggedIn || authProvider.userProfile == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.profile_details,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isEditing ? locale.edit_your_information : locale.your_personal_details,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDetailField(
                label: locale.full_name,
                controller: _fullNameController,
                icon: Icons.person_rounded,
                isEditable: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return locale.please_enter_your_full_name;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: locale.email,
                value: authProvider.userProfile!.email,
                icon: Icons.email_rounded,
                isEditable: false,
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: locale.location,
                controller: _locationController,
                icon: Icons.location_on_rounded,
                isEditable: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return locale.please_enter_your_location;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: '${locale.farm_size} (${locale.acres})',
                controller: _farmSizeController,
                icon: Icons.agriculture_rounded,
                isEditable: _isEditing,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return locale.please_enter_farm_size;
                  }
                  final farmSize = double.tryParse(value);
                  if (farmSize == null || farmSize <= 0) {
                    return locale.please_enter_a_valid_farm_size;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLanguageDropdown(locale),
              
              if (_isEditing) ...[
                const SizedBox(height: 24),
                _buildEditActions(locale),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailField({
    required String label,
    TextEditingController? controller,
    String? value,
    required IconData icon,
    required bool isEditable,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        isEditable
            ? TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFA8D5BA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFA8D5BA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FDF8),
                  border: Border.all(color: const Color(0xFFE8F5E8)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xFF2E7D32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        value ?? controller?.text ?? 'Not set',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildLanguageDropdown(AppLocalizations locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.preferred_language,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _isEditing
            ? DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.language_rounded, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFA8D5BA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFA8D5BA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                items: _languageDisplayNames.map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
              )
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FDF8),
                  border: Border.all(color: const Color(0xFFE8F5E8)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedLanguage,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildEditActions(AppLocalizations locale) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEditing,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            child: Text(
              locale.cancel.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    locale.save_changes.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButton(BuildContext context, AppAuthProvider authProvider, AppLocalizations locale) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: authProvider.isLoggedIn
            ? OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context, locale);
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text(
                  locale.logout,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.red),
                ),
              )
            : ElevatedButton.icon(
                onPressed: _navigateToLogin,
                icon: const Icon(Icons.login_rounded, color: Colors.white),
                label: Text(
                  locale.login,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations locale) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                locale.logout_question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                locale.are_you_sure_you_want_to_logout,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(locale.cancel.toUpperCase()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Provider.of<AppAuthProvider>(context, listen: false).logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(locale.logout.toUpperCase()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}