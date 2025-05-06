// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/workout/viewmodels/workout_history_view_model.dart';
import '../models/workout_record.dart';

@RoutePage()
class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(workoutHistoryViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Histórico de Treinos', style: AppTypography.headingMedium),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.router.maybePop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          tabs: const [
            Tab(text: 'Calendário'),
            Tab(text: 'Lista'),
          ],
        ),
      ),
      body: historyState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => _buildErrorView(message),
        empty: () => _buildEmptyView(),
        loaded: (allRecords, selectedDate, selectedDateRecords) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCalendarView(allRecords, selectedDate, selectedDateRecords),
              _buildHistoryList(allRecords),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar histórico',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Tentar novamente',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 64, color: AppColors.textLight),
          const SizedBox(height: 24),
          Text(
            'Nenhuma atividade registrada',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre seus treinos para acompanhar seu progresso',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalendarView(
    List<WorkoutRecord> allRecords, 
    DateTime? selectedDate, 
    List<WorkoutRecord>? selectedDateRecords
  ) {
    final viewModel = ref.read(workoutHistoryViewModelProvider.notifier);
    final workoutsByDay = viewModel.getWorkoutsByDay();
    
    return Column(
      children: [
        _buildCalendar(workoutsByDay, selectedDate),
        const Divider(color: AppColors.divider),
        Expanded(
          child: selectedDate != null && selectedDateRecords != null
              ? selectedDateRecords.isEmpty
                  ? _buildNoWorkoutsForDayView(selectedDate)
                  : _buildSelectedDayWorkouts(selectedDateRecords)
              : _buildSelectDayPrompt(),
        ),
      ],
    );
  }
  
  Widget _buildCalendar(Map<DateTime, List<WorkoutRecord>> workoutsByDay, DateTime? selectedDay) {
    final viewModel = ref.read(workoutHistoryViewModelProvider.notifier);
    
    return TableCalendar(
      firstDay: DateTime.utc(2021, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 1)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      eventLoader: (day) {
        // Normalizar a data para comparação
        final normalized = DateTime(day.year, day.month, day.day);
        return workoutsByDay[normalized] ?? [];
      },
      selectedDayPredicate: (day) {
        if (selectedDay == null) return false;
        return isSameDay(selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        viewModel.selectDate(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        weekendTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
        defaultTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.white),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: AppTypography.headingSmall.copyWith(color: AppColors.white),
        formatButtonTextStyle: AppTypography.bodySmall.copyWith(color: AppColors.primary),
        leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
        rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
        weekendStyle: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
      ),
    );
  }
  
  Widget _buildSelectDayPrompt() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 48, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'Selecione uma data no calendário para ver suas atividades',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoWorkoutsForDayView(DateTime date) {
    final formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 48, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              'Nenhuma atividade em $formattedDate',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(workoutHistoryViewModelProvider.notifier).clearSelectedDate();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Voltar ao calendário'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSelectedDayWorkouts(List<WorkoutRecord> records) {
    if (records.isEmpty) {
      return _buildNoWorkoutsForDayView(DateTime.now());
    }
    
    final viewModel = ref.read(workoutHistoryViewModelProvider.notifier);
    final formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(records.first.date);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Atividades em $formattedDate',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textLight),
                onPressed: () => viewModel.clearSelectedDate(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              return _buildHistoryItem(context, records[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<WorkoutRecord> records) {
    // Agrupar registros por mês
    final groupedRecords = <String, List<WorkoutRecord>>{};
    
    for (final record in records) {
      final month = DateFormat('MMMM y', 'pt_BR').format(record.date);
      groupedRecords.putIfAbsent(month, () => []).add(record);
    }
    
    // Ordenar meses (mais recentes primeiro)
    final sortedMonths = groupedRecords.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM y', 'pt_BR').parse(a);
        final dateB = DateFormat('MMMM y', 'pt_BR').parse(b);
        return dateB.compareTo(dateA);
      });
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final monthRecords = groupedRecords[month]!;
        
        // Ordenar registros do mês (mais recentes primeiro)
        monthRecords.sort((a, b) => b.date.compareTo(a.date));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                month,
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...monthRecords.map((record) => _buildHistoryItem(context, record)),
          ],
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, WorkoutRecord record) {
    // Converter o valor de intensidade para texto
    final String intensidade = _getIntensidadeText(record);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone do tipo de treino
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getWorkoutTypeIcon(record.workoutType),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modalidade de treino
                  Text(
                    record.workoutType,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Duração
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, size: 16, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        '${record.durationMinutes} minutos',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Data 
                  Text(
                    DateFormat('dd/MM/yyyy', 'pt_BR').format(record.date),
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
                  ),
                  // Intensidade
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.speed, size: 16, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getIntensidadeColor(record),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          intensidade,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status (completo)
            record.isCompleted
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : const Icon(Icons.pending, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
  
  // Função para converter o valor de intensidade para texto
  String _getIntensidadeText(WorkoutRecord record) {
    if (record.notes != null && record.notes!.contains("intens")) {
      return "Intensa";
    } else if (record.notes != null && (record.notes!.contains("metade") || record.notes!.contains("moderad"))) {
      return "Moderada";
    } else {
      return "Leve";
    }
  }
  
  Color _getIntensidadeColor(WorkoutRecord record) {
    if (record.notes != null && record.notes!.contains("intens")) {
      return AppColors.error.withOpacity(0.8);
    } else if (record.notes != null && (record.notes!.contains("metade") || record.notes!.contains("moderad"))) {
      return AppColors.accent.withOpacity(0.8);
    } else {
      return AppColors.success.withOpacity(0.8);
    }
  }
  
  IconData _getWorkoutTypeIcon(String workoutType) {
    switch (workoutType.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'força':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'pilates':
        return Icons.accessibility_new;
      case 'hiit':
        return Icons.flash_on;
      case 'alongamento':
        return Icons.straighten;
      default:
        return Icons.fitness_center;
    }
  }
} 