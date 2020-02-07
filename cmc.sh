#!/bin/bash
#
# cmc.sh -- coinmarketcap.com api access
# v0.7.1  feb/2020  by mountaineerbr

#cmc api personal key
#CMCAPIKEY=''

#defaults
#default from crypto currency
DEFCUR=BTC

#default vs currency
DEFTOCUR=USD

#scale if no custom scale
SCLDEFAULTS=16

#you should not change these:
LC_NUMERIC='en_US.UTF-8'

#troy ounce to gram ratio
TOZ='31.1034768' 

#manual and help
#usage: $ cmc.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
	Cmc.sh -- Currency Converter and Market Information
		  Coinmarketcap.com API Access


SYNOPSIS
	cmc.sh [-ahlv]

	cmc.sh [-p|-sNUM] [AMOUNT] 'FROM_CURRENCY' [TO_CURRENCY]
	
	cmc.sh -b [-gp] [-sNUM] [AMOUNT] 'FROM_CURRENCY' [TO_CURRENCY]

	cmc.sh -m [TO_CURRENCY]

	cmc.sh [-t] [NUM] [TO_CURRENCY]
	

DESCRIPTION
	This programme fetches updated currency rates from <coinmarketcap.com>
	through a free private API key. It can convert any amount of one sup-
	ported crypto currency into another. CMC also converts crypto to ~93 
	central bank currencies, gold and silver.

	You can see a List of supported currencies running the script with the
	argument '-l'.

	Central bank currency conversions are not supported officially by CMC,
	but we can derive bank currency rates undirectly, for ex USD vs CNY.
	The bank currency option '-b' can also calculate currencies vs. precious
	metals.

	Default precision is ${SCLDEFAULTS} and can be adjusted with '-s'.


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
	
		$ cmc.sh -2bg 1 xau usd 
	
	
	To get \e[0;33;40mAMOUNT\033[00m of EUR in grams of Gold, just multiply
	AMOUNT by the \"GRAM/OUNCE\" constant.
	
		$ cmc.sh -b \"\e[0;33;40mAMOUNT\033[00m*31.1\" eur xau 
	
	
	One EUR in grams of Gold:
	
		$ cmc.sh -b \"\e[1;33;40m1\033[00m*31.1\" eur xau 
	
	
	To get \e[0;33;40mAMOUNT\033[00m of grams of Gold in EUR, just divide 
	AMOUNT by the \"GRAM/OUNCE\" constant.
	
		$ cmc.sh -b \"\e[0;33;40m[amount]\033[00m/31.1\" xau usd 
	
	
	One gram of Gold in EUR:
			
		$ cmc.sh -b \"\e[1;33;40m1\033[00m/31.1\" xau eur 
	
	
	To convert (a) from gold to crypto currencies, (b) from bank currencies
	to gold	or (c) from gold to bank curren-cies, do not forget to use the 
	option \"-b\"!


IMPORTANT NOTICE
	Please take a little time to register at <https://coinmarketcap.com/api/>
	for a free API key and add it to the 'CMCAPIKEY' variable in the script 
	source code or set it as an environment variable.


WARRANTY
	Licensed under the GNU Public License v3 or better. It is distributed 
	without support or bug corrections. This programme needs Bash, cURL, JQ
	and Coreutils to work properly.

	It is _not_ advisable to depend solely on <coinmarketcap.com> rates for 
	serious	trading. Do your own research!
	
	If you found this script useful, please consider giving me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES		
		(1)     One Bitcoin in US Dollar:
			
			$ cmc.sh btc
			
			$ cmc.sh 1 btc usd


		(2)     One Dash in ZCash, with 4 decimal plates:
			
			$ cmc.sh -4 dash zec 
			
			$ cmc.sh -s4 dash zec 


		(3)     One Canadian Dollar in Japanese Yen (must use the Bank
			Currency Function):
			
			$ cmc.sh -b cad jpy 


		(4)     One thousand Brazilian Real in US Dollar with 3 decimal
			plates:
			
			$ cmc.sh -3b '101+(2*24.5)+850' brl usd


		(5) 	Market Ticker in JPY

			$ cmc.sh -m jpy


		(6) 	Top 20 crypto currency tickers in EUR; defaults: 10,BTC:

			$ cmc.sh -t 20 eur
			
			
			TIP: use Less with opion -S (--chop-long-lines) or the 
			'Most' pager for scrolling horizontally:

			$ cmc.sh -t 100 btc | less -S


		(7)    One Bitcoin in troy ounces of Gold:
					
			$ cmc.sh 1 btc xau 


OPTIONS
		-NUM 	Shortcut for scale setting, same as '-sNUM'.

		-a 	  API key status.

		-b 	  Bank currency function, converts between bank curren-
			  cies.

		-g 	  Use grams instead of troy ounces; only for precious
			  metals.
		
		-h 	  Show this help.

		-j 	  Debugging, print JSON.

		-l 	  List supported currencies.

		-m [TO_CURRENCY]
			  Market ticker.

		-s [NUM]  Set scale (decimal plates); defaults=${SCLDEFAULTS}.

		-p 	  Print timestamp, if available.
		
		-t [NUM] [TO_CURRENCY]
		-tt [NUM]
			  Tickers for top cryptos; twice to  see winners and 
			  losers against BTC and USD; defaults=10, max=100.

		-v 	  Script version."

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

#-b bank currency rate function
bankf() {
	unset BANK
	if [[ -n "${PJSON}" ]] && [[ -n "${BANK}" ]]; then
		#print json?
		printf 'No specific JSON for the bank currency function.\n'
		exit 1
	fi
	#rerun script, get rates and process data	
	BTCBANK="$("${0}" -p BTC "${2^^}")"
	BTCBANKHEAD=$(head -n1 <<< "${BTCBANK}") # Timestamp
	BTCBANKTAIL=$(tail -n1 <<< "${BTCBANK}") # Rate
	BTCTOCUR="$("${0}" -p BTC "${3^^}")"
	BTCTOCURHEAD=$(head -n1 <<< "${BTCTOCUR}") # Timestamp
	BTCTOCURTAIL=$(tail -n1 <<< "${BTCTOCUR}") # Rate
	if [[ -n "${TIMEST}" ]]; then
		printf '%s (from currency)\n' "${BTCBANKHEAD}"
		printf '%s ( to  currency)\n' "${BTCTOCURHEAD}"
	fi

	#calculate result & print result 
	#precious metals in grams?
	ozgramf "${2}" "${3}"
	RESULT="$(bc -l <<< "(((${1})*${BTCTOCURTAIL})/${BTCBANKTAIL})${GRAM}${TOZ}")"
	#check for errors
	if [[ -z "${RESULT}" ]]; then
		printf 'Err: invalid currency code(s).\n' 1>&2
		exit 1
	fi
	printf "%.${SCL}f\n" "${RESULT}"
}

#market capital function
mcapf() {
	#check inupt to_currency
	if [[ -n "${1}" ]]; then
		SYMBOLLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H 'Accept: application/json' -G 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/map' | jq '[.data[]| {"key": .slug, "value": .symbol},{"key": (.name|ascii_upcase), "value": .symbol}] | from_entries')"
		if  ! grep -qi "${1}" <<< "${TOCURLIST[@]}" && ! jq -r ".[]" <<< "${SYMBOLLIST}" | grep -iq "^${1}$"; then
			if jq -er '.["'"${1^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
				set -- "$(jq -r '.["'"${1^^}"'"]' <<< "${SYMBOLLIST}")"
			else
				printf 'Check TO_CURRENCY code.\n' 1>&2
				exit 1
			fi
		fi
	else
		set -- USD
	fi
	#get market data
	CMCGLOBAL=$(curl -s -H "X-CMC_PRO_API_KEY:  ${CMCAPIKEY}" -H 'Accept: application/json' -d "convert=${1^^}" -G 'https://pro-api.coinmarketcap.com/v1/global-metrics/quotes/latest')
	#print json?
	if [[ -n ${PJSON} ]]; then
		printf '%s\n' "${CMCGLOBAL}"
		exit 0
	fi
	LASTUP=$(jq -r '.data.last_updated' <<< "${CMCGLOBAL}")
	#avoid erros being printed
	{
	printf '## CRYPTO MARKET INFORMATION\n'
	date --date "${LASTUP}"  '+#  %FT%T%Z'
	printf '\n# Exchanges     : %s\n' "$(jq -r '.data.active_exchanges' <<< "${CMCGLOBAL}")"
	printf '# Active cryptos: %s\n' "$(jq -r '.data.active_cryptocurrencies' <<< "${CMCGLOBAL}")"
	printf '# Market pairs  : %s\n' "$(jq -r '.data.active_market_pairs' <<< "${CMCGLOBAL}")"

	printf '\n## All Crypto Market Cap\n'
	printf "   %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.total_market_cap" <<< "${CMCGLOBAL}")" "${1^^}"
	printf ' # Last 24h Volume\n'
	printf "    %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.total_volume_24h" <<< "${CMCGLOBAL}")" "${1^^}"
	printf ' # Last 24h Reported Volume\n'
	printf "    %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.total_volume_24h_reported" <<< "${CMCGLOBAL}")" "${1^^}"
	
	printf '\n## Bitcoin Market Cap\n'
	printf "   %'.2f %s\n" "$(jq -r "(.data.quote.${1^^}.total_market_cap-.data.quote.${1^^}.altcoin_market_cap)" <<< "${CMCGLOBAL}")" "${1^^}"
	printf ' # Last 24h Volume\n'
	printf "    %'.2f %s\n" "$(jq -r "(.data.quote.${1^^}.total_volume_24h-.data.quote.${1^^}.altcoin_volume_24h)" <<< "${CMCGLOBAL}")" "${1^^}"
	printf ' # Last 24h Reported Volume\n'
	printf "    %'.2f %s\n" "$(jq -r "(.data.quote.${1^^}.total_volume_24h_reported-.data.quote.${1^^}.altcoin_volume_24h_reported)" <<< "${CMCGLOBAL}")" "${1^^}"
	printf '## Circulating Supply\n'
	printf " # BTC: %'.2f bitcoins\n" "$(bc -l <<< "$(curl -s "https://blockchain.info/q/totalbc")/100000000")"

	printf '\n## AltCoin Market Cap\n'
	printf "   %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.altcoin_market_cap" <<< "${CMCGLOBAL}")" "${1^^}"
	printf ' # Last 24h Volume\n'
	printf "    %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.altcoin_volume_24h" <<< "${CMCGLOBAL}")" "${1^^}"
	printf ' # Last 24h Reported Volume\n'
	printf "    %'.2f %s\n" "$(jq -r ".data.quote.${1^^}.altcoin_volume_24h_reported" <<< "${CMCGLOBAL}")" "${1^^}"
	
	printf '\n## Dominance\n'
	printf " # BTC: %'.2f %%\n" "$(jq -r '.data.btc_dominance' <<< "${CMCGLOBAL}")"
	printf " # ETH: %'.2f %%\n" "$(jq -r '.data.eth_dominance' <<< "${CMCGLOBAL}")"

	printf '\n## Market Cap per Coin\n'
	printf " # Bitcoin : %'.2f %s\n" "$(jq -r "((.data.btc_dominance/100)*.data.quote.${1^^}.total_market_cap)" <<< "${CMCGLOBAL}")" "${1^^}"
	printf " # Ethereum: %'.2f %s\n" "$(jq -r "((.data.eth_dominance/100)*.data.quote.${1^^}.total_market_cap)" <<< "${CMCGLOBAL}")" "${1^^}"
	#avoid erros being printed
	} 2>/dev/null
}

#-t top tickers function
tickerf() {
	#how many top cryptosd? defaults=10
	if [[ ! ${1} =~ ^[0-9]+$ ]]; then
		set -- 10 "${@}"
	fi

	#default to currency
	if [[ -z "${2}" ]]; then
		set -- "${1}" USD
	fi

	#check input to_currency
	if [[ "${2^^}" != USD ]]; then
		SYMBOLLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H 'Accept: application/json' -G 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/map' | jq '[.data[]| {"key": .slug, "value": .symbol},{"key": (.name|ascii_upcase), "value": .symbol}] | from_entries')"
		if  ! grep -qi "${2}" <<< "${TOCURLIST[@]}" && ! jq -r '.[]' <<< "${SYMBOLLIST}" | grep -iq "^${2}$"; then
			if jq -er '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
				set -- "$(jq -r '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}")"
			else
				printf 'Check TO_CURRENCY code.\n' 1>&2
				exit 1
			fi
		fi
	fi

	#get data
	TICKERJSON="$(curl -s "https://api.coinmarketcap.com/v1/ticker/?limit=${1}&convert=${2^^}")"
	
	#print json?
	if [[ -n ${PJSON} ]]; then
		printf '%s\n' "${TICKERJSON}"
		exit 0
	fi

	#test screen width
	#if stdout is redirected; skip this
	if ! [[ -t 1 ]]; then
		true
	elif test "$(tput cols)" -lt '100'; then
		COLCONF="-HMCAP(${2^^}),SUPPLY/TOTAL,UPDATE -TPRICE(${2^^}),VOL24h(${2^^})"
		printf 'OBS: More columns are needed to print more info.\n' 1>&2
	elif test "$(tput cols)" -lt '120'; then
		COLCONF='-HSUPPLY/TOTAL,UPDATE'
		printf 'OBS: More columns are needed to print more info.\n' 1>&2
	else
		COLCONF='-TSUPPLY/TOTAL,UPDATE'
	fi
	
	#altcoins vs bitcoin
	if [[ "${2^^}" = BTC ]]; then

		BTC1H="$(jq -r '.[]|select(.id == "bitcoin")|.percent_change_1h'  <<< "${TICKERJSON}")"
		BTC24H="$(jq -r '.[]|select(.id == "bitcoin")|.percent_change_24h'  <<< "${TICKERJSON}")"
		BTC7D="$(jq -r '.[]|select(.id == "bitcoin")|.percent_change_7d'  <<< "${TICKERJSON}")"
		jq -r '.[]|"\(.rank)=\(.id)=\(.symbol)=\(.price_'${2,,}')=\(((.percent_change_1h // '${BTC1H}')|tonumber)-'${BTC1H}')%=\(((.percent_change_24h // '${BTC24H}')|tonumber)-'${BTC24H}')%=\(((.percent_change_7d // '${BTC7D}')|tonumber)-'${BTC7D}')%=\(."24h_volume_'${2,,}'")=\(.market_cap_'${2,,}')=\(.available_supply)/\(.total_supply)=\(.last_updated|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' <<< "${TICKERJSON}" | sed -E 's/([0-9]+\.[0-9]{0,4})[0-9]*%/\1%/g' | column -s"=" -t  -N"RANK,ID,SYMBOL,PRICE(BTC),D1h(BTC),D24h(BTC),D7D(BTC),VOL24h(BTC),MCAP(BTC),SUPPLY/TOTAL,UPDATE" ${COLCONF}
	#coins vs USD
	else
		jq -r '.[]|"\(.rank)=\(.id)=\(.symbol)=\(.price_'"${2,,}"')=\(.percent_change_1h)%=\(.percent_change_24h)%=\(.percent_change_7d)%=\(."24h_volume_'"${2,,}"'")=\(.market_cap_'"${2,,}"')=\(.available_supply)/\(.total_supply)=\(.last_updated|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' <<< "${TICKERJSON}" | column -s"=" -t  -N"RANK,ID,SYMBOL,PRICE(${2^^}),D1h(USD),D24h(USD),D7D(USD),VOL24h(${2^^}),MCAP(${2^^}),SUPPLY/TOTAL,UPDATE" ${COLCONF}
	fi
}

#-tt winners and losers
winlosef() {
	#how many top cryptosd? defaults=10
	if [[ ! ${1} =~ ^[0-9]+$ ]]; then
		set -- 10 "${@}"
	fi

	#get data
	DATA0="$(tickerf "${1}" BTC | sed '1,2d')" 
	DATA1="$(tickerf "${1}" USD | sed '1,2d')" 
	
	#calc winners and losers by time frame
	#1h
	A1=$(awk '{print $5}'<<<"$DATA0" | grep -cv '^-')
	B1=$(awk '{print $5}'<<<"$DATA0" | grep -c '^-')
	C1=$(awk '{print $5}'<<<"$DATA1" | grep -cv '^-')
	D1=$(awk '{print $5}'<<<"$DATA1" | grep -c '^-')
	
	#24h
	A24=$(awk '{print $6}'<<<"$DATA0" | grep -cv '^-')
	B24=$(awk '{print $6}'<<<"$DATA0" | grep -c '^-')
	C24=$(awk '{print $6}'<<<"$DATA1" | grep -cv '^-')
	D24=$(awk '{print $6}'<<<"$DATA1" | grep -c '^-')
	
	#7 days
	A7=$(awk '{print $7}'<<<"$DATA0" | grep -cv '^-')
	B7=$(awk '{print $7}'<<<"$DATA0" | grep -c '^-')
	C7=$(awk '{print $7}'<<<"$DATA1" | grep -cv '^-')
	D7=$(awk '{print $7}'<<<"$DATA1" | grep -c '^-')
	
	#winners vs losers against btc/usd
	echo 'Winners and losers'
	echo "Top ${1} coins"
	echo
	echo 'Alts vs BTC'
	column -et -s= -NTIME,WIN,LOSE -RTIME,WIN,LOSE <<-!
		1H=$A1=$B1
		24H=$A24=$B24
		7D=$A7=$B7
		!
	echo
	echo "Alts vs USD"
	#winners vs losers against btc/[to_currency]
	column -et -s= -NTIME,WIN,LOSE -RTIME,WIN,LOSE <<-!
		1H=$C1=$D1
		24H=$C24=$D24
		7D=$C7=$D7
		!
		:<<-!
		POS=${A1}=${B1}=${A24}=${B24}=${A7}=${B7}
		NEG=${C1}=${D1}=${C24}=${D24}=${C7}=${C7}
		!
}

#-l print currency lists
listsf() {
	printf '\n=============CRYPTOCURRENCIES============\n'
	curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H 'Accept: application/json' -G 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/map' | jq -r '.data[] | "\(.id)=\(.symbol)=\(.name)"' | column -s'=' -et -N 'ID,SYMBOL,NAME'
	printf '\n\n===========BANK CURRENCIES===========\n'
	printf '%s\n' "${OTHERCUR}" | column -s'=' -et -N'ID,SYMBOL,NAME'
}

#-a api status
apif() {
	PAGE="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H 'Accept: application/json'  'https://pro-api.coinmarketcap.com/v1/key/info')"
	#print json?
	if [[ -n ${PJSON} ]]; then
		printf '%s\n' "${PAGE}"
		exit 0
	fi
	#print heading and status page
	printf 'API key: %s\n\n' "${CMCAPIKEY}"
	tr -d '{}",' <<<"${PAGE}"| sed -e 's/^\s*\(.*\)/\1/' -e '1,/data/d' -e 's/_/ /g'| sed -e '/^$/N;/^\n$/D' | sed -e 's/^\([a-z]\)/\u\1/g'
}

#precious metals in grams?
ozgramf() {
	#precious metals - ounce to gram
	if [[ -n "${GRAMOPT}" ]]; then
		if grep -qi -e 'XAU' -e 'XAG' -e 'XPT' -e 'XPD' <<<"${1}"; then
			FMET=1
		fi
		if grep -qi -e 'XAU' -e 'XAG' -e 'XPT' -e 'XPD' <<<"${2}"; then
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


#parse options
while getopts ':0123456789ablmghjs:tvp' opt; do
	case ${opt} in
		( [0-9] ) #scale, same as '-sNUM'
			SCL="${SCL}${opt}"
			;;
		( a ) #api key status
			APIOPT=1
			;;
		( b ) #hack central bank currency rates
			BANK=1
			;;
		( g ) #gram opt
			GRAMOPT=1
			;;
		( j ) #debug: print json
			PJSON=1
			;;
		( l ) #list available currencies
			LISTS=1
			;;
		( m ) #market capital function
			MCAP=1
			;;
		( h ) #show help
			echo -e "${HELP_LINES}"
			exit 0
			;;
		( p ) #print timestamp with result
			TIMEST=1
			;;
		( s ) #decimal plates
			SCL="${OPTARG}"
			;;
		( t ) #tickers for crypto currencies
		      #winners and losers
			[[ -z "${TICKEROPT}" ]] && TICKEROPT=1 || TICKEROPT=2
			;;
		( v ) #script version
			grep -m1 '# v' "${0}"
			exit 0
			;;
		( \? )
			printf 'Invalid option: -%s\n' "$OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

#check for api key
if [[ -z "${CMCAPIKEY}" ]]; then
	printf 'Please create a free API key and add it to the script source-code or set it as an environment variable.\n' 1>&2
	exit 1
fi

#test for must have packages
if [[ -z "${CCHECK}" ]]; then
	if ! command -v jq &>/dev/null; then
		printf 'JQ is required.\n' 1>&2
		exit 1
	fi
	if ! command -v curl &>/dev/null; then
		printf 'cURL is required.\n' 1>&2
		exit 1
	fi
	CCHECK=1
	export CCHECK
fi

#set custom scale
if [[ -z ${SCL} ]]; then
	SCL="${SCLDEFAULTS}"
fi

#call opt functions
if [[ "${TICKEROPT}" = 1 ]]; then
	tickerf "${@}"
	exit
elif [[ "${TICKEROPT}" = 2 ]]; then
	winlosef "${@}"
	exit
elif [[ -n "${MCAP}" ]]; then
	mcapf "${@}"
	exit
elif [[ -n "${APIOPT}" ]]; then
	apif
	exit
fi

#set equation arguments
#if first argument does not have numbers
if ! [[ "${1}" =~ [0-9] ]]; then
	set -- 1 "${@}"
#if amount is not a valid expression for bc
elif [[ -z "$(bc -l <<< "${1}" 2>/dev/null)" ]]; then
	printf "Invalid expression in 'AMOUNT'\n" 1>&2
	exit 1
fi
if [[ -z ${2} ]]; then
	set -- "${1}" ${DEFCUR^^}
fi
if [[ -z ${3} ]]; then
	set -- "${1}" "${2}" ${DEFTOCUR^^}
fi

#check currencies
#get data if empty
if [[ -z "${SYMBOLLIST}" ]]; then
	SYMBOLLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H 'Accept: application/json' -G 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/map' | jq '[.data[]| {"key": .slug, "value": .symbol},{"key": (.name|ascii_upcase), "value": .symbol}] | from_entries')"
	export SYMBOLLIST
fi
#check
if [[ -z "${BANK}" ]]; then
	#check from_currency
	if ! jq -er '.[]' <<< "${SYMBOLLIST}" | grep -iq "^${2}$"; then
		if jq -er '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
			set -- "${1}" "$(jq -r '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}")" "${3}"
		else
			printf 'Err: invalid FROM_CURRENCY -- %s\n' "${2^^}" 1>&2
			exit 1
		fi
	fi
	#check to_currency
	if  ! grep -qi "${3}" <<< "${TOCURLIST[@]}" && ! jq -r '.[]' <<< "${SYMBOLLIST}" | grep -iq "^${3}$"; then
		if jq -er '.["'"${3^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
			set -- "${1}" "${2}" "$(jq -r '.["'"${3^^}"'"]' <<< "${SYMBOLLIST}")"
		else
			printf 'Err: invalid TO_CURRENCY -- %s\n' "${3^^}" 1>&2
			exit 1
		fi
	fi
fi

#call opt functions
if [[ -n "${BANK}" ]]; then
	bankf "${@}"
elif [[ -n "${LISTS}" ]]; then
	listsf
#default function
#currency converter
else
	#get rate json
	CMCJSON=$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H 'Accept: application/json' -d "&symbol=${2^^}&convert=${3^^}" -G 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest')
	
	#print json?
	if [[ -n ${PJSON} ]]; then
		printf '%s\n' "${CMCJSON}"
		exit 0
	fi
	
	#get pair rate
	CMCRATE=$(jq -r ".data[] | .quote.${3^^}.price" <<< "${CMCJSON}" | sed 's/e/*10^/g') 
	
	#print json timestamp ?
	if [[ -n ${TIMEST} ]]; then
	JSONTIME=$(jq -r ".data.${2^^}.quote.${3^^}.last_updated" <<< "${CMCJSON}")
		date --date "$JSONTIME" '+## %FT%T%Z'
	fi
	
	#make equation and calculate result
	#metals in grams?
	ozgramf "${2}" "${3}"
	
	RESULT="$(bc -l <<< "((${1})*${CMCRATE})${GRAM}${TOZ}")"
	
	printf "%.${SCL}f\n" "${RESULT}"
fi

