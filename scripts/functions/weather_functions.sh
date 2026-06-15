#!/usr/bin/env bash

# --- Weather tuning constants ---------------------------------------------
# Temperature is an integer 0..WEATHER_MAX. Each day is classified into a
# band, and the band shifts demand toward hot or cold drinks.
WEATHER_MAX=40          # weather rolls in 0..WEATHER_MAX
COLD_MAX=12             # weather <= COLD_MAX -> "cold"
HOT_MIN=28              # weather >= HOT_MIN  -> "hot"; otherwise "mild"

# Per-band demand multipliers (percent) for each drink type.
COLD_DAY_HOT=150;  COLD_DAY_COLD=60
MILD_DAY_HOT=100;  MILD_DAY_COLD=100
HOT_DAY_HOT=60;    HOT_DAY_COLD=150
# --------------------------------------------------------------------------

# get_weather: rolls the day's weather and sets the globals used by the main
# loop:
#   weather      - temperature (0..WEATHER_MAX)
#   weather_band - cold | mild | hot
#   footfall     - total potential customers (rises with temperature, floored
#                  so cold days still have customers)
get_weather () {
    weather=$(( RANDOM % (WEATHER_MAX + 1) ))
    if (( weather <= COLD_MAX )); then
        weather_band="cold"
    elif (( weather >= HOT_MIN )); then
        weather_band="hot"
    else
        weather_band="mild"
    fi
    # weather still drives foot traffic, but never down to zero
    footfall=$(( 20 + weather * 4 ))
}

# drink_demand <band> <type>: echoes the demand multiplier (percent) for a
# drink type ("hot" or "cold") on the given weather band.
drink_demand () {
    local band=$1
    local type=$2
    case "$band" in
        cold) [[ $type == hot ]] && echo "$COLD_DAY_HOT" || echo "$COLD_DAY_COLD" ;;
        hot)  [[ $type == hot ]] && echo "$HOT_DAY_HOT"  || echo "$HOT_DAY_COLD"  ;;
        *)    [[ $type == hot ]] && echo "$MILD_DAY_HOT" || echo "$MILD_DAY_COLD" ;;
    esac
}
