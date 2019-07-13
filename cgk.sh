#!/usr/bin/bash
#
# Cgk.sh -- Coingecko.com API Access
# v0.3 - 2019/jul/02   by mountaineerbr

## Manual and help
# printf "cgk [amount] [currency_id] [vs_currency]"
HELP_LINES="NAME
 	\033[01;36mCgk.sh -- Coingecko.com API Access\033[00m


SYNOPSIS
	cgk.sh \e[0;35;40m[-c|-h|-j|-k|-l]\033[00m

	cgk.sh \e[0;35;40m[-s|-t]\033[00m \e[0;33;40m[AMOUNT]\033[00m \e[0;32;40m[CURRENCY_ID]\033[00m \e[0;31;40m[VS_CURRENCY]\033[00m


DESCRIPTION
	Coin Gecko also has a public API. It is a little harder to use than
	other exchange APIs because you need to specify the id of the
	FROM_CURRENCY (not the usual \"codes\"), whereas VS_CURRENCY does use
	common codes for crypto and central bank currencies (*UPDATE:  it now
	tries to grep currency id automatically!).
	
	You can see Lists of these currencies running the function with the
	argument \"-l\" 

	This programme fetches updated currency rates from the internet	and can
	convert any amount of one supported currency into another.

	Default precision is 16. Trailing zeroes are trimmed by default.

	Usage example:
		
		(1)

		$ cgk.sh -s3 0.5 djf cny 


OPTIONS
		-b 	Activate Bank Currency Mode: FROM_CURRENCY can be
			any central bank currency supported by CGK.

		-h 	Show this help.

		-j 	Fetch JSON file and send to STOUT.

		-k 	Fetch tickers for currency.

		-l 	List supported currencies.

		-m 	Market Capitulation table.
	 	
		-s 	Set scale ( decimal plates ).

		-t 	No Timestamp in Coingecko.com JSON.
			Updates are usually around every 5 minutes.


BUGS
 	This programme is distributed without support or bug corrections.
	Licensed under GPLv3 and above.
		"

# Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit
fi
# Parse options
# If the very first character of the option string is a colon (:) then getopts will not report errors and instead will provide a means of handling the errors yourself.
while getopts ":bmlhjk:s:t" opt; do
  case ${opt} in
	b )
		BANK=1
		;;
	m ) ## Make Market Cap Table
		MCAP=1
		;;
  	l ) ## List available currencies
		LISTS=1
		;;
	h ) # Show Help
		echo -e "${HELP_LINES}"
		exit 0
		;;
	j ) # Print JSON
		# All CoinGecko Bitcoin-based rates
		curl -X GET "https://api.coingecko.com/api/v3/exchange_rates" -H  "accept: application/json"
		exit
		;;
	k ) # Tickers
		#read -r -p "Which currency id to see exchange tickers? " EX
		curl -X GET "https://api.coingecko.com/api/v3/coins/${OPTARG,,}/tickers" -H  "accept: application/json" | jq .
		exit
		;;
	s ) # Decimal plates
		SCL=${OPTARG}
		;;
	t ) # Print Timestamp with result
		TIMEST=1
		;;
	\? )
		echo "Invalid Option: -$OPTARG" 1>&2
		exit 1
		;;
  esac
done
shift $((OPTIND -1))

## Print currency lists
listsf() {
	printf "\nList of supported FROM_CURRENCY IDs\n\n"
	curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H  "accept: application/json" | jq -r '.[] | "\(.name) = \(.id)"' | column -s '=' -c 60 -T 1 -e -t -o '|' -N '-----FROM_CURRENCY NAME----,---------------ID---------------'
	printf "\n\n"
	printf "List of supported VS_CURRENCY Codes\n\n"
	curl -s -X GET "https://api.coingecko.com/api/v3/simple/supported_vs_currencies" -H  "accept: application/json" | jq -r '.[]' | column -c 100
	printf "\n"
}
if [[ -n "${LISTS}" ]]; then
	listsf
	exit
fi

## Market Cap function		
mcapf() {
	CGKGLOBAL=$(curl -sX GET "https://api.coingecko.com/api/v3/global" -H  "accept: application/json")

	CGKTIME=$(printf "%s" "${CGKGLOBAL}" | jq -r '.data.updated_at')
	date -d@"$CGKTIME" "+## %FT%T%Z%n"
	
	LC_NUMERIC="en_US.utf8"
	printf "CRYPTO MARKET CAPITAL\n"
	printf "Markets       : %s\n" "$(printf "%s" "${CGKGLOBAL}" | jq -r '.data.markets')"
	printf "Active cryptos: %s\n" "$(printf "%s" "${CGKGLOBAL}" | jq -r '.data.active_cryptocurrencies')"

	printf "\n## ICOs info\n"
	printf "Upcoming      : %s\n" "$(printf "%s" "${CGKGLOBAL}" | jq -r '.data.upcoming_icos')"
	printf "Ongoing       : %s\n" "$(printf "%s" "${CGKGLOBAL}" | jq -r '.data.ongoing_icos')"
	printf "Ended         : %s\n" "$(printf "%s" "${CGKGLOBAL}" | jq -r '.data.ended_icos')"

	printf "\n## Total market volume\n"
	printf "USD           : %s\n" "$(printf "%'.2f\n" "$(printf "%s" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.usd')")"
	printf "BRL           : %s\n" "$(printf "%'.2f\n" "$(printf "%s" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.brl')")"
	printf "Change(%%/24h) : "
	printf "%.4f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.market_cap_change_percentage_24h_usd')"

	printf "\n## Dominance\n"
	printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.market_cap_percentage | keys_unsorted[] as $k | "\($k) = \(.[$k])"' | column -s '=' -t -o "=" | awk -F"=" '{ printf "%s", toupper($1); printf("%16.4f %%\n", $2); }'
	printf "\n"

	printf "## Coin volume (in USD)\n"
	DOMINANCEARRAY=($(curl -sX GET "https://api.coingecko.com/api/v3/global" -H  "accept: application/json" | jq -r '.data.market_cap_percentage | keys_unsorted[]'))
	for i in "${DOMINANCEARRAY[@]}"; do
		printf "%s %'19.2f\n" "${i^^}" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r ".data.total_volume.${i}")" 2>/dev/null
	done

	exit
}
if [[ -n "${MCAP}" ]]; then
mcapf
fi

## Check for internet connection function
icheck() {
if [[ -z "${RESULT}" ]] &&
	   ! ping -q -w7 -c2 8.8.8.8 &> /dev/null; then
	printf "Bad internet connection.\n"
fi
}

## Set default scale if no custom scale
SCLDEFAULTS=16
if [[ -z ${SCL} ]]; then
	SCL="${SCLDEFAULTS}"
fi

# Set equation arguments
if ! [[ ${1} =~ [0-9] ]]; then
	set -- 1 ${@:1:2}
fi

if [[ -z ${3} ]]; then
	set -- ${@:1:2} usd
fi


## Bank currency rate function
bankf() {
	BTCBANK="$(${0} bitcoin ${2,,})"
	BTCTOCUR="$(${0} bitcoin ${3,,})"
	if [[ -n "${TIMEST}" ]]; then
		printf "%s\n" "No timestamp." 1>&2
	fi
	#echo $1-$2-$3-$4-$SCL-"${BTCTOCUR}"-"$BTCBANK"
	
	if [[ -z ${BTCBANK} ]]; then
		printf "%s\n" "${BTCBANK}" 1>&2
		printf "Bank currency function error\n" 1>&2
		exit 1
	elif [[ -z ${BTCTOCUR} ]]; then
		printf "%s\n" "${BTCTOCUR}" 1>&2
		printf "Bank currency function error\n" 1>&2
		exit 1
	fi
	# Calc result
	RESULT="$(printf "scale=%s; (%s*%s)/%s\n" "${SCL}" "${1}" "${BTCTOCUR}" "${BTCBANK}" | bc -l)"
	printf "%s\n" "${RESULT}"
	# Check for bad internet
	icheck
	exit
}
if [[ -n "${BANK}" ]]; then
	bankf ${*}
	exit
fi

## Check you are not requesting some unsupported FROM_CURRENCY
CLIST="$(curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H  "accept: application/json" | jq -r '[.[] | { key: .symbol, value: .id } ] | from_entries')"
if ! printf "%s\n" "${CLIST}" | jq -r .[] | grep -qi "^${2}$" &&
	! printf "%s\n" "${CLIST}" | jq -r keys[] | grep -qi "^${2}$"; then
	printf "Unsupported FROM_CURRENCY %s at CGK.\n" "${2^^}" 1>&2
	printf "Try the Bank currency function or\n" 1>&2
	printf "try \"-l\" to grep a list of suported currencies.\n" 1>&2
	exit 1
fi

## Check you are not requesting some unsupported TO_CURRENCY
TOLIST="$(curl -s https://api.coingecko.com/api/v3/simple/supported_vs_currencies | jq -r '.[]')"
CHECKTC=$(printf "%s\n" "${TOLIST}" | grep -i "^${3}$")
if [[ -z "${BANK}" ]] && [[ -z "${CHECKTC}" ]]; then
	printf "Unsupported TO_CURRENCY %s at CGK.\n" "${3^^}" 1>&2
	printf "Try \"-l\" to grep a list of suported currencies.\n" 1>&2
	exit 1
fi

# Check if you are using currency id (correct) or code (incorrect) as FROM_CURRENCY arg
#CLIST="$(curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H  "accept: application/json" | jq -r '[.[] | { key: .symbol, value: .id } ] | from_entries')"
if ! printf "%s\n" "${CLIST}" | jq -r .[] | grep -qi "^${2}$"; then
	printf "Grepping currency id...\n" 1>&2
	GREPID="$(printf "%s\n" "${CLIST}" | jq -r .${2,,})"
	set -- ${1} ${GREPID} ${@:3:6}
fi

# Get CoinGecko JSON
CGKRATE=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=${2,,}&vs_currencies=${3,,}" -H  "accept: application/json" | jq ".\"${2,,}\".\"${3,,}\"")

#echo -$1-$2-$3-$4-${*}-$CGKRATE

## Print JSON timestamp ?
if [[ -n ${TIMEST} ]]; then
	printf "%s\n" "No timestamp. Try -k for tickers." 1>&2
fi


# Make equation and print result
RESULT="$(printf "scale=%s; %s*%s\n" "${SCL}" "${1}" "${CGKRATE}" | bc -l)"
printf "%s\n" "${RESULT}"
# Check for bad internet
icheck
exit
## CGK APIs
# https://www.coingecko.com/pt/api#explore-api

# Ref: jq read names with dash : https://github.com/stedolan/jq/issues/38
# https://unix.stackexchange.com/questions/406410/jq-print-key-and-value-for-all-in-sub-object
# Unsorted keys https://stedolan.github.io/jq/manual/
# https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4

