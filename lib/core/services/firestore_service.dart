import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {

  static final FirestoreService _firestoreService = FirestoreService._();

  FirestoreService._();

  static FirestoreService get instance => _firestoreService;

  static final firestore = FirebaseFirestore.instance;

  static DocumentReference users() {
    final user = FirebaseAuth.instance.currentUser;
    return firestore.collection("users").doc(user?.uid);
  }

  static CollectionReference sessions() {
    final user = FirebaseAuth.instance.currentUser;
    return firestore.collection("users").doc(user?.uid).collection("sessions");
  }

  static CollectionReference tasks() {
    final user = FirebaseAuth.instance.currentUser;
    return firestore.collection("users").doc(user?.uid).collection("tasks");
  }

  static CollectionReference messages() {
    final user = FirebaseAuth.instance.currentUser;
    return firestore.collection("users").doc(user?.uid).collection("messages");
  }
}