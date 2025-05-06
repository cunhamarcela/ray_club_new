// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';

/// Widget que exibe o controle de consumo de água
class WaterIntakeWidget extends ConsumerWidget {
  /// Construtor
  const WaterIntakeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar o progresso de água
    final waterIntakeAsyncValue = ref.watch(waterIntakeProvider);
    
    return waterIntakeAsyncValue.when(
      data: (waterIntakeData) => _buildWaterIntakeCard(context, ref, waterIntakeData),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Erro ao carregar dados de água',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => ref.refresh(dashboardViewModelProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói o card de consumo de água
  Widget _buildWaterIntakeCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic>? waterIntakeData,
  ) {
    // Se não há dados de consumo de água, mostrar tela para criar
    if (waterIntakeData == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Consumo de Água',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Mensagem e botão
              Center(
                child: Column(
                  children: [
                    Text(
                      'Nenhum registro de água para hoje',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(dashboardViewModelProvider.notifier).initializeWaterIntakeIfNeeded();
                      },
                      child: const Text('Iniciar Registro'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Extrair dados do registro
    final int currentGlasses = waterIntakeData['cups'] as int? ?? 0;
    final int dailyGoal = waterIntakeData['goal'] as int? ?? 8;
    final isGoalReached = currentGlasses >= dailyGoal;
    final double progress = dailyGoal > 0 ? (currentGlasses / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final int remainingGlasses = (dailyGoal - currentGlasses).clamp(0, dailyGoal);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título e meta
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Consumo de Água',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$currentGlasses/$dailyGoal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isGoalReached ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Visualização do progresso
            _buildWaterVisualization(context, currentGlasses, dailyGoal, progress),
            
            const SizedBox(height: 16),
            
            // Status atual
            Text(
              isGoalReached
                  ? 'Meta diária atingida! 🎉'
                  : 'Faltam $remainingGlasses copos para atingir a meta',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isGoalReached ? Colors.green : Colors.black87,
                fontWeight: isGoalReached ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botões para adicionar/remover
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão de remover
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: currentGlasses > 0
                        ? () => ref.read(dashboardViewModelProvider.notifier).removeWaterGlass()
                        : null,
                    icon: const Icon(Icons.remove),
                    label: const Text('Remover'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Botão de adicionar
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(dashboardViewModelProvider.notifier).addWaterGlass(),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói a visualização do progresso de água
  Widget _buildWaterVisualization(
    BuildContext context,
    int currentGlasses,
    int dailyGoal,
    double progress,
  ) {
    final width = MediaQuery.of(context).size.width - 64; // Margem total de 64
    final glassWidth = width / dailyGoal;
    
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          // Fundo (copos vazios)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dailyGoal,
              (index) => _buildGlass(
                context,
                width: glassWidth,
                isFilled: false,
              ),
            ),
          ),
          
          // Copos preenchidos
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              currentGlasses,
              (index) => _buildGlass(
                context,
                width: glassWidth,
                isFilled: true,
              ),
            ),
          ),
          
          // Indicador de progresso
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói um copo individual
  Widget _buildGlass(
    BuildContext context, {
    required double width,
    required bool isFilled,
  }) {
    return Container(
      width: width - 4, // Espaço entre copos
      height: 60,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isFilled ? Colors.blue.withOpacity(0.2) : Colors.grey.shade100,
        border: Border.all(
          color: isFilled ? Colors.blue : Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop,
            size: 24,
            color: isFilled ? Colors.blue : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
} 