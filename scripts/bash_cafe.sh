#!/usr/bin/env bash
. saves/save_load_functions.sh
. functions/menu_functions.sh
. functions/calculation_functions.sh
. functions/weather_functions.sh
. functions/upgrade_functions.sh

#counts the date
day_num=1
#expense is the cost of making a single coffee
expense=1
#sales_mult multiplies the number of sales everyday, can be increased using upgrades (not added yet)
sales_mult=1
#drink menu registry (parallel arrays, indexed by drink); Coffee is unlocked by default
drink_names=("Coffee" "Latte" "Iced Coffee")
#cost to make one unit of each drink (sets `expense` for the selected drink)
drink_make_cost=(1 3 2)
#suggested charge per drink, shown as a hint (player still sets the price)
drink_suggested=(3 5 4)
#demand modifier: higher means more sales per warm degree of weather
drink_demand=(10 8 12)
#one-time purchase price to unlock each drink in the Upgrade menu (0 = free)
drink_unlock_cost=(0 80 60)
#unlock state: 1 = available to sell, 0 = locked
drink_unlocked=(1 0 0)
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
    #get user input (coffee_cnt and coffee_cost)
    tput rev;echo " Cash: $cash ";tput sgr0
    echo ""
    #choose which unlocked drink to sell today (sets global `sel`)
    select_drink
    expense=${drink_make_cost[$sel]}
    demand=${drink_demand[$sel]}
    drink=${drink_names[$sel]}
    echo ""
    while true; do
        read -p "How many $drink do you wish to make? >>> " coffee_cnt
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
        read -p "How much do you wish to charge per $drink? (suggested: \$${drink_suggested[$sel]}) >>> " coffee_cost
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
    calculate_profit "$weather" "$coffee_cost" "$coffee_cnt" "$demand"
    
    #display the days summary
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
