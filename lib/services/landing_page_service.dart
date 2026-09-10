import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/product_listing.dart';

class LandingPageService {
  /// Generates an HTML landing page for [listing], saves it to the
  /// application's documents directory and returns a map with keys:
  /// - "path": saved file path
  /// - "html": the HTML content
  static Future<Map<String, String>> generateLandingPage(ProductListing listing) async {
    final imageFile = File(listing.imagePath);
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final price = listing.finalPrice.toStringAsFixed(0);

    final html = _buildHtml(
      title: listing.titleEnglish,
      description: listing.descriptionEnglish,
      imageBase64: base64Image,
      price: price,
    );

    final dir = await getApplicationDocumentsDirectory();
    final filename = 'listing_${DateTime.now().millisecondsSinceEpoch}.html';
    final path = '${dir.path}/$filename';

    final file = File(path);
    await file.writeAsString(html, flush: true, mode: FileMode.write);

    return {'path': path, 'html': html};
  }

  static String _buildHtml({
    required String title,
    required String description,
    required String imageBase64,
    required String price,
  }) {
    // Basic responsive landing page with a simulated JS checkout flow that
    // posts an "ORDER_PLACED" message to the Flutter JavascriptChannel.
    return '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${_escapeHtml(title)}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial; margin:0; padding:0; color:#222 }
    .container { max-width:720px; margin:24px auto; padding:16px }
    .card { box-shadow: 0 6px 18px rgba(0,0,0,0.08); border-radius:12px; overflow:hidden }
    .media { width:100%; height:360px; object-fit:cover; display:block }
    .content { padding:18px }
    .title { font-size:22px; font-weight:800; margin:0 0 8px }
    .price { color:#b53; font-weight:800; font-size:20px }
    .btn { background:#d95a36; color:white; border:none; padding:12px 16px; border-radius:8px; font-weight:700; cursor:pointer }
    .muted { color:#666; font-size:14px }
    .modal { position:fixed; left:0; top:0; right:0; bottom:0; background:rgba(0,0,0,0.4); display:flex; align-items:center; justify-content:center }
    .modal-card { background:white; padding:18px; border-radius:12px; width:90%; max-width:420px }
    .field { margin-bottom:10px }
    input, textarea { width:100%; padding:10px; border-radius:8px; border:1px solid #ddd }
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <img class="media" src="data:image/jpeg;base64,$imageBase64" alt="Product photo" />
      <div class="content">
        <h1 class="title">${_escapeHtml(title)}</h1>
        <div class="muted">${_escapeHtml(description)}</div>
        <div style="height:12px"></div>
        <div class="price">₹ $price</div>
        <div style="height:18px"></div>
        <button class="btn" id="buyBtn">Buy</button>
        <div style="height:14px"></div>
        <div class="muted">This checkout is a simulated demo; no payment is collected.</div>
      </div>
    </div>
  </div>

  <div id="checkoutModal" class="modal" style="display:none">
    <div class="modal-card">
      <h3>Checkout</h3>
      <div class="field"><input id="name" placeholder="Full name" /></div>
      <div class="field"><input id="phone" placeholder="Phone or WhatsApp" /></div>
      <div class="field"><input id="address" placeholder="Delivery address" /></div>
      <div class="field"><input id="quantity" type="number" min="1" value="1" /></div>
      <div style="text-align:right">
        <button class="btn" id="placeOrder">Place order</button>
      </div>
    </div>
  </div>

  <script>
    const buyBtn = document.getElementById('buyBtn');
    const modal = document.getElementById('checkoutModal');
    const place = document.getElementById('placeOrder');

    buyBtn.addEventListener('click', () => { modal.style.display = 'flex'; });

    place.addEventListener('click', () => {
      const order = {
        orderId: 'ORD' + Math.floor(Math.random()*900000 + 100000),
        name: document.getElementById('name').value,
        phone: document.getElementById('phone').value,
        address: document.getElementById('address').value,
        quantity: document.getElementById('quantity').value,
        time: new Date().toISOString()
      };

      // Send the order back to Flutter via the Javascript channel named "OrderChannel".
      try {
        OrderChannel.postMessage(JSON.stringify({type:'ORDER_PLACED', payload: order}));
      } catch (e) {
        // Fallback for platforms where direct channel isn't available
        console.log('Order placed', order);
        alert('Order placed: ' + order.orderId);
      }

      modal.style.display = 'none';
      document.body.insertAdjacentHTML('beforeend', `<div style="position:fixed;left:12px;bottom:12px;background:#fff;padding:10px;border-radius:10px;box-shadow:0 6px 16px rgba(0,0,0,0.12)">Order placed: <strong>${order.orderId}</strong></div>`);
    });
  </script>
</body>
</html>
''';
  }

  static String _escapeHtml(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}
