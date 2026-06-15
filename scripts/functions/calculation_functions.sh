#!/usr/bin/env bash

# ----------------------------------------------------------
# calculate_profit <weather> <price> <count> <drink_index>
#
# Calculates sales, income, and profit for a given drink.
# Sets the global variable 'profit'.
#
# Formula:
#   mult         = random 5..14 (market friction)
#   demand_bonus = DRINK_DEMAND_BONUSES[drink_index] (percent)
#   make_cost    = DRINK_MAKE_COSTS[drink_index]
#   raw_sales    = ((weather - 20) * 10 - mult * price) / 2 * sales_mult
#   sales        = raw_sales * (100 + demand_bonus) / 100
#   income       = min(sales, count) * price
#   overhead     = sales / 2
#   production   = count * make_cost
#   profit       = income - production - overhead
# ----------------------------------------------------------
calculate_profit () {
    local weather=$1
    local price=$2
    local count=$3
    local drink_idx=${4:-0}

    local make_cost=${DRINK_MAKE_COSTS[$drink_idx]:-1}
    local demand_bonus=${DRINK_DEMAND_BONUSES[$drink_idx]:-0}

    # Random market friction factor (5..14)
    local mult=$(( 5 + RANDOM % 10 ))

    # Base sales calculation (same formula as original, but uses make_cost-adjusted price pressure)
    local raw_sales=$(( (( (weather - 20) * 10 - mult * price ) / 2 ) * sales_mult ))
    if (( raw_sales < 0 )); then
        raw_sales=0
    fi

    # Apply demand bonus from the drink type
    local sales=$(( raw_sales * (100 + demand_bonus) / 100 ))
    if (( sales <= 0 )); then
        sales=0
    fi

    echo "Sales: $sales"

    # Calculate income: min(sales, count) * price
    local sold
    if (( sales > count )); then
        sold=$count
    else
        sold=$sales
    fi
    local income=$(( sold * price ))
    echo "Income: $income"

    # Production cost: every cup made costs make_cost
    local production=$(( count * make_cost ))

    # Overhead scales with customer traffic
    local overhead=$(( sales / 2 ))

    # Final profit
    profit=$(( income - production - overhead ))
    echo "Production cost: $production"
    echo "Overhead: $overhead"
    return 0
}
