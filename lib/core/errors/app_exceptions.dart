/// App-wide exception and error handling
///
/// Custom exception types for different failure modes:
/// - Network errors (with retry-able indication)
/// - Location errors (permission, GPS off, accuracy)
/// - Validation errors (invalid data)
/// - SOS errors (immediate visibility required)
/// - Auth errors (token expired, unauthorized)

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({required this.message, this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';

  bool get isRetryable => false;
  bool get isUserFacing => true;
}

/// Network-related errors (HTTP, WebSocket, DNS, timeout)
class NetworkException extends AppException {
  final bool networkAvailable;
  final int? statusCode;

  NetworkException({
    required String message,
    this.networkAvailable = false,
    this.statusCode,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  bool get isRetryable =>
      networkAvailable == false ||
      (statusCode != null && (statusCode! >= 500 || statusCode == 429));

  @override
  String toString() =>
      'NetworkException: $message (status: $statusCode, retryable: $isRetryable)';
}

/// HTTP-specific errors (4xx, 5xx, timeouts)
class HttpException extends NetworkException {
  final String endpoint;

  HttpException({
    required String message,
    required this.endpoint,
    required int statusCode,
    String? code,
    dynamic originalError,
  }) : super(
         message: message,
         statusCode: statusCode,
         code: code,
         originalError: originalError,
         networkAvailable: true,
       );

  @override
  String toString() =>
      'HttpException: $endpoint - $message (status: $statusCode)';
}

/// Permission-related errors (location, camera, microphone)
class PermissionException extends AppException {
  final String permissionType; // 'location', 'camera', etc.
  final bool isPermanentlyDenied;

  PermissionException({
    required String message,
    required this.permissionType,
    this.isPermanentlyDenied = false,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  bool get isRetryable => !isPermanentlyDenied;

  @override
  String toString() =>
      'PermissionException: $permissionType - $message (permanent: $isPermanentlyDenied)';
}

/// Location-specific errors (GPS off, low accuracy, no fix)
class LocationException extends AppException {
  final String
  locationType; // 'gps_off', 'low_accuracy', 'no_fix', 'permission'

  LocationException({
    required String message,
    required this.locationType,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  bool get isRetryable => locationType != 'permission';

  @override
  String toString() => 'LocationException: $locationType - $message';
}

/// Validation errors (bad data, out of range, schema mismatch)
class ValidationException extends AppException {
  final String fieldName;
  final dynamic invalidValue;

  ValidationException({
    required String message,
    required this.fieldName,
    this.invalidValue,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  bool get isRetryable => false;

  @override
  String toString() =>
      'ValidationException: $fieldName = $invalidValue - $message';
}

/// Authentication and authorization errors
class AuthException extends AppException {
  final String
  authType; // 'token_expired', 'invalid_token', 'unauthorized', 'forbidden'

  AuthException({
    required String message,
    required this.authType,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  bool get isRetryable => authType == 'token_expired'; // Can retry after refresh

  @override
  String toString() => 'AuthException: $authType - $message';
}

/// SOS/Emergency-specific errors (must be visible and retryable)
class SOSException extends AppException {
  final String sosId;
  final String sosType;

  SOSException({
    required String message,
    required this.sosId,
    required this.sosType,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  bool get isRetryable => true; // Always retryable for SOS

  @override
  bool get isUserFacing => true; // Always show to user

  @override
  String toString() => 'SOSException: SOS $sosId ($sosType) - $message';
}

/// Storage/Database errors (drift, secure storage, file I/O)
class StorageException extends AppException {
  final String operationType; // 'read', 'write', 'delete', 'migrate'

  StorageException({
    required String message,
    required this.operationType,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  bool get isRetryable => operationType != 'read'; // Write/delete might be retryable

  @override
  String toString() => 'StorageException: $operationType - $message';
}

/// General app errors (unknown, uncaught)
class AppError extends AppException {
  AppError({required String message, String? code, dynamic originalError})
    : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'AppError: $message';
}

/// Utility for converting and standardizing exceptions
class ExceptionHandler {
  /// Returns a user-friendly message for any exception
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return _getAppExceptionMessage(error);
    }
    return 'An unexpected error occurred. Please try again.';
  }

  static String _getAppExceptionMessage(AppException error) {
    if (error is LocationException) {
      switch (error.locationType) {
        case 'gps_off':
          return 'GPS is off. Please enable location services in Settings.';
        case 'low_accuracy':
          return 'GPS accuracy is low. Please move to an open area.';
        case 'no_fix':
          return 'Unable to get location. Please ensure GPS is enabled.';
        case 'permission':
          return 'Location permission denied. Enable in Settings to use this app.';
        default:
          return error.message;
      }
    } else if (error is NetworkException) {
      if (error.statusCode == 429) {
        return 'Too many requests. Please wait a moment and try again.';
      } else if (error.statusCode == 401 || error.statusCode == 403) {
        return 'Session expired. Please open the app again.';
      } else if (!error.networkAvailable) {
        return 'No internet connection. The app will sync when you regain connection.';
      }
      return 'Network error. Please check your connection.';
    } else if (error is PermissionException) {
      final perm = error.permissionType == 'location'
          ? 'location'
          : error.permissionType;
      return 'Permission denied for $perm. Enable in Settings.';
    } else if (error is ValidationException) {
      return 'Invalid ${error.fieldName}. Please check and try again.';
    } else if (error is SOSException) {
      return 'Emergency alert pending. ${error.message}';
    } else if (error is AuthException) {
      return 'Authentication failed. Please try joining the event again.';
    }
    return error.message;
  }

  /// Determines if an exception should trigger a retry
  static bool shouldRetry(dynamic error) {
    if (error is AppException) {
      return error.isRetryable;
    }
    return false;
  }

  /// Determines if an error should be shown to the user
  static bool shouldShow(dynamic error) {
    if (error is AppException) {
      return error.isUserFacing;
    }
    return false;
  }
}
