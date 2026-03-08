import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseSavedBuildsService {
  FirebaseSavedBuildsService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? _safeAuth(),
      _firestore = firestore ?? _safeFirestore();

  static const String _collectionName = 'user_saved_builds';
  static const String _savedBuildsField = 'builds';

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  static FirebaseAuth? _safeAuth() {
    try {
      if (Firebase.apps.isEmpty) {
        return null;
      }
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? _safeFirestore() {
    try {
      if (Firebase.apps.isEmpty) {
        return null;
      }
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  String? get currentUserId {
    final String uid = _auth?.currentUser?.uid.trim() ?? '';
    if (uid.isEmpty) {
      return null;
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>>? _userDoc(String uid) {
    final FirebaseFirestore? firestore = _firestore;
    if (firestore == null) {
      return null;
    }
    return firestore.collection(_collectionName).doc(uid);
  }

  Future<List<Map<String, dynamic>>> fetchSavedBuilds() async {
    final String? uid = currentUserId;
    final DocumentReference<Map<String, dynamic>>? userDoc = uid == null
        ? null
        : _userDoc(uid);
    if (userDoc == null) {
      return const <Map<String, dynamic>>[];
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
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
    final DocumentReference<Map<String, dynamic>>? userDoc = uid == null
        ? null
        : _userDoc(uid);
    if (userDoc == null) {
      return;
    }

    final List<Map<String, dynamic>> payload = savedBuilds
        .map((Map<String, dynamic> build) => Map<String, dynamic>.from(build))
        .toList(growable: false);

    await userDoc.set(<String, dynamic>{
      _savedBuildsField: payload,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
