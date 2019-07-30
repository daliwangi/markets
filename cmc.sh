#!/usr/bin/bash
#
# Cmc.sh -- Coinmarketcap.com API Access
# v0.2.5 - 2019/jul/30   by mountaineerbr

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
	cmc.sh \e[0;35;40m[-f|-h|-l|-m]\033[00m

	cmc.sh \e[0;35;40m[-b|-j|-s|-t]\033[00m \e[0;33;40m[AMOUNT]\033[00m \
\e[0;32;40m[FROM_CURRENCY]\033[00m \e[0;31;40m[TO_CURRENCY]\033[00m

DESCRIPTION
	This programme fetches updated currency rates from the internet	and can
	convert any amount of one supported currency into another.

	CMC does not convert from a central bank currency to another,
	but it does convert from crypto to ~93 central bank currencies

	Default precision is 16. Trailing zeroes are trimmed by default.

	Usage example:

		\e[1;30;40m$ \e[1;34;40mcmc.sh 0.5 xmr brl -s3\033[00m


OPTIONS
		-b 	Activate Bank Currency Mode: FROM_CURRENCY can be
			any central bank currency supported by CMC.
		
		-h 	Show this help.

		-j 	Print JSON.

		-l 	List supported currencies.

		-m 	Market Ticker.

		-s 	Set scale ( decimal plates ).

		-t 	Print JSON timestamp.


BUGS
 	This programme is distributed without support or bug corrections.
	Licensed under GPLv3 and above.
	Give me a nickle! =)
          bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr
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
while getopts ":blmhjs:t" opt; do
  case ${opt} in
	b ) ## Hack central bank currency rates
		BANK=1
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
	#echo kkkkk$1-$2-$3-$4-$5-$SCL-"${BTCTOCURTAIL}"-$BTCTOCURHEAD"-${BTCTOCUR}"

	# Calculate result, print result or check for internet error
	RESULT="$(printf "(%s*%s)/%s\n" "${1}" "${BTCTOCURTAIL}" "${BTCBANKTAIL}" | bc -l)"
	printf "%.${SCL}f\n" "${RESULT}"
	icheck
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
	date --date "$CGKTIME"  "+%n## %FT%T%Z%n"
	LC_NUMERIC="en_US.utf8"
	
	printf "CRYPTO MARKET STATS\n\n"
	printf "## Exchanges     : %s\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.active_exchanges')"
	printf "## Active cryptos: %s\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.active_cryptocurrencies')"
	printf "## Market pairs  : %s\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.active_market_pairs')"

	printf "\n## All crypto market volume (USD)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.quote.USD.total_market_cap')"
	printf "## Last 24h volume (USD/24-H)\n"
	printf "%'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.quote.USD.total_volume_24h')"

	printf "\n## Dominance (%%)\n"
	printf "BTC: %'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.btc_dominance')"
	printf "ETH: %'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '.data.eth_dominance')"

	printf "\n## Market Cap per Coin (USD)\n"
	printf "BTC: %'.2f\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '((.data.btc_dominance/100)*.data.quote.USD.total_market_cap)')"
	printf "ETH: %'.2f\n\n" "$(printf "%s" "${CMCGLOBAL}" | jq -r '((.data.eth_dominance/100)*.data.quote.USD.total_market_cap)')"
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
RESULT="$(printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; trunc(%s*%s)\n" "${1}" "${CMCRATE}" | bc -l)"

printf "%.${SCL}f\n" "${RESULT}"
icheck

