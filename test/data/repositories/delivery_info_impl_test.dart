import 'package:eshop/core/error/failures.dart';
import 'package:eshop/core/network/network_info.dart';
import 'package:eshop/data/data_sources/local/delivery_info_local_data_source.dart';
import 'package:eshop/data/data_sources/local/user_local_data_source.dart';
import 'package:eshop/data/data_sources/remote/delivery_info_remote_data_source.dart';
import 'package:eshop/data/repositories/delivery_info_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/constant_objects.dart';

class MockRemoteDataSource extends Mock
    implements DeliveryInfoRemoteDataSource {}

class MockLocalDataSource extends Mock implements DeliveryInfoLocalDataSource {}

class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late DeliveryInfoRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockUserLocalDataSource mockUserLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockUserLocalDataSource = MockUserLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = DeliveryInfoRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
      userLocalDataSource: mockUserLocalDataSource,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreted', () {
    test(
      'should check if the device is online',
      () async {
        /// Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockUserLocalDataSource.isTokenAvailable())
            .thenAnswer((invocation) => Future.value(true));
        when(() => mockUserLocalDataSource.getToken())
            .thenAnswer((invocation) => Future.value('token'));
        when(() => mockRemoteDataSource.getDeliveryInfo('token'))
            .thenAnswer((_) async => [tDeliveryInfoModel]);
        when(() => mockLocalDataSource.saveDeliveryInfo([tDeliveryInfoModel]))
            .thenAnswer((invocation) => Future<void>.value());

        /// Act
        repository.getRemoteDeliveryInfo();

        /// Assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          /// Arrange
          when(() => mockUserLocalDataSource.isTokenAvailable())
              .thenAnswer((invocation) => Future.value(true));
          when(() => mockUserLocalDataSource.getToken())
              .thenAnswer((invocation) => Future.value('token'));
          when(() => mockRemoteDataSource.getDeliveryInfo('token'))
              .thenAnswer((_) async => [tDeliveryInfoModel]);
          when(() => mockLocalDataSource.saveDeliveryInfo([tDeliveryInfoModel]))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          final actualResult = await repository.getRemoteDeliveryInfo();

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) {
              verify(() =>
                  mockLocalDataSource.saveDeliveryInfo([tDeliveryInfoModel]));
              expect(right, [tDeliveryInfoModel]);
            },
          );
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          /// Arrange
          when(() => mockUserLocalDataSource.isTokenAvailable())
              .thenAnswer((invocation) => Future.value(true));
          when(() => mockUserLocalDataSource.getToken())
              .thenAnswer((invocation) => Future.value('token'));
          when(() => mockRemoteDataSource.getDeliveryInfo('token'))
              .thenThrow(ServerFailure());

          /// Act
          final result = await repository.getRemoteDeliveryInfo();

          /// Assert
          result.fold(
            (left) => expect(left, ServerFailure()),
            (right) => fail('test failed'),
          );
        },
      );

      test(
        'should return local cached data when the call to local data source is successful',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getDeliveryInfo())
              .thenAnswer((_) async => [tDeliveryInfoModel]);

          /// Act
          final actualResult = await repository.getCachedDeliveryInfo();

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) => expect(right, [tDeliveryInfoModel]),
          );
        },
      );

      test(
        'should return [CachedFailure] when the call to local data source is fail',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getDeliveryInfo())
              .thenThrow(CacheFailure());

          /// Act
          final actualResult = await repository.getCachedDeliveryInfo();

          /// Assert
          actualResult.fold(
            (left) => expect(left, CacheFailure()),
            (right) => fail('test failed'),
          );
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          /// Arrange
          when(() => mockRemoteDataSource.getDeliveryInfo('token'))
              .thenAnswer((_) async => [tDeliveryInfoModel]);
          when(() => mockLocalDataSource.getDeliveryInfo())
              .thenAnswer((_) async => [tDeliveryInfoModel]);

          /// Act
          final result = await repository.getCachedDeliveryInfo();

          /// Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getDeliveryInfo());
          result.fold(
            (left) => fail('test failed'),
            (right) => expect(right, [tDeliveryInfoModel]),
          );
        },
      );

      test(
        'should return local cached data when the call to local data source is successful',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getDeliveryInfo())
              .thenAnswer((_) async => [tDeliveryInfoModel]);

          /// Act
          final actualResult = await repository.getCachedDeliveryInfo();

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) => expect(right, [tDeliveryInfoModel]),
          );
        },
      );

      test(
        'should return [CachedFailure] when the call to local data source is fail',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getDeliveryInfo())
              .thenThrow(CacheFailure());

          /// Act
          final actualResult = await repository.getCachedDeliveryInfo();

          /// Assert
          actualResult.fold(
            (left) => expect(left, CacheFailure()),
            (right) => fail('test failed'),
          );
        },
      );
    });
  });
}
