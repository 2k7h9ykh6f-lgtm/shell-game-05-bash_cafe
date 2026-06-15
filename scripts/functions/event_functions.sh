#!/usr/bin/env bash
# event_functions.sh - Daily random event system
# Each event can affect: expense (cost per coffee), sales_mult (customer traffic),
# or flat cash changes. Functions are pure/testable where possible.

# Event definitions ---------------------------------------------------------
# Each event has: id, name, description, effect_type, effect_value
#   effect_type: "expense_delta" | "sales_mult" | "cash_delta"
#     - expense_delta: adds to the per-coffee expense for the day
#     - sales_mult:    percentage multiplier for sales (100=normal, 200=double, 50=half)
#     - cash_delta:    flat cash gain or loss
#   probability: percent chance (0-100) the event fires on any given day

declare -A EVENT_NAME EVENT_DESC EVENT_TYPE EVENT_VALUE EVENT_PROB

_register_events() {
    local i

    i="equipment_failure"
    EVENT_NAME[$i]="Equipment Failure"
    EVENT_DESC[$i]="Your espresso machine broke down! Repair costs increase your coffee expense today."
    EVENT_TYPE[$i]="expense_delta"
    EVENT_VALUE[$i]=1
    EVENT_PROB[$i]=10

    i="influencer_recommendation"
    EVENT_NAME[$i]="Influencer Recommendation"
    EVENT_DESC[$i]="A popular influencer posted about your cafe! Customer traffic doubles today."
    EVENT_TYPE[$i]="sales_mult"
    EVENT_VALUE[$i]=200
    EVENT_PROB[$i]=8

    i="ingredient_price_hike"
    EVENT_NAME[$i]="Ingredient Price Hike"
    EVENT_DESC[$i]="Coffee bean prices surged overnight. Each coffee costs $2 more to make today."
    EVENT_TYPE[$i]="expense_delta"
    EVENT_VALUE[$i]=2
    EVENT_PROB[$i]=12

    i="nearby_festival"
    EVENT_NAME[$i]="Nearby Festival"
    EVENT_DESC[$i]="A local festival is drawing crowds! Customer traffic is 1.5x today."
    EVENT_TYPE[$i]="sales_mult"
    EVENT_VALUE[$i]=150
    EVENT_PROB[$i]=10

    i="health_inspection"
    EVENT_NAME[$i]="Health Inspection"
    EVENT_DESC[$i]="Surprise health inspection limits your seating. Customer traffic halved today."
    EVENT_TYPE[$i]="sales_mult"
    EVENT_VALUE[$i]=50
    EVENT_PROB[$i]=8

    i="coffee_bean_sale"
    EVENT_NAME[$i]="Coffee Bean Sale"
    EVENT_DESC[$i]="Your supplier is running a sale! Each coffee costs $1 less to make today."
    EVENT_TYPE[$i]="expense_delta"
    EVENT_VALUE[$i]=-1
    EVENT_PROB[$i]=10

    i="viral_tiktok"
    EVENT_NAME[$i]="Viral TikTok"
    EVENT_DESC[$i]="A TikTok of your latte art went viral! Customer traffic triples today."
    EVENT_TYPE[$i]="sales_mult"
    EVENT_VALUE[$i]=300
    EVENT_PROB[$i]=5

    i="rainy_day"
    EVENT_NAME[$i]="Rainy Day"
    EVENT_DESC[$i]="Heavy rain keeps people indoors. Customer traffic drops by 30%."
    EVENT_TYPE[$i]="sales_mult"
    EVENT_VALUE[$i]=70
    EVENT_PROB[$i]=15

    i="tip_jar_windfall"
    EVENT_NAME[$i]="Generous Tip"
    EVENT_DESC[$i]="A generous customer left a big tip! You gain $10."
    EVENT_TYPE[$i]="cash_delta"
    EVENT_VALUE[$i]=10
    EVENT_PROB[$i]=8

    i="pipe_burst"
    EVENT_NAME[$i]="Pipe Burst"
    EVENT_DESC[$i]="A pipe burst in the shop! Emergency repairs cost $15."
    EVENT_TYPE[$i]="cash_delta"
    EVENT_VALUE[$i]=-15
    EVENT_PROB[$i]=6
}

_register_events

# List of all event IDs (order matters for roll_daily_event selection)
ALL_EVENT_IDS=(
    equipment_failure
    influencer_recommendation
    ingredient_price_hike
    nearby_festival
    health_inspection
    coffee_bean_sale
    viral_tiktok
    rainy_day
    tip_jar_windfall
    pipe_burst
)

# Public API ----------------------------------------------------------------

# roll_daily_event <random_seed_0_to_99>
#   Given a random number 0-99, pick the first event whose cumulative
#   probability range covers that number. Returns event id or "none".
#   Pure function - no side effects.
roll_daily_event() {
    local roll=$1
    local cumulative=0
    local id

    for id in "${ALL_EVENT_IDS[@]}"; do
        cumulative=$(( cumulative + EVENT_PROB[$id] ))
        if (( roll < cumulative )); then
            echo "$id"
            return
        fi
    done
    echo "none"
}

# get_event_field <event_id> <field>
#   Returns the value of a field for a given event. Fields: name, desc, type, value
get_event_field() {
    local id=$1
    local field=$2
    case "$field" in
        name)  echo "${EVENT_NAME[$id]}" ;;
        desc)  echo "${EVENT_DESC[$id]}" ;;
        type)  echo "${EVENT_TYPE[$id]}" ;;
        value) echo "${EVENT_VALUE[$id]}" ;;
    esac
}

# apply_event_effects <event_id> <current_expense> <current_sales_mult> <current_cash>
#   Outputs four lines: new_expense, new_sales_mult, new_cash, cash_delta
#   Pure function - does not modify global state.
apply_event_effects() {
    local id=$1
    local expense=$2
    local sales_mult=$3
    local cash=$4

    if [[ "$id" == "none" ]]; then
        echo "$expense"
        echo "$sales_mult"
        echo "$cash"
        echo "0"
        return
    fi

    local etype="${EVENT_TYPE[$id]}"
    local evalue="${EVENT_VALUE[$id]}"
    local cash_delta=0

    case "$etype" in
        expense_delta)
            expense=$(( expense + evalue ))
            if (( expense < 0 )); then
                expense=0
            fi
            ;;
        sales_mult)
            # All sales_mult values are percentages: 100=normal, 200=double, 50=half
            sales_mult=$(( sales_mult * evalue / 100 ))
            if (( sales_mult < 0 )); then
                sales_mult=0
            fi
            ;;
        cash_delta)
            cash=$(( cash + evalue ))
            cash_delta=$evalue
            ;;
    esac

    echo "$expense"
    echo "$sales_mult"
    echo "$cash"
    echo "$cash_delta"
}

# format_event_message <event_id>
#   Returns a formatted string for displaying the event to the player.
format_event_message() {
    local id=$1
    if [[ "$id" == "none" ]]; then
        echo ""
        return
    fi
    local name="${EVENT_NAME[$id]}"
    local desc="${EVENT_DESC[$id]}"
    echo "========================================"
    echo "  DAILY EVENT: $name"
    echo "  $desc"
    echo "========================================"
}

# format_effect_summary <event_id>
#   Returns a short summary of what the event does (for post-event display).
format_effect_summary() {
    local id=$1
    if [[ "$id" == "none" ]]; then
        echo ""
        return
    fi
    local etype="${EVENT_TYPE[$id]}"
    local evalue="${EVENT_VALUE[$id]}"
    case "$etype" in
        expense_delta)
            if (( evalue > 0 )); then
                echo "  -> Coffee expense +\$$evalue today"
            else
                local abs_val="${evalue#-}"
                echo "  -> Coffee expense -\$$abs_val today"
            fi
            ;;
        sales_mult)
            # All values are percentages (100=normal)
            if (( evalue >= 100 )); then
                local whole=$(( evalue / 100 ))
                local frac=$(( (evalue % 100) / 10 ))
                if (( frac > 0 )); then
                    echo "  -> Customer traffic x${whole}.${frac} today"
                else
                    echo "  -> Customer traffic x${whole} today"
                fi
            else
                local pct=$(( evalue ))
                echo "  -> Customer traffic ${pct}% today"
            fi
            ;;
        cash_delta)
            if (( evalue > 0 )); then
                echo "  -> +\$$evalue cash"
            else
                local abs_val="${evalue#-}"
                echo "  -> -\$$abs_val cash"
            fi
            ;;
    esac
}
