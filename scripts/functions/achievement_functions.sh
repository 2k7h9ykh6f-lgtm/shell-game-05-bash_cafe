#!/usr/bin/env bash

# ============================================================
# Achievement / Goal System for Bash Cafe
# ============================================================
# Tracks player stats and unlocks achievements based on
# milestones for income, profit streaks, upgrades, and more.
# ============================================================

# ---------- stat tracking variables (persisted in save) ----------
total_income=0
consecutive_profit_days=0
max_cash=0
total_coffees_sold=0
total_upgrades=0

# ---------- achievement unlock flags (0=locked, 1=unlocked) ----------

# Income milestones (cumulative total_income)
ach_first_hundred=0    # total_income >= 100
ach_five_hundred=0     # total_income >= 500
ach_thousand=0         # total_income >= 1000
ach_tycoon=0           # total_income >= 5000

# Consecutive profit streaks
ach_streak_3=0         # 3-day profit streak
ach_streak_7=0         # 7-day profit streak
ach_streak_14=0        # 14-day profit streak

# Cash milestones (max_cash reached)
ach_savings_200=0      # cash >= 200
ach_savings_500=0      # cash >= 500
ach_savings_1000=0     # cash >= 1000

# Special
ach_first_upgrade=0    # purchased first upgrade
ach_survivor=0         # survived to day 30
ach_coffee_100=0       # sold 100 coffees total

# ---------- achievement display names and descriptions ----------
# Parallel arrays: name, description, variable_name
ACHIEVEMENT_NAMES=(
    "First Hundred"
    "Five Hundred Club"
    "Thousandaire"
    "Coffee Tycoon"
    "Hot Streak"
    "Unstoppable"
    "Legend"
    "Nest Egg"
    "War Chest"
    "Fort Knox"
    "First Upgrade"
    "Survivor"
    "Coffee Veteran"
)

ACHIEVEMENT_DESCS=(
    "Earn a total income of \$100"
    "Earn a total income of \$500"
    "Earn a total income of \$1,000"
    "Earn a total income of \$5,000"
    "Achieve a 3-day profit streak"
    "Achieve a 7-day profit streak"
    "Achieve a 14-day profit streak"
    "Accumulate \$200 in cash"
    "Accumulate \$500 in cash"
    "Accumulate \$1,000 in cash"
    "Purchase your first upgrade"
    "Survive to day 30"
    "Sell a total of 100 coffees"
)

ACHIEVEMENT_VARS=(
    "ach_first_hundred"
    "ach_five_hundred"
    "ach_thousand"
    "ach_tycoon"
    "ach_streak_3"
    "ach_streak_7"
    "ach_streak_14"
    "ach_savings_200"
    "ach_savings_500"
    "ach_savings_1000"
    "ach_first_upgrade"
    "ach_survivor"
    "ach_coffee_100"
)

# ============================================================
# update_stats() - called at end of each day to update tracked stats
#   $1 = day profit
#   $2 = day income
#   $3 = day coffees sold
# ============================================================
update_stats () {
    local day_profit=$1
    local day_income=$2
    local day_coffees=$3

    # cumulative income
    total_income=$(( total_income + day_income ))

    # coffees sold
    total_coffees_sold=$(( total_coffees_sold + day_coffees ))

    # consecutive profit streak
    if (( day_profit > 0 )); then
        consecutive_profit_days=$(( consecutive_profit_days + 1 ))
    else
        consecutive_profit_days=0
    fi

    # max cash tracking
    if (( cash > max_cash )); then
        max_cash=$cash
    fi
}

# ============================================================
# check_achievements() - evaluate all achievement conditions
# returns 0 if any new achievement was unlocked, 1 otherwise
# stores newly unlocked achievement names in NEW_ACHIEVEMENTS array
# ============================================================
NEW_ACHIEVEMENTS=()

check_achievements () {
    NEW_ACHIEVEMENTS=()
    local any_new=1

    # Income milestones
    if (( ach_first_hundred == 0 && total_income >= 100 )); then
        ach_first_hundred=1
        NEW_ACHIEVEMENTS+=("First Hundred")
        any_new=0
    fi
    if (( ach_five_hundred == 0 && total_income >= 500 )); then
        ach_five_hundred=1
        NEW_ACHIEVEMENTS+=("Five Hundred Club")
        any_new=0
    fi
    if (( ach_thousand == 0 && total_income >= 1000 )); then
        ach_thousand=1
        NEW_ACHIEVEMENTS+=("Thousandaire")
        any_new=0
    fi
    if (( ach_tycoon == 0 && total_income >= 5000 )); then
        ach_tycoon=1
        NEW_ACHIEVEMENTS+=("Coffee Tycoon")
        any_new=0
    fi

    # Profit streaks
    if (( ach_streak_3 == 0 && consecutive_profit_days >= 3 )); then
        ach_streak_3=1
        NEW_ACHIEVEMENTS+=("Hot Streak")
        any_new=0
    fi
    if (( ach_streak_7 == 0 && consecutive_profit_days >= 7 )); then
        ach_streak_7=1
        NEW_ACHIEVEMENTS+=("Unstoppable")
        any_new=0
    fi
    if (( ach_streak_14 == 0 && consecutive_profit_days >= 14 )); then
        ach_streak_14=1
        NEW_ACHIEVEMENTS+=("Legend")
        any_new=0
    fi

    # Cash milestones
    if (( ach_savings_200 == 0 && cash >= 200 )); then
        ach_savings_200=1
        NEW_ACHIEVEMENTS+=("Nest Egg")
        any_new=0
    fi
    if (( ach_savings_500 == 0 && cash >= 500 )); then
        ach_savings_500=1
        NEW_ACHIEVEMENTS+=("War Chest")
        any_new=0
    fi
    if (( ach_savings_1000 == 0 && cash >= 1000 )); then
        ach_savings_1000=1
        NEW_ACHIEVEMENTS+=("Fort Knox")
        any_new=0
    fi

    # Special: first upgrade
    if (( ach_first_upgrade == 0 && total_upgrades >= 1 )); then
        ach_first_upgrade=1
        NEW_ACHIEVEMENTS+=("First Upgrade")
        any_new=0
    fi

    # Special: survivor (day >= 30)
    if (( ach_survivor == 0 && day_num >= 30 )); then
        ach_survivor=1
        NEW_ACHIEVEMENTS+=("Survivor")
        any_new=0
    fi

    # Special: coffee veteran (100 coffees sold)
    if (( ach_coffee_100 == 0 && total_coffees_sold >= 100 )); then
        ach_coffee_100=1
        NEW_ACHIEVEMENTS+=("Coffee Veteran")
        any_new=0
    fi

    return $any_new
}

# ============================================================
# show_new_achievements() - display popup for newly unlocked achievements
# ============================================================
show_new_achievements () {
    if [[ ${#NEW_ACHIEVEMENTS[@]} -eq 0 ]]; then
        return
    fi

    echo ""
    echo -e "\e[1;33m====================================\e[0m"
    echo -e "\e[1;33m   NEW ACHIEVEMENTS UNLOCKED!\e[0m"
    echo -e "\e[1;33m====================================\e[0m"
    for ach_name in "${NEW_ACHIEVEMENTS[@]}"; do
        echo -e "  \e[1;32m[Achievement]\e[0m \e[1m$ach_name\e[0m"
    done
    echo -e "\e[1;33m====================================\e[0m"
    echo ""
    read -p "Press enter to continue: "
}

# ============================================================
# display_achievements() - show full achievement list (menu option)
# ============================================================
display_achievements () {
    clear
    echo -e "\e[1;33m====================================\e[0m"
    echo -e "\e[1;33m       ACHIEVEMENTS / GOALS\e[0m"
    echo -e "\e[1;33m====================================\e[0m"
    echo ""

    local unlocked=0
    local total=${#ACHIEVEMENT_NAMES[@]}

    for i in "${!ACHIEVEMENT_NAMES[@]}"; do
        local var_name="${ACHIEVEMENT_VARS[$i]}"
        local value="${!var_name}"
        local name="${ACHIEVEMENT_NAMES[$i]}"
        local desc="${ACHIEVEMENT_DESCS[$i]}"

        if (( value == 1 )); then
            echo -e "  \e[1;32m[UNLOCKED]\e[0m \e[1m$name\e[0m"
            echo -e "             $desc"
            unlocked=$(( unlocked + 1 ))
        else
            echo -e "  \e[1;31m[LOCKED]  \e[0m \e[2m$name\e[0m"
            echo -e "             \e[2m$desc\e[0m"
        fi
    done

    echo ""
    echo -e "  Progress: \e[1m$unlocked / $total\e[0m"
    echo ""

    # Show current stats
    echo -e "\e[1;36m--- Stats ---\e[0m"
    echo "  Total Income:     \$$total_income"
    echo "  Profit Streak:    $consecutive_profit_days day(s)"
    echo "  Max Cash Held:    \$$max_cash"
    echo "  Coffees Sold:     $total_coffees_sold"
    echo "  Upgrades Bought:  $total_upgrades"
    echo ""

    read -p "Press enter to go back: "
}
