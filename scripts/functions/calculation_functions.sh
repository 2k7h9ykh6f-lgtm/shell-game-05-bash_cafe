#!/usr/bin/env bash

calculate_profit () {
    footfall=$1
    cost=$2
    count=$3
    demand_pct=$4
    #calculate # of sales
    mult=$(( 5+RANDOM%10 ))
    #customers wanting this drink = footfall scaled by the weather-band demand
    want=$(( footfall*demand_pct/100 ))
    sales=$(( ((want - mult*cost)/2) * sales_mult ))
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
    #calculate profit
    profit=$(( income-count-$((sales/2)) ))
    return $profit
}