import 'package:flutter/material.dart';

// Pagination widget, handles navigation between movie pages
class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Function(int page)? onPageSelect; // for direct page navigation
  final bool isLoading;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    this.onPageSelect,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        
        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          // Different layouts for mobile vs desktop
          child: isSmallScreen ? _buildMobileLayout(context) : _buildDesktopLayout(),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: isLoading || currentPage <= 1 ? null : onPrevious,
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5C518), // Yellow theme
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey[600],
              disabledForegroundColor: Colors.grey[400],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

          // Center section with page info and numbers
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Page $currentPage of $totalPages',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Show API limitation warning
                  if (totalPages >= 500)
                    Text(
                      'API Limit: Max 500 pages',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (totalPages > 1) _buildPageNumbers(),
                ],
              ),
            ),
          ),

          // Next button
          ElevatedButton.icon(
            onPressed: isLoading || currentPage >= totalPages ? null : onNext,
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5C518),
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey[600],
              disabledForegroundColor: Colors.grey[400],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
      ],
    );
  }

  // Mobile layout, vertical for limited space
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page info at top
        Text(
          'Page $currentPage of $totalPages',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        if (totalPages >= 500)
          Text(
            'API Limit: Max 500 pages',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
        const SizedBox(height: 8),
        
        // Compact navigation row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Compact previous button
            ElevatedButton(
              onPressed: isLoading || currentPage <= 1 ? null : onPrevious,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C518),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[600],
                disabledForegroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 36),
              ),
              child: const Text('Prev', style: TextStyle(fontSize: 12)),
            ),
            
            // Limited page numbers for mobile
            if (totalPages > 1) _buildMobilePageNumbers(),
            
            // Compact next button
            ElevatedButton(
              onPressed: isLoading || currentPage >= totalPages ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C518),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[600],
                disabledForegroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 36),
              ),
              child: const Text('Next', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  // Mobile page numbers - show fewer to save space
  Widget _buildMobilePageNumbers() {
    List<Widget> pageNumbers = [];
    
    int startPage = (currentPage - 1).clamp(1, totalPages);
    int endPage = (currentPage + 1).clamp(1, totalPages);
    
    if (startPage > 1) {
      pageNumbers.add(_buildPageButton(1));
      if (startPage > 2) {
        pageNumbers.add(const Text('...', style: TextStyle(fontSize: 10)));
      }
    }

    // Show pages in range
    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(_buildPageButton(i));
    }

    // Show last page if not in range
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageNumbers.add(const Text('...', style: TextStyle(fontSize: 10)));
      }
      pageNumbers.add(_buildPageButton(totalPages));
    }

    return Wrap(
      spacing: 4,
      children: pageNumbers,
    );
  }

  Widget _buildPageNumbers() {
    List<Widget> pageNumbers = [];
    
    // Calculate which pages to show
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);
    
    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = (startPage + 4).clamp(1, totalPages);
      } else if (endPage == totalPages) {
        startPage = (endPage - 4).clamp(1, totalPages);
      }
    }

    // First page
    if (startPage > 1) {
      pageNumbers.add(_buildPageButton(1));
      if (startPage > 2) {
        pageNumbers.add(const Text('...', style: TextStyle(fontSize: 12)));
      }
    }

    // Page range
    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(_buildPageButton(i));
    }

    // Last page
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageNumbers.add(const Text('...', style: TextStyle(fontSize: 12)));
      }
      pageNumbers.add(_buildPageButton(totalPages));
    }

    return Wrap(
      spacing: 4,
      children: pageNumbers,
    );
  }

  Widget _buildPageButton(int page) {
    final bool isCurrentPage = page == currentPage;
    
    return GestureDetector(
      onTap: isLoading || isCurrentPage ? null : () => onPageSelect?.call(page),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isCurrentPage 
              ? const Color(0xFFF5C518)
              : Colors.transparent,
          border: Border.all(
            color: isCurrentPage 
                ? const Color(0xFFF5C518)
                : Colors.grey[400]!,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            page.toString(),
            style: TextStyle(
              color: isCurrentPage ? Colors.black : Colors.white,
              fontSize: 12,
              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
} 