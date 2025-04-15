import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/transaction.dart';
import 'package:poker_ledger/providers/game_provider.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/custom_text_field.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final int gameId;
  final int userId;
  final String userName;

  const AddTransactionScreen({
    super.key,
    required this.gameId,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.buyIn;
  bool _isLoading = false;
  bool _hasEndAmount = false;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => _checkExistingTransactions());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingTransactions() async {
    // Load transactions for this game
    await ref
        .read(gameTransactionsProvider.notifier)
        .loadTransactions(widget.gameId);

    // Check if this user already has an end amount transaction
    final transactions = ref.read(gameTransactionsProvider).transactions;
    final hasEndAmount = transactions.any(
      (t) =>
          t.gameId == widget.gameId &&
          t.userId == widget.userId &&
          t.type == TransactionType.gameEndAmount,
    );

    if (hasEndAmount) {
      if (mounted) {
        setState(() {
          _hasEndAmount = true;
        });

        // Show a message and close the screen since no more transactions are allowed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'End amount already recorded. No more transactions allowed for this player.',
            ),
            backgroundColor: AppTheme.warningColor,
            duration: Duration(seconds: 3),
          ),
        );

        // Add a small delay before popping to ensure the snackbar is seen
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  Future<void> _addTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      final transaction = Transaction(
        gameId: widget.gameId,
        userId: widget.userId,
        type: _selectedType,
        amount: amount,
      );

      // Wrap the provider modification in a Future.delayed to avoid modifying during build
      await Future.delayed(Duration.zero, () async {
        await ref
            .read(gameTransactionsProvider.notifier)
            .addTransaction(transaction);
      });

      if (mounted) {
        String transactionTypeText = '';
        switch (_selectedType) {
          case TransactionType.buyIn:
            transactionTypeText = 'Buy-in';
            break;
          case TransactionType.addOn:
            transactionTypeText = 'Add-on';
            break;
          case TransactionType.gameEndAmount:
            transactionTypeText = 'End amount';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$transactionTypeText added successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Return success result and close the screen
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding transaction: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If end amount already exists, show loading indicator briefly before popping
    if (_hasEndAmount) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Transaction')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Player',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          Text(widget.userName, style: AppTheme.titleMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text('Transaction Type', style: AppTheme.labelLarge),
              const SizedBox(height: 8),

              // Transaction type selection
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Text(
                        'Transaction Type',
                        style: AppTheme.labelLarge.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    RadioListTile<TransactionType>(
                      title: const Text('Buy-in'),
                      subtitle: const Text('Initial buy-in amount'),
                      value: TransactionType.buyIn,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                      activeColor: AppTheme.secondaryColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    const Divider(height: 1),
                    RadioListTile<TransactionType>(
                      title: const Text('Add-on'),
                      subtitle: const Text('Additional buy-in during the game'),
                      value: TransactionType.addOn,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                          // Clear amount field when switching from end amount to avoid validation issues
                          if (_amountController.text.startsWith('-')) {
                            _amountController.clear();
                          }
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    const Divider(height: 1),
                    RadioListTile<TransactionType>(
                      title: const Text('End Amount'),
                      subtitle: const Text(
                        'Final cash out amount (can be negative)',
                      ),
                      value: TransactionType.gameEndAmount,
                      groupValue: _selectedType,
                      onChanged:
                          _hasEndAmount
                              ? null
                              : (value) {
                                setState(() {
                                  _selectedType = value!;
                                  // Clear amount field when switching to end amount to avoid validation issues
                                  if (value == TransactionType.gameEndAmount) {
                                    _amountController.clear();
                                  }
                                });
                              },
                      activeColor: AppTheme.primaryColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ],
                ),
              ),

              if (_hasEndAmount)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'End amount already recorded for this player',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.warningColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Amount field
              CustomTextField(
                label: 'Amount',
                hint:
                    _selectedType == TransactionType.gameEndAmount
                        ? 'Enter amount (can be negative)'
                        : 'Enter amount',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                prefixIcon: Icons.payments_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }

                  try {
                    final amount = double.parse(value);
                    // Allow negative amounts only for end amount
                    if (_selectedType != TransactionType.gameEndAmount &&
                        amount <= 0) {
                      return 'Amount must be greater than zero';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }

                  return null;
                },
                // Format input to allow numbers, decimal point, and minus sign (for end amount)
                onChanged: (value) {
                  if (value.isEmpty) return;

                  if (_selectedType == TransactionType.gameEndAmount) {
                    // For end amount, allow negative numbers
                    // Remove any non-numeric characters except decimal point and minus sign
                    String newValue = value.replaceAll(RegExp(r'[^\d.\-]'), '');

                    // Ensure minus sign is only at the beginning
                    if (newValue.contains('-')) {
                      if (newValue.indexOf('-') != 0) {
                        newValue = newValue.replaceAll('-', '');
                        if (newValue.isNotEmpty) {
                          newValue = '-' + newValue;
                        }
                      }
                    }

                    // Ensure only one decimal point
                    final parts = newValue.replaceAll('-', '').split('.');
                    if (parts.length > 2) {
                      String formattedValue =
                          '${parts[0]}.${parts.sublist(1).join('')}';
                      if (newValue.startsWith('-')) {
                        formattedValue = '-' + formattedValue;
                      }
                      _amountController.value = TextEditingValue(
                        text: formattedValue,
                        selection: TextSelection.collapsed(
                          offset: formattedValue.length,
                        ),
                      );
                    }
                  } else {
                    // For buy-in and add-on, only allow positive numbers
                    // Remove any non-numeric characters except decimal point
                    final newValue = value.replaceAll(RegExp(r'[^\d.]'), '');

                    // Ensure only one decimal point
                    final parts = newValue.split('.');
                    if (parts.length > 2) {
                      final formattedValue =
                          '${parts[0]}.${parts.sublist(1).join('')}';
                      _amountController.value = TextEditingValue(
                        text: formattedValue,
                        selection: TextSelection.collapsed(
                          offset: formattedValue.length,
                        ),
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'CANCEL',
                      onPressed: () => Navigator.of(context).pop(),
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'ADD TRANSACTION',
                      onPressed: _addTransaction,
                      isLoading: _isLoading,
                      gradient:
                          _selectedType == TransactionType.gameEndAmount
                              ? AppTheme.primaryGradient
                              : AppTheme.secondaryGradient,
                      icon: Icons.add_circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
