#!/bin/bash
#
# Cmc.sh -- Coinmarketcap.com API Access
# v0.6.18  2019/dec  by mountaineerbr


## CMC API Personal KEY
#CMCAPIKEY=""


## Some defaults
LC_NUMERIC="en_US.UTF-8"
## Set default scale if no custom scale
SCLDEFAULTS=16
## Oz to gram ratio
OZ='28.349523125'

## Manual and help
## Usage: $ cmc.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
	Cmc.sh -- Currency Converter and Market Information
		  Coinmarketcap.com API Access


SYNOPSIS
	cmc.sh [-ahlv]

	cmc.sh [-bgp] [-sNUM|-NUM] [AMOUNT] [FROM_CURRENCY] [TO_CURRENCY]

	cmc.sh [-m] [TO_CURRENCY]

	cmc.sh [-t] [NUM] [CURRENCY]
	

DESCRIPTION
	This programme fetches updated currency rates from CoinMarketCap.com
	through a Private API key. It can convert any amount of one supported
	crypto currency into another. CMC also converts crypto to ~93 central 
	bank currencies.

	You can see a List of supported currencies running the script with the
	argument \"-l\".

	Only central bank currency conversions are not supported directly, but 
	we can derive bank currency rates undirectly, for e.g. USD vs CNY.The 
	Bank Currency option \"-b\" can also calculate bank currencies vs. pre-
	cious metals.

	Gold and other metals are priced in Ounces. It means that in each ounce
	there are aproximately 28.35 grams, such as represented by the following
	constant:
		
		\"GRAM/OUNCE\" rate = 28.349523125


	Option \"-g\" will try to calculate rates in grams instead of ounces for
	precious metals. 

	Nonetheless, it is useful to learn how to do this convertion manually.
	It is useful to define a variable OZ in your \".bashrc\" to work with 
	precious metals (see usage example 10). I suggest a variable called OZ 
	that will contain the GRAM/OZ constant.

		OZ=\"28.349523125\"


	Default precision is 16 and can be adjusted with \"-s\".


IMPORTANT NOTICE
	Please take a little time to register at <https://coinmarketcap.com/api/>
	for a free API key and add it to the \"CMCAPIKEY\" variable in the script 
	source code or set it as an environment variable.


WARRANTY
	Licensed under the GNU Public License v3 or better. It is distributed 
	without support or bug corrections. This programme needs Bash, cURL, JQ
	and Coreutils to work properly.

	It  is  _not_  advisable  to depend  solely on CoinMarketCap rates for 
	serious	trading.
	
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


		(8)    Using grams for precious metals instead of ounces.

			To use grams instead of ounces for calculation precious 
			metals rates, use option \"-g\". The following section
			explains about the GRAM/OZ constant used in this program.

			The rate of conversion (constant) of grams by ounce may 
			be represented as below:
			 
				GRAM/OUNCE = \"28.349523125/1\"
			

			
			To get \e[0;33;40mAMOUNT\033[00m of EUR in grams of Gold,
			just multiply AMOUNT by the \"GRAM/OUNCE\" constant.

				$ cmc.sh -b \"\e[0;33;40mAMOUNT\033[00m*28.3495\" eur xau 


				One EUR in grams of Gold:

				$ cmc.sh -b \"\e[1;33;40m1\033[00m*28.3495\" eur xau 



			To get \e[0;33;40mAMOUNT\033[00m of grams of Gold in EUR,
			just divide AMOUNT by the \"GRAM/OUNCE\" costant.

				$ cmc.sh -b \"\e[0;33;40m[amount]\033[00m/28.3495\" xau usd 
			

				One gram of Gold in EUR:
					
				$ cmc.sh -b \"\e[1;33;40m1\033[00m/28.3495\" xau eur 


			To convert (a) from gold to crypto currencies, (b) from 
			bank currencies to gold or (c) from gold to bank curren-
			cies, do not forget to use the option \"-b\"!


OPTIONS
		-NUM 	Shortcut for scale setting, same as \"-sNUM\".

		-a 	  API key status.

		-b 	  Bank currency function: from_ and to_currency can be 
			  any central bank or crypto currency supported by CMC.

		-g 	  Use grams instead of ounces; only for precious metals.
		
		-h 	  Show this help.

		-j 	  Debugging, print JSON.

		-l 	  List supported currencies.

		-m [TO_CURRENCY]
			  Market ticker.

		-s [NUM]  Set scale (decimal plates); defaults=${SCLDEFAULTS}.

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

## -b Bank currency rate function
bankf() {
	unset BANK
	if [[ -n "${PJSON}" ]] && [[ -n "${BANK}" ]]; then
		# Print JSON?
		printf "No specific JSON for the bank currency function.\n"
		exit 1
	fi
	# Rerun script, get rates and process data	
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
	# Precious metals in grams?
	ozgramf "${2}" "${3}"
	RESULT="$(bc -l <<< "((${1}*${BTCTOCURTAIL})/${BTCBANKTAIL})${GRAM}${OZ}")"
	# Check for errors
	if [[ -z "${RESULT}" ]]; then
		printf "Error: check currency codes.\n" 1>&2
		exit 1
	fi
	printf "%.${SCL}f\n" "${RESULT}"
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
	# How many top cryptos should be printed? Defaults=10
	# If number of tickers is in ARG2
	if [[ ! ${1} =~ ^[0-9]+$ ]]; then
		if [[ -n "${SCL}" ]]; then
			set -- "${SCL}" ${@}
		else
			set -- 10 ${@}
		fi
	fi
	if [[ -z "${2}" ]]; then
		set -- "${1}" USD
	fi

	# Check input to_currency
	if [[ "${2^^}" != USD ]]; then
		SYMBOLLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -G "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map" | jq '[.data[]| {"key": .slug, "value": .symbol},{"key": (.name|ascii_upcase), "value": .symbol}] | from_entries')"
		if  ! grep -qi "${2}" <<< "${TOCURLIST[@]}" && ! jq -r ".[]" <<< "${SYMBOLLIST}" | grep -iq "^${2}$"; then
			if jq -er '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
				set -- "$(jq -r '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}")"
			else
				printf "Check TO_CURRENCY code.\n" 1>&2
				exit 1
			fi
		fi
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
		COLCONF="-HMCAP(${2^^}),SUPPLY/TOTAL,UPDATE -TPRICE(${2^^}),VOL24h(${2^^})"
		printf "OBS: More columns are needed to print more info.\n" 1>&2
	elif test "$(tput cols)" -lt "120"; then
		COLCONF="-HSUPPLY/TOTAL,UPDATE"
		printf "OBS: More columns are needed to print more info.\n" 1>&2
	else
		COLCONF="-TSUPPLY/TOTAL,UPDATE"
	fi
	# Bitcoin table is special from others
	if [[ "${2^^}" = BTC ]]; then

		BTC1H="$(jq -r '.[]|select(.id == "bitcoin")|.percent_change_1h'  <<< "${TICKERJSON}")"
		BTC24H="$(jq -r '.[]|select(.id == "bitcoin")|.percent_change_24h'  <<< "${TICKERJSON}")"
		BTC7D="$(jq -r '.[]|select(.id == "bitcoin")|.percent_change_7d'  <<< "${TICKERJSON}")"
		#XXXXXXXXXXXXXXXXXXXXXXXX
		jq -r '.[]|"\(.rank)=\(.id)=\(.symbol)=\(.price_'${2,,}')=\(((.percent_change_1h // '${BTC1H}')|tonumber)-'${BTC1H}')%=\(((.percent_change_24h // '${BTC24H}')|tonumber)-'${BTC24H}')%=\(((.percent_change_7d // '${BTC7D}')|tonumber)-'${BTC7D}')%=\(."24h_volume_'${2,,}'")=\(.market_cap_'${2,,}')=\(.available_supply)/\(.total_supply)=\(.last_updated|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' <<< "${TICKERJSON}" | sed -E 's/([0-9]+\.[0-9]{0,4})[0-9]*%/\1%/g' | column -s"=" -t  -N"RANK,ID,SYMBOL,PRICE(BTC),D1h(BTC),D24h(BTC),D7D(BTC),VOL24h(BTC),MCAP(BTC),SUPPLY/TOTAL,UPDATE" ${COLCONF}
	else
		jq -r '.[]|"\(.rank)=\(.id)=\(.symbol)=\(.price_'"${2,,}"')=\(.percent_change_1h)%=\(.percent_change_24h)%=\(.percent_change_7d)%=\(."24h_volume_'"${2,,}"'")=\(.market_cap_'"${2,,}"')=\(.available_supply)/\(.total_supply)=\(.last_updated|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' <<< "${TICKERJSON}" | column -s"=" -t  -N"RANK,ID,SYMBOL,PRICE(${2^^}),D1h(USD),D24h(USD),D7D(USD),VOL24h(${2^^}),MCAP(${2^^}),SUPPLY/TOTAL,UPDATE" ${COLCONF}
	fi
}

## -l Print currency lists
listsf() {
	printf "\n=============CRYPTOCURRENCIES============\n"
	curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/map | jq -r '.data[] | "\(.id)=\(.symbol)=\(.name)"' | column -s'=' -et -N 'ID,SYMBOL,NAME'
	printf "\n\n===========BANK CURRENCIES===========\n"
	printf "%s\n" "${OTHERCUR}" | column -s'=' -et -N'ID,SYMBOL,NAME'
}

## -a API status
apif() {
	PAGE="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json"  'https://pro-api.coinmarketcap.com/v1/key/info')"
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${PAGE}"
		exit 0
	fi
	#print heading and status page
	printf "API key: %s\n\n" "${CMCAPIKEY}"
	tr -d '{}",' <<<"${PAGE}"| sed -e 's/^\s*\(.*\)/\1/' -e '1,/data/d' -e 's/_/ /g'| sed -e '/^$/N;/^\n$/D' | sed -e 's/^\([a-z]\)/\u\1/g'
	#| cat -s    #sed -e '$d'
}

# Precious metals in grams?
ozgramf() {	
	# Precious metals - ounce to gram
	if [[ -n "${GRAMOPT}" ]]; then
		if grep -qi -e 'XAU' -e 'XAG' -e 'XPT' -e 'XPD' <<<"${1}"; then
			FMET=1
		fi
		if grep -qi -e 'XAU' -e 'XAG' -e 'XPT' -e 'XPD' <<<"${2}"; then
			TMET=1
		fi
		if [[ -n "${FMET}" ]] && [[ -n "${TMET}" ]] ||
			[[ -z "${FMET}" ]] && [[ -z "${TMET}" ]]; then
			unset OZ
			unset GRAM
		elif [[ -n "${FMET}" ]] && [[ -z "${TMET}" ]]; then
			GRAM='/'
		elif [[ -z "${FMET}" ]] && [[ -n "${TMET}" ]]; then
			GRAM='*'
		fi
	else
		unset OZ
		unset GRAM
	fi
}


# Parse options
while getopts ":0123456789ablmghjs:tp" opt; do
	case ${opt} in
		( [0-9] ) #scale, same as '-sNUM'
			SCL="${SCL}${opt}"
			;;
		( a ) # API key status
			APIOPT=1
			;;
		( b ) # Hack central bank currency rates
			BANK=1
			;;
		( g ) # Gram opt
			GRAMOPT=1
			;;
		( j ) # Debug: Print JSON
			PJSON=1
			;;
		( l ) # List available currencies
			LISTS=1
			;;
		( m ) # Market Capital Function
			MCAP=1
			;;
		( h ) # Show Help
			echo -e "${HELP_LINES}"
			exit 0
			;;
		( p ) # Print Timestamp with result
			TIMEST=1
			;;
		( s ) # Decimal plates
			SCL="${OPTARG}"
			;;
		( t ) ## Tickers for crypto currencies
			TICKEROPT=1
			;;
		( \? )
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
if [[ -n "${TICKEROPT}" ]]; then
	tickerf ${@}
	exit
fi

## Set custom scale
if [[ -z ${SCL} ]]; then
	SCL="${SCLDEFAULTS}"
fi

# Call opt functions
if [[ -n "${MCAP}" ]]; then
	mcapf "${@}"
	exit
elif [[ -n "${APIOPT}" ]]; then
	apif
	exit
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
CMCJSON=$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -d "&symbol=${2^^}&convert=${3^^}" -G "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest")
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
# Precious metals in grams?
ozgramf "${2}" "${3}"
RESULT="$(bc -l <<< "(${1}*${CMCRATE})${GRAM}${OZ}")"
printf "%.${SCL}f\n" "${RESULT}"

exit

##Dead code
# Check if there is any argument
#if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
#	printf "Run with -h for help.\n"
#	exit 1
#fi

