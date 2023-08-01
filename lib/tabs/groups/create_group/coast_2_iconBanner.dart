part of 'create_group_page.dart';

class _IconBannerPage extends StatefulWidget {
  final String? name;
  final Uint8List? initalIcon;
  final Uint8List? initalBanner;
  final void Function(Uint8List? icon, Uint8List? banner) onBack;
  final void Function(Uint8List? icon, Uint8List? banner) onSubmit;

  const _IconBannerPage({super.key, required this.name, required this.initalIcon, required this.initalBanner, required this.onBack, required this.onSubmit});

  @override
  State<_IconBannerPage> createState() => __IconBannerPageState();
}

class __IconBannerPageState extends State<_IconBannerPage> {
  late final GlobalKey<FormState> _formKey;
  late final FocusNode _focusNode;

  Timer? _onChangedTimer;

  var _valid = false;

  Uint8List? _icon;
  Uint8List? _banner;

  void _onChangedHandler() {
    _onChangedTimer?.cancel();
    _onChangedTimer = Timer(const Duration(milliseconds: 700), () => _validate());
  }

  void _validate() {
    if (_formKey.currentState != null) {
      setState(() {
        _valid = _formKey.currentState!.validate();
      });
    }
  }

  void _back() {
    setState(() {
      _valid = false;
    });
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid) {
      _formKey.currentState!.save();
      widget.onBack(_icon, _banner);
    } else {
      widget.onBack(null, null);
    }
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    _formKey.currentState!.save();
    widget.onSubmit(_icon, _banner);
    setState(() => _valid = false);
  }

  @override
  void initState() {
    _formKey = GlobalKey();
    _focusNode = FocusNode()..requestFocus();
    Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _validate();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _onChangedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: _onChangedHandler,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                AppLocale.createGroup_IconBanner_Explanation.getString(context),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18.0),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: FormField<Uint8List>(
                  builder: (state) {
                    return GestureDetector(
                      onTap: () async {
                        final result = await ImagePicker().pickImage(source: ImageSource.gallery, requestFullMetadata: false);
                        final bytes = await result?.readAsBytes();

                        void fail() {
                          state.didChange(null);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocale.createGroup_IconBanner_ErrorLoading.getString(context)),
                              ),
                            );
                          }
                        }

                        if (bytes != null) {
                          try {
                            final codec = await instantiateImageCodec(bytes);
                            final frameInfo = await codec.getNextFrame();
                            if (frameInfo.image.width > 0) {
                              state.didChange(bytes);
                            } else {
                              fail();
                            }
                          } catch (e) {
                            fail();
                          }
                        }
                      },
                      child: CircleAvatar(
                        radius: 36.0,
                        backgroundImage: state.value == null ? null : MemoryImage(state.value!),
                        child: state.value == null && widget.name != null
                            ? Text(
                                _getInitials(widget.name!),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 22.0,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                  onSaved: (value) {
                    _icon = value;
                  },
                ),
              ),
            ),
            const SizedBox(height: 18.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: FormField<Uint8List>(
                builder: (state) {
                  return GestureDetector(
                    onTap: () async {
                      final result = await ImagePicker().pickImage(source: ImageSource.gallery, requestFullMetadata: false);
                      final bytes = await result?.readAsBytes();

                      void fail() {
                        state.didChange(null);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocale.createGroup_IconBanner_ErrorLoading.getString(context)),
                            ),
                          );
                        }
                      }

                      if (bytes != null) {
                        try {
                          final codec = await instantiateImageCodec(bytes);
                          final frameInfo = await codec.getNextFrame();
                          if (frameInfo.image.width > 0) {
                            state.didChange(bytes);
                          } else {
                            fail();
                          }
                        } catch (e) {
                          fail();
                        }
                      }
                    },
                    child: Card(
                      shadowColor: Colors.transparent,
                      child: AspectRatio(
                        aspectRatio: 2.0,
                        child: state.value == null
                            ? const Center(
                                child: Icon(Icons.image_outlined),
                              )
                            : Image.memory(state.value!),
                      ),
                    ),
                  );
                },
                onSaved: (value) {
                  _banner = value;
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Crab(
                tag: 'back-button',
                child: FilledButton.tonal(
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    minimumSize: const MaterialStatePropertyAll(Size(40.0, 40.0)),
                    maximumSize: const MaterialStatePropertyAll(Size(40.0, 40.0)),
                    padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                    elevation: MaterialStateProperty.resolveWith(
                      (states) => states.contains(MaterialState.disabled) ? 0.0 : 4.0,
                    ),
                  ),
                  onPressed: () {
                    _back();
                  },
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Crab(
                tag: 'next-button',
                child: FilledButton.tonal(
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    minimumSize: const MaterialStatePropertyAll(Size(56.0, 56.0)),
                    maximumSize: const MaterialStatePropertyAll(Size(56.0, 56.0)),
                    padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                    elevation: MaterialStateProperty.resolveWith(
                      (states) => states.contains(MaterialState.disabled) ? 0.0 : 4.0,
                    ),
                  ),
                  onPressed: _valid
                      ? () {
                          _submit();
                        }
                      : null,
                  child: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getInitials(String name) => name.split(' ').take(2).map((e) => e.characters.first.toUpperCase()).join();
