import '../repositories/invoice_repository.dart';
import '../models/invoice.dart';

class GetAllInvoicesUseCase {
  final InvoiceRepository repository;

  GetAllInvoicesUseCase(this.repository);

  Future<List<Invoice>> call() async {
    return await repository.getAllInvoices();
  }
}