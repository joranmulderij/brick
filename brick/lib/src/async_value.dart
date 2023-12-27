sealed class AsyncValue<T> {
  factory AsyncValue.loading(Future<T> futureValue) =>
      AsyncLoading<T>(futureValue);
  factory AsyncValue.data(T value, Future<T> futureValue) =>
      AsyncData<T>(value, futureValue);
  factory AsyncValue.error(Object error, Future<T> futureValue) =>
      AsyncError<T>(error, futureValue);

  final T? value = null;
  final Object? error = null;
  final Future<T> futureValue = Future.value();
}

class AsyncLoading<T> implements AsyncValue<T> {
  AsyncLoading(this.futureValue);

  @override
  final T? value = null;
  @override
  final Object? error = null;
  @override
  final Future<T> futureValue;
}

class AsyncData<T> implements AsyncValue<T> {
  AsyncData(this.value, this.futureValue);

  @override
  final T value;
  @override
  final Object? error = null;
  @override
  final Future<T> futureValue;
}

class AsyncError<T> implements AsyncValue<T> {
  AsyncError(this.error, this.futureValue);

  @override
  final Object error;
  @override
  final T? value = null;
  @override
  final Future<T> futureValue;
}
