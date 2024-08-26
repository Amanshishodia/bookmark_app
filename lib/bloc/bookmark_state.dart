import 'package:equatable/equatable.dart';

class BookmarkState extends Equatable {
  final String? pdfPath;
  final int? lastPageIndex; // Add this line
  final Map<int, Set<int>> pageBookmarks;
  final Map<int, Set<int>> lineBookmarks;

  const BookmarkState({
    this.pdfPath,
    this.lastPageIndex, // Include this in the constructor
    this.pageBookmarks = const {},
    this.lineBookmarks = const {},
  });

  BookmarkState copyWith({
    String? pdfPath,
    int? lastPageIndex, // Include this in copyWith
    Map<int, Set<int>>? pageBookmarks,
    Map<int, Set<int>>? lineBookmarks,
  }) {
    return BookmarkState(
      pdfPath: pdfPath ?? this.pdfPath,
      lastPageIndex: lastPageIndex ?? this.lastPageIndex,
      pageBookmarks: pageBookmarks ?? this.pageBookmarks,
      lineBookmarks: lineBookmarks ?? this.lineBookmarks,
    );
  }

  @override
  List<Object?> get props => [pdfPath, lastPageIndex, pageBookmarks, lineBookmarks];
}
