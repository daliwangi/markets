#!/bin/bash
#
# Cmc.sh -- Coinmarketcap.com API Access
# v0.4.30  2019/nov/13  by mountaineerbr


## CMC API Personal KEY
#CMCAPIKEY=""


## Some defaults
LC_NUMERIC="en_US.UTF-8"

## Manual and help
## Usage: $ cmc.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
	Cmc.sh -- Currency Converter and Market Information
		  Coinmarketcap.com API Access


SYNOPSIS
	cmc.sh [options] [amount] [from_currency] [to_currency]

	cmc.sh [-b|-j|-s|-p] [amount] [from_code] [to_code]

	cmc.sh [-h|-j|-l|-m|-t|-v]


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
		(1)     One Bitcoin in U.S.A. Dollar:
			
			$ cmc.sh btc
			
			$ cmc.sh 1 btc usd


		(2) 	One Bitcoin in Brazilian Real:

			$ cmc.sh btc brl


		(3)     0.1 Bitcoin in Ether:
			
			$ cmc.sh 0.1 btc eth 


		(4)     One Dash in ZCash:
			
			$ cmc.sh dash zec 


		(5)     One Canadian Dollar in Japanese Yen (must use the Bank
			Currency Function):
			
			$ cmc.sh -b cad jpy 


		(6)     One thousand Brazilian Real in U.S.A. Dollars with 4 decimal plates:
			
			$ cmc.sh -b -s4 1000 brl usd 


		(7) 	Market Ticker

			$ cmc.sh -m


		(8) 	Top 20 crypto currency tickers in EUR (Defaults: 10,USD):

			$ cmc.sh -t 20 eur


		(9)    One Bitcoin in ounces of Gold:
					
			$ cgk.sh 1 btc xau 


		(10)    \e[0;33;40m[Amount]\033[00m of EUR in grams of Gold:
					
			$ cgk.sh \"\e[0;33;40m[amount]\033[00m*28.3495\" eur xau 

			    Just multiply amount by the \"gram/ounce\" rate.


		(11)    \e[1;33;40mOne\033[00m EUR in grams of Gold:
					
			$ cgk.sh -b \"\e[1;33;40m1\033[00m*28.3495\" eur xau 


		(12)    \e[0;33;40m[Amount]\033[00m (grams) of Gold in USD:
					
			$ cgk.sh -b \"\e[0;33;40m[amount]\033[00m/28.3495\" xau usd 
			
			    Just divide amount by the \"gram/ounce\" rate.

		
		(13)    \e[1;33;40mOne\033[00m gram of Gold in EUR:
					
			$ cgk.sh -b \"\e[1;33;40m1\033[00m/28.3495\" xau eur 
			

OPTIONS
		-b 	Bank currency function: from_ and to_currency can be 
			any central bank or crypto currency supported by CMC.
		
		-h 	Show this help.

		-j 	Print JSON (useful for debugging).

		-l 	List supported currencies.

		-m 	Market ticker.

		-s 	Set scale (decimal plates).

		-p 	Print JSON timestamp, if available.
		
		-t 	Tickers for top cryptos; enter the number of top cur-
			rencies to show; defaults=10, max=100;

		-v 	Show this programme version."

OTHERCUR="
2781 = USD = United States Dollar ($)
3526 = ALL = Albanian Lek (L)
3537 = DZD = Algerian Dinar (د.ج)
2821 = ARS = Argentine Peso ($)
3527 = AMD = Armenian Dram (֏)
2782 = AUD = Australian Dollar ($)
3528 = AZN = Azerbaijani Manat (₼)
3531 = BHD = Bahraini Dinar (.د.ب)
3530 = BDT = Bangladeshi Taka (৳)
3533 = BYN = Belarusian Ruble (Br)
3532 = BMD = Bermudan Dollar ($)
2832 = BOB = Bolivian Boliviano (Bs.)
3529 = BAM = Bosnia-Herzegovina Convertible Mark (KM)
2783 = BRL = Brazilian Real (R$)
2814 = BGN = Bulgarian Lev (лв)
3549 = KHR = Cambodian Riel (៛)
2784 = CAD = Canadian Dollar ($)
2786 = CLP = Chilean Peso ($)
2787 = CNY = Chinese Yuan (¥)
2820 = COP = Colombian Peso ($)
3534 = CRC = Costa Rican Colón (₡)
2815 = HRK = Croatian Kuna (kn)
3535 = CUP = Cuban Peso ($)
2788 = CZK = Czech Koruna (Kč)
2789 = DKK = Danish Krone (kr)
3536 = DOP = Dominican Peso ($)
3538 = EGP = Egyptian Pound (£)
2790 = EUR = Euro (€)
3539 = GEL = Georgian Lari (₾)
3540 = GHS = Ghanaian Cedi (₵)
3541 = GTQ = Guatemalan Quetzal (Q)
3542 = HNL = Honduran Lempira (L)
2792 = HKD = Hong Kong Dollar ($)
2793 = HUF = Hungarian Forint (Ft)
2818 = ISK = Icelandic Króna (kr)
2796 = INR = Indian Rupee (₹)
2794 = IDR = Indonesian Rupiah (Rp)
3544 = IRR = Iranian Rial (﷼)
3543 = IQD = Iraqi Dinar (ع.د)
2795 = ILS = Israeli New Shekel (₪)
3545 = JMD = Jamaican Dollar ($)
2797 = JPY = Japanese Yen (¥)
3546 = JOD = Jordanian Dinar (د.ا)
3551 = KZT = Kazakhstani Tenge (₸)
3547 = KES = Kenyan Shilling (Sh)
3550 = KWD = Kuwaiti Dinar (د.ك)
3548 = KGS = Kyrgystani Som (с)
3552 = LBP = Lebanese Pound (ل.ل)
3556 = MKD = Macedonian Denar (ден)
2800 = MYR = Malaysian Ringgit (RM)
2816 = MUR = Mauritian Rupee (₨)
2799 = MXN = Mexican Peso ($)
3555 = MDL = Moldovan Leu (L)
3558 = MNT = Mongolian Tugrik (₮)
3554 = MAD = Moroccan Dirham (د.م.)
3557 = MMK = Myanma Kyat (Ks)
3559 = NAD = Namibian Dollar ($)
3561 = NPR = Nepalese Rupee (₨)
2811 = TWD = New Taiwan Dollar ($)
2802 = NZD = New Zealand Dollar ($)
3560 = NIO = Nicaraguan Córdoba (C$)
2819 = NGN = Nigerian Naira (₦)
2801 = NOK = Norwegian Krone (kr)
3562 = OMR = Omani Rial (ر.ع.)
2804 = PKR = Pakistani Rupee (₨)
3563 = PAB = Panamanian Balboa (B/.)
2822 = PEN = Peruvian Sol (S/.)
2803 = PHP = Philippine Peso (₱)
2805 = PLN = Polish Złoty (zł)
2791 = GBP = Pound Sterling (£)
3564 = QAR = Qatari Rial (ر.ق)
2817 = RON = Romanian Leu (lei)
2806 = RUB = Russian Ruble (₽)
3566 = SAR = Saudi Riyal (ر.س)
3565 = RSD = Serbian Dinar (дин.)
2808 = SGD = Singapore Dollar ($)
2812 = ZAR = South African Rand (Rs)
2798 = KRW = South Korean Won (₩)
3567 = SSP = South Sudanese Pound (£)
3573 = VES = Sovereign Bolivar (Bs.)
3553 = LKR = Sri Lankan Rupee (Rs)
2807 = SEK = Swedish Krona ( kr)
2785 = CHF = Swiss Franc (Fr)
2809 = THB = Thai Baht (฿)	=
3569 = TTD = Trinidad and Tobago Dollar ($)
3568 = TND = Tunisian Dinar (د.ت)
2810 = TRY = Turkish Lira (₺)
3570 = UGX = Ugandan Shilling (Sh)
2824 = UAH = Ukrainian Hryvnia (₴)
2813 = AED = United Arab Emirates Dirham (د.إ)
3571 = UYU = Uruguayan Peso ($)
3572 = UZS = Uzbekistan Som (so'm)
2823 = VND = Vietnamese Dong (₫)

3575 = XAU = Gold Troy Ounce
3574 = XAG = Silver Troy Ounce
3577 = XPT = Platinum Ounce
3576 = XPD = Palladium Ounce
"

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
  	t ) ## Tickers for crypto currencies
		TICKEROPT=1
		# How many top cryptos should be printed? Defaults=10
		# If number of tickers is in ARG2
		if [[ -z "${2}" ]]; then
			set -- "${1}" 10 bitcoin USD
		elif grep -q "[0-9]" <<< "${2}"; then
			TICKEROPT="${2}"
			set -- "${1}" "${2}" bitcoin "${3}"
		# If number of tickers is in ARG3
		elif grep -q "[0-9]" <<< "${3}"; then
			set -- "${1}" "${3}" bitcoin "${2}"
		else
			set -- "${1}" 10 bitcoin "${2}"
		fi
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
	j ) # Print JSON
		PJSON=1
		;;
	s ) # Decimal plates
		SCL="${OPTARG}"
		;;
	p ) # Print Timestamp with result
		TIMEST=1
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

## Print currency lists
listsf() {
	printf "\n=============CRYPTOCURRENCIES============\n"
	curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/map |
	jq -r '.data[] | "\(.id)=\(.symbol)=\(.name)"' |
	column -s '=' -et -o '|' -N 'ID,SYMBOL,NAME'
	printf "\n\n===========BANK CURRENCIES===========\n"
	printf "%s\n" "${OTHERCUR}" | column -s '=' -et -o '|' -N 'ID,SYMBOL,NAME'
	exit 0
	}
if [[ -n "${LISTS}" ]]; then
	listsf
fi

## Set default scale if no custom scale
SCLDEFAULTS=16
if [[ -z ${SCL} ]]; then
	SCL="${SCLDEFAULTS}"
fi

## Set arguments
# If first argument does not have numbers OR isn't a  valid expression
if ! [[ "${1}" =~ [0-9] ]] ||
	[[ -z "$(bc -l <<< "${1}" 2>/dev/null)" ]]; then
	set -- 1 "${@:1:2}"
fi

if [[ -z ${3} ]]; then
	set -- ${@:1:2} "USD"
fi

## Bank currency rate function
bankf() {
	# Rerun script, get rates and process data	
	(
	BTCBANK="$(${0} -p BTC "${2^^}")"
	BTCBANKHEAD=$(head -n1 <<< "${BTCBANK}") # Timestamp
	BTCBANKTAIL=$(tail -n1 <<< "${BTCBANK}") # Rate
	BTCTOCUR="$(${0} -p BTC "${3^^}")"
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
		printf "Input must have valid currency symbols; check for eventual mistakes.\n"
		exit 1
	fi
	) 2>/dev/null
	exit 0
}
if [[ -n "${PJSON}" ]] && [[ -n "${BANK}" ]]; then
	# Print JSON?
	printf "No specific JSON for the bank currency function.\n"
	exit 1
elif [[ -n "${BANK}" ]]; then
	export BANKFSET=1
	bankf ${*}
fi

## Market Capital Function
mcapf() {
	CMCGLOBAL=$(curl -s -H "X-CMC_PRO_API_KEY:  ${CMCAPIKEY}" -H "Accept: application/json" -d "convert=USD" -G https://pro-api.coinmarketcap.com/v1/global-metrics/quotes/latest)
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
	printf "   %'.2f USD\n" "$(jq -r '.data.quote.USD.total_market_cap' <<< "${CMCGLOBAL}")"
	printf " # Last 24h Volume\n"
	printf "    %'.2f USD\n" "$(jq -r '.data.quote.USD.total_volume_24h' <<< "${CMCGLOBAL}")"
	printf " # Last 24h Reported Volume\n"
	printf "    %'.2f USD\n" "$(jq -r '.data.quote.USD.total_volume_24h_reported' <<< "${CMCGLOBAL}")"
	
	printf "\n## Bitcoin Market Cap\n"
	printf "   %'.2f USD\n" "$(jq -r '(.data.quote.USD.total_market_cap-.data.quote.USD.altcoin_market_cap)' <<< "${CMCGLOBAL}")"
	printf " # Last 24h Volume\n"
	printf "    %'.2f USD\n" "$(jq -r '(.data.quote.USD.total_volume_24h-.data.quote.USD.altcoin_volume_24h)' <<< "${CMCGLOBAL}")"
	printf " # Last 24h Reported Volume\n"
	printf "    %'.2f USD\n" "$(jq -r '(.data.quote.USD.total_volume_24h_reported-.data.quote.USD.altcoin_volume_24h_reported)' <<< "${CMCGLOBAL}")"
	printf "## Circulating Supply\n"
	printf " # BTC: %'.2f bitcoins\n" "$(bc -l <<< "$(curl -s "https://blockchain.info/q/totalbc")/100000000")"

	printf "\n## AltCoin Market Cap\n"
	printf "   %'.2f USD\n" "$(jq -r '.data.quote.USD.altcoin_market_cap' <<< "${CMCGLOBAL}")"
	printf " # Last 24h Volume\n"
	printf "    %'.2f USD\n" "$(jq -r '.data.quote.USD.altcoin_volume_24h' <<< "${CMCGLOBAL}")"
	printf " # Last 24h Reported Volume\n"
	printf "    %'.2f USD\n" "$(jq -r '.data.quote.USD.altcoin_volume_24h_reported' <<< "${CMCGLOBAL}")"
	
	printf "\n## Dominance\n"
	printf " # BTC: %'.2f %%\n" "$(jq -r '.data.btc_dominance' <<< "${CMCGLOBAL}")"
	printf " # ETH: %'.2f %%\n" "$(jq -r '.data.eth_dominance' <<< "${CMCGLOBAL}")"

	printf "\n## Market Cap per Coin\n"
	printf " # BTC: %'.2f USD\n" "$(jq -r '((.data.btc_dominance/100)*.data.quote.USD.total_market_cap)' <<< "${CMCGLOBAL}")"
	printf " # ETH: %'.2f USD\n" "$(jq -r '((.data.eth_dominance/100)*.data.quote.USD.total_market_cap)' <<< "${CMCGLOBAL}")"
	# Avoid erros being printed
	} 2>/dev/null
	exit 0
}
if [[ -n "${MCAP}" ]]; then
	mcapf
fi

## -t Top Tickers Function
tickerf() {
	# Prepare retrive query to server
	# Get JSON
	TICKERJSON="$(curl -s "https://api.coinmarketcap.com/v1/ticker/?limit=${1}&convert=${3^^}")"
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
		COLCONF="-HMCAP(${3^^}),SUPPLY/TOTAL,UPDATE -TPRICE(${3^^}),VOL(24H;${3^^})"
		printf "OBS: More columns are needed to print more info.\n" 1>&2
	elif test "$(tput cols)" -lt "120"; then
		COLCONF="-HSUPPLY/TOTAL,UPDATE"
		printf "OBS: More columns are needed to print more info.\n" 1>&2
	else
		COLCONF="-TSUPPLY/TOTAL,UPDATE"
	fi
	jq -r '.[]|"\(.rank)=\(.id)=\(.symbol)=\(.price_'"${3,,}"')=\(.percent_change_1h)%=\(.percent_change_24h)%=\(.percent_change_7d)%=\(."24h_volume_'"${3,,}"'")=\(.market_cap_'"${3,,}"')=\(.available_supply)/\(.total_supply)=\(.last_updated|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' <<< "${TICKERJSON}" |
		column -s"=" -t  -N"RANK,ID,SYMBOL,PRICE(${3^^}),D1h,D24h,D7D,VOL(24H;${3^^}),MCAP(${3^^}),SUPPLY/TOTAL,UPDATE" ${COLCONF}
# https://api.coinmarketcap.com/v1/ticker/?limit=10&convert=USD
# https://api.coinmarketcap.com/v1/ticker/bitcoin-cash/?convert=EUR
	exit 0
}
if [[ -n "${TICKEROPT}" ]]; then
	tickerf ${*}
fi


## Check you are NOT requesting some unsupported FROM_CURRENCY
# Make a list of currencies names and ids and their symvols
test -z "${BANKFSET}" &&
	SYMBOLLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/map | jq '[.data[]| {"key": .slug, "value": .symbol},{"key": (.name|ascii_upcase), "value": .symbol}] | from_entries')"
if test -z "${BANKFSET}" && ! jq -er ".[]" <<< "${SYMBOLLIST}" | grep -iq "^${2}$"; then
	if jq -er '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
		set -- "${1}" "$(jq -r '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}")" "${3}"
	else
		printf "ERR: FROM_CURRENCY -- %s\nCheck symbol or \"-h\" for help.\n" "${2^^}" 1>&2
		exit 1
	fi
fi

## NOTES: Multiple values for keys jq
#jq '[.data[]| {"key": .symbol, "value": [.slug,.name] } ] | from_entries'
#https://github.com/stedolan/jq/issues/785
#https://michaelheap.com/extract-keys-using-jq/

## Check you are not requesting some unsupported TO_CURRENCY
TOCURLIST=( USD ALL DZD ARS AMD AUD AZN BHD BDT BYN BMD BOB BAM BRL BGN KHR CAD CLP CNY COP CRC HRK CUP CZK DKK DOP EGP EUR GEL GHS GTQ HNL HKD HUF ISK INR IDR IRR IQD ILS JMD JPY JOD KZT KES KWD KGS LBP MKD MYR MUR MXN MDL MNT MAD MMK NAD NPR TWD NZD NIO NGN NOK OMR PKR PAB PEN PHP PLN GBP QAR RON RUB SAR RSD SGD ZAR KRW SSP VES LKR SEK CHF THB TTD TND TRY UGX UAH AED UYU UZS VND XAU XAG XPT XPD ) 
if test -z "${BANKFSET}" && ! grep -qi "${3}" <<< "${TOCURLIST[@]}" &&
	! jq -r ".[]" <<< "${SYMBOLLIST}" | grep -iq "^${3}$"; then
		if jq -er '.["'"${3^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
			set -- "${1}" "${2}" "$(jq -r '.["'"${3^^}"'"]' <<< "${SYMBOLLIST}")"
		else
			printf "ERR: TO_CURRENCY -- %s\nCheck symbol or \"-h\" for help.\n" "${3^^}" 1>&2
			exit 1
		fi
fi

## Default function
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
#Dead Code
## Check for internet connection function
#icheck() {
#if [[ -z "${RESULT}" ]] &&
#	   ! ping -q -w7 -c2 8.8.8.8 &> /dev/null; then
#	printf "Bad internet connection.\n"
#fi
#}

