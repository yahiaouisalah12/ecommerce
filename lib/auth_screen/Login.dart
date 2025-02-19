import 'package:amozon_app/Homepage/Tapbar.dart';
import 'package:amozon_app/auth_screen/Sigup.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/services.dart';

class Login extends StatelessWidget {
  Login({super.key});

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      print("🚀 بدء تسجيل الدخول باستخدام Google...");

      // Initialize GoogleSignIn with proper configuration
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
        signInOption: SignInOption.standard,
      );

      // Sign out any existing session
      await googleSignIn.signOut();
      print("✅ تسجيل الخروج من Google Sign-In السابق.");

      // Attempt to sign in
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("⚠️ لم يحدد المستخدم حساب Google. تم الإلغاء.");
        return;
      }

      print("✅ تسجيل الدخول ناجح، البريد الإلكتروني: ${googleUser.email}");

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print("🔑 الحصول على رموز المصادقة...");

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Missing Google Auth Tokens');
      }

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("🔄 محاولة تسجيل الدخول باستخدام Firebase...");

      // Sign in to Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        print(
            "🎉 تسجيل الدخول ناجح! اسم المستخدم: ${userCredential.user!.displayName}");

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Tabe()),
          );
        }
      } else {
        throw Exception('User is null after Firebase sign in');
      }
    } on PlatformException catch (e) {
      print("❌ Platform Exception: ${e.code} - ${e.message}");
      _showErrorDialog(context, e.toString());
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Exception: ${e.code} - ${e.message}");
      _showErrorDialog(context, e.message ?? e.toString());
    } catch (e) {
      print("❌ General Exception: ${e.toString()}");
      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    if (context.mounted) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: "خطأ في تسجيل الدخول",
        desc:
            "حدث خطأ أثناء تسجيل الدخول باستخدام Google. حاول مرة أخرى.\n$error",
        btnOkText: 'موافق',
        btnOkColor: Colors.red,
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Start Facebook Login
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Ensure context is still valid before dismissing the loading dialog
      if (context.mounted) Navigator.pop(context);

      if (loginResult.status == LoginStatus.success &&
          loginResult.accessToken != null) {
        // Convert Facebook credentials to Firebase credentials
        final OAuthCredential credential = FacebookAuthProvider.credential(
          loginResult
              .accessToken!.tokenString, // ✅ Use tokenString instead of token
        );

        // Sign in with Firebase
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Tabe()),
          );
        }
      } else if (loginResult.status == LoginStatus.cancelled) {
        // Login was canceled by the user
        if (context.mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.scale,
            title: "تم الإلغاء",
            desc: "تم إلغاء تسجيل الدخول بواسطة المستخدم",
            btnOkText: 'حسناً',
            btnOkColor: Colors.blue,
            btnOkOnPress: () {},
          ).show();
        }
      } else {
        throw Exception('حدث خطأ في تسجيل الدخول بالفيسبوك');
      }
    } catch (e) {
      print("Facebook Sign-In Error: ${e.toString()}");

      if (context.mounted) {
        // Ensure dialog is dismissed in case of an error
        Navigator.pop(context);

        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: "خطأ في تسجيل الدخول",
          desc: "حدث خطأ أثناء تسجيل الدخول باستخدام Facebook. حاول مرة أخرى.",
          btnOkText: 'موافق',
          btnOkColor: Colors.red,
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("icons/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 70, left: 130),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          "icons/app_logo.png",
                          height: 100,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        margin: const EdgeInsets.only(left: 130),
                        child: const Text(
                          "Log in to eMart ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 25),
                      height: 410,
                      color: Colors.grey[300],
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: TextFormField(
                                controller: email,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: TextFormField(
                                controller: password,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () async {
                                  if (email.text == "") {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.scale,
                                      title: "خطأ في إعادة تعيين كلمة المرور",
                                      desc:
                                          "يرجى إدخال البريد الإلكتروني أولاً",
                                      btnOkText: 'موافق',
                                      btnOkColor: Colors.red,
                                      btnOkOnPress: () {},
                                    ).show();
                                    return;
                                  }
                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                            email: email.text);
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.success,
                                      animType: AnimType.scale,
                                      title: "إعادة تعيين كلمة المرور",
                                      desc:
                                          "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني",
                                      btnOkText: 'موافق',
                                      btnOkColor: Colors.green,
                                      btnOkOnPress: () {},
                                    ).show();
                                  } catch (e) {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.scale,
                                      title: "خطأ",
                                      desc:
                                          "تأكد من صحة البريد الإلكتروني المدخل",
                                      btnOkText: 'حسناً',
                                      btnOkColor: Colors.red,
                                      btnOkOnPress: () {},
                                    ).show();
                                  }
                                },
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                // التحقق من أن الحقول ليست فارغة
                                if (email.text.isEmpty ||
                                    password.text.isEmpty) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.scale,
                                    title: "حقول فارغة",
                                    desc:
                                        "يرجى إدخال البريد الإلكتروني وكلمة المرور",
                                    btnOkText: 'فهمت',
                                    btnOkColor: Colors.orange,
                                    btnOkOnPress: () {},
                                  ).show();
                                  return;
                                }

                                try {
                                  final credential = await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                    email: email.text,
                                    password: password.text,
                                  );

                                  if (credential.user != null) {
                                    if (credential.user!.emailVerified) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => const Tabe()),
                                      );
                                    } else {
                                      await credential.user!
                                          .sendEmailVerification();
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.warning,
                                        animType: AnimType.scale,
                                        title: "تأكيد البريد الإلكتروني",
                                        desc:
                                            "تم إرسال رابط التحقق إلى بريدك الإلكتروني. يرجى تفعيله ثم المحاولة مرة أخرى.",
                                        btnOkText: 'موافق',
                                        btnOkColor: Colors.orange,
                                        btnOkOnPress: () {},
                                      ).show();
                                    }
                                  }
                                } on FirebaseAuthException catch (e) {
                                  print(
                                      "Firebase Error Code: ${e.code}"); // طباعة الكود الفعلي لمعرفة المشكلة

                                  String errorMessage;
                                  switch (e.code) {
                                    case 'invalid-email':
                                      errorMessage =
                                          'البريد الإلكتروني غير صالح';
                                      break;
                                    case 'user-disabled':
                                      errorMessage = 'تم تعطيل هذا الحساب';
                                      break;
                                    case 'user-not-found':
                                      errorMessage =
                                          'لا يوجد حساب بهذا البريد الإلكتروني';
                                      break;
                                    case 'wrong-password':
                                      errorMessage = 'كلمة المرور غير صحيحة';
                                      break;
                                    case 'invalid-credential': // حل المشكلة هنا
                                      errorMessage =
                                          'البريد الإلكتروني أو كلمة المرور غير صحيحة';
                                      break;
                                    case 'too-many-requests':
                                      errorMessage =
                                          'تم حظر المحاولات بسبب عدد كبير من المحاولات الفاشلة. حاول لاحقًا.';
                                      break;
                                    default:
                                      errorMessage =
                                          'خطأ غير متوقع: ${e.message}';
                                  }

                                  // عرض الخطأ باستخدام AwesomeDialog
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.scale,
                                    title: "خطأ في تسجيل الدخول",
                                    desc: errorMessage,
                                    btnOkText: 'موافق',
                                    btnOkColor: Colors.red,
                                    btnOkOnPress: () {},
                                  ).show();
                                }
                              },
                              child: Container(
                                height: 45,
                                width: 275,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text("create to accounte"),
                            const SizedBox(
                              height: 5,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const Signup()));
                              },
                              child: Container(
                                height: 40,
                                width: 275,
                                decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(30)),
                                child: const Center(
                                  child: Text(
                                    "Sign up",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    signInWithFacebook(context);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    height: 60,
                                    width: 100,
                                    decoration: const BoxDecoration(),
                                    child:
                                        Image.asset("icons/facebook_logo.png"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    signInWithGoogle(context);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    height: 60,
                                    width: 100,
                                    decoration: const BoxDecoration(),
                                    child: Image.asset("icons/google_logo.png"),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
