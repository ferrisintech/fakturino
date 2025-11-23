import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/invoice.dart';
import '../../../domain/usecases/get_all_invoices_usecase.dart';
import '../../../domain/usecases/add_invoice_usecase.dart';
import '../../../domain/usecases/update_invoice_usecase.dart';
import '../../../domain/usecases/delete_invoice_usecase.dart';
import '../../../domain/usecases/search_invoices_usecase.dart';
import '../../../data/repositories/invoice_repository_impl.dart';

final invoiceRepositoryProvider = Provider((ref) {
  return InvoiceRepositoryImpl();
});

final getAllInvoicesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return GetAllInvoicesUseCase(repository);
});

final addInvoiceUseCaseProvider = Provider((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return AddInvoiceUseCase(repository);
});

final updateInvoiceUseCaseProvider = Provider((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return UpdateInvoiceUseCase(repository);
});

final deleteInvoiceUseCaseProvider = Provider((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return DeleteInvoiceUseCase(repository);
});

final searchInvoicesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return SearchInvoicesUseCase(repository);
});

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, List<Invoice>>((ref) {
  return InvoicesNotifier(ref);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

class InvoicesNotifier extends StateNotifier<List<Invoice>> {
  final Ref ref;

  InvoicesNotifier(this.ref) : super([]) {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    try {
      final getAllInvoicesUseCase = ref.read(getAllInvoicesUseCaseProvider);
      final invoices = await getAllInvoicesUseCase();
      state = invoices;
    } catch (e) {
      state = [];
    }
  }

  Future<void> searchInvoices(String query) async {
    if (query.isEmpty) {
      loadInvoices();
      return;
    }

    try {
      final searchUseCase = ref.read(searchInvoicesUseCaseProvider);
      final invoices = await searchUseCase(query);
      state = invoices;
    } catch (e) {
      state = [];
    }
  }
}