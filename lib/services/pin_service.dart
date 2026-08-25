/// Barrel file — re-exports PinRepository from the authentication feature,
/// plus a legacy [PinService] wrapper for backward compatibility.
library;

import 'package:local_debt_management/features/authentication/data/repositories/pin_repository_impl.dart';

export 'package:local_debt_management/features/authentication/data/repositories/pin_repository_impl.dart';

typedef PinService = PinRepositoryImpl;
