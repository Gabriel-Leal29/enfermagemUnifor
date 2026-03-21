import 'package:flutter/material.dart';

import '../theme/theme.dart';

class CampoDropdownWidget<T> extends StatefulWidget {
  const CampoDropdownWidget({
    required this.label,
    required this.items,
    required this.onSelected,
    super.key,
    this.value,
    this.hintText,
    this.getLabel,
    this.obrigatorio = false,
  });

  final String label;
  final List<T> items;
  final T? value;
  final String? hintText;
  final bool obrigatorio;
  final Function(T) onSelected;
  final String Function(T)? getLabel;

  @override
  State<StatefulWidget> createState() => _CampoDropdowmWidgetState<T>();
}

class _CampoDropdowmWidgetState<T> extends State<CampoDropdownWidget<T>> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = _isMenuOpen ? azulUnifor : cinzaFundo;
    final double borderWidth = _isMenuOpen ? 2 : 1.5;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Label
            Row(
              children: [
                Text(widget.label, style: textStyleBlackLabel),
              ],
            ),

            const SizedBox(height: 6),

            /// Dropdown
            Focus(
              focusNode: _focusNode,
              onFocusChange: (hasSubFocus) {
                setState(() {});
              },
              child: GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                },
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: PopupMenuButton<T>(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      maxWidth: constraints.maxWidth,
                    ),

                    onOpened: () => setState(() => _isMenuOpen = true),
                    onCanceled: () => setState(() => _isMenuOpen = false),
                    onSelected: (value) {
                      setState(() => _isMenuOpen = false);
                      widget.onSelected(value);
                    },

                    color: Colors.white,
                    elevation: 2,
                    padding: EdgeInsets.zero,
                    offset: const Offset(0, 52),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: cinzaFundo,
                        width: 1.5,
                      ),
                    ),

                    /// Itens
                    itemBuilder: (context) {
                      return widget.items.map((item) {
                        final isSelected = widget.value == item;

                        return PopupMenuItem<T>(
                          value: item,
                          height: 40,
                          padding: EdgeInsets.zero,
                          child: _DropdownItem<T>(
                            item: item,
                            label: widget.getLabel != null
                                ? widget.getLabel!(item)
                                : item.toString(),
                            isSelected: isSelected,
                          ),
                        );
                      }).toList();
                    },

                    /// Campo visível
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: cinzaFundo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor,
                          width: borderWidth,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.value == null
                                  ? (widget.hintText ?? "Selecione")
                                  : (widget.getLabel != null
                                  ? widget.getLabel!(widget.value as T)
                                  : widget.value.toString()),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
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

class _DropdownItem<T> extends StatefulWidget {
  const _DropdownItem({
    required this.item,
    required this.label,
    required this.isSelected,
  });

  final T item;
  final String label;
  final bool isSelected;

  @override
  State<_DropdownItem<T>> createState() => _DropdownItemState<T>();
}

class _DropdownItemState<T> extends State<_DropdownItem<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        width: double.infinity,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? azulSelecionadoDropDown
              : _hover
              ? azulSelecionadoDropDown.withOpacity(0.6)
              : Colors.transparent,
        ),
        child: Text(widget.label),
      ),
    );
  }
}