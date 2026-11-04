/// In-app language toggle for the Flutter sample app. Drives the displayed
/// strings only (via [SampleLocale]); it does NOT change the OS / per-app
/// locale or `Locale` resolution. Default is [SampleLanguage.english] so
/// existing E2E flows and the widget/parity tests (which assert on English
/// copy) keep passing.
///
/// Mirrors `compose-multiplatform/shared-ui/.../SampleStrings.kt` (English + `KaStrings`)
/// so the Compose Multiplatform sample and this Flutter sample stay consistent.
library;

enum SampleLanguage {
  english('English'),
  georgian('Georgian');

  const SampleLanguage(this.label);
  final String label;
}

/// Type-safe string table. Every user-visible string in the Flutter sample is
/// a named member here, grouped by screen. The abstract class forces
/// [KaStrings] to supply a translation for every key — a missing override is a
/// compile error.
///
/// Methods (e.g. [loginSuccess]) cover strings that interpolate runtime values.
/// Test-tag strings (see `TestTags`), route names, network paths, and data ids
/// are intentionally NOT in this table — they must never be translated.
abstract class SampleStrings {
  // TopAppBar / navigation
  String get back;
  String get languageChooser;
  String get languageEnglish;
  String get languageGeorgian;

  // Home grid / screen titles
  String get titleHome;
  String get titleLogin;
  String get titleRegistration;
  String get titleList;
  String get titleGrid;
  String get titleShowcase;
  String get titleSearch;
  String get titleCheckout;
  String get titleProfile;
  String get titlePinch;
  String get titleModals;
  String get titleDragDrop;
  String get titleNetwork;

  // Login
  String get loginWelcome;
  String get loginEmail;
  String get loginPassword;
  String get loginRememberMe;
  String get loginSignIn;
  String loginEmailTyped(String value);
  String loginPasswordTyped(String value);
  String loginSuccess(String email);
  String get loginFailure;

  // Registration
  String get regCreateAccount;
  String get regFullName;
  String get regEmail;
  String get regPassword;
  String get regAcceptTerms;
  String get regTermsAccepted;
  String get regRegister;
  String regNameTyped(String value);
  String regEmailTyped(String value);
  String regPasswordTyped(String value);
  String regSuccess(String email);
  String get regFailureName;
  String get regFailureEmail;
  String get regFailurePassword;

  // Checkout
  String get checkoutTitle;
  String get checkoutOrderSummary;
  String get checkoutProduct;
  String checkoutSubtotal(String amount);
  String checkoutShipping(String amount);
  String checkoutTotal(String amount);
  String get checkoutShippingAddress;
  String get checkoutExpressDelivery;
  String checkoutPayment(String method);
  String get checkoutPlaceOrder;
  String checkoutAddressTyped(String value);
  String checkoutOrderPlaced(String address);
  String get checkoutFailure;

  // Profile
  String get profileTitle;
  String get profileDisplayName;
  String get profilePhone;
  String get profileMarketingEmails;
  String get profileSave;
  String profileNameTyped(String value);
  String profilePhoneTyped(String value);
  String profileSaved(String name);
  String get profileFailureName;
  String get profileFailurePhone;

  // List
  String get listOrderDetails;
  String listSelected(String id);
  String listCustomer(String name);
  String listTotal(String total);
  String listStatus(String status);
  String get listStatusReady;
  String get listStatusProcessing;

  // Grid
  String get gridProductDetails;
  String gridSelected(String name);
  String gridPrice(String price);
  String gridInventory(String inventory);
  String get gridInStock;
  String get gridLowStock;

  // Search
  String get searchTitle;
  String get searchField;
  String get searchRun;
  String searchQueryTyped(String value);
  String searchFeatured(int count);
  String searchResults(String query, int count);
  String searchCategory(String category);
  String searchPrice(String price);

  // Showcase
  String get showcaseTitle;
  String get showcaseIntro;
  String get showcaseEnableNotifications;
  String get showcaseProgress;
  String showcaseListElement(int index);
  String get showcasePrimary;
  String get showcaseSecondary;
  String get showcaseEnd;

  // Pinch
  String get pinchTitle;
  String get pinchIntro;
  String get pinchMe;
  String pinchStatus(double scale, String direction, int events);
  String get pinchDirIn;
  String get pinchDirOut;
  String get pinchDirNone;

  // Modals
  String get modalsTitle;
  String get modalsIntro;
  String get modalsPartialSheet;
  String get modalsFullSheet;
  String get modalsAlertDialog;
  String get modalsFullscreenDialog;
  String modalsStatus(String value);
  String get modalsStatusNone;
  String get modalsStatusPartialVisible;
  String get modalsStatusFullVisible;
  String get modalsStatusSheetDismissed;
  String get modalsStatusAlertVisible;
  String get modalsStatusFullscreenVisible;
  String get modalsStatusAlertConfirmed;
  String get modalsStatusAlertHidden;
  String get modalsStatusSheetHidden;
  String get modalsStatusFullscreenHidden;
  String get modalsBottomSheet;
  String get modalsSheetIntro;
  String get modalsHideSheet;
  String get modalsAlertTitle;
  String get modalsAlertBody;
  String get modalsConfirm;
  String get modalsDismiss;
  String get modalsFullscreenTitle;
  String get modalsFullscreenBody;
  String get modalsClose;
  String get modalsCodeSheet;
  String get modalsVerifyByCode;
  String get modalsSmsCode;
  String get modalsVerify;
  String modalsStatusCodeVerified(String code);

  // Drag & drop
  String get dragTitle;
  String get dragIntro;
  String dragStatus(String value);
  String get dragStatusNone;
  String get dragDropZone;
  String get dragDropHint;
  String dragDropHere(String name);
  String get dragSources;
  String get dragReorderable;
  String get dragReorderHint;
  String dragDragging(String name);
  String dragDroppedInZone(String name);
  String dragCancelled(String name);
  String dragPickedUp(String item);
  String dragMovedUp(String item);
  String dragMovedDown(String item);
  String get dragRowOne;
  String get dragRowTwo;
  String get dragRowThree;

  // Network
  String get networkDemoTitle;
  String get networkDemoBody;
  String get networkAutoFiring;
  String networkAutoFailed(String message);
  String networkAutoDone(int code, int durationMs);
  String get networkAutoLabel;
  String get networkBtnGetPost;
  String get networkBtnPostBody;
  String get networkBtnHttpbin;
  String get networkBtn404;
}

/// English string table. Values must stay exactly as the prior hardcoded copy
/// so existing English-asserting flows/tests keep passing.
class EnStrings implements SampleStrings {
  const EnStrings();

  // TopAppBar / navigation
  @override
  String get back => 'Back';
  @override
  String get languageChooser => 'Language';
  @override
  String get languageEnglish => 'English';
  @override
  String get languageGeorgian => 'Georgian';

  // Home grid / screen titles
  @override
  String get titleHome => 'Sample Screens';
  @override
  String get titleLogin => 'Login';
  @override
  String get titleRegistration => 'Registration';
  @override
  String get titleList => 'List';
  @override
  String get titleGrid => 'Grid';
  @override
  String get titleShowcase => 'Showcase';
  @override
  String get titleSearch => 'Search';
  @override
  String get titleCheckout => 'Checkout';
  @override
  String get titleProfile => 'Profile';
  @override
  String get titlePinch => 'Pinch';
  @override
  String get titleModals => 'Modals';
  @override
  String get titleDragDrop => 'Drag & Drop';
  @override
  String get titleNetwork => 'Network';

  // Login
  @override
  String get loginWelcome => 'Welcome back';
  @override
  String get loginEmail => 'Email';
  @override
  String get loginPassword => 'Password';
  @override
  String get loginRememberMe => 'Remember me';
  @override
  String get loginSignIn => 'Sign in';
  @override
  String loginEmailTyped(String value) => 'Login email typed: $value';
  @override
  String loginPasswordTyped(String value) => 'Login password typed: $value';
  @override
  String loginSuccess(String email) => 'Login success for $email';
  @override
  String get loginFailure =>
      'Login failed: enter a valid email and 6+ character password';

  // Registration
  @override
  String get regCreateAccount => 'Create account';
  @override
  String get regFullName => 'Full name';
  @override
  String get regEmail => 'Email';
  @override
  String get regPassword => 'Password';
  @override
  String get regAcceptTerms => 'Accept terms';
  @override
  String get regTermsAccepted => 'Terms accepted';
  @override
  String get regRegister => 'Register';
  @override
  String regNameTyped(String value) => 'Registration name typed: $value';
  @override
  String regEmailTyped(String value) => 'Registration email typed: $value';
  @override
  String regPasswordTyped(String value) => 'Registration password typed: $value';
  @override
  String regSuccess(String email) => 'Registration success for $email';
  @override
  String get regFailureName => 'Registration failed: enter full name';
  @override
  String get regFailureEmail => 'Registration failed: enter a valid email';
  @override
  String get regFailurePassword =>
      'Registration failed: password must be 8+ characters';

  // Checkout
  @override
  String get checkoutTitle => 'Checkout';
  @override
  String get checkoutOrderSummary => 'Order summary';
  @override
  String get checkoutProduct => 'Wireless Headphones';
  @override
  String checkoutSubtotal(String amount) => 'Subtotal: $amount';
  @override
  String checkoutShipping(String amount) => 'Shipping: $amount';
  @override
  String checkoutTotal(String amount) => 'Total: $amount';
  @override
  String get checkoutShippingAddress => 'Shipping address';
  @override
  String get checkoutExpressDelivery => 'Express delivery';
  @override
  String checkoutPayment(String method) => 'Payment: $method';
  @override
  String get checkoutPlaceOrder => 'Place order';
  @override
  String checkoutAddressTyped(String value) => 'Checkout address typed: $value';
  @override
  String checkoutOrderPlaced(String address) => 'Order placed for $address';
  @override
  String get checkoutFailure =>
      'Checkout failed: enter a valid shipping address';

  // Profile
  @override
  String get profileTitle => 'Profile settings';
  @override
  String get profileDisplayName => 'Display name';
  @override
  String get profilePhone => 'Phone number';
  @override
  String get profileMarketingEmails => 'Marketing emails';
  @override
  String get profileSave => 'Save profile';
  @override
  String profileNameTyped(String value) => 'Profile name typed: $value';
  @override
  String profilePhoneTyped(String value) => 'Profile phone typed: $value';
  @override
  String profileSaved(String name) => 'Profile saved for $name';
  @override
  String get profileFailureName => 'Profile failed: enter display name';
  @override
  String get profileFailurePhone => 'Profile failed: enter phone number';

  // List
  @override
  String get listOrderDetails => 'Order details';
  @override
  String listSelected(String id) => 'Selected $id';
  @override
  String listCustomer(String name) => 'Customer: $name';
  @override
  String listTotal(String total) => 'Total: $total';
  @override
  String listStatus(String status) => 'Status: $status';
  @override
  String get listStatusReady => 'Ready to ship';
  @override
  String get listStatusProcessing => 'Processing';

  // Grid
  @override
  String get gridProductDetails => 'Product details';
  @override
  String gridSelected(String name) => 'Selected $name';
  @override
  String gridPrice(String price) => 'Price: $price';
  @override
  String gridInventory(String inventory) => 'Inventory: $inventory';
  @override
  String get gridInStock => 'In stock';
  @override
  String get gridLowStock => 'Low stock';

  // Search
  @override
  String get searchTitle => 'Search catalog';
  @override
  String get searchField => 'Search products';
  @override
  String get searchRun => 'Run search';
  @override
  String searchQueryTyped(String value) => 'Search query typed: $value';
  @override
  String searchFeatured(int count) => 'Showing $count featured products';
  @override
  String searchResults(String query, int count) =>
      'Search results for $query: $count items';
  @override
  String searchCategory(String category) => 'Category: $category';
  @override
  String searchPrice(String price) => 'Price: $price';

  // Showcase
  @override
  String get showcaseTitle => 'Component Showcase';
  @override
  String get showcaseIntro =>
      'This tab helps validate gestures, scrolling, toggles, and assertions.';
  @override
  String get showcaseEnableNotifications => 'Enable notifications';
  @override
  String get showcaseProgress => 'Progress';
  @override
  String showcaseListElement(int index) => 'List element $index';
  @override
  String get showcasePrimary => 'Primary';
  @override
  String get showcaseSecondary => 'Secondary';
  @override
  String get showcaseEnd => 'End of screen';

  // Pinch
  @override
  String get pinchTitle => 'Pinch Playground';
  @override
  String get pinchIntro => 'Use two fingers to zoom the target in/out.';
  @override
  String get pinchMe => 'Pinch me';
  @override
  String pinchStatus(double scale, String direction, int events) =>
      'Pinch scale: ${scale.toStringAsFixed(2)} | last: $direction | events: $events';
  @override
  String get pinchDirIn => 'zoom in';
  @override
  String get pinchDirOut => 'zoom out';
  @override
  String get pinchDirNone => 'none';

  // Modals
  @override
  String get modalsTitle => 'Modals';
  @override
  String get modalsIntro =>
      'Open dialogs and sheets, then swipe down or dismiss to validate hide commands.';
  @override
  String get modalsPartialSheet => 'Partial sheet';
  @override
  String get modalsFullSheet => 'Full sheet';
  @override
  String get modalsAlertDialog => 'Alert dialog';
  @override
  String get modalsFullscreenDialog => 'Fullscreen dialog';
  @override
  String modalsStatus(String value) => 'Status: $value';
  @override
  String get modalsStatusNone => 'No modal opened yet';
  @override
  String get modalsStatusPartialVisible => 'Partial bottom sheet visible';
  @override
  String get modalsStatusFullVisible => 'Full bottom sheet visible';
  @override
  String get modalsStatusSheetDismissed => 'Bottom sheet dismissed';
  @override
  String get modalsStatusAlertVisible => 'Alert dialog visible';
  @override
  String get modalsStatusFullscreenVisible => 'Fullscreen dialog visible';
  @override
  String get modalsStatusAlertConfirmed => 'Alert dialog confirmed';
  @override
  String get modalsStatusAlertHidden => 'Alert dialog hidden with dismiss';
  @override
  String get modalsStatusSheetHidden =>
      'Bottom sheet hidden with close action';
  @override
  String get modalsStatusFullscreenHidden => 'Fullscreen dialog hidden';
  @override
  String get modalsBottomSheet => 'Bottom sheet';
  @override
  String get modalsSheetIntro =>
      'Swipe down to hide, or use the close action below.';
  @override
  String get modalsHideSheet => 'Hide sheet';
  @override
  String get modalsAlertTitle => 'Session expired';
  @override
  String get modalsAlertBody =>
      'Test dismiss and confirm commands on this dialog.';
  @override
  String get modalsConfirm => 'Confirm';
  @override
  String get modalsDismiss => 'Dismiss';
  @override
  String get modalsFullscreenTitle => 'Fullscreen-like dialog';
  @override
  String get modalsFullscreenBody => 'Use swipe/tap commands then close it.';
  @override
  String get modalsClose => 'Close';
  @override
  String get modalsCodeSheet => 'Code sheet';
  @override
  String get modalsVerifyByCode => 'Verify by code';
  @override
  String get modalsSmsCode => 'SMS code';
  @override
  String get modalsVerify => 'Verify';
  @override
  String modalsStatusCodeVerified(String code) => 'Code verified: $code';

  // Drag & drop
  @override
  String get dragTitle => 'Drag & Drop';
  @override
  String get dragIntro =>
      'Drag a source chip into the drop zone, or drag rows to reorder them.';
  @override
  String dragStatus(String value) => 'Status: $value';
  @override
  String get dragStatusNone => 'No drag performed yet';
  @override
  String get dragDropZone => 'Drop Zone';
  @override
  String get dragDropHint => '(drag a chip here)';
  @override
  String dragDropHere(String name) => 'Drop "$name" here';
  @override
  String get dragSources => 'Drag sources:';
  @override
  String get dragReorderable => 'Reorderable rows:';
  @override
  String get dragReorderHint =>
      'Drag a row up or down to change its position.';
  @override
  String dragDragging(String name) => 'Dragging $name';
  @override
  String dragDroppedInZone(String name) => '$name dropped in zone';
  @override
  String dragCancelled(String name) => '$name drag cancelled';
  @override
  String dragPickedUp(String item) => 'Picked up: $item';
  @override
  String dragMovedUp(String item) => '$item moved up';
  @override
  String dragMovedDown(String item) => '$item moved down';
  @override
  String get dragRowOne => 'Row One';
  @override
  String get dragRowTwo => 'Row Two';
  @override
  String get dragRowThree => 'Row Three';

  // Network
  @override
  String get networkDemoTitle => 'Dev Scenario interceptor demo';
  @override
  String get networkDemoBody =>
      "These requests are captured by Dev Scenario with NO `.addInterceptor(…)` "
      "lines anywhere in this app's source — the auto-wire plugin / SwiftPM "
      "swizzle handles it for you.";
  @override
  String get networkAutoFiring => 'Firing initial request…';
  @override
  String networkAutoFailed(String message) => 'Auto request failed: $message';
  @override
  String networkAutoDone(int code, int durationMs) =>
      'Auto request done — $code in $durationMs ms. Check the Dev Scenario Network tab.';
  @override
  String get networkAutoLabel => 'Auto-fired on screen entry';
  @override
  String get networkBtnGetPost => 'GET jsonplaceholder /posts/1';
  @override
  String get networkBtnPostBody => 'POST jsonplaceholder /posts';
  @override
  String get networkBtnHttpbin => 'GET httpbin.org/get';
  @override
  String get networkBtn404 => 'GET → 404 (force error)';
}

/// Georgian (ქართული) string table. Copy reused from the Compose sample's
/// `KaStrings` so the two platforms read identically.
class KaStrings implements SampleStrings {
  const KaStrings();

  // TopAppBar / navigation
  @override
  String get back => 'უკან';
  @override
  String get languageChooser => 'ენა';
  @override
  String get languageEnglish => 'ინგლისური';
  @override
  String get languageGeorgian => 'ქართული';

  // Home grid / screen titles
  @override
  String get titleHome => 'სანიმუშო ეკრანები';
  @override
  String get titleLogin => 'შესვლა';
  @override
  String get titleRegistration => 'რეგისტრაცია';
  @override
  String get titleList => 'სია';
  @override
  String get titleGrid => 'ბადე';
  @override
  String get titleShowcase => 'კომპონენტები';
  @override
  String get titleSearch => 'ძებნა';
  @override
  String get titleCheckout => 'გადახდა';
  @override
  String get titleProfile => 'პროფილი';
  @override
  String get titlePinch => 'მასშტაბირება';
  @override
  String get titleModals => 'ფანჯრები';
  @override
  String get titleDragDrop => 'გადათრევა';
  @override
  String get titleNetwork => 'ქსელი';

  // Login
  @override
  String get loginWelcome => 'კეთილი იყოს თქვენი დაბრუნება';
  @override
  String get loginEmail => 'ელფოსტა';
  @override
  String get loginPassword => 'პაროლი';
  @override
  String get loginRememberMe => 'დამიმახსოვრე';
  @override
  String get loginSignIn => 'შესვლა';
  @override
  String loginEmailTyped(String value) => 'აკრეფილი ელფოსტა: $value';
  @override
  String loginPasswordTyped(String value) => 'აკრეფილი პაროლი: $value';
  @override
  String loginSuccess(String email) => 'წარმატებული შესვლა: $email';
  @override
  String get loginFailure =>
      'შესვლა ვერ მოხერხდა: შეიყვანეთ სწორი ელფოსტა და 6+ სიმბოლოიანი პაროლი';

  // Registration
  @override
  String get regCreateAccount => 'ანგარიშის შექმნა';
  @override
  String get regFullName => 'სრული სახელი';
  @override
  String get regEmail => 'ელფოსტა';
  @override
  String get regPassword => 'პაროლი';
  @override
  String get regAcceptTerms => 'პირობების მიღება';
  @override
  String get regTermsAccepted => 'პირობები მიღებულია';
  @override
  String get regRegister => 'რეგისტრაცია';
  @override
  String regNameTyped(String value) => 'აკრეფილი სახელი: $value';
  @override
  String regEmailTyped(String value) => 'აკრეფილი ელფოსტა: $value';
  @override
  String regPasswordTyped(String value) => 'აკრეფილი პაროლი: $value';
  @override
  String regSuccess(String email) => 'წარმატებული რეგისტრაცია: $email';
  @override
  String get regFailureName => 'რეგისტრაცია ვერ მოხერხდა: შეიყვანეთ სრული სახელი';
  @override
  String get regFailureEmail => 'რეგისტრაცია ვერ მოხერხდა: შეიყვანეთ სწორი ელფოსტა';
  @override
  String get regFailurePassword =>
      'რეგისტრაცია ვერ მოხერხდა: პაროლი უნდა იყოს 8+ სიმბოლო';

  // Checkout
  @override
  String get checkoutTitle => 'გადახდა';
  @override
  String get checkoutOrderSummary => 'შეკვეთის მიმოხილვა';
  @override
  String get checkoutProduct => 'უსადენო ყურსასმენები';
  @override
  String checkoutSubtotal(String amount) => 'ჯამი: $amount';
  @override
  String checkoutShipping(String amount) => 'მიწოდება: $amount';
  @override
  String checkoutTotal(String amount) => 'სულ: $amount';
  @override
  String get checkoutShippingAddress => 'მიწოდების მისამართი';
  @override
  String get checkoutExpressDelivery => 'სწრაფი მიწოდება';
  @override
  String checkoutPayment(String method) => 'გადახდა: $method';
  @override
  String get checkoutPlaceOrder => 'შეკვეთის გაფორმება';
  @override
  String checkoutAddressTyped(String value) => 'აკრეფილი მისამართი: $value';
  @override
  String checkoutOrderPlaced(String address) =>
      'შეკვეთა გაფორმდა მისამართზე: $address';
  @override
  String get checkoutFailure =>
      'გადახდა ვერ მოხერხდა: შეიყვანეთ სწორი მიწოდების მისამართი';

  // Profile
  @override
  String get profileTitle => 'პროფილის პარამეტრები';
  @override
  String get profileDisplayName => 'სახელი';
  @override
  String get profilePhone => 'ტელეფონის ნომერი';
  @override
  String get profileMarketingEmails => 'სარეკლამო წერილები';
  @override
  String get profileSave => 'პროფილის შენახვა';
  @override
  String profileNameTyped(String value) => 'აკრეფილი სახელი: $value';
  @override
  String profilePhoneTyped(String value) => 'აკრეფილი ტელეფონი: $value';
  @override
  String profileSaved(String name) => 'პროფილი შენახულია: $name';
  @override
  String get profileFailureName => 'შენახვა ვერ მოხერხდა: შეიყვანეთ სახელი';
  @override
  String get profileFailurePhone =>
      'შენახვა ვერ მოხერხდა: შეიყვანეთ ტელეფონის ნომერი';

  // List
  @override
  String get listOrderDetails => 'შეკვეთის დეტალები';
  @override
  String listSelected(String id) => 'არჩეული $id';
  @override
  String listCustomer(String name) => 'მომხმარებელი: $name';
  @override
  String listTotal(String total) => 'სულ: $total';
  @override
  String listStatus(String status) => 'სტატუსი: $status';
  @override
  String get listStatusReady => 'გასაგზავნად მზად';
  @override
  String get listStatusProcessing => 'მუშავდება';

  // Grid
  @override
  String get gridProductDetails => 'პროდუქტის დეტალები';
  @override
  String gridSelected(String name) => 'არჩეული $name';
  @override
  String gridPrice(String price) => 'ფასი: $price';
  @override
  String gridInventory(String inventory) => 'მარაგი: $inventory';
  @override
  String get gridInStock => 'მარაგშია';
  @override
  String get gridLowStock => 'მცირე მარაგი';

  // Search
  @override
  String get searchTitle => 'კატალოგის ძებნა';
  @override
  String get searchField => 'პროდუქტების ძებნა';
  @override
  String get searchRun => 'ძებნა';
  @override
  String searchQueryTyped(String value) => 'აკრეფილი მოთხოვნა: $value';
  @override
  String searchFeatured(int count) => 'ნაჩვენებია $count რჩეული პროდუქტი';
  @override
  String searchResults(String query, int count) =>
      'ძებნის შედეგი „$query“-ზე: $count ერთეული';
  @override
  String searchCategory(String category) => 'კატეგორია: $category';
  @override
  String searchPrice(String price) => 'ფასი: $price';

  // Showcase
  @override
  String get showcaseTitle => 'კომპონენტების გალერეა';
  @override
  String get showcaseIntro =>
      'ეს ჩანართი ეხმარება ჟესტების, გადახვევის, გადამრთველებისა და შემოწმებების ვალიდაციას.';
  @override
  String get showcaseEnableNotifications => 'შეტყობინებების ჩართვა';
  @override
  String get showcaseProgress => 'პროგრესი';
  @override
  String showcaseListElement(int index) => 'სიის ელემენტი $index';
  @override
  String get showcasePrimary => 'ძირითადი';
  @override
  String get showcaseSecondary => 'მეორეული';
  @override
  String get showcaseEnd => 'ეკრანის დასასრული';

  // Pinch
  @override
  String get pinchTitle => 'მასშტაბირების სავარჯიშო';
  @override
  String get pinchIntro =>
      'გამოიყენეთ ორი თითი სამიზნის გასადიდებლად/დასაპატარავებლად.';
  @override
  String get pinchMe => 'დამაპატარავე';
  @override
  String pinchStatus(double scale, String direction, int events) =>
      'მასშტაბი: ${scale.toStringAsFixed(2)} | ბოლო: $direction | მოვლენები: $events';
  @override
  String get pinchDirIn => 'გადიდება';
  @override
  String get pinchDirOut => 'დაპატარავება';
  @override
  String get pinchDirNone => 'არცერთი';

  // Modals
  @override
  String get modalsTitle => 'ფანჯრები';
  @override
  String get modalsIntro =>
      'გახსენით დიალოგები და ფურცლები, შემდეგ გადაასრიალეთ ქვევით ან დახურეთ დამალვის ბრძანებების შესამოწმებლად.';
  @override
  String get modalsPartialSheet => 'ნაწილობრივი ფურცელი';
  @override
  String get modalsFullSheet => 'სრული ფურცელი';
  @override
  String get modalsAlertDialog => 'გამაფრთხილებელი დიალოგი';
  @override
  String get modalsFullscreenDialog => 'სრულეკრანიანი დიალოგი';
  @override
  String modalsStatus(String value) => 'სტატუსი: $value';
  @override
  String get modalsStatusNone => 'ჯერ არცერთი ფანჯარა არ გახსნილა';
  @override
  String get modalsStatusPartialVisible => 'ნაწილობრივი ქვედა ფურცელი ხილულია';
  @override
  String get modalsStatusFullVisible => 'სრული ქვედა ფურცელი ხილულია';
  @override
  String get modalsStatusSheetDismissed => 'ქვედა ფურცელი დაიხურა';
  @override
  String get modalsStatusAlertVisible => 'გამაფრთხილებელი დიალოგი ხილულია';
  @override
  String get modalsStatusFullscreenVisible => 'სრულეკრანიანი დიალოგი ხილულია';
  @override
  String get modalsStatusAlertConfirmed => 'გამაფრთხილებელი დიალოგი დადასტურდა';
  @override
  String get modalsStatusAlertHidden =>
      'გამაფრთხილებელი დიალოგი დაიმალა გაუქმებით';
  @override
  String get modalsStatusSheetHidden =>
      'ქვედა ფურცელი დაიმალა დახურვის მოქმედებით';
  @override
  String get modalsStatusFullscreenHidden => 'სრულეკრანიანი დიალოგი დაიმალა';
  @override
  String get modalsBottomSheet => 'ქვედა ფურცელი';
  @override
  String get modalsSheetIntro =>
      'გადაასრიალეთ ქვევით დასამალად ან გამოიყენეთ ქვემოთ მოცემული დახურვის მოქმედება.';
  @override
  String get modalsHideSheet => 'ფურცლის დამალვა';
  @override
  String get modalsAlertTitle => 'სესია ამოიწურა';
  @override
  String get modalsAlertBody =>
      'შეამოწმეთ გაუქმებისა და დადასტურების ბრძანებები ამ დიალოგზე.';
  @override
  String get modalsConfirm => 'დადასტურება';
  @override
  String get modalsDismiss => 'გაუქმება';
  @override
  String get modalsFullscreenTitle => 'სრულეკრანის მსგავსი დიალოგი';
  @override
  String get modalsFullscreenBody =>
      'გამოიყენეთ სრიალის/შეხების ბრძანებები, შემდეგ დახურეთ იგი.';
  @override
  String get modalsClose => 'დახურვა';
  @override
  String get modalsCodeSheet => 'კოდის ფურცელი';
  @override
  String get modalsVerifyByCode => 'კოდით დადასტურება';
  @override
  String get modalsSmsCode => 'SMS კოდი';
  @override
  String get modalsVerify => 'დადასტურება';
  @override
  String modalsStatusCodeVerified(String code) => 'კოდი დადასტურდა: $code';

  // Drag & drop
  @override
  String get dragTitle => 'გადათრევა';
  @override
  String get dragIntro =>
      'გადაიტანეთ წყაროს ჩიპი ჩასაგდებ ზონაში, ან გადაათრიეთ მწკრივები მათი თანმიმდევრობის შესაცვლელად.';
  @override
  String dragStatus(String value) => 'სტატუსი: $value';
  @override
  String get dragStatusNone => 'ჯერ გადათრევა არ შესრულებულა';
  @override
  String get dragDropZone => 'ჩასაგდები ზონა';
  @override
  String get dragDropHint => '(გადმოათრიეთ ჩიპი აქ)';
  @override
  String dragDropHere(String name) => 'ჩააგდეთ „$name“ აქ';
  @override
  String get dragSources => 'გადასათრევი წყაროები:';
  @override
  String get dragReorderable => 'გადასალაგებელი მწკრივები:';
  @override
  String get dragReorderHint =>
      'გადაათრიეთ მწკრივი ზევით ან ქვევით პოზიციის შესაცვლელად.';
  @override
  String dragDragging(String name) => 'გადათრევა: $name';
  @override
  String dragDroppedInZone(String name) => '$name ჩაგდებულია ზონაში';
  @override
  String dragCancelled(String name) => '$name გადათრევა გაუქმდა';
  @override
  String dragPickedUp(String item) => 'აღებულია: $item';
  @override
  String dragMovedUp(String item) => '$item გადაინაცვლა ზევით';
  @override
  String dragMovedDown(String item) => '$item გადაინაცვლა ქვევით';
  @override
  String get dragRowOne => 'მწკრივი ერთი';
  @override
  String get dragRowTwo => 'მწკრივი ორი';
  @override
  String get dragRowThree => 'მწკრივი სამი';

  // Network
  @override
  String get networkDemoTitle => 'Dev Scenario ინტერცეპტორის დემო';
  @override
  String get networkDemoBody =>
      'ამ მოთხოვნებს Dev Scenario იჭერს ამ აპლიკაციის კოდში ერთი `.addInterceptor(…)` '
      'ხაზის გარეშეც — ავტომატური დაკავშირების მოდული / SwiftPM swizzle ამას '
      'თქვენ მაგივრად აკეთებს.';
  @override
  String get networkAutoFiring => 'მიმდინარეობს საწყისი მოთხოვნის გაგზავნა…';
  @override
  String networkAutoFailed(String message) => 'ავტომოთხოვნა ვერ შესრულდა: $message';
  @override
  String networkAutoDone(int code, int durationMs) =>
      'ავტომოთხოვნა შესრულდა — $code, $durationMs მწმ-ში. იხილეთ Dev Scenario-ის ქსელის ჩანართი.';
  @override
  String get networkAutoLabel => 'ავტომატურად გაიგზავნა ეკრანზე შესვლისას';
  @override
  String get networkBtnGetPost => 'GET jsonplaceholder /posts/1';
  @override
  String get networkBtnPostBody => 'POST jsonplaceholder /posts';
  @override
  String get networkBtnHttpbin => 'GET httpbin.org/get';
  @override
  String get networkBtn404 => 'GET → 404 (შეცდომის გამოწვევა)';
}

/// Resolves the [SampleStrings] table for a [SampleLanguage]. Default English.
SampleStrings stringsFor(SampleLanguage language) =>
    language == SampleLanguage.georgian
        ? const KaStrings()
        : const EnStrings();
