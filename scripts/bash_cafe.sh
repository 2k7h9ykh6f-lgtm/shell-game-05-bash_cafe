#!/usr/bin/env bash
. saves/save_load_functions.sh
. functions/menu_functions.sh
. functions/calculation_functions.sh
. functions/weather_functions.sh
. functions/upgrade_functions.sh

#counts the date
day_num=1
#expense is the cost of making a single coffee (overridden by drink selection)
expense=1
#sales_mult multiplies the number of sales everyday, can be increased using upgrades (not added yet)
sales_mult=1
#cash user has to spend
cash=100
shop_name=""
SAVE_FILE=""

# Drink selection state (set by drink_menu / get_drink_order in menu_functions.sh)
selected_drink=0
drink_count=0
drink_price=0
drink_expense=1

#asks users to load old sessions or create new session (in menu_functions)
begin
#refer to save_load_functions to see save/load functions

#main loop
while true; do
    clear

    # Check if any new drinks are unlocked by cash threshold
    check_cash_unlocks

    #output the day and weather
    center " Day $day_num "
    sleep 1
    tput clear
    weather=$(( 20+RANDOM%15 ))
    #centers cursor and outputs text in middle of terminal (in menu_functions)
    center "Weather: $weather"
    sleep 1
    tput clear

    # Let player choose which drink to sell today (in menu_functions)
    drink_menu
    clear

    #get user input (drink_count and drink_price for selected drink)
    tput rev;echo " Cash: $cash ";tput sgr0
    echo ""
    echo "Selling: ${DRINK_NAMES[$selected_drink]} (cost to make: \$${DRINK_MAKE_COSTS[$selected_drink]})"
    echo ""
    get_drink_order

    #opens shop, displays clock and calculates profit
    read -p "Press enter to open shop: "
    clear
    #Displays clock/timer (in menu_functions)
    open_shop
    echo -e "\e[1;7m $shop_name on Day $day_num \e[0m"
    echo "Selling: ${DRINK_NAMES[$selected_drink]}"
    echo ""
    profit=0
    #in calculation_functions (now supports per-drink pricing)
    calculate_profit "$weather" "$drink_price" "$drink_count" "$selected_drink"

    #display the days summary
    echo ""
    echo "Profit: $profit"
    cash=$(( cash+profit ))

        if ! (( day_num % 7 )) ; then
            cash=$(( cash-50 ))
            echo ""
            echo -e "\e[31mYou paid '$'50 in weekly bills\e[0m"
        fi
    day_num=$(( day_num+1 ))
    echo ""

    read -p "Press enter to continue: "
    clear
    #get next action from user (in menu_functions)
    day_menu
    #case statement for menu return (in menu_functions)
    handle_menu $?
done
