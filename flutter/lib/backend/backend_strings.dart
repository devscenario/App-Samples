import '../sample_strings.dart';

/// Backend screen strings. Mirrors `shared-ui` `BackendStrings.kt` (English +
/// Georgian) so texts match the Compose and SwiftUI samples.
abstract class BackendStrings {
  String get title;
  String get username;
  String get password;
  String get signIn;
  String signedIn(String username);
  String get wrongCredentials;
  String get unreachable;
  String get placeOrder;
  String get orderPlaced;
  String get refresh;
  String status(String status);
  String get noOrder;
}

/// The backend table for the active [SampleStrings] language.
BackendStrings backendStringsOf(SampleStrings strings) =>
    strings is KaStrings ? const KaBackendStrings() : const EnBackendStrings();

class EnBackendStrings implements BackendStrings {
  const EnBackendStrings();
  @override
  String get title => 'Backend';
  @override
  String get username => 'Username';
  @override
  String get password => 'Password';
  @override
  String get signIn => 'Sign in';
  @override
  String signedIn(String username) => 'Signed in as $username';
  @override
  String get wrongCredentials => 'Wrong username or password';
  @override
  String get unreachable => 'Backend unreachable';
  @override
  String get placeOrder => 'Place order';
  @override
  String get orderPlaced => 'Order placed';
  @override
  String get refresh => 'Refresh status';
  @override
  String status(String status) => 'Status: $status';
  @override
  String get noOrder => 'No order';
}

class KaBackendStrings implements BackendStrings {
  const KaBackendStrings();
  @override
  String get title => 'ბექენდი';
  @override
  String get username => 'მომხმარებელი';
  @override
  String get password => 'პაროლი';
  @override
  String get signIn => 'შესვლა';
  @override
  String signedIn(String username) => 'შესულია: $username';
  @override
  String get wrongCredentials => 'არასწორი მომხმარებელი ან პაროლი';
  @override
  String get unreachable => 'ბექენდი მიუწვდომელია';
  @override
  String get placeOrder => 'შეკვეთის განთავსება';
  @override
  String get orderPlaced => 'შეკვეთა განთავსებულია';
  @override
  String get refresh => 'სტატუსის განახლება';
  @override
  String status(String status) => 'სტატუსი: $status';
  @override
  String get noOrder => 'შეკვეთა არ არის';
}
