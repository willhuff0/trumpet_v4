import 'package:flutter/material.dart';
import 'package:trumpet/database/db.dart';

import 'package:flutter_quill/flutter_quill.dart' as fq;

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final Future<(Iterable<TEvent> iterable, int count)> _getUpcommingEventsFuture;

  @override
  void initState() {
    _getUpcommingEventsFuture = loggedInUser.getUpcommingEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Events'),
      ),
      body: FutureBuilder(
        initialData: null,
        future: _getUpcommingEventsFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            final (upcommingEvents, count) = asyncSnapshot.data!;
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: count,
              itemBuilder: (context, index) {
                final event = upcommingEvents.elementAt(index);
                return EventsPageEventView(event: event);
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class EventsPageEventView extends StatefulWidget {
  final TEvent event;

  const EventsPageEventView({super.key, required this.event});

  @override
  State<EventsPageEventView> createState() => _EventsPageEventViewState();
}

class _EventsPageEventViewState extends State<EventsPageEventView> {
  late final fq.QuillController _quillController;

  @override
  void initState() {
    _quillController = fq.QuillController(
      document: fq.Document.fromDelta(widget.event.about),
      selection: const TextSelection.collapsed(offset: 0),
    );
    super.initState();
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.event.name, style: Theme.of(context).textTheme.titleLarge),
        Expanded(
          child: fq.QuillEditor.basic(
            controller: _quillController,
            readOnly: true,
          ),
        ),
      ],
    );
  }
}
