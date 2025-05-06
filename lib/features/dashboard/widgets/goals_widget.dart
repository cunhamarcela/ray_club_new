// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';

/// Widget que exibe as metas do usuário
class GoalsWidget extends ConsumerWidget {
  /// Construtor
  const GoalsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar as metas do usuário
    final goalsAsyncValue = ref.watch(userGoalsProvider);
    
    return goalsAsyncValue.when(
      data: (goals) => _buildGoalsCard(context, ref, goals),
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
                'Erro ao carregar metas',
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
  
  /// Constrói o card de metas
  Widget _buildGoalsCard(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> goals) {
    if (goals.isEmpty) {
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
                  const Icon(Icons.flag, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Suas Metas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Mensagem de nenhuma meta
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_task,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Você ainda não tem metas definidas',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Defina metas no seu perfil para acompanhar seu progresso aqui',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navegação para a tela de perfil (adicionar metas)
                        // TODO: Implementar navegação para a tela de metas
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Meta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
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
            // Título e botão de adicionar
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Suas Metas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Navegação para a tela de perfil (adicionar metas)
                    // TODO: Implementar navegação para a tela de metas
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Adicionar Meta',
                  color: Colors.green,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lista de metas
            for (int i = 0; i < goals.length; i++)
              _buildGoalItem(context, ref, goals[i], i),
          ],
        ),
      ),
    );
  }
  
  /// Constrói um item de meta individual
  Widget _buildGoalItem(BuildContext context, WidgetRef ref, Map<String, dynamic> goal, int index) {
    // Extrair valores do mapa de goal
    final String title = goal['title'] as String? ?? 'Meta';
    final double currentValue = (goal['current_value'] as num?)?.toDouble() ?? 0.0;
    final double targetValue = (goal['target_value'] as num?)?.toDouble() ?? 100.0;
    final String unit = goal['unit'] as String? ?? '';
    final bool isCompleted = goal['is_completed'] as bool? ?? false;
    
    // Calcular progresso
    final double progress = targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    
    // Verificar se os valores devem ser exibidos como inteiros
    final bool isInteger = goal['is_integer'] as bool? ?? false;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e valores
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${currentValue.toStringAsFixed(isInteger ? 0 : 1)}/${targetValue.toStringAsFixed(isInteger ? 0 : 1)} $unit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Barra de progresso
          Stack(
            children: [
              // Background
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              // Progresso
              Container(
                width: MediaQuery.of(context).size.width * progress * 0.8, // 0.8 para compensar os paddings
                height: 8,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Buttons para ajustar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botão para diminuir
              IconButton(
                onPressed: () {
                  // Decrementar o valor da meta
                  // Obter o ViewModel do dashboard e chamar o método para decrementar
                  ref.read(dashboardViewModelProvider.notifier).decrementGoalValue(index);
                },
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.red,
              ),
              const SizedBox(width: 16),
              
              // Botão para aumentar
              IconButton(
                onPressed: () {
                  // Incrementar o valor da meta
                  // Obter o ViewModel do dashboard e chamar o método para incrementar
                  ref.read(dashboardViewModelProvider.notifier).incrementGoalValue(index);
                },
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 