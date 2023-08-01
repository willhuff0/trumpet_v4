part of 'create_group_page.dart';

class _NamePage extends StatefulWidget {
  final String? initialName;
  final void Function(String name) onSubmit;

  const _NamePage({super.key, required this.initialName, required this.onSubmit});

  @override
  State<_NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<_NamePage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  Timer? _onChangedTimer;

  var _valid = false;

  String? _name;

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

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    _formKey.currentState!.save();
    setState(() => _valid = false);
    _focusNode.unfocus();
    widget.onSubmit(_name!);
  }

  @override
  void initState() {
    _name = widget.initialName;
    _formKey = GlobalKey();
    _controller = TextEditingController(text: _name);
    _focusNode = FocusNode()..requestFocus();
    if (_name?.isNotEmpty ?? false) {
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          _validate();
        }
      });
    }
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
                AppLocale.createGroup_Name_Explanation.getString(context),
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
                labelText: AppLocale.createGroup_Name_Label.getString(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
              ),
              maxLength: 32,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              validator: (value) {
                if (value == null || value.isEmpty) return AppLocale.createGroup_Name_Error_NoValue.getString(context);
                if (value.trim() != value) return AppLocale.createGroup_Name_Error_TrimInvalid.getString(context);
                if (value.length < 3) return AppLocale.createGroup_Name_Error_TooShort.getString(context);
                if (value.length > 32) return AppLocale.createGroup_Name_Error_TooLong.getString(context);
                return null;
              },
              onSaved: (value) => _name = value,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                _submit();
              },
            ),
          ],
        ),
        floatingActionButton: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Container()),
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
