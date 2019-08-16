#!/usr/bin/bash
#
# Cmc.sh -- Coinmarketcap.com API Access
# v0.3 - 2019/ago/16   by mountaineerbr

## Some defaults
LC_NUMERIC="en_US.utf8"

## CMC API Personal KEY
APIKEY="29f3d386-d47d-4b54-9790-278e1faa7cdc"
# Spare key:
#APIKEY="f70ef502-0d91-496b-bd5b-5c0f20334720"
# dirufit@mailmetal.com -- hellodear



## Manual and help
## Usage: $ cmc.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	\033[01;36mCmc.sh -- Coinmarketcap.com API Access\033[00m


SYNOPSIS
	cmc.sh \e[0;35;40m[-h|-j|-l|-m]\033[00m

	cmc.sh \e[0;35;40m[-b|-g|-j|-s|-t]\033[00m \e[0;33;40m[AMOUNT]\033[00m \
\e[0;32;40m[FROM_CURRENCY]\033[00m \e[0;31;40m[TO_CURRENCY]\033[00m

DESCRIPTION
	This programme fetches updated currency rates from CoinMarketCap.com
	through a Private API key. It can convert any amount of one supported
	currency into another.

	CMC does not convert from a central bank currency to another,
	but it does convert from crypto to ~93 central bank currencies
	
	Central bank currency conversions are not supported directly, but we can
	derive bank currency rates undirectly, for e.g. USD vs CNY. As CoinMarketCap
	updates frequently, it is one of the best API for bank currency rates.

	All these unofficially supported market pairs can be calculated with the
	\"Bank Currency Function\", called with the flag \"-b\". It can also be
	used with crypto currencies that may not be supported otherwise.

	It is _not_ advisable to depend solely on CoinGecko rates for serious trading.
	
	You can see a List of supported currencies running the script with the
	argument \"-l\". 

	Default precision is 16 and can be adjusted with \"-s\". Trailing noughts
	are trimmed by default.


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


		(7)     One ounce of Gold in U.S.A. Dollar:
			
			$ cmc.sh -b xau 
			
			$ cmc.sh -b 1 xau usd 

		
		(8)     One gram of Silver in New Zealand Dollar:
			
			$ cmc.sh -bg xag nzd 


		(9)     Ticker for all Bitcoin market pairs:
			
			$ cmc.sh -k btc 


OPTIONS
		-b 	Activate Bank Currency Mode: FROM_CURRENCY and
			TO_CURRENCY can be any central bank or crypto currency
			supported by CMC.
		
		-g 	Use gram instead of ounce (useful for precious metals).

		-h 	Show this help.

		-j 	Print JSON (useful for debugging).

		-l 	List supported currencies.

		-m 	Market Ticker.

		-s 	Set scale (decimal plates).

		-t 	Print JSON timestamp, if any.


BUGS
 	This programme is distributed without support or bug corrections.
	Licensed under GPLv3 and above.
	Give me a nickle! =)
          bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


IMPORTANT NOTICE
	Please take a little time to register at <https://coinmarketcap.com/api/>
	for a free API key and change the APIKEY variable in the script source
	code for yours. The default API key may stop working at any moment and
	without any warning!
		"
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
	exit
fi
# Parse options
while getopts ":bglmhjs:t" opt; do
  case ${opt} in
	b ) ## Hack central bank currency rates
		BANK=1
		;;
	g ) ## Use gram instead of ounce for precious metals
		GRAM=1
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


## Print currency lists
listsf() {
	printf "\n=============CRYPTOCURRENCIES============\n"
	curl -s -H "X-CMC_PRO_API_KEY: ${APIKEY}" -H "Accept: application/json" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/map |
	jq -r '.data[] | "\(.id) = \(.symbol) = \(.name)"' |
	column -s '=' -c 46 -T 2 -e -t -o '|' -N '---ID---,---SYMBOL---,----------NAME----------'
	printf "\n\n===========BANK CURRENCIES===========\n"
	printf "%s\n" "${OTHERCUR}" | column -s '=' -c 46 -T 2 -e -t -o '|' -N '---ID---,---SYMBOL---,----------NAME----------'
	}
if [[ -n "${LISTS}" ]]; then
	listsf
	exit
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


## Set arguments
if ! [[ ${1} =~ [0-9] ]]; then
	set -- 1 ${@:1:2}
fi

if [[ -z ${3} ]]; then
	set -- ${@:1:2} "USD"
fi

## Bank currency rate function
bankf() {
	BTCBANK="$(${0} -t BTC ${2^^})"
	BTCBANKHEAD=$(printf "%s\n" "${BTCBANK}" | head -n1) # Timestamp
	BTCBANKTAIL=$(printf "%s\n" "${BTCBANK}" | tail -n1) # Rate
	BTCTOCUR="$(${0} -t BTC ${3^^})"
	BTCTOCURHEAD=$(printf "%s\n" "${BTCTOCUR}" | head -n1) # Timestamp
	BTCTOCURTAIL=$(printf "%s\n" "${BTCTOCUR}" | tail -n1) # Rate
	if [[ -n "${TIMEST}" ]]; then
		printf "%s (from currency)\n" "${BTCBANKHEAD}"
		printf "%s (to   currency)\n" "${BTCTOCURHEAD}"
	fi
	#echo iiiii$1-$2-$3-$4-$5-$SCL-"${BTCBANKTAIL}"-$BTCBANKHEAD"-${BTCTOCUR}"
	#exit
	#echo kkkkk$1-$2-$3-$4-$5-$SCL-"${BTCTOCURTAIL}"-$BTCTOCURHEAD"-${BTCTOCUR}"

	# Calculate result, print result or check for internet error
	if [[ -z ${GRAM} ]]; then
		RESULT="$(printf "(%s*%s)/%s\n" "${1}" "${BTCTOCURTAIL}" "${BTCBANKTAIL}" | bc -l)"
	else	
		RESULT="$(printf "((1/28.349523125)*%s*%s)/%s\n" "${1}" "${BTCTOCURTAIL}" "${BTCBANKTAIL}" | bc -l)"
	fi
	printf "%.${SCL}f\n" "${RESULT}"
	#icheck
	exit
}
if [[ -n "${PJSON}" ]] && [[ -n "${BANK}" ]]; then
	# Print JSON?
	printf "No specific JSON for the bank currency function.\n"
	exit 1
elif [[ -n "${BANK}" ]]; then
	bankf ${*}
fi


## Market Capital Function
mcapf() {
	CMCGLOBAL=$(curl -s -H "X-CMC_PRO_API_KEY:  ${APIKEY}" -H "Accept: application/json" -d "convert=USD" -G https://pro-api.coinmarketcap.com/v1/global-metrics/quotes/latest)

	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${CMCGLOBAL}"
		exit 0
	fi

	LASTUP=$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.last_updated')
	date --date "${LASTUP}"  "+%n## %FT%T%Z%n"
	LC_NUMERIC="en_US.utf8"
	
	printf "CRYPTO MARKET STATS\n\n"
	printf "## Exchanges     : %s\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.active_exchanges')"
	printf "## Active cryptos: %s\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.active_cryptocurrencies')"
	printf "## Market pairs  : %s\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.active_market_pairs')"

	printf "\n## All Crypto Market Cap (USD)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.quote.USD.total_market_cap')"
	printf "## Last 24h Volume (USD/24-H)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.quote.USD.total_volume_24h')"
	printf "## Last 24h Reported Volume (USD/24-H)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.quote.USD.total_volume_24h_reported')"

	printf "\n## Bitcoin Market Cap (USD)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '(.data.quote.USD.total_market_cap-.data.quote.USD.altcoin_market_cap)')"
	printf "## Last 24h Volume (USD/24-H)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '(.data.quote.USD.total_volume_24h-.data.quote.USD.altcoin_volume_24h)')"
	printf "## Last 24h Reported Volume (USD/24-H)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '(.data.quote.USD.total_volume_24h_reported-.data.quote.USD.altcoin_volume_24h_reported)')"

	printf "\n## AltCoin Market Cap (USD)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.quote.USD.altcoin_market_cap')"
	printf "## Last 24h Volume (USD/24-H)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.quote.USD.altcoin_volume_24h')"
	printf "## Last 24h Reported Volume (USD/24-H)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.quote.USD.altcoin_volume_24h_reported')"

	printf "\n## Dominance (%%)\n"
	printf "BTC: %'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.btc_dominance')"
	printf "ETH: %'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.eth_dominance')"

	printf "\n## Market Cap per Coin (USD)\n"
	printf "BTC: %'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '((.data.btc_dominance/100)*.data.quote.USD.total_market_cap)')"
	printf "ETH: %'.2f\n\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '((.data.eth_dominance/100)*.data.quote.USD.total_market_cap)')"
# v1.15.0 on Jul 10, 2019
#/v1/global-metrics/quotes/latest now updates more frequently, every minute. It aslo now includes total_volume_24h_reported, altcoin_volume_24h, altcoin_volume_24h_reported, and altcoin_market_cap.

}
if [[ -n "${MCAP}" ]]; then
	mcapf
	exit
fi


## Check you are not requesting some unsupported FROM_CURRENCY
NOFCUR=(USD ALL DZD ARS AMD AUD AZN BHD BDT BYN BMD BOB BAM BRL
	BGN KHR CAD CLP CNY COP CRC HRK CUP CZK DKK DOP EGP EUR
	GEL GHS GTQ HNL HKD HUF ISK INR IDR IRR IQD ILS JMD JPY
	JOD KZT KES KWD KGS LBP MKD MYR MUR MXN MDL MNT MAD MMK
	NAD NPR TWD NZD NIO NGN NOK OMR PKR PAB PEN PHP PLN GBP
	QAR RON RUB SAR RSD SGD ZAR KRW SSP VES LKR SEK CHF THB
	TTD TND TRY UGX UAH AED UYU UZS VND XAU XAG XPT XPD)
if [[ -z ${JSONM} ]] &&	printf "%s\n" "${NOFCUR[*]}" | grep -qi "${2}" &> /dev/null; then
	printf "Unsupported FROM_CURRENCY %s at CMC.\nTry the Bank currency function.\n" "${2^^}"
	exit 1
fi

## Get JSON
CMCJSON=$(curl -s -H "X-CMC_PRO_API_KEY: ${APIKEY}" -H "Accept: application/json" -d "&symbol=${2^^}&convert=${3^^}" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest)

# Print JSON?
if [[ -n ${PJSON} ]]; then
	printf "%s\n" "${CMCJSON}"
	exit 0
fi

## Get pair rate
CMCRATE=$(printf "%s\n" "${CMCJSON}" | jq -r ".data[] | .quote.${3^^}.price") 


## Print JSON timestamp ?
if [[ -n ${TIMEST} ]]; then
JSONTIME=$(printf "%s\n" "${CMCJSON}" | jq -r ".data.${2^^}.quote.${3^^}.last_updated")
	date --date "$JSONTIME" "+## %FT%T%Z"
fi


## Make equation and calculate result
if [[ -z ${GRAM} ]]; then
	RESULT="$(printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; trunc(%s*%s)\n" "${1}" "${CMCRATE}" | bc -l)"
else
	RESULT="$(printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; trunc((1/28.349523125)*%s*%s)\n" "${1}" "${CMCRATE}" | bc -l)"
fi

printf "%.${SCL}f\n" "${RESULT}"
#icheck

