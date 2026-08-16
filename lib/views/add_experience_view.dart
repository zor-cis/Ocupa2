import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExperienceProvider>();
    final success = await provider.addExperience(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      jobTypeKey: _selectedJobTypeKey,
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
