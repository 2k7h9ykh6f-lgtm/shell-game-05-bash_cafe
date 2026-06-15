#!/usr/bin/env bash
. saves/save_load_functions.sh
. functions/menu_functions.sh
. functions/calculation_functions.sh
. functions/weather_functions.sh
. functions/upgrade_functions.sh
. functions/event_functions.sh

#counts the date
day_num=1
#expense is the cost of making a single coffee
expense=1
#sales_mult multiplies the number of sales everyday, can be increased using upgrades (not added yet)
#Uses percentage-based system: 100 = normal (1x), 200 = double (2x), 50 = half (0.5x)
sales_mult=100
#cash user has to spend
cash=100
shop_name=""
SAVE_FILE=""

#asks users to load old sessions or create new session (in menu_functions)
begin
#refer to save_load_functions to see save/load functions

#main loop
while true; do
    clear
    #output the day and weather
    center " Day $day_num "
    sleep 1
    tput clear
    weather=$(( 20+RANDOM%15 ))
    #centers cursor and outputs text in middle of terminal (in menu_functions)
    center "Weather: $weather"
    sleep 1
    tput clear

    #--- Daily Random Event ---
    # Save base values before event effects
    base_expense=$expense
    base_sales_mult=$sales_mult
    event_roll=$(( RANDOM % 100 ))
    daily_event=$(roll_daily_event "$event_roll")

    # Apply event effects (returns: new_expense, new_sales_mult, new_cash, cash_delta)
    if [[ "$daily_event" != "none" ]]; then
        # Display event to player BEFORE they make decisions
        format_event_message "$daily_event"
        echo ""
        format_effect_summary "$daily_event"
        echo ""

        # Read the four output lines from apply_event_effects
        {
            read -r event_expense
            read -r event_sales_mult
            read -r event_cash
            read -r event_cash_delta
        } < <(apply_event_effects "$daily_event" "$expense" "$sales_mult" "$cash")

        expense=$event_expense
        sales_mult=$event_sales_mult
        cash=$event_cash

        # Show effect summary and wait for player to acknowledge
        read -p "Press enter to continue: "
        clear
    fi

    #get user input (coffee_cnt and coffee_cost)
    tput rev;echo " Cash: $cash ";tput sgr0
    echo ""
    while true; do
        read -p "How many coffees do you wish make? >>> " coffee_cnt
        if (( coffee_cnt*expense > cash)) || [ ! -z "${coffee_cnt##[0-9]*}" ]; then
            echo "You cannot do that!"
        elif [ -z "$coffee_cnt" ]; then
            echo "invalid!"
	    :
        else
            break
        fi
    done
    while true; do
        read -p "How much do you wish to charge per coffee? >>> " coffee_cost
        if [ ! -z "${coffee_cost##[0-9]*}" ]; then
            echo "You cannot do that!"
	elif [ -z "$coffee_cnt" ]; then
	    :
        else
            break  
        fi
    done
    
    #opens shop, displays clock and calculates profit
    read -p "Press enter to open shop: "
    clear
    #Displays clock/timer (in menu_functions)
    open_shop
    echo -e "\e[1;7m $shop_name on Day $day_num \e[0m"  
    profit=0    
    #in calculation_functions
    calculate_profit "$weather" "$coffee_cost" "$coffee_cnt"
    
    #display the days summary
    echo "Profit: $profit"
    cash=$(( cash+profit ))
    
        if ! (( day_num % 7 )) ; then
            cash=$(( cash-50 ))
            echo ""
            echo -e "\e[31mYou paid '$'50 in weekly bills\e[0m"
        fi
    day_num=$(( day_num+1 ))

    # Restore base values after event effects (events only last one day)
    expense=$base_expense
    sales_mult=$base_sales_mult

    echo ""
    
    read -p "Press enter to continue: "
    clear
    #get next action from user (in menu_functions)
    day_menu
    #case statement for menu return (in menu_functions)
    handle_menu $?
done
