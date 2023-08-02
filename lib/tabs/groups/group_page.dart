import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:trumpet/database/db.dart';
import 'package:trumpet/firebase_image/firebase_image.dart';

class GroupPage extends StatelessWidget {
  final TGroup group;

  const GroupPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(group.name),
          ),
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 2.0,
              child: group.hasBanner
                  ? Image(image: FirebaseImage(group.bannerRefUrl))
                  : Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.image_outlined,
                        size: 52.0,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
            ),
          ),
          SliverFillRemaining(
            fillOverscroll: true,
            hasScrollBody: false,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.about),
                    const SizedBox(height: 24.0),
                    UpcommingEventsPanel(group: group),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpcommingEventsPanel extends StatefulWidget {
  final TGroup group;

  const UpcommingEventsPanel({super.key, required this.group});

  @override
  State<UpcommingEventsPanel> createState() => _UpcommingEventsPanelState();
}

class _UpcommingEventsPanelState extends State<UpcommingEventsPanel> {
  var _loading = true;
  (Iterable<TEvent> iterable, int count)? _upcommingEvents;

  @override
  void initState() {
    widget.group.getUpcommingEvents().then((value) {
      setState(() {
        _loading = false;
        _upcommingEvents = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubicEmphasized,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Text('Events', style: Theme.of(context).textTheme.labelLarge),
            ),
            _loading || _upcommingEvents == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(3, (index) {
                      return Card(
                        clipBehavior: Clip.hardEdge,
                        child: Shimmer(
                          colorOpacity: 0.7,
                          child: const SizedBox(height: 80.0),
                        ),
                      );
                    }),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _upcommingEvents!.$1.map((event) {
                      return Card(
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          height: 100.0,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text(event.name, style: Theme.of(context).textTheme.titleMedium),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 20.0),
                                      const SizedBox(width: 6.0),
                                      Text(DateFormat('MMM d, h:mm').format(event.date)),
                                    ],
                                  ),
                                  if (event.location != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 20.0),
                                        const SizedBox(width: 6.0),
                                        Text('${event.location!.latitude}, ${event.location!.longitude}'),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
