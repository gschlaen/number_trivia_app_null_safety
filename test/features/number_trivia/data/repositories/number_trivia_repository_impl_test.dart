import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_app/core/error/exceptions.dart';
import 'package:number_trivia_app/core/error/failures.dart';
import 'package:number_trivia_app/core/network/network_info.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia_app/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getCocreteNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: tNumber);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the divice is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getConcreteNumberTrivia(any())).thenAnswer((_) async => tNumberTriviaModel);
      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future<void>);
      // act
      repository.getConcreteNumberTrivia(tNumber);
      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestOnline(() {
      test('should return remote data when call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any())).thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future<void>);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, const Right(tNumberTrivia));
      });

      test('should cache the data locally when call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any())).thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future<void>);
        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test('should return server failure when call to remote data source is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any())).thenThrow(ServerException());
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      });
    });

    runTestOffline(() {
      test('should return last locally cached data when the cached data is present', () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, const Right(tNumberTrivia));
      });

      test('should return CachedFailure when there is no cached data present', () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: 123);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the divice is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future<void>);
      // act
      repository.getRandomNumberTrivia();
      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestOnline(() {
      test('should return remote data when call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future<void>);
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, const Right(tNumberTrivia));
      });

      test('should cache the data locally when call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future<void>);
        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test('should return server failure when call to remote data source is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenThrow(ServerException());
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      });
    });

    runTestOffline(() {
      test('should return last locally cached data when the cached data is present', () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, const Right(tNumberTrivia));
      });

      test('should return CachedFailure when there is no cached data present', () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });
}
