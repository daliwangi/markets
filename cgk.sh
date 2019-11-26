#!/bin/bash
# Cgk.sh -- Coingecko.com API Access
# v0.9  2019/nov/25  by mountaineerbr

# Some defaults
SCLDEFAULTS=16
LC_NUMERIC="en_US.UTF-8"

## Manual and help
HELP_LINES="NAME
	\e[1;33;40m
	Cgk.sh -- Currency Converter and Market Stats\033[00m
		\e[1;33;40m  Coingecko.com API Access\033[00m

SYNOPSIS
	cgk.sh [AMOUNT] [FROM_CURRENCY] [VS_CURRENCY]

	cgk.sh [-bs] [AMOUNT] [FROM_CURRENCY] [VS_CURRENCY] 
	
	cgk.sh [-pt] [CURRENCY] [optional:VS_SYMBOL]

	cgk.sh [-ehjlmpv]


	Note: Currencies can be symbols or CoinGecko IDs.


DESCRIPTION
	This programme fetches updated currency rates from CoinGecko.com and can
	convert any amount of one supported currency into another.
	
	CoinGecko has got a public API for many crypto and bank currency rates.
	Officially, CoinGecko only keeps rates of existing market pairs. For ex-
	ample, the market BTC/XRP is supported but XRP/BTC is not.

	Central bank currency conversions are not supported directly, but we can
	derive  them  undirectly, for e.g. USD vs CNY. As CoinGecko updates fre-
	quently, it is one of the best APIs for bank currency rates, too.

	The  Bank  Currency Function \"-b\" can calculate central bank currency
	rates , such  as USD/BRL. It can also calculate unofficially supported
	crypto currency markets, such as \"ZCash vs. DigiByte\" and \"Ripple vs
	Bitcoin\".

	Due to how CoinGecko API works, this programme needs do a lot of check-
	ing and multiple calls to the API each run. For example, CoinGecko only
	accepts  IDs  in the  \"from_currrency\" field. However, if input is a 
	symbol, it will be swapped to its corresponding ID automatically.
	
	It  is  _not_ advisable to depend solely on CoinGecko rates for serious 
	trading.
	
	You can get a List of supported currencies running the script with the
	option \"-l\".

	Gold and other metals are priced in Ounces.
		
		\"Gram/Ounce\" rate: 28.349523125


	It is also useful to define a variable OZ in your \".bashrc\" to work 
	with precious metals (see usage examples 12-15).

		OZ=\"28.349523125\"


	Default precision is 16 and can be adjusted with option \"-s\". Trailing
	noughts are trimmed by default.
	

ABBREVIATIONS
	Some functions function uses abbreviations to indicate data type.

		EX_ID 		Exchange identifier
		EX_NAME 	Exchange name
		INC? 		Incentives for trading?
		TRANK 		Trust rank
		TSCORE 		Trust score

	
	For more information, such as normal and normalized volume, check:

		<https://blog.coingecko.com/trust-score/>


FUNCTION \"-t\" 24H ROLLING TICKER
	Some currency convertion data is available for use with the Market Cap 
	Function \"-m\". You can choose which currency to display data, when 
	available, from the table below:

 	AED     BMD     CLP     EUR     INR     MMK     PKR     THB     VND
 	ARS     BNB     CNY     GBP     JPY     MXN     PLN     TRY     XAG
 	AUD     BRL     CZK     HKD     KRW     MYR     RUB     TWD     XAU
 	BCH     BTC     DKK     HUF     KWD     NOK     SAR     UAH     XDR
 	BDT     CAD     EOS     IDR     LKR     NZD     SEK     USD     XLM
	BHD     CHF     ETH     ILS     LTC     PHP     SGD     VEF     XRP
        								ZAR


	Otherwise, the market capitulation table will display data in various
	currencies by defaults.


WARRANTY
	Licensed under the GNU Public License v3 or better.
 	This programme is distributed without support or bug corrections.

   	This programme needs Bash, cURL, JQ , Xargs and Coreutils to work pro-
	perly.


	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES:		
		(1)     One Bitcoin in U.S.A. Dollar:
			
			$ cgk.sh btc
			
			$ cgk.sh 1 btc usd


		(2) 	One Bitcoin in Brazilian Real:

			$ cmc.sh btc brl


		(3)     0.1 Bitcoin in Ether:
			
			$ cgk.sh 0.1 btc eth 


		(4)     One Bitcoin in DigiBytes (unofficial market; use \"-b\"):
			
			$ cgk.sh -b btc dgb 


		(5)     100 ZCash in Digibyte (unofficial market) 
			with 8 decimal plates:
			
			$ cgk.sh -bs8 100 zcash digibyte 
			
			$ cgk.sh -bs8 100 zec dgb 

		
		(6)     One Canadian Dollar in Japanese Yen (for bank-currency-
			only rates, use the Bank Currency Function option \"-b\"):
			
			$ cgk.sh -b cad jpy 


		(7)     One thousand Brazilian Real in U.S.A. Dollars with 4
			decimal plates:
			
			$ cgk.sh -b -s4 1000 brl usd 


		(8)     One ounce of Gold in U.S.A. Dollar:
			
			$ cgk.sh -b xau 
			
			$ cgk.sh -b 1 xau usd 


		(09)    One Bitcoin in ounces of Gold:
					
			$ cgk.sh 1 btc xau 


		(10)    \e[0;33;40m[Amount]\033[00m of EUR in grams of Gold:
					
			$ cgk.sh -b \"\e[0;33;40m[amount]\033[00m*28.3495\" eur xau 

			    Just multiply amount by the \"gram/ounce\" rate.


		(11)    \e[1;33;40mOne\033[00m EUR in grams of Gold:
					
			$ cgk.sh -b \"\e[1;33;40m1\033[00m*28.3495\" eur xau 


		(12)    \e[0;33;40m[Amount]\033[00m (grams) of Gold in USD:
					
			$ cgk.sh -b \"\e[0;33;40m[amount]\033[00m/28.3495\" xau usd 
			
			    Just divide amount by the \"gram/ounce\" rate.

		
		(13)    \e[1;33;40mOne\033[00m gram of Gold in EUR:
					
			$ cgk.sh -b \"\e[1;33;40m1\033[00m/28.3495\" xau eur 


		(14)    Tickers of any Ethereum pair from all exchanges;
					
			$ cgk.sh -t eth 


		(15)    Only Tickers of Ethereum/Bitcoin, and retrieve 10 pages
			of results:
					
			$ cgk.sh -t -p10 eth btc 


		(16) 	Market cap function, show data for Chinese CNY:

			$ cgk.sh -m cny


OPTIONS
		-b 	Activate Bank Currency function; it extends support for
			converting any central bank or crypto currency to any
			other.

		-e 	Exchange information; number of pages to fetch with opt-
			ion \"-p\"; pass \"-ee\" to print a list of exchange 
			names and IDs only.

		-h 	Show this help.

		-j 	Fetch JSON and print to STOUT.

		-l 	List supported currencies.

		-m 	Market Capitulation table; accepts one currency as arg;
			defaults=show all available.

		-p 	Number of pages retrieved from the server; each page may
			contain 100 results; use with option \"-e\" and \"-t\";
			defaults=4.
	 	
		-s 	Scale setting (decimal plates).
		
		-t 	Tickers of a single cryptocurrency from all suported ex-
			changes and all its pairs; a second crypto can also be
			set to form a currency pair (market); change number of 
			pages to fetch with option \"-p\".
		
		-v 	Show this programme version."

## Functions
## -m Market Cap function		
mcapf() {
	# Check if input has a defined to_currency
	if [[ -z "${1}" ]]; then
		NOARG=1
		set -- usd
	fi
	# Get Data 
	CGKGLOBAL="$(${YOURAPP} "https://api.coingecko.com/api/v3/global" -H  "accept: application/json")"
	#DOMINANCEARRAY=($(jq -r '.data.market_cap_percentage | keys_unsorted[]' <<< "${CGKGLOBAL}"))
	# Check if input is a valid to_currency for this function
	if ! jq -r '.data.total_market_cap|keys[]' <<< "${CGKGLOBAL}" | grep -qi "^${1}$"; then
		printf "Using USD. Not supported -- %s.\n" "${1^^}" 1>&2
		NOARG=1
		set -- usd
	fi
	MARKETGLOBAL="$(${YOURAPP} "https://api.coingecko.com/api/v3/coins/markets?vs_currency=${1,,}&order=market_cap_desc&per_page=10&page=1&sparkline=false")"
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${CGKGLOBAL}"
		printf "%s\n" "${MARKETGLOBAL}"
		exit
	fi
	CGKTIME=$(jq -r '.data.updated_at' <<< "${CGKGLOBAL}")
	{ # Avoid erros being printed
	printf "## CRYPTO MARKET STATS\n"
	date -d@"$CGKTIME" "+#  %FT%T%Z"
	printf "## Markets : %s\n" "$(jq -r '.data.markets' <<< "${CGKGLOBAL}")"
	printf "## Cryptos : %s\n" "$(jq -r '.data.active_cryptocurrencies' <<< "${CGKGLOBAL}")"
	printf "## ICOs Stats\n"
	printf " # Upcoming: %s\n" "$(jq -r '.data.upcoming_icos' <<< "${CGKGLOBAL}")"
	printf " # Ongoing : %s\n" "$(jq -r '.data.ongoing_icos' <<< "${CGKGLOBAL}")"
	printf " # Ended   : %s\n" "$(jq -r '.data.ended_icos' <<< "${CGKGLOBAL}")"

	printf "\n## Total Market Cap\n"
	printf " # Equivalent in\n"
	printf "    %s    : %'22.2f\n" "${1^^}" "$(jq -r ".data.total_market_cap.${1,,}" <<< "${CGKGLOBAL}")"
	if [[ -n "${NOARG}" ]]; then
		printf "    EUR    : %'22.2f\n" "$(jq -r '.data.total_market_cap.eur' <<< "${CGKGLOBAL}")"
		printf "    GBP    : %'22.2f\n" "$(jq -r '.data.total_market_cap.gbp' <<< "${CGKGLOBAL}")"
		printf "    BRL    : %'22.2f\n" "$(jq -r '.data.total_market_cap.brl' <<< "${CGKGLOBAL}")"
		printf "    JPY    : %'22.2f\n" "$(jq -r '.data.total_market_cap.jpy' <<< "${CGKGLOBAL}")"
		printf "    CNY    : %'22.2f\n" "$(jq -r '.data.total_market_cap.cny' <<< "${CGKGLOBAL}")"
		printf "    XAU(oz): %'22.2f\n" "$(jq -r '.data.total_market_cap.xau' <<< "${CGKGLOBAL}")"
		printf "    BTC    : %'22.2f\n" "$(jq -r '.data.total_market_cap.btc' <<< "${CGKGLOBAL}")"
		printf "    ETH    : %'22.2f\n" "$(jq -r '.data.total_market_cap.eth' <<< "${CGKGLOBAL}")"
		printf "    XRP    : %'22.2f\n" "$(jq -r '.data.total_market_cap.xrp' <<< "${CGKGLOBAL}")"
	fi
	printf " # Change(%%USD/24h): %.4f %%\n" "$(jq -r '.data.market_cap_change_percentage_24h_usd' <<< "${CGKGLOBAL}")"

	printf "\n## Market Cap per Coin\n"
	printf "  # SYMBOL      CAP                   CHANGE(24h)\n" "${1^^}"
	jq -r '.[]|"\(.symbol) \(.market_cap) '${1^^}' \(.market_cap_change_percentage_24h)"' <<< "${MARKETGLOBAL}"  | awk '{ printf "  # %s  %'"'"'22.2f %s    %.4f%%\n", toupper($1) , $2 , $3 , $4 , $5 }'
	#Valid, but it they become indirect calculated numbers:
	#for i in ${DOMINANCEARRAY[@]}; do
	#	printf " #  %s    : %'22.2f %s\n" "${i^^}" "$(jq -r "(.data.total_market_cap.${1,,}*(.data.market_cap_percentage.${i,,}/100))" <<< "${CGKGLOBAL}")" "${1^^}"
	#done

	printf "\n## Dominance (Top 10)\n"
	jq -r '.data.market_cap_percentage | keys_unsorted[] as $k | "\($k) \(.[$k])"' <<< "${CGKGLOBAL}" | awk '{ printf "  # %s    : %8.4f%%\n", toupper($1), $2 }'
	jq -r '(100-(.data.market_cap_percentage|add))' <<< "${CGKGLOBAL}" | awk '{ printf "  # Others : %8.4f%%\n", $1 }'

	printf "\n## Market Volume (Last 24H)\n"
	printf " # Equivalent in\n"
	printf "    %s    : %'22.2f\n" "${1^^}" "$(jq -r ".data.total_volume.${1,,}" <<< "${CGKGLOBAL}")"
	if [[ -n "${NOARG}" ]]; then
		printf "    EUR    : %'22.2f\n" "$(jq -r '.data.total_volume.eur' <<< "${CGKGLOBAL}")"
		printf "    GBP    : %'22.2f\n" "$(jq -r '.data.total_volume.gbp' <<< "${CGKGLOBAL}")"
		printf "    BRL    : %'22.2f\n" "$(jq -r '.data.total_volume.brl' <<< "${CGKGLOBAL}")"
		printf "    JPY    : %'22.2f\n" "$(jq -r '.data.total_volume.jpy' <<< "${CGKGLOBAL}")"
		printf "    CNY    : %'22.2f\n" "$(jq -r '.data.total_volume.cny' <<< "${CGKGLOBAL}")"
		printf "    XAU(oz): %'22.2f\n" "$(jq -r '.data.total_volume.xau' <<< "${CGKGLOBAL}")"
		printf "    BTC    : %'22.2f\n" "$(jq -r '.data.total_volume.btc' <<< "${CGKGLOBAL}")"
		printf "    ETH    : %'22.2f\n" "$(jq -r '.data.total_volume.eth' <<< "${CGKGLOBAL}")"
		printf "    XRP    : %'22.2f\n" "$(jq -r '.data.total_volume.xrp' <<< "${CGKGLOBAL}")"
	fi
	
	printf "\n## Market Volume per Coin (Last 24H)\n"
	printf "  # SYMBOL      VOLUME                  CHANGE\n"
	jq -r '.[]|"\(.symbol) \(.total_volume) '${1^^}' \(.market_cap_change_percentage_24h)"' <<< "${MARKETGLOBAL}"  | awk '{ printf "  # %s   %'"'"'22.2f %s    %.4f%%\n", toupper($1) , $2 , $3 , $4 }'

	printf "\n## Supply and All Time High\n"
	printf "  # SYMBOL       CIRCULATING            TOTAL SUPPLY\n"
	jq -r '.[]|"\(.symbol) \(.circulating_supply) \(.total_supply)"' <<< "${MARKETGLOBAL}"  | awk '{ printf "  # %s      %'"'"'22.2f   %'"'"'22.2f\n", toupper($1) , $2 , $3 }'

	printf "\n## Price Stats (%s)\n" "${1^^}"
	jq -r '.[]|"\(.symbol) \(.high_24h) \(.low_24h) \(.price_change_24h) \(.price_change_percentage_24h)"' <<< "${MARKETGLOBAL}"  | awk '{ printf "  # %s=%s=%s=%s=%.4f%%\n", toupper($1) , $2 , $3 , $4 , $5 }' | column -t -s"=" -N"  # SYMBOL,HIGH(24h),LOW(24h),CHANGE,CHANGE"

	printf "\n## All Time Highs (%s)\n" "${1^^}"
	jq -r '.[]|"\(.symbol) \(.ath) \(.ath_change_percentage) \(.ath_date)"' <<< "${MARKETGLOBAL}"  | awk '{ printf "  # %s=%s=%.4f%%= %s\n", toupper($1) , $2 , $3 , $4 }' | column -t -s'=' -N'  # SYMBOL,PRICE,CHANGE,DATE'

	# Avoid erros being printed
	} 2>/dev/null
}

## -e Show Exchange info function
exf() { # -ee Show Exchange list
	if [[ "${EXOPT}" -eq 2 ]]; then
		ELIST="$(${YOURAPP} "https://api.coingecko.com/api/v3/exchanges/list")"
		# Print JSON?
		if [[ -n ${PJSON} ]]; then
			printf "%s\n" "${ELIST}"
			exit
		fi
		jq -r '.[]|"\(.id)=\(.name)"' <<< "${ELIST}" | column -et -s'=' -N"EXCHANGE_ID,EXCHANGE_NAME"
		printf "Exchanges: %s.\n" "$(jq -r '.[].id' <<< "${ELIST}" | wc -l)"
		exit
	fi

	# Test screen width
	# if stdout is redirected; skip this
	if ! [[ -t 1 ]]; then
		true
	elif test "$(tput cols)" -lt "85"; then
		COLCONF="-HINC?,COUNTRY,EX_NAME -TEX_ID"
		printf "OBS: More columns are needed to print table properly.\n" 1>&2
	elif test "$(tput cols)" -lt "115"; then
		COLCONF="-HINC?,EX_NAME -TCOUNTRY,EX_ID"
		printf "OBS: More columns are needed to print table properly.\n" 1>&2
	else
		COLCONF="-TCOUNTRY,EX_ID,EX_NAME"
	fi

	#Get pages with exchange info
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		${YOURAPP} "https://api.coingecko.com/api/v3/exchanges?page=1"
		exit
	fi
	printf "Table of Exchanges\n"
	${YOURAPP2} "https://api.coingecko.com/api/v3/exchanges" 2>&1 | grep -ie "total:" -e "per-page:" | sort -r 
	# Check how many pages to fetch and fetch 4 instead of one if nothing specified
	test -z "${TPAGES}" && TPAGES=4
	i="${TPAGES}"
	while [[ "${i}" -ge 1 ]]; do
		printf "Page %s of %s.\n" "${i}" "${TPAGES}" 1>&2
		${YOURAPP} "https://api.coingecko.com/api/v3/exchanges?page=${i}" | jq -r 'reverse[] | "\(if .trust_score_rank == null then "??" else .trust_score_rank end)=\(if .trust_score == null then "??" else .trust_score end)=\(.id)=[\(.trade_volume_24h_btc)]=\(.trade_volume_24h_btc_normalized)=\(if .has_trading_incentive == true then "yes" else "no" end)=\(if .year_established == null then "??" else .year_established end)=\(if .country != null then .country else "??" end)=\(.name)"' | column -et -s'=' -N"TRANK,TSCORE,EX_ID,[VOLUME(24H;BTC)],NORMALISED_VOLUME,INC?,YEAR,COUNTRY,EX_NAME" ${COLCONF}
		i=$((i-1))
	done
	# Check if CoinEgg still has a weird "en_US" in its name that havocks table
}

## Bank currency rate function
bankf() {
	# Call CGK.com less
	# Get currency lists (they will be exported by the function)
	clistf
	tolistf
	
	# Grep possible currency ids
	if jq -r '.[],keys[]' <"${CGKTEMPLIST1}" | grep -qi "^${2}$"; then
		changevscf "${2}" 2>/dev/null
		MAYBE1="${GREPID}"
	fi
	if jq -r '.[],keys[]' <"${CGKTEMPLIST1}" | grep -qi "^${3}$"; then
		changevscf "${3}" 2>/dev/null
		MAYBE2="${GREPID}"
	fi

	# Get CoinGecko JSON
	CGKRATERAW="$(${YOURAPP} "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,${2,,},${3,,},${MAYBE1},${MAYBE2}&vs_currencies=btc,${2,,},${3,,},${MAYBE1},${MAYBE2}")"
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${CGKRATERAW}"
		exit
	fi
	export CGKRATERAW
	# Get rates to from_currency anyways
	if [[ "${2,,}" = "btc" ]]; then
		BTCBANK=1
	elif ! BTCBANK="$("${0}" "${2,,}" btc 2>/dev/null)"; then
		BTCBANK="(1/$("${0}" bitcoin "${2,,}" 2>/dev/null))" ||
			{ echo "Function error; check currencies."; exit 1;}
	fi
	# Get rates to to_currency anyways
	if [[ "${3,,}" = "btc" ]]; then
		BTCTOCUR=1
	elif ! BTCTOCUR="$("${0}" "${3,,}" btc 2>/dev/null)"; then
		BTCTOCUR="(1/$("${0}" bitcoin "${3,,}" 2>/dev/null))" ||
			{ echo "Function error; check currencies."; exit 1;}
	fi
	# Timestamp? No timestamp for this API
	# Calculate result
	bc -l <<< "(${1}*${BTCBANK})/${BTCTOCUR}" | xargs printf "%.${SCL}f\n"
	exit
}

## -t Ticker Function
tickerf() {
	# Temp file for tickers
	CGKTEMPLIST3=$(mktemp /tmp/cgk.tickers.XXXXX) || tmperrf
	## Trap temp cleaning functions
	trap "rm3f; exit 130" EXIT SIGINT
	# Test screen width
	# if stdout is redirected; skip this
	if ! [[ -t 1 ]]; then
		true
	elif test "$(tput cols)" -lt "105"; then
		COLCONF="-HEX_NAME,LAST_TRADE,PRICE(BTC),PRICE(USD)"
		printf "Note: More columns are needed to show more info.\n" 1>&2
	elif test "$(tput cols)" -lt "115"; then
		COLCONF="-HEX_NAME,LAST_TRADE"
		printf "Note: More columns are needed to show more info.\n" 1>&2
	else
		COLCONF="-TLAST_TRADE" 
	fi
	# Start print Heading
	printf "Tickers (%s)\n" "${CODE1^^}" 
	${YOURAPP2} "https://api.coingecko.com/api/v3/coins/${2,,}/tickers" 2>&1 | grep -ie "total:" -e "per-page:" | sort -r
	if [[ -z "${CODE2}" ]]; then
		printf "Results for %s\n" "${CODE1^^}"
	else
		printf "Results for only %s/%s\n" "${CODE1^^}" "${CODE2^^}"
	fi
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		${YOURAPP2} "https://api.coingecko.com/api/v3/coins/${2,,}/tickers"
		${YOURAPP} "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}"
		exit
	fi
	## If there is CODE 2, then make sure you get only those pairs specified
	GREPARG="."
	test -n "${CODE2}" && GREPARG="^${CODE1}/${CODE2}="
	## Grep 4 pages of results instead of only 1
	test -z "${TPAGES}" && TPAGES=4
	printf "..." 1>&2
	i="${TPAGES}"
	while [[ "${i}" -ge "1" ]]; do
		printf "\rPage %s of %s..." "${i}" "${TPAGES}" 1>&2
		${YOURAPP} "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}" | jq -r '.tickers[]|"\(.base)/\(.target)=\(.last)=\(.market.identifier)=\(.volume)=\(if .bid_ask_spread_percentage ==  null then "??" else .bid_ask_spread_percentage end)=\(.converted_last.btc)=\(.converted_last.usd)=\(.market.name)=\(.last_traded_at)"' >> "${CGKTEMPLIST3}"
		#TICKERS+="$(${YOURAPP} "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}" | jq -r '.tickers[]|"\(.base)/\(.target)=\(.last)=\(.market.identifier)=\(.volume)=\(if .bid_ask_spread_percentage ==  null then "??" else .bid_ask_spread_percentage end)=\(.converted_last.btc)=\(.converted_last.usd)=\(.market.name)=\(.last_traded_at)"')"
		i=$((i-1))
	done
	printf "\n"
	# Format all table and print

	




	grep -i -e "${GREPARG}" "${CGKTEMPLIST3}" | column -s= -et -N"MARKET,PRICE,EX_ID,VOLUME,SPREAD(%),PRICE(BTC),PRICE(USD),EX_NAME,LAST_TRADE" ${COLCONF}
}

## -l Print currency lists
listsf() {
	FCLISTS="$(${YOURAPP} "https://api.coingecko.com/api/v3/coins/list")"	
	VSCLISTS="$(${YOURAPP} "https://api.coingecko.com/api/v3/simple/supported_vs_currencies")"	
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n\n" "${FCLISTS}"
		printf "%s\n" "${VSCLISTS}"
		exit
	fi
	printf "List of supported FROM_CURRENCY and precious metal IDs and codes\n"
	jq -r '.[]|"\(.symbol)=\(.id)=\(.name)"' <<< "${FCLISTS}" | column -s'=' -et -N'SYMBOL,ID,NAME'
	printf "\nList of supported VS_CURRENCY Codes\n"
	jq -r '.[]' <<< "${VSCLISTS}" | tr "[:lower:]" "[:upper:]" | sort | column -c 80
}

# List of from_currencies
# Create temp file only if not yet created
clistf() {
	# Check if there is a list or create one
	if [[ -z "${CGKTEMPLIST1}" ]]; then
		# Make Temp files
		CGKTEMPLIST1=$(mktemp /tmp/cgk.list2.XXXXX) || tmperrf
		export CGKTEMPLIST1
		## Trap temp cleaning functions
		trap "rm1f; exit 130" EXIT SIGINT
		# Retrieve list from CGK
		${YOURAPP} "https://api.coingecko.com/api/v3/coins/list" | jq -r '[.[] | { key: .symbol, value: .id } ] | from_entries' >> "${CGKTEMPLIST1}"
	fi
}

# List of vs_currencies
tolistf() {
	# Ceck if there is a list or create one
	if [[ -z "${CGKTEMPLIST2}" ]]; then
		CGKTEMPLIST2=$(mktemp /tmp/cgk.list3.XXXXX) || tmperrf
		export CGKTEMPLIST2
		## Trap temp cleaning functions
		trap "rm1f; rm2f; exit 130" EXIT SIGINT
		# Retrieve list from CGK
		${YOURAPP} "https://api.coingecko.com/api/v3/simple/supported_vs_currencies" | jq -r '.[]' >> "${CGKTEMPLIST2}"
	fi
}

# Change currency code to ID in FROM_CURRENCY
# export currency id as GREPID
changevscf() {
	if jq -r keys[] <"${CGKTEMPLIST1}" | grep -qi "^${*}$"; then
		GREPID="$(jq -r ".${*,,}" <"${CGKTEMPLIST1}")"
	fi
}

# Temporary file management functions
rm1f() { rm -f "${CGKTEMPLIST1}"; }
rm2f() { rm -f "${CGKTEMPLIST2}"; }
rm3f() { rm -f "${CGKTEMPLIST3}"; }
tmperrf() { printf "Cannot create temp file at /tmp.\n" 1>&2; exit 1;}

# Check if there is any argument or option
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit 1
fi

# Parse options
while getopts ":behljmp:s:tv" opt; do
	case ${opt} in
		b ) ## Activate the Bank currency function
			BANK=1
			;;
		e ) ## List supported Exchanges
			[[ -z "${EXOPT}" ]] && EXOPT=1 || EXOPT=2
			;;
		h ) # Show Help
			echo -e "${HELP_LINES}"
			exit 0
			;;
		l ) ## List available currencies
			listsf
			exit
			;;
		j ) # Print JSON
			PJSON=1
			;;
		m ) ## Make Market Cap Table
			MCAP=1
			;;
		p ) # Number of pages to retrieve with the Ticker Function
			TPAGES=${OPTARG}
			;;
		s ) # Scale, Decimal plates
			SCL=${OPTARG}
			;;
		t ) # Tickers
			TOPT=1
			;;
		v ) # Version of Script
			head "${0}" | grep -e '# v'
			exit 0
			;;
		\? )
			echo "Invalid Option: -$OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

# Test for must have packages
if ! command -v jq &>/dev/null; then
	printf "JQ is required.\n" 1>&2
	exit 1
fi
if command -v curl &>/dev/null; then
	YOURAPP="curl -s"
	YOURAPP2="curl -s --head"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO-"
	YOURAPP2="wget -qO- --server-response"
else
	printf "cURL or Wget is required.\n" 1>&2
	exit 1
fi

# Call opt function
if [[ -n "${MCAP}" ]]; then
	mcapf "${@}"
	exit
fi

## Set default scale if no custom scale
if [[ -z ${SCL} ]]; then
	SCL="${SCLDEFAULTS}"
fi

# Set equation arguments
# If first argument does not have numbers OR isn't a  valid expression
if ! [[ "${1}" =~ [0-9] ]] ||
	[[ -z "$(bc -l <<< "${1}" 2>/dev/null)" ]]; then
	set -- 1 "${@:1:2}"
fi
# For use with ticker option
CODE1="${2}"
CODE2="${3}"
if [[ -z ${2} ]]; then
	set -- "${1}" btc
fi
if [[ -z ${3} ]]; then
	set -- "${@:1:2}" usd
fi

## Check FROM currency
# Make sure "XAG Silver" does not get translated to "XAG Xrpalike Gene"
if [[ -z "${BANK}" && "${2,,}" = "xag" ]]; then
	printf "Did you mean xrpalike-gene?\n" 1>&2
	exit 1
fi
clistf   # Bank opt needs this anyways
if [[ -z "${BANK}" ]]; then
	if ! jq -r '.[],keys[]' <"${CGKTEMPLIST1}" | grep -qi "^${2}$"; then
		printf "ERR: FROM_CURRENCY -- %s\n" "${2^^}" 1>&2
		printf "Check symbol/ID and market pair.\n" 1>&2
		exit 1
	fi
fi
## Check VS_CURRENCY
tolistf  # Bank opt needs this anyways
if [[ -z "${TOPT}" && -z "${BANK}" ]]; then
	if ! grep -qi "^${3}$" <"${CGKTEMPLIST2}"; then
		printf "ERR: VS_CURRENCY -- %s\n" "${3^^}" 1>&2
		printf "Check symbol/ID and market pair.\n" 1>&2
		exit 1
	fi
	unset GREPID
fi
# Check if I can get from currency ID
changevscf "${2}"
if [[ -n ${GREPID} ]]; then
	set -- "${1}" "${GREPID}" "${3}"
fi

## Call opt functions
if [[ -n ${TOPT} ]]; then
	tickerf "${@}"
	exit
fi
if [[ -n "${EXOPT}" ]]; then
	exf
	exit
fi
if [[ -n "${BANK}" ]]; then
	bankf "${@}"
	exit
fi

## Crypto and Central Bank Currency converter (Default option)
if [[ -z "${CGKRATERAW}" ]]; then
	# Make equation and print result
	bc -l <<< "scale=${SCL};(${1}*$(${YOURAPP} "https://api.coingecko.com/api/v3/simple/price?ids=${2,,}&vs_currencies=${3,,}" | jq -r '."'${2,,}'"."'${3,,}'"' | sed 's/e/*10^/g'))/1"
else	
	# From Bank function
	# Make equation and print result
	bc -l <<< "scale=${SCL};(${1}*$(jq -r '."'${2,,}'"."'${3,,}'"' <<< "${CGKRATERAW}" | sed 's/e/*10^/g'))/1"
fi

exit

#Dead code
# Ticker function Check for NO currency 
if [[ -n "${TOPT}" ]] && [[ -z "${1}" ]]; then
	printf "No currency given.\n" 1>&2
	exit 1
fi

