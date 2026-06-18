// Supabase Edge Function: send FCM data-only push on order/coupon events.
// Deploy: supabase functions deploy send-fcm --no-verify-jwt
// Secret: FIREBASE_SERVICE_ACCOUNT_JSON

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';

interface WebhookPayload {
  type: 'INSERT' | 'UPDATE';
  table: string;
  record: Record<string, unknown>;
  old_record?: Record<string, unknown>;
}

serve(async (req) => {
  try {
    const payload = (await req.json()) as WebhookPayload;
    const record = payload.record;

    // TODO: Initialize firebase-admin with Deno-compatible JWT signing
    // and send data-only message to profiles.fcm_token for the user.
    //
    // Example data payload:
    // { type: 'ORDER_READY', orderId: record.id }

    console.log('FCM webhook received', payload.table, record);

    return new Response(JSON.stringify({ ok: true }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
