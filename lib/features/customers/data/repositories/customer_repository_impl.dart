/// CUSTOMERS FEATURE — DATA LAYER: REPOSITORY IMPLEMENTATION
///
/// Implements the [CustomerRepository] contract from the domain layer.
/// Bridges the pure domain entities with the SQLite datasource via
/// [CustomerModel]: every read converts model → entity, every write
/// converts entity → model.
///
/// The sync helpers (getUnsynced/markSynced/upsertFromCloud) intentionally
/// do NOT appear here — they belong to the datasource, which the cloud
/// sync service talks to directly.
/// ---------------------------------------------------------------------------
library;

import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDatasource _datasource;

  CustomerRepositoryImpl({CustomerLocalDatasource? datasource})
    : _datasource = datasource ?? CustomerLocalDatasource();

  @override
  Future<void> insert(Customer customer) async {
    await _datasource.insert(CustomerModel.fromEntity(customer));
  }

  @override
  Future<void> update(Customer customer) async {
    await _datasource.update(CustomerModel.fromEntity(customer));
  }

  @override
  Future<void> delete(String id) => _datasource.delete(id);

  @override
  Future<List<Customer>> getAll({String? ownerId}) async {
    final models = await _datasource.getAll(ownerId: ownerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Customer?> getById(String id) async {
    final model = await _datasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Customer>> search(String query, {String? ownerId}) async {
    final models = await _datasource.search(query, ownerId: ownerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> getCustomerCount({String? ownerId}) {
    return _datasource.getCustomerCount(ownerId: ownerId);
  }
}