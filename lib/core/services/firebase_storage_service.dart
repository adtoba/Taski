import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static Future<Map<String, dynamic>> uploadFile(String path, String fileName) async {
    final storage = FirebaseStorage.instance;

    final file = File(path);

    UploadTask uploadTask;

    final ref = storage.ref()
      .child("recordings/${FirebaseAuth.instance.currentUser?.uid}/$fileName");

    final metaData = SettableMetadata(
      contentType: "audio/aac",
      customMetadata: {
        "uploaded_by": FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
        "picked_file_path": path,
      },
    );
    uploadTask = ref.putFile(file, metaData);
    
    final snapshot = await uploadTask.whenComplete(() {});
    if (snapshot.state != TaskState.success) {
      throw Exception('Upload failed (${snapshot.state})');
    }

    final url = await ref.getDownloadURL();
    final metadata = await ref.getMetadata();

    return {
      'url': url,
      'metadata': metadata,
    };
    
  }
}