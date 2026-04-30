import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/custom_equipment_item.dart';

class FirebaseCustomEquipmentService {
  FirebaseCustomEquipmentService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? _safeAuth(),
      _firestore = firestore ?? _safeFirestore();

  static const String _collectionName = 'user_custom_equipment';
  static const String _itemsField = 'items';

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

  Future<List<CustomEquipmentItem>> fetchItems() async {
    final String? uid = currentUserId;
    final DocumentReference<Map<String, dynamic>>? userDoc = uid == null
        ? null
        : _userDoc(uid);
    if (userDoc == null) {
      return const <CustomEquipmentItem>[];
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
    final dynamic rawItems = snapshot.data()?[_itemsField];
    if (rawItems is! List) {
      return const <CustomEquipmentItem>[];
    }

    final List<CustomEquipmentItem> items = <CustomEquipmentItem>[];
    for (final dynamic row in rawItems) {
      if (row is! Map) {
        continue;
      }
      final CustomEquipmentItem item = CustomEquipmentItem.fromJson(
        Map<String, dynamic>.from(row),
      );
      if (!item.isValid) {
        continue;
      }
      items.add(item);
    }

    return items;
  }

  Future<void> saveItems(List<CustomEquipmentItem> items) async {
    final String? uid = currentUserId;
    final DocumentReference<Map<String, dynamic>>? userDoc = uid == null
        ? null
        : _userDoc(uid);
    if (userDoc == null) {
      return;
    }

    final List<Map<String, dynamic>> payload = items
        .map((CustomEquipmentItem item) => item.toJson())
        .toList(growable: false);

    await userDoc.set(<String, dynamic>{
      _itemsField: payload,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
