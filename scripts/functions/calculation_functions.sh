#!/usr/bin/env bash

calculate_profit () {
    weather=$1
    cost=$2
    count=$3
    demand=$4
    #calculate # of sales
    mult=$(( 5+RANDOM%10 ))
    sales=$(( $(( $(($((weather-20))*demand - mult*cost))/2 ))*sales_mult))
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
    #calculate profit (subtract the per-unit make cost for the selected drink)
    profit=$(( income-count*expense-$((sales/2)) ))
    return $profit
}