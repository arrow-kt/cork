import 'package:cork/core/data/either.dart';
import 'package:cork/core/data/eval.dart';
import 'package:meta/meta.dart';

abstract class Option<A> {
  Option._();

  factory Option.just(value) => Some(value);

  factory Option.empty() => None();

  factory Option.fromNullable(value) => value == null ? None() : Some(value);

  B fold<B>(B ifEmpty(), B ifSome(A)) =>
      this is Some ? ifSome((this as Some).value) : ifEmpty();

  B foldLeft<B>(B initial, B operation(B, A)) =>
      fold(() => initial, (a) => operation(initial, a));

  Eval<B> foldRight<B>(Eval<B> initial, Eval<B> op(A, Eval<B> b)) =>
      fold(() => initial, (a) => op(a, initial));

  Option<B> flatMap<B>(Option<B> f(A)) =>
      fold(() => None(), (a) => f(a));

  Option<B> map<B>(B f(A)) => fold(() => None(), (a) => Some(f(a)));

  Option<B> mapFilter<B>(Option<B> f(A)) =>
      flatMap((a) => f(a).fold(() => None(), (a) => Some(a)));

  Option<A> filter(bool isValid(A)) =>
      flatMap((a) => isValid(a) ? this : None());

  Option<A> filterNot(bool isValid(A)) =>
      flatMap((a) => !isValid(a) ? this : None());

  Option<B> ap<B>(Option<B Function(A)> ff) => ff.flatMap((f) => map(f));

  bool exists(bool predicate(A)) => fold(() => false, predicate);

  bool forall(bool predicate(A)) => fold(() => true, predicate);

  A getOrElse(A f()) => fold(f, (a) => a);

  A orNull() => getOrElse(() => null);

  Option<A> or(Option<A> alternative) => fold(() => alternative, (a) => this);

  Option<A> orElse(Option<A> alternative()) => fold(alternative, (a) => this);

  List<A> toList() => fold(() => [], (a) => [a]);

  Either<L, A> toEither<L>(L ifEmpty()) =>
      fold(() => Either.left(ifEmpty()), (a) => Either.right(a));
}

@immutable
class Some<A> extends Option<A> {
  final A value;

  Some(this.value) : super._();

  @override
  bool operator ==(o) => o is Some && o.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => "Some($value)";
}

class None<A> extends Option<A> {
  None() : super._();

  @override
  bool operator ==(o) => o is None<A>;

  @override
  int get hashCode => 0;

  @override
  String toString() => "None()";
}
