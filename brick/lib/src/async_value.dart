sealed class AsyncValue<T> {
  factory AsyncValue.loading() => AsyncLoading<T>();
  factory AsyncValue.data(T value) => AsyncData<T>(value);
  factory AsyncValue.error(Object error) => AsyncError<T>(error);

  final T? value = null;
  final Object? error = null;
}

class AsyncLoading<T> implements AsyncValue<T> {
  AsyncLoading();

  @override
  final T? value = null;
  @override
  final Object? error = null;
}

class AsyncData<T> implements AsyncValue<T> {
  AsyncData(this.value);

  @override
  final T value;
  @override
  final Object? error = null;
}

class AsyncError<T> implements AsyncValue<T> {
  AsyncError(this.error);

  @override
  final Object error;

  @override
  final T? value = null;
}
