#!/usr/bin/env bash
#
# Unit tests for functions/event_functions.sh
#
# Sources ONLY the event module (no terminal/menu dependencies), which is
# possible because the event logic is split out of the main loop.
# Run from anywhere:  bash scripts/tests/test_event_functions.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/../functions/event_functions.sh"

fail=0
# assert_eq <description> <expected> <actual>
assert_eq () {
    if [[ "$2" != "$3" ]]; then
        echo "FAIL: $1 (expected '$2', got '$3')"
        fail=1
    else
        echo "ok: $1"
    fi
}

# --- select_event: pure roll -> id, including band boundaries ---
assert_eq "roll 0 -> ordinary"            0 "$(select_event 0)"
assert_eq "roll 49 -> ordinary (upper)"   0 "$(select_event 49)"
assert_eq "roll 50 -> equipment (lower)"  1 "$(select_event 50)"
assert_eq "roll 59 -> equipment (upper)"  1 "$(select_event 59)"
assert_eq "roll 60 -> influencer (lower)" 2 "$(select_event 60)"
assert_eq "roll 74 -> influencer (upper)" 2 "$(select_event 74)"
assert_eq "roll 75 -> raw material"       3 "$(select_event 75)"
assert_eq "roll 84 -> raw material (up)"  3 "$(select_event 84)"
assert_eq "roll 85 -> festival"           4 "$(select_event 85)"
assert_eq "roll 94 -> festival (upper)"   4 "$(select_event 94)"
assert_eq "roll 95 -> inspection"         5 "$(select_event 95)"
assert_eq "roll 99 -> inspection (upper)" 5 "$(select_event 99)"

# --- modifiers: specific values per event ---
assert_eq "equipment cost +50%"       150 "$(event_cost_mod 1)"
assert_eq "equipment customers -20%"   80 "$(event_customer_mod 1)"
assert_eq "influencer customers +80%" 180 "$(event_customer_mod 2)"
assert_eq "influencer revenue +10%"   110 "$(event_revenue_mod 2)"
assert_eq "raw material cost +40%"    140 "$(event_cost_mod 3)"
assert_eq "festival customers +40%"   140 "$(event_customer_mod 4)"
assert_eq "inspection customers -30%"  70 "$(event_customer_mod 5)"

# --- modifiers default to neutral (100) when an event has no effect ---
assert_eq "ordinary cost neutral"      100 "$(event_cost_mod 0)"
assert_eq "ordinary customers neutral" 100 "$(event_customer_mod 0)"
assert_eq "ordinary revenue neutral"   100 "$(event_revenue_mod 0)"
assert_eq "equipment revenue neutral"  100 "$(event_revenue_mod 1)"

# --- out-of-range id stays safe (neutral modifiers, graceful name) ---
assert_eq "unknown id cost neutral"     100 "$(event_cost_mod 99)"
assert_eq "unknown id customer neutral" 100 "$(event_customer_mod 99)"
assert_eq "unknown id revenue neutral"  100 "$(event_revenue_mod 99)"
assert_eq "unknown id name"  "Unknown Event" "$(event_name 99)"

# --- roll_daily_event wires globals consistently with the chosen event ---
roll_daily_event
assert_eq "rolled cost matches event"     "$(event_cost_mod "$current_event")"     "$event_cost_mult"
assert_eq "rolled customer matches event" "$(event_customer_mod "$current_event")" "$event_customer_mult"
assert_eq "rolled revenue matches event"  "$(event_revenue_mod "$current_event")"  "$event_revenue_mult"
if (( current_event >= 0 && current_event < EVENT_COUNT )); then
    echo "ok: rolled event id in range ($current_event)"
else
    echo "FAIL: rolled event id out of range ($current_event)"
    fail=1
fi

echo ""
if (( fail )); then
    echo "TESTS FAILED"
    exit 1
fi
echo "ALL TESTS PASSED"
