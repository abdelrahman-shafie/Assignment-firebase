import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoursesStream() {
    return _db.collection('courses').snapshots();
  }

  Future<void> addCourse({
    required String title,
    required String description,
  }) async {
    await _db.collection('courses').add({
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> enrollInCourse(String courseId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged in user');

    // Write both 'userId' and 'userID' to remain compatible with any existing indexes
    await _db.collection('enrollments').add({
      'userId': user.uid,
      'userID': user.uid,
      'courseId': courseId,
      'enrolledAt': FieldValue.serverTimestamp(),
    });
  }
}
