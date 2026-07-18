# Live Payment Integration Guide

The included course checkout sheet is a front-end demo. For production payments:

1. Create an order on your secure backend with course ID, student details, amount, and currency.
2. Request a hosted checkout/payment session from your chosen gateway.
3. Redirect or open the provider's hosted payment page instead of collecting sensitive card details directly in Flutter.
4. Verify the provider callback/webhook on your backend.
5. Mark the order paid only after server-side verification.
6. Return a success/failure status to Flutter and show the enrollment confirmation.

## Suggested mapping

- JazzCash: hosted/mobile wallet checkout
- Easypaisa: hosted/mobile account checkout
- Card: provider-hosted PCI-compliant checkout
- Bank transfer: generate an order reference and verify payment manually or through banking APIs

Never put secret API keys in Flutter Web source because browser users can inspect them.
