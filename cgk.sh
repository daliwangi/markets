#!/bin/bash
#
# Cgk.sh -- Coingecko.com API Access
# v0.8.3  2019/nov/13  by mountaineerbr

# Some defaults
LC_NUMERIC="en_US.UTF-8"

## Manual and help
HELP_LINES="NAME
	\e[1;33;40m
	Cgk.sh -- Currency Converter and Market Stats\033[00m
		\e[1;33;40m  Coingecko.com API Access\033[00m

SYNOPSIS
	cgk.sh [optional:amount] [from_currency] [vs_currency]

	cgk.sh [-bs] [optional:amount] [from_currency] [vs_currency]
	
	cgk.sh [-pt] [currency] [optional:vs_id|vs_symbol]

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
		P_SP 		Price spread
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

		
		(9)    Ticker for all Bitcoin market pairs:
			
			$ cgk.sh -t btc 


		(10)    Ticker for Bitcoin/USD only:
			
			$ cgk.sh -t btc usd 
		

		(11)    One Bitcoin in ounces of Gold:
					
			$ cgk.sh 1 btc xau 


		(12)    \e[0;33;40m[Amount]\033[00m of EUR in grams of Gold:
					
			$ cgk.sh \"\e[0;33;40m[amount]\033[00m*28.3495\" eur xau 

			    Just multiply amount by the \"gram/ounce\" rate.


		(13)    \e[1;33;40mOne\033[00m EUR in grams of Gold:
					
			$ cgk.sh -b \"\e[1;33;40m1\033[00m*28.3495\" eur xau 


		(14)    \e[0;33;40m[Amount]\033[00m (grams) of Gold in USD:
					
			$ cgk.sh -b \"\e[0;33;40m[amount]\033[00m/28.3495\" xau usd 
			
			    Just divide amount by the \"gram/ounce\" rate.

		
		(15)    \e[1;33;40mOne\033[00m gram of Gold in EUR:
					
			$ cgk.sh -b \"\e[1;33;40m1\033[00m/28.3495\" xau eur 


		(16)    Tickers of any Ethereum pair from all exchanges;
					
			$ cgk.sh -t eth 


		(17)    Only Tickers of Ethereum/Bitcoin, and retrieve 10 pages
			of results:
					
			$ cgk.sh -t -p10 eth btc 


		(18) 	Market cap function, show data for Chinese CNY:

			$ cgk.sh -m cny


OPTIONS
		-b 	Activate Bank Currency function; it extends support for
			converting any central bank or crypto currency to any
			other.

		-e 	Exchange information; number of pages to fecth with opt-
			ion \"-p\"; if used with \"-l\", only exchange	names 
			and IDs will be printed.

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

# Check if there is any argument or option
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit 1
fi
# Parse options
# If the very first character of the option string is a colon (:) then getopts will not report errors and instead will provide a means of handling the errors yourself.
while getopts ":bemlhjp:s:tv" opt; do
  case ${opt} in
	b ) ## Activate the Bank currency function
		BANK=1
		;;
	e ) ## List supported Exchanges
		EXOPT=1
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

# Ticker function Check for NO currency 
if [[ -n "${TOPT}" ]] && [[ -z "${1}" ]]; then
	printf "No currency given.\n" 1>&2
	exit 1
fi

# Temporary file management functions
rm1f() { rm -f "${CGKTEMPLIST2}"; }
rm2f() { rm -f "${CGKTEMPLIST3}"; }
tmperrf() { printf "Cannot create temp file at /tmp.\n" 1>&2; exit 1;}

## Some recurring functions
# List of from_currencies
# Only if there is no path created already
clistf() {
	# Ceck if there is a list or create one
	if [[ -z "${CGKTEMPLIST2}" ]]; then
		# Make Temp files
		CGKTEMPLIST2=$(mktemp /tmp/cgk.list2.XXXXX) || tmperrf
		export CGKTEMPLIST2
		## Trap temp cleaning functions
		trap "rm1f; exit 130" EXIT SIGINT
		# Retrieve list from CGK
		curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H  "accept: application/json" |
		jq -r '[.[] | { key: .symbol, value: .id } ] | from_entries' >> "${CGKTEMPLIST2}"
	fi
}
# List of vs_currencies
tolistf() {
	# Ceck if there is a list or create one
	if [[ -z "${CGKTEMPLIST3}" ]]; then
		CGKTEMPLIST3=$(mktemp /tmp/cgk.list3.XXXXX) || tmperrf
		export CGKTEMPLIST3
		## Trap temp cleaning functions
		trap "rm1f; rm2f; exit 130" EXIT SIGINT
		# Retrieve list from CGK
		curl -s https://api.coingecko.com/api/v3/simple/supported_vs_currencies | jq -r '.[]' >> "${CGKTEMPLIST3}"
	fi
}

# Change currency code to ID in FROM_CURRENCY
# export currency id as GREPID
changevscf() {
	if jq -r keys[] <"${CGKTEMPLIST2}" | grep -qi "^${*}$"; then
		GREPID="$(jq -r ".${*,,}" <"${CGKTEMPLIST2}")"
	fi
}

## -m Market Cap function		
mcapf() {
	# Check if input has a defined to_currency
	if [[ -z "${1}" ]]; then
		NOARG=1
		set -- usd
	fi
	# Get Data 
	CGKGLOBAL="$(curl -sX GET "https://api.coingecko.com/api/v3/global" -H  "accept: application/json")"
	#DOMINANCEARRAY=($(jq -r '.data.market_cap_percentage | keys_unsorted[]' <<< "${CGKGLOBAL}"))
	# Check if input is a valid to_currency for this function
	if ! jq -r '.data.total_market_cap|keys[]' <<< "${CGKGLOBAL}" | grep -qi "^${1}$"; then
		printf "Using USD. Not supported -- %s.\n" "${1^^}" 1>&2
		NOARG=1
		set -- usd
	fi
	MARKETGLOBAL="$(curl -sX GET "https://api.coingecko.com/api/v3/coins/markets?vs_currency=${1,,}&order=market_cap_desc&per_page=10&page=1&sparkline=false" -H  "accept: application/json")"
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
	exit 0
}
test -n "${MCAP}" && mcapf ${*}

## -e Show Exchange info function
exf() { # -el Show Exchange list
	if [[ -n "${LISTS}" ]]; then
		ELIST="$(curl -sX GET "https://api.coingecko.com/api/v3/exchanges/list" -H  "accept: application/json")"
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
	if ! [[ -t 1 ]]; then
		echo here0; exit
		:
	fi
	if test "$(tput cols)" -lt "85"; then
		COLCONF="-HINC?,COUNTRY,EX_NAME -TEX_ID"
		printf "OBS: More columns are needed to print table properly.\n" 1>&2
	elif test "$(tput cols)" -lt "105"; then
		COLCONF="-HINC?,COUNTRY,EX_NAME"
		printf "OBS: More columns are needed to print table properly.\n" 1>&2
	elif test "$(tput cols)" -lt "115"; then
		COLCONF="-HINC?,EX_NAME -WCOUNTRY"
		printf "OBS: More columns are needed to print table properly.\n" 1>&2
	fi

	#Get pages with exchange info
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		curl -sX GET "https://api.coingecko.com/api/v3/exchanges?page=1" -H  "accept: application/json"
		exit
	fi
	printf "Table of Exchanges\n"
	curl -s --head "https://api.coingecko.com/api/v3/exchanges" | grep -ie "total:" -e "per-page:" | sort -r 1>&2
	# Check how many pages to fetch and fetch 4 instead of one if nothing specified
	test -z "${TPAGES}" && TPAGES=4
	i="${TPAGES}"
	while [[ "${i}" -ge 1 ]]; do
		printf "Page %s of %s.\n" "${i}" "${TPAGES}" 1>&2
		curl -sX GET "https://api.coingecko.com/api/v3/exchanges?page=${i}" -H  "accept: application/json" | jq -r 'reverse[] | "\(if .trust_score_rank == null then "??" else .trust_score_rank end)=\(if .trust_score == null then "??" else .trust_score end)=\(.id)=[\(.trade_volume_24h_btc)]=\(.trade_volume_24h_btc_normalized)=\(if .has_trading_incentive == true then "yes" else "no" end)=\(if .year_established == null then "??" else .year_established end)=\(if .country != null then .country else "??" end)=\(.name)"' | column -et -s'=' -N"TRANK,TSCORE,EX_ID,[VOLUME(24H;BTC)],NORMALISED_VOLUME,INC?,YEAR,COUNTRY,EX_NAME" ${COLCONF}
		i=$((i-1))
	done
	# Check if CoinEgg still has a weird "en_US" in its name that havocks table
	exit
}
test -n "${EXOPT}" && exf "${*}"

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
	printf "List of supported FROM_CURRENCY and precious metal IDs and codes\n"
	jq -r '.[]|"\(.symbol)=\(.id)=\(.name)"' <<< "${FCLISTS}" | column -s'=' -et -N'SYMBOL,ID,NAME'
	printf "\nList of supported VS_CURRENCY Codes\n"
	jq -r '.[]' <<< "${VSCLISTS}" | tr "[:lower:]" "[:upper:]" | sort | column -c 80
}
if [[ -n "${LISTS}" ]]; then
	listsf
	exit
fi

## Check for internet connection function ( CURRENTLY UNUSED )
#icheck() {
#if [[ -z "${RESULT}" ]] &&
#	   ! ping -q -w7 -c2 8.8.8.8 &> /dev/null; then
#	printf "Bad internet connection.\n"
#fi
#}

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
# If first argument does not have numbers OR isn't a  valid expression
if ! [[ "${1}" =~ [0-9] ]] ||
	[[ -z "$(bc -l <<< "${1}" 2>/dev/null)" ]]; then
	set -- 1 "${@:1:2}"
fi

if [[ -z ${3} ]]; then
	set -- "${@:1:2}" usd
fi

## Bank currency rate function
bankf() {
	# Call CGK.com less
	# Get currency lists (they will be exported by the function)
	clistf
	tolistf
	
	# Grep possible currency ids
	if jq -r '.[],keys[]' <"${CGKTEMPLIST2}" | grep -qi "^${2}$"; then
		changevscf "${2}" 2>/dev/null
		MAYBE1="${GREPID}"
	fi
	if jq -r '.[],keys[]' <"${CGKTEMPLIST2}" | grep -qi "^${3}$"; then
		changevscf "${3}" 2>/dev/null
		MAYBE2="${GREPID}"
	fi

	# Get CoinGecko JSON
	CGKRATERAW="$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,${2,,},${3,,},${MAYBE1},${MAYBE2}&vs_currencies=btc,${2,,},${3,,},${MAYBE1},${MAYBE2}" -H  "accept: application/json")"
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
if [[ -n "${BANK}" ]]; then
	bankf ${*}
	exit
fi

## Check you are not requesting some unsupported FROM_CURRENCY
# Make sure "XAG Silver" does not get translated to "XAG Xrpalike Gene"
if [[ "${2,,}" = "xag" ]]; then
	printf "Did you mean xrpalike-gene?\n" 1>&2
	exit 1
fi
clistf
if ! jq -r '.[],keys[]' <"${CGKTEMPLIST2}" | grep -qi "^${2}$"; then
	printf "ERR: FROM_CURRENCY -- %s\n" "${2^^}" 1>&2
	printf "Check symbol/ID and market pair.\n" 1>&2
	exit 1
fi

## Check you are not requesting some unsupported VS_CURRENCY
tolistf
if [[ -z "${TOPT}" ]] && [[ -z "${BANK}" ]] && ! grep -qi "^${3}$" <"${CGKTEMPLIST3}"; then
	printf "ERR: VS_CURRENCY -- %s\n" "${3^^}" 1>&2
	printf "Check symbol/ID and market pair.\n" 1>&2
	exit 1
fi
unset GREPID
# Check if I can help changing from currency code (incorrect) 
# to its id (correct) (for FROM_CURRENCY)
changevscf "${2}"
if [[ -n ${GREPID} ]]; then
	set -- "${1}" "${GREPID}" "${3}"
fi

## -t Ticker Function
tickerf() {
	# Test screen width
	if ! [[ -t 1 ]]; then
		:
	elif test "$(tput cols)" -lt "115"; then
		COLCONF="-HEX_NAME,LAST_TRADE_TIME"
		printf "Note: More columns are needed to show more info.\n" 1>&2
	elif test "$(tput cols)" -lt "140"; then
		COLCONF="-HLAST_TRADE_TIME"
		printf "Note: More columns are needed to show more info.\n" 1>&2
	fi
	# Start print Heading
	printf "Tickers\n" 
	printf "Results for %s\n" "${ORIGARG1^^}"
	curl -s --head "https://api.coingecko.com/api/v3/coins/${2,,}/tickers" | grep -ie "total:" -e "per-page:" | sort -r
	if [[ -n "${ORIGARG2}" ]]; then
		printf "Note: %s/%s will be spread over result pages.\n" "${ORIGARG1^^}" "${ORIGARG2^^}"
	fi
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		curl -s --head "https://api.coingecko.com/api/v3/coins/${2,,}/tickers"
		curl -s -X GET "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}" -H  "accept: application/json"
		exit
	fi
	## If there is ARG 2, then make sure you get only those pairs specified
	GREPARG="."
	test -n "${ORIGARG2}" && GREPARG="^${ORIGARG1}/${ORIGARG2}="
	## Grep 4 pages of results instead of only 1
	test -z "${TPAGES}" && TPAGES=4
	printf "........"
	i="${TPAGES}"
	while [[ "${i}" -ge "1" ]]; do
		printf "\rFetching page %s of %s..." "${i}" "${TPAGES}" 1>&2
		TICKERS+="$(curl -s -X GET "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}" -H  "accept: application/json" | jq -r '.tickers[]|"\(.base)/\(.target)=\(.last)=\(.market.identifier)=\(.volume)=\(if .bid_ask_spread_percentage ==  null then "??" else .bid_ask_spread_percentage end)=\(.converted_last.btc)=\(.converted_last.usd)=\(.market.name)=\(.last_traded_at)"')"
		i=$((i-1))
	done
	printf "\n"
	# Format all table and print
	grep -i "${GREPARG}" <<< "${TICKERS}" |	column -s= -et -N"MARKET,PRICE,EX_ID,VOLUME,P_SP(%),PRICE(BTC),PRICE(USD),EX_NAME,LAST_TRADE_TIME" ${COLCONF}
}
if [[ -n ${TOPT} ]]; then
	tickerf ${*}
	exit
fi

# Get CoinGecko JSON & Calc results
if [[ -z "${CGKRATERAW}" ]]; then
	# Make equation and print result
	bc -l <<< "scale=${SCL};(${1}*$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=${2,,}&vs_currencies=${3,,}" -H  "accept: application/json" | jq -r '."'${2,,}'"."'${3,,}'"' | sed 's/e/*10^/g'))/1"
else	
	# From Bank function
	# Make equation and print result
	bc -l <<< "scale=${SCL};(${1}*$(jq -r '."'${2,,}'"."'${3,,}'"' <<< "${CGKRATERAW}" | sed 's/e/*10^/g'))/1"
fi
exit

## CGK APIs
# https://www.coingecko.com/pt/api#explore-api

# Ref: jq read names with dash : https://github.com/stedolan/jq/issues/38
# https://unix.stackexchange.com/questions/406410/jq-print-key-and-value-for-all-in-sub-object
# Unsorted keys https://stedolan.github.io/jq/manual/
# https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4

#printf "Unsupported TO_CURRENCY %s at CGK.\n" "${3^^}" 1>&2
#printf "Try \"-l\" to grep a list of suported currencies.\n" 1>&2
#printf "Or try to use the Bank Currency Function flag \"-b\" (even for crypto).\n" 1>&2
