import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/budget.dart';
import '../models/transaction.dart';

class BudgetScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  final List<Budget> budgets;
  final ValueChanged<List<Budget>> onChanged;
  final bool isDark;

  const BudgetScreen({
    super.key,
    required this.transactions,
    required this.budgets,
    required this.onChanged,
    required this.isDark,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late List<Budget> _budgets;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _budgets = widget.budgets.map((b) => b.copyWith()).toList();
    for (final cat in kExpenseCategories) {
      final budget = _budgets.firstWhere(
        (b) => b.category == cat,
        orElse: () => Budget(category: cat, limit: 0),
      );
      _controllers[cat] = TextEditingController(
        text: budget.limit > 0 ? budget.limit.toStringAsFixed(0) : '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final newBudgets = <Budget>[];
    for (final cat in kExpenseCategories) {
      final controller = _controllers[cat];
      final text = controller?.text.trim() ?? '';
      if (text.isEmpty) {
        newBudgets.add(Budget(category: cat, limit: 0));
      } else {
        final amount = double.tryParse(text);
        if (amount != null) {
          newBudgets.add(Budget(category: cat, limit: amount));
        } else {
          newBudgets.add(Budget(category: cat, limit: 0));
        }
      }
    }
    widget.onChanged(newBudgets);
    Navigator.pop(context);
  }

  double _getSpent(String category) {
    final now = DateTime.now();
    return widget.transactions
        .where((tx) => tx.type == TransactionType.expense &&
            tx.category == category &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Color _getProgressColor(double spent, double limit) {
    if (limit <= 0) return Colors.grey;
    final ratio = spent / limit;
    if (ratio < 0.8) return const Color(0xFF34C759);
    if (ratio <= 1.0) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final sheetBg = widget.isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "Anggaran Bulanan",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...kExpenseCategories.map((cat) {
                final controller = _controllers[cat];
                final budget = _budgets.firstWhere(
                  (b) => b.category == cat,
                  orElse: () => Budget(category: cat, limit: 0),
                );
                final spent = _getSpent(cat);
                final remaining = budget.limit - spent;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (budget.limit > 0)
                            Text(
                              _formatCurrency(remaining),
                              style: TextStyle(
                                color: _getProgressColor(spent, budget.limit),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _getProgressColor(spent, budget.limit)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: CupertinoTextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                maxLength: 12,
                                placeholder: budget.limit > 0
                                    ? budget.limit.toStringAsFixed(0)
                                    : "0",
                                placeholderStyle: TextStyle(
                                  color: secondaryTextColor.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              budget.limit > 0
                                  ? "${_formatCurrency(spent)} dari ${_formatCurrency(budget.limit)}"
                                  : "Tanpa batas",
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (budget.limit > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: widget.isDark
                                ? Colors.grey[700]
                                : Colors.grey[200],
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: (spent / budget.limit) * 100,
                                decoration: BoxDecoration(
                                  color: _getProgressColor(spent, budget.limit),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              CupertinoButton(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(18),
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: _save,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.checkmark_alt, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Simpan",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
