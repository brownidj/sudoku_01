# Play Store Monetization Checklist

Yes. At this point, that’s the right place to focus.

Your app is querying `premium-unlock` correctly, but Play returns `notFound`, so this is product exposure/monetization config.

Check these exact Play Console items:

1. **Monetize → Products → One-time products → `premium_unlock`**
   - Base product status must be **Active**.
   - Purchase option `premium-unlock` must be **Active**.

2. **Countries/regions**
   - Purchase option available in your tester’s country (Australia).

3. **Publishing overview**
   - No pending changes. Publish anything pending.

4. **Internal track build linkage**
   - Internal testing active release is your latest build.
   - Tester list attached (you already showed this is true).

5. **Tester account + Play install path**
   - Tester page says “You are a tester” (you have this).
   - Install/update strictly via the tester link → Play Store.

6. **Wait for propagation**
   - After any monetization change, wait 30–60 minutes and retry.

If you send one screenshot of the one-time product page showing both:
- base product `premium_unlock` status
- purchase option `premium-unlock` status + region availability

I can confirm whether monetization is the remaining blocker.
