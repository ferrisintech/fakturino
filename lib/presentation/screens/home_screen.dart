import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/models/invoice.dart';
import '../providers/invoice_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/app_icons.dart';
import '../constants/app_constants.dart';
import '../localization/app_strings.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/attachment_card.dart';
import '../widgets/vat_rate_dropdown.dart';
import 'todays_invoices_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _contractorNameController = TextEditingController();
  final _netAmountController = TextEditingController();
  String? _attachmentPath;
  String? _attachmentName;
  
  int _selectedVatRate = 23;
  double _grossAmount = 0.0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _netAmountController.addListener(_calculateGrossAmount);
    
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
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _contractorNameController.dispose();
    _netAmountController.dispose();
    _netAmountController.removeListener(_calculateGrossAmount);
    _animationController.dispose();
    super.dispose();
  }

  void _calculateGrossAmount() {
    setState(() {
      final netAmountText = _netAmountController.text;
      if (netAmountText.isNotEmpty) {
        final netAmount = double.tryParse(netAmountText) ?? 0.0;
        _grossAmount = netAmount + (netAmount * _selectedVatRate / 100);
      } else {
        _grossAmount = 0.0;
      }
    });
  }

  void _onVatRateChanged(int? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedVatRate = newValue;
        _calculateGrossAmount();
      });
    }
  }

  Future<void> _pickAttachment() async {
    final source = await showDialog<PickSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.attachmentLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(AppIcons.filePresent),
              title: Text(AppStrings.filesOption),
              onTap: () => Navigator.of(context).pop(PickSource.files),
            ),
            ListTile(
              leading: const Icon(AppIcons.image),
              title: Text(AppStrings.galleryOption),
              onTap: () => Navigator.of(context).pop(PickSource.gallery),
            ),
            ListTile(
              leading: const Icon(AppIcons.download),
              title: Text(AppStrings.downloadsOption),
              onTap: () => Navigator.of(context).pop(PickSource.downloads),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    FilePickerResult? result;

    try {
      switch (source) {
        case PickSource.files:
          result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: AppConstants.allowedFileExtensions,
          );
          break;
        case PickSource.gallery:
          result = await FilePicker.platform.pickFiles(
            type: FileType.image,
          );
          break;
        case PickSource.downloads:
          result = await FilePicker.platform.pickFiles(
            type: FileType.any,
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.filePickerError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (result != null) {
      setState(() {
        _attachmentPath = result!.files.single.path;
        _attachmentName = result.files.single.name;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_attachmentPath == null || _attachmentName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.attachmentRequired),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      final invoice = Invoice(
        invoiceNumber: _invoiceNumberController.text,
        contractorName: _contractorNameController.text,
        netAmount: double.parse(_netAmountController.text),
        vatRate: _selectedVatRate,
        grossAmount: _grossAmount,
        attachmentPath: _attachmentPath,
        createdAtTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      try {
        final addInvoiceUseCase = ref.read(addInvoiceUseCaseProvider);
        await addInvoiceUseCase(invoice);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.invoiceSavedSuccess),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          _resetForm();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.invoiceSaveFailed}: $error'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _invoiceNumberController.clear();
    _contractorNameController.clear();
    _netAmountController.clear();
    setState(() {
      _attachmentPath = null;
      _attachmentName = null;
      _selectedVatRate = 23;
      _grossAmount = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.homeScreenTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.list),
            onPressed: () {
              Navigator.pushNamed(context, '/invoices');
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  labelText: AppStrings.invoiceNumberLabel,
                  controller: _invoiceNumberController,
                  inputFormatters: [
                    FilteringTextInputFormatter.singleLineFormatter,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.invoiceNumberRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.m),
                CustomTextField(
                  labelText: AppStrings.contractorNameLabel,
                  controller: _contractorNameController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    FilteringTextInputFormatter.singleLineFormatter,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.contractorNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.m),
                CustomTextField(
                  labelText: AppStrings.netAmountLabel,
                  controller: _netAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    FilteringTextInputFormatter.singleLineFormatter,
                  ],
                  suffixIcon: Text(AppStrings.netAmountCurrency.replaceAll('{}', '')),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.netAmountRequired;
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount < AppConstants.minAmount) {
                      return AppStrings.netAmountInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.m),
                VatRateDropdown(
                  selectedVatRate: _selectedVatRate,
                  onChanged: _onVatRateChanged,
                ),
                const SizedBox(height: AppSpacing.m),
                CustomTextField(
                  labelText: AppStrings.grossAmountLabel,
                  controller: TextEditingController(text: _grossAmount.toStringAsFixed(2)),
                  readOnly: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (_grossAmount < AppConstants.minAmount) {
                      return AppStrings.grossAmountInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.m),
                AttachmentCard(
                  attachmentName: _attachmentName,
                  attachmentPath: _attachmentPath,
                  onPickAttachment: _pickAttachment,
                ),
                const SizedBox(height: AppSpacing.l),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(AppStrings.saveInvoiceButton),
                ),
                const SizedBox(height: AppSpacing.m),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TodaysInvoicesScreen(),
                      ),
                    );
                  },
                  child: Text(AppStrings.invoiceListButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PickSource { files, gallery, downloads }