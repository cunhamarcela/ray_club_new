// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';

void showRegisterExerciseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const RegisterExerciseSheet(),
  );
}

class RegisterExerciseSheet extends StatefulWidget {
  const RegisterExerciseSheet({super.key});

  @override
  State<RegisterExerciseSheet> createState() => _RegisterExerciseSheetState();
}

class _RegisterExerciseSheetState extends State<RegisterExerciseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedType = 'Funcional';
  double _intensity = 3;
  
  final List<String> _exerciseTypes = [
    'Funcional',
    'Musculação',
    'Yoga',
    'Pilates',
    'Corrida',
    'Natação',
    'Ciclismo',
    'Outro'
  ];

  @override
  void dispose() {
    _exerciseController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Barra superior
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Título
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Registrar Treino',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Formulário
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de nome do exercício
                    _buildLabel('Nome do exercício'),
                    TextFormField(
                      controller: _exerciseController,
                      decoration: _inputDecoration('Ex: Agachamento, Supino, Yoga...'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe o nome do exercício';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Campo de tipo de exercício
                    _buildLabel('Tipo de exercício'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedType,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _exerciseTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedType = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Campo de duração
                    _buildLabel('Duração (minutos)'),
                    TextFormField(
                      controller: _durationController,
                      decoration: _inputDecoration('Ex: 30'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe a duração';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Campo de intensidade
                    _buildLabel('Intensidade'),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Leve', style: TextStyle(color: Colors.grey)),
                        Text('Moderada', style: TextStyle(color: Colors.grey)),
                        Text('Intensa', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Slider(
                      value: _intensity,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: AppColors.success,
                      inactiveColor: Colors.grey.shade300,
                      label: _intensity.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _intensity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Substituir notas por upload de imagem
                    _buildLabel('Imagem do treino (opcional)'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        // Em um app real, usaríamos image_picker
                        setState(() {
                          // Simulação de seleção
                        });
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toque para adicionar uma foto',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Registre visualmente seu progresso',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Botão de enviar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Salvar Treino',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Label dos campos
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Estilo dos inputs
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.success),
      ),
    );
  }

  // Enviar formulário
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Aqui implementamos a lógica para salvar o treino
      
      // Fechamos o bottom sheet
      Navigator.pop(context);
      
      // Mostramos uma confirmação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Treino registrado com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
