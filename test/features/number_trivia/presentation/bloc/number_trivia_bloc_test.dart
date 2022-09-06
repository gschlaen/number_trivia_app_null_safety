import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_app/core/error/failures.dart';
import 'package:number_trivia_app/core/usecases/usecase.dart';
import 'package:number_trivia_app/core/util/input_converter.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initialState should be Empty', () {
    // assert
    expect(bloc.state, Empty());
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInteger(any())).thenReturn(const Right(tNumberParsed));

    void setUpmockGetConcreteNumberTriviaSuccess() => when(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
        .thenAnswer((_) async => const Right(tNumberTrivia));

    test('should call the InputConverter to validate and convert the string to an unsigned integer', () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpmockGetConcreteNumberTriviaSuccess();
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockInputConverter.stringToUnsignedInteger(any()));
      // assert
      verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () async {
      // arrange
      when(() => mockInputConverter.stringToUnsignedInteger(any())).thenReturn(Left(InvalidInputFailure()));
      // assert later
      final expected = [
        const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case', () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpmockGetConcreteNumberTriviaSuccess();
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
      // assert
      verify(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully', () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpmockGetConcreteNumberTriviaSuccess();
      // assert later
      final expected = [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed))).thenAnswer((_) async => Left(ServerFailure()));
      // assert later
      final expected = [
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading, Error] with a proper message for the error when getting data fails', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(const Params(number: tNumberParsed))).thenAnswer((_) async => Left(CacheFailure()));
      // assert later
      final expected = [
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    void setUpmockGetRandomNumberTriviaSuccess() =>
        when(() => mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => const Right(tNumberTrivia));

    test('should get data from the random use case', () async {
      // arrange
      setUpmockGetRandomNumberTriviaSuccess();
      // act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandomNumberTrivia(NoParams()));
      // assert
      verify(() => mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully', () async {
      // arrange
      setUpmockGetRandomNumberTriviaSuccess();
      // assert later
      final expected = [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(ServerFailure()));
      // assert later
      final expected = [
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] with a proper message for the error when getting data fails', () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(CacheFailure()));
      // assert later
      final expected = [
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
