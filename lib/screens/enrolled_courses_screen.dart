import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EnrolledCoursesScreen extends StatefulWidget {
  const EnrolledCoursesScreen({super.key});

  @override
  State<EnrolledCoursesScreen> createState() => _EnrolledCoursesScreenState();
}

class _EnrolledCoursesScreenState extends State<EnrolledCoursesScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    if (_user == null) {
      _stream = null;
      return;
    }

    // NOTE: Removing server-side orderBy prevents Firestore requiring a composite index.
    // We fetch enrollments filtered by userId and sort them client-side.
    _stream = _db.collection('enrollments').where('userId', isEqualTo: _user!.uid).snapshots();
  }

  void _retry() {
    setState(() {
      _initStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Enrollments')),
        body: const Center(child: Text('Not signed in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Enrollments')),
      body: _stream == null
          ? const Center(child: Text('No stream'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  final err = snapshot.error?.toString() ?? 'Unknown error';
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Error loading enrollments', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(err, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _retry, child: const Text('Retry')),
                          const SizedBox(height: 8),
                          const Text('If this mentions an index, ensure the index uses the field name exactly as written in documents (e.g. "userId").'),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.data!.docs);
                if (docs.isEmpty) return const Center(child: Text('You are not enrolled in any courses'));

                // Sort client-side by 'enrolledAt' timestamp (descending)
                docs.sort((a, b) {
                  final aTs = (a.data()['enrolledAt'] as Timestamp?)?.toDate().millisecondsSinceEpoch ?? 0;
                  final bTs = (b.data()['enrolledAt'] as Timestamp?)?.toDate().millisecondsSinceEpoch ?? 0;
                  return bTs.compareTo(aTs);
                });

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final enrollment = docs[index].data();
                    final courseId = enrollment['courseId'] as String?;

                    if (courseId == null) return const SizedBox.shrink();

                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: _db.collection('courses').doc(courseId).get(),
                      builder: (context, courseSnap) {
                        if (courseSnap.connectionState != ConnectionState.done) {
                          return const ListTile(title: Text('Loading...'));
                        }
                        if (!courseSnap.hasData || !courseSnap.data!.exists) {
                          return const ListTile(title: Text('Course not found'));
                        }

                        final course = courseSnap.data!.data()!;

                        return ListTile(
                          title: Text(course['title'] ?? ''),
                          subtitle: Text(course['description'] ?? ''),
                          trailing: Text(
                            enrollment['enrolledAt'] != null ? 'Enrolled' : '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
