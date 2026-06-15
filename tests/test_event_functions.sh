#!/usr/bin/env bash
# test_event_functions.sh - Unit tests for event_functions.sh
# Run: bash tests/test_event_functions.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/functions/event_functions.sh"

PASS=0
FAIL=0

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        PASS=$((PASS + 1))
        echo "  PASS: $desc"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $desc"
        echo "        expected: '$expected'"
        echo "        actual:   '$actual'"
    fi
}

echo "=== roll_daily_event ==="

# Roll 0 should hit first event (equipment_failure, range 0-9)
result=$(roll_daily_event 0)
assert_eq "roll 0 -> equipment_failure" "equipment_failure" "$result"

# Roll 9 should still hit equipment_failure (range 0-9, prob=10)
result=$(roll_daily_event 9)
assert_eq "roll 9 -> equipment_failure" "equipment_failure" "$result"

# Roll 10 should hit influencer_recommendation (range 10-17, prob=8)
result=$(roll_daily_event 10)
assert_eq "roll 10 -> influencer_recommendation" "influencer_recommendation" "$result"

# Roll 17 should hit influencer_recommendation
result=$(roll_daily_event 17)
assert_eq "roll 17 -> influencer_recommendation" "influencer_recommendation" "$result"

# Roll 18 should hit ingredient_price_hike (range 18-29, prob=12)
result=$(roll_daily_event 18)
assert_eq "roll 18 -> ingredient_price_hike" "ingredient_price_hike" "$result"

# Roll 99 should return "none" (total probability is 92, so 92-99 = none)
result=$(roll_daily_event 99)
assert_eq "roll 99 -> none" "none" "$result"

# Roll 92 should also return "none"
result=$(roll_daily_event 92)
assert_eq "roll 92 -> none" "none" "$result"

echo ""
echo "=== get_event_field ==="

result=$(get_event_field "equipment_failure" "name")
assert_eq "equipment_failure name" "Equipment Failure" "$result"

result=$(get_event_field "equipment_failure" "type")
assert_eq "equipment_failure type" "expense_delta" "$result"

result=$(get_event_field "equipment_failure" "value")
assert_eq "equipment_failure value" "1" "$result"

result=$(get_event_field "influencer_recommendation" "name")
assert_eq "influencer_recommendation name" "Influencer Recommendation" "$result"

result=$(get_event_field "influencer_recommendation" "type")
assert_eq "influencer_recommendation type" "sales_mult" "$result"

result=$(get_event_field "tip_jar_windfall" "type")
assert_eq "tip_jar_windfall type" "cash_delta" "$result"

echo ""
echo "=== apply_event_effects ==="

# Test "none" event - should return inputs unchanged
result=$(apply_event_effects "none" 1 100 100)
expected="1
100
100
0"
assert_eq "none event returns unchanged values" "$expected" "$result"

# Test expense_delta: equipment_failure (+1 expense)
result=$(apply_event_effects "equipment_failure" 1 100 100)
expected="2
100
100
0"
assert_eq "equipment_failure: expense 1->2" "$expected" "$result"

# Test expense_delta: ingredient_price_hike (+2 expense)
result=$(apply_event_effects "ingredient_price_hike" 1 100 100)
expected="3
100
100
0"
assert_eq "ingredient_price_hike: expense 1->3" "$expected" "$result"

# Test expense_delta floor at 0: coffee_bean_sale (-1 expense, starting from 0)
result=$(apply_event_effects "coffee_bean_sale" 0 100 100)
expected="0
100
100
0"
assert_eq "coffee_bean_sale: expense 0 stays 0 (floor)" "$expected" "$result"

# Test expense_delta: coffee_bean_sale (-1 expense from 2)
result=$(apply_event_effects "coffee_bean_sale" 2 100 100)
expected="1
100
100
0"
assert_eq "coffee_bean_sale: expense 2->1" "$expected" "$result"

# Test sales_mult: influencer_recommendation (200% = double, base 100)
result=$(apply_event_effects "influencer_recommendation" 1 100 100)
expected="1
200
100
0"
assert_eq "influencer: sales_mult 100->200 (2x)" "$expected" "$result"

# Test sales_mult: nearby_festival (150% = 1.5x, base 100)
result=$(apply_event_effects "nearby_festival" 1 100 100)
expected="1
150
100
0"
assert_eq "festival: sales_mult 100->150 (1.5x)" "$expected" "$result"

# Test sales_mult: health_inspection (50% = half, base 100)
result=$(apply_event_effects "health_inspection" 1 100 100)
expected="1
50
100
0"
assert_eq "health_inspection: sales_mult 100->50 (0.5x)" "$expected" "$result"

# Test sales_mult: viral_tiktok (300% = triple, base 100)
result=$(apply_event_effects "viral_tiktok" 1 100 100)
expected="1
300
100
0"
assert_eq "viral_tiktok: sales_mult 100->300 (3x)" "$expected" "$result"

# Test sales_mult: rainy_day (70% = 0.7x, base 100)
result=$(apply_event_effects "rainy_day" 1 100 100)
expected="1
70
100
0"
assert_eq "rainy_day: sales_mult 100->70 (0.7x)" "$expected" "$result"

# Test cash_delta: tip_jar_windfall (+10 cash)
result=$(apply_event_effects "tip_jar_windfall" 1 100 100)
expected="1
100
110
10"
assert_eq "tip_jar: cash 100->110" "$expected" "$result"

# Test cash_delta: pipe_burst (-15 cash)
result=$(apply_event_effects "pipe_burst" 1 100 100)
expected="1
100
85
-15"
assert_eq "pipe_burst: cash 100->85" "$expected" "$result"

echo ""
echo "=== format_event_message ==="

# Test "none" event returns empty
result=$(format_event_message "none")
assert_eq "none event -> empty message" "" "$result"

# Test a real event has content
result=$(format_event_message "equipment_failure")
if [[ "$result" == *"DAILY EVENT: Equipment Failure"* ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: equipment_failure message contains event name"
else
    FAIL=$((FAIL + 1))
    echo "  FAIL: equipment_failure message missing event name"
fi

if [[ "$result" == *"espresso machine"* ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: equipment_failure message contains description"
else
    FAIL=$((FAIL + 1))
    echo "  FAIL: equipment_failure message missing description"
fi

echo ""
echo "=== format_effect_summary ==="

# Test none event
result=$(format_effect_summary "none")
assert_eq "none event -> empty summary" "" "$result"

# Test expense increase
result=$(format_effect_summary "equipment_failure")
if [[ "$result" == *"expense"* ]] && [[ "$result" == *'+$1'* ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: equipment_failure summary shows expense +\$1"
else
    FAIL=$((FAIL + 1))
    echo "  FAIL: equipment_failure summary: '$result'"
fi

# Test sales boost
result=$(format_effect_summary "influencer_recommendation")
if [[ "$result" == *"Customer traffic"* ]] && [[ "$result" == *"x2"* ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: influencer summary shows x2 traffic"
else
    FAIL=$((FAIL + 1))
    echo "  FAIL: influencer summary: '$result'"
fi

# Test cash gain
result=$(format_effect_summary "tip_jar_windfall")
if [[ "$result" == *'+$10'* ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: tip_jar summary shows +\$10"
else
    FAIL=$((FAIL + 1))
    echo "  FAIL: tip_jar summary: '$result'"
fi

echo ""
echo "========================================="
echo "  Results: $PASS passed, $FAIL failed"
echo "========================================="

if (( FAIL > 0 )); then
    exit 1
fi
exit 0
