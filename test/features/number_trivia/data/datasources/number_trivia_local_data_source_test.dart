import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_app/core/error/exceptions.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockShearedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockShearedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockShearedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));
    test('should return NumberTrivia from SharedPreferences when there is one in the cahce', () async {
      // assert
      when(() => mockSharedPreferences.getString(any())).thenReturn(fixture('trivia_cached.json'));
      // act
      final result = await dataSource.getLastNumberTrivia();
      // assert
      verify(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, tNumberTriviaModel);
    });

    test('should throw a CachedExeption when there is not a cahced value', () async {
      // assert
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);
      // act
      final call = dataSource.getLastNumberTrivia;
      // assert
      expect(call, throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: 1);
    test('should call SharedPreferences to cache the data', () async {
      // arrange
      when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) => Future.value(true));
      // act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      final expectedJsonString = jsonEncode(tNumberTriviaModel.toJson());
      verify(() => mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}
