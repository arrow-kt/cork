import 'package:cork/core/data/option.dart';
import 'package:cork/core/data/eval.dart';
import 'package:cork/core/data/either.dart';
import 'package:test/test.dart';

void main() {
  group('Option', () {
    Option<String> none = Option.empty();
    Option<String> some = Option.just("value");
    group('creation', () {
      test('none is None', () => expect(none, None()));
      test('some is Some', () => expect(some, Some("value")));
    });

    group('map', () {
      test('None to None', () {
        expect(none.map((a) => ""), None());
      });
      test('Some to Some', () {
        expect(some.map((a) => "$a extra"), Some("value extra"));
      });
    });

    group('flatMap', () {
      test('None to None', () {
        expect(none.flatMap((a) => Some("")), None());
      });
      test('Some to Some', () {
        expect(some.flatMap((a) => Some("$a extra")), Some("value extra"));
      });
      test('Some to None', () {
        expect(some.flatMap((a) => None()), None());
      });
    });

    group('filter', () {
      group('positive predicate', () {
        bool allIn(a) => true;
        test('None to None', () => expect(none.filter(allIn), None()));
        test('Some to Some', () => expect(some.filter(allIn), some));
      });
      group('negative predicate', () {
        bool noneIn(a) => false;
        test('None to None', () => expect(none.filter(noneIn), None()));
        test('Some to None', () => expect(some.filter(noneIn), None()));
      });
    });

    group('filterNot', () {
      group('positive predicate', () {
        bool allIn(a) => true;
        test('None to None', () => expect(none.filterNot(allIn), None()));
        test('Some to Some', () => expect(some.filterNot(allIn), None()));
      });
      group('negative predicate', () {
        bool noneIn(a) => false;
        test('None to None', () => expect(none.filterNot(noneIn), None()));
        test('Some to None', () => expect(some.filterNot(noneIn), some));
      });
    });

    group('mapfilter', () {
      test('None to None', () {
        expect(none.mapFilter((a) => Some("anything")), None());
      });
      test('Some to Some', () {
        expect(some.mapFilter((a) => Some("$a extra")), Some("value extra"));
      });
      test('Some to None', () {
        expect(some.mapFilter((a) => None()), None());
      });
    });

    group('exists', () {
      group('positive predicate', () {
        bool allIn(a) => true;
        test('None is false', () => expect(none.exists(allIn), false));
        test('Some is true', () => expect(some.exists(allIn), true));
      });
      group('negative predicate', () {
        bool noneIn(a) => false;
        test('None to false', () => expect(none.exists(noneIn), false));
        test('Some to false', () => expect(some.exists(noneIn), false));
      });
    });

    group('forall', () {
      group('positive predicate', () {
        bool allIn(a) => true;
        test('None is true', () => expect(none.forall(allIn), true));
        test('Some is true', () => expect(some.forall(allIn), true));
      });
      group('negative predicate', () {
        bool noneIn(a) => false;
        test('None to true', () => expect(none.forall(noneIn), true));
        test('Some to false', () => expect(some.forall(noneIn), false));
      });
    });

    group('getOrElse', () {
      test('Some returns value', () {
        expect(some.getOrElse(() => throw Error()), "value");
      });
      test('None returns alternative value', () {
        expect(none.getOrElse(() => "alternative"), "alternative");
      });
    });

    group('or', () {
      test('none returns alternative optional', () {
        expect(none.or(Some("value")), Some("value"));
      });
      test('some returns itself', () {
        expect(some.or(Some("alternative")), Some("value"));
      });
    });

    group('orElse', () {
      test('none returns alternative optional', () {
        expect(none.orElse(() => Some("value")), Some("value"));
      });
      test('some returns itself', () {
        expect(some.orElse(() => Some("alternative")), Some("value"));
      });
    });

    group('fold', () {
      ifEmpty() => "a";
      ifSome(a) => "b";
      test('None uses ifEmpty', () => expect(none.fold(ifEmpty, ifSome), "a"));
      test('Some uses ifSome', () => expect(some.fold(ifEmpty, ifSome), "b"));
    });

    group('foldLeft', () {
      test('none returns initial', () {
        expect(none.foldLeft("a", (c, b) => "b"), "a");
      });
      test('some returns result from operation', () {
        expect(some.foldLeft("a", (c, b) => "b"), "b");
      });
    });

    group('foldRight', () {
      var initial = Eval.now("a");
      var fromOperation = Eval.now("b");
      test('none returns initial', () {
        expect(none.foldRight(initial, (c, b) => fromOperation), initial);
      });
      test('some returns result from operation', () {
        expect(some.foldRight(initial, (c, b) => fromOperation), fromOperation);
      });
    });

    group('toList', () {
      test('none is empty list', () => expect(none.toList(), []));
      test('some is list with value', () => expect(some.toList(), ["value"]));
    });

    test('toString', () {
      expect(none.toString(), "None()");
      expect(some.toString(), "Some(value)");
    });

    test('set uses value\'s hash code', () {
      var set = Set.of([none, Some("a"), Some("a"), Some("A"), none]);
      expect(set, [none, Some("a"), Some("A")]);
    });

    test('toEither', () {
      expect(none.toEither(() => "l"), Either.left("l"));
      expect(some.toEither(() => "l"), Either.right("value"));
    });

    test('orNull', () {
      expect(none.orNull(), null);
      expect(some.orNull(), "value");
    });

  });
}
