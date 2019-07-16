#!/usr/bin/bash
#
# Cgk.sh -- Coingecko.com API Access
# v0.4.2 - 2019/jul/16   by mountaineerbr

# Some defaults
LC_NUMERIC="en_US.utf8"

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

		-k 	Fetch tickers for currency (under development).

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
while getopts ":bmlhjks:t" opt; do
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
		PJSON=1
		;;
	k ) # Tickers
		TOPT=1
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

## Some recurring functions
# List of from_currencies
clistf() {
	CLIST="$(curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H  "accept: application/json" | jq -r '[.[] | { key: .symbol, value: .id } ] | from_entries')"
	export CLIST
}
# List of vs_currencies
tolistf() {
	TOLIST="$(curl -s https://api.coingecko.com/api/v3/simple/supported_vs_currencies | jq -r '.[]')"
	export TOLIST
}
# Check if you are using currency id (correct) or code (incorrect) as FROM_CURRENCY arg
# and export currency id as GREPID
changevscf() {
	if ! printf "%s\n" "${CLIST}" | jq -r .[] | grep -qi "^${*}$"; then
	printf "Grepping currency id...\n" >&2
	GREPID="$(printf "%s\n" "${CLIST}" | jq -r .${*,,})"
 	export GREPID
	fi
}

## Print currency lists
listsf() {
	FCLISTS="$(curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H  "accept: application/json")"	
	VSCLISTS="$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/supported_vs_currencies" -H  "accept: application/json")"	
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n\n" "${FCLISTS}" 
		printf "%s\n" "${VSCLISTS}" 
		exit
	fi
	printf "\nList of supported FROM_CURRENCY IDs\n\n"
	printf "%s\n" "${FCLISTS}" | jq -r '.[] | "\(.name) = \(.id)"' | column -s '=' -c 60 -T 1 -e -t -o '|' -N '-----FROM_CURRENCY NAME----,---------------ID---------------'
	printf "\n\n"
	printf "List of supported VS_CURRENCY Codes\n\n"
	printf "%s\n" "${VSCLISTS}" | jq -r '.[]' | column -c 100
	printf "\n"
}
if [[ -n "${LISTS}" ]]; then
	listsf
	exit
fi

## Market Cap function		
mcapf() {
	CGKGLOBAL=$(curl -sX GET "https://api.coingecko.com/api/v3/global" -H  "accept: application/json")
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${CGKGLOBAL}" 
		exit
	fi

	CGKTIME=$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.updated_at')
	date -d@"$CGKTIME" "+## %FT%T%Z%n"
	
	printf "CRYPTO MARKET STATS\n"
	printf "Markets       : %s\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.markets')"
	printf "Active cryptos: %s\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.active_cryptocurrencies')"

	printf "\n## ICOs info\n"
	printf "Upcoming      : %s\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.upcoming_icos')"
	printf "Ongoing       : %s\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.ongoing_icos')"
	printf "Ended         : %s\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.ended_icos')"

	printf "\n## Total market volume\n"
	printf "USD           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.usd')")"
	printf "BRL           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.brl')")"
	printf "Change(%%/24h) : "
	printf "%.4f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.market_cap_change_percentage_24h_usd')"

	printf "\n## Dominance\n"
	printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.market_cap_percentage | keys_unsorted[] as $k | "\($k) = \(.[$k])"' | column -s '=' -t -o "=" | awk -F"=" '{ printf "%s", toupper($1); printf("%16.4f %%\n", $2); }'
	printf "\n"
	
	printf "## Market Cap per Coin (USD)\n"
	DOMINANCEARRAY=($(curl -sX GET "https://api.coingecko.com/api/v3/global" -H  "accept: application/json" | jq -r '.data.market_cap_percentage | keys_unsorted[]'))
	for i in "${DOMINANCEARRAY[@]}"; do
		printf "%s %'19.2f\n" "${i^^}" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r "((.data.market_cap_percentage.${i}/100)*.data.total_market_cap.usd)")" 2>/dev/null
	done

	printf "\n## Coin Volume (24-H)\n"
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
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "No specific JSON for Bank Currency Function.\n" >&2 
		exit 1
	fi

	# Call CGK.com less
	# Get currency lists (they will be exported by the fucntion)
	clistf
	tolistf

	# Grep possible currency ids
	if printf "%s\n" "${CLIST}" | jq -r .[] | grep -qi "^${2}$" ||
	   printf "%s\n" "${CLIST}" | jq -r keys[] | grep -qi "^${2}$"; then
		changevscf ${2} 2>/dev/null
		MAYBE1="${GREPID}"
	fi
	if printf "%s\n" "${CLIST}" | jq -r .[] | grep -qi "^${3}$" ||
	   printf "%s\n" "${CLIST}" | jq -r keys[] | grep -qi "^${3}$"; then
		changevscf ${3} 2>/dev/null
		MAYBE2="${GREPID}"
	fi

	# Get CoinGecko JSON
	CGKRATERAW=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,${2,,},${3,,},${MAYBE1},${MAYBE2}&vs_currencies=btc,${2,,},${3,,},${MAYBE1},${MAYBE2}" -H  "accept: application/json")
	export CGKRATERAW
	# Get rates to from_currency anyways
	if ! BTCBANK="$(${0} ${2,,} btc 2>/dev/null)"; then
		BTCBANK="(1/$(${0} bitcoin ${2,,} ))"
		test "${?}" -ne 0 && echo "Function error; check currencies." && exit 1
	fi
	# Get rates to to_currency anyways
	if ! BTCTOCUR="$(${0} ${3,,} btc 2>/dev/null)"; then
		BTCTOCUR="(1/$(${0} bitcoin ${3,,} 2>/dev/null))"
		test "${?}" -ne 0 && echo "Function error; check currencies." && exit 1
	fi
	# Timestamp? No timestamp for this API
	if [[ -n "${TIMEST}" ]]; then
		printf "%s\n" "No timestamp." 1>&2
	fi
	# Calculate result
	RESULT="$(printf "scale=%s; (%s*%s)/%s\n" "${SCL}" "${1}" "${BTCBANK}" "${BTCTOCUR}" | bc -l)"
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
if [[ -z ${CLIST} ]]; then
	clistf
fi
if ! printf "%s\n" "${CLIST}" | jq -r .[] | grep -qi "^${2}$" &&
	! printf "%s\n" "${CLIST}" | jq -r keys[] | grep -qi "^${2}$"; then
	printf "Unsupported FROM_CURRENCY %s at CGK.\n" "${2^^}" 1>&2
	printf "Try the Bank currency function or\n" 1>&2
	printf "try \"-l\" to grep a list of suported currencies.\n" 1>&2
	exit 1
fi

## Check you are not requesting some unsupported TO_CURRENCY
if [[ -z ${TOLIST} ]]; then
	tolistf
fi
if [[ -z "${BANK}" ]] && ! printf "%s\n" "${TOLIST}" | grep -qi "^${3}$"; then
	printf "Unsupported TO_CURRENCY %s at CGK.\n" "${3^^}" 1>&2
	printf "Try \"-l\" to grep a list of suported currencies.\n" 1>&2
	exit 1
fi

# Check if you are using currency id (correct) or code (incorrect) as FROM_CURRENCY arg
changevscf ${2}
if [[ -n ${GREPID} ]]; then
	set -- ${1} ${GREPID} ${3}
fi

## Ticker Function
tickerf() {
	#read -r -p "Which currency id to see exchange tickers? " EX
	#echo ${1}-${2}-${3}
	TJSON=$(curl -X GET "https://api.coingecko.com/api/v3/coins/${2,,}/tickers" -H  "accept: application/json")
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${TJSON}" 
		exit
	fi
	# UNDER DEVELOPMENT!
	echo "This ticker function is under development." >&2
	echo ${TJSON} | jq .
	exit 1
}
if [[ -n ${TOPT} ]]; then
	tickerf ${*}
	exit
fi

# Get CoinGecko JSON
if [[ -z ${CGKRATERAW} ]]; then
	CGKRATERAW=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=${2,,}&vs_currencies=${3,,}" -H  "accept: application/json")
fi
CGKRATE=$(printf "%s\n" "${CGKRATERAW}" | jq ".${2,,}.${3,,}" | sed 's/e/*10^/g')
# Print JSON?
if [[ -n ${PJSON} ]]; then
	printf "%s\n" "${CGKRATE}" 
	exit
fi
#echo -$1-$2-$3-$4-${*}-$CGKRATE
## Print JSON timestamp ?
if [[ -n ${TIMEST} ]]; then
	printf "%s\n" "No timestamp. Try -k for tickers." 1>&2
fi


# Make equation and print result
RESULT="$(printf "scale=%s; %s*(%s)\n" "${SCL}" "${1}" "${CGKRATE}" | bc -l)"
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

