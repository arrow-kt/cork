import 'package:cork/core/data/eval.dart';
import 'package:test/test.dart';

void main() {
  group('Eval', () {

    group('has constant', () {
      test('for true', () => expect(Eval.True, Now(true)));
      test('for false', () => expect(Eval.False, Now(false)));
      test('for zero', () => expect(Eval.Zero, Now(0)));
      test('for one', () => expect(Eval.One, Now(1)));
    });

    group('with an inmediate value', () {
      Eval<String> eval = Eval.now("Some value");
      baseTests(eval);
    });

    group('with a value evaluated when needed', () {
      Eval<String> eval = Eval.later(() => "Some value");
      baseTests(eval);
    });

    group('with a new evaluation every time', () {
      Eval<String> eval = Eval.always(() => "Some value");
      baseTests(eval);
      test('generates new content each time', () {
        var counter = 0;
        Eval<String> eval = Eval.always(() {
          counter++;
          return "Value: $counter";
        });
        expect(eval.value, "Value: 1");
        expect(eval.value, "Value: 2");
      });
    });

    group('with defered evaluation', () {
      Eval<String> eval = Eval.defer(() => Eval.now("Some value"));
      baseTests(eval);
    });

    group('with raised exception', () {
      var exception = Exception();
      Eval<String> eval = Eval.raise(exception);
      test('throws an exception', () {
        expect(() => eval.value, throwsA(exception));
      });
    });

  });
}

void baseTests(Eval<String> eval) {
  test('has correct value', () => expect(eval.value, "Some value"));
  test('can map value', () {
    Eval<String> newEval = eval.map((a) => a + " extra");
    expect(newEval.value, "Some value extra");
  });
  test('can flatMap value', () {
    Eval<String> newEval = eval.flatMap((a) => Eval.now(a + " extra"));
    expect(newEval.value, "Some value extra");
  });
}
