import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'glass_card.dart';

class AddTransactionSheet extends StatefulWidget {
  final Function(TransactionModel) onAdd;
  final bool isDark;
  final TransactionType initialType;

  const AddTransactionSheet({
    super.key,
    required this.onAdd,
    this.isDark = true,
    this.initialType = TransactionType.expense,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  late TransactionType _selectedType;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String _selectedSource = 'Manual';

  final List<String> _expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Kesehatan',
    'Investasi',
  ];

  final List<String> _incomeCategories = [
    'Gaji',
    'Investasi',
    'Freelance',
    'Bonus',
    'Lainnya',
  ];

  final List<String> _sources = [
    'Manual',
    'BCA',
    'Mandiri',
    'BRI',
    'GoPay',
    'OVO',
    'DANA',
    'ShopeePay',
  ];

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedCategory = _selectedType == TransactionType.income
        ? _incomeCategories.first
        : _expenseCategories.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(rawAmount) ?? 0.0;

    if (amount <= 0) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text("Nominal Tidak Valid"),
          content: const Text("Masukkan nominal transaksi terlebih dahulu."),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? _selectedCategory
        : _titleController.text.trim();

    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      date: DateTime.now(),
      source: _selectedSource,
      note: "Dicatat manual",
    );

    widget.onAdd(newTx);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;

    final sheetBg = widget.isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final secondaryTextColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.55);

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
        top: 12,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // iOS Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Center(
                child: Text(
                  "Catat Transaksi SakuAman",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Segmented Switch
              Container(
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : const Color(0xFFE5E5EA).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.expense;
                            _selectedCategory = _expenseCategories.first;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.expense
                                ? const Color(0xFFFF3B30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedType == TransactionType.expense
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFF3B30)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: const Center(
                            child: Text(
                              "Pengeluaran",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.income;
                            _selectedCategory = _incomeCategories.first;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.income
                                ? const Color(0xFF34C759)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedType == TransactionType.income
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF34C759)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: const Center(
                            child: Text(
                              "Pemasukan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Nominal Input Box
              GlassCard(
                isDark: widget.isDark,
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nominal (Rp)",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Rp ",
                          style: TextStyle(
                            color: _selectedType == TransactionType.expense
                                ? const Color(0xFFFF453A)
                                : const Color(0xFF30D158),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: CupertinoTextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            placeholder: "0",
                            placeholderStyle: TextStyle(
                              color: secondaryTextColor.withValues(alpha: 0.35),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Catatan / Deskripsi
              GlassCard(
                isDark: widget.isDark,
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Keterangan / Merchant",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: "Contoh: Kopi Kenangan, Nasi Padang, Belanja",
                      placeholderStyle: TextStyle(
                        color: secondaryTextColor.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Kategori Chips
              Text(
                "Pilih Kategori",
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF007AFF)
                            : (widget.isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE5E5EA)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF70D6FF)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (widget.isDark ? Colors.white70 : Colors.black87),
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Sumber Dana (Source)
              Text(
                "Sumber Dana / Rekening",
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _sources.map((src) {
                    final isSelected = _selectedSource == src;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSource = src),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (widget.isDark ? Colors.white : Colors.black)
                                : (widget.isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFE5E5EA)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            src,
                            style: TextStyle(
                              color: isSelected
                                  ? (widget.isDark ? Colors.black : Colors.white)
                                  : (widget.isDark
                                      ? Colors.white70
                                      : Colors.black87),
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Simpan Button
              CupertinoButton(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: _submit,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.checkmark_alt, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Simpan Transaksi",
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
