sealed class AsyncValue<T> {
  factory AsyncValue.loading() => AsyncLoading<T>();

  factory AsyncValue.data(T value) => AsyncData<T>(value);

  factory AsyncValue.error(Object error) => AsyncError<T>(error);
}

class AsyncLoading<T> implements AsyncValue<T> {}

class AsyncData<T> implements AsyncValue<T> {
  AsyncData(this.value);

  final T value;
}

class AsyncError<T> implements AsyncValue<T> {
  AsyncError(this.error);

  final Object error;
}
