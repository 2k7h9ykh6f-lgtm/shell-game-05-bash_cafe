#!/usr/bin/env bash
. saves/save_load_functions.sh

# ----------------------------------------------------------
# drink_menu: Display unlocked drinks and let the player
# choose which drink to sell today. Sets the global variable
# selected_drink to the chosen drink index.
# ----------------------------------------------------------
drink_menu () {
    clear
    echo -e "\e[4m=== Drink Menu ===\e[0m"
    echo ""

    # Build list of unlocked drinks
    local unlocked_list=()
    for i in "${!DRINK_NAMES[@]}"; do
        if is_drink_unlocked "$i"; then
            unlocked_list+=("$i")
        fi
    done

    if (( ${#unlocked_list[@]} == 1 )); then
        # Only basic coffee is unlocked
        selected_drink=${unlocked_list[0]}
        echo "Only ${DRINK_NAMES[$selected_drink]} is available."
        return 0
    fi

    # Display unlocked drinks
    local display_idx=1
    for i in "${unlocked_list[@]}"; do
        local bonus_text=""
        if (( DRINK_DEMAND_BONUSES[$i] > 0 )); then
            bonus_text=" (+${DRINK_DEMAND_BONUSES[$i]}% demand)"
        fi
        echo "  $display_idx. ${DRINK_NAMES[$i]}  (cost: \$${DRINK_MAKE_COSTS[$i]}/cup, suggested price: \$${DRINK_BASE_PRICES[$i]})$bonus_text"
        display_idx=$((display_idx + 1))
    done

    echo ""
    while true; do
        read -p "Which drink would you like to sell today? [1-$((display_idx-1))] >>> " choice
        if [[ -z "${choice##[0-9]*}" ]] && (( choice >= 1 && choice < display_idx )); then
            selected_drink=${unlocked_list[$((choice-1))]}
            break
        fi
        echo "Invalid choice!"
    done

    echo "Selected: ${DRINK_NAMES[$selected_drink]}"
    sleep 1
    return 0
}

# ----------------------------------------------------------
# get_drink_order: Ask how many units and at what price for
# the selected drink. Sets global variables:
#   drink_count, drink_price, drink_expense
# ----------------------------------------------------------
get_drink_order () {
    local make_cost=${DRINK_MAKE_COSTS[$selected_drink]}
    drink_expense=$make_cost

    # How many to make
    while true; do
        read -p "How many ${DRINK_NAMES[$selected_drink]}s do you wish to make? >>> " drink_count
        if (( drink_count * make_cost > cash )) || [ ! -z "${drink_count##[0-9]*}" ]; then
            echo "You cannot do that!"
        elif [ -z "$drink_count" ]; then
            echo "Invalid!"
            :
        else
            break
        fi
    done

    # How much to charge
    while true; do
        read -p "How much do you wish to charge per ${DRINK_NAMES[$selected_drink]}? >>> " drink_price
        if [ ! -z "${drink_price##[0-9]*}" ]; then
            echo "You cannot do that!"
        elif [ -z "$drink_price" ]; then
            :
        else
            break
        fi
    done
}

center () {
    #get size of terminal window
    width=$(tput cols)
    height=$(tput lines)
    #center cursor into center of terminal and echo
    str="$1"
    length=${#str}
    tput cup $((height / 2)) $(((width / 2) - (length / 2)))
    if [[ $str == *"Day"* ]];then
        tput rev;echo "$str";  tput sgr0
    else
        echo "$str"
    fi

}

#functions get_save, new_save, save, and load are in save_load_functions
begin () {
    #gets all saves from file and puts them in array
    get_saves
    #return of 0 means theres are previous save files to open
    if [[ $? == 0 ]]; then
        read -p "Would you like to load your saved game? (y/n) >>> " input
        if [[ $input == "y" ]]; then
            clear
            #opens save file and writes data into global variables
            load
        else
            #
            new_save
            save
        fi
    else
        new_save
        save
    fi
}

open_shop () {
    #displays simple timer
    m=15
    h=9
    t="am"
    width=$(tput cols)
    height=$(tput lines)-4
    spacer=""
    for ((c=0; c <=$((height/2)); c++)); do
        spacer+="\n"
    done
    while (( h != 5 )); do
    echo -e $spacer
    printf "%*s\n" $((( 12+width )/2 )) "$h:$m $t"
        if (( m == 45 )); then
            m=00
            if (( h == 11 )); then
                t="pm"
            elif (( h == 12 )); then
                h=00
            fi
            h=$(( h+1 ))
        fi
        m=$(( m+15 ))
        sleep 0.01
        clear
    done
}

day_menu () {
    #displays menu options and gets user input
    tput clear
    title="Day Options"
    in=$2
    options="Continue,Upgrade,New_Save,Save_As,Load_Game,Exit"
    arr=$(echo $options | tr "," "\n")
    x=0
    y=0
    
    tput cup $y $x
    tput rev;echo " $title "; tput sgr0
    y=$((y+2))
    i=0
    for n in $arr
    do
        tput cup $(( y+$i )) $x
            str="$n" 
            echo "$((i+1)). $str"
        i=$((i+1))
    done
    tput cup $(( y+$i+1 )) $x
    while true; do
        read -p "Enter your choice [1-$i] >>> " choice
        if (( $choice < 1 )) || (( $choice > $i )); then
            echo "Invalid choice!"
        else
            return $choice
        fi
    done
}

#handle input from user after menu is displayed
#save, new_save, and load are in save_load_functions.sh
handle_menu () {
    clear
    case "$1" in
    #Continue: save game then continue
    1)  save
        return 1 ;;
    #Upgrade: open the upgrade shop
    2)  show_upgrade_menu
        save
        return 2 ;;
    #New_Save: Get save name and creates new save
    3)  new_save
        save
        return 3 ;;
    #Save_As: Save overwrites current save file under shop_name
    4)  save
        return 4 ;;
    #Load_Game: Save current session then load new game
    5)  save
        load
        return 5 ;;
    #Exit: Save current session then exit
    6)  save
        exit 0 ;;
    *)  echo "ERROR"
        return 10 ;;
    esac
}
