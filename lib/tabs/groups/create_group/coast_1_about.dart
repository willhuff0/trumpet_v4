part of 'create_group_page.dart';

class _AboutPage extends StatefulWidget {
  final String? initialAbout;
  final void Function(String? about) onBack;
  final void Function(String? about) onSubmit;

  const _AboutPage({super.key, required this.initialAbout, required this.onBack, required this.onSubmit});

  @override
  State<_AboutPage> createState() => __AboutPageState();
}

class __AboutPageState extends State<_AboutPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  Timer? _onChangedTimer;

  var _valid = false;

  var _backButtonOpacity = 0.0;

  String? _about;

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
      _backButtonOpacity = 0.0;
    });
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid) {
      _formKey.currentState!.save();
      widget.onBack(_about);
    } else {
      widget.onBack(null);
    }
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    _formKey.currentState!.save();
    setState(() => _valid = false);
    widget.onSubmit(_about);
  }

  @override
  void initState() {
    _about = widget.initialAbout;
    _formKey = GlobalKey();
    _controller = TextEditingController(text: _about);
    _focusNode = FocusNode()..requestFocus();
    Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _backButtonOpacity = 1.0);
        _validate();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                AppLocale.createGroup_About_Explanation.getString(context),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18.0),
            TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                labelText: AppLocale.createGroup_About_Label.getString(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
              ),
              minLines: 3,
              maxLines: 6,
              maxLength: 200,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              validator: (value) {
                if (value == null) return null;
                if (value.length > 200) return;
                return null;
              },
              onSaved: (value) => _about = value!,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                _submit();
              },
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _backButtonOpacity,
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
