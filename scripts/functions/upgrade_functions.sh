#!/usr/bin/env bash

#Upgrade shop: spend cash to permanently unlock new drinks.
#Reads/writes the drink registry globals defined in bash_cafe.sh
#(drink_names, drink_unlock_cost, drink_unlocked) and `cash`.
upgrade_menu () {
    while true; do
        clear
        tput rev;echo " Upgrade Shop "; tput sgr0
        echo ""
        tput rev;echo " Cash: $cash ";tput sgr0
        echo ""
        #list owned drinks, and collect the indices still available to buy
        buy_idx=()
        for i in "${!drink_names[@]}"; do
            if [[ ${drink_unlocked[$i]} -eq 1 ]]; then
                echo " - ${drink_names[$i]} (owned)"
            else
                buy_idx+=("$i")
            fi
        done
        echo ""
        #nothing left to unlock
        if [[ ${#buy_idx[@]} -eq 0 ]]; then
            echo "You have unlocked every drink!"
            read -p "Press enter to go back: "
            return
        fi
        #print the buyable drinks with their one-time unlock cost
        n=1
        for i in "${buy_idx[@]}"; do
            printf "%s. %-12s \$%s\n" "$n" "${drink_names[$i]}" "${drink_unlock_cost[$i]}"
            n=$(( n+1 ))
        done
        back=$n
        echo "$back. Back"
        echo ""
        read -p "Enter your choice [1-$back] >>> " choice
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 )) || (( choice > back )); then
            echo "Invalid choice!"
            sleep 1
        elif (( choice == back )); then
            return
        else
            #map menu position back to the registry index and try to buy it
            pick=${buy_idx[$(( choice-1 ))]}
            cost=${drink_unlock_cost[$pick]}
            if (( cash < cost )); then
                echo "Not enough cash to unlock ${drink_names[$pick]}!"
                sleep 1
            else
                cash=$(( cash-cost ))
                drink_unlocked[$pick]=1
                echo "Unlocked ${drink_names[$pick]}! (-\$$cost)"
                sleep 1
            fi
        fi
    done
}
