import 'package:chama_app/widgets/app_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2calendar;

// Usaremos a mesma classe de modelo de evento
class AgendaEvent {
  final String title;
  final String description;
  final DateTime date;
  AgendaEvent({required this.title, required this.description, required this.date});

  factory AgendaEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AgendaEvent(
      title: data['titulo'] ?? 'Sem título',
      description: data['descricao'] ?? '',
      date: (data['data'] as Timestamp).toDate(),
    );
  }
}

class AgendaBandaScreen extends StatefulWidget {
  const AgendaBandaScreen({super.key});

  @override
  State<AgendaBandaScreen> createState() => _AgendaBandaScreenState();
}

class _AgendaBandaScreenState extends State<AgendaBandaScreen> {
  bool _isCalendarView = true;
  Map<DateTime, List<AgendaEvent>> _eventsByDay = {};
  List<AgendaEvent> _allEventsSorted = [];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<AgendaEvent> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEvents();
  }

  void _fetchEvents() {
    // <<<--- MUDANÇA PRINCIPAL: Lê da nova coleção 'agenda_banda'
    FirebaseFirestore.instance.collection('agenda_banda').orderBy('data').snapshots().listen((snapshot) {
      final Map<DateTime, List<AgendaEvent>> eventsSource = {};
      final List<AgendaEvent> allEvents = [];

      for (var doc in snapshot.docs) {
        final event = AgendaEvent.fromFirestore(doc);
        allEvents.add(event);

        final dayOnly = DateTime.utc(event.date.year, event.date.month, event.date.day);
        if (eventsSource[dayOnly] == null) {
          eventsSource[dayOnly] = [];
        }
        eventsSource[dayOnly]!.add(event);
      }
      if(mounted) {
        setState(() {
          _eventsByDay = eventsSource;
          _allEventsSorted = allEvents;
          _onDaySelected(_selectedDay!, _focusedDay);
        });
      }
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if(mounted){
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  List<AgendaEvent> _getEventsForDay(DateTime day) {
    final dayOnly = DateTime.utc(day.year, day.month, day.day);
    return _eventsByDay[dayOnly] ?? [];
  }

  Future<void> _addToPersonalCalendar(AgendaEvent nossoEvento) async {
    final eventoDoPacote = add2calendar.Event(
      title: nossoEvento.title,
      description: nossoEvento.description,
      location: '',
      startDate: nossoEvento.date,
      endDate: nossoEvento.date.add(const Duration(hours: 1)),
    );
    
    try {
      final bool? success = await add2calendar.Add2Calendar.addEvent2Cal(eventoDoPacote);
      if (!mounted) return;
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento adicionado ao calendário com sucesso!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ação cancelada pelo usuário.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o aplicativo de calendário.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Agenda da Banda', // <<<--- TÍTULO ATUALIZADO
      actions: [
        IconButton(
          icon: Icon(_isCalendarView ? Icons.view_list_outlined : Icons.calendar_today_outlined),
          tooltip: _isCalendarView ? 'Ver em lista' : 'Ver em calendário',
          onPressed: () {
            setState(() {
              _isCalendarView = !_isCalendarView;
            });
          },
        ),
      ],
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isCalendarView ? _buildCalendarView() : _buildTimelineView(),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        TableCalendar<AgendaEvent>(
          locale: 'pt_BR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          eventLoader: _getEventsForDay,
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: Colors.white),
            weekendTextStyle: const TextStyle(color: Colors.white70),
            selectedDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: Colors.red.withOpacity(0.5), shape: BoxShape.circle),
            markerDecoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.white),
            weekendStyle: TextStyle(color: Colors.white),
          ),
        ),
        const Divider(color: Colors.white30, height: 1),
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("Eventos do Dia Selecionado", style: TextStyle(color: Colors.white, fontFamily: 'Nexa', fontSize: 16)),
        ),
        Expanded(
          child: _selectedEvents.isEmpty
            ? const Center(
                child: Text('Nenhum evento para este dia.', style: TextStyle(color: Colors.white)),
              )
            : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: _selectedEvents.length,
            itemBuilder: (context, index) {
              final event = _selectedEvents[index];
              return Card(
                color: const Color(0xFF192F3C).withOpacity(0.9),
                child: ListTile(
                  leading: Text(DateFormat('HH:mm').format(event.date), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  title: Text(event.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: event.description.isNotEmpty ? Text(event.description, style: const TextStyle(color: Colors.white70)) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.add_alert_outlined, color: Colors.white70),
                    tooltip: 'Adicionar à agenda pessoal',
                    onPressed: () => _addToPersonalCalendar(event),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineView() {
    if (_allEventsSorted.isEmpty) {
      return const Center(
        child: Text('Nenhum evento na agenda.', style: TextStyle(color: Colors.white, fontSize: 16)),
      );
    }
    
    // ignore: unused_local_variable
    String? lastDateHeader;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _allEventsSorted.length,
      itemBuilder: (context, index) {
        final event = _allEventsSorted[index];
        final eventDateHeader = DateFormat.yMMMMd('pt_BR').format(event.date);
        final bool showHeader = index == 0 || !isSameDay(_allEventsSorted[index - 1].date, event.date);
        lastDateHeader = eventDateHeader;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  if (showHeader)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('dd').format(event.date),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('E', 'pt_BR').format(event.date).toUpperCase(),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.only(top: showHeader ? 4 : 20),
                    width: 2,
                    height: 100, // A altura pode precisar de ajuste dependendo do conteúdo do Card
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: showHeader ? 20 : 8, bottom: 8),
                child: Card(
                  color: const Color(0xFF192F3C).withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                     title: Text(event.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                     subtitle: Text(
                       '${DateFormat('HH:mm').format(event.date)} - ${event.description}',
                       style: const TextStyle(color: Colors.white70),
                     ),
                     trailing: IconButton(
                       icon: const Icon(Icons.add_alert_outlined, color: Colors.white70),
                       tooltip: 'Adicionar à agenda pessoal',
                       onPressed: () => _addToPersonalCalendar(event),
                     ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}