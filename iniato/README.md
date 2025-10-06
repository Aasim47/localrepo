# Iniato (MVP)

Flutter + Supabase shared auto app promoting EV rides with Green Tokens.

## Setup

1. Supabase:
   - Create project, retrieve `SUPABASE_URL` and `ANON` key.
   - Apply SQL in `supabase/migrations/0001_init.sql`.
   - Deploy Edge Function `reward_tokens` (Supabase CLI):
     ```bash
     supabase functions deploy reward_tokens
     ```
   - Add env vars for function runtime: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`.

2. Flutter:
   - Edit `lib/config.dart` with your Supabase creds.
   - Run:
     ```bash
     flutter pub get
     flutter run
     ```

Notes: Google Maps UI is mocked in MVP; fare estimation is simple formula.
