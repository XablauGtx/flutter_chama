import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // A importação de intl ainda é necessária para formatar HH:mm, mas não para o locale do calendário.

// --- Classes de Modelo ---

// Classe para representar um evento do coral
class CoralEvent {
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String location;

  CoralEvent({
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.location = 'Local não especificado', // Valor padrão
  });

  // Método para facilitar a cópia (útil se você for modificar eventos futuramente)
  CoralEvent copyWith({
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    String? location,
  }) {
    return CoralEvent(
      title: title ?? this.title,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
      location: location ?? this.location,
    );
  }
}

// --- Tela da Agenda ---

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  // Controle do calendário
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mapa para armazenar eventos por data.
  // A chave é uma data normalizada (apenas ano, mês, dia)
  // para que os eventos sejam agrupados corretamente.
  Map<DateTime, List<CoralEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Inicia com o dia atual selecionado
    _loadCoralEvents(); // Carrega os eventos do coral ao iniciar a tela
  }

  // Função para carregar os eventos do coral
  // No futuro, você obterá esses dados de uma API, Firebase, etc.
  void _loadCoralEvents() {
    final now = DateTime.now();
    // Exemplo de eventos "hardcoded" para demonstração:
    _events = {
      // Evento para amanhã
      DateTime.utc(now.year, now.month, now.day + 1): [
        CoralEvent(
          title: 'Ensaio Vozes e Instrumentos',
          description: 'Ensaio geral para a missa de domingo. Trazer partituras.',
          start: DateTime.utc(now.year, now.month, now.day + 1, 19, 30),
          end: DateTime.utc(now.year, now.month, now.day + 1, 21, 0),
          location: 'Salão Paroquial',
        ),
      ],
      // Evento para daqui a 3 dias
      DateTime.utc(now.year, now.month, now.day + 3): [
        CoralEvent(
          title: 'Missa Especial de Ação de Graças',
          description: 'Participação do coral na missa das 10h. Chegar 30 min antes.',
          start: DateTime.utc(now.year, now.month, now.day + 3, 10, 0),
          end: DateTime.utc(now.year, now.month, now.day + 3, 11, 30),
          location: 'Igreja Matriz Nossa Senhora do Rosário',
        ),
      ],
      // Múltiplos eventos para a próxima semana
      DateTime.utc(now.year, now.month, now.day + 7): [
        CoralEvent(
          title: 'Reunião de Planejamento - Natal',
          description: 'Discussão do repertório e logística para as celebrações de Natal.',
          start: DateTime.utc(now.year, now.month, now.day + 7, 18, 0),
          end: DateTime.utc(now.year, now.month, now.day + 7, 19, 0),
          location: 'Sala de Reuniões da Secretaria',
        ),
        CoralEvent(
          title: 'Ensaio Adicional - Sopranos',
          description: 'Foco em passagens específicas para o naipe de sopranos.',
          start: DateTime.utc(now.year, now.month, now.day + 7, 19, 15),
          end: DateTime.utc(now.year, now.month, now.day + 7, 20, 30),
          location: 'Auditório da Igreja',
        ),
      ],
    };
    setState(() {}); // Atualiza a UI para exibir os eventos carregados
  }

  // Retorna a lista de eventos para um dia específico.
  // Garante que a data passada seja normalizada para corresponder às chaves do mapa.
  List<CoralEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda do Coral'),
      ),
      body: Column(
        children: [
          // Widget do Calendário
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              // Usa 'isSameDay' para comparar apenas ano, mês e dia
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              // Só atualiza o estado se um novo dia for selecionado
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // Mantém o calendário focado no mês do dia selecionado
                });
              }
            },
            onFormatChanged: (format) {
              // Permite mudar o formato do calendário (mês, semana, etc.)
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // Atualiza o dia focado quando o usuário arrasta para outros meses/semanas
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay, // Função que carrega eventos para cada dia
            calendarBuilders: CalendarBuilders(
              // Construtor para marcadores de eventos (o pequeno ponto/número no dia)
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildEventsMarker(events.length),
                  );
                }
                return null;
              },
            ),
            // Remova a linha abaixo:
            // locale: 'pt_BR', // Agora o calendário usará o locale padrão do dispositivo
          ),
          const SizedBox(height: 8.0),
          // Lista de eventos para o dia selecionado
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Selecione um dia para ver os eventos do coral.'))
                : _getEventsForDay(_selectedDay!).isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum evento agendado para ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}.',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _getEventsForDay(_selectedDay!).length,
                        itemBuilder: (context, index) {
                          final event = _getEventsForDay(_selectedDay!)[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '${DateFormat('HH:mm').format(event.start)} - ${DateFormat('HH:mm').format(event.end)}',
                                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Local: ${event.location}',
                                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                                  ),
                                  if (event.description.isNotEmpty) ...[
                                    const SizedBox(height: 4.0),
                                    Text(
                                      event.description,
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para construir o marcador de eventos no calendário
  Widget _buildEventsMarker(int eventCount) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor, // Usa a cor primária do seu tema
      ),
      width: 18.0,
      height: 18.0,
      child: Center(
        child: Text(
          '$eventCount',
          style: const TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
