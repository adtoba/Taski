import 'package:dartz/dartz.dart';
import 'package:taski/domain/models/contact_model.dart';
import 'package:taski/domain/models/failure.dart';

abstract class ContactsRepository {
  Future<Either<Failure, void>> createContact({required ContactModel contact});
  Future<Either<Failure, void>> deleteContact({required String contactId});
  Future<Either<Failure, List<ContactModel>>> getContacts();
  Future<Either<Failure, void>> updateContact({required String contactId, required ContactModel contact});
}