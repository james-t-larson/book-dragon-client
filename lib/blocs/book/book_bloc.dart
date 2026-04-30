import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/book.dart';
import '../../repositories/book_repository.dart';
import 'book_event.dart';
import 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository _repository;

  BookBloc({
    required BookRepository repository,
    required List<Book> initialBooks,
  })  : _repository = repository,
        super(BookLoaded(initialBooks.where((b) => b.reading).toList())) {
    on<FetchActiveBooks>(_onFetchActiveBooks);
    on<AddBook>(_onAddBook);
  }

  Future<void> _onFetchActiveBooks(
    FetchActiveBooks event,
    Emitter<BookState> emit,
  ) async {
    // We optionally don't emit loading if we already have data
    // to avoid flickering the UI, but if you want a loading spinner:
    // if (state is! BookLoaded) emit(BookLoading());
    try {
      final books = await _repository.fetchActiveBooks(event.token);
      emit(BookLoaded(books));
    } catch (e) {
      emit(BookError('Failed to fetch active scrolls'));
    }
  }

  Future<void> _onAddBook(
    AddBook event,
    Emitter<BookState> emit,
  ) async {
    try {
      final newBook = await _repository.addBook(event.token, event.book);
      emit(BookAddedSuccess(newBook));
      
      // Automatically refresh the active books list after adding
      add(FetchActiveBooks(event.token));
    } catch (e) {
      emit(BookError('Failed to add scroll. Please try again.'));
      // In case of error, we can revert to the previous loaded state if we stored it,
      // but for now we just emit error, and UI handles it.
    }
  }
}
