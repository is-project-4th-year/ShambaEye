import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../services/auth_service.dart'; 
import 'auth/login_screen.dart';

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
  final List<String> _languages = [
    'English',
    'Swahili',
    'French',
    'Spanish',
    'Portuguese'
  ];

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
      _selectedLanguage = userProfile.preferredLanguage;
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
          final updatedProfile = UserProfile( // ✅ NOW DEFINED
            uid: currentUser.uid,
            email: currentUser.email,
            fullName: _fullNameController.text.trim(),
            location: _locationController.text.trim(),
            farmSize: double.tryParse(_farmSizeController.text.trim()) ?? 0.0,
            preferredLanguage: _selectedLanguage,
          );

          await authProvider.createProfile(updatedProfile);
          
          setState(() {
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
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
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, authProvider),
              const SizedBox(height: 32),
              
              // Profile Card
              _buildProfileCard(authProvider),
              const SizedBox(height: 24),
              
              // Stats Section - Only show when logged in
              if (authProvider.isLoggedIn) ...[
                _buildStatsSection(),
                const SizedBox(height: 32),
              ],
              
              // Profile Details - Only show when logged in
              if (authProvider.isLoggedIn) ...[
                _buildProfileDetails(context, authProvider),
                const SizedBox(height: 40),
              ],
              
              // Login/Logout Button
              _buildAuthButton(context, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppAuthProvider authProvider) {
    return Row(
      children: [
        const SizedBox(width: 48), // Placeholder for alignment
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage your account and preferences',
                style: TextStyle(
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
              tooltip: 'Edit Profile',
            ),
          ),
      ],
    );
  }

  Widget _buildProfileCard(AppAuthProvider authProvider) {
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
        child: const Column(
          children: [
            Icon(Icons.person_off_rounded, size: 48, color: Color(0xFF2E7D32)),
            SizedBox(height: 12),
            Text(
              'No Profile Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5E20),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please log in to view your profile',
              textAlign: TextAlign.center,
              style: TextStyle(
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

  Widget _buildStatsSection() {
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
          const Text(
            'Farm Overview',
            style: TextStyle(
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
                'Farm Size',
                '${_farmSizeController.text.isEmpty ? '0' : _farmSizeController.text} acres',
                Icons.agriculture_rounded,
              ),
              _buildStatItem(
                'Language',
                _selectedLanguage,
                Icons.language_rounded,
              ),
              _buildStatItem(
                'Status',
                'Active',
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

  Widget _buildProfileDetails(BuildContext context, AppAuthProvider authProvider) {
    if (!authProvider.isLoggedIn || authProvider.userProfile == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isEditing ? 'Edit your information' : 'Your personal details',
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
                label: 'Full Name',
                controller: _fullNameController,
                icon: Icons.person_rounded,
                isEditable: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: 'Email',
                value: authProvider.userProfile!.email,
                icon: Icons.email_rounded,
                isEditable: false,
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: 'Location',
                controller: _locationController,
                icon: Icons.location_on_rounded,
                isEditable: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                label: 'Farm Size (acres)',
                controller: _farmSizeController,
                icon: Icons.agriculture_rounded,
                isEditable: _isEditing,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter farm size';
                  }
                  final farmSize = double.tryParse(value);
                  if (farmSize == null || farmSize <= 0) {
                    return 'Please enter a valid farm size';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLanguageDropdown(),
              
              if (_isEditing) ...[
                const SizedBox(height: 24),
                _buildEditActions(),
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

  Widget _buildLanguageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Language',
          style: TextStyle(
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
                items: _languages.map((String language) {
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

  Widget _buildEditActions() {
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
            child: const Text(
              'CANCEL',
              style: TextStyle(
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
                : const Text(
                    'SAVE CHANGES',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButton(BuildContext context, AppAuthProvider authProvider) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: authProvider.isLoggedIn
            ? OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
                label: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

  void _showLogoutDialog(BuildContext context) {
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
              const Text(
                'Logout?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                      child: const Text('CANCEL'),
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
                      child: const Text('LOGOUT'),
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