import 'package:flutter/material.dart';
import '../models/worker.dart';

class AdvanceEditor extends StatefulWidget {
  final Worker worker;
  final DateTime date;
  final bool editable;
  final ValueChanged<double> onAdvanceChanged;

  const AdvanceEditor({
    Key? key,
    required this.worker,
    required this.date,
    required this.editable,
    required this.onAdvanceChanged,
  }) : super(key: key);

  @override
  State<AdvanceEditor> createState() => _AdvanceEditorState();
}

class _AdvanceEditorState extends State<AdvanceEditor> {
  late TextEditingController controller;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    final advanceRecord = widget.worker.advances.firstWhere(
      (a) => a.date.year == widget.date.year && a.date.month == widget.date.month && a.date.day == widget.date.day,
      orElse: () => AdvanceRecord(date: widget.date, amount: 0),
    );
    controller = TextEditingController(
      text: (advanceRecord.amount == 0) ? '' : advanceRecord.amount.toStringAsFixed(2)
    );
    focusNode = FocusNode();
    focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (focusNode.hasFocus) {
      controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.removeListener(_handleFocus);
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AdvanceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.worker != widget.worker || oldWidget.date != widget.date) {
      final advanceRecord = widget.worker.advances.firstWhere(
        (a) => a.date.year == widget.date.year && a.date.month == widget.date.month && a.date.day == widget.date.day,
        orElse: () => AdvanceRecord(date: widget.date, amount: 0),
      );
      controller.text = (advanceRecord.amount == 0) ? '' : advanceRecord.amount.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final advanceRecord = widget.worker.advances.firstWhere(
      (a) => a.date.year == widget.date.year && a.date.month == widget.date.month && a.date.day == widget.date.day,
      orElse: () => AdvanceRecord(date: widget.date, amount: 0),
    );
    if (!widget.editable) {
      return Text('₹${advanceRecord.amount == 0 ? '' : advanceRecord.amount.toStringAsFixed(2)}');
    }
    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: () {
          if (!focusNode.hasFocus) {
            focusNode.requestFocus();
          }
          controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
        },
        child: AbsorbPointer(
          absorbing: false,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(6)),
            onSubmitted: (value) {
              final newAdvance = double.tryParse(value) ?? advanceRecord.amount;
              widget.onAdvanceChanged(newAdvance);
            },
          ),
        ),
      ),
    );
  }
} 