import '../models/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getAllInvoices();
  Future<Invoice?> getInvoiceById(int id);
  Future<int> addInvoice(Invoice invoice);
  Future<void> updateInvoice(Invoice invoice);
  Future<void> deleteInvoice(int id);
  Future<List<Invoice>> searchInvoices(String query);
}