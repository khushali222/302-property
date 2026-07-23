import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:three_zero_two_property/constant/constant.dart';

/// Which secure-field set the widget renders: [card] (ccnumber/ccexp/cvv) or
/// [ach] bank fields (checkname/checkaba/checkaccount). Defaults to [card] so
/// every existing card call site is completely unchanged.
enum CollectJsMode { card, ach }

/// Result of a successful Collect.js tokenization. Contains **no raw PAN /
/// full account number** — only the token and non-sensitive metadata (the
/// account number arrives already masked, exactly like the card number does).
class CardToken {
  final String token; // payment_token
  final String? bin; // cc_bin (first 6)
  final String? exp; // MMYY
  final String? type; // visa / mastercard / amex …
  // ACH mode only (null for cards): masked values from the Collect.js response,
  // mirroring what the web AddACHForm sends alongside the token.
  final String? accountNumber; // masked bank account
  final String? routingNumber; // routing number (ABA)
  final String? accountName; // account holder name
  const CardToken({
    required this.token,
    this.bin,
    this.exp,
    this.type,
    this.accountNumber,
    this.routingNumber,
    this.accountName,
  });
}

/// Imperative handle so the host screen's own Save button can trigger
/// tokenization: `controller.tokenize()`. `isReady` gates the button until
/// the secure fields have rendered.
class CollectJsController {
  _CollectJsCardFieldState? _s;
  void _bind(_CollectJsCardFieldState s) => _s = s;
  void _unbind(_CollectJsCardFieldState s) {
    if (_s == s) _s = null;
  }

  bool get isReady => _s?._ready ?? false;
  void tokenize() => _s?._tokenize();
}

/// Reusable PCI-safe card entry.
///
/// Renders NMI Collect.js secure fields inside a WebView and returns a
/// `payment_token` via [onToken]. The card number is typed inside NMI's own
/// iframes and **never reaches Dart or our server**.
///
/// [publicKey] may be `null` at first (while the host screen fetches it from
/// `GET /api/tenant/nmi_public_key(_by_admin)`); the widget shows a stable,
/// fixed-height "loading" state and starts the WebView the moment the key
/// arrives — so the card area never jumps or pops in late.
class CollectJsCardField extends StatefulWidget {
  final String? publicKey;
  final CollectJsController controller;
  final void Function(CardToken token) onToken;
  final VoidCallback? onReady;
  final void Function(String message)? onError;
  final void Function(String field, bool valid, String message)? onValidation;

  /// Origin the page is served from — some tokenization keys are
  /// domain-restricted, so this defaults to the CRM host.
  final String? baseUrl;

  /// Widget height. Card needs ~172; ACH stacks 3 fields so pass ~236.
  final double height;
  final String scriptUrl;

  /// Card fields (default) or ACH bank fields. ACH is additive — any card
  /// call site that omits this renders exactly as before.
  final CollectJsMode mode;

  const CollectJsCardField({
    super.key,
    required this.publicKey,
    required this.controller,
    required this.onToken,
    this.onReady,
    this.onError,
    this.onValidation,
    this.baseUrl,
    this.height = 172,
    this.scriptUrl = 'https://hms.transactiongateway.com/token/Collect.js',
    this.mode = CollectJsMode.card,
  });

  @override
  State<CollectJsCardField> createState() => _CollectJsCardFieldState();
}

class _CollectJsCardFieldState extends State<CollectJsCardField> {
  WebViewController? _web;
  bool _ready = false;
  String? _error;
  Timer? _loadTimer;

  @override
  void initState() {
    super.initState();
    widget.controller._bind(this);
    if (widget.publicKey != null && widget.publicKey!.isNotEmpty) {
      _buildController();
    }
    // Safety net: if the key never arrives (no NMI gateway configured, or a
    // failed fetch) or Collect.js never loads, surface an error instead of an
    // endless "Loading…" state.
    _loadTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !_ready && _error == null) {
        setState(() => _error =
            "Couldn't load the secure card fields. Check your connection or "
            "payment setup and try again.");
        widget.onError?.call(_error!);
      }
    });
  }

  @override
  void didUpdateWidget(CollectJsCardField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Key arrived after the first build → start the WebView now.
    if (_web == null &&
        widget.publicKey != null &&
        widget.publicKey!.isNotEmpty) {
      _buildController();
    }
  }

  void _buildController() {
    // Key just arrived — restart the safety timer so Collect.js gets a full
    // 15s to load (not whatever was left over from the key fetch).
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !_ready && _error == null) {
        setState(() => _error =
            "Couldn't load the secure card fields. Check your connection or "
            "payment setup and try again.");
        widget.onError?.call(_error!);
      }
    });
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..addJavaScriptChannel('CJ', onMessageReceived: _onMessage)
      ..loadHtmlString(widget.mode == CollectJsMode.ach ? _achHtml : _html,
          baseUrl: widget.baseUrl ?? Api_url);
    setState(() {});
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    widget.controller._unbind(this);
    super.dispose();
  }

  void _tokenize() {
    if (_ready) _web?.runJavaScript('window.tokenize()');
  }

  void _onMessage(JavaScriptMessage m) {
    Map<String, dynamic> d;
    try {
      d = jsonDecode(m.message) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    switch (d['status']) {
      case 'fields_available':
        _loadTimer?.cancel();
        if (mounted) {
          setState(() {
            _ready = true;
            _error = null; // clear a stale timeout error so the overlay lifts
          });
        }
        widget.onReady?.call();
        break;
      case 'validation':
        widget.onValidation
            ?.call('${d['field']}', d['valid'] == true, '${d['message'] ?? ''}');
        break;
      case 'token':
        final t = d['token'] as String?;
        if (t == null || t.isEmpty) {
          widget.onError?.call('Tokenization returned no token.');
        } else {
          widget.onToken(CardToken(
            token: t,
            bin: d['bin'] as String?,
            exp: d['exp'] as String?,
            type: d['type'] as String?,
            accountNumber: d['account'] as String?,
            routingNumber: d['aba'] as String?,
            accountName: d['name'] as String?,
          ));
        }
        break;
      case 'script_error':
        if (mounted) {
          setState(() => _error = 'Could not load the secure payment fields.');
        }
        widget.onError?.call('Could not load the secure payment fields.');
        break;
      case 'timeout':
        if (mounted) {
          setState(() =>
              _error = 'Payment fields did not initialise. Please try again.');
        }
        widget.onError
            ?.call('Payment fields did not initialise. Please try again.');
        break;
      case 'error':
      case 'js_error':
        widget.onError?.call('${d['message'] ?? 'Payment field error.'}');
        break;
    }
  }

  // Collect.js styles the inputs INSIDE its iframes via customCss, so the
  // host divs carry no border (avoids a double-box).
  String get _html => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
  <script src="${widget.scriptUrl}" data-tokenization-key="${widget.publicKey}"
          data-theme="material"
          onload="post({status:'script_loaded'})"
          onerror="post({status:'script_error'})"></script>
  <style>
    body { margin:0; padding:0; font-family:-apple-system,Roboto,sans-serif; background:#fff; -webkit-tap-highlight-color:transparent; }
    * { -webkit-tap-highlight-color:rgba(0,0,0,0) !important; }
    iframe, .fld iframe, .fld { -webkit-tap-highlight-color:rgba(0,0,0,0) !important; -webkit-user-select:none; }
    .label { font-size:13px; font-weight:500; color:#A6ACB4; margin:6px 0 4px; }
    .fld { height:44px; }
    .row { display:flex; gap:12px; margin-top:14px; }
    .row > div { flex:1; }
  </style>
</head>
<body>
  <div class="label">Card Number *</div>
  <div id="ccnumber" class="fld"></div>
  <div class="row">
    <div><div class="label">Expiration Date *</div><div id="ccexp" class="fld"></div></div>
    <div><div class="label">CVV *</div><div id="cvv" class="fld"></div></div>
  </div>
  <script>
    function post(m){ try { window.CJ.postMessage(JSON.stringify(m)); } catch(e){} }
    window.addEventListener('error', function(e){ post({status:'js_error', message:(e.message||'window error')}); });
    var tries = 0;
    function waitForCollectJS(){
      if (typeof CollectJS !== 'undefined') {
        try {
          CollectJS.configure({
            variant:'inline',
            // Match the app's native CustomTextField look: white, radius 8,
            // light border + soft shadow (like elevation 2), navy on focus.
            customCss: { 'border':'1px solid #E0E0E0', 'border-radius':'8px', 'padding':'0 14px', 'height':'46px', 'font-size':'15px', 'color':'#1F2937', 'background-color':'#FFFFFF', 'box-shadow':'none', 'outline':'none', '-webkit-tap-highlight-color':'transparent', 'box-sizing':'border-box' },
            focusCss: { 'border-color':'#E0E0E0', 'box-shadow':'none', 'background-color':'#FFFFFF', '-webkit-tap-highlight-color':'transparent', 'outline':'none' },
            invalidCss: { 'color':'#B40E3E', 'border-color':'#F04438' },
            validCss: { 'color':'#1F2937', 'border-color':'#E0E0E0' },
            placeholderCss: { 'color':'#b0b6c3' },
            fields: {
              ccnumber: { selector:'#ccnumber', placeholder:'0000 0000 0000 0000' },
              ccexp:    { selector:'#ccexp',    placeholder:'MM / YY' },
              cvv:      { selector:'#cvv',      placeholder:'CVV' }
            },
            fieldsAvailableCallback: function(){ post({status:'fields_available'}); },
            validationCallback: function(field, valid, message){ post({status:'validation', field:field, valid:valid, message:message}); },
            callback: function(resp){
              post({ status:'token', token: resp && resp.token,
                     bin: resp&&resp.card?resp.card.bin:null,
                     exp: resp&&resp.card?resp.card.exp:null,
                     type: resp&&resp.card?resp.card.type:null });
            }
          });
        } catch(e){ post({status:'error', message:'configure: '+e.message}); }
      } else if (tries++ < 50) { setTimeout(waitForCollectJS, 200); }
      else { post({status:'timeout'}); }
    }
    document.addEventListener('DOMContentLoaded', function(){ setTimeout(waitForCollectJS, 300); });
    window.tokenize = function(){
      try { if (window.CollectJS) { CollectJS.startPaymentRequest(); } else { post({status:'error', message:'CollectJS not loaded'}); } }
      catch(e){ post({status:'error', message:'tokenize: '+e.message}); }
    };
  </script>
</body>
</html>
''';

  // ACH bank fields (checkname / checkaba / checkaccount). Same Collect.js
  // setup, styling and JS bridge as the card HTML above — only the three fields
  // and the token callback (reads resp.check instead of resp.card) differ.
  String get _achHtml => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
  <script src="${widget.scriptUrl}" data-tokenization-key="${widget.publicKey}"
          data-theme="material"
          onload="post({status:'script_loaded'})"
          onerror="post({status:'script_error'})"></script>
  <style>
    body { margin:0; padding:0; font-family:-apple-system,Roboto,sans-serif; background:#fff; -webkit-tap-highlight-color:transparent; }
    * { -webkit-tap-highlight-color:rgba(0,0,0,0) !important; }
    iframe, .fld iframe, .fld { -webkit-tap-highlight-color:rgba(0,0,0,0) !important; -webkit-user-select:none; }
    .label { font-size:13px; font-weight:500; color:#A6ACB4; margin:6px 0 4px; }
    .fld { height:44px; }
    .stack { margin-top:14px; }
  </style>
</head>
<body>
  <div class="label">Account Holder Name *</div>
  <div id="checkname" class="fld"></div>
  <div class="label stack">Routing Number *</div>
  <div id="checkaba" class="fld"></div>
  <div class="label stack">Account Number *</div>
  <div id="checkaccount" class="fld"></div>
  <script>
    function post(m){ try { window.CJ.postMessage(JSON.stringify(m)); } catch(e){} }
    window.addEventListener('error', function(e){ post({status:'js_error', message:(e.message||'window error')}); });
    var tries = 0;
    function waitForCollectJS(){
      if (typeof CollectJS !== 'undefined') {
        try {
          CollectJS.configure({
            variant:'inline',
            customCss: { 'border':'1px solid #E0E0E0', 'border-radius':'8px', 'padding':'0 14px', 'height':'46px', 'font-size':'15px', 'color':'#1F2937', 'background-color':'#FFFFFF', 'box-shadow':'none', 'outline':'none', '-webkit-tap-highlight-color':'transparent', 'box-sizing':'border-box' },
            focusCss: { 'border-color':'#E0E0E0', 'box-shadow':'none', 'background-color':'#FFFFFF', '-webkit-tap-highlight-color':'transparent', 'outline':'none' },
            invalidCss: { 'color':'#B40E3E', 'border-color':'#F04438' },
            validCss: { 'color':'#1F2937', 'border-color':'#E0E0E0' },
            placeholderCss: { 'color':'#b0b6c3' },
            fields: {
              checkname:    { selector:'#checkname',    placeholder:'Account Holder Name' },
              checkaba:     { selector:'#checkaba',     placeholder:'Routing Number' },
              checkaccount: { selector:'#checkaccount', placeholder:'Account Number' }
            },
            fieldsAvailableCallback: function(){ post({status:'fields_available'}); },
            validationCallback: function(field, valid, message){ post({status:'validation', field:field, valid:valid, message:message}); },
            callback: function(resp){
              var chk = (resp && resp.check) ? resp.check : {};
              post({ status:'token', token: resp && resp.token,
                     account: (chk.account || (resp && resp.checkaccount) || null),
                     aba:     (chk.aba     || (resp && resp.checkaba)     || null),
                     name:    (chk.name    || (resp && resp.checkname)    || null) });
            }
          });
        } catch(e){ post({status:'error', message:'configure: '+e.message}); }
      } else if (tries++ < 50) { setTimeout(waitForCollectJS, 200); }
      else { post({status:'timeout'}); }
    }
    document.addEventListener('DOMContentLoaded', function(){ setTimeout(waitForCollectJS, 300); });
    window.tokenize = function(){
      try { if (window.CollectJS) { CollectJS.startPaymentRequest(); } else { post({status:'error', message:'CollectJS not loaded'}); } }
      catch(e){ post({status:'error', message:'tokenize: '+e.message}); }
    };
  </script>
</body>
</html>
''';

  Widget _loadingOverlay() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error == null) ...[
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 10),
            Text(
                widget.mode == CollectJsMode.ach
                    ? 'Loading secure bank fields…'
                    : 'Loading secure card fields…',
                style: const TextStyle(fontSize: 12, color: Color(0xFF5F5E5A))),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFB40E3E))),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fixed height at all times → the card area never jumps or pops in late.
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        children: [
          if (_web != null)
            Positioned.fill(child: WebViewWidget(controller: _web!)),
          // Overlay covers the WebView until the secure fields are ready
          // (or if the key hasn't arrived yet), then disappears in place.
          if (!_ready || _error != null)
            Positioned.fill(child: _loadingOverlay()),
        ],
      ),
    );
  }
}
