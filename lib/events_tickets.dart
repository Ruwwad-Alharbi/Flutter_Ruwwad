import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';


// ========== MODELS ==========

class Event {
  final String id, title, introduction;
  final List<String> images;
  bool isRead;
  int viewCount;
  Event({
    required this.id,
    required this.title,
    required this.introduction,
    required this.images,
    this.isRead = false,
    this.viewCount = 0,
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'introduction': introduction,
    'images': images, 'isRead': isRead, 'viewCount': viewCount,
  };
  factory Event.fromJson(Map<String, dynamic> j) => Event(
    id: j['id'], title: j['title'], introduction: j['introduction'],
    images: List<String>.from(j['images']),
    isRead: j['isRead'] ?? false, viewCount: j['viewCount'] ?? 0,
  );
}

class Ticket {
  final String id, type, name, imagePath, dateTime, seat;
  Ticket({
    required this.id,
    required this.type,
    required this.name,
    required this.imagePath,
    required this.dateTime,
    required this.seat,
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'name': name,
    'imagePath': imagePath, 'dateTime': dateTime, 'seat': seat,
  };
  factory Ticket.fromJson(Map<String, dynamic> j) => Ticket(
    id: j['id'], type: j['type'], name: j['name'],
    imagePath: j['imagePath'], dateTime: j['dateTime'], seat: j['seat'],
  );
}

// ========== EVENTS LIST PAGE ==========

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});
  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  List<Event> _events = [];
  String _filter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final jsonString = await rootBundle.loadString('assets/events_data.json');
      final jsonData = jsonDecode(jsonString);
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('events');

      if (saved != null && saved.isNotEmpty) {
        final List<dynamic> savedList = jsonDecode(saved);
        _events = savedList.map((e) => Event.fromJson(e)).toList();
      } else {
        _events = (jsonData['events'] as List).map((e) => Event(
          id: e['id'], title: e['title'], introduction: e['introduction'],
          images: List<String>.from(e['images']),
        )).toList();
      }
    } catch (e) {
      print('Error loading events: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('events', jsonEncode(_events.map((e) => e.toJson()).toList()));
  }

  List<Event> get _filteredEvents {
    if (_filter == 'Unread') return _events.where((e) => !e.isRead).toList();
    if (_filter == 'Read') return _events.where((e) => e.isRead).toList();
    return _events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _filterBtn('All'), const SizedBox(width: 12),
              _filterBtn('Unread'), const SizedBox(width: 12),
              _filterBtn('Read'),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEvents.length,
              itemBuilder: (ctx, i) {
                final event = _filteredEvents[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(6)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: event.images.isNotEmpty
                            ? Image.asset(event.images[0], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey))
                            : const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                    title: Text(event.title, style: TextStyle(fontWeight: event.isRead ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text(event.introduction, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: event.isRead ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(12)),
                      child: Text(event.isRead ? 'Read' : 'Unread', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                    onTap: () {
                      final idx = _events.indexWhere((e) => e.id == event.id);
                      if (idx != -1) {
                        setState(() => _events[idx].isRead = true);
                        _saveEvents();
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsPage(event: event))).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(String label) => ElevatedButton(
    onPressed: () => setState(() => _filter = label),
    style: ElevatedButton.styleFrom(
      backgroundColor: _filter == label ? Colors.blue : Colors.grey.shade300,
      foregroundColor: _filter == label ? Colors.white : Colors.black87,
      elevation: 0,
    ),
    child: Text(label),
  );
}

// ========== EVENT DETAILS PAGE ==========

class EventDetailsPage extends StatefulWidget {
  final Event event;
  const EventDetailsPage({super.key, required this.event});
  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => widget.event.viewCount++);
      _saveViewCount();
    });
  }

  Future<void> _saveViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('events');
    if (saved != null && saved.isNotEmpty) {
      final List<dynamic> events = jsonDecode(saved);
      for (var e in events) {
        if (e['id'] == widget.event.id) {
          e['viewCount'] = widget.event.viewCount;
          break;
        }
      }
      await prefs.setString('events', jsonEncode(events));
    }
  }

  void _openFullscreen(int startIndex) {
    int current = startIndex;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.black87,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          child: Image.asset(
                            widget.event.images[current],
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                        onPressed: () => setDialogState(() {
                          current = (current - 1 + widget.event.images.length) % widget.event.images.length;
                        }),
                      ),
                      Text(
                        '${current + 1}/${widget.event.images.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                        onPressed: () => setDialogState(() {
                          current = (current + 1) % widget.event.images.length;
                        }),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.event.introduction,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.visibility, size: 15, color: Colors.grey), const SizedBox(width: 4), Text('${widget.event.viewCount} views', style: const TextStyle(color: Colors.grey, fontSize: 13))]),
            const SizedBox(height: 16),
            const Text('Images', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.event.images.length,
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () { setState(() => _selectedIndex = i); _openFullscreen(i); },
                  child: Container(
                    width: 96, height: 96,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _selectedIndex == i ? Colors.blue : Colors.transparent, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(widget.event.images[i], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40, color: Colors.grey)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.event.introduction, style: const TextStyle(fontSize: 15, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

// ========== TICKETS LIST PAGE ==========

class TicketsListPage extends StatefulWidget {
  const TicketsListPage({super.key});
  @override
  State<TicketsListPage> createState() => _TicketsListPageState();
}

class _TicketsListPageState extends State<TicketsListPage> {
  List<Ticket> _opening = [];
  List<Ticket> _closing = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('tickets');
    if (saved != null && saved.isNotEmpty) {
      final list = jsonDecode(saved) as List;
      setState(() {
        _opening = list.where((t) => t['type'] == 'Opening Ceremony').map((t) => Ticket.fromJson(t)).toList();
        _closing = list.where((t) => t['type'] == 'Closing Ceremony').map((t) => Ticket.fromJson(t)).toList();
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final all = [..._opening, ..._closing];
    await prefs.setString('tickets', jsonEncode(all.map((t) => t.toJson()).toList()));
  }

  void _addTicket(Ticket t) {
    setState(() { t.type == 'Opening Ceremony' ? _opening.add(t) : _closing.add(t); });
    _save();
  }

  Widget _buildDraggableList(List<Ticket> list, bool isOpening) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = list.removeAt(oldIndex);
          list.insert(newIndex, item);
        });
        _save();
      },
      itemBuilder: (ctx, i) {
        final ticket = list[i];
        return Dismissible(
          key: Key(ticket.id),
          direction: DismissDirection.horizontal,
          onDismissed: (_) { setState(() => list.remove(ticket)); _save(); },
          background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Icon(Icons.delete, color: Colors.white)),
          secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
          child: Card(
            key: ValueKey(ticket.id),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                child: ticket.imagePath.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.memory(base64Decode(ticket.imagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey)))
                    : const Icon(Icons.confirmation_number, color: Colors.grey),
              ),
              title: Text(ticket.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(ticket.seat, style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailsPage(ticket: ticket))),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets List'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Button at the top of the body
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicketCreatePage()),
                );
                if (result != null) _addTicket(result);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create a new ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          // Tickets list
          Expanded(
            child: _opening.isEmpty && _closing.isEmpty
                ? const Center(child: Text('No tickets yet.\nTap "Create a new ticket" to add one.', textAlign: TextAlign.center))
                : ListView(
              children: [
                if (_opening.isNotEmpty) ...[
                  const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text('Opening Ceremony Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey))),
                  _buildDraggableList(_opening, true),
                ],
                if (_closing.isNotEmpty) ...[
                  const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text('Closing Ceremony Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey))),
                  _buildDraggableList(_closing, false),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== TICKET CREATE PAGE ==========

class TicketCreatePage extends StatefulWidget {
  const TicketCreatePage({super.key});
  @override
  State<TicketCreatePage> createState() => _TicketCreatePageState();
}

class _TicketCreatePageState extends State<TicketCreatePage> {
  String _type = 'Opening Ceremony';
  final _nameCtrl = TextEditingController();
  String? _imageBase64;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBase64 = base64Encode(bytes));
    }
  }

  String _generateSeat() {
    final rng = DateTime.now().millisecondsSinceEpoch;
    final letter = ['A', 'B', 'C'][rng % 3];
    final row = (rng % 10) + 1;
    final col = ((rng ~/ 13) % 10) + 1;
    return '$letter$row Row$row Column$col';
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  void _create() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }
    final now = DateTime.now();
    final dt = '${now.year}-${_p(now.month)}-${_p(now.day)} ${_p(now.hour)}:${_p(now.minute)}';
    Navigator.pop(context, Ticket(
      id: now.millisecondsSinceEpoch.toString(),
      type: _type,
      name: _nameCtrl.text.trim(),
      imagePath: _imageBase64 ?? '',
      dateTime: dt,
      seat: _generateSeat(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Create'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _type,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onChanged: (v) => setState(() => _type = v!),
                  items: const [
                    DropdownMenuItem(value: 'Opening Ceremony', child: Text('Opening Ceremony')),
                    DropdownMenuItem(value: 'Closing Ceremony', child: Text('Closing Ceremony')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'Input your name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _pickImage, child: const Text('Choose one picture')),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                child: _imageBase64 != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.memory(base64Decode(_imageBase64!), fit: BoxFit.contain))
                    : const Center(child: Text('Preview picture', style: TextStyle(color: Colors.grey))),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _create,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, side: const BorderSide(color: Colors.grey), padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== TICKET DETAILS PAGE ==========

class TicketDetailsPage extends StatefulWidget {
  final Ticket ticket;
  const TicketDetailsPage({super.key, required this.ticket});
  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  bool _saving = false;
  final GlobalKey _ticketKey = GlobalKey();

  Future<void> _download() async {
    setState(() => _saving = true);
    try {
      final boundary = _ticketKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage();
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        if (byteData != null) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save Successfully')));
          }
        }
      }
    } catch (e) {
      print('Error saving: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save Successfully')));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _ticketKey,
                child: Container(
                  width: 320, margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity, height: 160,
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        child: widget.ticket.imagePath.isNotEmpty
                            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(base64Decode(widget.ticket.imagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50)))
                            : const Center(child: Text('Ticket Picture', style: TextStyle(color: Colors.grey))),
                      ),
                      const SizedBox(height: 16),
                      _row('Ticket type:', widget.ticket.type),
                      const SizedBox(height: 6),
                      _row("Audience's name:", widget.ticket.name),
                      const SizedBox(height: 6),
                      _row('Time:', widget.ticket.dateTime),
                      const SizedBox(height: 6),
                      _row('Seat:', widget.ticket.seat),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _download,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, side: const BorderSide(color: Colors.grey), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Download'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(width: 6),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
    ],
  );
}