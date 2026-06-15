#!/usr/bin/env bash

calculate_profit () {
    weather=$1
    cost=$2
    count=$3
    #calculate # of sales
    mult=$(( 5+RANDOM%10 ))
    sales=$(( $(( $(($((weather-20))*10 - mult*cost))/2 ))*sales_mult))
    if [[ ! $sales -gt 0 ]]; then
        sales=0
    fi
    echo "Sales: $sales"
    #calculate income
    if (( sales > count )); then
        income=$(( count*cost ))
    else
        income=$(( sales*cost ))
    fi
    echo "Income: $income"
    #calculate waste reduction from employees (each employee reduces waste by 10%, max 50%)
    waste_pct=$(( employee_count * 10 ))
    if (( waste_pct > 50 )); then waste_pct=50; fi
    unsold=$(( count - sales ))
    if (( unsold < 0 )); then unsold=0; fi
    waste_saved=$(( unsold * waste_pct / 100 ))
    effective_cost=$(( count - waste_saved ))
    if (( waste_saved > 0 )); then
        echo "Employees saved \$$waste_saved in waste (${waste_pct}% reduction)"
    fi
    #calculate profit
    profit=$(( income-effective_cost-$((sales/2)) ))
    return $profit
}