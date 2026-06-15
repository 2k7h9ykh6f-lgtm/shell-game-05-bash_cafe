#!/bin/bash
#!/usr/bin/env bash

new_save () {
while true; do
    read -p "What would you like to name your shop? >>> " shop_name
    if [[ $shop_name =~ [^a-zA-Z0-9_-] ]]; then
        echo "Shop name contains invalid characters, please try again!"
    else
        break
    fi
done
}

#outputs the list of saves in folder
get_saves () {
    saves=($(ls|grep "_save.txt"|awk -F "_save.txt" '{print $1}'))
    if [[ -z "$saves" ]]; then
        return 1
    fi    
    echo -e "\e[4m Your shops: \e[0m"
    for i in "${saves[@]}"; do
        echo " - $i"
    done
    return 0
}

#creates new save file and writes to it
save () {
    FILE="$shop_name"_save.txt
    > $FILE
    echo "day_num=$day_num" >> $FILE
    echo "cash=$cash" >> $FILE
    echo "sales_mult=$sales_mult" >> $FILE
    # --- stats ---
    echo "total_income=$total_income" >> $FILE
    echo "consecutive_profit_days=$consecutive_profit_days" >> $FILE
    echo "max_cash=$max_cash" >> $FILE
    echo "total_coffees_sold=$total_coffees_sold" >> $FILE
    echo "total_upgrades=$total_upgrades" >> $FILE
    # --- achievement flags ---
    echo "ach_first_hundred=$ach_first_hundred" >> $FILE
    echo "ach_five_hundred=$ach_five_hundred" >> $FILE
    echo "ach_thousand=$ach_thousand" >> $FILE
    echo "ach_tycoon=$ach_tycoon" >> $FILE
    echo "ach_streak_3=$ach_streak_3" >> $FILE
    echo "ach_streak_7=$ach_streak_7" >> $FILE
    echo "ach_streak_14=$ach_streak_14" >> $FILE
    echo "ach_savings_200=$ach_savings_200" >> $FILE
    echo "ach_savings_500=$ach_savings_500" >> $FILE
    echo "ach_savings_1000=$ach_savings_1000" >> $FILE
    echo "ach_first_upgrade=$ach_first_upgrade" >> $FILE
    echo "ach_survivor=$ach_survivor" >> $FILE
    echo "ach_coffee_100=$ach_coffee_100" >> $FILE
}

#asks user which load to open and reads it
load () {
    #get list of save files
    get_saves
    if [[ $? == 1 ]]; then
        echo "There are no saves to load"
        new_save
        return 0
    fi
    #check if save file exists
    while true; do
        read -p "Which shop would you like to load? >>> " input
        save_file=$input"_save.txt"
        if [[ $(ls) == *"$save_file"* ]]; then
            #load saves file, parse its content into global variables
            saved_data=$(cat $save_file)
            day_num=$(grep "day_num" <<< "$saved_data"|awk -F "=" '{print $2}')
            cash=$(grep "cash" <<< "$saved_data"|awk -F "=" '{print $2}')
            sales_mult=$(grep "sales_mult" <<< "$saved_data"|awk -F "=" '{print $2}')
            # --- stats (default to 0 for backward compatibility) ---
            total_income=$(grep "^total_income=" <<< "$saved_data"|awk -F "=" '{print $2}')
            total_income=${total_income:-0}
            consecutive_profit_days=$(grep "^consecutive_profit_days=" <<< "$saved_data"|awk -F "=" '{print $2}')
            consecutive_profit_days=${consecutive_profit_days:-0}
            max_cash=$(grep "^max_cash=" <<< "$saved_data"|awk -F "=" '{print $2}')
            max_cash=${max_cash:-0}
            total_coffees_sold=$(grep "^total_coffees_sold=" <<< "$saved_data"|awk -F "=" '{print $2}')
            total_coffees_sold=${total_coffees_sold:-0}
            total_upgrades=$(grep "^total_upgrades=" <<< "$saved_data"|awk -F "=" '{print $2}')
            total_upgrades=${total_upgrades:-0}
            # --- achievement flags (default to 0) ---
            ach_first_hundred=$(grep "^ach_first_hundred=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_first_hundred=${ach_first_hundred:-0}
            ach_five_hundred=$(grep "^ach_five_hundred=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_five_hundred=${ach_five_hundred:-0}
            ach_thousand=$(grep "^ach_thousand=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_thousand=${ach_thousand:-0}
            ach_tycoon=$(grep "^ach_tycoon=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_tycoon=${ach_tycoon:-0}
            ach_streak_3=$(grep "^ach_streak_3=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_streak_3=${ach_streak_3:-0}
            ach_streak_7=$(grep "^ach_streak_7=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_streak_7=${ach_streak_7:-0}
            ach_streak_14=$(grep "^ach_streak_14=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_streak_14=${ach_streak_14:-0}
            ach_savings_200=$(grep "^ach_savings_200=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_savings_200=${ach_savings_200:-0}
            ach_savings_500=$(grep "^ach_savings_500=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_savings_500=${ach_savings_500:-0}
            ach_savings_1000=$(grep "^ach_savings_1000=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_savings_1000=${ach_savings_1000:-0}
            ach_first_upgrade=$(grep "^ach_first_upgrade=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_first_upgrade=${ach_first_upgrade:-0}
            ach_survivor=$(grep "^ach_survivor=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_survivor=${ach_survivor:-0}
            ach_coffee_100=$(grep "^ach_coffee_100=" <<< "$saved_data"|awk -F "=" '{print $2}')
            ach_coffee_100=${ach_coffee_100:-0}
            break
        fi
            echo "This shop does not exist"
            sleep 1
    done
}