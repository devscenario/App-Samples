import SwiftUI
import WebKit

/// A native label above a WKWebView hosting `sampleWebPage`. Parity with the shared-ui `WebViewScreen`:
/// exercises drivers inside web content (inputs, buttons, a checkbox, a link, scrolling) and hybrid checks —
/// the page reports each action through the `DevtoolSample` script message handler, and the native label
/// shows the last one.
struct WebViewScreen: View {
    @ObservedObject private var store = LanguageStore.shared
    @State private var lastEvent: String?

    private var strings: SampleStrings { store.strings }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(strings.webLastEvent(lastEvent ?? strings.webNoEvent))
                .font(.subheadline)
                .accessibilityIdentifier(TestTags.webViewEvent)
            SampleWebView(html: sampleWebPage, baseURL: sampleWebBaseURL) { lastEvent = $0 }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

/// `WKWebView` with the `DevtoolSample` bridge. A `UIViewRepresentable`, so the web view (and the page's
/// accessibility tree) sits in the native hierarchy where XCUITest can reach it.
private struct SampleWebView: UIViewRepresentable {
    let html: String
    let baseURL: URL?
    let onEvent: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onEvent: onEvent) }

    func makeUIView(context: Context) -> WKWebView {
        let controller = WKUserContentController()
        // Weak proxy: the content controller retains its handlers strongly.
        controller.add(WeakMessageHandler(context.coordinator), name: "DevtoolSample")
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.accessibilityIdentifier = TestTags.webViewPage
        webView.loadHTMLString(html, baseURL: baseURL)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.onEvent = onEvent
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "DevtoolSample")
    }

    final class Coordinator: NSObject, WKScriptMessageHandler {
        var onEvent: (String) -> Void

        init(onEvent: @escaping (String) -> Void) { self.onEvent = onEvent }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            if let event = message.body as? String { onEvent(event) }
        }
    }
}

private final class WeakMessageHandler: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?

    init(_ target: WKScriptMessageHandler) { self.target = target }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        target?.userContentController(userContentController, didReceive: message)
    }
}

/// Base URL the page is loaded under, so `#terms` navigation and history behave like a real site.
/// Must match `SAMPLE_WEB_BASE_URL` in shared-ui `WebViewPage.kt`.
private let sampleWebBaseURL = URL(string: "https://sample.devtool.local/checkout")

/// The page the WebView screen hosts. MUST stay identical to `SAMPLE_WEB_PAGE` in
/// `compose-multiplatform/shared-ui/src/commonMain/kotlin/ge/devtool/samples/ui/WebViewPage.kt` — flows written for
/// either sample app rely on the same page contents.
private let sampleWebPage = #"""
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Web checkout</title>
<style>
  body { font-family: -apple-system, Roboto, sans-serif; margin: 0; padding: 16px; color: #1b1b1b; background: #fbfaf7; }
  h1 { font-size: 22px; margin: 4px 0 12px; }
  label { display: block; font-size: 14px; margin: 12px 0 4px; }
  input[type=text], input[type=email] { width: 100%; box-sizing: border-box; font-size: 16px; padding: 10px; border: 1px solid #bbb; border-radius: 8px; }
  button { font-size: 16px; padding: 10px 16px; margin-top: 12px; border: 0; border-radius: 8px; background: #3a55e0; color: #fff; }
  button:disabled { background: #b8bfe6; }
  .row { display: flex; align-items: center; gap: 8px; margin-top: 14px; font-size: 15px; }
  .msg { margin-top: 10px; font-size: 15px; min-height: 20px; }
  li { padding: 10px 0; border-bottom: 1px solid #e6e2da; }
  a { color: #3a55e0; }
  section[hidden] { display: none; }
</style>
</head>
<body>
<section id="checkout">
  <h1>Web checkout</h1>
  <label for="email">Email</label>
  <input id="email" type="email" placeholder="you@example.com" aria-label="Email">
  <label for="promo">Promo code</label>
  <input id="promo" type="text" placeholder="Promo code" aria-label="Promo code">
  <button id="apply" type="button">Apply code</button>
  <div class="msg" id="promo-msg" role="status"></div>
  <div class="row"><input id="agree" type="checkbox" aria-label="I agree to the terms"><label for="agree" style="margin:0">I agree to the terms</label></div>
  <button id="pay" type="button" disabled>Pay now</button>
  <div class="msg" id="pay-msg" role="status"></div>
  <p><a href="#terms" id="terms-link">Terms</a></p>
  <h2 style="font-size:17px">Your order</h2>
  <ul id="items"></ul>
  <p id="footer">Footer reached</p>
</section>
<section id="terms" hidden>
  <h1>Terms of service</h1>
  <p>Orders placed in this sample are not real.</p>
  <p><a href="#checkout" id="back-link">Back to checkout</a></p>
</section>
<script>
  function post(event) {
    try { if (window.DevtoolSample) DevtoolSample.postMessage(event); } catch (e) {}
    try { window.webkit.messageHandlers.DevtoolSample.postMessage(event); } catch (e) {}
  }
  var items = document.getElementById('items');
  for (var i = 1; i <= 20; i++) { var li = document.createElement('li'); li.textContent = 'Order item ' + i; items.appendChild(li); }
  document.getElementById('apply').onclick = function () {
    var code = document.getElementById('promo').value.trim().toUpperCase();
    var msg = code === 'SPRING10' ? 'Code SPRING10 applied' : (code ? 'Unknown code ' + code : 'Enter a code');
    document.getElementById('promo-msg').textContent = msg;
    post(msg);
  };
  var agree = document.getElementById('agree');
  agree.onchange = function () { document.getElementById('pay').disabled = !agree.checked; post(agree.checked ? 'terms accepted' : 'terms declined'); };
  document.getElementById('pay').onclick = function () {
    var email = document.getElementById('email').value.trim();
    var text = email ? 'Payment confirmed for ' + email : 'Payment confirmed';
    document.getElementById('pay-msg').textContent = text;
    post('payment confirmed');
  };
  function route() {
    var terms = location.hash === '#terms';
    document.getElementById('checkout').hidden = terms;
    document.getElementById('terms').hidden = !terms;
    post(terms ? 'opened terms' : 'opened checkout');
  }
  window.addEventListener('hashchange', route);
  post('page loaded');
</script>
</body>
</html>
"""#
