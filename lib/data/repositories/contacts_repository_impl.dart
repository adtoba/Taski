import 'package:dartz/dartz.dart';
import 'package:taski/core/services/firestore_service.dart';
import 'package:taski/domain/models/contact_model.dart';
import 'package:taski/domain/models/failure.dart';
import 'package:taski/domain/repositories/contacts_repository.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  @override
  Future<Either<Failure, void>> createContact({required ContactModel contact}) async {
    try {
      await FirestoreService.contacts().add(contact.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContact({required String contactId}) async {
    try {
      await FirestoreService.contacts().doc(contactId).delete();
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContactModel>>> getContacts() async {
    try {
      final contacts = await FirestoreService.contacts().get();
      return right(contacts.docs.map((doc) => ContactModel.fromJson(doc.data() as Map<dynamic, dynamic>)).toList());
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateContact({required String contactId, required ContactModel contact}) async {
    try {
      await FirestoreService.contacts().doc(contactId).update(contact.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}