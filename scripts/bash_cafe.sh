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
#cash user has to spend
cash=100
#employee system
employee_count=0
employee_wage=5
#base max coffee production (increased by employees)
base_max_coffee=50
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
    max_coffee=$(( base_max_coffee + employee_count * 20 ))
    echo "Max coffees you can make today: $max_coffee (base $base_max_coffee + $employee_count employees x 20)"
    echo ""
    while true; do
        read -p "How many coffees do you wish make? >>> " coffee_cnt
        if [ ! -z "${coffee_cnt##[0-9]*}" ] || [ -z "$coffee_cnt" ]; then
            echo "Please enter a valid number!"
        elif (( coffee_cnt*expense > cash )); then
            echo "You don't have enough cash! (need $(( coffee_cnt*expense )))"
        elif (( coffee_cnt > max_coffee )); then
            echo "You can only make $max_coffee coffees! Hire more employees to increase capacity."
        else
            break
        fi
    done
    while true; do
        read -p "How much do you wish to charge per coffee? >>> " coffee_cost
        if [ ! -z "${coffee_cost##[0-9]*}" ]; then
            echo "You cannot do that!"
        elif [ -z "$coffee_cost" ]; then
            echo "Please enter a valid number!"
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

    #deduct employee wages
    if (( employee_count > 0 )); then
        total_wages=$(( employee_count * employee_wage ))
        cash=$(( cash - total_wages ))
        echo ""
        echo -e "\e[33mPaid \$$total_wages in employee wages ($employee_count employees x \$$employee_wage)\e[0m"
    fi

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
