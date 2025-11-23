import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/models/invoice.dart';
import '../localization/app_strings.dart';
import '../theme/app_spacing.dart';
import '../theme/app_icons.dart';
import '../theme/app_colors.dart';
import '../providers/invoice_provider.dart';
import '../constants/app_constants.dart';

class InvoiceCard extends ConsumerStatefulWidget {
  final Invoice invoice;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
    required this.onEdit,
  });

  @override
  ConsumerState<InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends ConsumerState<InvoiceCard> {
  late double _netAmount;
  late int _vatRate;
  late double _grossAmount;
  late String _invoiceNumber;
  late String _contractorName;
  String? _attachmentPath;

  @override
  void initState() {
    super.initState();
    _netAmount = widget.invoice.netAmount;
    _vatRate = widget.invoice.vatRate;
    _grossAmount = widget.invoice.grossAmount;
    _invoiceNumber = widget.invoice.invoiceNumber;
    _contractorName = widget.invoice.contractorName;
    _attachmentPath = widget.invoice.attachmentPath;
  }



  Future<void> _pickNewAttachment(BuildContext context, StateSetter setState) async {
    final messenger = ScaffoldMessenger.of(context);
    
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
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.filePickerError),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (result != null && result.files.single.path != null) {
      final newPath = result.files.single.path;
      setState(() {
        _attachmentPath = newPath;
      });
      if (mounted) {
        this.setState(() {
          _attachmentPath = newPath;
        });
      }
      await _updateInvoice();
    }
  }

  void _viewAttachment(BuildContext context) {
    if (_attachmentPath != null && _attachmentPath!.isNotEmpty) {
      final lowerCasePath = _attachmentPath!.toLowerCase();
      if (lowerCasePath.endsWith('.pdf')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog.fullscreen(
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(AppStrings.pdfPreviewTitle),
                  actions: [
                    IconButton(
                      icon: const Icon(AppIcons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                body: SfPdfViewer.file(
                  File(_attachmentPath!),
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppStrings.pdfLoadError}: ${details.description}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      } else if (lowerCasePath.endsWith('.jpg') || 
                 lowerCasePath.endsWith('.jpeg') || 
                 lowerCasePath.endsWith('.png')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog.fullscreen(
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(AppStrings.imagePreviewTitle),
                  actions: [
                    IconButton(
                      icon: const Icon(AppIcons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                body: Center(
                  child: Image.file(
                    File(_attachmentPath!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppStrings.documentPreviewTitle),
              content: Text(AppStrings.documentPreviewContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppStrings.closeButtonText),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Widget _buildThumbnail(BuildContext context) {
    if (_attachmentPath != null && _attachmentPath!.isNotEmpty) {
      final lowerCasePath = _attachmentPath!.toLowerCase();
      
      if (lowerCasePath.endsWith('.pdf') || lowerCasePath.contains('.pdf')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              children: [
                SfPdfViewer.file(
                  File(_attachmentPath!),
                  pageLayoutMode: PdfPageLayoutMode.single,
                  enableDoubleTapZooming: false,
                  interactionMode: PdfInteractionMode.pan,
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {},
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.overlayLight,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            File(_attachmentPath!),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.greyBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.image,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              );
            },
          ),
        );
      }
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.greyBackground,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.attach_file,
          color: AppColors.textSecondary,
          size: 24,
        ),
      );
    }
  }

  Future<void> _updateInvoice() async {
    final updatedInvoice = Invoice(
      id: widget.invoice.id,
      invoiceNumber: _invoiceNumber,
      contractorName: _contractorName,
      netAmount: _netAmount,
      vatRate: _vatRate,
      grossAmount: _grossAmount,
      attachmentPath: _attachmentPath,
    );
    
    final updateUseCase = ref.read(updateInvoiceUseCaseProvider);
    try {
      await updateUseCase(updatedInvoice);
      if (mounted) {
        ref.read(invoicesProvider.notifier).loadInvoices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.invoiceUpdateError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showInvoiceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.borderGrey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.invoiceDetailsTitle,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _updateInvoice();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(AppIcons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),
                      
                      if (_attachmentPath != null && _attachmentPath!.isNotEmpty) ...[
                        Center(
                          child: GestureDetector(
                            onTap: () => _viewAttachment(context),
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borderGrey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: () {
                                      final lowerCasePath = _attachmentPath!.toLowerCase();
                                      
                                      if (lowerCasePath.endsWith('.pdf') || lowerCasePath.contains('.pdf')) {
                                        try {
                                          return SfPdfViewer.file(
                                            File(_attachmentPath!),
                                            pageLayoutMode: PdfPageLayoutMode.single,
                                            enableDoubleTapZooming: false,
                                            interactionMode: PdfInteractionMode.pan,
                                            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {},
                                          );
                                        } catch (e) {
                                          return Container(
                                            color: AppColors.pdfBackground,
                                            child: const Icon(
                                              Icons.picture_as_pdf,
                                              color: AppColors.pdfIcon,
                                              size: 60,
                                            ),
                                          );
                                        }
                                      } else {
                                        return Image.file(
                                          File(_attachmentPath!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: AppColors.greyBackground,
                                              child: const Icon(
                                                Icons.image,
                                                color: AppColors.textSecondary,
                                                size: 60,
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    }(),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.overlayDark,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.zoom_in,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            AppStrings.clickToEnlarge,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        ElevatedButton.icon(
                          onPressed: () => _pickNewAttachment(context, setState),
                          icon: const Icon(AppIcons.attachFile),
                          label: const Text(AppStrings.changeAttachment),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                      ],
                      
                      _buildEditableDetailRow(context, AppStrings.invoiceNumberLabel, _invoiceNumber, setState, (value) {
                        setState(() {
                          _invoiceNumber = value;
                        });
                      }),
                      const SizedBox(height: AppSpacing.s),
                      _buildEditableDetailRow(context, AppStrings.contractorNameLabel, _contractorName, setState, (value) {
                        setState(() {
                          _contractorName = value;
                        });
                      }),
                      const SizedBox(height: AppSpacing.s),
                      _buildEditableDetailRow(context, AppStrings.netAmountLabel, '${_netAmount.toStringAsFixed(2)} zł', setState, (value) {
                        final net = double.tryParse(value) ?? 0.0;
                        final gross = net + (net * _vatRate / 100);
                        setState(() {
                          _netAmount = net;
                          _grossAmount = gross;
                        });
                      }),
                      const SizedBox(height: AppSpacing.s),
                      _buildEditableDetailRow(context, AppStrings.vatRateLabel, '$_vatRate%', setState, (value) {
                        final vat = int.tryParse(value.replaceAll('%', '')) ?? 23;
                        final net = _netAmount;
                        final gross = net + (net * vat / 100);
                        setState(() {
                          _vatRate = vat;
                          _grossAmount = gross;
                        });
                      }),
                      const SizedBox(height: AppSpacing.s),
                      _buildEditableDetailRow(context, AppStrings.grossAmountLabel, '${_grossAmount.toStringAsFixed(2)} zł', setState, null),
                      const SizedBox(height: AppSpacing.m),
                      
                      const SizedBox(height: AppSpacing.m),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
        });
      }
    });
  }

  Widget _buildEditableDetailRow(BuildContext context, String label, String value, StateSetter setState, Function(String)? onChanged) {
    if (label == AppStrings.grossAmountLabel) {
      return _buildReadOnlyDetailRow(context, label, value);
    }
    
    if (label == AppStrings.vatRateLabel) {
      return _buildVatRateDropdown(context, label, value, setState);
    }
    
    if (label == AppStrings.netAmountLabel) {
      return _buildNetAmountField(context, label, value, setState);
    }
    
    if (label == AppStrings.invoiceNumberLabel) {
      return _buildTextField(context, label, value, false, onChanged);
    }
    
    if (label == AppStrings.contractorNameLabel) {
      return _buildTextField(context, label, value, true, onChanged);
    }
    
    return _buildTextField(context, label, value, false, onChanged);
  }
  
  Widget _buildReadOnlyDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextField(BuildContext context, String label, String value, bool lettersOnly, Function(String)? onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            initialValue: value,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            inputFormatters: lettersOnly
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    FilteringTextInputFormatter.singleLineFormatter,
                  ]
                : [
                    FilteringTextInputFormatter.singleLineFormatter,
                  ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
  
  Widget _buildNetAmountField(BuildContext context, String label, String value, StateSetter setState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextFormField(
                initialValue: value.replaceAll(' zł', ''),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                onChanged: (value) {
                  final net = double.tryParse(value) ?? 0.0;
                  final gross = net + (net * _vatRate / 100);
                  setState(() {
                    _netAmount = net;
                    _grossAmount = gross;
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Text(
                  'zł',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildVatRateDropdown(BuildContext context, String label, String value, StateSetter setState) {
    final vatRates = [0, 7, 23];
    int selectedValue = 23;
    
    final vatString = value.replaceAll('%', '');
    if (vatString.isNotEmpty) {
      selectedValue = int.tryParse(vatString) ?? 23;
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedValue,
                isDense: true,
                isExpanded: true,
                items: vatRates.map<DropdownMenuItem<int>>((int rate) {
                  return DropdownMenuItem<int>(
                    value: rate,
                    child: Text('$rate%'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    final net = _netAmount;
                    final gross = net + (net * newValue / 100);
                    setState(() {
                      _vatRate = newValue;
                      _grossAmount = gross;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showInvoiceDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Row(
            children: [
              _buildThumbnail(context),
              const SizedBox(width: AppSpacing.s),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Nr: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _invoiceNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          'Kontrahent: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _contractorName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Netto: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${_netAmount.toStringAsFixed(2)} zł',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Brutto: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${_grossAmount.toStringAsFixed(2)} zł',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


enum PickSource { files, gallery, downloads }
