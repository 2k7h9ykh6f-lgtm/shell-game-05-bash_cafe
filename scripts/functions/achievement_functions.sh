#!/usr/bin/env bash

# Achievement / goal system for Bash Cafe.
# Tracks consecutive profitable days, cumulative income, and wealth (cash) milestones.
# State is persisted by save()/load() in saves/save_load_functions.sh:
#   profit_streak, total_income, and ach_unlocked (space-joined 0/1 flags).
# Written for bash 3.2 compatibility: indexed arrays only, no associative arrays.

# Static catalog. ach_ids are stable keys used in the save data; ach_names are the
# labels shown to the player. The two arrays are parallel (same index = same achievement).
ach_ids=(
    "streak_3"
    "streak_7"
    "income_100"
    "income_500"
    "income_1000"
    "wealth_250"
    "wealth_500"
    "wealth_1000"
    "survive_7"
    "survive_30"
)

ach_names=(
    "On a Roll - 3 profitable days in a row"
    "Hot Streak - 7 profitable days in a row"
    "First Returns - earn \$100 total income"
    "Steady Earner - earn \$500 total income"
    "Coffee Tycoon - earn \$1000 total income"
    "Getting Comfortable - reach \$250 cash"
    "Well Established - reach \$500 cash"
    "Cafe Empire - reach \$1000 cash"
    "Surviving the Week - reach day 7"
    "Seasoned Owner - reach day 30"
)

# Default unlocked state, sized to match the catalog (all locked). load() replaces this
# if the save file contains an ach_unlocked line.
ach_unlocked=()
for _ in "${ach_ids[@]}"; do
    ach_unlocked+=(0)
done

# update_achievements <day_profit> <day_income>
# Called once per day right after settlement. Updates the tracked stats, unlocks any
# newly-earned achievements, and prints a prompt listing the new ones.
update_achievements () {
    local day_profit=$1
    local day_income=$2

    # cumulative income across all days
    total_income=$(( total_income + day_income ))

    # consecutive profitable days: extend on profit, reset otherwise
    if (( day_profit > 0 )); then
        profit_streak=$(( profit_streak + 1 ))
    else
        profit_streak=0
    fi

    local i met
    local new_list
    new_list=()
    for i in "${!ach_ids[@]}"; do
        # already earned -> nothing to do
        [[ "${ach_unlocked[$i]}" == "1" ]] && continue
        met=0
        case "${ach_ids[$i]}" in
            streak_3)    (( profit_streak >= 3 ))   && met=1 ;;
            streak_7)    (( profit_streak >= 7 ))   && met=1 ;;
            income_100)  (( total_income >= 100 ))  && met=1 ;;
            income_500)  (( total_income >= 500 ))  && met=1 ;;
            income_1000) (( total_income >= 1000 )) && met=1 ;;
            wealth_250)  (( cash >= 250 ))          && met=1 ;;
            wealth_500)  (( cash >= 500 ))          && met=1 ;;
            wealth_1000) (( cash >= 1000 ))         && met=1 ;;
            survive_7)   (( day_num >= 7 ))         && met=1 ;;
            survive_30)  (( day_num >= 30 ))        && met=1 ;;
        esac
        if (( met == 1 )); then
            ach_unlocked[$i]=1
            new_list+=("${ach_names[$i]}")
        fi
    done

    # prompt the player about anything newly unlocked this day
    if (( ${#new_list[@]} > 0 )); then
        local n
        echo ""
        echo -e "\e[1;33m*** New Achievement(s) Unlocked! ***\e[0m"
        for n in "${new_list[@]}"; do
            echo -e " \e[32m+\e[0m $n"
        done
    fi
}

# show_achievements
# Viewer invoked from the Day Options menu. Lists every achievement with its status
# plus a summary of the stats that drive them.
show_achievements () {
    clear
    echo -e "\e[4m Achievements \e[0m"
    echo ""
    local i
    for i in "${!ach_ids[@]}"; do
        if [[ "${ach_unlocked[$i]}" == "1" ]]; then
            echo -e " \e[32m[x]\e[0m ${ach_names[$i]}"
        else
            echo -e " [ ] ${ach_names[$i]}"
        fi
    done
    echo ""
    echo -e "Streak: $profit_streak day(s)  |  Total income: \$$total_income  |  Cash: \$$cash  |  Day: $day_num"
    echo ""
    read -p "Press enter to return: "
}
