// ── AddProjectScreen is temporarily commented out ─────────────────────────
// Projects are now fetched from the API and cannot be created locally.
// Uncomment this file when the create-project API endpoint is ready.

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../viewmodel/project_cubit/project_cubit.dart';
//
// class AddProjectScreen extends StatefulWidget {
//   const AddProjectScreen({super.key});
//
//   @override
//   State<AddProjectScreen> createState() => _AddProjectScreenState();
// }
//
// class _AddProjectScreenState extends State<AddProjectScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   bool _isSaving = false;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isSaving = true);
//
//     await context.read<ProjectCubit>().addProject(
//       name: _nameController.text.trim(),
//       description: _descriptionController.text.trim(),
//     );
//
//     if (mounted) {
//       Navigator.of(context).pop(true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('New Project')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Project Name',
//                   prefixIcon: Icon(Icons.folder_outlined),
//                 ),
//                 textCapitalization: TextCapitalization.words,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter the project name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 18),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description (optional)',
//                   prefixIcon: Icon(Icons.description_outlined),
//                   alignLabelWithHint: true,
//                 ),
//                 maxLines: 3,
//                 textCapitalization: TextCapitalization.sentences,
//               ),
//               const SizedBox(height: 36),
//               SizedBox(
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _isSaving ? null : _save,
//                   child: _isSaving
//                       ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2.5,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.create_new_folder_rounded),
//                             SizedBox(width: 10),
//                             Text('Create Project'),
//                           ],
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
