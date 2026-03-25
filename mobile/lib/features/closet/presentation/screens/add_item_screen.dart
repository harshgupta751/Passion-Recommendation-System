import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../closet/providers/closet_provider.dart';
import '../../../auth/widgets/drobe_text_field.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  String _category = 'Tops';
  String _season = 'All Season';
  String _status = 'available';
  List<String> _selectedOccasions = [];
  bool _isUploading = false;
  bool _isMlProcessing = false;
  Map<String, dynamic>? _mlSuggestions;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
      _isMlProcessing = true;
      _mlSuggestions = null;
    });

    // Simulate ML auto-tagging (backend processes image)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isMlProcessing = false;
      _mlSuggestions = {
        'category': 'Tops',
        'color': 'Navy Blue',
        'color_hex': '#1B2A4A',
        'fabric': 'Cotton Jersey',
        'season': 'All Season',
        'suggested_name': 'Premium Essential T-Shirt',
      };
      if (_nameController.text.isEmpty) {
        _nameController.text = _mlSuggestions!['suggested_name'] as String;
      }
      _category = _mlSuggestions!['category'] as String;
      _season = _mlSuggestions!['season'] as String;
    });
  }

  Future<void> _submit() async {
    if (_selectedImage == null) {
      _showSnack('Please select an image.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final repo = ref.read(closetRepositoryProvider);
      final item = await repo.addItem({
        'name': _nameController.text.trim(),
        'category': _category,
        'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        'season': _season,
        'status': _status,
        'occasions': _selectedOccasions,
        'purchase_price': _priceController.text.isEmpty
            ? null
            : double.tryParse(_priceController.text),
        if (_mlSuggestions != null) ...{
          'color': _mlSuggestions!['color'],
          'color_hex': _mlSuggestions!['color_hex'],
          'fabric': _mlSuggestions!['fabric'],
        },
      }, _selectedImage!.path);

      ref.read(closetProvider.notifier).addItemLocally(item);
      if (mounted) {
        context.pop();
        _showSnack('Item added to your closet.');
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to add item. Please try again.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Add Item', style: AppTypography.heading3(color: AppColors.textPrimary)),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.close, color: AppColors.textPrimary, size: 22),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _submit,
            child: _isUploading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentBlue),
                  )
                : Text('Save', style: AppTypography.button(color: AppColors.accentBlue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              _buildImagePicker().animate().fadeIn(duration: 400.ms),

              // ML suggestions banner
              if (_isMlProcessing) _buildMlProcessing(),
              if (_mlSuggestions != null) _buildMlBanner(),

              const SizedBox(height: 28),

              // Form fields
              Text('ITEM DETAILS', style: AppTypography.label(color: AppColors.textSecondary)),
              const SizedBox(height: 14),

              DrobeTextField(
                controller: _nameController,
                label: 'Item name',
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 14),

              DrobeTextField(
                controller: _brandController,
                label: 'Brand (optional)',
                textInputAction: TextInputAction.next,
              ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

              const SizedBox(height: 14),

              DrobeTextField(
                controller: _priceController,
                label: 'Purchase price (optional)',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 22),

              // Category
              _buildDropdown(
                label: 'CATEGORY',
                value: _category,
                options: AppConstants.categories.skip(1).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

              const SizedBox(height: 16),

              // Season
              _buildDropdown(
                label: 'SEASON',
                value: _season,
                options: AppConstants.seasons,
                onChanged: (v) => setState(() => _season = v!),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: 22),

              // Occasions
              Text('OCCASIONS', style: AppTypography.label(color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.occasions.map((o) {
                  final selected = _selectedOccasions.contains(o);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedOccasions.remove(o);
                        } else {
                          _selectedOccasions.add(o);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accentBlue.withOpacity(0.15) : AppColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: selected ? AppColors.accentBlue : AppColors.borderDefault,
                          width: selected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(o, style: AppTypography.body2(
                        color: selected ? AppColors.accentBlue : AppColors.textSecondary,
                      ).copyWith(fontWeight: selected ? FontWeight.w500 : FontWeight.w400)),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(),
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _selectedImage != null
                ? AppColors.accentBlue.withOpacity(0.3)
                : AppColors.borderDefault,
            width: 0.5,
          ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg - 1),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.textTertiary, size: 26),
                  ),
                  const SizedBox(height: 12),
                  Text('Tap to add photo', style: AppTypography.body1(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('ML auto-tags category, color & fabric',
                      style: AppTypography.caption(color: AppColors.textTertiary)),
                ],
              ),
      ),
    );
  }

  Widget _buildMlProcessing() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentBlue),
          ),
          const SizedBox(width: 12),
          Text('Analyzing with ML engine...', style: AppTypography.body2(color: AppColors.accentBlue)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildMlBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.success, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Auto-tagged: ${_mlSuggestions!['category']}, ${_mlSuggestions!['color']}, ${_mlSuggestions!['fabric']}',
              style: AppTypography.body2(color: AppColors.success),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderDefault, width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.backgroundElevated,
              style: AppTypography.body1(color: AppColors.textPrimary),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
              items: options.map((o) => DropdownMenuItem(
                value: o,
                child: Text(o),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.borderDefault, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.borderStrong, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _SourceRow(
                    icon: Icons.camera_alt_outlined,
                    label: 'Take photo',
                    onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
                  ),
                  _SourceRow(
                    icon: Icons.photo_library_outlined,
                    label: 'Choose from gallery',
                    onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTypography.body2(color: AppColors.textPrimary)),
      backgroundColor: AppColors.backgroundElevated,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

class _SourceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Text(label, style: AppTypography.body1(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}