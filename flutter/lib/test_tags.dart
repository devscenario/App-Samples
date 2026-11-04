/// Mirrors `compose-multiplatform/shared-ui/.../TestTags.kt` so flows and selectors are
/// identical across the Compose Multiplatform sample and this Flutter sample.
/// Attached to widgets as `ValueKey(...)` (the in-app SDK reads it as
/// resource-id / accessibility identifier).
class TestTags {
  static const appRoot = 'sample.app.root';
  static const homeGrid = 'sample.home.grid';
  static const navBack = 'BackButton';
  static const navTitle = 'sample.nav.title';

  // Language chooser (in the AppBar `actions`). Mirrors the CMP sample's
  // TestTags so flows/selectors stay identical across platforms.
  static const actionLanguage = 'sample.action.language';
  static const langEnglish = 'sample.lang.english';
  static const langGeorgian = 'sample.lang.georgian';

  static const tabLogin = 'sample.tab.login';
  static const tabRegistration = 'sample.tab.registration';
  static const tabList = 'sample.tab.list';
  static const tabGrid = 'sample.tab.grid';
  static const tabShowcase = 'sample.tab.showcase';
  static const tabSearch = 'sample.tab.search';
  static const tabCheckout = 'sample.tab.checkout';
  static const tabProfile = 'sample.tab.profile';
  static const tabPinch = 'sample.tab.pinch';
  static const tabModals = 'sample.tab.modals';
  static const tabDragDrop = 'sample.tab.dragdrop';
  static const tabNetwork = 'sample.tab.network';
  static const tabBackend = 'sample.tab.backend';

  static const loginEmail = 'sample.login.email';
  static const loginPassword = 'sample.login.password';
  static const loginRemember = 'sample.login.remember';
  static const loginButton = 'sample.login.submit';
  static const loginEmailPreview = 'sample.login.email.preview';
  static const loginPasswordPreview = 'sample.login.password.preview';
  static const loginStatus = 'sample.login.status';

  static const regName = 'sample.registration.name';
  static const regEmail = 'sample.registration.email';
  static const regPassword = 'sample.registration.password';
  static const regTerms = 'sample.registration.terms';
  static const regSubmit = 'sample.registration.submit';
  static const regNamePreview = 'sample.registration.name.preview';
  static const regEmailPreview = 'sample.registration.email.preview';
  static const regPasswordPreview = 'sample.registration.password.preview';
  static const regStatus = 'sample.registration.status';

  static const listContainer = 'sample.list.container';
  static const listDetail = 'sample.list.detail';
  static const gridContainer = 'sample.grid.container';
  static const gridDetail = 'sample.grid.detail';
  static const showcaseScroll = 'sample.showcase.scroll';
  static const showcaseSlider = 'sample.showcase.slider';
  static const showcaseSwitch = 'sample.showcase.switch';
  static const showcaseProgress = 'sample.showcase.progress';

  static const searchQuery = 'sample.search.query';
  static const searchQueryPreview = 'sample.search.query.preview';
  static const searchSubmit = 'sample.search.submit';
  static const searchStatus = 'sample.search.status';
  static const searchResults = 'sample.search.results';

  static const checkoutAddress = 'sample.checkout.address';
  static const checkoutAddressPreview = 'sample.checkout.address.preview';
  static const checkoutDelivery = 'sample.checkout.delivery';
  static const checkoutPayment = 'sample.checkout.payment';
  static const checkoutPlaceOrder = 'sample.checkout.place.order';
  static const checkoutStatus = 'sample.checkout.status';

  static const profileName = 'sample.profile.name';
  static const profileNamePreview = 'sample.profile.name.preview';
  static const profilePhone = 'sample.profile.phone';
  static const profilePhonePreview = 'sample.profile.phone.preview';
  static const profileMarketing = 'sample.profile.marketing';
  static const profileSave = 'sample.profile.save';
  static const profileStatus = 'sample.profile.status';

  static const pinchPlayground = 'sample.pinch.playground';
  static const pinchTarget = 'sample.pinch.target';
  static const pinchStatus = 'sample.pinch.status';

  static const modalsStatus = 'sample.modals.status';
  static const modalsOpenPartialSheet = 'sample.modals.sheet.partial';
  static const modalsOpenFullSheet = 'sample.modals.sheet.full';
  static const modalsSheet = 'sample.modals.sheet';
  static const modalsSheetHide = 'sample.modals.sheet.hide';
  static const modalsOpenAlertDialog = 'sample.modals.dialog.alert';
  static const modalsAlertConfirm = 'sample.modals.dialog.alert.confirm';
  static const modalsAlertDismiss = 'sample.modals.dialog.alert.dismiss';
  static const modalsOpenFullscreenDialog = 'sample.modals.dialog.fullscreen';
  static const modalsFullscreenDialog =
      'sample.modals.dialog.fullscreen.content';
  static const modalsFullscreenClose = 'sample.modals.dialog.fullscreen.close';
  static const modalsOpenVerifySheet = 'sample.modals.verify.open';
  static const modalsVerifySheet = 'sample.modals.verify.sheet';
  static const modalsVerifyCode = 'sample.modals.verify.code';
  static const modalsVerifySubmit = 'sample.modals.verify.submit';

  static const dragStatus = 'sample.dragdrop.status';
  static const dragDropTarget = 'sample.dragdrop.target';
  static const dragItemAlpha = 'sample.dragdrop.item.alpha';
  static const dragItemBeta = 'sample.dragdrop.item.beta';
  static const dragItemGamma = 'sample.dragdrop.item.gamma';
  static const dragReorderItemPrefix = 'sample.dragdrop.reorder.';

  static const networkAutoStatus = 'sample.network.auto.status';
  static const networkResults = 'sample.network.results';
  static const networkBtnGetPost = 'sample.network.button.getPost';
  static const networkBtnPostBody = 'sample.network.button.postBody';
  static const networkBtnHttpbin = 'sample.network.button.httpbin';
  static const networkBtn404 = 'sample.network.button.404';

  // Backend screen: signs in against test-backend and follows an
  // order.
  static const backendUrl = 'sample.backend.url';
  static const backendUsername = 'sample.backend.username';
  static const backendPassword = 'sample.backend.password';
  static const backendSignIn = 'sample.backend.signin';
  static const backendStatus = 'sample.backend.status';
  static const backendSubmit = 'sample.backend.submit';
  static const backendRefresh = 'sample.backend.refresh';
  static const backendOrder = 'sample.backend.order';
}
