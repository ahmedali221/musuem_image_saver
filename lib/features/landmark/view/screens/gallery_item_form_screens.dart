import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:musuem_image_saver/features/landmark/model/gallery_item_model.dart';

import 'package:musuem_image_saver/features/landmark/viewmodel/landmark_detail_cubit/landmark_detail_cubit.dart';
import 'package:musuem_image_saver/features/landmark/viewmodel/landmark_detail_cubit/landmark_detail_state.dart';

// Form screen for adding a new gallery item to a landmark.
class AddGalleryItemScreen extends StatefulWidget {
  final int projectId;
  final int landmarkId;

  const AddGalleryItemScreen({
    super.key,
    required this.projectId,
    required this.landmarkId,
  });

  @override
  State<AddGalleryItemScreen> createState() => _AddGalleryItemScreenState();
}

class _AddGalleryItemScreenState extends State<AddGalleryItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  String _partType = 'statue';
  String _signatureType = 'hieroglyphic';
  final List<XFile> _images = [];
  bool _submitting = false;

  static const _partTypes = [
    'statue',
    'wall',
    'part_of_wall',
    'target_mural',
    'artifact',
  ];

  static const _sigTypes = ['hieroglyphic', 'hieratic', 'demotic', 'coptic'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    await context.read<LandmarkDetailCubit>().addGalleryItem(
      projectId: widget.projectId,
      landmarkId: widget.landmarkId,
      name: _nameCtrl.text.trim(),
      partType: _partType,
      signatureType: _signatureType.toLowerCase(),
      width: _widthCtrl.text.trim().isEmpty ? null : _widthCtrl.text.trim(),
      height: _heightCtrl.text.trim().isEmpty ? null : _heightCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      images: _images,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LandmarkDetailCubit, LandmarkDetailState>(
      listener: (context, state) {
        if (state is GalleryActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.of(context).pop();
        } else if (state is GalleryActionError) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Gallery Item')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Name
              _field(label: 'Name', controller: _nameCtrl, required: true),
              const SizedBox(height: 16),

              // Part Type
              _dropdown(
                label: 'Part Type',
                value: _partType,
                items: _partTypes,
                onChanged: (v) => setState(() => _partType = v!),
              ),
              const SizedBox(height: 16),

              // Signature Type
              _dropdown(
                label: 'Signature Type',
                value: _signatureType,
                items: _sigTypes,
                onChanged: (v) => setState(() => _signatureType = v!),
              ),
              const SizedBox(height: 16),

              // Width / Height
              Row(
                children: [
                  Expanded(
                    child: _field(
                      label: 'Width (cm)',
                      controller: _widthCtrl,
                      numeric: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      label: 'Height (cm)',
                      controller: _heightCtrl,
                      numeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              _field(
                label: 'Description',
                controller: _descCtrl,
                maxLines: 3,
                required: true,
              ),
              const SizedBox(height: 16),

              // Notes
              _field(label: 'Notes', controller: _notesCtrl, maxLines: 2),
              const SizedBox(height: 24),

              // Image picker
              _ImagePickerSection(
                images: _images,
                onAdd: (img) => setState(() => _images.add(img)),
                onRemove: (i) => setState(() => _images.removeAt(i)),
              ),
              const SizedBox(height: 32),

              // Submit button
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_submitting ? 'Saving…' : 'Add to Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    bool required = false,
    bool numeric = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ── Edit screen ────────────────────────────────────────────────────────────────

class EditGalleryItemScreen extends StatefulWidget {
  final int projectId;
  final int landmarkId;
  final GalleryItemModel item;

  const EditGalleryItemScreen({
    super.key,
    required this.projectId,
    required this.landmarkId,
    required this.item,
  });

  @override
  State<EditGalleryItemScreen> createState() => _EditGalleryItemScreenState();
}

class _EditGalleryItemScreenState extends State<EditGalleryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _widthCtrl;
  late final TextEditingController _heightCtrl;

  late String _partType;
  late String _signatureType;
  final List<XFile> _newImages = [];
  final List<int> _removeImageIds = [];
  bool _submitting = false;

  static const _partTypes = [
    'statue',
    'wall',
    'part_of_wall',
    'target_mural',
    'artifact',
  ];

  static const _sigTypes = ['hieroglyphic', 'hieratic', 'demotic', 'coptic'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: item.name);
    _descCtrl = TextEditingController(text: item.description);
    _notesCtrl = TextEditingController(text: item.notes);
    _widthCtrl = TextEditingController(text: item.width?.toString() ?? '');
    _heightCtrl = TextEditingController(text: item.height?.toString() ?? '');
    _partType = _partTypes.contains(item.partType)
        ? item.partType
        : _partTypes.first;
    _signatureType = _sigTypes.contains(item.signatureType)
        ? item.signatureType
        : _sigTypes.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    await context.read<LandmarkDetailCubit>().updateGalleryItem(
      projectId: widget.projectId,
      landmarkId: widget.landmarkId,
      itemId: widget.item.id,
      name: _nameCtrl.text.trim(),
      partType: _partType,
      signatureType: _signatureType,
      width: _widthCtrl.text.trim().isEmpty ? null : _widthCtrl.text.trim(),
      height: _heightCtrl.text.trim().isEmpty ? null : _heightCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      newImages: _newImages.isEmpty ? null : _newImages,
      removeImageIds: _removeImageIds.isEmpty ? null : _removeImageIds,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LandmarkDetailCubit, LandmarkDetailState>(
      listener: (context, state) {
        if (state is GalleryActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.of(context).pop();
        } else if (state is GalleryActionError) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Gallery Item')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _field(label: 'Name', controller: _nameCtrl, required: true),
              const SizedBox(height: 16),
              _dropdown(
                label: 'Part Type',
                value: _partType,
                items: _partTypes,
                onChanged: (v) => setState(() => _partType = v!),
              ),
              const SizedBox(height: 16),
              _dropdown(
                label: 'Signature Type',
                value: _signatureType,
                items: _sigTypes,
                onChanged: (v) => setState(() => _signatureType = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      label: 'Width (cm)',
                      controller: _widthCtrl,
                      numeric: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      label: 'Height (cm)',
                      controller: _heightCtrl,
                      numeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _field(
                label: 'Description',
                controller: _descCtrl,
                maxLines: 3,
                required: true,
              ),
              const SizedBox(height: 16),
              _field(label: 'Notes', controller: _notesCtrl, maxLines: 2),
              const SizedBox(height: 24),

              // Existing images with remove toggles
              if (widget.item.images.isNotEmpty) ...[
                Text(
                  'Existing Images',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.item.images.map((img) {
                    final removed = _removeImageIds.contains(img.id);
                    return Stack(
                      children: [
                        Opacity(
                          opacity: removed ? 0.35 : 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: img.url,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              if (removed) {
                                _removeImageIds.remove(img.id);
                              } else {
                                _removeImageIds.add(img.id);
                              }
                            }),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                removed ? Icons.undo : Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // New images picker
              _ImagePickerSection(
                images: _newImages,
                onAdd: (img) => setState(() => _newImages.add(img)),
                onRemove: (i) => setState(() => _newImages.removeAt(i)),
                label: 'Add New Images',
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_submitting ? 'Saving…' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    bool required = false,
    bool numeric = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ── Shared image picker section ───────────────────────────────────────────────

class _ImagePickerSection extends StatefulWidget {
  final List<XFile> images;
  final void Function(XFile image) onAdd;
  final void Function(int index) onRemove;
  final String label;

  const _ImagePickerSection({
    required this.images,
    required this.onAdd,
    required this.onRemove,
    this.label = 'Images',
  });

  @override
  State<_ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<_ImagePickerSection> {
  final _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage();
    for (final img in picked) {
      widget.onAdd(img);
    }
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) widget.onAdd(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Gallery button
            TextButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Gallery'),
            ),
            const SizedBox(width: 4),
            // Camera button
            TextButton.icon(
              onPressed: _pickFromCamera,
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('Camera'),
            ),
          ],
        ),
        if (widget.images.isEmpty)
          Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No images selected',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.images.length, (i) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.images[i].path,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => widget.onRemove(i),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
      ],
    );
  }
}
