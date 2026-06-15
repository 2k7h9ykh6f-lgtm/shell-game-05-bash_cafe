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
    #calculate income and units actually sold
    if (( sales > count )); then
        sold=$count
    else
        sold=$sales
    fi
    income=$(( sold*cost ))
    echo "Income: $income"
    #employees recover part of the cost of unsold (wasted) coffees
    #25% recovered per employee, capped at 100% (4 employees = zero waste)
    wasted=$(( count-sold ))
    rate=$(( employees*25 ))
    if (( rate > 100 )); then
        rate=100
    fi
    recovered=$(( wasted*rate/100 ))
    if (( recovered > 0 )); then
        echo "Waste recovered by employees: $recovered"
    fi
    #calculate profit
    profit=$(( income-count-$((sales/2))+recovered ))
    return $profit
}