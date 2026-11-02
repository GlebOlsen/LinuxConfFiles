#!/usr/bin/env bash

set -u -o pipefail

latitude=55.76
longitude=12.10
agent='PolybarWeather/1.0 (local desktop status widget)'
cache_dir=${XDG_CACHE_HOME:-"${HOME}/.cache"}/polybar
forecast_cache=$cache_dir/weather.json
sun_cache=$cache_dir/sun.json
mkdir -p "$cache_dir"

fetch() {
    local url=$1 cache=$2 temporary
    temporary=$(mktemp "${cache}.XXXXXX") || return 1

    if curl -fsS --max-time 15 -A "$agent" "$url" -o "$temporary" &&
        jq -e . "$temporary" >/dev/null 2>&1; then
        mv "$temporary" "$cache"
    else
        rm -f "$temporary"
    fi

    [[ -s "$cache" ]]
}

forecast_url="https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=${latitude}&lon=${longitude}"
fetch "$forecast_url" "$forecast_cache" || exit 0

# Sunrise changes once per day, so reuse today's cached response.
today=$(date +%F)
sun_cache_date=$(date -r "$sun_cache" +%F 2>/dev/null || true)
if [[ $sun_cache_date != "$today" ]]; then
    offset=$(date +%:z)
    offset=${offset/+/%2B}
    sun_url="https://api.met.no/weatherapi/sunrise/3.0/sun?lat=${latitude}&lon=${longitude}&date=${today}&offset=${offset}"
    fetch "$sun_url" "$sun_cache" || true
fi

read -r symbol temperature humidity direction wind < <(
    jq -r '.properties.timeseries[0].data as $data |
        $data.instant.details as $details |
        ["N", "NE", "E", "SE", "S", "SW", "W", "NW"] as $compass |
        [($data.next_1_hours.summary.symbol_code //
          $data.next_6_hours.summary.symbol_code //
          $data.next_12_hours.summary.symbol_code // "unknown"),
         ($details.air_temperature | round),
         ($details.relative_humidity | round),
         $compass[((($details.wind_from_direction + 22.5) / 45 | floor) % 8)],
         ($details.wind_speed | round)] | @tsv' "$forecast_cache"
) || exit 0

case "$symbol" in
    clearsky*) icon='' ;;
    fair*) icon='' ;;
    partlycloudy*) icon='' ;;
    cloudy*) icon='' ;;
    fog*) icon='' ;;
    *thunder*) icon='' ;;
    *snow*|*sleet*) icon='' ;;
    *rainshowers*|*rain*) icon='' ;;
    *) icon='' ;;
esac

sun_text=
if read -r sunrise sunset < <(jq -r '
    [.properties.sunrise.time, .properties.sunset.time] |
    map(if . then split("T")[1][0:5] else "" end) | @tsv' "$sun_cache" 2>/dev/null) &&
    [[ -n $sunrise && -n $sunset ]]; then
    sun_text="  ${sunrise}  ${sunset}"
fi

printf ' %s %s° %s%% %s %s m/s%s ' \
    "$icon" "$temperature" "$humidity" "$direction" "$wind" "$sun_text"
