import 'package:hive/hive.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/models/invoice.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  Box<Invoice>? _invoiceBox;

  Future<void> _ensureInitialized() async {
    if (_invoiceBox == null || !_invoiceBox!.isOpen) {
      _invoiceBox = await Hive.openBox<Invoice>('invoices');
    }
  }

  @override
  Future<List<Invoice>> getAllInvoices() async {
    await _ensureInitialized();
    return _invoiceBox!.values.toList();
  }

  @override
  Future<Invoice?> getInvoiceById(int id) async {
    await _ensureInitialized();
    return _invoiceBox!.get(id);
  }

  @override
  Future<int> addInvoice(Invoice invoice) async {
    await _ensureInitialized();
    if (invoice.id == -1) {
      invoice.id = _invoiceBox!.isEmpty ? 1 : _invoiceBox!.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;
    }
    await _invoiceBox!.put(invoice.id, invoice);
    return invoice.id;
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    await _ensureInitialized();
    await _invoiceBox!.put(invoice.id, invoice);
  }

  @override
  Future<void> deleteInvoice(int id) async {
    await _ensureInitialized();
    await _invoiceBox!.delete(id);
  }

  @override
  Future<List<Invoice>> searchInvoices(String query) async {
    await _ensureInitialized();
    final allInvoices = _invoiceBox!.values.toList();
    if (query.isEmpty) {
      return allInvoices;
    }
    
    return allInvoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(query.toLowerCase()) ||
          invoice.contractorName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}