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
    #apply today's event customer-flow modifier (100 = no change)
    sales=$(( sales*event_customer_mult/100 ))
    echo "Sales: $sales"
    #calculate income
    if (( sales > count )); then
        income=$(( count*cost ))
    else
        income=$(( sales*cost ))
    fi
    #apply today's event revenue modifier (100 = no change)
    income=$(( income*event_revenue_mult/100 ))
    echo "Income: $income"
    #calculate profit; cost of goods scales with today's event cost modifier (100 = no change)
    cost_of_goods=$(( count*event_cost_mult/100 ))
    profit=$(( income-cost_of_goods-$((sales/2)) ))
    return $profit
}