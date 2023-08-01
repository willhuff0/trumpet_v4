part of 'create_group_page.dart';

class _DonePage extends StatefulWidget {
  final String? name;
  final String? about;
  final Uint8List? icon;
  final Uint8List? banner;
  final VoidCallback onComplete;

  const _DonePage({super.key, this.name, this.about, this.icon, this.banner, required this.onComplete});

  @override
  State<_DonePage> createState() => _DonePageState();
}

class _DonePageState extends State<_DonePage> {
  var _loading = true;
  var _success = false;

  @override
  void initState() {
    _complete();
    super.initState();
  }

  void _complete() async {
    final group = await TGroup.create(
      name: widget.name!,
      about: widget.about ?? '',
    );
    if (group == null) {
      setState(() {
        _loading = false;
        _success = false;
      });
      return;
    }

    final uploadResults = await Future.wait([
      if (widget.icon != null) group.uploadIcon(widget.icon!),
      if (widget.banner != null) group.uploadBanner(widget.banner!),
    ]);
    if (uploadResults.any((element) => element == false)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocale.createGroup_IconBanner_ErrorLoading.getString(context)),
          ),
        );
      }
    }

    setState(() {
      _loading = false;
      _success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_success ? AppLocale.createGroup_Done_Success.getString(context) : AppLocale.createGroup_Done_Error.getString(context)),
                    const SizedBox(height: 24.0),
                    FilledButton.tonal(
                      onPressed: () {
                        widget.onComplete();
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
