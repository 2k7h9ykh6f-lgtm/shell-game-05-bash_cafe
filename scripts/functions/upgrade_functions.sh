#!/usr/bin/env bash

# ============================================================
# Drink Catalog
# Each drink is defined as a colon-separated string:
#   name:make_cost:base_price:demand_bonus:unlock_cash:unlock_equip:unlock_equip_cost
# - name:             display name
# - make_cost:        cost to make one unit
# - base_price:       suggested selling price (player can change)
# - demand_bonus:     % bonus added to demand (e.g., 20 = +20%)
# - unlock_cash:      cash threshold to auto-unlock (0 = never by cash alone)
# - unlock_equip:     equipment name required (empty = none)
# - unlock_equip_cost: cost to buy the equipment (0 = not purchasable)
# ============================================================

DRINK_CATALOG=(
    "Coffee:1:3:0:0::0"
    "Latte:2:5:15:200:Espresso Machine:150"
    "Iced Coffee:2:4:10:300:Ice Machine:200"
    "Cappuccino:3:6:20:500:Premium Grinder:300"
    "Mocha:4:7:25:750:Chocolate Station:400"
)

# Parallel arrays parsed from DRINK_CATALOG
declare -a DRINK_NAMES
declare -a DRINK_MAKE_COSTS
declare -a DRINK_BASE_PRICES
declare -a DRINK_DEMAND_BONUSES
declare -a DRINK_UNLOCK_CASH
declare -a DRINK_UNLOCK_EQUIPS
declare -a DRINK_UNLOCK_EQUIP_COSTS

# Currently unlocked drink indices (space-separated indices, e.g. "0 1 2")
unlocked_drinks="0"

# Equipment the player has purchased (space-separated names)
owned_equipment=""

# ----------------------------------------------------------
# init_drinks: Parse DRINK_CATALOG into parallel arrays.
# ----------------------------------------------------------
init_drinks () {
    DRINK_NAMES=()
    DRINK_MAKE_COSTS=()
    DRINK_BASE_PRICES=()
    DRINK_DEMAND_BONUSES=()
    DRINK_UNLOCK_CASH=()
    DRINK_UNLOCK_EQUIPS=()
    DRINK_UNLOCK_EQUIP_COSTS=()
    for entry in "${DRINK_CATALOG[@]}"; do
        IFS=':' read -r name mc bp db uc ue uec <<< "$entry"
        DRINK_NAMES+=("$name")
        DRINK_MAKE_COSTS+=("$mc")
        DRINK_BASE_PRICES+=("$bp")
        DRINK_DEMAND_BONUSES+=("$db")
        DRINK_UNLOCK_CASH+=("$uc")
        DRINK_UNLOCK_EQUIPS+=("$ue")
        DRINK_UNLOCK_EQUIP_COSTS+=("$uec")
    done
}

# ----------------------------------------------------------
# is_drink_unlocked <index>: Returns 0 if unlocked, 1 otherwise.
# ----------------------------------------------------------
is_drink_unlocked () {
    local idx=$1
    for u in $unlocked_drinks; do
        if (( u == idx )); then
            return 0
        fi
    done
    return 1
}

# ----------------------------------------------------------
# unlock_drink <index>: Adds drink index to unlocked_drinks
# if not already present.
# ----------------------------------------------------------
unlock_drink () {
    local idx=$1
    if is_drink_unlocked "$idx"; then
        return 1
    fi
    unlocked_drinks="$unlocked_drinks $idx"
    return 0
}

# ----------------------------------------------------------
# check_cash_unlocks: Check if current cash unlocks any drinks.
# Called at the start of each day.
# ----------------------------------------------------------
check_cash_unlocks () {
    local newly_unlocked=()
    for i in "${!DRINK_NAMES[@]}"; do
        if is_drink_unlocked "$i"; then
            continue
        fi
        local req="${DRINK_UNLOCK_CASH[$i]}"
        if (( req > 0 && cash >= req )); then
            unlock_drink "$i"
            newly_unlocked+=("${DRINK_NAMES[$i]}")
        fi
    done
    if (( ${#newly_unlocked[@]} > 0 )); then
        echo ""
        echo -e "\e[32m*** New drinks unlocked! ***\e[0m"
        for d in "${newly_unlocked[@]}"; do
            echo "  - $d"
        done
        sleep 2
    fi
}

# ----------------------------------------------------------
# buy_equipment <drink_index>: Purchase equipment to unlock a drink.
# Returns 0 on success, 1 on failure.
# ----------------------------------------------------------
buy_equipment () {
    local idx=$1
    local equip_name="${DRINK_UNLOCK_EQUIPS[$idx]}"
    local equip_cost="${DRINK_UNLOCK_EQUIP_COSTS[$idx]}"

    if [[ -z "$equip_name" ]] || (( equip_cost == 0 )); then
        echo "This drink has no equipment to purchase."
        return 1
    fi

    # Check if already owned
    for e in $owned_equipment; do
        if [[ "$e" == "$equip_name" ]]; then
            echo "You already own $equip_name."
            return 1
        fi
    done

    if (( cash < equip_cost )); then
        echo "Not enough cash! You need \$$equip_cost but only have \$$cash."
        return 1
    fi

    cash=$(( cash - equip_cost ))
    owned_equipment="$owned_equipment $equip_name"
    unlock_drink "$idx"
    echo -e "\e[32mPurchased $equip_name for \$$equip_cost!\e[0m"
    echo -e "\e[32m${DRINK_NAMES[$idx]} is now unlocked!\e[0m"
    sleep 2
    return 0
}

# ----------------------------------------------------------
# show_upgrade_menu: Display upgrade shop for equipment/drinks.
# ----------------------------------------------------------
show_upgrade_menu () {
    clear
    echo -e "\e[4m=== Upgrade Shop ===\e[0m"
    echo -e " Cash: \$$cash"
    echo ""

    # Show owned equipment
    if [[ -n "$owned_equipment" ]]; then
        echo -e "\e[32mOwned equipment:\e[0m"
        for e in $owned_equipment; do
            echo "  [x] $e"
        done
        echo ""
    fi

    # Show available equipment to buy
    echo -e "\e[4mAvailable Equipment:\e[0m"
    local has_items=0
    for i in "${!DRINK_NAMES[@]}"; do
        if (( i == 0 )); then continue; fi  # skip basic coffee
        local equip_name="${DRINK_UNLOCK_EQUIPS[$i]}"
        local equip_cost="${DRINK_UNLOCK_EQUIP_COSTS[$i]}"
        if [[ -z "$equip_name" ]] || (( equip_cost == 0 )); then continue; fi

        # Check if already owned
        local owned=0
        for e in $owned_equipment; do
            if [[ "$e" == "$equip_name" ]]; then
                owned=1
                break
            fi
        done
        if (( owned )); then continue; fi

        # Check if already unlocked by cash
        if is_drink_unlocked "$i"; then continue; fi

        has_items=1
        echo "  $((i)). $equip_name - \$$equip_cost  (unlocks ${DRINK_NAMES[$i]})"
    done
    if (( has_items == 0 )); then
        echo "  (all equipment purchased)"
    fi

    echo ""
    echo -e "\e[4mUnlock thresholds (auto-unlock when cash reaches):\e[0m"
    for i in "${!DRINK_NAMES[@]}"; do
        if (( i == 0 )); then continue; fi
        local req="${DRINK_UNLOCK_CASH[$i]}"
        if (( req > 0 )); then
            if is_drink_unlocked "$i"; then
                echo -e "  \e[32m${DRINK_NAMES[$i]}: unlocked!\e[0m"
            else
                echo "  ${DRINK_NAMES[$i]}: \$$req"
            fi
        fi
    done

    echo ""
    echo "Enter equipment number to buy, or 0 to go back:"
    while true; do
        read -p ">>> " choice
        if [[ "$choice" == "0" ]]; then
            return 0
        fi
        if [[ -z "${choice##[0-9]*}" ]] && (( choice > 0 && choice < ${#DRINK_NAMES[@]} )); then
            buy_equipment "$choice"
            return $?
        fi
        echo "Invalid choice!"
    done
}

# Initialize drink data when this file is sourced
init_drinks
