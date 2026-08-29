import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a v4 UUID string for use as a unified primary key.
String generateId() => _uuid.v4();
