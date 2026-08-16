import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../providers/experience_provider.dart';

class AddExperienceView extends StatefulWidget {
  const AddExperienceView({super.key});

  @override
  State<AddExperienceView> createState() => _AddExperienceViewState();
}

class _AddExperienceViewState extends State<AddExperienceView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedJobTypeKey;
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExperienceProvider>().loadJobTypes();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExperienceProvider>();
    String? certificateImageUrl;

    // Subir imagen si se seleccionó una
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      certificateImageUrl = await provider.uploadCertificate(base64Image);
      
      if (certificateImageUrl == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Error al subir la imagen')),
        );
        return;
      }
    }

    final success = await provider.addExperience(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      jobTypeKey: _selectedJobTypeKey,
      certificateImage: certificateImageUrl,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experiencia agregada correctamente')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error al agregar experiencia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExperienceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Experiencia'),
      ),
      body: provider.isLoading && provider.jobTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Ej: Desarrollador Flutter',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedJobTypeKey,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Trabajo',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.jobTypes.map((type) {
                        return DropdownMenuItem(
                          value: type.key,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJobTypeKey = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona un tipo de trabajo';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Describe tus responsabilidades y logros...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    Text('Certificado (Opcional)', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: provider.isAdding ? null : _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 18,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, size: 18, color: Colors.white),
                                        onPressed: () => setState(() => _selectedImage = null),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Toca para subir una foto', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: provider.isAdding ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: provider.isAdding
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar Experiencia'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
