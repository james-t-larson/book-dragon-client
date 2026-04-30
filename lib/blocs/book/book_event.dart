import 'package:equatable/equatable.dart';
import '../../models/book.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object> get props => [];
}

class FetchActiveBooks extends BookEvent {
  final String token;

  const FetchActiveBooks(this.token);

  @override
  List<Object> get props => [token];
}

class AddBook extends BookEvent {
  final String token;
  final Book book;

  const AddBook(this.token, this.book);

  @override
  List<Object> get props => [token, book];
}
