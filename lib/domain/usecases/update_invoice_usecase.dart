import '../repositories/invoice_repository.dart';
import '../models/invoice.dart';

class UpdateInvoiceUseCase {
  final InvoiceRepository repository;

  UpdateInvoiceUseCase(this.repository);

  Future<void> call(Invoice invoice) async {
    return await repository.updateInvoice(invoice);
  }
}