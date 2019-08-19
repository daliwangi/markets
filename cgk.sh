#!/usr/bin/bash
#
# Cgk.sh -- Coingecko.com API Access
# v0.5.30 - 2019/ago/19   by mountaineerbr
#set -x

# Some defaults
LC_NUMERIC="en_US.utf8"

## Manual and help
# printf "cgk [amount] [currency_id] [vs_currency]"
HELP_LINES="NAME
 	\033[01;36mCgk.sh -- Coingecko.com API Access\033[00m


SYNOPSIS
	cgk.sh \e[0;35;40m[-e|-h|-j|-l|-m]\033[00m

	cgk.sh \e[0;35;40m[-b|-g|-j|-s]\033[00m \e[0;33;40m[AMOUNT]\033[00m \e[0;32;40m[FROM_CURRENCY_ID]\033[00m \e[0;31;40m[VS_CURRENCY_SYMBOL]\033[00m
	
	cgk.sh \e[0;35;40m[-b|-g]\033[00m \e[0;33;40m[AMOUNT]\033[00m \e[0;32;40m[ID|SYMBOL]\033[00m \e[0;31;40m[ID|SYMBOL]\033[00m
		
	cgk.sh \e[0;35;40m[-p|-t]\033[00m \e[0;32;40m[ID|SYMBOL]\033[00m optional:\e[0;31;40m[ID|SYMBOL]\033[00m

	# [AMOUNT] is optinal.


DESCRIPTION
	This programme fetches updated currency rates from CoinGecko.com and can
	convert any amount of one supported currency into another.
	
	Coin Gecko has got a public API for many crypto and bank currency rates.
	Central bank currency conversions are not supported directly, but we can
	derive bank currency rates undirectly, for e.g. USD vs CNY. As CoinGecko
	updates frequently, it is one of the best API for bank currency rates.

	The Bak Currency Function \"-b\" can calculate central bank currency rates,
	such as USD/BRL or any crypto currency pair rate even if there is no official
	market for it (i.e. no exchange uses that pair for trading). Unofficially
	supported crypto markets can also be calculated, such as ZCash vs. DigiByte.

	Due to how CoinGecko API works, this programme does a lot of checking and
	multiple calls to the API every run. For example, it tries to grep currency
	\"ids\" when FROM_CURRENCY input is rather a currency \"code\" and it checks
	if input is a supported currency, too. A small percentage of cryptocurrencies 
	that CoinGecko supports may not really be supported by this script, due 
	to their weird currency ids/names or codes.

	
	It is _not_ advisable to depend solely on CoinGecko rates for serious trading.
	
	You can see a List of supported currencies running the script with the
	argument \"-l\". 

	Default precision is 16 and can be adjusted with \"-s\". Trailing noughts
	are trimmed by default.


USAGE EXAMPLES:		
		(1)     One Bitcoin in U.S.A. Dollar:
			
			$ cgk.sh btc
			
			$ cgk.sh 1 btc usd


		(2) 	One Bitcoin in Brazilian Real:

			$ cmc.sh btc brl


		(3)     0.1 Bitcoin in Ether:
			
			$ cgk.sh 0.1 btc eth 


		(4)     One Bitcoin in DigiBytes (unoficially supported market;
			it needs to use the Bank Currency Function flag \"-b\"):
			
			$ cgk.sh -b btc dgb 


		(5)     100 ZCash in Digibyte (unoficially supported market) 
			with 8 decimal plates:
			
			$ cgk.sh -bs8 100 zcash digibyte 
			
			$ cgk.sh -bs8 100 zec dgb 

		
		(6)     One Canadian Dollar in Japanese Yen (must use the Bank
			Currency Function):
			
			$ cgk.sh -b cad jpy 


		(7)     One thousand Brazilian Real in U.S.A. Dollars with 4 decimal plates:
			
			$ cgk.sh -b -s4 1000 brl usd 


		(8)     One ounce of Gold in U.S.A. Dollar:
			
			$ cgk.sh -b xau 
			
			$ cgk.sh -b 1 xau usd 

		
		(9)     One gram of Silver in New Zealand Dollar:
			
			$ cgk.sh -bg xag nzd 


		(10)    Ticker for all Bitcoin market pairs:
			
			$ cgk.sh -t btc 

		(11)    Ticker for Bitcoin/USD only:
			
			$ cgk.sh -t btc usd 


OPTIONS
		-b 	Activate Bank Currency function; it extends support for
			converting any central bank or crypto currency to any other.

		-e 	Exchange list; for information on trading incentives and
			normalized volume, check <https://blog.coingecko.com/trust-score/>.

		-g 	Use gram instead of ounce (for precious metals).

		-h 	Show this help.

		-j 	Fetch JSON file and send to STOUT.

		-l 	List supported currencies.

		-m 	Market Capitulation table.

		-p 	Number of pages retrieved from the server, defaults 
			is 4*100 results/page. For use with the Ticker function.
	 	
		-s 	Scale setting ( decimal plates ).
		
		-t 	Tickers for a cryptocurrency or cryptocurrency pair;
			to change how many result pages are fetched from the server,
			check flag \"-p\"; input must be an existing/supported 
			currency or currency pair;


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
while getopts ":begmlhjp:s:t" opt; do
  case ${opt} in
	b ) ## Activate the Bank currency function
		BANK=1
		;;
	e ) ## List supported Exchanges
		EXOPT=1
		;;
	g ) ## Use gram instead of ounce for precious metals
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
	t ) # Tickers
		TOPT=1
		;;
	p ) # Number of pages to retrieve with the Ticker Function
		TPAGES=${OPTARG}
		;;
	s ) # Scale, Decimal plates
		SCL=${OPTARG}
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
# Only if there is no path created already
if [[ -z "${CGKTEMPLIST2}" ]]; then
	CGKTEMPLIST=$(mktemp /tmp/cgk.list.XXXXX) || exit 1
	CGKTEMPLIST2=$(mktemp /tmp/cgk.list2.XXXXX) || exit 1
	export CGKTEMPLIST #As $CLISTRAW
	export CGKTEMPLIST2 #As $CLIST
fi
clistf() {
	if ! [[ -s "${CGKTEMPLIST2}" ]]; then
		curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H  "accept: application/json" >> "${CGKTEMPLIST}"
		jq -r '[.[] | { key: .symbol, value: .id } ] | from_entries' <"${CGKTEMPLIST}" >> "${CGKTEMPLIST2}"
	fi
}
# List of vs_currencies
if [[ -z "${CGKTEMPLIST3}" ]]; then
	CGKTEMPLIST3=$(mktemp /tmp/cgk.list3.XXXXX) || exit 1
	export CGKTEMPLIST3
fi
tolistf() {
	#TOLIST=
	if ! [[ -s "${CGKTEMPLIST3}" ]]; then
	curl -s https://api.coingecko.com/api/v3/simple/supported_vs_currencies | jq -r '.[]' >> "${CGKTEMPLIST3}"
	fi
}
## Trap cleaning temp files
if [[ -z ${CLEANER1} ]]; then
	CLEANER1=1
	export CLEANER1
	cleanf1() {
		rm -f "${CGKTEMPLIST}" "${CGKTEMPLIST2}" "${CGKTEMPLIST3}"
		exit 130
	}
	trap "cleanf1" EXIT SIGINT
fi
# Change currency code to ID in FROM_CURRENCY
# export currency id as GREPID
changevscf() {
	if jq -r keys[] <"${CGKTEMPLIST2}" | grep -qi "^${*}$"; then
	GREPID="$(jq -r ".${*,,}" <"${CGKTEMPLIST2}")"
	fi
}

## -l Print currency lists
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
	printf "%s\n" "${FCLISTS}" | jq -r '.[] | "\(.name) = \(.id) = \(.symbol)"' | column -s'=' -et -W'FROM_CURRENCY_NAME,ID' -o'|' -N'FROM_CURRENCY_NAME,ID,SYMBOL/CODE'
	printf "\n\n"
	printf "List of supported VS_CURRENCY Codes\n\n"
	printf "%s\n" "${VSCLISTS}" | jq -r '.[]' | tr "[:lower:]" "[:upper:]" | sort | column -c 100
	printf "\n"
}
if [[ -n "${LISTS}" ]]; then
	listsf
	exit
fi

## -m Market Cap function		
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

	printf "\n## Total Market Cap\n"
	printf "# Equivalent in:\n"
	printf "USD           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.usd')")"
	printf "EUR           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.eur')")"
	printf "GBP           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.gbp')")"
	printf "JPY           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.jpy')")"
	printf "CNY           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.cny')")"
	printf "BRL           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.brl')")"
	printf "XAU           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.xau')")"
	printf "BTC           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.btc')")"
	printf "ETH           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.eth')")"
	printf "XRP           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_market_cap.xrp')")"
	printf "Change(%%/24h) : "
	printf "%.4f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.market_cap_change_percentage_24h_usd')"

	printf "\n## Market Volume (last 24-H)\n"
	printf "# Equivalent in:\n"
	printf "BTC           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.btc')")"
	printf "ETH           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.eth')")"
	printf "XRP           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.xrp')")"
	printf "USD           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.usd')")"
	printf "EUR           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.eur')")"
	printf "GBP           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.gbp')")"
	printf "JPY           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.jpy')")"
	printf "CNY           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.cny')")"
	printf "BRL           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.brl')")"
	printf "XAU           : %s\n" "$(printf "%'.2f\n" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.total_volume.xau')")"


	printf "\n## Dominance\n"
	printf "%s\n" "${CGKGLOBAL}" | jq -r '.data.market_cap_percentage | keys_unsorted[] as $k | "\($k) = \(.[$k])"' | column -s '=' -t -o "=" | awk -F"=" '{ printf "%s", toupper($1); printf("%16.4f %%\n", $2); }'
	printf "\n"
	
	printf "## Market Cap per Coin (USD)\n"
	DOMINANCEARRAY=($(curl -sX GET "https://api.coingecko.com/api/v3/global" -H  "accept: application/json" | jq -r '.data.market_cap_percentage | keys_unsorted[]'))
	for i in "${DOMINANCEARRAY[@]}"; do
		printf "%s %'19.2f\n" "${i^^}" "$(printf "%s\n" "${CGKGLOBAL}" | jq -r "((.data.market_cap_percentage.${i}/100)*.data.total_market_cap.usd)")" 2>/dev/null
	done

	exit
}
if [[ -n "${MCAP}" ]]; then
mcapf
fi

## -e Show Exchange info function
exf() {
	EXRAW="$(curl -sX GET "https://api.coingecko.com/api/v3/exchanges" -H  "accept: application/json")"
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${EXRAW}" 
		exit
	fi
	protablef() {
		jq -r '.[] | "\(.name)=\(if .year_established == null then "??" else .year_established end)=\(if .country != null then .country else "??" end)=\(if .trade_volume_24h_btc == .trade_volume_24h_btc_normalized then "\(.trade_volume_24h_btc)=[same]" else "\(.trade_volume_24h_btc)=[\(.trade_volume_24h_btc_normalized)]" end)=\(if .has_trading_incentive == "true" then "YES" else "NO" end)=\(.id)=\(.url)"'
	}
	printf "\nTable of Exchanges\n\n"
	printf "\nExchanges in this list: %s\n\n" "$(printf "%s\n" "${EXRAW}"| jq -r '.[].id' | wc -l)"
	printf "%s\n" "${EXRAW}"| protablef | sort | column -ts'=' -eN"NAME   ,YEAR,COUNTRY,BTC_VOLUME(24H),[NORMALIZED_BTC_VOL],INC?,ID    ,URL" -T'NAME   ,ID    ,COUNTRY,URL'
	exit
}
test -n "${EXOPT}" && exf "${*}"

## Check for internet connection function ( CURRENTLY UNUSED )
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
	set -- 1 "${@:1:2}"
fi

if [[ -z ${3} ]]; then
	set -- "${@:1:2}" usd
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
	if jq -r .[] <"${CGKTEMPLIST2}" | grep -qi "^${2}$" ||
	   jq -r keys[] <"${CGKTEMPLIST2}" | grep -qi "^${2}$"; then
		changevscf "${2}" 2>/dev/null
		MAYBE1="${GREPID}"
	fi
	if jq -r .[] <"${CGKTEMPLIST2}" | grep -qi "^${3}$" ||
	   jq -r keys[] <"${CGKTEMPLIST2}" | grep -qi "^${3}$"; then
		changevscf "${3}" 2>/dev/null
		MAYBE2="${GREPID}"
	fi

	# Get CoinGecko JSON
	CGKRATERAW=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,${2,,},${3,,},${MAYBE1},${MAYBE2}&vs_currencies=btc,${2,,},${3,,},${MAYBE1},${MAYBE2}" -H  "accept: application/json")
	export CGKRATERAW
	# Get rates to from_currency anyways
	if [[ "${2,,}" = "btc" ]]; then
		BTCBANK=1
	elif ! BTCBANK="$(${0} ${2,,} btc 2>/dev/null)"; then
		BTCBANK="(1/$(${0} bitcoin ${2,,} 2>/dev/null))"
		test "${?}" -ne 0 && echo "Function error; check currencies." && exit 1
	fi
	# Get rates to to_currency anyways
	if [[ "${3,,}" = "btc" ]]; then
		BTCTOCUR=1
	elif ! BTCTOCUR="$(${0} ${3,,} btc 2>/dev/null)"; then
		BTCTOCUR="(1/$(${0} bitcoin ${3,,} ))"
		test "${?}" -ne 0 && echo "Function error; check currencies." && exit 1
	fi
	# Timestamp? No timestamp for this API
	# Calculate result

	if [[ -z ${GRAM} ]]; then
		RESULT="$(printf "(%s*%s)/%s\n" "${1}" "${BTCBANK}" "${BTCTOCUR}" | bc -l)"
	else
		RESULT="$(printf "((1/28.349523125)*%s*%s)/%s\n" "${1}" "${BTCBANK}" "${BTCTOCUR}" | bc -l)"
	fi
	printf "%.${SCL}f\n" "${RESULT}"
	exit
}
if [[ -n "${BANK}" ]]; then
	bankf ${*}
	exit
fi

## Check you are not requesting some unsupported FROM_CURRENCY
clistf
if ! jq -r .[][] <"${CGKTEMPLIST}" | grep -qi "^${2}$"; then
	printf "Unsupported FROM_CURRENCY %s at CGK.\n" "${2^^}" 1>&2
	printf "Try the bank currency function \"-b\",\n" 1>&2
	printf "list of suported currencies \"-l\" or help \"-h\".\n" 1>&2
	exit 1
fi

## Check you are not requesting some unsupported TO_CURRENCY
tolistf
if [[ -z "${TOPT}" ]] && [[ -z "${BANK}" ]] && ! grep -qi "^${3}$" <"${CGKTEMPLIST3}"; then
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

## -t Ticker Function
tickerf() {
	printf "\nTickers for %s\n" "${ORIGARG1^^}" 1>&2 
	printf "Results\n" 1>&2

	curl -s --head https://api.coingecko.com/api/v3/coins/bitcoin/tickers |
		grep -ie "total:" -e "per-page:" | sort -r 1>&2
	printf "\n" 1>&2 
	## Trap cleaning temp files
	CGKTEMP=$(mktemp /tmp/cgk.ticker.XXXXX) || exit 1
	if [[ -z ${CLEANER2} ]]; then
	CLEANER2=1
	export CLEANER2
	cleanf2() {
		rm -f "${CGKTEMP}"
		exit 130
	}
	trap "cleanf2" EXIT SIGINT
	fi
	## Grep 4 pages of results instead of only 1
	i=1
	test -z "${TPAGES}" && TPAGES=4
	while [ $i -le "${TPAGES}" ]; do
		printf "Fetching page %s of %s...\n" "${i}" "${TPAGES}" 1>&2
		curl -s -X GET "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}" -H  "accept: application/json" >> "${CGKTEMP}"
		echo "" >> "${CGKTEMP}"
		i=$[$i+1]
	done
	printf "\n"
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		cat "${CGKTEMP}" 
		exit
	fi
	## If there is ARG 2, then make sure you get only those pairs specified
	test -n "${ORIGARG2}" && GREPARG="^${ORIGARG1}/${ORIGARG2}=" ||	GREPARG="[aA-zZ]"
	cat "${CGKTEMP}" |
		jq -r '.tickers[]|"\(.base)/\(.target)= \(.market.name)= \(.last)= \(.volume)= \(.bid_ask_spread_percentage)= \(.converted_last.btc)= \(.converted_last.usd)= \(.last_traded_at)"' |
		grep -i "${GREPARG}" |
		sort |
		column -s= -et -N"PAIR,MARKET,LAST_PRICE,VOLUME,SPREAD(%),PRICE(BTC),PRICE(USD),LAST_TRADE_TIME" |
		grep -i "[a-z]"
	test "${?}" != 0 &&
		printf "No match for %s %s.\n" "${ORIGARG1^^}" "${ORIGARG2^^}" 1>&2 &&
		exit 1
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

# Make equation and print result
if [[ -z ${GRAM} ]]; then
	RESULT="$(printf "%s*%s\n" "${1}" "${CGKRATE}" | bc -l)"
else
	RESULT="$(printf "(1/28.349523125)*%s*%s\n" "${1}" "${CGKRATE}" | bc -l)"
fi
printf "%.${SCL}f\n" "${RESULT}"
exit
## CGK APIs
# https://www.coingecko.com/pt/api#explore-api

# Ref: jq read names with dash : https://github.com/stedolan/jq/issues/38
# https://unix.stackexchange.com/questions/406410/jq-print-key-and-value-for-all-in-sub-object
# Unsorted keys https://stedolan.github.io/jq/manual/
# https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4

