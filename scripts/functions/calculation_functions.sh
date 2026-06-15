#!/usr/bin/env bash
. saves/save_load_functions.sh

calculate_profit () {
    weather=$1
    cost=$2
    count=$3
    #drink_mult: weather-based demand modifier for the chosen drink type
    #  =2 for matching drink (hot in cold weather, iced in hot weather)
    #  =1 otherwise. Defaults to 1 for backward compatibility.
    d_mult=${4:-1}
    #calculate # of sales
    mult=$(( 5+RANDOM%10 ))
    sales=$(( $(( $(($((weather-20))*10 - mult*cost))/2 ))*sales_mult*d_mult))
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
