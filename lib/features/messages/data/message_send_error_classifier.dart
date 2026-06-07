import 'package:dio/dio.dart';

enum SendFailureAction {
  retryLater,
  markFailed,
}

SendFailureAction classifySendFailure(Object error) {
  if (error is! DioException) {
    return SendFailureAction.markFailed;
  }

  final statusCode = error.response?.statusCode;

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.unknown) {
    return SendFailureAction.retryLater;
  }

  if (statusCode == null) {
    return SendFailureAction.retryLater;
  }

  if (statusCode >= 500) {
    return SendFailureAction.retryLater;
  }

  if (statusCode == 400 ||
      statusCode == 401 ||
      statusCode == 403 ||
      statusCode == 404 ||
      statusCode == 422) {
    return SendFailureAction.markFailed;
  }

  return SendFailureAction.markFailed;
}

String sendFailureMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return 'Message saved locally. It will be retried when connection returns.';
    }

    final statusCode = error.response?.statusCode;

    if (statusCode != null && statusCode >= 500) {
      return 'Server unavailable. Message will be retried later.';
    }
  }

  return 'Could not send message.';
}