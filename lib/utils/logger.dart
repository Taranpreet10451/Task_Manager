import 'package:logger/logger.dart';

final logger = Logger();

void main() {
  logger.d('Debug message');
  logger.i('Info message');
  logger.w('Warning message');
  logger.e('Error message');
}