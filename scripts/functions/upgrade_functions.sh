#!/usr/bin/env bash

#hire_employees: spend a recurring daily wage to hire staff who reduce the
#waste from unsold coffees. Called from the Upgrade option in handle_menu.
hire_employees () {
    clear
    echo -e "\e[1;7m Upgrades: Hire Employees \e[0m"
    echo ""
    echo "Each employee reduces the cost of unsold (wasted) coffees."
    echo "Employees are paid \$$wage each per day at daily settlement."
    echo ""
    echo "Current employees: $employees"
    echo "Current daily wage cost: \$$(( employees*wage ))"
    tput rev;echo " Cash: $cash ";tput sgr0
    echo ""
    #get number to hire; mirrors the integer validation used for coffee_cnt
    while true; do
        read -p "How many employees would you like to hire? (0 to cancel) >>> " hire_cnt
        if [ -z "$hire_cnt" ] || [ ! -z "${hire_cnt##[0-9]*}" ]; then
            echo "You cannot do that!"
        else
            break
        fi
    done
    if (( hire_cnt == 0 )); then
        return
    fi
    employees=$(( employees+hire_cnt ))
    echo ""
    echo "Hired $hire_cnt employee(s). You now have $employees."
    echo "New daily wage cost: \$$(( employees*wage ))"
    sleep 2
}
