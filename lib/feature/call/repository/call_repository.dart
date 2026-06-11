// lib/feature/call/repository/call_repository.dart
import 'package:chitchat/feature/call/model/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chitchat/common/helper/show_alert_dialog.dart';

final callRepositoryProvider = Provider(
  (ref) => CallRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CallRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream =>
      firestore.collection('call').doc(auth.currentUser!.uid).snapshots();

  Future<void> makeCall(
      Call senderCallData, Call receiverCallData, BuildContext context) async {
    try {
      // تسجيل المكالمة لكل من المرسل والمستقبل
      await firestore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await firestore
          .collection('call')
          .doc(receiverCallData.receiverId)
          .set(receiverCallData.toMap());
    } catch (e) {
      showAlertDialog(
          context: context, message: 'Error making call: ${e.toString()}');
    }
  }

  Future<void> endCall(
      String callerId, String receiverId, BuildContext context) async {
    try {
      // حذف سجلات المكالمة عند انتهاء المكالمة
      await firestore.collection('call').doc(callerId).delete();
      await firestore.collection('call').doc(receiverId).delete();
    } catch (e) {
      showAlertDialog(
          context: context, message: 'Error ending call: ${e.toString()}');
    }
  }
}
