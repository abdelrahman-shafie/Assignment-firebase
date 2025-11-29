import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import 'add_course_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseService = CourseService();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'My Enrollments',
            onPressed: () {
              Navigator.pushNamed(context, '/enrolled');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCourseScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: courseService.getCoursesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading courses'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No courses yet'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final courseDoc = docs[index];
              final course = courseDoc.data();
              final courseId = courseDoc.id;

              return ListTile(
                title: Text(course['title'] ?? ''),
                subtitle: Text(course['description'] ?? ''),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await courseService.enrollInCourse(courseId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enrolled successfully')),
                    );
                  },
                  child: const Text('Enroll'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
