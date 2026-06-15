#!/usr/bin/env bash
. saves/save_load_functions.sh
. functions/menu_functions.sh
. functions/calculation_functions.sh
. functions/weather_functions.sh
. functions/upgrade_functions.sh

#counts the date
day_num=1
#expense is the cost of making a single drink
expense=1
#sales_mult multiplies the number of sales everyday, can be increased using upgrades (not added yet)
sales_mult=1
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
    #roll the day's weather: sets weather, weather_band, footfall (in weather_functions)
    get_weather
    #centers cursor and outputs text in middle of terminal (in menu_functions)
    center "Weather: $weather ($weather_band)"
    sleep 1
    tput clear
    #get user input for each drink line (hot + cold)
    tput rev;echo " Cash: $cash ";tput sgr0
    echo ""
    #reset the day's orders so combined affordability is computed fresh
    hot_cnt=0; cold_cnt=0
    #prompt count + price per drink line (in menu_functions)
    prompt_drink "hot"
    prompt_drink "cold"

    #opens shop, displays clock and calculates profit
    read -p "Press enter to open shop: "
    clear
    #Displays clock/timer (in menu_functions)
    open_shop
    echo -e "\e[1;7m $shop_name on Day $day_num \e[0m"
    #profit per drink line; the weather band shifts demand toward hot or cold
    #(calculate_profit in calculation_functions, drink_demand in weather_functions)
    hot_profit=0
    cold_profit=0
    if (( hot_cnt > 0 )); then
        echo -e "\e[1mHot drinks:\e[0m"
        calculate_profit "$footfall" "$hot_cost" "$hot_cnt" "$(drink_demand "$weather_band" hot)"
        hot_profit=$profit
    fi
    if (( cold_cnt > 0 )); then
        echo -e "\e[1mCold drinks:\e[0m"
        calculate_profit "$footfall" "$cold_cost" "$cold_cnt" "$(drink_demand "$weather_band" cold)"
        cold_profit=$profit
    fi
    profit=$(( hot_profit + cold_profit ))

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
