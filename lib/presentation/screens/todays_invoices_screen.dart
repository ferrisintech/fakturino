import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/invoice.dart';
import '../providers/invoice_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/app_icons.dart';
import '../localization/app_strings.dart';
import '../widgets/invoice_card.dart';

class TodaysInvoicesScreen extends ConsumerStatefulWidget {
  const TodaysInvoicesScreen({super.key});

  @override
  ConsumerState<TodaysInvoicesScreen> createState() => _TodaysInvoicesScreenState();
}

class _TodaysInvoicesScreenState extends ConsumerState<TodaysInvoicesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(invoicesProvider.notifier).loadInvoices();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _editInvoice(Invoice invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.editNotAvailable),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Invoice> _getTodaysInvoices(List<Invoice> allInvoices) {
    final now = DateTime.now();
    final tenMinutesAgo = now.subtract(const Duration(minutes: 10));
    
    return allInvoices.where((invoice) {
      return invoice.createdDateTime.isAfter(tenMinutesAgo);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allInvoices = ref.watch(invoicesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    final recentInvoices = _getTodaysInvoices(allInvoices);
    
    final filteredInvoices = searchQuery.isEmpty
        ? recentInvoices
        : recentInvoices.where((invoice) {
            final query = searchQuery.toLowerCase();
            return invoice.invoiceNumber.toLowerCase().contains(query) ||
                   invoice.contractorName.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.invoiceListButton,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(AppIcons.arrowBack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  prefixIcon: const Icon(AppIcons.search),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),
            Expanded(
              child: filteredInvoices.isEmpty
                  ? const Center(
                      child: Text(AppStrings.noInvoicesText),
                    )
                  : ListView.builder(
                      itemCount: filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = filteredInvoices[index];
                        return InvoiceCard(
                          invoice: invoice,
                          onTap: () {
                          },
                          onEdit: () => _editInvoice(invoice),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}