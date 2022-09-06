import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:number_trivia_app/core/error/exceptions.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  const tNumber = 1;

  void setUpMockHttpClientSuccess200() {
    when(() => mockHttpClient.get(Uri.parse('http://numbersapi.com/$tNumber'), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientSuccess404() {
    when(() => mockHttpClient.get(Uri.parse('http://numbersapi.com/$tNumber'), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  void setUpMockHttpClientRandomSuccess200() {
    when(() => mockHttpClient.get(Uri.parse('http://numbersapi.com/random'), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientRandomSuccess404() {
    when(() => mockHttpClient.get(Uri.parse('http://numbersapi.com/random'), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    // const tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

    test('should perform a GET request on a URL with number being the endpoint and with application/json header', () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      dataSource.getConcreteNumberTrivia(tNumber);
      // assert
      verify(() => mockHttpClient.get(
            Uri.parse('http://numbersapi.com/$tNumber'),
            headers: {
              'Content-Type': 'application/json',
            },
          ));
    });

    test('should return NumberTrivia when the response code us 299 (success', () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      // assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException when the response code is 404 or other', () async {
      // arrange
      setUpMockHttpClientSuccess404();
      // act
      final call = dataSource.getConcreteNumberTrivia;
      // assert
      expect(call(tNumber), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    // const tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

    test('should perform a GET request on a URL with number being the endpoint and with application/json header', () async {
      // arrange
      setUpMockHttpClientRandomSuccess200();
      // act
      dataSource.getRandomNumberTrivia();
      // assert
      verify(() => mockHttpClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: {
              'Content-Type': 'application/json',
            },
          ));
    });

    test('should return NumberTrivia when the response code us 299 (success', () async {
      // arrange
      setUpMockHttpClientRandomSuccess200();
      // act
      final result = await dataSource.getRandomNumberTrivia();
      // assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException when the response code is 404 or other', () async {
      // arrange
      setUpMockHttpClientRandomSuccess404();
      // act
      final call = dataSource.getRandomNumberTrivia;
      // assert
      expect(call(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}
