import 'package:cork/core/data/option.dart';
import 'package:meta/meta.dart';

abstract class Eval<A> {
  A get value;

  Eval._();

  Eval<A> memoize() => this;

  Eval<B> map<B>(B f(A)) => flatMap((a) => Eval.now(f(a)));

  Eval<B> flatMap<B>(Eval<B> f(A)) => Defer<B>(() => f(value));

  factory Eval.just(A a) => Eval.now(a);

  factory Eval.now(A a) => Now<A>(a);

  factory Eval.later(A f()) => Later(f);

  factory Eval.always(A f()) => Always(f);

  factory Eval.defer(Eval<A> f()) => Defer(f);

  factory Eval.raise(exception) => Eval.defer(() => throw exception);

  static Eval<bool> True = Eval.now(true);

  static Eval<bool> False = Eval.now(false);

  static Eval<num> Zero = Eval.now(0);

  static Eval<num> One = Eval.now(1);

  static Eval<A> _collapse<A>(Eval<A> fa) =>
      fa is Defer<A> ? _collapse<A>(fa._thunk()) : fa;
}

@immutable
class Now<A> extends Eval<A> {
  @override
  final A value;

  Now(this.value) : super._();

  @override
  bool operator ==(o) => o is Now && o.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Later<A> extends Eval<A> {
  final A Function() f;
  A _value;

  Later(this.f) : super._();

  @override
  A get value {
    if (_value == null) _value = f();
    return _value;
  }
}

@immutable
class Always<A> extends Eval<A> {
  final A Function() f;

  Always(this.f) : super._();

  @override
  A get value => f();

  @override
  Eval<A> memoize() => Later(f);
}

@immutable
class Defer<A> extends Eval<A> {
  final Eval<A> Function() _thunk;

  Defer(this._thunk) : super._();

  @override
  A get value => Eval._collapse<A>(this).value;

  @override
  Eval<A> memoize() => _Memoize(this);
}

class _Memoize<A> extends Eval<A> {
  final Eval<A> eval;
  Option<A> _result = None();

  _Memoize(this.eval) : super._();

  @override
  A get value => _result.getOrElse(() {
        var evaluation = eval.value;
        _result = Some(evaluation);
        return evaluation;
      });
}
