import '../repositories/invoice_repository.dart';
import '../models/invoice.dart';

class AddInvoiceUseCase {
  final InvoiceRepository repository;

  AddInvoiceUseCase(this.repository);

  Future<int> call(Invoice invoice) async {
    return await repository.addInvoice(invoice);
  }
}