
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:nyoba/utils/utility.dart';

class LocalAuth {
  static final auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async =>
      await auth.canCheckBiometrics && await auth.isDeviceSupported();

  static Future<bool> authenticate() async {
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    printLog((availableBiometrics.toString()), name: "Biometrics");
    try {
      if (!await canAuthenticate()) return false;
      if (availableBiometrics[0] == BiometricType.strong) {
        printLog("FingerPrint");
      } else if (availableBiometrics[0] == BiometricType.face) {
        printLog("FaceID");
      }
      return await auth.authenticate(
          authMessages: const <AuthMessages>[
            IOSAuthMessages(cancelButton: 'No, Thanks'),
            AndroidAuthMessages(
              signInTitle: 'Sign in',
              cancelButton: 'No, Thanks',
            ),
          ],
          localizedReason: 'Sign in with biometric',
          options: AuthenticationOptions(
              useErrorDialogs: true, stickyAuth: true, biometricOnly: true));
    } catch (e) {
      printLog(e.toString(), name: "Error biometric");
      return false;
    }
  }
}
