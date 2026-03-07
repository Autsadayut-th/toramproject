import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseSavedBuildsService {
  FirebaseSavedBuildsService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionName = 'user_saved_builds';
  static const String _savedBuildsField = 'builds';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? get currentUserId {
    final String? uid = _auth.currentUser?.uid.trim();
    if (uid == null || uid.isEmpty) {
      return null;
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection(_collectionName).doc(uid);
  }

  Future<List<Map<String, dynamic>>> fetchSavedBuilds() async {
    final String? uid = currentUserId;
    if (uid == null) {
      return const <Map<String, dynamic>>[];
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _userDoc(
      uid,
    ).get();
    final dynamic rawBuilds = snapshot.data()?[_savedBuildsField];
    if (rawBuilds is! List) {
      return const <Map<String, dynamic>>[];
    }

    final List<Map<String, dynamic>> builds = <Map<String, dynamic>>[];
    for (final dynamic rawBuild in rawBuilds) {
      if (rawBuild is Map) {
        builds.add(Map<String, dynamic>.from(rawBuild));
      }
    }
    return builds;
  }

  Future<void> saveSavedBuilds(List<Map<String, dynamic>> savedBuilds) async {
    final String? uid = currentUserId;
    if (uid == null) {
      return;
    }

    final List<Map<String, dynamic>> payload = savedBuilds
        .map((Map<String, dynamic> build) => Map<String, dynamic>.from(build))
        .toList(growable: false);

    await _userDoc(uid).set(<String, dynamic>{
      _savedBuildsField: payload,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
