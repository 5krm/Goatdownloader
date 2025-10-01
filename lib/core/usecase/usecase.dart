import 'package:equatable/equatable.dart';

/// Abstract base class for all use cases in the application
/// 
/// This follows the Clean Architecture pattern where each use case
/// represents a single business operation that can be executed
/// with specific parameters and returns a result.
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters
  Future<Type> call(Params params);
}

/// Special parameter class for use cases that don't require any parameters
/// 
/// This is used when a use case doesn't need any input parameters,
/// providing a consistent interface across all use cases.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}