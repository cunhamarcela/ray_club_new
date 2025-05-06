// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/widgets/app_loading_indicator.dart';
import 'package:ray_club_app/core/widgets/app_error_widget.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';
import 'package:ray_club_app/features/goals/repositories/goal_repository.dart';
import 'package:ray_club_app/features/goals/repositories/water_intake_repository.dart';
import 'package:ray_club_app/shared/bottom_navigation_bar.dart';

@RoutePage()
class ProgressPlanScreen extends ConsumerStatefulWidget {
  const ProgressPlanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProgressPlanScreen> createState() => _ProgressPlanScreenState();
}

class _ProgressPlanScreenState extends ConsumerState<ProgressPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Your Activity',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goals progress section
            _buildGoalsProgress(),
            
            // Water consumption tracker
            _buildWaterConsumptionTracker(),
            
            // Workout statistics with chart
            _buildWorkoutStatistics(),
            
            // Challenge participation section
            _buildChallengeParticipation(),
            
            // Redeemed coupons section
            _buildRedeemedCoupons(),
            
            // Calendar showing workout days
            _buildWorkoutCalendar(),
          ],
        ),
      ),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 0),
    );
  }

  // Indicadores circulares de progresso para estatísticas
  Widget _buildProgressMetrics() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCircularMetric(
            value: 10,
            total: 14,
            label: '04 left',
            color: Colors.orange,
            percent: 71, // 10/14 ≈ 71%
          ),
          _buildCircularMetric(
            value: 70,
            total: 100,
            label: '30 left',
            color: Colors.green,
            percent: 70,
          ),
          _buildCircularMetric(
            value: 82,
            total: 100,
            label: '18% left',
            color: Colors.amber,
            percent: 82,
          ),
        ],
      ),
    );
  }

  // Métrica circular individual
  Widget _buildCircularMetric({
    required int value,
    required int total,
    required String label,
    required Color color,
    required int percent,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/${total}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Seção "My Workouts" com gráfico e histórico
  Widget _buildWorkoutsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Workouts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Show All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildWorkoutItem(
            title: 'Morning GYM',
            date: 'Last • 13/11/24',
            intensity: 15.0,
          ),
          const SizedBox(height: 16),
          // Gráfico de progresso simulado
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: ChartPainter(),
            ),
          ),
          const SizedBox(height: 20),
          // Número atual e botão de início
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '28',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    'Today completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Start Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Item individual de treino
  Widget _buildWorkoutItem({
    required String title,
    required String date,
    required double intensity,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF777777)),
          onPressed: () {},
        ),
      ],
    );
  }

  // Calendário de treinos
  Widget _buildWorkoutCalendar() {
    // Mock data for workout days
    final workoutDays = {
      DateTime(2025, 4, 1): ['Treino de Pernas'],
      DateTime(2025, 4, 3): ['Treino de Peito', 'Cardio HIIT'],
      DateTime(2025, 4, 5): ['Treino Completo'],
      DateTime(2025, 4, 8): ['Treino de Costas e Bíceps'],
      DateTime(2025, 4, 11): ['Yoga Flow'],
      DateTime(2025, 4, 12): ['Cardio Moderado'],
      DateTime(2025, 4, 15): ['Treino de Ombros'],
      DateTime(2025, 4, 18): ['Treino de Pernas'],
      DateTime(2025, 4, 21): ['Treino de Peito e Tríceps'],
      DateTime(2025, 4, 23): ['Yoga Restaurativo'],
      DateTime(2025, 4, 25): ['HIIT Intenso'],
      DateTime(2025, 4, 26): ['Treino de Core'],
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendário de Treinos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  // Navegue para o calendário completo (histórico de treinos)
                  context.router.pushNamed(AppRoutes.workoutHistory);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(color: Colors.red),
              holidayTextStyle: const TextStyle(color: Colors.blue),
              todayDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black54),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black54),
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            eventLoader: (day) {
              // Retorna os eventos para este dia
              return workoutDays[DateTime(day.year, day.month, day.day)] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              
              // Mostrar detalhes do treino se houver algum neste dia
              final workouts = workoutDays[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];
              if (workouts != null && workouts.isNotEmpty) {
                _showWorkoutDetails(context, selectedDay, workouts);
              }
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          
          // Se um dia com treinos for selecionado, mostre informações resumidas
          if (_selectedDay != null) ...[
            const SizedBox(height: 16),
            _buildSelectedDayWorkouts(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSelectedDayWorkouts() {
    // Mock data para os treinos do dia selecionado
    final workoutDetails = {
      DateTime(2025, 4, 3): [
        {
          'name': 'Treino de Peito',
          'duration': '45 min',
          'calories': 320,
          'exercises': ['Supino', 'Crucifixo', 'Pullover', 'Flexões'],
          'time': '07:30',
        },
        {
          'name': 'Cardio HIIT',
          'duration': '25 min',
          'calories': 280,
          'exercises': ['Burpees', 'Mountain Climbers', 'Jumping Jacks', 'Sprints'],
          'time': '18:15',
        },
      ],
    };
    
    // Verifique se há detalhes para o dia selecionado
    final dayKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final workouts = workoutDetails[dayKey] ?? [];
    
    if (workouts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Nenhum detalhe disponível para ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Treinos em ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...workouts.map((workout) {
          return _buildWorkoutListItem(workout);
        }).toList(),
      ],
    );
  }
  
  Widget _buildWorkoutListItem(Map<String, dynamic> workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${workout['time']} • ${workout['duration']} • ${workout['calories']} kcal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Exercícios: ${(workout['exercises'] as List).join(', ')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
  
  void _showWorkoutDetails(BuildContext context, DateTime day, List<dynamic> workouts) {
    // Aqui você mostraria um bottom sheet ou diálogo com detalhes completos
    // dos treinos realizados naquele dia
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Treinos em ${DateFormat('dd/MM/yyyy').format(day)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...workouts.map((workoutName) {
                return ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.orange),
                  title: Text(workoutName),
                  subtitle: const Text('Toque para ver detalhes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navegue para os detalhes do treino específico
                    Navigator.pop(context);
                    // Adicione aqui a navegação para a tela de detalhes do treino
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsProgress() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Suas Metas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Navegar para tela de adicionar meta
                  final result = await context.router.pushNamed(AppRoutes.goalForm);
                  // Se voltou com sucesso, recarrega as metas (atualiza a tela)
                  if (result == true) {
                    setState(() {});
                  }
                },
                child: const Text(
                  'Adicionar Meta',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Buscar metas do repositório
          Consumer(
            builder: (context, ref, child) {
              final goalsAsync = ref.watch(userGoalsProvider);
              
              return goalsAsync.when(
                data: (goals) {
                  if (goals.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Você ainda não tem metas definidas.\nAdicione uma meta para começar!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return Column(
                    children: goals.map((goal) => _buildUserGoalItem(goal)).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: AppLoadingIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: AppErrorWidget(
                    message: 'Erro ao carregar metas: $error',
                    onRetry: () => ref.refresh(userGoalsProvider),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserGoalItem(UserGoal goal) {
    final progressPercentage = goal.percentageCompleted;
    final goalColor = _getGoalColor(goal.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progressPercentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: goalColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(goalColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  
  Color _getGoalColor(GoalType type) {
    switch (type) {
      case GoalType.weight:
        return Colors.red;
      case GoalType.workout:
        return Colors.orange;
      case GoalType.steps:
        return Colors.green;
      case GoalType.nutrition:
        return Colors.blue;
      case GoalType.custom:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildWaterConsumptionTracker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Consumo de Água',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, size: 20),
                onPressed: () => _showUpdateWaterGoalDialog(context),
                tooltip: 'Alterar meta diária',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Uso do Provider para dados de água em tempo real
          Consumer(
            builder: (context, ref, child) {
              final waterIntakeAsync = ref.watch(waterIntakeProvider);
              
              return waterIntakeAsync.when(
                data: (waterIntake) {
                  return Row(
                    children: [
                      _buildWaterIndicator(waterIntake.currentGlasses, waterIntake.dailyGoal),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${waterIntake.currentGlasses}/${waterIntake.dailyGoal} copos',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              waterIntake.remainingGlasses > 0
                                  ? 'Faltam ${waterIntake.remainingGlasses} copos para atingir sua meta diária'
                                  : 'Meta diária atingida! Parabéns!',
                              style: TextStyle(
                                fontSize: 14,
                                color: waterIntake.isGoalReached ? Colors.green : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Adicionar copo de água usando o repository
                                    ref.read(waterIntakeRepositoryProvider).addGlass().then((_) {
                                      ref.refresh(waterIntakeProvider);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: const Text('Adicionar'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: waterIntake.currentGlasses > 0 
                                      ? () {
                                          ref.read(waterIntakeRepositoryProvider).removeGlass().then((_) {
                                            ref.refresh(waterIntakeProvider);
                                          });
                                        }
                                      : null,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Remover'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: AppLoadingIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: AppErrorWidget(
                    message: 'Erro ao carregar dados de água: $error',
                    onRetry: () => ref.refresh(waterIntakeProvider),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showUpdateWaterGoalDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final waterIntakeAsync = ref.watch(waterIntakeProvider);
          
          return waterIntakeAsync.when(
            data: (waterIntake) {
              int newGoal = waterIntake.dailyGoal;
              
              return StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Alterar Meta de Água',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Quantos copos de água você deseja consumir por dia?',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (newGoal > 1) {
                                  setState(() => newGoal--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle, color: Colors.blue),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$newGoal copos',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (newGoal < 20) {
                                  setState(() => newGoal++);
                                }
                              },
                              icon: const Icon(Icons.add_circle, color: Colors.blue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (newGoal != waterIntake.dailyGoal) {
                                  ref.read(waterIntakeRepositoryProvider).updateDailyGoal(newGoal).then((_) {
                                    ref.refresh(waterIntakeProvider);
                                  });
                                }
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: AppLoadingIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text('Erro ao carregar dados: $error'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutStatistics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // Navegue para a tela de histórico de treinos
                  context.router.pushNamed(AppRoutes.workoutHistory);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      size: 20,
                      color: Color(0xFF333333),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Meus Treinos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegue para a tela de histórico de treinos
                  context.router.pushNamed(AppRoutes.workoutHistory);
                },
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                title: 'Treinos Completados',
                value: '28',
                subtitle: 'Este mês',
                iconData: Icons.fitness_center,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Tempo Total',
                value: '14.5h',
                subtitle: 'Este mês',
                iconData: Icons.timer,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Frequência',
                value: '86%',
                subtitle: 'Meta atingida',
                iconData: Icons.trending_up,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Progresso de Tempo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: _buildWorkoutChart(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData iconData,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconData,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildWorkoutChart() {
    // Mock data for the workout time chart
    final weekData = [
      {'day': 'S', 'minutes': 30, 'color': Colors.orange},
      {'day': 'M', 'minutes': 45, 'color': Colors.orange},
      {'day': 'T', 'minutes': 0, 'color': Colors.grey.withOpacity(0.3)},
      {'day': 'W', 'minutes': 60, 'color': Colors.orange},
      {'day': 'T', 'minutes': 40, 'color': Colors.orange},
      {'day': 'F', 'minutes': 50, 'color': Colors.orange},
      {'day': 'S', 'minutes': 75, 'color': Colors.orange},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: weekData.map((data) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              (data['minutes'] as int) > 0 ? '${data['minutes']}m' : '',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: (data['minutes'] as int) > 0 ? (data['minutes'] as int) * 1.2 : 0,
              decoration: BoxDecoration(
                color: data['color'] as Color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['day'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChallengeParticipation() {
    // Mock data for challenges
    final activeChallenges = [
      {
        'name': 'Desafio de Verão 2025',
        'progress': 0.45,
        'position': 12,
        'participants': 230,
        'daysLeft': 18,
        'color': Colors.orange,
      }
    ];
    
    final pastChallenges = [
      {
        'name': 'Maratona Fitness',
        'finalPosition': 8,
        'participants': 186,
        'completionDate': '10/04/2025',
        'color': Colors.green,
      },
      {
        'name': 'Desafio 30 Dias',
        'finalPosition': 3,
        'participants': 145,
        'completionDate': '15/03/2025',
        'color': Colors.blue,
      },
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Desafios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegue para a tela de desafios
                  context.router.push(const ChallengesListRoute());
                },
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Desafios ativos
          if (activeChallenges.isNotEmpty) ...[
            const Text(
              'Desafio Atual',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 12),
            ...activeChallenges.map((challenge) => 
              GestureDetector(
                onTap: () {
                  // Navegue para o detalhe do desafio
                  // Usaria um ID real em um app em produção
                  context.router.push(RealtimeChallengeDetailRoute(challengeId: '123'));
                },
                child: _buildActiveChallenge(challenge),
              )
            ).toList(),
            const SizedBox(height: 24),
          ],
          
          // Desafios passados
          if (pastChallenges.isNotEmpty) ...[
            const Text(
              'Desafios Concluídos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 12),
            ...pastChallenges.map((challenge) => 
              GestureDetector(
                onTap: () {
                  // Navegue para o detalhe do desafio
                  context.router.push(RealtimeChallengeDetailRoute(challengeId: '456'));
                },
                child: _buildPastChallenge(challenge),
              )
            ).toList(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActiveChallenge(Map<String, dynamic> challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: challenge['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  challenge['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Faltam ${challenge['daysLeft']} dias',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: challenge['color'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: challenge['progress'],
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(challenge['color']),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(challenge['progress'] * 100).toInt()}% concluído',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge['position']}º lugar de ${challenge['participants']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPastChallenge(Map<String, dynamic> challenge) {
    final position = challenge['finalPosition'] as int;
    final medal = position <= 3
        ? Icon(
            Icons.emoji_events,
            color: position == 1
                ? Colors.amber
                : position == 2
                    ? Colors.grey[400]
                    : Colors.brown[300],
            size: 20,
          )
        : const SizedBox.shrink();
        
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: challenge['color'],
            margin: const EdgeInsets.only(right: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Concluído em ${challenge['completionDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              medal,
              const SizedBox(width: 4),
              Text(
                '${challenge['finalPosition']}º lugar',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ' / ${challenge['participants']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemedCoupons() {
    // Mock data for redeemed coupons
    final coupons = [
      {
        'title': 'Desconto Smart Fit',
        'description': 'Desconto mensal de 15%',
        'expirationDate': '30/05/2025',
        'logoUrl': 'assets/images/gym_logo.png', // Substitua pelo caminho correto
        'status': 'Ativo',
        'color': Colors.green,
      },
      {
        'title': 'Protein Shop',
        'description': '10% OFF na primeira compra',
        'expirationDate': '10/04/2025',
        'logoUrl': 'assets/images/shop_logo.png', // Substitua pelo caminho correto
        'status': 'Expirado',
        'color': Colors.grey,
      },
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Benefícios Resgatados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegue para a tela de benefícios resgatados
                  context.router.pushNamed(AppRoutes.redeemedBenefits);
                },
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (coupons.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum benefício resgatado ainda',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Navegue para a seção de benefícios disponíveis
                      context.router.pushNamed(AppRoutes.benefits);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Explorar Benefícios'),
                  ),
                ],
              ),
            )
          else
            ...coupons.map((coupon) => 
              GestureDetector(
                onTap: () {
                  // Navegue para o detalhe do benefício
                  context.router.pushNamed(AppRoutes.redeemedBenefitDetail);
                },
                child: _buildCouponItem(coupon),
              )
            ).toList(),
        ],
      ),
    );
  }
  
  Widget _buildCouponItem(Map<String, dynamic> coupon) {
    final isActive = coupon['status'] == 'Ativo';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? coupon['color'].withOpacity(0.3) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Logo placeholder - replace with actual image loading
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? coupon['color'].withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.storefront,
              color: isActive ? coupon['color'] : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coupon['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive ? Colors.black54 : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Válido até ${coupon['expirationDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.black45 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? coupon['color'].withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              coupon['status'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? coupon['color'] : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterIndicator(int consumed, int total) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: (consumed / total) * 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(8),
                bottomRight: const Radius.circular(8),
                topLeft: Radius.circular(consumed == total ? 8 : 0),
                topRight: Radius.circular(consumed == total ? 8 : 0),
              ),
            ),
          ),
          // Water drop icons to visually represent glasses
          ...List.generate(
            total,
            (index) => Positioned(
              bottom: (index * (90 / total)) + 5,
              child: Icon(
                Icons.water_drop,
                color: index < consumed ? Colors.blue : Colors.grey.withOpacity(0.3),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter personalizado para o gráfico
class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.deepOrange.withOpacity(0.3),
          Colors.deepOrange.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    const double baseHeight = 90; // Altura base do gráfico
    
    // Pontos do gráfico (simulados)
    final List<double> points = [
      baseHeight - 30, // 3.0 (escala de intensidade)
      baseHeight - 60, // 6.0
      baseHeight - 45, // 4.5
      baseHeight - 80, // 8.0
      baseHeight - 60, // 6.0
      baseHeight - 90, // 9.0
      baseHeight - 105, // 10.5
    ];
    
    // Calcular o espaçamento horizontal
    final double dx = size.width / (points.length - 1);
    
    // Criar o path para a linha
    final Path linePath = Path();
    linePath.moveTo(0, points[0]);
    
    // Adicionar pontos ao path
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(dx * i, points[i]);
    }
    
    // Criar o path para o preenchimento
    final Path fillPath = Path()..addPath(linePath, Offset.zero);
    fillPath.lineTo(size.width, baseHeight);
    fillPath.lineTo(0, baseHeight);
    fillPath.close();
    
    // Desenhar o preenchimento e a linha
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    
    // Desenhar pontos no gráfico
    final Paint dotPaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final Paint dotFillPaint = Paint()
      ..color = Colors.white;
    
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(Offset(dx * i, points[i]), 3, dotFillPaint);
      canvas.drawCircle(Offset(dx * i, points[i]), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Provider para fornecer as metas do usuário
final userGoalsProvider = FutureProvider<List<UserGoal>>((ref) async {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.getUserGoals();
});

/// ViewModel para gerenciar o consumo de água
class WaterIntakeViewModel extends StateNotifier<AsyncValue<WaterIntake>> {
  final WaterIntakeRepository _repository;
  
  WaterIntakeViewModel(this._repository) : super(const AsyncValue.loading()) {
    // Carrega os dados iniciais
    loadTodayWaterIntake();
  }
  
  /// Carrega os dados de hoje
  Future<void> loadTodayWaterIntake() async {
    state = const AsyncValue.loading();
    try {
      final waterIntake = await _repository.getTodayWaterIntake();
      state = AsyncValue.data(waterIntake);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Adiciona um copo de água
  Future<void> addGlass() async {
    try {
      // Otimismo da UI: atualiza primeiro para feedback imediato
      final currentIntake = state.value;
      if (currentIntake != null) {
        // Atualiza a UI imediatamente (otimisticamente)
        state = AsyncValue.data(
          currentIntake.copyWith(
            currentGlasses: currentIntake.currentGlasses + 1,
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      // Faz a chamada real ao repositório
      final updatedIntake = await _repository.addGlass();
      
      // Atualiza com os dados reais do servidor
      state = AsyncValue.data(updatedIntake);
    } catch (e, stack) {
      // Em caso de erro, reverte para o estado anterior ou mostra erro
      state = AsyncValue.error(e, stack);
      
      // Recarrega os dados corretos
      loadTodayWaterIntake();
    }
  }
  
  /// Remove um copo de água
  Future<void> removeGlass() async {
    try {
      // Otimismo da UI: atualiza primeiro para feedback imediato
      final currentIntake = state.value;
      if (currentIntake != null && currentIntake.currentGlasses > 0) {
        // Atualiza a UI imediatamente (otimisticamente)
        state = AsyncValue.data(
          currentIntake.copyWith(
            currentGlasses: currentIntake.currentGlasses - 1,
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      // Faz a chamada real ao repositório
      final updatedIntake = await _repository.removeGlass();
      
      // Atualiza com os dados reais do servidor
      state = AsyncValue.data(updatedIntake);
    } catch (e, stack) {
      // Em caso de erro, reverte para o estado anterior ou mostra erro
      state = AsyncValue.error(e, stack);
      
      // Recarrega os dados corretos
      loadTodayWaterIntake();
    }
  }
  
  /// Atualiza a meta diária
  Future<void> updateDailyGoal(int newGoal) async {
    try {
      // Validação rápida
      if (newGoal <= 0) return;
      
      // Otimismo da UI: atualiza primeiro para feedback imediato
      final currentIntake = state.value;
      if (currentIntake != null) {
        // Atualiza a UI imediatamente (otimisticamente)
        state = AsyncValue.data(
          currentIntake.copyWith(
            dailyGoal: newGoal,
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      // Faz a chamada real ao repositório
      final updatedIntake = await _repository.updateDailyGoal(newGoal);
      
      // Atualiza com os dados reais do servidor
      state = AsyncValue.data(updatedIntake);
    } catch (e, stack) {
      // Em caso de erro, reverte para o estado anterior ou mostra erro
      state = AsyncValue.error(e, stack);
      
      // Recarrega os dados corretos
      loadTodayWaterIntake();
    }
  }
}

/// Provider para o ViewModel de consumo de água
final waterIntakeViewModelProvider = StateNotifierProvider<WaterIntakeViewModel, AsyncValue<WaterIntake>>((ref) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  return WaterIntakeViewModel(repository);
});

/// Provider para acessar diretamente o estado atual de consumo de água
final waterIntakeProvider = Provider<AsyncValue<WaterIntake>>((ref) {
  return ref.watch(waterIntakeViewModelProvider);
}); 