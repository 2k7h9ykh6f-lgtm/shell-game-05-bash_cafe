#!/usr/bin/env bash

# Weather type classification and drink demand modifiers
# Weather range: 20-34
#   Cold:  20-24 -> hot drinks boosted, iced drinks penalized
#   Mild:  25-29 -> neutral (all modifiers = 1)
#   Hot:   30-34 -> iced drinks boosted, hot drinks penalized

# Classify weather and set demand multipliers
# Sets globals: weather_type, hot_drink_mult, iced_drink_mult
get_weather_type() {
    local weather=$1
    if (( weather <= 24 )); then
        weather_type="cold"
        hot_drink_mult=2
        iced_drink_mult=1
    elif (( weather <= 29 )); then
        weather_type="mild"
        hot_drink_mult=1
        iced_drink_mult=1
    else
        weather_type="hot"
        hot_drink_mult=1
        iced_drink_mult=2
    fi
}

# Return the demand multiplier for a given drink type
# Args: $1 = drink type ("hot" or "iced")
# Uses globals: hot_drink_mult, iced_drink_mult
get_drink_mult() {
    local drink_type=$1
    if [[ "$drink_type" == "iced" ]]; then
        drink_mult=$iced_drink_mult
    else
        drink_mult=$hot_drink_mult
    fi
}
