#!/usr/bin/bash

# Check Tether rates
LC_NUMERIC="en_US.utf8"
printf "\nUSDT/USD Rates\n\n"

CLIBJSON=$(curl -s "https://coinlib.io/api/v1/coin?key=fdcd5af7010ab1e0&pref=USD&symbol=USDT")
ENAMES=($(printf "%s\n" "${CLIBJSON}" | jq -r ".markets[0]|.exchanges[]|.name"))
PRICES=($(printf "%s\n" "${CLIBJSON}" | jq -r ".markets[0]|.exchanges[]|.price"))

CLIBAVG=0
printf "CLIB:\n"
for i in {0..5}; do
	if [[ -n "${PRICES[$i]}" ]]; then
		printf "%s\t%.6f\n" "${ENAMES[$i]}" "${PRICES[$i]}"
		CLIBAVG=$(printf "%s+%s\n" "${CLIBAVG}" "${PRICES[$i]}" | bc -l)
	fi
done

CMCUSDT=$(~/_Scripts/markets/cmc.sh -s8 usdt usd)
printf "CMC:\t%.6f\n" "${CMCUSDT}"
CGKUSDT=$(~/_Scripts/markets/cgk.sh -s8 usdt usd 2>/dev/null)
printf "CGK:\t%.6f\n" "${CGKUSDT}"
printf "\nAvg:\t%.6f\n\n" "$(printf "scale=8;(%s+%s+%s)/5\n" "${CLIBAVG}" "${CMCUSDT}" "${CGKUSDT}" | bc -l)"

# Coinlib.io
# fdcd5af7010ab1e0
