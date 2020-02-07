#!/bin/bash
# Cgk.sh -- Coingecko.com API Access
# v0.10.12  feb/2020  by mountaineerbr

#defaults

#default crypto, defaults=btc
DEFCUR=btc

#vs currency, defaults=usd
DEFVSCUR=usd

#scale, defaults=16
SCLDEFAULTS=16

#don't change these
LC_NUMERIC="en_US.UTF-8"

#troy ounce to gram ratio
TOZ='31.1034768'

## Manual and help
HELP_LINES="NAME
	\e[1;33;40m
	Cgk.sh -- Currency Converter and Market Stats\033[00m
		\e[1;33;40m  Coingecko.com API Access\033[00m

SYNOPSIS
	cgk.sh [-sNUM] [AMOUNT] 'FROM_CRYPTO' [VS_CURRENCY]

	cgk.sh -b [-g|-sNUM] [AMOUNT] 'FROM_CURRENCY' [VS_CURRENCY] 
	
	cgk.sh -d [CRYPTO]
	
	cgk.sh -ee [-p]
	
	cgk.sh -t [-pNUM] 'CRYPTO' [VS_CURRENCY]
	
	cgk.sh -m [VS_CURRENCY]

	cgk.sh [-hlv]


DESCRIPTION
	This programme fetches updated crypto and bank currency rates from Coin
	Gecko.com and can convert any amount of one supported currency into an-
	other. Currencies can be symbols or CoinGecko IDs, list them with option
	\"-l\". VS_CURRENCY is optional and defaults to ${DEFVSCUR,,}.
	
	CoinGecko has got a public API for many crypto and bank currency rates.
	Officially, CoinGecko only keeps rates of existing market pairs. For ex-
	ample, the market BTC/XRP is supported but XRP/BTC is not.

	Central bank currency conversions are not supported directly, but we can
	derive them undirectly, for e.g. USD vs CNY. As CoinGecko updates fre-
	quently, it is one of the best APIs for bank currency rates, too.

	The  bank  currency Function \"-b\" can calculate central bank currency
	rates , such  as USD/BRL. It can also calculate unofficially supported
	crypto currency markets, such as \"ZCash vs. DigiByte\" and \"Ripple vs
	Bitcoin\".

	Due to how CoinGecko API works, this programme needs do a lot of check-
	ing and multiple calls to the API each run. For example, CoinGecko only
	accepts  IDs  in the  \"from_currrency\" field. However, if input is a 
	symbol, it will be swapped to its corresponding ID automatically.
	
	Default precision is ${SCLDEFAULTS} and can be adjusted with option \"-s\" (scale).
	

ABBREVIATIONS
	Some functions function uses abbreviations to indicate data type.

		EX_ID 		Exchange identifier
		EX_NAME 	Exchange name
		INC? 		Incentives for trading?
		TRANK 		Trust rank
		TSCORE 		Trust score

	
	For more information, such as normal and normalized volume, check:

		<https://blog.coingecko.com/trust-score/>


PRECIOUS METALS -- OUNCES TROY AND GRAMS
	The following section explains about the GRAM/OZ constant used in this
	program.
	
	Gold and Silver are priced in Troy Ounces. It means that in each troy 
	ounce there are aproximately 31.1 grams, such as represented by the fol-
	lowing constant:
		
		\"GRAM/OUNCE\" rate = ${TOZ}
	
	
	Option \"-g\" will try to calculate rates in grams instead of ounces for
	precious metals.
	
	Nonetheless, it is useful to learn how to do this convertion manually. 
	It is useful to define a variable with the gram to troy oz ratio in your
	\".bashrc\" to work with precious metals (see usage example 10). I sug-
	gest a variable called TOZ that will contain the GRAM/OZ constant:
	
		TOZ=\"${TOZ}\"
	
	
	To use grams instead of ounces for calculation precious metals rates, 
	use option \"-g\". E.g. one gram of gold in USD, with two decimal plates:
	
		$ cgk.sh -2bg 1 xau usd 
	
	
	To get \e[0;33;40mAMOUNT\033[00m of EUR in grams of Gold, just multiply
	AMOUNT by the \"GRAM/OUNCE\" constant.
	
		$ cgk.sh -b \"\e[0;33;40mAMOUNT\033[00m*31.1\" eur xau 
	
	
	One EUR in grams of Gold:
	
		$ cgk.sh -b \"\e[1;33;40m1\033[00m*31.1\" eur xau 
	
	
	To get \e[0;33;40mAMOUNT\033[00m of grams of Gold in EUR, just divide 
	AMOUNT by the \"GRAM/OUNCE\" constant.
	
		$ cgk.sh -b \"\e[0;33;40m[amount]\033[00m/31.1\" xau usd 
	
	
	One gram of Gold in EUR:
			
		$ cgk.sh -b \"\e[1;33;40m1\033[00m/31.1\" xau eur 
	
	
	To convert (a) from gold to crypto currencies, (b) from bank currencies
	to gold	or (c) from gold to bank curren-cies, do not forget to use the 
	option \"-b\"!


24H ROLLING TICKER FUNCTION \"-t\" 
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
	Licensed under the GNU Public License v3 or better. It is distributed 
	without support or bug corrections. This programme needs Bash, cURL or 
	Wget, JQ and Coreutils to work properly.
	
	It  is  _not_ advisable to depend solely on CoinGecko rates for serious 
	trading.
	
	If you found this useful, consider giving me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES		
		(1)     One Bitcoin in US Dollar:
			
			$ cgk.sh btc
			
			$ cgk.sh 1 btc usd


		(2)     100 ZCash in Digibyte (unofficial market, use opt \"-b\") 
			with 8 decimal plates:
			
			$ cgk.sh -b -s8 100 zcash digibyte 
			
			$ cgk.sh -8b 100 zec dgb 

		
		(3)     One thousand Brazilian Real in US Dollar with 3 decimal
			plates and using math expression in AMOUNT:
			
			$ cgk.sh -3b '101+(2*24.5)+850' brl usd 


		(4)     One troy ounce of Gold in U.S.A. Dollar:
			
			$ cgk.sh -b xau 
			
			$ cgk.sh -b 1 xau usd 


		(5)    One Bitcoin in troy ounces of Gold:
					
			$ cgk.sh 1 btc xau 


		(6)    Tickers of any Ethereum pair from all exchanges;
					
			$ cgk.sh -t eth 
			
			TIP: use Less with opion -S (--chop-long-lines) or the 
			\"Most\" pager for scrolling horizontally:

			$ cgk.sh -t eth | less -S


		(7)    Only Tickers of Ethereum/Bitcoin, and retrieve 10 pages
			of results:
					
			$ cgk.sh -t -p10 eth btc 


		(8) 	Market cap function, show data for Chinese CNY:

			$ cgk.sh -m cny


OPTIONS
	-NUM 	  Shortcut for scale setting, same as \"-sNUM\".

	-b 	  Activate Bank Currency function; it extends support for con-
		  verting any central bank or crypto currency to any other.

	-d 'CRYPTO'
		  Dominance of a single crypto currency in percentage.

	-e 	  Exchange information; number of pages to fetch with option \"-p\";
		  pass \"-ee\" to print a list of exchange names and IDs only.

	-g 	  Use grams instead of troy ounces; only for precious metals.
		
	-h 	  Show this help.

	-j 	  Debug; print JSON.

	-l 	  List supported currencies.

	-m [VS_CURRENCY]
		  Market capitulation table; defaults=USD.

	-p [NUM]
		  Number of pages retrieved from the server; each page may con-
		  tain 100 results; use with options \"-e\" and \"-t\"; defaults=4.
	 	
	-s [NUM]  Scale setting (decimal plates); defaults=${SCLDEFAULTS}.
	
	-t 	  Tickers of a single cryptocurrency from all suported exchanges
		  and all its pairs; a second crypto can also be set to form a 
		  currency pair; can use with \"-p\".
		
	-v 	  Show this programme version."

## Functions
## -m Market Cap function		
#-d dominance opt
mcapf() {
	# Check if input has a defined vs_currency
	if [[ -z "${1}" ]]; then
		NOARG=1
		set -- "${DEFVSCUR,,}"
	fi
	# Get Data 
	CGKGLOBAL="$(${YOURAPP} "https://api.coingecko.com/api/v3/global" -H  "accept: application/json")"
	# Check if input is a valid vs_currency for this function
	if ! jq -r '.data.total_market_cap|keys[]' <<< "${CGKGLOBAL}" | grep -qi "^${1}$"; then
		printf "Using USD. Not supported -- %s.\n" "${1^^}" 1>&2
		NOARG=1
		set -- usd
	fi

	#-d only dominance?
	if [[ -n "${DOMOPT}" ]] &&
		DOM="$(jq -e ".data.market_cap_percentage.${1,,}//empty" <<< "${CGKGLOBAL}")"; then
		
		# Print JSON?
		if [[ -n ${PJSON} ]]; then
			printf "%s\n" "${CGKGLOBAL}"
			exit
		fi

		printf "%.${SCL}f\n" "${DOM}"
		
		exit 
	else
		jq -r '.data.market_cap_percentage|to_entries[] | [.key, .value] | @tsv' <<< "${CGKGLOBAL}"
		exit 1
	fi
	#DOMINANCEARRAY=($(jq -r '.data.market_cap_percentage | keys_unsorted[]' <<< "${CGKGLOBAL}"))

	MARKETGLOBAL="$(${YOURAPP} "https://api.coingecko.com/api/v3/coins/markets?vs_currency=${1,,}&order=market_cap_desc&per_page=10&page=1&sparkline=false")"

	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${CGKGLOBAL}"
		printf 'Second json:' 1>&2
		sleep 4
		printf "%s\n" "${MARKETGLOBAL}"
		exit
	fi

	#timestamp
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
	printf "  # SYMBOL      CAP(%s)            CHANGE(24h)\n" "${1^^}"
	jq -r '.[]|"\(.symbol) \(.market_cap)  \(.market_cap_change_percentage_24h)"' <<< "${MARKETGLOBAL}"  | awk '{ printf "  # %s  %'"'"'22.2f    %.4f%%\n", toupper($1) , $2 , $3 , $4 }'
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
	unset BANK FMET TMET
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
	# Get rates to vs_currency anyways
	if [[ "${3,,}" = "btc" ]]; then
		BTCTOCUR=1
	elif ! BTCTOCUR="$("${0}" "${3,,}" btc 2>/dev/null)"; then
		BTCTOCUR="(1/$("${0}" bitcoin "${3,,}" 2>/dev/null))" ||
			{ echo "Function error; check currencies."; exit 1;}
	fi
	# Timestamp? No timestamp for this API
	# Calculate result
	# Precious metals in grams?
	ozgramf "${2}" "${3}"
	RESULT="$(bc -l <<< "(((${1})*${BTCBANK})/${BTCTOCUR})${GRAM}${TOZ}")"
	printf "%.${SCL}f\n" "${RESULT}"
}

## -t Ticker Function
tickerf() {
	# Temp file for tickers
	CGKTEMPLIST3=$(mktemp /tmp/cgk.tickers.XXXXX) || tmperrf
	## Trap temp cleaning functions
	trap "rm1f; rm3f; exit" EXIT SIGINT
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
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		${YOURAPP2} "https://api.coingecko.com/api/v3/coins/${2,,}/tickers"
		${YOURAPP} "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}"
		exit
	fi
	## If there is CODE 2, then make sure you get only those pairs specified
	test -n "${CODE2}" && GREPARG="^${CODE1}/${CODE2}=" || GREPARG="."
	## Grep 4 pages of results instead of only 1
	test -z "${TPAGES}" && TPAGES=4
	printf "..." 1>&2
	i="${TPAGES}"
	while [[ "${i}" -ge "1" ]]; do
		printf "\rPage %s of %s..." "${i}" "${TPAGES}" 1>&2
		${YOURAPP} "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}" | jq -r '.tickers[]|"\(.base)/\(.target)=\(.last)=\(.market.identifier)=\(.volume)=\(if .bid_ask_spread_percentage ==  null then "??" else .bid_ask_spread_percentage end)=\(.converted_last.btc)=\(.converted_last.usd)=\(.market.name)=\(.last_traded_at)"' >> "${CGKTEMPLIST3}"
		i=$((i-1))
	done
	printf "\n"
	# Format all table and print
	grep -i -e "${GREPARG}" "${CGKTEMPLIST3}" | column -s= -et -N"MARKET,PRICE,EX_ID,VOLUME,SPREAD(%),PRICE(BTC),PRICE(USD),EX_NAME,LAST_TRADE" ${COLCONF}
	if [[ -z "${CODE2}" ]]; then
		printf "Matches(%s): %s\n" "${CODE1^^}" "$(grep -ci -e "${GREPARG}" "${CGKTEMPLIST3}")"
	else
		printf "Matches(%s/%s): %s\n" "${CODE1^^}" "${CODE2^^}" "$(grep -ci -e "${GREPARG}" "${CGKTEMPLIST3}")"
	fi
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
	if [[ ! -f "${CGKTEMPLIST1}" ]]; then
		# Make Temp files
		CGKTEMPLIST1=$(mktemp /tmp/cgk.list1.XXXXX) || tmperrf
		export CGKTEMPLIST1
		## Trap temp cleaning functions
		trap "rm1f; exit" EXIT SIGINT
		# Retrieve list from CGK
		${YOURAPP} "https://api.coingecko.com/api/v3/coins/list" | jq -r '[.[] | { key: .symbol, value: .id } ] | from_entries' >> "${CGKTEMPLIST1}"
	fi
}

# List of vs_currencies
tolistf() {
	# Check if there is a list or create one
	if [[ ! -f "${CGKTEMPLIST2}" ]]; then
		CGKTEMPLIST2=$(mktemp /tmp/cgk.list2.XXXXX) || tmperrf
		export CGKTEMPLIST2
		## Trap temp cleaning functions
		trap "rm1f; rm2f; exit" EXIT SIGINT
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


# Precious metals in grams?
ozgramf() {	
	# Precious metals - troy ounce to gram
	#CGK does not support Platinum(xpt) and Palladium(xpd)
	if [[ -n "${GRAMOPT}" ]]; then
		if grep -qi -e 'XAU' -e 'XAG' <<<"${1}"; then
			FMET=1
		fi
		if grep -qi -e 'XAU' -e 'XAG' <<<"${2}"; then
			TMET=1
		fi
		if { [[ -n "${FMET}" ]] && [[ -n "${TMET}" ]];} ||
			{ [[ -z "${FMET}" ]] && [[ -z "${TMET}" ]];}; then
			unset TOZ
			unset GRAM
		elif [[ -n "${FMET}" ]] && [[ -z "${TMET}" ]]; then
			GRAM='/'
		elif [[ -z "${FMET}" ]] && [[ -n "${TMET}" ]]; then
			GRAM='*'
		fi
	else
		unset TOZ
		unset GRAM
	fi
}


# Parse options
while getopts ":0123456789bdeghljmp:s:tv" opt; do
	case ${opt} in
		( [0-9] ) #scale, same as '-sNUM'
			SCL="${SCL}${opt}"
			;;
		( b ) ## Activate the Bank currency function
			BANK=1
			;;
		( d ) #single currency dominance
			DOMOPT=1
			MCAP=1
			;;
		( e ) ## List supported Exchanges
			[[ -z "${EXOPT}" ]] && EXOPT=1 || EXOPT=2
			;;
		( g ) # Gram opt
			GRAMOPT=1
			;;
		( h ) # Show Help
			echo -e "${HELP_LINES}"
			exit 0
			;;
		( l ) ## List available currencies
			LOPT=1
			;;
		( j ) # Print JSON
			PJSON=1
			;;
		( m ) ## Make Market Cap Table
			MCAP=1
			;;
		( p ) # Number of pages to retrieve with the Ticker Function
			TPAGES=${OPTARG}
			;;
		( s ) # Scale, Decimal plates
			SCL=${OPTARG}
			;;
		( t ) # Tickers
			TOPT=1
			;;
		( v ) # Version of Script
			head "${0}" | grep -e '# v'
			exit 0
			;;
		( \? )
			printf "Invalid option: -%s\n" "${OPTARG}" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

## Set default scale if no custom scale
if [[ -z ${SCL} ]]; then
	SCL="${SCLDEFAULTS}"
fi

# Test for must have packages
if [[ -z "${YOURAPP}" ]]; then
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
	export YOURAPP YOURAPP2
fi

# Call opt function
if [[ -n "${MCAP}" ]]; then
	mcapf "${@}"
	exit
elif [[ -n "${EXOPT}" ]]; then
	exf
	exit
elif [[ -n "${LOPT}" ]]; then
	listsf
	exit
fi

# Set equation arguments
# If first argument does not have numbers
if ! [[ "${1}" =~ [0-9] ]]; then
	set -- 1 "${@}"
# if AMOUNT is not a valid expression for Bc
elif [[ -z "$(bc -l <<< "${1}" 2>/dev/null)" ]]; then
	printf "Invalid expression in \"AMOUNT\".\n" 1>&2
	exit 1
fi
# For use with ticker option
CODE1="${2}"
CODE2="${3}"
if [[ -z ${2} ]]; then
	set -- "${1}" "${DEFCUR,,}"
fi
if [[ -z ${3} ]]; then
	set -- "${1}" "${2}" "${DEFVSCUR,,}"
fi

## Check FROM currency
# Make sure "XAG Silver" does not get translated to "XAG Xrpalike Gene"
if [[ -n "${BANK}" ]]; then
	clistf
	tolistf
else
	if [[ "${2,,}" = "xag" ]]; then
		printf "Did you mean xrpalike-gene?\n" 1>&2
		exit 1
	fi
	clistf   # Bank opt needs this anyways
	if ! jq -r '.[],keys[]' <"${CGKTEMPLIST1}" | grep -qi "^${2}$"; then
		printf "ERR: FROM_CURRENCY -- %s\n" "${2^^}" 1>&2
		printf "Check symbol/ID and market pair.\n" 1>&2
		exit 1
	fi
	## Check VS_CURRENCY
	if [[ -z "${TOPT}" ]]; then
		tolistf  # Bank opt needs this anyways
		if ! grep -qi "^${3}$" <"${CGKTEMPLIST2}"; then
			printf "ERR: VS_CURRENCY -- %s\n" "${3^^}" 1>&2
			printf "Check symbol/ID and market pair.\n" 1>&2
			exit 1
		fi
	fi
	unset GREPID
	# Check if I can get from currency ID
	changevscf "${2}"
	if [[ -n ${GREPID} ]]; then
		set -- "${1}" "${GREPID}" "${3}"
	fi
fi

## Call opt functions
if [[ -n ${TOPT} ]]; then
	tickerf "${@}"
	exit
elif [[ -n "${BANK}" ]]; then
	bankf "${@}"
	exit
fi

## Default option - Cryptocurrency converter
# Precious metals in grams?
ozgramf "${2}" "${3}"
if [[ -n "${CGKRATERAW}" ]]; then
	# Result for Bank function
	bc -l <<< "${1}*$(jq -r '."'${2,,}'"."'${3,,}'"' <<< "${CGKRATERAW}" | sed 's/e/*10^/g')"
else
	# Make equation and print result
	RATE="$(${YOURAPP} "https://api.coingecko.com/api/v3/simple/price?ids=${2,,}&vs_currencies=${3,,}")"
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${RATE}"
		exit
	fi
	RATE="$(jq -r '."'${2,,}'"."'${3,,}'"' <<<"${RATE}" | sed 's/e/*10^/g')"
	RESULT="$(bc -l <<< "((${1})*${RATE})${GRAM}${TOZ}")"
	printf "%.${SCL}f\n" "${RESULT}"
fi

exit

#Dead code

