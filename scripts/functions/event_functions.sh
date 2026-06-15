#!/usr/bin/env bash
#
# Daily random events for Bash Cafe.
#
# The event logic is split into small, single-purpose functions so it can be
# unit tested in isolation and kept out of the main loop:
#   - event_name / event_desc / event_*_mod : pure id -> value lookups
#   - select_event                          : pure roll (0-99) -> event id
#   - roll_daily_event                      : the ONLY impure piece ($RANDOM),
#                                             loads the chosen event's modifiers
#                                             into globals
#   - display_event                         : presentation only
#
# Modifiers are integer percentages: 100 = no change, 150 = +50%, 80 = -20%.
# They are consumed in calculate_profit (functions/calculation_functions.sh):
#   event_cost_mult     -> cost of the coffees made
#   event_customer_mult -> customer flow (sales)
#   event_revenue_mult  -> income / revenue

# Number of defined events (ids 0..EVENT_COUNT-1). Id 0 is the ordinary day.
EVENT_COUNT=6

# Display name for an event id.
event_name () {
    case "$1" in
        0) echo "Ordinary Day" ;;
        1) echo "Equipment Failure" ;;
        2) echo "Influencer Shout-out" ;;
        3) echo "Raw Material Price Hike" ;;
        4) echo "Street Festival" ;;
        5) echo "Health Inspection" ;;
        *) echo "Unknown Event" ;;
    esac
}

# One-line description shown to the player before they decide.
event_desc () {
    case "$1" in
        0) echo "A calm, ordinary day at the cafe." ;;
        1) echo "Your espresso machine broke! Repairs cost extra and service slows down." ;;
        2) echo "A popular influencer recommended your cafe! Expect a rush of customers." ;;
        3) echo "Coffee bean prices spiked today. Every cup costs more to make." ;;
        4) echo "A street festival nearby is drawing crowds past your door." ;;
        5) echo "A surprise health inspection disrupts service and dents takings." ;;
        *) echo "Something unusual is happening." ;;
    esac
}

# Cost-of-goods modifier (percentage). Default 100 = no change.
event_cost_mod () {
    case "$1" in
        1) echo 150 ;;   # equipment failure: repairs + wasted stock
        3) echo 140 ;;   # raw material price hike
        5) echo 110 ;;   # inspection: minor compliance cost
        *) echo 100 ;;
    esac
}

# Customer-flow modifier (percentage). Default 100 = no change.
event_customer_mod () {
    case "$1" in
        1) echo 80 ;;    # slower service while machine is down
        2) echo 180 ;;   # influencer-driven rush
        4) echo 140 ;;   # festival crowd
        5) echo 70 ;;    # inspection scares customers off
        *) echo 100 ;;
    esac
}

# Revenue modifier (percentage). Default 100 = no change.
event_revenue_mod () {
    case "$1" in
        2) echo 110 ;;   # hype lets you charge a little more
        4) echo 105 ;;   # festive mood loosens wallets
        *) echo 100 ;;
    esac
}

# Pure selection: map a roll (0-99) to an event id.
# Probability bands (sum to 100):
#   0-49  (50%) ordinary day
#   50-59 (10%) equipment failure
#   60-74 (15%) influencer shout-out
#   75-84 (10%) raw material price hike
#   85-94 (10%) street festival
#   95-99 ( 5%) health inspection
select_event () {
    local roll=$1
    if   (( roll < 50 )); then echo 0
    elif (( roll < 60 )); then echo 1
    elif (( roll < 75 )); then echo 2
    elif (( roll < 85 )); then echo 3
    elif (( roll < 95 )); then echo 4
    else                       echo 5
    fi
}

# Roll today's event and load its modifiers into globals read by calculate_profit.
# This is the only function that depends on $RANDOM, keeping the rest pure.
# Sets: current_event, event_cost_mult, event_customer_mult, event_revenue_mult
roll_daily_event () {
    current_event=$(select_event $(( RANDOM % 100 )))
    event_cost_mult=$(event_cost_mod "$current_event")
    event_customer_mult=$(event_customer_mod "$current_event")
    event_revenue_mult=$(event_revenue_mod "$current_event")
}

# Presentation only: announce the event, then leave a banner above the
# decision prompts so the player can react before committing.
display_event () {
    local id=$1
    center "Today: $(event_name "$id")"
    sleep 1
    tput clear
    echo -e "\e[1;33m* $(event_name "$id") *\e[0m"
    echo "$(event_desc "$id")"
    echo ""
}
