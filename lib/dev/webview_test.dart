// ─────────────────────────────────────────────────────────────────────────
// PHASE 5 — full tokenize + SAVE test (THROWAWAY / DEV ONLY)
//
// Proves the whole card-add loop end to end:
//   read adminId+token from prefs -> fetch NMI key -> Collect.js renders
//   secure fields -> tokenize -> POST payment_token to add-tenant-payment
//   -> card saved in the vault (HTTP 200). Raw PAN never touches Dart.
//
// ⚠️ REAL SIDE EFFECTS on the configured server (staging): a successful save
// creates a customer-vault entry for the tenant AND emails a "Welcome to Your
// Customer Vault" message to the `email` you enter. Use a THROWAWAY test
// tenant_id and YOUR OWN email.
//
// Standalone entry — touches NO production screen. Delete before shipping.
// Run:  flutter run -t lib/dev/webview_test.dart -d <deviceId>
// ─────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/services/api_helpers.dart';

void main() => runApp(const CollectJsTestApp());

class CollectJsTestApp extends StatelessWidget {
  const CollectJsTestApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Collect.js Test',
        home: CollectJsTestScreen(),
      );
}

class CollectJsTestScreen extends StatefulWidget {
  const CollectJsTestScreen({super.key});
  @override
  State<CollectJsTestScreen> createState() => _CollectJsTestScreenState();
}

class _CollectJsTestScreenState extends State<CollectJsTestScreen> {
  WebViewController? _controller;
  String _status = 'Starting…';
  final List<String> _log = [];
  bool _fieldsReady = false;
  bool _busy = false;
  bool _loadingTenant = false;

  // From the logged-in session (SharedPreferences, shared via bundle id).
  String? _adminId;
  String? _authToken;

  // Test billing inputs (entered at runtime — nothing hardcoded).
  final _tenantId = TextEditingController();
  final _firstName = TextEditingController(text: 'Test');
  final _lastName = TextEditingController(text: 'Card');
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _tenantId.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      _set('Reading session (adminId/token) from prefs…');
      final prefs = await SharedPreferences.getInstance();
      _adminId = prefs.getString('adminId') ?? prefs.getString('staff_id');
      _authToken = prefs.getString('token');
      if (_adminId == null || _adminId!.isEmpty) {
        _set('No adminId in prefs — log into the real CRM app first.');
        return;
      }
      _add('adminId found (…${_tail(_adminId!)}), token ${_authToken != null ? "present" : "MISSING"}');

      _set('Fetching tokenization key…');
      final res = await apiGet(
          Uri.parse('$Api_url/api/tenant/nmi_public_key_by_admin/$_adminId'));
      if (res.statusCode != 200) {
        _set('Key fetch failed: HTTP ${res.statusCode}');
        return;
      }
      final publicKey = (jsonDecode(res.body) as Map<String, dynamic>)['publicKey'];
      if (publicKey == null || (publicKey as String).isEmpty) {
        _set('publicKey null — no NMI key for this admin (guard works ✅).');
        return;
      }
      _add('Key received: ${publicKey.length} chars (masked)');
      _set('Loading Collect.js…');

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFFFFFF))
        ..addJavaScriptChannel('CJ', onMessageReceived: _onJs)
        ..setNavigationDelegate(NavigationDelegate(
          onWebResourceError: (e) => _add('web error: ${e.description}'),
        ))
        ..loadHtmlString(_html(publicKey), baseUrl: Api_url);
      setState(() => _controller = controller);
    } catch (e) {
      _set('Error: $e');
    }
  }

  void _onJs(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final s = data['status'] as String?;
      final m = data['message'];
      if (kDebugMode) debugPrint('CJ status: $s ${m ?? ''}');
      switch (s) {
        case 'script_loaded':
          _add('script_loaded');
          break;
        case 'collectjs_configured':
          _add('collectjs_configured ✅');
          break;
        case 'fields_available':
          setState(() => _fieldsReady = true);
          _set('Card fields rendered ✅ — fill the form + card, tap Save');
          break;
        case 'validation':
          _add('validation: ${data['field']} '
              '${data['valid'] == true ? 'valid ✅' : 'invalid — ${data['message']}'}');
          break;
        case 'script_error':
          _set('Collect.js SCRIPT failed to load ❌');
          break;
        case 'timeout':
          _set('Collect.js never initialised ❌');
          break;
        case 'error':
        case 'js_error':
          setState(() => _busy = false);
          _set('Collect.js error ❌ — ${m ?? "see log"}');
          break;
        case 'token':
          final token = data['token'] as String?;
          if (token == null || token.isEmpty) {
            setState(() => _busy = false);
            _set('Callback fired but NO token ❌');
          } else {
            _add('token ✅ (${token.length} chars) · card ${data['masked']} · '
                '${data['type']} · bin ${data['bin']} · exp ${data['exp']}');
            _saveCard(token, data['bin'] as String?); // PHASE 5: POST it
          }
          break;
      }
    } catch (_) {
      _add('JS(raw): ${message.message}');
    }
  }

  // PHASE 5 — send ONLY the token (+ bin + billing) to our server.
  Future<void> _saveCard(String paymentToken, String? ccBin) async {
    _set('Saving card (POST add-tenant-payment)…');
    try {
      final body = jsonEncode({
        'payment_token': paymentToken, // NOT the card number
        'cc_bin': ccBin,
        'first_name': _firstName.text.trim(),
        'last_name': _lastName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'admin_id': _adminId,
        'tenant_id': _tenantId.text.trim(),
      });
      // Role-aware id header: Staff sends its OWN id; Admin sends adminId.
      // (verifyToken 401s "user not active" when the id doesn't match the
      // token's user.) The BODY admin_id stays the company adminId.
      final prefs = await SharedPreferences.getInstance();
      final headerId =
          prefs.getString('staff_id') ?? prefs.getString('adminId') ?? '';
      _add('POST id-header …${_tail(headerId)} · body admin_id …${_tail(_adminId ?? '')}');
      final res = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/tenant/add-tenant-payment'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'CRM $_authToken',
          'id': 'CRM $headerId',
        },
        body: body,
      );
      setState(() => _busy = false);
      Map<String, dynamic>? json;
      try {
        json = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}
      if (res.statusCode == 200) {
        _set('CARD SAVED ✅ (HTTP 200) — ${json?['data'] ?? res.body} — Phase 5 passed');
      } else {
        _set('Save failed (HTTP ${res.statusCode}): '
            '${json?['error'] ?? json?['data'] ?? res.body}');
      }
    } catch (e) {
      setState(() => _busy = false);
      _set('Save error: $e');
    }
  }

  void _onSavePressed() {
    if (_tenantId.text.trim().isEmpty ||
        _firstName.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _phone.text.trim().isEmpty) {
      _set('Fill tenant_id, first name, email, and phone first.');
      return;
    }
    setState(() => _busy = true);
    _set('Tokenizing…');
    _controller?.runJavaScript('window.tokenize()');
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _busy) {
        setState(() => _busy = false);
        _add('no token after 12s — check validation lines / retry');
      }
    });
  }

  // Pull a current tenant from THIS company so we have a valid tenant_id.
  // The id is written to the on-screen field only — never logged/printed.
  Future<void> _loadTenant() async {
    if (_adminId == null) return;
    setState(() => _loadingTenant = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final headerId =
          prefs.getString('staff_id') ?? prefs.getString('adminId') ?? '';
      final uri = Uri.parse('$Api_url/api/tenant/tenants/v2/$_adminId').replace(
        queryParameters: {
          'page': '1',
          'limit': '10',
          'search': '',
          'tenantType': 'current',
          'sortBy': 'createdAt',
          'sortOrder': 'desc',
        },
      );
      final res = await apiGet(uri,
          headers: {'authorization': 'CRM $token', 'id': 'CRM $headerId'});
      if (res.statusCode != 200) {
        _add('tenant list failed: HTTP ${res.statusCode}');
        return;
      }
      final tid = _findTenantId(jsonDecode(res.body));
      if (tid == null) {
        _add('no current tenant found for this company');
        return;
      }
      setState(() => _tenantId.text = tid); // shown on screen only
      _add('Loaded a current tenant into the field ✅ (id on screen)');
    } catch (e) {
      _add('load tenant error: $e');
    } finally {
      setState(() => _loadingTenant = false);
    }
  }

  // Structure-agnostic: first non-empty tenant_id anywhere in the response.
  String? _findTenantId(dynamic node) {
    if (node is Map) {
      final v = node['tenant_id'];
      if (v is String && v.isNotEmpty) return v;
      if (v is num) return v.toString();
      for (final val in node.values) {
        final f = _findTenantId(val);
        if (f != null) return f;
      }
    } else if (node is List) {
      for (final item in node) {
        final f = _findTenantId(item);
        if (f != null) return f;
      }
    }
    return null;
  }

  String _html(String key) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
  <script src="https://hms.transactiongateway.com/token/Collect.js"
          data-tokenization-key="$key" data-theme="material"
          onload="post({status:'script_loaded'})"
          onerror="post({status:'script_error'})"></script>
  <style>
    body { margin:0; padding:12px 16px; font-family:-apple-system,Roboto,sans-serif; background:#fff; color:#063164; }
    .label { font-size:12px; font-weight:600; color:#5F5E5A; margin:8px 0 4px; }
    .field { border:1px solid #063164; border-radius:8px; height:42px; }
    .row { display:flex; gap:12px; }
    .row > div { flex:1; }
  </style>
</head>
<body>
  <div class="label">Card Number *</div>
  <div id="ccnumber" class="field"></div>
  <div class="row">
    <div><div class="label">Expiration *</div><div id="ccexp" class="field"></div></div>
    <div><div class="label">CVV *</div><div id="cvv" class="field"></div></div>
  </div>
  <script>
    function post(m){ try { window.CJ.postMessage(JSON.stringify(m)); } catch(e){} }
    window.addEventListener('error', function(e){ post({status:'js_error', message:(e.message||'window error')}); });
    var tries = 0;
    function waitForCollectJS(){
      if (typeof CollectJS !== 'undefined') {
        try {
          CollectJS.configure({
            variant: 'inline',
            fields: {
              ccnumber: { selector:'#ccnumber', placeholder:'Card Number' },
              ccexp:    { selector:'#ccexp',    placeholder:'MM / YY' },
              cvv:      { selector:'#cvv',      placeholder:'CVV' }
            },
            fieldsAvailableCallback: function(){ post({status:'fields_available'}); },
            validationCallback: function(field, valid, message){ post({status:'validation', field:field, valid:valid, message:message}); },
            callback: function(resp){
              post({ status:'token', token: resp && resp.token,
                     bin: resp&&resp.card?resp.card.bin:null,
                     exp: resp&&resp.card?resp.card.exp:null,
                     type: resp&&resp.card?resp.card.type:null,
                     masked: resp&&resp.card?resp.card.number:null });
            }
          });
          post({status:'collectjs_configured'});
        } catch(e){ post({status:'error', message:'configure: '+e.message}); }
      } else if (tries++ < 50) { setTimeout(waitForCollectJS, 200); }
      else { post({status:'timeout'}); }
    }
    document.addEventListener('DOMContentLoaded', function(){ post({status:'dom_ready'}); setTimeout(waitForCollectJS, 300); });
    window.tokenize = function(){
      try { if (window.CollectJS) { CollectJS.startPaymentRequest(); } else { post({status:'error', message:'CollectJS not loaded'}); } }
      catch(e){ post({status:'error', message:'tokenize: '+e.message}); }
    };
  </script>
</body>
</html>
''';

  void _set(String s) {
    if (kDebugMode) debugPrint('[P5] $s');
    setState(() {
      _status = s;
      _log.insert(0, s);
    });
  }

  void _add(String s) {
    if (kDebugMode) debugPrint('[P5] $s');
    setState(() => _log.insert(0, s));
  }

  String _tail(String s) => s.length <= 4 ? s : s.substring(s.length - 4);

  Widget _tf(TextEditingController c, String hint, {TextInputType? kb}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: TextField(
          controller: c,
          keyboardType: kb,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView Test — Phase 5 (Save)'),
        backgroundColor: const Color(0xFF063164),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFE6F1FB),
            padding: const EdgeInsets.all(10),
            child: Text('Status: $_status',
                style: const TextStyle(fontSize: 13, color: Color(0xFF063164), height: 1.4)),
          ),
          // Test billing inputs (use a throwaway tenant + YOUR email).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                      child: _tf(_tenantId,
                          'tenant_id (throwaway — will vault + email)')),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed:
                        (_loadingTenant || _adminId == null) ? null : _loadTenant,
                    child: Text(_loadingTenant ? '…' : 'Load'),
                  ),
                ]),
                Row(children: [
                  Expanded(child: _tf(_firstName, 'first name')),
                  const SizedBox(width: 8),
                  Expanded(child: _tf(_phone, 'phone (10 digits)', kb: TextInputType.phone)),
                ]),
                _tf(_email, 'email (gets the welcome msg — use yours)', kb: TextInputType.emailAddress),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _controller == null
                ? const Center(child: CircularProgressIndicator())
                : WebViewWidget(controller: _controller!),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF063164),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: (_fieldsReady && !_busy) ? _onSavePressed : null,
              child: Text(_busy
                  ? 'Working…'
                  : _fieldsReady
                      ? 'Tokenize & Save Card (test)'
                      : 'Waiting for card fields…'),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF5F6FA),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListView(
                children: [
                  const Text('Event log (newest first):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5F5E5A))),
                  const SizedBox(height: 4),
                  ..._log.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('• $e', style: const TextStyle(fontSize: 12, color: Color(0xFF063164))),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
