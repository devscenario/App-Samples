package ge.devtool.samples.ui

/**
 * The page the WebView screen hosts, identical on every sample app (the SwiftUI app keeps a copy in
 * `WebViewScreen.swift`). A small "web checkout" that exercises what E2E drivers need inside a WebView:
 * text inputs, buttons that change text, a checkbox that enables a button, a link to a second page and
 * a long list to scroll. Every action is also posted to the native side through the `DevtoolSample`
 * bridge, which shows it in a native label above the WebView.
 */
internal const val SAMPLE_WEB_PAGE: String = """<!doctype html>
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
</html>"""

/** Base URL the page is loaded under, so `#terms` navigation and history behave like a real site. */
internal const val SAMPLE_WEB_BASE_URL: String = "https://sample.devtool.local/checkout"
