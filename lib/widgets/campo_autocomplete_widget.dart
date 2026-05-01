import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'campo_texto_widget.dart';

class CampoAutocompleteWidget<T extends Object> extends StatefulWidget {
  const CampoAutocompleteWidget({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
    required this.getLabel,
    this.controller,
    this.hintText,
    this.obrigatorio = false,
    this.valorInicial,
  });

  final String label;
  final List<T> items;
  final Function(T) onSelected;
  final String Function(T) getLabel;
  final String? hintText;
  final bool obrigatorio;
  final TextEditingController? controller;
  final T? valorInicial;

  @override
  State<CampoAutocompleteWidget<T>> createState() =>
      _CampoAutocompleteWidgetState<T>();
}

class _CampoAutocompleteWidgetState<T extends Object>
    extends State<CampoAutocompleteWidget<T>> {

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<T>(
          initialValue: widget.controller != null
              ? TextEditingValue(text: widget.controller!.text)
              : null,

          optionsBuilder: (textValue) {
            if (textValue.text.isEmpty) return const Iterable.empty();

            final filteredItems = widget.items.where((item) =>
                widget.getLabel(item)
                    .toLowerCase()
                    .contains(textValue.text.toLowerCase()))
                .toList();

            filteredItems.sort((a, b) =>
                widget.getLabel(a).toLowerCase().compareTo(widget.getLabel(b).toLowerCase())
            );

            return filteredItems;
          },

          displayStringForOption: widget.getLabel,
          onSelected: (item) {
            widget.onSelected(item);
            FocusScope.of(context).unfocus();
          },

          fieldViewBuilder: (context, ctrl, node, onSubmit) {
            if (widget.valorInicial != null && ctrl.text.isEmpty) {
              ctrl.text = widget.getLabel(widget.valorInicial as T);
            }

            if (widget.controller != null) {
              ctrl.addListener(() {
                if (widget.controller!.text != ctrl.text) {
                  widget.controller!.text = ctrl.text;
                }
              });

              if (ctrl.text != widget.controller!.text) {
                ctrl.text = widget.controller!.text;
              }
            }

            node.addListener(() {
              if (mounted && _isFocused != node.hasFocus) {
                setState(() => _isFocused = node.hasFocus);
              }
            });

            return CampoTextoWidget(
              controller: ctrl,
              focusNode: node,
              label: widget.label,
              hintText: widget.hintText,
              obrigatorio: widget.obrigatorio,
              sufixoIcon: const Icon(Icons.keyboard_arrow_down),
            );
          },

          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: constraints.maxWidth,
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cinzaFundo, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                    ],
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return _AutocompleteItem<T>(
                        label: widget.getLabel(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AutocompleteItem<T> extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _AutocompleteItem({
    required this.label,
    required this.onTap,
  });

  @override
  State<_AutocompleteItem<T>> createState() => _AutocompleteItemState<T>();
}

class _AutocompleteItemState<T> extends State<_AutocompleteItem<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: _hover
                ? azulSelecionadoDropDown.withOpacity(0.6)
                : Colors.transparent,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontWeight: _hover ? FontWeight.bold : FontWeight.normal,

            ),
          ),
        ),
      ),
    );
  }
}
