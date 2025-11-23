import 'dart:io';
import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../theme/app_icons.dart';
import '../theme/app_colors.dart';

class AttachmentCard extends StatefulWidget {
  final String? attachmentName;
  final String? attachmentPath;
  final VoidCallback onPickAttachment;

  const AttachmentCard({
    super.key,
    required this.attachmentName,
    required this.attachmentPath,
    required this.onPickAttachment,
  });

  @override
  State<AttachmentCard> createState() => _AttachmentCardState();
}

class _AttachmentCardState extends State<AttachmentCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  Future<Widget> _getPdfThumbnail(String filePath) async {
    return const Icon(
      Icons.picture_as_pdf,
      color: AppColors.pdfIcon,
      size: 40,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPreview() {
    if (widget.attachmentPath != null && widget.attachmentPath!.isNotEmpty) {
      final lowerCasePath = widget.attachmentPath!.toLowerCase();
      
      if (lowerCasePath.endsWith('.pdf') || lowerCasePath.contains('.pdf')) {
        return Container(
          height: 100,
          width: double.infinity,
          color: AppColors.pdfBackground,
          child: FutureBuilder<Widget>(
            future: _getPdfThumbnail(widget.attachmentPath!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return snapshot.data!;
              } else {
                return const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.pdfIcon,
                  size: 40,
                );
              }
            },
          ),
        );
      } else if (lowerCasePath.endsWith('.jpg') || 
                 lowerCasePath.endsWith('.jpeg') || 
                 lowerCasePath.endsWith('.png')) {
        return SizedBox(
          height: 100,
          width: double.infinity,
          child: Image.file(
            File(widget.attachmentPath!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.greyBackground,
                child: const Icon(
                  Icons.image,
                  color: AppColors.textSecondary,
                  size: 40,
                ),
              );
            },
          ),
        );
      } else {
        return Container(
          height: 100,
          width: double.infinity,
          color: AppColors.greyBackground,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_drive_file,
                color: AppColors.textSecondary,
                size: 40,
              ),
              SizedBox(height: 8),
              Text('Document'),
            ],
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(widget.attachmentName ?? AppStrings.noAttachmentText),
              trailing: IconButton(
                icon: const Icon(AppIcons.attachFile),
                onPressed: () {
                  _controller.forward().then((_) {
                    _controller.reverse();
                    widget.onPickAttachment();
                  });
                },
              ),
            ),
            if (widget.attachmentPath != null && widget.attachmentPath!.isNotEmpty) ...[
              _buildPreview(),
              const SizedBox(height: 8),
            ],
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: Text(
                AppStrings.supportedFileFormats,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}