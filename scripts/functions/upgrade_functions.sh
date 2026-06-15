#!/usr/bin/env bash

upgrade_menu () {
    clear
    echo -e "\e[1;7m Upgrade Shop \e[0m"
    echo ""
    echo "=== Current Staff ==="
    echo "Employees: $employee_count"
    echo "Daily wage per employee: \$$employee_wage"
    if (( employee_count > 0 )); then
        echo "Total daily wages: \$$(( employee_count * employee_wage ))"
    fi
    echo "Current max coffee capacity: $(( base_max_coffee + employee_count * 20 ))"
    echo ""
    echo "=== Hire / Manage ==="
    echo "1. Hire an employee (cost: \$$employee_wage/day, +20 coffee capacity, -10% waste)"
    echo "2. Fire an employee (save \$$employee_wage/day, -20 coffee capacity)"
    echo "3. Back to main menu"
    echo ""
    while true; do
        read -p "Enter your choice [1-3] >>> " choice
        case $choice in
            1)
                if (( cash < employee_wage )); then
                    echo "Not enough cash to hire! You need at least \$$employee_wage."
                    sleep 1
                else
                    employee_count=$(( employee_count + 1 ))
                    echo -e "\e[32mHired a new employee! You now have $employee_count employee(s).\e[0m"
                    echo "Max coffee capacity: $(( base_max_coffee + employee_count * 20 ))"
                    sleep 1
                fi
                break
                ;;
            2)
                if (( employee_count <= 0 )); then
                    echo "You have no employees to fire!"
                    sleep 1
                else
                    employee_count=$(( employee_count - 1 ))
                    echo -e "\e[31mFired an employee. You now have $employee_count employee(s).\e[0m"
                    echo "Max coffee capacity: $(( base_max_coffee + employee_count * 20 ))"
                    sleep 1
                fi
                break
                ;;
            3)
                break
                ;;
            *)
                echo "Invalid choice!"
                ;;
        esac
    done
    save
}
