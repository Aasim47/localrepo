// Supabase Edge Function: reward_tokens
// Trigger this when a ride is marked completed (client-side invocation)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return new Response("Method not allowed", { status: 405 });
    }

    const { ride_id } = await req.json();
    if (!ride_id) {
      return new Response("ride_id required", { status: 400 });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      return new Response("Server misconfigured", { status: 500 });
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Fetch the ride
    const { data: ride, error: rideErr } = await supabase
      .from("rides")
      .select("id, passenger_id, driver_id, is_ev, status")
      .eq("id", ride_id)
      .single();

    if (rideErr) {
      return new Response(`Ride fetch error: ${rideErr.message}` , { status: 400 });
    }

    if (!ride) {
      return new Response("Ride not found", { status: 404 });
    }

    if (!ride.is_ev || ride.status !== "completed") {
      return new Response("Not eligible (not EV or not completed)", { status: 400 });
    }

    // Idempotency: if transactions already exist for this ride, skip
    const { count, error: countErr } = await supabase
      .from("transactions")
      .select("id", { count: "exact", head: true })
      .eq("ride_id", ride_id);

    if (countErr) {
      return new Response(`Count error: ${countErr.message}`, { status: 400 });
    }

    if ((count ?? 0) >= 2) {
      return new Response(JSON.stringify({ success: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // Rewards
    const passengerTokens = 10;
    const driverTokens = 15;

    // Update balances
    const { error: passIncErr } = await supabase.rpc("increment_token_balance", {
      user_id: ride.passenger_id,
      tokens: passengerTokens,
    });
    if (passIncErr) {
      return new Response(`Passenger increment error: ${passIncErr.message}`, { status: 400 });
    }

    const { error: driverIncErr } = await supabase.rpc("increment_token_balance", {
      user_id: ride.driver_id,
      tokens: driverTokens,
    });
    if (driverIncErr) {
      return new Response(`Driver increment error: ${driverIncErr.message}`, { status: 400 });
    }

    // Log transactions
    const { error: txErr } = await supabase.from("transactions").insert([
      { user_id: ride.passenger_id, ride_id, tokens: passengerTokens, reason: "EV Ride" },
      { user_id: ride.driver_id, ride_id, tokens: driverTokens, reason: "EV Ride Completed" },
    ]);

    if (txErr) {
      return new Response(`Transaction insert error: ${txErr.message}`, { status: 400 });
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(`Unexpected error: ${e instanceof Error ? e.message : String(e)}`, { status: 500 });
  }
});