import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/data/repositories/contacts_repository_impl.dart';
import 'package:taski/domain/models/contact_model.dart';
import 'package:taski/domain/repositories/contacts_repository.dart';
import 'package:taski/main.dart';

class ContactsProvider extends ChangeNotifier {
  final ContactsRepository contactsRepository;
  
  ContactsProvider({required this.contactsRepository});

  List<ContactModel> _contacts = [];
  List<ContactModel> get contacts => _contacts;

  bool _isLoadingContacts = false;
  bool get isLoadingContacts => _isLoadingContacts;

  bool _isCreatingContact = false;
  bool get isCreatingContact => _isCreatingContact;

  bool _isUpdatingContact = false;
  bool get isUpdatingContact => _isUpdatingContact;

  bool _isDeletingContact = false;
  bool get isDeletingContact => _isDeletingContact;
  

  Future<void> createContact(ContactModel contact) async {
    _isCreatingContact = true;
    notifyListeners();

    final result = await contactsRepository.createContact(contact: contact);
    result.fold(
      (failure) {
        _isCreatingContact = false;
        notifyListeners();
        logger.e("Failed to create contact", error: failure.message);
      }, 
      (success) async {
        _isCreatingContact = false;
        notifyListeners();

        await getContacts();
      }
    );
  }

  Future<void> getContacts() async {
    log("Getting contacts");
    _isLoadingContacts = true;
    notifyListeners();

    final result = await contactsRepository.getContacts();
    result.fold((failure) {
      _isLoadingContacts = false;
      notifyListeners();

      logger.e("Failed to get contacts", error: failure.message);
      
    }, (success) {
      _contacts = success;
      logger.d("Contacts fetched successfully");
      _isLoadingContacts = false;
      notifyListeners();
    });
  }

  Future<void> updateContact(String contactId, ContactModel contact) async {
    _isUpdatingContact = true;
    notifyListeners();

    final result = await contactsRepository.updateContact(contactId: contactId, contact: contact);
    result.fold((failure) {
      _isUpdatingContact = false;
      notifyListeners();
      logger.e("Failed to update contact", error: failure.message);
    }, (success) async {
      _isUpdatingContact = false;
      notifyListeners();
      await getContacts();

      logger.d("Contact updated successfully");
    });
  }

  Future<void> deleteContact(String contactId) async {
    _isDeletingContact = true;
    notifyListeners();

    final result = await contactsRepository.deleteContact(contactId: contactId);
    result.fold((failure) {
      _isDeletingContact = false;
      notifyListeners();
    }, (success) async {
      _isDeletingContact = false;
      notifyListeners();
      await getContacts();

      logger.d("Contact deleted successfully");
    });
  }
}


final contactsProvider = ChangeNotifierProvider<ContactsProvider>((ref) {
  return ContactsProvider(contactsRepository: ContactsRepositoryImpl());
});