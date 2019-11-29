#!/bin/bash
#
# Cmc.sh -- Coinmarketcap.com API Access
# v0.5.1  2019/nov/26  by mountaineerbr


## CMC API Personal KEY
#CMCAPIKEY=""


## Some defaults
LC_NUMERIC="en_US.UTF-8"
## Set default scale if no custom scale
SCLDEFAULTS=16

## Manual and help
## Usage: $ cmc.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
	Cmc.sh -- Currency Converter and Market Information
		  Coinmarketcap.com API Access


SYNOPSIS
	cmc.sh [-bp] [-sNUM] [AMOUNT] [FROM_CURRENCY] [TO_CURRENCY]

	cmc.sh [-mt] [NUM] [CURRENCY]

	cmc.sh [-hlv]


DESCRIPTION
	This programme fetches updated currency rates from CoinMarketCap.com
	through a Private API key. It can convert any amount of one supported
	crypto currency into another. CMC also converts crypto to ~93 central 
	bank currencies.

	Only central bank currency conversions are not supported directly, but 
	we can derive bank currency rates undirectly, for e.g. USD vs CNY. As 
	CoinMarketCap updates frequently, it is one of the best APIs for bank 
	currency rates, too.

	The  Bank  Currency  Function \"-b\" can calculate central bank currency
	rates, such  as USD/BRL.

	It  is  _not_  advisable  to depend  solely on CoinMarketCap rates for 
	serious	trading.
	
	You can see a List of supported currencies running the script with the
	argument \"-l\".

	Gold and other metals are priced in Ounces.
		
		\"Gram/Ounce\" rate: 28.349523125


	It is also useful to define a variable OZ in your \".bashrc\" to work 
	with precious metals (see usage examples 10-13).

		OZ=\"28.349523125\"


	Default precision is 16 and can be adjusted with \"-s\". Trailing noughts
	are trimmed by default.


IMPORTANT NOTICE
	Please take a little time to register at <https://coinmarketcap.com/api/>
	for a free API key and add it to the \"CMCAPIKEY\" variable in the script 
	source code or set it as an environment variable.


WARRANTY
	Licensed under the GNU Public License v3 or better.
 	This programme is distributed without support or bug corrections.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES:		
		(1)     One Bitcoin in US Dollar:
			
			$ cmc.sh btc
			
			$ cmc.sh 1 btc usd


		(2)     One Dash in ZCash:
			
			$ cmc.sh dash zec 


		(3)     One Canadian Dollar in Japanese Yen (must use the Bank
			Currency Function):
			
			$ cmc.sh -b cad jpy 


		(4)     One thousand Brazilian Real in U.S.A. Dollars with 4 decimal plates:
			
			$ cmc.sh -b -s4 1000 brl usd 


		(5) 	Market Ticker in JPY

			$ cmc.sh -m jpy


		(6) 	Top 20 crypto currency tickers in EUR; defaults: 10,BTC:

			$ cmc.sh -t 20 eur


		(7)    One Bitcoin in ounces of Gold:
					
			$ cmc.sh 1 btc xau 


		(8)    \e[0;33;40m[Amount]\033[00m of EUR in grams of Gold:
					
			$ cmc.sh -b \"\e[0;33;40m[amount]\033[00m*28.3495\" eur xau 

			    Just multiply amount by the \"gram/ounce\" rate.


		(9)    \e[1;33;40mOne\033[00m EUR in grams of Gold:
					
			$ cmc.sh -b \"\e[1;33;40m1\033[00m*28.3495\" eur xau 


		(10)    \e[0;33;40m[Amount]\033[00m (grams) of Gold in USD:
					
			$ cmc.sh -b \"\e[0;33;40m[amount]\033[00m/28.3495\" xau usd 
			
			    Just divide amount by the \"gram/ounce\" rate.

		
		(11)    \e[1;33;40mOne\033[00m gram of Gold in EUR:
					
			$ cmc.sh -b \"\e[1;33;40m1\033[00m/28.3495\" xau eur 
			

OPTIONS
		-b 	  Bank currency function: from_ and to_currency can be 
			  any central bank or crypto currency supported by CMC.
		
		-h 	  Show this help.

		-j 	  Debugging, print JSON.

		-l 	  List supported currencies.

		-m [TO_CURRENCY]
			  Market ticker.

		-s [NUM]  Set scale (decimal plates).

		-p 	  Print timestamp, if available.
		
		-t [NUM] [TO_CURRENCY]
			  Tickers for top cryptos; number of top currencies 
			  defaults=10, max=100; target rates defaults=USD; 

		-v 	  Show this script version."

OTHERCUR="2781=USD=United States Dollar ($)
3526=ALL=Albanian Lek (L)
3537=DZD=Algerian Dinar (د.ج)
2821=ARS=Argentine Peso ($)
3527=AMD=Armenian Dram (֏)
2782=AUD=Australian Dollar ($)
3528=AZN=Azerbaijani Manat (₼)
3531=BHD=Bahraini Dinar (.د.ب)
3530=BDT=Bangladeshi Taka (৳)
3533=BYN=Belarusian Ruble (Br)
3532=BMD=Bermudan Dollar ($)
2832=BOB=Bolivian Boliviano (Bs.)
3529=BAM=Bosnia-Herzegovina Convertible Mark (KM)
2783=BRL=Brazilian Real (R$)
2814=BGN=Bulgarian Lev (лв)
3549=KHR=Cambodian Riel (៛)
2784=CAD=Canadian Dollar ($)
2786=CLP=Chilean Peso ($)
2787=CNY=Chinese Yuan (¥)
2820=COP=Colombian Peso ($)
3534=CRC=Costa Rican Colón (₡)
2815=HRK=Croatian Kuna (kn)
3535=CUP=Cuban Peso ($)
2788=CZK=Czech Koruna (Kč)
2789=DKK=Danish Krone (kr)
3536=DOP=Dominican Peso ($)
3538=EGP=Egyptian Pound (£)
2790=EUR=Euro (€)
3539=GEL=Georgian Lari (₾)
3540=GHS=Ghanaian Cedi (₵)
3541=GTQ=Guatemalan Quetzal (Q)
3542=HNL=Honduran Lempira (L)
2792=HKD=Hong Kong Dollar ($)
2793=HUF=Hungarian Forint (Ft)
2818=ISK=Icelandic Króna (kr)
2796=INR=Indian Rupee (₹)
2794=IDR=Indonesian Rupiah (Rp)
3544=IRR=Iranian Rial (﷼)
3543=IQD=Iraqi Dinar (ع.د)
2795=ILS=Israeli New Shekel (₪)
3545=JMD=Jamaican Dollar ($)
2797=JPY=Japanese Yen (¥)
3546=JOD=Jordanian Dinar (د.ا)
3551=KZT=Kazakhstani Tenge (₸)
3547=KES=Kenyan Shilling (Sh)
3550=KWD=Kuwaiti Dinar (د.ك)
3548=KGS=Kyrgystani Som (с)
3552=LBP=Lebanese Pound (ل.ل)
3556=MKD=Macedonian Denar (ден)
2800=MYR=Malaysian Ringgit (RM)
2816=MUR=Mauritian Rupee (₨)
2799=MXN=Mexican Peso ($)
3555=MDL=Moldovan Leu (L)
3558=MNT=Mongolian Tugrik (₮)
3554=MAD=Moroccan Dirham (د.م.)
3557=MMK=Myanma Kyat (Ks)
3559=NAD=Namibian Dollar ($)
3561=NPR=Nepalese Rupee (₨)
2811=TWD=New Taiwan Dollar ($)
2802=NZD=New Zealand Dollar ($)
3560=NIO=Nicaraguan Córdoba (C$)
2819=NGN=Nigerian Naira (₦)
2801=NOK=Norwegian Krone (kr)
3562=OMR=Omani Rial (ر.ع.)
2804=PKR=Pakistani Rupee (₨)
3563=PAB=Panamanian Balboa (B/.)
2822=PEN=Peruvian Sol (S/.)
2803=PHP=Philippine Peso (₱)
2805=PLN=Polish Złoty (zł)
2791=GBP=Pound Sterling (£)
3564=QAR=Qatari Rial (ر.ق)
2817=RON=Romanian Leu (lei)
2806=RUB=Russian Ruble (₽)
3566=SAR=Saudi Riyal (ر.س)
3565=RSD=Serbian Dinar (дин.)
2808=SGD=Singapore Dollar ($)
2812=ZAR=South African Rand (Rs)
2798=KRW=South Korean Won (₩)
3567=SSP=South Sudanese Pound (£)
3573=VES=Sovereign Bolivar (Bs.)
3553=LKR=Sri Lankan Rupee (Rs)
2807=SEK=Swedish Krona ( kr)
2785=CHF=Swiss Franc (Fr)
2809=THB=Thai Baht (฿)	=
3569=TTD=Trinidad and Tobago Dollar ($)
3568=TND=Tunisian Dinar (د.ت)
2810=TRY=Turkish Lira (₺)
3570=UGX=Ugandan Shilling (Sh)
2824=UAH=Ukrainian Hryvnia (₴)
2813=AED=United Arab Emirates Dirham (د.إ)
3571=UYU=Uruguayan Peso ($)
3572=UZS=Uzbekistan Som (so'm)
2823=VND=Vietnamese Dong (₫)
3575=XAU=Gold Troy Ounce
3574=XAG=Silver Troy Ounce
3577=XPT=Platinum Ounce
3576=XPD=Palladium Ounce"

TOCURLIST=( USD ALL DZD ARS AMD AUD AZN BHD BDT BYN BMD BOB BAM BRL BGN KHR CAD CLP CNY COP CRC HRK CUP CZK DKK DOP EGP EUR GEL GHS GTQ HNL HKD HUF ISK INR IDR IRR IQD ILS JMD JPY JOD KZT KES KWD KGS LBP MKD MYR MUR MXN MDL MNT MAD MMK NAD NPR TWD NZD NIO NGN NOK OMR PKR PAB PEN PHP PLN GBP QAR RON RUB SAR RSD SGD ZAR KRW SSP VES LKR SEK CHF THB TTD TND TRY UGX UAH AED UYU UZS VND XAU XAG XPT XPD ) 

## Bank currency rate function
bankf() {
	unset BANK
	if [[ -n "${PJSON}" ]] && [[ -n "${BANK}" ]]; then
		# Print JSON?
		printf "No specific JSON for the bank currency function.\n"
		exit 1
	fi
	# Rerun script, get rates and process data	
	(
	BTCBANK="$("${0}" -p BTC "${2^^}")"
	BTCBANKHEAD=$(head -n1 <<< "${BTCBANK}") # Timestamp
	BTCBANKTAIL=$(tail -n1 <<< "${BTCBANK}") # Rate
	BTCTOCUR="$("${0}" -p BTC "${3^^}")"
	BTCTOCURHEAD=$(head -n1 <<< "${BTCTOCUR}") # Timestamp
	BTCTOCURTAIL=$(tail -n1 <<< "${BTCTOCUR}") # Rate
	if [[ -n "${TIMEST}" ]]; then
		printf "%s (from currency)\n" "${BTCBANKHEAD}"
		printf "%s ( to  currency)\n" "${BTCTOCURHEAD}"
	fi
	# Calculate result & print result 
	RESULT="$(bc -l <<< "(${1}*${BTCTOCURTAIL})/${BTCBANKTAIL}")"
	printf "%.${SCL}f\n" "${RESULT}"
	# Check for errors
	if ! grep -q "[1-9]" <<< "${RESULT}"; then
		printf "Check currency codes for typos.\n" 1>&2
		exit 1
	fi
	) 2>/dev/null
}

## Market Capital Function
mcapf() {
	# Check inupt to_currency
	if [[ -n "${1}" ]]; then
		SYMBOLLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -G "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map" | jq '[.data[]| {"key": .slug, "value": .symbol},{"key": (.name|ascii_upcase), "value": .symbol}] | from_entries')"
		if  ! grep -qi "${1}" <<< "${TOCURLIST[@]}" && ! jq -r ".[]" <<< "${SYMBOLLIST}" | grep -iq "^${1}$"; then
			if jq -er '.["'"${1^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
				set -- "$(jq -r '.["'"${1^^}"'"]' <<< "${SYMBOLLIST}")"
			else
				printf "Check TO_CURRENCY code.\n" 1>&2
				exit 1
			fi
		fi
	else
		set -- USD
	fi
	# Get market data
	CMCGLOBAL=$(curl -s -H "X-CMC_PRO_API_KEY:  ${CMCAPIKEY}" -H "Accept: application/json" -d "convert=${1^^}" -G "https://pro-api.coinmarketcap.com/v1/global-metrics/quotes/latest")
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${CMCGLOBAL}"
		exit 0
	fi
	LASTUP=$(jq -r '.data.last_updated' <<< "${CMCGLOBAL}")
	# Avoid erros being printed
	{
	printf "## CRYPTO MARKET INFORMATION\n"
	date --date "${LASTUP}"  "+#  %FT%T%Z"
	printf "\n# Exchanges     : %s\n" "$(jq -r '.data.active_exchanges' <<< "${CMCGLOBAL}")"
	printf "# Active cryptos: %s\n" "$(jq -r '.data.active_cryptocurrencies' <<< "${CMCGLOBAL}")"
	printf "# Market pairs  : %s\n" "$(jq -r '.data.active_market_pairs' <<< "${CMCGLOBAL}")"

	printf "\n## All Crypto Market Cap\n"
	printf "   %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.total_market_cap" <<< "${CMCGLOBAL}")" "${1^^}"
	printf " # Last 24h Volume\n"
	printf "    %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.total_volume_24h" <<< "${CMCGLOBAL}")" "${1^^}"
	printf " # Last 24h Reported Volume\n"
	printf "    %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.total_volume_24h_reported" <<< "${CMCGLOBAL}")" "${1^^}"
	
	printf "\n## Bitcoin Market Cap\n"
	printf "   %'.2f %s\n" "$(jq -r "(.data.quote.${1^^}.total_market_cap-.data.quote.${1^^}.altcoin_market_cap)" <<< "${CMCGLOBAL}")" "${1^^}"
	printf " # Last 24h Volume\n"
	printf "    %'.2f %s\n" "$(jq -r "(.data.quote.${1^^}.total_volume_24h-.data.quote.${1^^}.altcoin_volume_24h)" <<< "${CMCGLOBAL}")" "${1^^}"
	printf " # Last 24h Reported Volume\n"
	printf "    %'.2f %s\n" "$(jq -r "(.data.quote.${1^^}.total_volume_24h_reported-.data.quote.${1^^}.altcoin_volume_24h_reported)" <<< "${CMCGLOBAL}")" "${1^^}"
	printf "## Circulating Supply\n"
	printf " # BTC: %'.2f bitcoins\n" "$(bc -l <<< "$(curl -s "https://blockchain.info/q/totalbc")/100000000")"

	printf "\n## AltCoin Market Cap\n"
	printf "   %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.altcoin_market_cap" <<< "${CMCGLOBAL}")" "${1^^}"
	printf " # Last 24h Volume\n"
	printf "    %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.altcoin_volume_24h" <<< "${CMCGLOBAL}")" "${1^^}"
	printf " # Last 24h Reported Volume\n"
	printf "    %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.altcoin_volume_24h_reported" <<< "${CMCGLOBAL}") "${1^^}""
	
	printf "\n## Dominance\n"
	printf " # BTC: %'.2f %%\n" "$(jq -r '.data.btc_dominance' <<< "${CMCGLOBAL}")"
	printf " # ETH: %'.2f %%\n" "$(jq -r '.data.eth_dominance' <<< "${CMCGLOBAL}")"

	printf "\n## Market Cap per Coin\n"
	printf " # Bitcoin : %'.2f %s\n" "$(jq -r "((.data.btc_dominance/100)*.data.quote.${1^^}.total_market_cap)" <<< "${CMCGLOBAL}")" "${1^^}"
	printf " # Ethereum: %'.2f %s\n" "$(jq -r "((.data.eth_dominance/100)*.data.quote.${1^^}.total_market_cap)" <<< "${CMCGLOBAL}")" "${1^^}"
	# Avoid erros being printed
	} 2>/dev/null
}

## -t Top Tickers Function
tickerf() {
	# Check inupt to_currency
	if [[ -n "${2}" ]]; then
		SYMBOLLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -G "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map" | jq '[.data[]| {"key": .slug, "value": .symbol},{"key": (.name|ascii_upcase), "value": .symbol}] | from_entries')"
		if  ! grep -qi "${2}" <<< "${TOCURLIST[@]}" && ! jq -r ".[]" <<< "${SYMBOLLIST}" | grep -iq "^${2}$"; then
			if jq -er '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
				set -- "$(jq -r '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}")"
			else
				printf "Check TO_CURRENCY code.\n" 1>&2
				exit 1
			fi
		fi
	else
		set -- "${1}" USD
	fi
	# How many top cryptos should be printed? Defaults=10
	# If number of tickers is in ARG2
	if [[ "${1}" -le 1 ]]; then
		set -- 10 "${2}"
	fi
	# Prepare retrive query to server
	# Get JSON
	TICKERJSON="$(curl -s "https://api.coinmarketcap.com/v1/ticker/?limit=${1}&convert=${2^^}")"
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${TICKERJSON}"
		exit 0
	fi
	# Test screen width
	# If stdout is redirected; skip this
	if ! [[ -t 1 ]]; then
		true
	elif test "$(tput cols)" -lt "100"; then
		COLCONF="-HMCAP(${2^^}),SUPPLY/TOTAL,UPDATE -TPRICE(${2^^}),VOL(24H;${2^^})"
		printf "OBS: More columns are needed to print more info.\n" 1>&2
	elif test "$(tput cols)" -lt "120"; then
		COLCONF="-HSUPPLY/TOTAL,UPDATE"
		printf "OBS: More columns are needed to print more info.\n" 1>&2
	else
		COLCONF="-TSUPPLY/TOTAL,UPDATE"
	fi
	jq -r '.[]|"\(.rank)=\(.id)=\(.symbol)=\(.price_'"${2,,}"')=\(.percent_change_1h)%=\(.percent_change_24h)%=\(.percent_change_7d)%=\(."24h_volume_'"${2,,}"'")=\(.market_cap_'"${2,,}"')=\(.available_supply)/\(.total_supply)=\(.last_updated|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' <<< "${TICKERJSON}" |
		column -s"=" -t  -N"RANK,ID,SYMBOL,PRICE(${2^^}),D1h,D24h,D7D,VOL(24H;${2^^}),MCAP(${2^^}),SUPPLY/TOTAL,UPDATE" ${COLCONF}
}

## -l Print currency lists
listsf() {
	printf "\n=============CRYPTOCURRENCIES============\n"
	curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/map | jq -r '.data[] | "\(.id)=\(.symbol)=\(.name)"' | column -s'=' -et -N 'ID,SYMBOL,NAME'
	printf "\n\n===========BANK CURRENCIES===========\n"
	printf "%s\n" "${OTHERCUR}" | column -s'=' -et -N'ID,SYMBOL,NAME'
}

# Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit 1
fi

# Parse options
while getopts ":blmhjs:tp" opt; do
	case ${opt} in
		b ) ## Hack central bank currency rates
			BANK=1
			;;
		j ) # Debug: Print JSON
			PJSON=1
			;;
		l ) ## List available currencies
			LISTS=1
			;;
		m ) # Market Capital Function
			MCAP=1
			;;
		h ) # Show Help
			echo -e "${HELP_LINES}"
			exit 0
			;;
		p ) # Print Timestamp with result
			TIMEST=1
			;;
		s ) # Decimal plates
			SCL="${OPTARG}"
			;;
		t ) ## Tickers for crypto currencies
			TICKEROPT=1
			;;
		\? )
			echo "Invalid Option: -$OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

#Check for API KEY
if [[ -z "${CMCAPIKEY}" ]]; then
	printf "Please create a free API key and add it to the script source-code or set it as an environment variable.\n" 1>&2
	exit 1
fi

# Test for must have packages
if [[ -z "${CCHECK}" ]]; then
	if ! command -v jq &>/dev/null; then
		printf "JQ is required.\n" 1>&2
		exit 1
	fi
	if ! command -v curl &>/dev/null; then
		printf "cURL is required.\n" 1>&2
		exit 1
	fi
	CCHECK=1
	export CCHECK
fi

# Call opt functions
if [[ -n "${MCAP}" ]]; then
	mcapf "${@}"
	exit
elif [[ -n "${TICKEROPT}" ]]; then
	tickerf "${@}"
	exit
fi

## Set custom scale
if [[ -z ${SCL} ]]; then
	SCL="${SCLDEFAULTS}"
fi

# Set equation arguments
# If first argument does not have numbers
if ! [[ "${1}" =~ [0-9] ]]; then
	set -- 1 "${@}"
# if AMOUNT is not a valid expression for Bc
elif [[ -z "$(bc -l <<< "${1}" 2>/dev/null)" ]]; then
	printf "Invalid expression in \"AMOUNT\"." 1>&2
	exit 1
fi
if [[ -z ${2} ]]; then
	set -- "${1}" btc
fi
if [[ -z ${3} ]]; then
	set -- "${1}" "${2}" usd
fi

## Check currencies
if [[ -z "${SYMBOLLIST}" ]]; then
	SYMBOLLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -G "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map" | jq '[.data[]| {"key": .slug, "value": .symbol},{"key": (.name|ascii_upcase), "value": .symbol}] | from_entries')"
	export SYMBOLLIST
fi
if [[ -z "${BANK}" ]]; then
	## Check FROM_CURRENCY
	if ! jq -er ".[]" <<< "${SYMBOLLIST}" | grep -iq "^${2}$"; then
		if jq -er '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
			set -- "${1}" "$(jq -r '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}")" "${3}"
		else
			printf "ERR: FROM_CURRENCY -- %s\nCheck symbol or \"-h\" for help.\n" "${2^^}" 1>&2
			exit 1
		fi
	fi
	## Check TO_CURRENCY
	if  ! grep -qi "${3}" <<< "${TOCURLIST[@]}" && ! jq -r ".[]" <<< "${SYMBOLLIST}" | grep -iq "^${3}$"; then
		if jq -er '.["'"${3^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
			set -- "${1}" "${2}" "$(jq -r '.["'"${3^^}"'"]' <<< "${SYMBOLLIST}")"
		else
			printf "ERR: TO_CURRENCY -- %s\nCheck symbol or \"-h\" for help.\n" "${3^^}" 1>&2
			exit 1
		fi
	fi
fi

## Call opt functions
if [[ -n "${BANK}" ]]; then
	bankf "${@}"
	exit
elif [[ -n "${LISTS}" ]]; then
	listsf
	exit
fi

## Currency converter -- Default function
## Get Rate JSON
CMCJSON=$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -d "&symbol=${2^^}&convert=${3^^}" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest)
# Print JSON?
if [[ -n ${PJSON} ]]; then
	printf "%s\n" "${CMCJSON}"
	exit 0
fi

## Get pair rate
CMCRATE=$(jq -r ".data[] | .quote.${3^^}.price" <<< "${CMCJSON}" | sed 's/e/*10^/g') 

## Print JSON timestamp ?
if [[ -n ${TIMEST} ]]; then
JSONTIME=$(jq -r ".data.${2^^}.quote.${3^^}.last_updated" <<< "${CMCJSON}")
	date --date "$JSONTIME" "+## %FT%T%Z"
fi

## Make equation and calculate result
RESULT="$(bc -l <<< "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; trunc(${1}*${CMCRATE})")"
printf "%.${SCL}f\n" "${RESULT}"

exit

