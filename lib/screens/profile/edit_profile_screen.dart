import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../ui/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: '•••••••');
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  Uint8List? _imageBytes; // Cross-platform preview
  File? _imageFile;       // Untuk upload (non-web)
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (userData != null && mounted) {
          setState(() {
            _nameController.text = userData['full_name'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _phoneController.text = userData['phone_number'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _avatarUrl = '${Supabase.instance.client.storage.from('avatars').getPublicUrl('${user.id}/profile.jpg')}?t=${DateTime.now().millisecondsSinceEpoch}';
            _isLoading = false;
          });
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        if (_passwordController.text != '•••••••' && _passwordController.text.isNotEmpty) {
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(password: _passwordController.text),
          );
        }

        await Supabase.instance.client.from('users').update({
          'full_name': _nameController.text,
          'phone_number': _phoneController.text,
          'address': _addressController.text,
        }).eq('user_id', user.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil berhasil diperbarui', style: TextStyle(fontFamily: 'Montserrat')),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 24,
                right: 24,
              ),
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: ${e.toString()}', style: const TextStyle(fontFamily: 'Montserrat')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 24,
              right: 24,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return;

    // Baca sebagai bytes untuk cross-platform preview
    final bytes = await image.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      if (!kIsWeb) _imageFile = File(image.path);
      _isUploadingAvatar = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final String path = '${user.id}/profile.jpg';

        if (kIsWeb) {
          // Upload dari bytes untuk web
          await Supabase.instance.client.storage.from('avatars').uploadBinary(
            path,
            _imageBytes!,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
        } else {
          // Upload dari File untuk mobile/desktop
          await Supabase.instance.client.storage.from('avatars').upload(
            path,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );
        }

        setState(() {
          _avatarUrl = '${Supabase.instance.client.storage.from('avatars').getPublicUrl(path)}?t=${DateTime.now().millisecondsSinceEpoch}';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Foto profil berhasil diunggah', style: TextStyle(fontFamily: 'Montserrat')),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 24,
                right: 24,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunggah foto: $e', style: const TextStyle(fontFamily: 'Montserrat')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 24,
              right: 24,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 110,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.background,
            size: 16,
          ),
          label: const Text(
            'Kembali',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.background,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Edit Profil',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.background,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 64, 
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
              // Profile Picture Section
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: _imageBytes != null
                          ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                          : (_avatarUrl != null
                              ? Image.network(
                                  _avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person, size: 40, color: Colors.grey[400]),
                                )
                              : Icon(Icons.person, size: 40, color: Colors.grey[400])),
                    ),
                    if (_isUploadingAvatar)
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ubah Foto Profil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'JPG/PNG, maks. 2MB',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 32),
              
              // Form Fields
              _buildTextField(Icons.person_outline, _nameController),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(Icons.email_outlined, _emailController, enabled: false),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Text(
                      '* Email tidak dapat diubah',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(Icons.lock_outline, _passwordController, obscureText: true),
              const SizedBox(height: 16),
              _buildTextField(Icons.phone_outlined, _phoneController),
              const SizedBox(height: 16),
              _buildTextField(Icons.location_on_outlined, _addressController),
              
              const SizedBox(height: 24),
              const Spacer(),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 1,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Security info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gpp_good_outlined, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Perubahan akan Tersimpan secara Aman',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, TextEditingController controller, {bool obscureText = false, bool enabled = true}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        color: enabled ? Colors.black87 : Colors.grey[500],
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: enabled ? Colors.black87 : Colors.grey[400], size: 22),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        isDense: true,
      ),
    );
  }
}
