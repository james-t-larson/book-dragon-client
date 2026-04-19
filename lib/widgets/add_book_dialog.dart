import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import 'button.dart';

class AddBookDialog extends StatefulWidget {
  final Color themeColor;

  const AddBookDialog({
    super.key,
    required this.themeColor,
  });

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _currentPageController = TextEditingController();
  final _genreController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Add a Scroll to Begin',
              style: GoogleFonts.medievalSharp(
                color: AppColors.onSurface,
                fontSize: 22,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.muted),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You need a scroll in your library before you can begin a focus session.',
                style: GoogleFonts.rosarivo(
                  fontSize: 13,
                  color: AppColors.muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_titleController, 'Title', Icons.book),
              _buildTextField(_authorController, 'Author', Icons.person),
              _buildTextField(_genreController, 'Genre', Icons.category),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _totalPagesController,
                      'Total Pages',
                      Icons.pages,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _currentPageController,
                      'Current Page',
                      Icons.edit_note,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          onPressed: () {
            if (_titleController.text.isEmpty) return;
            final newBook = Book(
              id: 0,
              title: _titleController.text,
              author: _authorController.text,
              genre: _genreController.text,
              totalPages: int.tryParse(_totalPagesController.text) ?? 0,
              currentPage: int.tryParse(_currentPageController.text) ?? 0,
              reading: true,
            );
            Navigator.pop(context, newBook);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.themeColor,
          ),
          child: Text(
            'Add Scroll',
            style: GoogleFonts.medievalSharp(
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.rosarivo(color: AppColors.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.rosarivo(color: AppColors.muted),
          prefixIcon: Icon(icon, color: AppColors.secondaryLight),
          filled: true,
          fillColor: AppColors.background.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
