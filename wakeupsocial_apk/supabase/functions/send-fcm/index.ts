// Supabase Edge Function: send FCM data-only push on order/coupon events.
// Deploy: supabase functions deploy send-fcm
// Secrets: FIREBASE_SERVICE_ACCOUNT_JSON, FCM_WEBHOOK_SECRET
//           SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (auto-injected in Supabase)

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { create, getNumericDate } from 'https://deno.land/x/djwt@v2.8/mod.ts';

interface WebhookPayload {
  type: 'INSERT' | 'UPDATE';
  table: string;
  record: Record<string, unknown>;
  old_record?: Record<string, unknown>;
}

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const raw = atob(b64);
  const buffer = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) buffer[i] = raw.charCodeAt(i);
  return buffer.buffer;
}

async function getGoogleAccessToken(
  serviceAccount: ServiceAccount,
): Promise<string> {
  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToArrayBuffer(serviceAccount.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const jwt = await create(
    { alg: 'RS256', typ: 'JWT' },
    {
      iss: serviceAccount.client_email,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
      aud: 'https://oauth2.googleapis.com/token',
      exp: getNumericDate(3600),
    },
    key,
  );

  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  if (!tokenResponse.ok) {
    throw new Error(`Google OAuth failed: ${await tokenResponse.text()}`);
  }

  const tokenJson = await tokenResponse.json();
  return tokenJson.access_token as string;
}

async function sendFcmMessage(
  accessToken: string,
  projectId: string,
  token: string,
  data: Record<string, string>,
): Promise<void> {
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: { token, data },
      }),
    },
  );

  if (!response.ok) {
    throw new Error(`FCM send failed: ${await response.text()}`);
  }
}

async function resolveFcmToken(
  payload: WebhookPayload,
): Promise<string | null> {
  const record = payload.record;
  if (typeof record.fcm_token === 'string' && record.fcm_token.length > 0) {
    return record.fcm_token;
  }

  const userId = record.user_id as string | undefined;
  if (!userId) return null;

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !serviceRoleKey) return null;

  const supabase = createClient(supabaseUrl, serviceRoleKey);
  const { data, error } = await supabase
    .from('profiles')
    .select('fcm_token')
    .eq('id', userId)
    .maybeSingle();

  if (error) {
    console.error('Profile lookup failed', error.message);
    return null;
  }

  return (data?.fcm_token as string | null) ?? null;
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const webhookSecret = Deno.env.get('FCM_WEBHOOK_SECRET');
  if (!webhookSecret) {
    return new Response(JSON.stringify({ error: 'Webhook secret not configured' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  if (authHeader !== `Bearer ${webhookSecret}`) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  if (!serviceAccountJson) {
    return new Response(
      JSON.stringify({ error: 'FIREBASE_SERVICE_ACCOUNT_JSON not configured' }),
      { status: 503, headers: { 'Content-Type': 'application/json' } },
    );
  }

  try {
    const payload = (await req.json()) as WebhookPayload;
    const serviceAccount = JSON.parse(serviceAccountJson) as ServiceAccount;
    const fcmToken = await resolveFcmToken(payload);

    if (!fcmToken) {
      return new Response(JSON.stringify({ ok: true, skipped: 'no fcm_token' }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const record = payload.record;
    const data: Record<string, string> = {
      type: payload.table === 'orders' ? 'ORDER_UPDATE' : 'NOTIFICATION',
      table: payload.table,
      recordId: String(record.id ?? ''),
    };

    if (payload.table === 'orders' && record.status_v2) {
      data.status = String(record.status_v2);
    }

    const accessToken = await getGoogleAccessToken(serviceAccount);
    await sendFcmMessage(
      accessToken,
      serviceAccount.project_id,
      fcmToken,
      data,
    );

    return new Response(JSON.stringify({ ok: true }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error('FCM webhook error', err);
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
