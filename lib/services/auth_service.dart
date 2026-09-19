import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// ห่อการเรียกใช้ FirebaseAuth ไว้ที่เดียว พร้อมแปล error code เป็นข้อความไทย
/// รองรับการล็อกอินด้วย username โดยเก็บ mapping username -> email ไว้ใน Firestore
/// (Firebase Auth เองรองรับแค่ email/phone เท่านั้น ไม่มี username โดยตรง)
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  String _normalizeUsername(String username) => username.trim().toLowerCase();

  /// เข้าสู่ระบบด้วยอีเมล หรือ username ก็ได้ (ดูจากว่ามี '@' ในข้อความหรือไม่)
  Future<void> signIn(
      {required String identifier, required String password}) async {
    try {
      final email = identifier.contains('@')
          ? identifier
          : await _resolveEmailFromUsername(identifier);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e.code));
    }
  }

  Future<String> _resolveEmailFromUsername(String username) async {
    final doc = await _db
        .collection('usernames')
        .doc(_normalizeUsername(username))
        .get();
    if (!doc.exists) {
      throw AuthFailure('ไม่พบชื่อผู้ใช้นี้ในระบบ');
    }
    return doc.data()!['email'] as String;
  }

  /// สมัครสมาชิกด้วย email/password + username เท่านั้น ยังไม่มีชื่อเล่น (displayName)
  /// ผู้ใช้ต้องไปกรอกชื่อเล่นในหน้าสร้างโปรไฟล์หลังล็อกอินครั้งแรก
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final normalizedUsername = _normalizeUsername(username);
    final usernameRef = _db.collection('usernames').doc(normalizedUsername);

    if ((await usernameRef.get()).exists) {
      throw AuthFailure('ชื่อผู้ใช้นี้ถูกใช้ไปแล้ว กรุณาเลือกชื่ออื่น');
    }

    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e.code));
    }

    final uid = credential.user!.uid;
    try {
      await usernameRef.set({
        'uid': uid,
        'email': email,
        'username': username.trim(),
      });
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'username': username.trim(),
      });
    } catch (_) {
      // เขียน Firestore ไม่สำเร็จ (เช่น หลุดเน็ต) แต่บัญชี Auth สร้างไปแล้ว
      // ลบบัญชีทิ้งเพื่อไม่ให้ค้างเป็นบัญชีที่ไม่มี username ผูกอยู่
      await credential.user?.delete();
      throw AuthFailure('สมัครสมาชิกไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
    }
  }

  /// บันทึกชื่อเล่น (displayName) + ข้อมูลโปรไฟล์อื่นๆ ตอนผู้ใช้สร้างโปรไฟล์ครั้งแรกหลังล็อกอิน
  Future<void> completeProfile({
    required String displayName,
    Map<String, dynamic> extraFields = const {},
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(displayName);
    await user.reload();
    await _db.collection('users').doc(user.uid).set({
      'displayName': displayName,
      ...extraFields,
    }, SetOptions(merge: true));
  }

  /// อัปโหลดรูปโปรไฟล์ขึ้น Firebase Storage แล้วอัปเดต photoURL ของบัญชี + Firestore
  /// คืนค่า download URL ของรูปที่อัปโหลดสำเร็จ
  Future<String> uploadProfileImage(Uint8List bytes,
      {String contentType = 'image/jpeg'}) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure('กรุณาเข้าสู่ระบบก่อน');

    final ref = _storage.ref('profile_images/${user.uid}.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    final url = await ref.getDownloadURL();

    await user.updatePhotoURL(url);
    await _db
        .collection('users')
        .doc(user.uid)
        .set({'profileImageUrl': url}, SetOptions(merge: true));

    return url;
  }

  Future<void> signOut() => _auth.signOut();

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      case 'user-disabled':
        return 'บัญชีนี้ถูกระงับการใช้งาน';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'อีเมล/ชื่อผู้ใช้ หรือรหัสผ่านไม่ถูกต้อง';
      case 'email-already-in-use':
        return 'อีเมลนี้ถูกใช้สมัครสมาชิกไปแล้ว';
      case 'weak-password':
        return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
      case 'network-request-failed':
        return 'เชื่อมต่อเครือข่ายไม่สำเร็จ กรุณาลองใหม่';
      case 'too-many-requests':
        return 'พยายามเข้าสู่ระบบบ่อยเกินไป กรุณาลองใหม่ภายหลัง';
      default:
        return 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
    }
  }
}

class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
