import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/services/payout_accounts_service.dart';

/// تفاصيل سحب الأموال: بطاقات متعددة (بيانات السحب) مع حساب رئيسي.
class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  static const Color _headerDark = Color(0xFF2C2C2E);
  static const Color _contentBg = Color(0xFFF5F0E6);

  List<PayoutAccountItem> _accounts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await PayoutAccountsService.list();
      if (mounted) {
        setState(() {
          _accounts = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _openEditor({PayoutAccountItem? existing}) async {
    final ibanCtrl = TextEditingController(text: existing?.iban ?? '');
    final bankCtrl = TextEditingController(text: existing?.bankName ?? '');
    final holderCtrl = TextEditingController(text: existing?.accountHolder ?? '');
    final nickCtrl = TextEditingController(text: existing?.nickname ?? '');
    var makePrimary = existing?.isPrimary ?? (_accounts.isEmpty);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: AppLocale.textDirection,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: StatefulBuilder(
              builder: (ctx, setModal) {
                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          existing == null
                              ? AppStrings.payoutAddCardTitle
                              : AppStrings.payoutEditCardTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nickCtrl,
                          decoration: InputDecoration(
                            labelText: AppStrings.payoutCardNickname,
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: ibanCtrl,
                          decoration: InputDecoration(
                            labelText: AppStrings.payoutIbanLabel,
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: bankCtrl,
                          decoration: InputDecoration(
                            labelText: AppStrings.payoutBankNameLabel,
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: holderCtrl,
                          decoration: InputDecoration(
                            labelText: AppStrings.payoutAccountHolderLabel,
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                        ),
                        if (_accounts.length > 1 || existing != null) ...[
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            value: makePrimary,
                            onChanged: (v) => setModal(() => makePrimary = v ?? false),
                            title: Text(AppStrings.payoutSetAsPrimary),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(AppStrings.cancel),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () async {
                                  final iban = ibanCtrl.text.trim();
                                  final bank = bankCtrl.text.trim();
                                  final holder = holderCtrl.text.trim();
                                  final nick = nickCtrl.text.trim();
                                  if (iban.isEmpty && bank.isEmpty && holder.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppStrings.payoutNeedOneField)),
                                    );
                                    return;
                                  }
                                  Navigator.of(ctx).pop();
                                  try {
                                    if (existing == null) {
                                      await PayoutAccountsService.create(
                                        iban: iban.isEmpty ? null : iban,
                                        bankName: bank.isEmpty ? null : bank,
                                        accountHolder: holder.isEmpty ? null : holder,
                                        nickname: nick.isEmpty ? null : nick,
                                        isPrimary: makePrimary,
                                      );
                                    } else {
                                      await PayoutAccountsService.update(
                                        existing.id,
                                        iban: iban,
                                        bankName: bank,
                                        accountHolder: holder,
                                        nickname: nick.isEmpty ? null : nick,
                                        isPrimary: makePrimary,
                                      );
                                    }
                                    if (mounted) {
                                      await _load();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppStrings.profileDataSaved)),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('$e')),
                                      );
                                    }
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryYellow,
                                  foregroundColor: Colors.black87,
                                ),
                                child: Text(AppStrings.save),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
    ibanCtrl.dispose();
    bankCtrl.dispose();
    holderCtrl.dispose();
    nickCtrl.dispose();
  }

  Future<void> _confirmDelete(PayoutAccountItem a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.payoutDeleteTitle),
        content: Text(AppStrings.payoutDeleteMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await PayoutAccountsService.delete(a.id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.profileDataSaved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: _contentBg,
        appBar: AppBar(
          backgroundColor: _headerDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppStrings.withdrawalPayoutScreenTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Text(
                        AppStrings.payoutIntroHint,
                        style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.4),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    Expanded(
                      child: _accounts.isEmpty
                          ? Center(
                              child: Text(
                                AppStrings.payoutEmptyState,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: _accounts.length,
                              itemBuilder: (context, i) {
                                final a = _accounts[i];
                                final title = a.nickname?.isNotEmpty == true
                                    ? a.nickname!
                                    : AppStrings.payoutUnnamedCard;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: Icon(Icons.credit_card, color: AppColors.primaryYellow, size: 32),
                                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (a.bankName != null && a.bankName!.isNotEmpty)
                                          Text(a.bankName!, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                        if (a.iban != null && a.iban!.isNotEmpty)
                                          Text(
                                            a.iban!,
                                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                            textDirection: TextDirection.ltr,
                                          ),
                                        if (a.isPrimary)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              AppStrings.payoutPrimaryBadge,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: const Color(0xFFB8860B),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (v) async {
                                        if (v == 'edit') {
                                          await _openEditor(existing: a);
                                        } else if (v == 'delete') {
                                          await _confirmDelete(a);
                                        } else if (v == 'primary' && !a.isPrimary) {
                                          try {
                                            await PayoutAccountsService.setPrimary(a.id);
                                            await _load();
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                                            }
                                          }
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        PopupMenuItem(value: 'edit', child: Text(AppStrings.edit)),
                                        if (!a.isPrimary)
                                          PopupMenuItem(value: 'primary', child: Text(AppStrings.payoutSetAsPrimary)),
                                        PopupMenuItem(value: 'delete', child: Text(AppStrings.delete)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: FilledButton.icon(
                        onPressed: () => _openEditor(),
                        icon: const Icon(Icons.add),
                        label: Text(AppStrings.payoutAddCardTitle),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
