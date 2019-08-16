#!/usr/bin/bash
#
# Cgk.sh -- Coingecko.com API Access
# v0.5.4 - 2019/ago/15   by mountaineerbr

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
	This programme fetches updated currency rates from CoinGecko.com and can
	convert any amount of one supported currency into another.
	
	Coin Gecko has got a public API for many crypto and bank currency rates.
	Central bank currency conversions are not supported directly, but we can
	derive bank currency rates undirectly, for e.g. USD vs CNY. As CoinGecko
	updates frequently, it is one of the best API for bank currenciy artes.

	All these unofficially supported markets can be calculated with the \"Bank
	Currency Function\", called with the flag \"-b\". Unofficially supported
	crypto markets can also be calculated, such as ZCash vs. DigiByte.

	Due to how CoinGecko API works, this programme does a lot of checking and
	multiple calls to the API every run. For example, it tries to grep currency
	*ids* when FROM_CURRENCY input is rather a currency *code* and it checks
	if input is a supported currency, too. A small percentage of cryptocurrencies 
	that CoinGecko supports may not really be supported by this script, due 
	to their weird currency ids/names or codes.
	
	It is _not_ advisable to depend solely on CoinGecko rates for serious trading.
	
	You can see a List of supported currencies running the script with the
	argument \"-l\". 

	Default precision is 16 and can be adjusted with \"-s\". Trailing noughts
	are trimmed by default.


USAGE EXAMPLES:		
		(1)     One Bitcoin in U.S.A. Dollars:
			
			$ cgk.sh btc
			
			$ cgk.sh 1 btc usd


		(2)     0.1 Bitcoin in Ether:
			
			$ cgk.sh 0.1 btc eth 


		(3)     One Bitcoin in DigiBytes (unoficially supported market;
			it needs to use the Bank Currency Function flag \"-b\"):
			
			$ cgk.sh -b btc dgb 


		(4)     100 ZCash in Digibyte (unoficially supported market) 
			with 8 decimal plates:
			
			$ cgk.sh -bs8 100 zcash digibyte 
			
			$ cgk.sh -bs8 100 zec dgb 

		
		(5)     One Canadian Dollar in Japanese Yen (must use the Bank
			Currency Function):
			
			$ cgk.sh -b cad jpy 


		(6)     One thousand Brazilian Real in U.S.A. Dollars with 4 decimal plates:
			
			$ cgk.sh -b -s4 1000 brl usd 


		(7)     One ounce of Gold in U.S.A. Dollar:
			
			$ cgk.sh -b xau 
			
			$ cgk.sh -b 1 xau usd 

		
		(8)     One gramme of Silver in New Zealand Dollar:
			
			$ cgk.sh -bg xag nzd 


		(9)     Ticker for all Bitcoin market pairs:
			
			$ cgk.sh -k btc 

		(10)    Ticker for Bitcoin/USD only:
			
			$ cgk.sh -k btc 


OPTIONS
		-b 	Activate Bank Currency function; it extends support for
			converting any central bank or crypto currency to any other.

		-g 	Use gramme instead of ounce (for precious metals).

		-h 	Show this help.

		-j 	Fetch JSON file and send to STOUT.

		-k 	Fetch tickers for a cryptocurrency or cryptocurrency pair;
			make sure input is an existing/supported market pair;
			Results may be sorted with flag \"-z\".

		-l 	List supported currencies.

		-m 	Market Capitulation table.
	 	
		-s 	Set scale ( decimal plates ).
		
		-z 	Ticker function results may be sorted according to:
			defaults: sort by name;
			       1: sort by market;
			       2: sort by market volume.


BUGS
 	This programme is distributed without support or bug corrections.
	Licensed under GPLv3 and above.
	Give me a nickle! =)
          bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr
		"

# Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit
fi
# Parse options
# If the very first character of the option string is a colon (:) then getopts will not report errors and instead will provide a means of handling the errors yourself.
while getopts ":bgmlhjks:tz:" opt; do
  case ${opt} in
	b ) ## Activate the Bank currency function
		BANK=1
		;;
	g ) ## Use gramme instead of ounce for precious metals
		GRAM=1
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
	z ) # Set Sort option for Ticker Function
	    # defaults: 0: sort by name; 1: sort by market; 2: sort by market volume
	    	ZOPT=${OPTARG}
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
	CLISTRAW=$(curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H  "accept: application/json")
	CLIST="$(printf "%s\n" "${CLISTRAW}" | jq -r '[.[] | { key: .symbol, value: .id } ] | from_entries')"
}
# List of vs_currencies
tolistf() {
	TOLIST="$(curl -s https://api.coingecko.com/api/v3/simple/supported_vs_currencies | jq -r '.[]')"
	#export TOLIST
}
# Check if you are using currency id (correct) or code (incorrect) as FROM_CURRENCY arg
# and export currency id as GREPID
changevscf() {
	if printf "%s\n" "${CLIST}" | jq -r keys[] | grep -qi "^${*}$"; then
	printf "Grepping currency id...\n" >&2
	GREPID="$(printf "%s\n" "${CLIST}" | jq -r .${*,,})"
 	#export GREPID
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
	printf "\nList of supported FROM_CURRENCY IDs (also precious metals codes)\n\n"
	printf "%s\n" "${FCLISTS}" | jq -r '.[] | "\(.name) = \(.id)"' | column -s '=' -c 60 -T 1 -e -t -o '|' -N '-----FROM_CURRENCY NAME----,---------------ID---------------'
	printf "\n\n"
	printf "List of supported VS_CURRENCY Codes\n\n"
	printf "%s\n" "${VSCLISTS}" | jq -r '.[]' | tr [a-z] [A-Z] | sort | column -c 100
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
# Let's keep a copy of the original argument
# for use with the Ticker function
ORIGARG1="${1}"
ORIGARG2="${2}"

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
#echo $BTCBANK-$BTCTOCUR
		BTCBANK="(1/$(${0} bitcoin ${2,,} 2>/dev/null))"
		test "${?}" -ne 0 && echo "Function error; check currencies." && exit 1
	fi
	# Get rates to to_currency anyways
	if ! BTCTOCUR="$(${0} ${3,,} btc 2>/dev/null)"; then
		BTCTOCUR="(1/$(${0} bitcoin ${3,,} ))"
		test "${?}" -ne 0 && echo "Function error; check currencies." && exit 1
	fi
#echo $BTCBANK-$BTCTOCUR
	# Timestamp? No timestamp for this API
	if [[ -n "${TIMEST}" ]]; then
		printf "%s\n" "No timestamp." 1>&2
	fi
	# Calculate result

	if [[ -z ${GRAM} ]]; then
		RESULT="$(printf "(%s*%s)/%s\n" "${1}" "${BTCBANK}" "${BTCTOCUR}" | bc -l)"
	else
		RESULT="$(printf "((1/28.349523125)*%s*%s)/%s\n" "${1}" "${BTCBANK}" "${BTCTOCUR}" | bc -l)"
	fi
	printf "%.${SCL}f\n" "${RESULT}"
#echo ${SCL}-${1}-$BTCBANK-$BTCTOCUR-----${1}-${2}-${3}-${4}-${SCL}-${EQ}
	# Check for bad internet
	#icheck
	exit
}
if [[ -n "${BANK}" ]]; then
	bankf ${*}
	exit
fi

## Check you are not requesting some unsupported FROM_CURRENCY
if [[ -z ${CLISTRAW} ]]; then
	clistf
fi
if ! printf "%s\n" "${CLISTRAW}" | jq -r .[][] | grep -qi "^${2}$"; then
	printf "Unsupported FROM_CURRENCY %s at CGK.\n" "${2^^}" 1>&2
	printf "Try the Bank currency function or\n" 1>&2
	printf "try \"-l\" to grep a list of suported currencies.\n" 1>&2
	exit 1
fi
#if ! printf "%s\n" "${CLIST}" | jq -r .[] | grep -qi "^${2}$" &&
#	! printf "%s\n" "${CLIST}" | jq -r keys[] | grep -qi "^${2}$"; then
#	printf "Unsupported FROM_CURRENCY %s at CGK.\n" "${2^^}" 1>&2
#	printf "Try the Bank currency function or\n" 1>&2
#	printf "try \"-l\" to grep a list of suported currencies.\n" 1>&2
#	exit 1
#fi

## Check you are not requesting some unsupported TO_CURRENCY
if [[ -z ${TOLIST} ]]; then
	tolistf
fi
if [[ -z "${TOPT}" ]] && [[ -z "${BANK}" ]] && ! printf "%s\n" "${TOLIST}" | grep -qi "^${3}$"; then
	printf "Unsupported TO_CURRENCY %s at CGK.\n" "${3^^}" 1>&2
	printf "Try \"-l\" to grep a list of suported currencies.\n" 1>&2
	printf "Or try to use the Bank Currency Function flag \"-b\" (even for crypto).\n" 1>&2
	exit 1
fi
GREPID=
# Check if I can help changing from currency code (incorrect) 
# to its id (correct) (for FROM_CURRENCY)
changevscf ${2}
if [[ -n ${GREPID} ]]; then
	set -- ${1} ${GREPID} ${3}
fi

## Ticker Function
tickerf() {
	printf "\nTickers for %s %s\n" "${ORIGARG1^^}" "${ORIGARG2^^}" 
	printf "\tTip: check flag \"-z\" for sorting opts.\n\n"
	printf "It may take a while now; if it returns empty, make sure\n"
	printf "input is a valid cryptocurrency code or maket pair.\n\n"
	
	## Grep 6 pages of results instead of only 1
	CGKTEMP=$(mktemp /tmp/cgk.ticker.XXXXX) || exit 1
	i=1
	while [ $i -le 6 ]; do
		curl -s -X GET "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}" -H  "accept: application/json" >> "${CGKTEMP}"
		echo "" >> "${CGKTEMP}"
		i=$[$i+1]
	done
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		cat "${CGKTEMP}" 
		exit
	fi
	## Set column sort option with $ZOPT
	# 0: defaults: sort by 1st col; 1:exchange (2nd col); 2: volume (4th col); 3: spread (5th col)
	test "${ZOPT}" = "3" && ZOPT=5; ZOPTFLAG="-rn"
	test "${ZOPT}" = "2" && ZOPT=4; ZOPTFLAG="-rn"
	test "${ZOPT}" = "1" && ZOPT=2; ZOPTFLAG="-f"
	test -z "${ZOPT}" && ZOPT=1; ZOPTFLAG="-f"
	## If there is ARG 2, then make sure you get only those pairs specified
	GREPARG="[aA-zZ]"
	test -n "${ORIGARG2}" && GREPARG="^${ORIGARG1}/${ORIGARG2}="
#echo ">$ZOPT-${1}-${2}-${3}-${ORIGARG2}<"	
	cat "${CGKTEMP}" |
		jq -r '.tickers[]|"\(.base)/\(.target)= \(.market.name)= \(.last)= \(.volume)= \(.bid_ask_spread_percentage)= \(.converted_last.btc)= \(.converted_last.usd)= \(.last_traded_at)"' |
		grep -i "${GREPARG}" |
		sort -k"${ZOPT}" "${ZOPTFLAG}" |
		column -s= -et -N"PAIR,MARKET,LAST_PRICE,VOLUME,SPREAD(%),PRICE(BTC),PRICE(USD),LAST_TRADE_TIME"
	exit 0
}
if [[ -n ${TOPT} ]]; then
	tickerf ${*}
	exit
fi

# Get CoinGecko JSON
if [[ -z ${CGKRATERAW} ]]; then
	CGKRATERAW=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=${2,,}&vs_currencies=${3,,}" -H  "accept: application/json")
fi

CGKRATE=$(printf "%s\n" "${CGKRATERAW}" | jq '."'${2,,}'"."'${3,,}'"' | sed 's/e/*10^/g')
# Print JSON?
if [[ -n ${PJSON} ]]; then
	printf "%s\n" "${CGKRATERAW}" 
	exit
fi

## Print JSON timestamp ?
if [[ -n ${TIMEST} ]]; then
	printf "%s\n" "No timestamp. Try -k for tickers." 1>&2
fi


# Make equation and print result
if [[ -z ${GRAM} ]]; then
	RESULT="$(printf "%s*%s\n" "${1}" "${CGKRATE}" | bc -l)"
else
	RESULT="$(printf "(1/28.349523125)*%s*%s\n" "${1}" "${CGKRATE}" | bc -l)"
fi
printf "%.${SCL}f\n" "${RESULT}"
# Check for bad internet
#icheck
exit
## CGK APIs
# https://www.coingecko.com/pt/api#explore-api

# Ref: jq read names with dash : https://github.com/stedolan/jq/issues/38
# https://unix.stackexchange.com/questions/406410/jq-print-key-and-value-for-all-in-sub-object
# Unsorted keys https://stedolan.github.io/jq/manual/
# https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4

