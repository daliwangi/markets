#!/bin/bash
#
# Cgk.sh -- Coingecko.com API Access
# v0.6.6  2019/oct/05  by mountaineerbr

# Some defaults
LC_NUMERIC="en_US.utf8"

## Manual and help
HELP_LINES="NAME
	\e[1;33;40m
	Cgk.sh -- Currency Converter and Market Stats\033[00m
		\e[1;33;40m  Coingecko.com API Access\033[00m

SYNOPSIS
	cgk.sh [option] [amount] [from_currency] [vs_currency]

	cgk.sh [-b|-j|-s] [optional:amount] [from_id|from_symbol] [vs_id|vs_symbol]
	
	cgk.sh [-p|-t] [id|symbol] [optional:vs_id|vs_symbol]

	cgk.sh [-e|-h|-j|-l|-m|-v]


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

	Some currency convertion data is available for use with the Market Cap 
	Function \"-m\". You can choose which currency to display data, when 
	available, from the table below:

	aed     bmd     clp     eur     inr     mmk     pkr     thb     vnd
	ars     bnb     cny     gbp     jpy     mxn     pln     try     xag
	aud     brl     czk     hkd     krw     myr     rub     twd     xau
	bch     btc     dkk     huf     kwd     nok     sar     uah     xdr
	bdt     cad     eos     idr     lkr     nzd     sek     usd     xlm
	bhd     chf     eth     ils     ltc     php     sgd     vef     xrp
									zar

	Otherwise, the market capitulation table will display data in various
	currencies by defaults.


WARRANTY
	Licensed under the GNU Public License v3 or better.
 	This programme is distributed without support or bug corrections.

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
			converting any central bank or crypto currency to any other.

		-e 	Exchange list; allow at least 100 columns for the table.
			If over 150 are available, URLs will be printed as well.
			For information on trading incentives (column \"INC?\")
			and normalized volume, check:
			<https://blog.coingecko.com/trust-score/>.

		-h 	Show this help.

		-j 	Fetch JSON file and send to STOUT.

		-l 	List supported currencies.

		-m 	Market Capitulation table; accepts one currency as arg;
			defaults=usd.

		-p 	Number of pages retrieved from the server; each page may
			contain 100 results; use with option \"-t\"; defaults=4.
	 	
		-s 	Scale setting (decimal plates).
		
		-t 	Tickers from all suported exchanges of a single crypto-
			currency and all its pairs or only of a specific crypto-
			currency pair; change number of pages fetched with opt-
			ion \"-p\".
		
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
rm1f() { rm -f "${CGKTEMPLIST}" "${CGKTEMPLIST2}"; }
rm2f() { rm -f "${CGKTEMPLIST3}"; }
rm3f() { rm -f "${CGKTEMP}"; }
tmperrf() { printf "Cannot create TMP file.\n" 1>&2; exit 1;}

## Some recurring functions
# List of from_currencies
# Only if there is no path created already
clistf() {
	# Ceck if there is a list or create one
	if [[ -z "${CGKTEMPLIST2}" ]]; then
		# Make Temp files
		CGKTEMPLIST=$(mktemp /tmp/cgk.list.XXXXX) || tmperrf
		CGKTEMPLIST2=$(mktemp /tmp/cgk.list2.XXXXX) || tmperrf
		export CGKTEMPLIST
		export CGKTEMPLIST2
		## Trap temp cleaning functions
		trap "rm1f; exit 130" EXIT SIGINT
		# Retrieve list from CGK
		curl -s -X GET "https://api.coingecko.com/api/v3/coins/list" -H  "accept: application/json" >> "${CGKTEMPLIST}"
		jq -r '[.[] | { key: .symbol, value: .id } ] | from_entries' <"${CGKTEMPLIST}" >> "${CGKTEMPLIST2}"
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
	printf "%s\n" "${VSCLISTS}" | jq -r '.[]' | tr "[:lower:]" "[:upper:]" | sort | column -c 80
	printf "\n"
}
if [[ -n "${LISTS}" ]]; then
	listsf
	exit
fi

## -m Market Cap function		
mcapf() {
	# Check if input has a defined to_currency
	if [[ -z "${1}" ]]; then
		NOARG=1
		set -- usd
	fi
	# Get Data 
	CGKGLOBAL=$(curl -sX GET "https://api.coingecko.com/api/v3/global" -H  "accept: application/json")
	# Check if input is a valid to_currency for this function
	if ! jq -r '.data.total_market_cap|keys[]' <<< "${CGKGLOBAL}" | grep -qi "${1}"; then
		printf "Using USD. Not supported -- %s.\n" "${1^^}" 1>&2
		NOARG=1
		set -- usd
	fi
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${CGKGLOBAL}" 
		exit
	fi
	CGKTIME=$(jq -r '.data.updated_at' <<< "${CGKGLOBAL}")
	printf "## CRYPTO MARKET STATS\n"
	date -d@"$CGKTIME" "+#  %FT%T%Z%n"
	printf "## Markets : %s\n" "$(jq -r '.data.markets' <<< "${CGKGLOBAL}")"
	printf "## Cryptos : %s\n" "$(jq -r '.data.active_cryptocurrencies' <<< "${CGKGLOBAL}")"

	printf "## ICOs Stats\n"
	printf " # Upcoming: %s\n" "$(jq -r '.data.upcoming_icos' <<< "${CGKGLOBAL}")"
	printf " # Ongoing : %s\n" "$(jq -r '.data.ongoing_icos' <<< "${CGKGLOBAL}")"
	printf " # Ended   : %s\n" "$(jq -r '.data.ended_icos' <<< "${CGKGLOBAL}")"

	printf "\n## Dominance\n"
	jq -r '.data.market_cap_percentage | keys_unsorted[] as $k | "\($k) = \(.[$k])"' <<< "${CGKGLOBAL}" | column -s '=' -t -o "=" | awk -F"=" '{ printf "  # %s  : ", toupper($1); printf("%7.4f %%\n", $2); }'
	printf "\n"
	
	printf "## Market Cap per Coin\n"
	DOMINANCEARRAY=($(curl -sX GET "https://api.coingecko.com/api/v3/global" -H  "accept: application/json" | jq -r '.data.market_cap_percentage | keys_unsorted[]'))
	for i in "${DOMINANCEARRAY[@]}"; do
		printf "  # %s    : %'22.2f %s\n" "${i^^}" "$(jq -r "((.data.market_cap_percentage.${i}/100)*.data.total_market_cap.${1,,})" <<< "${CGKGLOBAL}")" "${1^^}" 2>/dev/null
	done

	printf "\n## Amount Created (approx.)\n"
	printf "  # BTC    : %'14.2f bitcoins\n" "$(jq -r "((.data.market_cap_percentage.btc/100)*.data.total_market_cap.btc)" <<< "${CGKGLOBAL}")" 2>/dev/null
	printf "  # ETH    : %'14.2f ethers\n" "$(jq -r "((.data.market_cap_percentage.eth/100)*.data.total_market_cap.eth)" <<< "${CGKGLOBAL}")" 2>/dev/null

	printf "\n## Total Market Cap\n"
	printf " # Equivalent in\n"
	printf "    %s    : %'22.2f\n" "${1^^}" "$(jq -r ".data.total_market_cap.${1,,}" <<< "${CGKGLOBAL}")"
	if [[ -n "${NOARG}" ]]; then
	printf "    EUR    : %'22.2f\n" "$(jq -r '.data.total_market_cap.eur' <<< "${CGKGLOBAL}")"
	printf "    GBP    : %'22.2f\n" "$(jq -r '.data.total_market_cap.gbp' <<< "${CGKGLOBAL}")"
	printf "    JPY    : %'22.2f\n" "$(jq -r '.data.total_market_cap.jpy' <<< "${CGKGLOBAL}")"
	printf "    CNY    : %'22.2f\n" "$(jq -r '.data.total_market_cap.cny' <<< "${CGKGLOBAL}")"
	printf "    BRL    : %'22.2f\n" "$(jq -r '.data.total_market_cap.brl' <<< "${CGKGLOBAL}")"
	printf "    XAU(oz): %'22.2f\n" "$(jq -r '.data.total_market_cap.xau' <<< "${CGKGLOBAL}")"
	printf "    BTC    : %'22.2f\n" "$(jq -r '.data.total_market_cap.btc' <<< "${CGKGLOBAL}")"
	printf "    ETH    : %'22.2f\n" "$(jq -r '.data.total_market_cap.eth' <<< "${CGKGLOBAL}")"
	printf "    XRP    : %'22.2f\n" "$(jq -r '.data.total_market_cap.xrp' <<< "${CGKGLOBAL}")"
	fi
	printf " # Change(%%USD/24h): %.4f %%\n" "$(jq -r '.data.market_cap_change_percentage_24h_usd' <<< "${CGKGLOBAL}")"

	printf "\n## Market Volume (last 24h)\n"
	printf " # Equivalent in\n"
	printf "    %s    : %'22.2f\n" "${1^^}" "$(jq -r ".data.total_volume.${1,,}" <<< "${CGKGLOBAL}")"
	if [[ -n "${NOARG}" ]]; then
	printf "    EUR    : %'22.2f\n" "$(jq -r '.data.total_volume.eur' <<< "${CGKGLOBAL}")"
	printf "    GBP    : %'22.2f\n" "$(jq -r '.data.total_volume.gbp' <<< "${CGKGLOBAL}")"
	printf "    JPY    : %'22.2f\n" "$(jq -r '.data.total_volume.jpy' <<< "${CGKGLOBAL}")"
	printf "    CNY    : %'22.2f\n" "$(jq -r '.data.total_volume.cny' <<< "${CGKGLOBAL}")"
	printf "    BRL    : %'22.2f\n" "$(jq -r '.data.total_volume.brl' <<< "${CGKGLOBAL}")"
	printf "    XAU(oz): %'22.2f\n" "$(jq -r '.data.total_volume.xau' <<< "${CGKGLOBAL}")"
	printf "    BTC    : %'22.2f\n" "$(jq -r '.data.total_volume.btc' <<< "${CGKGLOBAL}")"
	printf "    ETH    : %'22.2f\n" "$(jq -r '.data.total_volume.eth' <<< "${CGKGLOBAL}")"
	printf "    XRP    : %'22.2f\n" "$(jq -r '.data.total_volume.xrp' <<< "${CGKGLOBAL}")"
	fi

	exit 0
}
test -n "${MCAP}" && mcapf ${*}

## -e Show Exchange info function
exf() {
	EXRAW="$(curl -sX GET "https://api.coingecko.com/api/v3/exchanges" -H  "accept: application/json")"
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${EXRAW}" 
		exit
	fi
	protablef() {
		jq -r '.[] | "\(.name)=\(if .year_established == null then "??" else .year_established end)=\(if .country != null then .country else "??" end)=\(if .trade_volume_24h_btc == .trade_volume_24h_btc_normalized then "\(.trade_volume_24h_btc)=[same]" else "\(.trade_volume_24h_btc)=[\(.trade_volume_24h_btc_normalized)]" end)=\(if .has_trading_incentive == true then "YES" else "NO" end)=\(.id)=\(.url)"'
	}
	printf "\nTable of Exchanges\n\n"
	printf "\nExchanges in this list: %s\n\n" "$(printf "%s\n" "${EXRAW}"| jq -r '.[].id' | wc -l)"
	# Check terminal column number
	test "$(tput cols)" -lt "150" && HCOL=",URL"

	# Make table
	# Check if CoinEgg still has a weird "en_US" in its name that havocks table
	printf "%s\n" "${EXRAW}" | protablef | sort | column -ts'=' -eN"NAME,YEAR,COUNTRY,BTC_VOLUME(24H),[NORMALIZED_BTC_VOL],INC?,ID,URL,NONE" -W'NAME,COUNTRY' -H"NONE${HCOL}" 
	exit
}
test -n "${EXOPT}" && exf "${*}"

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
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "No specific JSON for Bank Currency Function.\n" >&2 
		exit 1
	fi

	# Call CGK.com less
	# Get currency lists (they will be exported by the function)
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
	elif ! BTCBANK="$(${0} "${2,,}" btc 2>/dev/null)"; then
		BTCBANK="(1/$(${0} bitcoin "${2,,}" 2>/dev/null))" ||
			{ echo "Function error; check currencies."; exit 1;}
	fi
	# Get rates to to_currency anyways
	if [[ "${3,,}" = "btc" ]]; then
		BTCTOCUR=1
	elif ! BTCTOCUR="$(${0} "${3,,}" btc 2>/dev/null)"; then
		BTCTOCUR="(1/$(${0} bitcoin "${3,,}" 2>/dev/null))" ||
			{ echo "Function error; check currencies."; exit 1;}
	fi
	# Timestamp? No timestamp for this API
	# Calculate result
	RESULT="$(bc -l <<< "(${1}*${BTCBANK})/${BTCTOCUR}")"
	printf "%.${SCL}f\n" "${RESULT}"
	exit
}
if [[ -n "${BANK}" ]]; then
	bankf ${*}
	exit
fi

## Check you are not requesting some unsupported FROM_CURRENCY
# Make sure "XAG Silver" does not get translated to "XAG Xrpalike Gene"
test "${2,,}" = "xag" &&
	printf "Did you mean xrpalike-gene?\n" &&
	exit 1
clistf
if ! jq -r .[][] <"${CGKTEMPLIST}" | grep -qi "^${2}$"; then
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
	# Start print Heading
	printf "\nTickers\n" 1>&2 
	printf "Results for %s\n" "${ORIGARG1^^}" 1>&2
	curl -s --head "https://api.coingecko.com/api/v3/coins/${2,,}/tickers" |
		grep -ie "total:" -e "per-page:" | sort -r 1>&2
	printf "\n" 1>&2 
	# Create Temp file if not available already
	if [[ -z ${CGKTEMP} ]]; then
		CGKTEMP=$(mktemp /tmp/cgk.ticker.XXXXX) || tmperrf
		export CGKTEMP
		## Trap temp cleaning functions
		trap "rm1f; rm2f; rm3f; exit 130" EXIT SIGINT
	fi
	## Grep 4 pages of results instead of only 1
	i=1
	test -z "${TPAGES}" && TPAGES=4
	while [ $i -le "${TPAGES}" ]; do
		printf "Fetching page %s of %s...\n" "${i}" "${TPAGES}" 1>&2
		curl -s -X GET "https://api.coingecko.com/api/v3/coins/${2,,}/tickers?page=${i}" -H  "accept: application/json" >> "${CGKTEMP}"
		echo "" >> "${CGKTEMP}"
		i=$((i+1))
	done
	printf "\n"
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		cat "${CGKTEMP}" 
		exit
	fi
	## If there is ARG 2, then make sure you get only those pairs specified
	unset GREPARG
	test -n "${ORIGARG2}" && GREPARG="^${ORIGARG1}/${ORIGARG2}=" 
	TABLE="$(jq -er '.tickers[]|"\(.base)/\(.target)= \(.market.name)= \(.last)= \(.volume)= \(.bid_ask_spread_percentage)= \(.converted_last.btc)= \(.converted_last.usd)= \(.last_traded_at)"' <"${CGKTEMP}" |
		grep -i "${GREPARG}" | sort |
		column -s= -et -N"PAIR,MARKET,LAST_PRICE,VOLUME,SPREAD(%),PRICE(BTC),PRICE(USD),LAST_TRADE_TIME")"
	# Check for any matches retrieved
	if [[ -z "${TABLE}" ]]; then
		printf "No match for %s %s.\n" "${ORIGARG1^^}" "${ORIGARG2^^}" 1>&2
		exit 1
	else
		printf "\nRetrieved matches for %s %s: %s\n\n" "${ORIGARG1^^}" "${ORIGARG2^^}" "$(ttablef | wc -l)"
		exit 0
	fi
}
if [[ -n ${TOPT} ]]; then
	tickerf ${*}
	exit
fi

# Get CoinGecko JSON
if [[ -z "${CGKRATERAW}" ]]; then
	CGKRATERAW=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=${2,,}&vs_currencies=${3,,}" -H  "accept: application/json")
fi

CGKRATE=$(jq -r '."'${2,,}'"."'${3,,}'"' <<< "${CGKRATERAW}" | sed 's/e/*10^/g')
# Print JSON?
if [[ -n ${PJSON} ]]; then
	printf "%s\n" "${CGKRATERAW}" 
	exit
fi

# Make equation and print result
RESULT="$(bc -l <<< "${1}*${CGKRATE}")"
printf "%.${SCL}f\n" "${RESULT}"

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
