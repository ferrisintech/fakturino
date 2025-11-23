import '../repositories/invoice_repository.dart';
import '../models/invoice.dart';

class SearchInvoicesUseCase {
  final InvoiceRepository repository;

  SearchInvoicesUseCase(this.repository);

  Future<List<Invoice>> call(String query) async {
    return await repository.searchInvoices(query);
  }
}