#!/bin/bash
# cmc.sh -- coinmarketcap.com api access
# v0.8.3  feb/2020  by mountaineerbr

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
export LC_NUMERIC='en_US.UTF-8'

#troy ounce to gram ratio
TOZ='31.1034768' 

#script location
SCRIPT="${0}"

#number of lines to get nokeyf resources
#from end of script
ENDLINES=2310

#manual and help
#usage: $ cmc.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
	Cmc.sh -- Currency Converter and Market Information
		  Coinmarketcap.com API Access


SYNOPSIS
	cmc.sh [-p|-sNUM] [AMOUNT] 'FROM_CURRENCY' [TO_CURRENCY]
	
	cmc.sh -b [-gp] [-sNUM] [AMOUNT] 'FROM_CURRENCY' [TO_CURRENCY]

	cmc.sh -m [TO_CURRENCY]

	cmc.sh -t 'SYMBOL' [TO_CURRENCY]
	
	cmc.sh -tt [NUM] [TO_CURRENCY]
	
	cmc.sh -w [NUM]
	
	cmc.sh [-adhlv]


DESCRIPTION
	This programme fetches updated currency rates from <coinmarketcap.com>.
	It can convert any amount of one supported crypto currency into another.
	CMC also converts crypto to ~93 central bank currencies, gold and silver.

	If you do not have got a free api key, the default currency convertion 
	option will work, as well the single ticker option '-t', but other func-
	tions will not.

	You can see a list of supported currencies running the script with the
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
	precious metals. Nonetheless, it is useful to learn how to do this con-
	vertion manually. 
	
	It is useful to define a variable with the gram to troy oz ratio in your
	\".bashrc\" to work with precious metals. I suggest a variable called 
	TOZ that will contain the GRAM/OZ constant:
	
		TOZ=\"${TOZ}\"
	
	
	To get \e[0;33;40mAMOUNT\033[00m of EUR in grams of Gold, just multiply AMOUNT by
	the \"GRAM/OUNCE\" constant.
	
		$ cmc.sh -b \"\e[0;33;40mAMOUNT\033[00m*31.1\" eur xau 
	
	
	One EUR in grams of Gold:
	
		$ cmc.sh -b \"\e[1;33;40m1\033[00m*31.1\" eur xau 
		
		$ cmc.sh -b -g 1 eur xau 
	
	
	To get \e[0;33;40mAMOUNT\033[00m of grams of Gold in EUR, just divide AMOUNT by
	the \"GRAM/OUNCE\" constant.
	
		$ cmc.sh -b \"\e[0;33;40m[amount]\033[00m/31.1\" xau usd 
	
	
	One gram of Gold in EUR:
			
		$ cmc.sh -b \"\e[1;33;40m1\033[00m/31.1\" xau eur 
		
		$ cmc.sh -b -g 1 xau eur 
	
	
	To convert (a) from gold to crypto currencies, (b) from bank currencies
	to gold	or (c) from gold to bank curren-cies, do not forget to use the 
	option \"-b\"!


API KEY
	Please take a little time to register at <https://coinmarketcap.com/api/>
	for a free API key and add it to the 'CMCAPIKEY' variable in the script 
	source code or set it as an environment variable.

	Only the default currency convertion option works without an api key.


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

			$ cmc.sh -tt 20 eur
			
			
			TIP: use Less with opion -S (--chop-long-lines) or the 
			'Most' pager for scrolling horizontally:

			$ cmc.sh -tt 100 btc | less -S


		(7)    One Bitcoin in troy ounces of Gold:
					
			$ cmc.sh 1 btc xau 


OPTIONS
		-NUM 	Shortcut for scale setting, same as '-sNUM'.

		-a 	  API key status.

		-b 	  Bank currency function, converts between bank curren-
			  cies.

		-d 	  Print dominance stats.

		-g 	  Use grams instead of troy ounces; only for precious
			  metals.
		
		-h 	  Show this help.

		-j 	  Debugging, print JSON.

		-l 	  List supported currencies.

		-m [TO_CURRENCY]
			  Market ticker.

		-s [NUM]  Set scale (decimal plates) for some opts; defaults=${SCLDEFAULTS}.

		-p 	  Print timestamp, if available.
		
		-t 'SYMBOL' [TO_CURRENCY]
			Single ticker, optionally set quote symbol (public api).

		-tt [NUM] [TO_CURRENCY]
			  Tickers for top NUM cryptos, optionally set quote 
			  symbol (only affects some data); defaults=10; max 100.
		
		-v 	  Script version.
		
		-w [NUM]
			  Winners and losers against BTC and USD for top NUM 
			  cryptos, including BTC/BTC; defaults=10, max=100."

FIATCUR="2781=USD=$=United States Dollar
2782=AUD=$=Australian Dollar
2783=BRL=R$=Brazilian Real
2784=CAD=$=Canadian Dollar
2785=CHF=Fr=Swiss Franc
2786=CLP=$=Chilean Peso
2787=CNY=¥=Chinese Yuan
2788=CZK=Kč=Czech Koruna
2789=DKK=kr=Danish Krone
2790=EUR=€=Euro
2791=GBP=£=Pound Sterling
2792=HKD=$=Hong Kong Dollar
2793=HUF=Ft=Hungarian Forint
2794=IDR=Rp=Indonesian Rupiah
2795=ILS=₪=Israeli New Shekel
2796=INR=₹=Indian Rupee
2797=JPY=¥=Japanese Yen
2798=KRW=₩=South Korean Won
2799=MXN=$=Mexican Peso
2800=MYR=RM=Malaysian Ringgit
2801=NOK=kr=Norwegian Krone
2802=NZD=$=New Zealand Dollar
2803=PHP=₱=Philippine Peso
2804=PKR=₨=Pakistani Rupee
2805=PLN=zł=Polish Złoty
2806=RUB=₽=Russian Ruble
2807=SEK=kr=Swedish Krona
2808=SGD=$=Singapore Dollar
2809=THB=฿=Thai Baht
2810=TRY=₺=Turkish Lira
2811=TWD=$=New Taiwan Dollar
2812=ZAR=Rs=South African Rand
2813=AED=د.إ=United Arab Emirates Dirham
2814=BGN=лв=Bulgarian Lev
2815=HRK=kn=Croatian Kuna
2816=MUR=₨=Mauritian Rupee
2817=RON=lei=Romanian Leu
2818=ISK=kr=Icelandic Króna
2819=NGN=₦=Nigerian Naira
2820=COP=$=Colombian Peso
2821=ARS=$=Argentine Peso
2822=PEN=S/.=Peruvian Sol
2823=VND=₫=Vietnamese Dong
2824=UAH=₴=Ukrainian Hryvnia
2832=BOB=Bs.=Bolivian Boliviano
3526=ALL=L=Albanian Lek
3527=AMD=֏=Armenian Dram
3528=AZN=₼=Azerbaijani Manat
3529=BAM=KM=Bosnia-Herzegovina Convertible Mark
3530=BDT=৳=Bangladeshi Taka
3531=BHD=.د.ب=Bahraini Dinar
3532=BMD=$=Bermudan Dollar
3533=BYN=Br=Belarusian Ruble
3534=CRC=₡=Costa Rican Colón
3535=CUP=$=Cuban Peso
3536=DOP=$=Dominican Peso
3537=DZD=د.ج=Algerian Dinar
3538=EGP=£=Egyptian Pound
3539=GEL=₾=Georgian Lari
3540=GHS=₵=Ghanaian Cedi
3541=GTQ=Q=Guatemalan Quetzal
3542=HNL=L=Honduran Lempira
3543=IQD=ع.د=Iraqi Dinar
3544=IRR=﷼=Iranian Rial
3545=JMD=$=Jamaican Dollar
3546=JOD=د.ا=Jordanian Dinar
3547=KES=Sh=Kenyan Shilling
3548=KGS=с=Kyrgystani Som
3549=KHR=៛=Cambodian Riel
3550=KWD=د.ك=Kuwaiti Dinar
3551=KZT=₸=Kazakhstani Tenge
3552=LBP=ل.ل=Lebanese Pound
3553=LKR=Rs=Sri Lankan Rupee
3554=MAD=د.م.=Moroccan Dirham
3555=MDL=L=Moldovan Leu
3556=MKD=ден=Macedonian Denar
3557=MMK=Ks=Myanma Kyat
3558=MNT=₮=Mongolian Tugrik
3559=NAD=$=Namibian Dollar
3560=NIO=C$=Nicaraguan Córdoba
3561=NPR=₨=Nepalese Rupee
3562=OMR=ر.ع.=Omani Rial
3563=PAB=B/.=Panamanian Balboa
3564=QAR=ر.ق=Qatari Rial
3565=RSD=дин.=Serbian Dinar
3566=SAR=ر.س=Saudi Riyal
3567=SSP=£=South Sudanese Pound
3568=TND=د.ت=Tunisian Dinar
3569=TTD=$=Trinidad and Tobago Dollar
3570=UGX=Sh=Ugandan Shilling
3571=UYU=$=Uruguayan Peso
3572=UZS=so'm=Uzbekistan Som
3573=VES=Bs.=Sovereign Bolivar"

METALS="3575=XAU=Gold Troy Ounce
3574=XAG=Silver Troy Ounce
3577=XPT=Platinum Ounce
3576=XPD=Palladium Ounce"

FIATCODES=(USD AUD BRL CAD CHF CLP CNY CZK DKK EUR GBP HKD HUF IDR ILS INR JPY KRW MXN MYR NOK NZD PHP PKR PLN RUB SEK SGD THB TRY TWD ZAR AED BGN HRK MUR RON ISK NGN COP ARS PEN VND UAH BOB ALL AMD AZN BAM BDT BHD BMD BYN CRC CUP DOP DZD EGP GEL GHS GTQ HNL IQD IRR JMD JOD KES KGS KHR KWD KZT LBP LKR MAD MDL MKD MMK MNT NAD NIO NPR OMR PAB QAR RSD SAR SSP TND TTD UGX UYU UZS VES XAU XAG XPD XPT)

#check for error response
#errf() { if [[ "$(jq -r '.status.error_code' <<<"${JSON}")" != 0 ]]; then jq -r '.status.error_message' <<<${JSON}"; exit 1; fi;}

#check for api key
keycheckf() {
	if [[ -z "${CMCAPIKEY}" ]] && [[ -n "${*}" ]]; then
		printf 'Please create a free API key and add it to the script source-code or set it as an environment variable.\n' 1>&2
		exit 1
	fi
}

#check currencies
checkcurf() {
	#get data if empty
	if [[ -z "${SYMBOLLIST}" ]]; then
		SYMBOLLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H 'Accept: application/json' -G 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/map' | jq '[.data[]| {"key": .slug, "value": .symbol},{"key": (.name|ascii_upcase), "value": .symbol}] | from_entries')"
		export SYMBOLLIST
	fi
	
	if [[ -z "${FIATLIST}" ]]; then
		FIATLIST="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -d "" -G 'https://pro-api.coinmarketcap.com/v1/fiat/map' | jq -r '.data[].symbol')"
		FIATLIST+="$(printf '\n%s\n' "${FIATCODES[@]}")"
		export FIATLIST
	fi

	#check from_currency
	if [[ -n "${2}" ]] && ! jq -r '.[]' <<< "${SYMBOLLIST}" | grep -iqx "${2}"; then
		if jq -er '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
			set -- "${1}" "$(jq -r '.["'"${2^^}"'"]' <<< "${SYMBOLLIST}")" "${3}"
		else
			printf 'Err: invalid FROM_CURRENCY -- %s\n' "${2^^}" 1>&2
			exit 1
		fi
	fi

	#check to_currency
	if [[ -n "${3}" ]]; then
		#reinvert lists for no api key and single ticker opts..
		[[ -z "${CMCAPIKEY}" ]] && SYMBOLLIST="$(jq -r '[keys_unsorted[] as $k | {"key": .[$k], "value": $k}] | from_entries' <<<"${SYMBOLLIST}")"
		
		#check
		if ! grep -qix "${3}" <<< "${FIATLIST}" && ! jq -r '.[]' <<< "${SYMBOLLIST}" | grep -iqx "${3}"; then
			if jq -er '.["'"${3^^}"'"]' <<< "${SYMBOLLIST}" &>/dev/null; then
				set -- "${1}" "${2}" "$(jq -r '.["'"${3^^}"'"]' <<< "${SYMBOLLIST}")"
			else
				printf 'Err: invalid TO_CURRENCY -- %s\n' "${3^^}" 1>&2
				exit 1
			fi
		fi
	fi

	#export new args
	ARGS=(${@})
}
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
	
	#print timestamp?
	if [[ -n "${TIMEST}" ]]; then
		printf '%s (from currency)\n' "${BTCBANKHEAD}"
		printf '%s ( to  currency)\n' "${BTCTOCURHEAD}"
	fi

	#precious metals in grams?
	ozgramf "${2}" "${3}"

	#calculate result & print result 
	RESULT="$(bc -l <<< "(((${1})*${BTCTOCURTAIL})/${BTCBANKTAIL})${GRAM}${TOZ}")"
	
	#check for errors
	if [[ -z "${RESULT}" ]]; then
		#printf 'Err: invalid currency code(s)\n' 1>&2
		exit 1
	else
		printf "%.${SCL}f\n" "${RESULT}"
	fi
}

#market capital function
mcapf() {
	#check for input to_currency
	if [[ "${1^^}" =~ ^(USD|BRL|CAD|CNY|EUR|GBP|JPY|BTC|ETH|XRP|LTC|EOS|USDT)$ ]]; then
		true	
	elif [[ -n "${DOMOPT}" ]] || [[ -z "${1}" ]]; then
		set -- USD
	elif [[ -n "${1}" ]]; then
		#check to_currency (convert prices)
		checkcurf '' '' "${1}" && set -- "${ARGS[@]}"
	fi

	#get market data
	CMCGLOBAL=$(curl -s -H "X-CMC_PRO_API_KEY:  ${CMCAPIKEY}" -H 'Accept: application/json' -d "convert=${1^^}" -G 'https://pro-api.coinmarketcap.com/v1/global-metrics/quotes/latest')
	
	#print json?
	if [[ -n ${PJSON} ]]; then
		printf '%s\n' "${CMCGLOBAL}"
		exit 0
	fi

	#-d dominance opt
	if [[ -n "${DOMOPT}" ]]; then
		printf "BTC: %'.2f %%\n" "$(jq -r '.data.btc_dominance' <<< "${CMCGLOBAL}")"
		printf "ETH: %'.2f %%\n" "$(jq -r '.data.eth_dominance' <<< "${CMCGLOBAL}")"
		exit 0
	fi

	#timestamp
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

#no api key funct
nokeyf() {
	if [[ -z "${BANK}" ]]; then
		#export local lists
		#these jsons has a different structure than normal checking
		SYMBOLLIST="$(tail -${ENDLINES} "${SCRIPT}")"
		export SYMBOLLIST
		FIATLIST="$(printf '%s\n' "${FIATCODES[@]}")"
		export FIATLIST

		#check from_currency
		checkcurf "${@}" && set -- "${ARGS[@]}"

		#get data
		CMCJSON="$(curl -s "https://api.coinmarketcap.com/v1/ticker/${2,,}/?convert=${3^^}")"
		
		#print json?
		if [[ -n ${PJSON} ]]; then
			printf '%s\n' "${CMCJSON}"
			exit 0
		fi
		
		#get pair rate
		CMCRATE=$(jq -r ".[].price_${3,,}" <<< "${CMCJSON}" | sed 's/e/*10^/') 

		#print json timestamp ?
		if [[ -n ${TIMEST} ]]; then
			JSONTIME=$(jq -r '.[].last_updated' <<< "${CMCJSON}")
			date -d@"$JSONTIME" '+#%FT%T%Z'
		fi
		
		#make equation and calculate result
		#metals in grams?
		ozgramf "${2}" "${3}"
		
		RESULT="$(bc -l <<< "((${1})*${CMCRATE})${GRAM}${TOZ}")"
	else
		#set some parameters
		TIMESTX=1
		GRAMOPT2="${GRAMOPT}"
		unset BANK
		unset GRAMOPT

		#get rates
		BTCBANK="$(nokeyf 1 BTC "${2^^}")"
		BTCBANKHEAD=$(head -n1 <<< "${BTCBANK}") # Timestamp
		BTCBANKTAIL=$(tail -n1 <<< "${BTCBANK}") # Rate
		
		BTCTOCUR="$(nokeyf 1 BTC "${3^^}")"
		BTCTOCURHEAD=$(head -n1 <<< "${BTCTOCUR}") # Timestamp
		BTCTOCURTAIL=$(tail -n1 <<< "${BTCTOCUR}") # Rate
		
		#set some parameters
		GRAMOPT="${GRAMOPT2}"

		#print timestamp?
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
			printf 'Err: bad code(s).\n' 1>&2
			exit 1
		fi
	fi
	
	printf "%.${SCL}f\n" "${RESULT}"

	exit
}

#-tt top tickers function
tickerf() {
	if [[ "${TICKEROPT}" -eq 1 ]]; then
		#check for api key
		keycheckf 1
		
		#how many top cryptosd? defaults=10
		if [[ ! ${1} =~ ^[0-9]+$ ]]; then
			set -- 10 "${@}"
		fi

		#default to currency
		if [[ -z "${2}" ]]; then
			set -- "${1}" USD
		fi

		#check to_currency (convert price)
		checkcurf "${1}" '' "${2}" && set -- "${ARGS[@]}"

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
			COLCONF="-HMcap${2^^},SUPPLY/TOTAL,UPDATE -TPrice${2^^},VOL24h${2^^}"
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
			
			jq -r '.[]|"\(.rank)=\(.id)=\(.symbol)=\(.price_'${2,,}')=\(((.percent_change_1h // '${BTC1H}')|tonumber)-'${BTC1H}')%=\(((.percent_change_24h // '${BTC24H}')|tonumber)-'${BTC24H}')%=\(((.percent_change_7d // '${BTC7D}')|tonumber)-'${BTC7D}')%=\(."24h_volume_'${2,,}'")=\(.market_cap_'${2,,}')=\(.available_supply)/\(.total_supply)=\(.last_updated|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' <<< "${TICKERJSON}" | sed -E 's/([0-9]+\.[0-9]{0,4})[0-9]*%/\1%/g' | column -s"=" -t  -N"R,ID,SYMBOL,PriceBTC,1hBTC%,24hBTC%,7dBTC%,VOL24hBTC,McapBTC,SUPPLY/TOTAL,UPDATE" ${COLCONF}
		
		#coins vs USD
		else
			jq -r '.[]|"\(.rank)=\(.id)=\(.symbol)=\(.price_'"${2,,}"')=\(.percent_change_1h)%=\(.percent_change_24h)%=\(.percent_change_7d)%=\(."24h_volume_'"${2,,}"'")=\(.market_cap_'"${2,,}"')=\(.available_supply)/\(.total_supply)=\(.last_updated|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' <<< "${TICKERJSON}" | column -s"=" -t  -N"R,ID,SYMBOL,Price${2^^},1hUSD%,24hUSD%,7dUSD%,VOL24h${2^^},Mcap${2^^},SUPPLY/TOTAL,UPDATE" ${COLCONF}
		
		fi
	#single ticker -- public api
	else
		#check ticker symbol
		if [[ "${1}" =~ ^[0-9]+$ ]]; then
			set -- ${@:2}
		fi

		#default ticker symbol
		if [[ -z "${1}" ]]; then 
			set -- BTC
		fi

		#default to currency
		if [[ -z "${2}" ]]; then 
			set -- "${1}" USD
		fi

		#export local lists
		#this jsons has a different structure than normal checking
		SYMBOLLIST="$(tail -${ENDLINES} "${SCRIPT}")"
		export SYMBOLLIST
		
		if [[ -z "${CMCAPIKEY}" ]]; then
			FIATLIST="$(printf '%s\n' "${FIATCODES[@]}")"
			export FIATLIST
		fi

		#check from currency
		FROMCURSYMBOL="${1}"
		TOCURSYMBOL="${2}"
		checkcurf '' "${@}" && set -- "${ARGS[@]}" 
		
		#get data
		CMCJSON="$(curl -s "https://api.coinmarketcap.com/v1/ticker/${1,,}/?convert=${2^^}")"
		
		#print json?
		if [[ -n ${PJSON} ]]; then
			printf '%s\n' "${CMCJSON}"
			exit 0
		fi
		
		#format ticker
		jq -r '.[]|
			"Ticker",
			(.last_updated|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z")),
			"",
			"Id_____: \(.id)",
			"Name___: \(.name)",
			"Symbol_: \(.symbol)",
			"Rank___: \(.rank)",
			"",
			"Supply",
			"Availab: \(.available_supply)",
			"Total__: \(.total_supply)",
			"Max____: \(.max_supply)",
			"",
			"MktCap_: \(.market_cap_usd) USD",
			"MktCap_: \(.market_cap_'${TOCURSYMBOL,,}'//empty) '${TOCURSYMBOL^^}'",
			"",
			"24HVol_: \(."24h_volume_usd") USD",
			"24HVol_: \(."24h_volume_'${TOCURSYMBOL,,}'"//empty)  '${TOCURSYMBOL^^}'",
			"",
			"Chg_1H_: \(.percent_change_1h) %",
			"Chg_24H: \(.percent_change_24h) %",
			"Chg_7D_: \(.percent_change_7d) %",
			"",
			"Price",
			"'${FROMCURSYMBOL^^}'BTC_: \(.price_btc)",
			"'${FROMCURSYMBOL^^}'USD_: \(.price_usd)",
			"'${TOCURSYMBOL^^}${FROMCURSYMBOL^^}'_: \(.price_'${TOCURSYMBOL,,}'//empty)"
			' <<<"${CMCJSON}"
	fi
}

#-w winners and losers
winlosef() {
	#how many top cryptosd? defaults=10
	if [[ ! ${1} =~ ^[0-9]+$ ]]; then
		set -- 10 "${@}"
	fi

	#get data
	DATA0="$(curl -s "https://api.coinmarketcap.com/v1/ticker/?limit=${1}&convert=BTC")"
	DATA1="$(curl -s "https://api.coinmarketcap.com/v1/ticker/?limit=${1}&convert=USD")"

	#process data
	BTC1H="$(jq -r '.[]|select(.id == "bitcoin")|.percent_change_1h'  <<< "${DATA0}")"
	DATA01H="$(jq -r ".[]|((.percent_change_1h|tonumber)-${BTC1H})" <<<"${DATA0}")"
	DATA11H="$(jq -r '.[].percent_change_1h' <<<"${DATA1}")"

	BTC24H="$(jq -r '.[]|select(.id == "bitcoin")|.percent_change_24h'  <<< "${DATA0}")"
	DATA024H="$(jq -r ".[]|((.percent_change_24h|tonumber)-${BTC24H})" <<<"${DATA0}")"
	DATA124H="$(jq -r '.[].percent_change_24h' <<<"${DATA1}")"
	
	BTC7D="$(jq -r '.[]|select(.id == "bitcoin")|.percent_change_7d'  <<< "${DATA0}")"
	DATA07D="$(jq -r ".[]|((.percent_change_7d|tonumber)-${BTC7D})" <<<"${DATA0}")"
	DATA17D="$(jq -r '.[].percent_change_7d' <<<"${DATA1}")"


	#calc winners and losers by time frame
	#1h
	A1=$(grep -cv '^-' <<<"${DATA01H}")
	B1=$(grep -c '^-'  <<<"${DATA01H}")
	C1=$(grep -cv '^-' <<<"${DATA11H}")
	D1=$(grep -c '^-'  <<<"${DATA11H}")
	
	#24h
	A24=$(grep -cv '^-' <<<"${DATA024H}")
	B24=$(grep -c '^-'  <<<"${DATA024H}")
	C24=$(grep -cv '^-' <<<"${DATA124H}")
	D24=$(grep -c '^-'  <<<"${DATA124H}")
	
	#7 days
	A7=$(grep -cv '^-' <<<"${DATA07D}")
	B7=$(grep -c '^-'  <<<"${DATA07D}")
	C7=$(grep -cv '^-' <<<"${DATA17D}")
	D7=$(grep -c '^-'  <<<"${DATA17D}")
	
	#winners vs losers against btc/usd tables
	VSBTC=$(column -et -s= -NRNG,WIN,LOSE -RRNG,WIN,LOSE <<-!
		1H=$A1=$B1
		24H=$A24=$B24
		7D=$A7=$B7
		!
		)
	VSUSD=$(column -et -s= -NRNG,WIN,LOSE -RRNG,WIN,LOSE <<-!
		1H=$C1=$D1
		24H=$C24=$D24
		7D=$C7=$D7
		!
		)
	
	#format tables
	cat <<-!
	Winners and losers
	Top ${1} coins
	
	All vs BTC
	${VSBTC}

	All vs USD
	${VSUSD}
	!
}

#-l print currency lists
listsf() {
	if [[ -n "${CMCAPIKEY}" ]]; then
		#get data
		PAGE="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H 'Accept: application/json' -G 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/map')"
		
		#print json?
		if [[ -n ${PJSON} ]]; then
			printf '%s\n' "${PAGE}"
			exit 0
		fi

		#make table
		printf 'CRYPTOCURRENCIES\n'		
		LIST="$(jq -r '.data[] | "\(.id)=\(.symbol)=\(.name)"' <<<"${PAGE}")"
		column -s'=' -et -N 'ID,SYMBOL,NAME' <<<"${LIST}"
		
		printf '\nBANK CURRENCIES\n'
		LIST2="$(curl -s -H "X-CMC_PRO_API_KEY: ${CMCAPIKEY}" -H "Accept: application/json" -d "" -G https://pro-api.coinmarketcap.com/v1/fiat/map | jq -r '.data[]|"\(.id)=\(.symbol)=\(.sign)=\(.name)"')"
		column -s'=' -et -N'ID,SYMBOL,SIGN,NAME' <<<"${LIST2}"
		column -s'=' -et -N'ID,SYMBOL,NAME' <<<"${METALS}"

		printf 'Cryptos: %s\n' "$(wc -l <<<"${LIST}")"
		printf 'BankCur: %s\n' "$(wc -l <<<"${LIST2}")"
		printf 'Metals : %s\n' "$(wc -l <<<"${METALS}")"
	else
		printf 'CRYPTOCURRENCIES\n'		
		LIST="$(pr -mJ -t <(tail -${ENDLINES} "${SCRIPT}" | jq -r 'keys_unsorted[]') <(tail -${ENDLINES} "${SCRIPT}" | jq -r '.[]') | sort)"
		column -s$'\t' -et -N 'SYMBOL,NAME' <<<"${LIST}"
		
		printf '\nBANK CURRENCIES\n'
		printf '%s\n' "${FIATCUR}" | column -s'=' -et -N'ID,SYMBOL,SIGN,NAME'
		column -s'=' -et -N'ID,SYMBOL,NAME' <<<"${METALS}"

		printf 'Cryptos: %s\n' "$(wc -l <<<"${LIST}")"
		printf 'BankCur: %s\n' "$(wc -l <<<"${FIATCUR}")"
		printf 'Metals : %s\n' "$(wc -l <<<"${METALS}")"
		printf 'No api key. Currency list may be outdated.\n' 1>&2
	fi

	exit
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
while getopts ':0123456789abdlmghjs:tvpw' opt; do
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
		( d ) #dominance only opt
			DOMOPT=1
			MCAP=1
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
			[[ -z "${TICKEROPT}" ]] && TICKEROPT=3 || TICKEROPT=1
			;;
		( v ) #script version
			grep -m1 '# v' "${0}"
			exit 0
			;;
		( w ) #winners and losers
			TICKEROPT=2
			;;
		( \? )
			printf 'Invalid option: -%s\n' "$OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

#check for api key for some opts
keycheckf "${APIOPT}${DOMOPT}${MCAP}"

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
if [[ "${TICKEROPT}" =~ (1|3) ]]; then
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
	printf 'Err: invalid expression in AMOUNT\n' 1>&2
	exit 1
fi
if [[ -z ${2} ]]; then
	set -- "${1}" ${DEFCUR^^}
fi
if [[ -z ${3} ]]; then
	set -- "${1}" "${2}" ${DEFTOCUR^^}
fi

#check currencies
if [[ -n "${CMCAPIKEY}" ]]; then
	[[ -z "${BANK}" ]] && checkcurf "${@}" && set -- "${ARGS[@]}"
else
	[[ -n "${LISTS}" ]] && listsf
	nokeyf "${@}"
	exit
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
	if [[ -n ${TIMEST} ]] || [[ -n ${TIMESTX} ]]; then
		JSONTIME=$(jq -r ".data.${2^^}.quote.${3^^}.last_updated" <<< "${CMCJSON}")
		date --date "$JSONTIME" '+#%FT%T%Z'
	fi
	
	#make equation and calculate result
	#metals in grams?
	ozgramf "${2}" "${3}"
	
	RESULT="$(bc -l <<< "((${1})*${CMCRATE})${GRAM}${TOZ}")"
	
	printf "%.${SCL}f\n" "${RESULT}"
fi

exit

#cmc data to convert from symbol to id
#without an api key






{
  "BTC": "bitcoin",
  "LTC": "litecoin",
  "NMC": "namecoin",
  "TRC": "terracoin",
  "PPC": "peercoin",
  "NVC": "novacoin",
  "FTC": "feathercoin",
  "MNC": "maincoin",
  "FRC": "freicoin",
  "IXC": "ixcoin",
  "BTB": "bitball",
  "DGC": "digitalcoin",
  "GLC": "goldcoin",
  "PXC": "pixie-coin",
  "MEC": "megacoin",
  "IFC": "infinitecoin",
  "XPM": "primecoin",
  "ANC": "anoncoin",
  "CSC": "casinocoin",
  "EMD": "emerald",
  "XRP": "xrp",
  "QRK": "quark",
  "ZET": "zetacoin",
  "SXC": "sexcoin",
  "TAG": "tagcoin",
  "FLO": "flo",
  "NXT": "nxt",
  "UNO": "unobtanium",
  "DTC": "datacoin",
  "DEM": "deutsche-emark",
  "DOGE": "dogecoin",
  "DMD": "diamond",
  "ORB": "orbitcoin",
  "OMNI": "omni",
  "TIPS": "fedoracoin",
  "MOON": "mooncoin",
  "DIME": "dimecoin",
  "42": "42-coin",
  "VTC": "vertcoin",
  "DGB": "digibyte",
  "SMC": "smartcoin",
  "RDD": "reddcoin",
  "POT": "potcoin",
  "BLC": "blakecoin",
  "MAX": "maxcoin",
  "DASH": "dash",
  "XCP": "counterparty",
  "MINT": "mintcoin",
  "ARI": "aricoin",
  "DOPE": "dopecoin",
  "AUR": "auroracoin",
  "PTC": "pesetacoin",
  "PND": "pandacoin-pnd",
  "BLK": "blackcoin",
  "PHO": "photon",
  "ZEIT": "zeitcoin",
  "XMY": "myriad",
  "NOTE": "dnotes",
  "EMC2": "einsteinium",
  "BTCS": "bitcoin-scrypt",
  "ECC": "eccoin",
  "MONA": "monacoin",
  "RBY": "rubycoin",
  "BELA": "belacoin",
  "SLR": "solarcoin",
  "EFL": "e-gulden",
  "NLG": "gulden",
  "GRS": "groestlcoin",
  "XPD": "petrodollar",
  "PLNC": "plncoin",
  "XWC": "whitecoin",
  "POP": "popularcoin",
  "BITS": "bitcoinus",
  "QBC": "quebecoin",
  "BLU": "bluecoin",
  "MAID": "maidsafecoin",
  "XBC": "bitcoin-plus",
  "TALK": "btctalkcoin",
  "NYC": "newyorkcoin",
  "PINK": "pinkcoin",
  "DRM": "dreamcoin",
  "ENRG": "energycoin",
  "VRC": "vericoin",
  "XMR": "monero",
  "LCP": "litecoin-plus",
  "CURE": "curecoin",
  "SUPER": "supercoin",
  "BOST": "boostcoin",
  "MOTO": "motocoin",
  "CLOAK": "cloakcoin",
  "BSD": "bitsend",
  "C2": "coin2-1",
  "BCN": "bytecoin-bcn",
  "NAV": "nav-coin",
  "START": "startcoin",
  "XDN": "digitalnote",
  "BBR": "boolberry",
  "THC": "hempcoin",
  "XST": "stealth",
  "CLAM": "clams",
  "BTS": "bitshares",
  "VIA": "viacoin",
  "IOC": "iocoin",
  "XCN": "cryptonite",
  "CARBON": "carboncoin",
  "CANN": "cannabiscoin",
  "XLM": "stellar",
  "TIT": "titcoin",
  "VTA": "virtacoin",
  "J": "joincoin",
  "SYS": "syscoin",
  "EMC": "emercoin",
  "RBBT": "rabbitcoin",
  "BURST": "burst",
  "GAME": "gamecredits",
  "N8V": "native-coin",
  "UBQ": "ubiq",
  "OPAL": "opal",
  "ACOIN": "acoin",
  "BITUSD": "bitusd",
  "BITCNY": "bitcny",
  "BITBTC": "bitbtc",
  "USNBT": "nubits",
  "XMG": "magi",
  "EXCL": "exclusivecoin",
  "TROLL": "trollcoin",
  "BSTY": "globalboost-y",
  "PXI": "prime-xi",
  "XVG": "verge",
  "NSR": "nushares",
  "SPR": "spreadcoin",
  "RBT": "rimbit",
  "MUE": "monetaryunit",
  "BLOCK": "blocknet",
  "VIP": "limitless-vip",
  "CRW": "crown",
  "GCN": "gcn-coin",
  "XQN": "quotient",
  "OK": "okcash",
  "XPY": "paycoin2",
  "BITGOLD": "bitgold",
  "NXS": "nexus",
  "SMLY": "smileycoin",
  "BITSILVER": "bitsilver",
  "KOBO": "kobocoin",
  "BITB": "bean-cash",
  "GEO": "geocoin",
  "USDT": "tether",
  "WBB": "wild-beast-block",
  "GRC": "gridcoin",
  "XCO": "x-coin",
  "LDOGE": "litedoge",
  "SONG": "songcoin",
  "XEM": "nem",
  "NTRN": "neutron",
  "XAUR": "xaurum",
  "CF": "californium",
  "AIB": "advanced-internet-blocks",
  "SPHR": "sphere",
  "MEDIC": "mediccoin",
  "BUB": "bubble",
  "XSD": "bitshares-music",
  "UNIT": "universal-currency",
  "PKB": "parkbyte",
  "ARB": "arbit",
  "BTA": "bata",
  "ADC": "audiocoin",
  "SNRG": "synergy",
  "BITEUR": "biteur",
  "FJC": "fujicoin",
  "GXX": "gravitycoin",
  "XRA": "xriba",
  "CREVA": "crevacoin",
  "ZNY": "bitzeny",
  "BSC": "bowscoin",
  "HNC": "helleniccoin",
  "CPC": "cashpayz-token",
  "MANNA": "manna",
  "AXIOM": "axiom",
  "LEO": "unus-sed-leo",
  "AEON": "aeon",
  "ETH": "ethereum",
  "TX": "transfercoin",
  "GCC": "global-cryptocurrency",
  "AMS": "amsterdamcoin",
  "AGRS": "agoras-tokens",
  "EUC": "eurocoin",
  "SC": "siacoin",
  "GCR": "global-currency-reserve",
  "SHIFT": "shift",
  "VEC2": "vector",
  "BOLI": "bolivarcoin",
  "BCY": "bitcrystals",
  "PAK": "pakcoin",
  "EXP": "expanse",
  "SIB": "sibcoin",
  "SWING": "swing",
  "FCT": "firmachain",
  "DUO": "duo-network-token",
  "SANDG": "save-and-gain",
  "REP": "augur",
  "SHND": "stronghands",
  "PAC": "pac-global",
  "1337": "1337coin",
  "SCRT": "secretcoin",
  "DFT": "digifinextoken",
  "OBITS": "obits",
  "CLUB": "clubcoin",
  "ADZ": "adzcoin",
  "MOIN": "moin",
  "AV": "avatarcoin",
  "EGC": "evergreencoin",
  "CRB": "creditbit",
  "RADS": "radium",
  "LTCR": "litecred",
  "YOC": "yocoin",
  "SLS": "salus",
  "FRN": "francs",
  "EVIL": "evil-coin",
  "DCR": "decred",
  "PIVX": "pivx",
  "SFT": "safex-token",
  "RBIES": "rubies",
  "TRUMP": "trumpcoin",
  "MEME": "memetic",
  "IMS": "independent-money-system",
  "NEVA": "nevacoin",
  "BUMBA": "bumbacoin",
  "PEX": "posex",
  "CAB": "cabbage",
  "MOJO": "mojocoin",
  "LSK": "lisk",
  "EDRC": "edrcoin",
  "POST": "postcoin",
  "BERN": "berncash",
  "DGD": "digixdao",
  "STEEM": "steem",
  "ESP": "espers",
  "FUZZ": "fuzzballs",
  "XHI": "hicoin",
  "ARCO": "aquariuscoin",
  "XBTC21": "bitcoin-21",
  "EL": "elcoin-el",
  "ZUR": "zurcoin",
  "2GIVE": "2give",
  "XPTX": "platinumbar",
  "LANA": "lanacoin",
  "PONZI": "ponzicoin",
  "MXT": "martexcoin",
  "CTL": "citadel",
  "WAVES": "waves",
  "ICOO": "ico-openledger",
  "PWR": "powercoin",
  "ION": "ion",
  "HVCO": "high-voltage",
  "GB": "goldblocks",
  "CMT": "cybermiles",
  "RISE": "rise",
  "CHESS": "chesscoin",
  "LBC": "library-credit",
  "PUT": "profile-utility-token",
  "CJ": "cryptojacks",
  "HEAT": "heat-ledger",
  "SBD": "steem-dollars",
  "ARDR": "ardor",
  "ETC": "ethereum-classic",
  "BIT": "bitmoney",
  "ELE": "elementrem",
  "KRB": "karbo",
  "STRAT": "stratis",
  "ACES": "aces",
  "TAJ": "tajcoin",
  "EDC": "edc-blockchain",
  "XP": "experience-points",
  "VLT": "veltor",
  "NEO": "neo",
  "LMC": "lomocoin",
  "BTDX": "bitcloud",
  "NLC2": "nolimitcoin",
  "VRM": "veriumreserve",
  "ZYD": "zayedcoin",
  "PLU": "pluton",
  "TELL": "tellurion",
  "DLC": "dollarcoin",
  "MST": "mustangcoin",
  "PROUD": "proud-money",
  "1ST": "firstblood",
  "PEPECASH": "pepe-cash",
  "SNGLS": "singulardtv",
  "XZC": "zcoin",
  "ARC": "arcticcoin",
  "ZEC": "zcash",
  "ASAFE": "allsafe",
  "ZCL": "zclassic",
  "LKK": "lykke",
  "GNT": "golem-network-tokens",
  "IOP": "internet-of-people",
  "HUSH": "hush",
  "KURT": "kurrent",
  "PASC": "pascal",
  "ENT": "eternity",
  "INCNT": "incent",
  "DCT": "decent",
  "GOLOS": "golos",
  "VSL": "vslice",
  "DOLLAR": "dollar-international",
  "GBYTE": "obyte",
  "POSW": "posw-coin",
  "LUNA": "terra-luna",
  "WINGS": "wings",
  "DAR": "darcrus",
  "IFLT": "inflationcoin",
  "XSPEC": "spectrecoin",
  "BENJI": "benjirolls",
  "CCRB": "cryptocarbon",
  "VIDZ": "purevidz",
  "ICOB": "icobid",
  "IBANK": "ibank",
  "MKR": "maker",
  "KMD": "komodo",
  "FRST": "firstcoin",
  "WCT": "waves-community-token",
  "ICON": "iconic",
  "CNT": "centurion",
  "MLN": "melon",
  "TIME": "chronobank",
  "ARGUS": "argus",
  "SWT": "swarm-city",
  "NANO": "nano",
  "MILO": "milocoin",
  "ZER": "zero",
  "NETKO": "netko",
  "ARK": "ark",
  "DYN": "dynamic",
  "TKS": "tokes",
  "MER": "mercury",
  "TAAS": "taas",
  "EDG": "edgeless",
  "B@": "bankcoin",
  "UNI": "unicorn-token",
  "XLR": "solaris",
  "XAS": "asch",
  "DBIX": "dubaicoin-dbix",
  "GUP": "guppy",
  "USC": "usdcoin",
  "SKY": "scopuly",
  "BLAZR": "blazercoin",
  "ZENI": "zennies",
  "CXT": "coinonat",
  "CONX": "concoin",
  "RLC": "rlc",
  "TRST": "trust",
  "WGO": "wavesgo",
  "PROC": "procurrency",
  "SCS": "speedcash",
  "BTX": "bitcore",
  "VOLT": "bitvolt",
  "LUN": "lunyr",
  "GNO": "gnosis-gno",
  "TKN": "monolith",
  "HMQ": "humaniq",
  "ITI": "iticoin",
  "MNE": "minereum",
  "CNNC": "cannation",
  "DICE": "etheroll",
  "INSN": "insanecoin-insn",
  "ANT": "aragon",
  "PZM": "prizm",
  "RLT": "roulettetoken",
  "QTUM": "qtum",
  "DMB": "digital-money-bits",
  "NANOX": "project-x",
  "MAY": "theresa-may-coin",
  "SUMO": "sumokoin",
  "BAT": "basic-attention-token",
  "ZEN": "horizen",
  "AE": "aeternity",
  "V": "version",
  "ETP": "metaverse",
  "EBST": "eboostcoin",
  "ADK": "aidos-kuneen",
  "PTOY": "patientory",
  "VERI": "veritaseum",
  "ECA": "electra",
  "QRL": "quantum-resistant-ledger",
  "ETT": "encryptotel-eth",
  "MGO": "mobilego",
  "PPY": "peerplays-ppy",
  "MIOTA": "iota",
  "MYST": "mysterium",
  "MORE": "mithril-ore",
  "SNM": "sonm",
  "ADL": "adelphoi",
  "ZRC": "zrcoin",
  "BNT": "bancor",
  "GLT": "globaltoken",
  "NMR": "numeraire",
  "UNIFY": "unify",
  "XEL": "xel",
  "MRT": "miners-reward-token",
  "DCY": "dinastycoin",
  "ONX": "onix",
  "GXC": "gxchain",
  "ATCC": "atc-coin",
  "BRO": "bitradio",
  "FLASH": "flash",
  "FUN": "funfair",
  "PAY": "tenx",
  "SNT": "status",
  "ERG": "ergo",
  "BRIA": "briacoin",
  "EOS": "eos",
  "ADX": "adx-net",
  "D": "denarius-d",
  "BET": "dao-casino",
  "STORJ": "storj",
  "SOCC": "socialcoin-socc",
  "ADT": "adtoken",
  "MCO": "crypto-com",
  "PING": "cryptoping",
  "WGR": "wagerr",
  "ECOB": "ecobit",
  "PLBT": "polybius",
  "GAS": "gas",
  "SNC": "suncontract",
  "JET": "jetcoin",
  "MTL": "metal",
  "PPT": "populous",
  "RUP": "rupee",
  "PCN": "peepcoin",
  "SAN": "santiment",
  "OMG": "omisego",
  "TER": "terranova",
  "CVN": "cvcoin",
  "MRX": "metrix-coin",
  "CVC": "civic",
  "VGX": "voyager-token",
  "STA": "starta",
  "COAL": "bitcoal",
  "LBTC": "lightning-bitcoin",
  "PART": "particl",
  "SMART": "smartcash",
  "SKIN": "skincoin",
  "BCH": "bitcoin-cash",
  "HMC": "hi-mutual-society",
  "TOA": "toacoin",
  "PLR": "pillar",
  "SIGT": "signatum",
  "OCT": "oraclechain",
  "BNB": "binance-coin",
  "PBT": "primalbase",
  "EMB": "embercoin",
  "IXT": "ixledger",
  "GSR": "geysercoin",
  "CRM": "cream",
  "KEK": "kekcoin",
  "OAX": "oax",
  "DNT": "district0x",
  "STX": "blockstack",
  "CDT": "blox",
  "WINK": "wink",
  "BTM": "bytom",
  "MAO": "mao-zedong",
  "TIX": "blocktix",
  "DCN": "dentacoin",
  "RUPX": "rupaya",
  "SHDW": "shadow-token",
  "ONION": "deeponion",
  "CAT": "bitclave",
  "ADS": "adshares",
  "DENT": "dent",
  "IFT": "investfeed",
  "TCC": "the-champcoin",
  "ZRX": "0x",
  "YOYOW": "yoyow",
  "MYB": "mybit",
  "HC": "hypercash",
  "TFL": "trueflip",
  "NAS": "nebulas-token",
  "DALC": "dalecoin",
  "BBP": "biblepay",
  "ACT": "achain",
  "SIGMA": "sigmacoin",
  "TNT": "tierion",
  "WTC": "waltonchain",
  "BRAT": "brat",
  "PST": "primas",
  "OPT": "opus",
  "SUR": "suretly",
  "LRC": "loopring",
  "LTCU": "litecoin-ultra",
  "POE": "poet",
  "MCC": "magic-cube-coin",
  "MTH": "monetha",
  "AVT": "aventus",
  "DLT": "agrello-delta",
  "HVN": "hiveterminal-token",
  "MDA": "moeda-loyalty-points",
  "NEBL": "neblio",
  "TRX": "tron",
  "OCL": "oceanlab",
  "REX": "imbrex",
  "BUZZ": "buzzcoin",
  "CREDO": "credo",
  "MANA": "decentraland",
  "IND": "indorse-token",
  "XPA": "xpa",
  "SCL": "sociall",
  "ATB": "atbcoin",
  "PRO": "propy",
  "LINK": "chainlink",
  "BMC": "blackmoon",
  "KNC": "kyber-network",
  "VIBE": "vibe",
  "SUB": "substratum",
  "DAY": "chronologic",
  "PIX": "lampix",
  "COS": "contentos",
  "RVT": "rivetz",
  "KIN": "kin",
  "SALT": "salt",
  "ORMEUS": "ormeus-coin",
  "KLN": "kolion",
  "COLX": "colossusxt",
  "TZC": "trezarcoin",
  "COB": "cobinhood",
  "REC": "regalcoin",
  "MSD": "msd",
  "BIS": "bismuth",
  "ADA": "cardano",
  "XTZ": "tezos",
  "VOISE": "voisecom",
  "XIN": "mixin",
  "ATM": "attention-token-of-media",
  "KICK": "kick-token",
  "VIB": "viberate",
  "RHOC": "rchain",
  "INXT": "internxt",
  "CNX": "cryptonex",
  "REAL": "real",
  "HBT": "hubii-network",
  "CCT": "crystal-clear",
  "EVX": "everex",
  "PPP": "paypie",
  "ALIS": "alis",
  "BTCZ": "bitcoinz",
  "HGT": "hellogold",
  "CND": "cindicator",
  "ENG": "enigma",
  "ZSC": "zeusshield",
  "ECASH": "ethereumcash",
  "ATS": "authorship",
  "PIPL": "piplcoin",
  "EDO": "eidoo",
  "AST": "airswap",
  "CAG": "change",
  "BCPT": "blockmason",
  "AION": "aion",
  "TRCT": "tracto",
  "ART": "maecenas",
  "XGOX": "xgox",
  "EVR": "everus",
  "OTN": "open-trading-network",
  "DRT": "domraider",
  "REQ": "request",
  "BLUE": "ethereum-blue",
  "LIFE": "life",
  "AMB": "amber",
  "BTG": "bitcoin-gold",
  "KCS": "kucoin-shares",
  "EXRN": "exrnchain",
  "POLL": "clearpoll",
  "LA": "latoken",
  "XUC": "exchange-union",
  "NULS": "nuls",
  "BTCRED": "bitcoin-red",
  "PRG": "paragon",
  "BOS": "boscoin",
  "RCN": "ripio-credit-network",
  "ICX": "icon",
  "JS": "javascript-token",
  "ELITE": "ethereum-lite",
  "ITT": "intelligent-trading-foundation",
  "IETH": "iethereum",
  "PIRL": "pirl",
  "LUX": "luxcoin",
  "DOV": "dovu",
  "PHX": "red-pulse",
  "BTCM": "btcmoon",
  "FUEL": "etherparty",
  "ELLA": "ellaism",
  "FYP": "flypme",
  "EBTC": "ebtcnew",
  "ENJ": "enjin-coin",
  "IBTC": "ibtc",
  "POWR": "power-ledger",
  "GRID": "grid",
  "R": "revain",
  "ATL": "atlant",
  "ETN": "electroneum",
  "MNX": "minexcoin",
  "SONO": "altcommunity-coin",
  "DATA": "streamr-datacoin",
  "XSH": "shield-xsh",
  "ELTCOIN": "eltcoin",
  "DSR": "desire",
  "UKG": "unikoin-gold",
  "NIO": "autonio",
  "ARN": "aeron",
  "PHR": "phore",
  "RDN": "raiden-network-token",
  "DPY": "delphy",
  "ERC20": "erc20",
  "TIE": "tiesdb",
  "GRIM": "grimcoin",
  "EPY": "emphy",
  "DBET": "decent-bet",
  "UFR": "upfiring",
  "STU": "student-coin",
  "GVT": "genesis-vision",
  "PRIX": "privatix",
  "LTHN": "lethean",
  "PAYX": "paypex",
  "XLQ": "alqo",
  "GBX": "gobyte",
  "WC": "win-coin",
  "B2B": "b2bx",
  "PNX": "phantomx",
  "DNA": "encrypgen",
  "INK": "ink",
  "QSP": "quantstamp",
  "QASH": "qash",
  "TSL": "energo",
  "SPANK": "spankchain",
  "VOT": "votecoin",
  "BCD": "bitcoin-diamond",
  "VEE": "blockv",
  "MONK": "monkey-project",
  "FLIXX": "flixxo",
  "TNB": "time-new-bank",
  "WISH": "mywish",
  "EVC": "eva-cash",
  "LEND": "aave",
  "ONG": "ontology-gas",
  "CCO": "ccore",
  "QBT": "qbao",
  "DRGN": "dragonchain",
  "PFR": "payfair",
  "PRE": "presearch",
  "BCDN": "blockcdn",
  "CAPP": "cappasity",
  "ERO": "eroscoin",
  "ITC": "iot-chain",
  "SEND": "social-send",
  "BON": "bonpay",
  "NUKO": "nekonium",
  "SNOV": "snov",
  "BWK": "bulwark",
  "CMS": "comsa-xem",
  "WABI": "tael",
  "WAND": "wandx",
  "SPF": "sportyco",
  "CRED": "verify",
  "SCT": "soma",
  "UQC": "uquid-coin",
  "MDS": "medishares",
  "PRA": "prochain",
  "IGNIS": "ignis",
  "SMT": "smartmesh",
  "HWC": "hollywoodcoin",
  "PKT": "playkey",
  "FIL": "filecoin",
  "BCX": "bitcoinx",
  "SBTC": "super-bitcoin",
  "DAT": "datum",
  "AMM": "micromoney",
  "LOC": "lockchain",
  "WRC": "worldcore",
  "GTO": "gifto",
  "YTN": "yenten",
  "GNX": "genaro-network",
  "UBTC": "united-bitcoin",
  "STAR": "starbase",
  "OST": "ost",
  "STORM": "storm",
  "DTR": "dynamic-trading-rights",
  "ELF": "aelf",
  "WAXP": "wax",
  "MED": "medibloc",
  "NGC": "naga",
  "BRD": "bread",
  "BIX": "bibox-token",
  "SAI": "single-collateral-dai",
  "SPHTX": "sophiatx",
  "BNTY": "bounty0x",
  "ACE": "ace",
  "DIM": "dimcoin",
  "SRN": "sirin-labs-token",
  "CPAY": "cryptopay",
  "HTML": "html-coin",
  "DBC": "deepbrain-chain",
  "NEU": "neumark",
  "QC": "qcash",
  "UTK": "utrust",
  "QLC": "qlink",
  "PLAY": "herocoin",
  "ONE": "harmony",
  "MTX": "matryx",
  "HPY": "hyper-pay",
  "PYLNT": "pylon-network",
  "STAK": "straks",
  "FDX": "fidentiax",
  "GTC": "game",
  "TAU": "lamden",
  "BLT": "bloomtoken",
  "SWFTC": "swftcoin",
  "COV": "covesting",
  "CAN": "content-and-ad-network",
  "APPC": "appcoins",
  "HPB": "high-performance-blockchain",
  "WICC": "waykichain",
  "MDT": "measurable-data-token",
  "CL": "coinlancer",
  "GET": "themis",
  "OPC": "op-coin",
  "CFUN": "cfun",
  "AIDOC": "aidoc",
  "POLIS": "polis",
  "HKN": "hacken",
  "SHOW": "show",
  "ZAP": "zap",
  "TCT": "tokenclub",
  "FAIR": "fairgame",
  "AIX": "aigang",
  "REBL": "rebl",
  "INS": "insolar",
  "GOD": "bitcoin-god",
  "UTT": "uttoken",
  "CDX": "cdx-network",
  "BDG": "bitdegree",
  "QUN": "qunqun",
  "TOPC": "topchain",
  "LEV": "leverj",
  "KCASH": "kcash",
  "ATN": "atn",
  "SXDT": "spectre-dividend",
  "SXUT": "spectre-utility",
  "SWTC": "jingtum-tech",
  "VZT": "vezt",
  "KZC": "kz-cash",
  "BCA": "bitcoin-atom",
  "BKX": "bankex",
  "EKO": "echolink",
  "BTO": "bottos",
  "TEL": "telcoin",
  "IC": "ignition",
  "WETH": "weth",
  "KEY": "key",
  "INT": "int-chain",
  "RNT": "oneroot-network",
  "SENSE": "sense",
  "MOAC": "moac",
  "TOKC": "tokyo",
  "IOST": "iostoken",
  "IDT": "investdigital",
  "AIT": "aichain",
  "QUBE": "qube",
  "SPC": "spacechain",
  "ORE": "galactrum",
  "HORSE": "ethouse",
  "RCT": "realchain",
  "ARCT": "arbitragect",
  "THETA": "theta",
  "MVC": "maverick-chain",
  "NOX": "nitro",
  "IPL": "insurepal",
  "IDXM": "idex-membership",
  "AGI": "singularitynet",
  "GAT": "global-awards-token",
  "SEXC": "sharex",
  "CHAT": "chatcoin",
  "DDD": "scryinfo",
  "MOBI": "mobius",
  "HOT": "hot-token",
  "STC": "starchain",
  "IPC": "ipchain",
  "MAG": "maggie",
  "LIGHT": "lightchain",
  "REF": "reftoken",
  "YEE": "yee",
  "AAC": "acute-angle-cloud",
  "SSC": "selfsell",
  "READ": "read",
  "MOF": "molecular-future",
  "TNC": "trinity-network-credit",
  "C20": "c20",
  "DTA": "data",
  "CRPT": "crpt",
  "SPK": "sparkspay",
  "CV": "carvertical",
  "TBX": "tokenbox",
  "EKT": "educare",
  "UIP": "unlimitedip",
  "PRS": "pressone",
  "OF": "ofcoin",
  "TRUE": "truechain",
  "OCN": "odyssey",
  "IDH": "indahash",
  "QBIC": "qbic",
  "GUESS": "guess",
  "AID": "aidcoin",
  "EVE": "devery",
  "BPT": "blockport",
  "AXPR": "axpire",
  "TRAC": "origintrail",
  "LET": "linkeye",
  "ZIL": "zilliqa",
  "MEET": "coinmeet",
  "SLT": "social-lending-token",
  "FOTA": "fortuna",
  "SOC": "soda-coin",
  "MAN": "matrix-ai-network",
  "GRLC": "garlicoin",
  "RUFF": "ruff",
  "NKC": "nework",
  "COFI": "coinfi",
  "EQL": "equal",
  "HLC": "qitmeer",
  "ZPT": "zeepin",
  "OC": "oceanchain",
  "VLC": "valuechain",
  "BTW": "bitwhite",
  "CXO": "cargox",
  "CXP": "caixapay",
  "ELA": "elastos",
  "STK": "stk",
  "POLY": "polymath-network",
  "MTN": "medical-chain",
  "JNT": "jibrel-network",
  "CHSB": "swissborg",
  "ZLA": "zilla",
  "ADB": "adbank",
  "HT": "huobi-token",
  "DMT": "dmarket",
  "ING": "iungo",
  "BLZ": "bluzelle",
  "SWM": "swarm-fund",
  "TKY": "thekey",
  "ESZ": "ethersportz",
  "DXT": "datawallet",
  "WPR": "wepower",
  "UCASH": "ucash",
  "MNTP": "goldmint",
  "JEW": "shekel",
  "ACC": "asian-african-capital-chain",
  "MLM": "mktcoin",
  "AVH": "animation-vision-cash",
  "LOCI": "locicoin",
  "BIO": "biocoin",
  "SUP": "superior-coin",
  "UTNP": "universa",
  "ACAT": "alphacat",
  "EVN": "evencoin",
  "RMT": "sureremit",
  "DTH": "dether",
  "CAS": "cashaa",
  "FSN": "fusion",
  "MWAT": "restart-energy-mwat",
  "DADI": "edge",
  "NTK": "netkoin",
  "GEM": "gems-protocol",
  "NEC": "nectar",
  "REN": "ren",
  "LCC": "litecoin-cash",
  "STQ": "storiqa",
  "TDX": "tidex-token",
  "CPY": "copytrack",
  "NCASH": "nucleus-vision",
  "ABT": "arcblock",
  "REM": "remme",
  "EXY": "experty",
  "POA": "poa",
  "XNK": "ink-protocol",
  "BEZ": "bezop",
  "IHT": "iht-real-estate-protocol",
  "RFR": "refereum",
  "LYM": "lympo",
  "CS": "credits",
  "BEE": "bee-token",
  "INSTAR": "insights-network",
  "AUTO": "cube",
  "TUBE": "bit-tube",
  "LEDU": "education-ecosystem",
  "TUSD": "trueusd",
  "HQX": "hoqu",
  "STAC": "startercoin",
  "ONT": "ontology",
  "DATX": "datx",
  "J8T": "jet8",
  "CHP": "coinpoker",
  "TOMO": "tomochain",
  "GRFT": "graft",
  "BAX": "babb",
  "ELEC": "electrifyasia",
  "BTCP": "bitcoin-private",
  "TEN": "tokenomy",
  "RVN": "ravencoin",
  "TFD": "te-food",
  "SHIP": "shipchain",
  "LDC": "leadcoin",
  "SHP": "sharpe-platform-token",
  "LALA": "lala-world",
  "OCC": "octoin-coin",
  "CENNZ": "centrality",
  "SNX": "synthetix-network-token",
  "LOOM": "loom-network",
  "GETX": "guaranteed-ethurance-token-extra",
  "DROP": "dropil",
  "BANCA": "banca",
  "DRG": "dragon-coins",
  "NANJ": "nanjcoin",
  "CKUSD": "ckusd",
  "UP": "uptoken",
  "BBN": "banyan-network",
  "NOAH": "noah-coin",
  "1WO": "1world",
  "NPX": "napoleonx",
  "NPXS": "pundi-x",
  "BITG": "bitgreen",
  "BFT": "bnktothefuture",
  "WAN": "wanchain",
  "AMLT": "amlt",
  "MITH": "mithril",
  "LST": "luckyseventoken",
  "PCL": "peculium",
  "SIG": "signal-token",
  "RNTB": "bitrent",
  "XBP": "blitzpredict",
  "LNC": "blocklancer",
  "SPD": "spindle",
  "IPSX": "ip-exchange",
  "SCC": "stakecubecoin",
  "BSTN": "bitstation",
  "SWTH": "switcheo",
  "SEN": "consensus",
  "SENC": "sentinel-chain",
  "VIT": "vision-industry-token",
  "FDZ": "friends",
  "TPAY": "tokenpay",
  "BERRY": "rentberry",
  "XLA": "scala",
  "NCT": "polyswarm",
  "ODE": "odem",
  "XSN": "stakenet",
  "XDCE": "xinfin-network",
  "TDS": "tokendesk",
  "CTXC": "cortex",
  "CPX": "apex",
  "CVT": "cybervein",
  "SENT": "sentinel",
  "EOSDAC": "eosdac",
  "UUU": "u-network",
  "ADH": "adhive",
  "SNIP": "snipcoin",
  "BSM": "bitsum",
  "DEV": "deviantcoin",
  "CBT": "commerceblock",
  "AUC": "auctus",
  "XMC": "monero-classic",
  "DAN": "daneel",
  "MFG": "syncfab",
  "DIG": "dignity",
  "ADI": "aditus",
  "TRIO": "tripio",
  "XHV": "haven-protocol",
  "KST": "starcointv",
  "CRC": "crycash",
  "DERO": "dero",
  "EFX": "effect-ai",
  "FTX": "fintrux-network",
  "MRK": "mark-space",
  "SRCOIN": "srcoin",
  "CHX": "we-own",
  "MSR": "masari",
  "DOCK": "dock",
  "PHI": "phi-token",
  "BBC": "b2bcoin",
  "DML": "decentralized-machine-learning",
  "HBZ": "hbz-coin",
  "ORI": "origami",
  "TRAK": "trakinvest",
  "ZEBI": "zebi-token",
  "LND": "lendingblock",
  "XES": "proxeus",
  "VIPS": "vipstar-coin",
  "RBLX": "rublix",
  "BTRN": "biotron",
  "PNT": "penta",
  "NBAI": "nebula-ai",
  "LRN": "loopring-neo",
  "NEXO": "nexo",
  "VME": "verime",
  "DAX": "daex",
  "HYDRO": "hydrogen",
  "SS": "sharder",
  "CEL": "celsius",
  "TTT": "trustnote",
  "BCI": "bitcoin-interest",
  "BETR": "betterbetting",
  "TNS": "transcodium",
  "AMN": "amon",
  "FLP": "flip",
  "CMCT": "cyber-movie-chain",
  "MITX": "morpheus-labs",
  "MTC": "mtc-mesh-network",
  "MT": "monarch",
  "NTY": "nexty",
  "CJT": "connectjob",
  "BOUTS": "boutspro",
  "PAL": "pal-network",
  "CRE": "carry",
  "GENE": "gene-source-code-chain",
  "APR": "apr-coin",
  "AC3": "ac3",
  "FXT": "fuzex",
  "ZIPT": "zippie",
  "SKM": "skrumble-network",
  "GEN": "daostack",
  "BZNT": "bezant",
  "LIF": "winding-tree",
  "TEAM": "tokenstars",
  "OOT": "utrum",
  "ATX": "aston",
  "FREC": "freyrchain",
  "EDU": "edu-coin",
  "CNN": "content-neutrality-network",
  "INSUR": "insurchain",
  "GSC": "global-social-chain",
  "DGX": "digix-gold-token",
  "INC": "influence-chain",
  "IIC": "intelligent-investment-chain",
  "SKB": "sakura-bloom",
  "JOINT": "joint-ventures",
  "GRN": "greenpower",
  "BMH": "blockmesh",
  "LOKI": "loki",
  "SGN": "signals-network",
  "FND": "fundrequest",
  "DTRC": "datarius-credit",
  "CLN": "colu-local-network",
  "HER": "heronode",
  "RAISE": "raise",
  "CLO": "callisto-network",
  "UBT": "unibright",
  "PAT": "patron",
  "LBA": "libra-credit",
  "OPEN": "open-platform",
  "MRPH": "morpheus-network",
  "SNTR": "silent-notary",
  "XYO": "xyo",
  "CPT": "contents-protocol",
  "APIS": "apix",
  "FT": "ftoken",
  "RED": "red",
  "DGTX": "digitex-futures",
  "GIN": "gincoin",
  "INV": "invacio",
  "FACE": "faceter",
  "AVA": "travala",
  "IOTX": "iotex",
  "LUC": "level-up",
  "NKN": "nkn",
  "ZIP": "zip",
  "SOUL": "cryptosoul",
  "REPO": "repo",
  "SEELE": "seele",
  "IVY": "ivy",
  "EDR": "endor-protocol",
  "BBO": "bigbom",
  "0xBTC": "0xbtc",
  "PI": "pchain",
  "QKC": "quarkchain",
  "LYL": "loyalcoin",
  "BNK": "bankera",
  "ETZ": "ether-zero",
  "OMX": "shivom",
  "FTO": "futurocoin",
  "ABYSS": "abyss-token",
  "PMNT": "paymon",
  "HUR": "hurify",
  "TM2": "traxia",
  "EGCC": "engine",
  "CBC": "cryptobosscoin",
  "CEEK": "ceek-vr",
  "SAL": "salpay",
  "COU": "couchain",
  "XMX": "xmax",
  "GO": "gochain",
  "SSP": "smartshare",
  "HOLD": "hold",
  "TRTT": "trittium",
  "UPP": "sentinel-protocol",
  "BWT": "bittwatt",
  "DAG": "constellation",
  "MVP": "merculet",
  "UCT": "ubique-chain-of-things",
  "ETK": "energitoken",
  "MET": "metronome",
  "AOA": "aurora",
  "ALX": "alax",
  "TERN": "ternio",
  "ORS": "ors-group",
  "RTE": "rate3",
  "ZCN": "0chain",
  "ZINC": "zinc",
  "FSBT": "fsbt-api-token",
  "EGT": "egretia",
  "CAR": "carblock",
  "BOB": "bobs-repair",
  "KNDC": "kanadecoin",
  "CARD": "cardstack",
  "WWB": "wowbit",
  "ONL": "on-live",
  "OTB": "otcbtc-token",
  "CONI": "coni",
  "MFT": "mainframe",
  "CCC": "coindom",
  "GOT": "parkingo",
  "THRT": "thrive-token",
  "PAI": "project-pai",
  "FTI": "fanstime",
  "PCH": "popchain",
  "SEER": "seer",
  "ESS": "essentia",
  "KBC": "karatgold-coin",
  "HSC": "hashcoin",
  "LIKE": "likecoin",
  "YUP": "crowdholding",
  "XSG": "snowgem",
  "DTX": "databroker",
  "BKBT": "beekan",
  "MOC": "moss-coin",
  "NIM": "nimiq",
  "BZ": "bit-z-token",
  "DWS": "dws",
  "ZXC": "0xcert",
  "OLT": "oneledger",
  "ATMI": "atonomi",
  "XMCT": "xmct",
  "FNKOS": "fnkos",
  "PSM": "prasm",
  "SUSD": "susd",
  "PLY": "playcoin-erc20",
  "TGAME": "tgame",
  "IQ": "iqcash",
  "ENGT": "engagement-token",
  "NOBS": "no-bs-crypto",
  "BMX": "bitmart-token",
  "KAN": "bitkan",
  "VITE": "vite",
  "GARD": "hashgard",
  "XD": "data-transaction-token",
  "SPX": "sp8de",
  "CET": "coinex-token",
  "RPL": "rocket-pool",
  "ELY": "elysian",
  "BOX": "box-token",
  "PTT": "proton-token",
  "SOP": "sopay",
  "KRL": "kryll",
  "LEMO": "lemochain",
  "GBC": "gold-bits-coin",
  "BWX": "blue-whale-exchange",
  "WYS": "wys-token",
  "COSM": "cosmo-coin",
  "NRVE": "narrative",
  "OLE": "olive",
  "TRTL": "turtlecoin",
  "WT": "wetoken",
  "TOTO": "tourist-token",
  "RLX": "relex",
  "CHEX": "chex",
  "VIEW": "view",
  "VIKKY": "vikkytoken",
  "FOXT": "fox-trading",
  "BRDG": "bridge-protocol",
  "GVE": "globalvillage-ecosystem",
  "LCS": "local-coin-swap",
  "ZPR": "zper",
  "LPC": "lightpaycoin",
  "FUNDZ": "fundtoken",
  "RYO": "ryo-currency",
  "ACED": "aced",
  "LFC": "linfinity",
  "WAB": "wabnetwork",
  "CSM": "consentium",
  "MVL": "mvl",
  "NCP": "newton-coin-project",
  "DACC": "dacc",
  "TOS": "thingsoperatingsystem",
  "PGN": "pigeoncoin",
  "EURS": "stasis-euro",
  "EXMR": "exmr-fdn",
  "NIX": "nix",
  "APL": "apollo-currency",
  "HORUS": "horuspay",
  "BIFI": "bitcoin-file",
  "DPN": "dipnet",
  "VEX": "vexanium",
  "HDAC": "hdac",
  "KWH": "kwhcoin",
  "MCT": "master-contract-token",
  "ACDC": "volt",
  "NBR": "niobio-cash",
  "VIVID": "vivid-coin",
  "CEN": "centaure",
  "BITX": "bitscreener-token",
  "VTHO": "vethor-token",
  "PRIV": "privcy",
  "RMESH": "rightmesh",
  "BBK": "bitblocks",
  "NCC": "neurochain",
  "KLKS": "kalkulus",
  "BHP": "bhp-coin",
  "INCX": "internationalcryptox",
  "ZMN": "zmine",
  "SEM": "semux",
  "ARO": "arionum",
  "IOV": "iov-blockchain",
  "WEB": "webcoin",
  "ZEL": "zel",
  "BNN": "brokernekonetwork",
  "OBT": "orbis-token",
  "CZR": "cononchain",
  "OPCX": "opcoinx",
  "XUN": "ultranote-coin",
  "BTK": "bitcoin-turbo-koin",
  "DTEM": "dystem",
  "GOC": "gocrypto-token",
  "YOU": "you-coin",
  "DACS": "dacsee",
  "EBC": "ebcoin",
  "TCH": "tchain",
  "SDA": "sdchain",
  "YCC": "yuan-chain-coin",
  "PC": "promotion-coin",
  "VITAE": "vitae",
  "ROCK2": "ice-rock-mining",
  "BCV": "bitcapitalvendor",
  "XTRD": "xtrd",
  "BTCN": "bitcoinote",
  "NAM": "nam-coin",
  "LXT": "litex",
  "EUNO": "euno",
  "MGD": "massgrid",
  "EST": "esports-token",
  "EXT": "experience-token",
  "EDS": "endorsit",
  "VET": "vechain",
  "KIND": "kind-ads-token",
  "X8X": "x8x-token",
  "CMM": "commercium",
  "ECOM": "omnitude",
  "VIN": "vinchain",
  "LINA": "lina",
  "BTT": "bittorrent",
  "INO": "ino-coin",
  "KNT": "knekted",
  "CROAT": "croat",
  "BTCONE": "bitcoin-one",
  "WIKI": "wiki-token",
  "SPN": "sapien",
  "NUG": "nuggets",
  "BBS": "bbscoin",
  "SCR": "scorum-coins",
  "NBC": "niobium-coin",
  "NPXSXEM": "pundi-x-nem",
  "XOV": "xovbank",
  "OPTI": "optitoken",
  "GIC": "giant-coin",
  "ABDT": "atlantis-blue-digital-token",
  "PKG": "pkg-token",
  "BOC": "bingocoin",
  "RDC": "ordocoin",
  "NEWOS": "newstoken",
  "XPAT": "bitnation",
  "ICR": "intercrone",
  "MXM": "maximine-coin",
  "INB": "insight-chain",
  "GIO": "graviocoin",
  "SDS": "alchemint-standards",
  "OWN": "owndata",
  "IG": "igtoken",
  "GSE": "gsenetwork",
  "XDNA": "xdna",
  "XPX": "proximax",
  "NYEX": "nyerium",
  "TIC": "thingschain",
  "EGEM": "ethergem",
  "AREPA": "arepacoin",
  "XET": "eternal-token",
  "CEDEX": "cedex-coin",
  "MEETONE": "meetone",
  "KARMA": "karma-eos",
  "NOKU": "noku",
  "DX": "dxchain-token",
  "UBEX": "ubex",
  "PASS": "blockpass",
  "BAAS": "baasid",
  "THR": "thorecoin",
  "CYFM": "cyberfm",
  "HYC": "hycon",
  "METM": "metamorph",
  "AKA": "akroma",
  "OBTC": "obitan-chain",
  "TKT": "twinkle",
  "DAC": "davinci-coin",
  "QNT": "quant",
  "ABL": "airbloc",
  "ZCR": "zcore",
  "XAP": "apollon",
  "SVD": "savedroid",
  "YLC": "yolocash",
  "PMA": "pumapay",
  "ARION": "arion",
  "XBI": "bitcoin-incognito",
  "FTT": "ftx-token",
  "HYB": "hybrid-block",
  "HB": "heartbout",
  "FNTB": "fintab",
  "TTC": "ttc",
  "SEAL": "sealchain",
  "LKY": "linkey",
  "ABX": "arbidex",
  "HAND": "showhand",
  "HIT": "hitchain",
  "GPKR": "gold-poker",
  "ZP": "zen-protocol",
  "ECT": "superedge",
  "MFTU": "mainstream-for-the-underground",
  "RRC": "rrcoin",
  "RATING": "dprating",
  "CTC": "creditcoin",
  "KNOW": "know",
  "KXC": "kingxchain",
  "NSD": "nasdacoin",
  "LOBS": "lobstex",
  "VDG": "veridocglobal",
  "SAT": "social-activity-token",
  "YUKI": "yuki",
  "KWATT": "4new",
  "MIB": "mib-coin",
  "GTM": "gentarium",
  "DELTA": "delta-chain",
  "NRG": "energi",
  "FTXT": "futurax",
  "DAV": "dav-coin",
  "BNC": "bionic",
  "DOW": "dowcoin",
  "QBIT": "qubitica",
  "BTN": "bitnewchain",
  "TAC": "traceability-chain",
  "VULC": "vulcano",
  "BQT": "blockchain-quotations-index-token",
  "STR": "staker",
  "UT": "ulord",
  "AT": "artfinity",
  "ESN": "ethersocial",
  "FKX": "fortknoxster",
  "BEET": "beetle-coin",
  "IMT": "moneytoken",
  "MIC": "mindexcoin",
  "UBC": "ubcoin-market",
  "FLOT": "fire-lotto",
  "ALI": "ailink-token",
  "USE": "usechain-token",
  "ZBA": "zoomba",
  "SHE": "shinechain",
  "BLACK": "eosblack",
  "MRI": "mirai",
  "CYMT": "cybermusic",
  "BTR": "bitrue-coin",
  "GZE": "gazecoin",
  "BUT": "bitup-token",
  "UC": "youlive-coin",
  "AMO": "amo-coin",
  "CCL": "cyclean",
  "DIN": "dinero",
  "DIT": "digital-insurance-token",
  "HAVY": "havy",
  "CARE": "carebit",
  "PRJ": "project-coin",
  "ECHT": "e-chat",
  "IMP": "ether-kingdoms-token",
  "C8": "carboneum-c8-token",
  "SNO": "savenode",
  "VSC": "vsportcoin",
  "PENG": "peng",
  "RTH": "rotharium",
  "RET": "realtract",
  "QNTU": "quanta-utility-token",
  "TV": "ti-value",
  "BIR": "birake",
  "MEX": "mex",
  "AAA": "abulaba",
  "BEN": "bitcoen",
  "ELLI": "elliot-coin",
  "CIT": "carinet",
  "BTAD": "bitcoin-adult",
  "BU": "bumo",
  "MIN": "mindol",
  "IHF": "invictus-hyperion-fund",
  "UCN": "uchain",
  "MOLK": "mobilinktoken",
  "EDN": "eden",
  "GUSD": "gemini-dollar",
  "SPND": "spendcoin",
  "XCG": "xchange",
  "ALC": "allcoin",
  "CSTL": "castle",
  "CFL": "cryptoflow",
  "BOXX": "blockparty-boxx-token",
  "IOG": "playgroundz",
  "AOG": "smartofgiving",
  "CTRT": "cryptrust",
  "TCN": "tcoin",
  "BUNNY": "bunnytoken",
  "PYN": "paycent",
  "PLURA": "pluracoin",
  "ROX": "robotina",
  "SIX": "six",
  "CMIT": "cmitcoin",
  "DFS": "fantasy-sports",
  "PAX": "paxos-standard",
  "WIZ": "crowdwiz",
  "GOSS": "gossipcoin",
  "SOL": "sola-token",
  "XCASH": "x-cash",
  "IQN": "iqeon",
  "QCH": "qchi",
  "PAXEX": "paxex",
  "MLC": "mallcoin",
  "PHON": "phonecoin",
  "ANON": "anon",
  "ECOREAL": "ecoreal-estate",
  "DAPS": "daps-coin",
  "CARAT": "carat",
  "MNP": "mnpcoin",
  "GPYX": "goldenpyrex",
  "DACHX": "dach-coin",
  "ZB": "zerobank",
  "MAS": "midasprotocol",
  "TRXC": "tronclassic",
  "AZART": "azart",
  "TMTG": "the-midas-touch-gold",
  "DAGT": "digital-asset-guarantee-token",
  "HSN": "hyper-speed-network",
  "WIT": "witchain",
  "ERT": "eristica",
  "MINTME": "mintme-com-coin",
  "AUX": "auxilium",
  "WXC": "wxcoins",
  "PLC": "platincoin",
  "VSF": "verisafe",
  "SINS": "safeinsure",
  "CRD": "cryptaldash",
  "KUE": "kuende",
  "MIR": "mir-coin",
  "BETHER": "bethereum",
  "RAGNA": "ragnarok",
  "DEC": "darcio-ecosystem-coin",
  "XGS": "genesisx",
  "WBL": "wizbl",
  "CIV": "civitas",
  "BENZ": "benz",
  "ACM": "actinium",
  "BLAST": "blast",
  "FREE": "free-coin",
  "TOL": "tolar",
  "QUAN": "quantis-network",
  "MASH": "masternet",
  "STEEP": "steepcoin",
  "NRP": "neural-protocol",
  "SCRIV": "scriv-network",
  "X12": "x12-coin",
  "IFOOD": "ifoods-chain",
  "EGX": "eaglex",
  "WIX": "wixlar",
  "BC": "block-chain-com",
  "RSTR": "ondori",
  "USDC": "usd-coin",
  "SIM": "simmitri",
  "NDX": "ndex",
  "ZEUS": "zeusnetwork",
  "BCZERO": "buggyra-coin-zero",
  "WAGE": "digiwage",
  "F1C": "future1coin",
  "META": "metadium",
  "QAC": "quasarcoin",
  "KKC": "kabberry-coin",
  "SHPING": "shping",
  "S": "sharpay",
  "QNO": "qyno",
  "INCO": "incodium",
  "AGLT": "agrolot",
  "ICNQ": "iconiq-lab-token",
  "RPD": "rapids",
  "ENTS": "eunomia",
  "SNET": "snetwork",
  "SMQ": "simdaq",
  "ABBC": "abbc-coin",
  "OXY": "oxycoin",
  "DEAL": "idealcash",
  "WIRE": "airwire",
  "DIVI": "divi",
  "XIND": "indinode",
  "ZNT": "zenswap-network-token",
  "ATH": "atheios",
  "CDC": "commerce-data-connection",
  "MMO": "mmocoin",
  "BLOC": "blockcloud",
  "ETHO": "ether-1",
  "DATP": "decentralized-asset-trading-platform",
  "DEEX": "deex",
  "PLUS1": "plusonecoin",
  "IRD": "iridium",
  "ZT": "ztcoin",
  "HELP": "helpico",
  "RPI": "rpicoin",
  "CHEESE": "cheesecoin",
  "ALT": "alt-estate-token",
  "ISR": "insureum",
  "HLM": "helium",
  "FBN": "fivebalance",
  "TDP": "truedeck",
  "DT": "dragon-token",
  "ROBET": "robet",
  "JSE": "jsecoin",
  "YEED": "yeed",
  "ITL": "italian-lira",
  "ASA": "asura-coin",
  "MODX": "model-x-coin",
  "SHMN": "stronghands-masternode",
  "PNY": "peony",
  "TELOS": "teloscoin",
  "WTN": "waletoken",
  "GST": "game-stars",
  "GZRO": "gravity",
  "ESCE": "escroco-emerald",
  "VLU": "valuto",
  "EZW": "ezoow",
  "VLD": "vetri",
  "BZX": "bitcoin-zero",
  "XCD": "capdaxtoken",
  "LQD": "liquidity-network",
  "CGEN": "communitygeneration",
  "HNDC": "hondaiscoin",
  "TYPE": "typerium",
  "IONC": "ionchain",
  "MBC": "microbitcoin",
  "BZL": "bzlcoin",
  "VOCO": "provoco-token",
  "APC": "alpha-coin",
  "FTM": "fantom",
  "SIN": "sinovate",
  "DEX": "dex",
  "SNR": "sonder",
  "BRZE": "breezecoin",
  "VNX": "visionx",
  "PAWS": "paws-fund",
  "SND": "snodecoin",
  "CYL": "crystal-token",
  "PNK": "kleros",
  "MEDIBIT": "medibit",
  "POSS": "posscoin",
  "TTV": "tv-two",
  "WET": "weshow-token",
  "BGG": "bgogo-token",
  "ABS": "absolute",
  "ETHM": "ethereum-meta",
  "CRYP": "crypticcoin",
  "LION": "coin-lion",
  "PTN": "palletone",
  "XNV": "nerva",
  "INVE": "intervalue",
  "OSA": "optimal-shelf-availability-token",
  "ETI": "etherinc",
  "HUM": "humanscape",
  "BSV": "bitcoin-sv",
  "SHB": "skyhub-coin",
  "VITES": "vites",
  "VEST": "vestchain",
  "UDOO": "howdoo",
  "CWV": "cwv-chain",
  "MICRO": "micromines",
  "NOR": "noir",
  "BCAC": "business-credit-alliance-chain",
  "DASHG": "dash-green",
  "HQT": "hyperquant",
  "BCDT": "blockchain-certified-data-token",
  "ILC": "ilcoin",
  "STACS": "stacs",
  "BEAT": "beat",
  "ATP": "atlas-protocol",
  "BTNT": "bitnautic-token",
  "NOS": "nos",
  "NZL": "zealium",
  "EQUAD": "quadrantprotocol",
  "RBTC": "rsk-smart-bitcoin",
  "BLTG": "block-logic",
  "MXC": "machine-xchange-coin",
  "LRM": "lrm-coin",
  "FOAM": "foam",
  "OPQ": "opacity",
  "PLAT": "bitguild-plat",
  "KAT": "kambria",
  "CRO": "crypto-com-coin",
  "LML": "lisk-machine-learning",
  "AERGO": "aergo",
  "SKCH": "skychain",
  "PXG": "playgame",
  "LPT": "livepeer",
  "TIOX": "trade-token-x",
  "TENA": "tena",
  "TVNT": "travelnote",
  "SHVR": "shivers",
  "HERB": "herbalist-token",
  "CNUS": "coinus",
  "NPLC": "plus-coin",
  "COVA": "cova",
  "ZUM": "zum-token",
  "BRC": "baer-chain",
  "FIII": "fiii",
  "BECN": "beacon",
  "LAMB": "lambda",
  "FTN": "fountain",
  "QUIN": "quinads",
  "SHX": "stronghold-token",
  "HEDG": "hedgetrade",
  "XFC": "footballcoin",
  "AGVC": "agavecoin",
  "IMPL": "impleum",
  "ULT": "ultiledger",
  "AWC": "atomic-wallet-coin",
  "PRX": "proxynode",
  "WCO": "winco",
  "ROM": "romtoken",
  "KZE": "almeela",
  "DOGEC": "dogecash",
  "BTMX": "bitmax-token",
  "ROCO": "roiyal-coin",
  "SNPC": "snapcoin",
  "CENT": "centercoin",
  "XTA": "italo",
  "AEN": "aencoin",
  "B2G": "bitcoiin",
  "BTCL": "btc-lite",
  "CVNT": "content-value-network",
  "MOX": "mox",
  "BUL": "bulleon",
  "KT": "kuai-token",
  "TOK": "tokok",
  "M2O": "m2o",
  "INX": "inmax",
  "HYN": "hyperion",
  "XSM": "spectrumcash",
  "GMBC": "gamblica",
  "CTX": "centauri",
  "RIF": "rif-token",
  "BEAM": "beam",
  "ADM": "adamant-messenger",
  "VSYS": "v-systems",
  "ALB": "albos",
  "TOSC": "t-os",
  "EXO": "exosis",
  "GRIN": "grin",
  "PLA": "planet",
  "CLB": "cloudbric",
  "LTO": "lto-network",
  "CAJ": "cajutel",
  "VEO": "amoveo",
  "WBTC": "wrapped-bitcoin",
  "USDS": "stableusd",
  "HPT": "huobi-pool-token",
  "TEMCO": "temco",
  "SOLVE": "solve",
  "FLC": "flowchain",
  "HALO": "halo-platform",
  "WLO": "wollo",
  "TCAT": "the-currency-analytics",
  "CCX": "conceal",
  "S4F": "s4fe",
  "ELAC": "ela-coin",
  "VGW": "vegawallet-token",
  "BTU": "btu-protocol",
  "DCTO": "decentralized-crypto-token",
  "CONST": "constant",
  "ECTE": "eurocoin-token",
  "BNANA": "chimpion",
  "QUSD": "qusd",
  "WEBN": "webn-token",
  "777": "bingo-fun",
  "ELD": "electrumdark",
  "AUNIT": "aunite",
  "HXRO": "hxro",
  "XPC": "experience-chain",
  "LABX": "stakinglab",
  "UPX": "uplexa",
  "PLTC": "platoncoin",
  "EVY": "everycoin",
  "MHC": "metahash",
  "GMB": "gamb",
  "MPG": "max-property-group",
  "JNB": "jinbi-token",
  "SWC": "scanetchain",
  "1SG": "1sg",
  "OWC": "oduwa",
  "SET": "save-environment-token",
  "FAT": "fatcoin",
  "PIB": "pibble",
  "HBX": "hashsbx",
  "CCN": "customcontractnetwork",
  "ETX": "ethereumx",
  "FET": "fetch",
  "TWINS": "win-win",
  "GFUN": "goldfund",
  "SPT": "spectrum",
  "EVOS": "evos",
  "COT": "cotrader",
  "SPRKL": "sparkle",
  "ONOT": "onotoken",
  "ANKR": "ankr",
  "OVC": "ovcode",
  "AIDUS": "aidus-token",
  "LUNES": "lunes",
  "INNBCL": "innovative-bioresearch-classic",
  "NET": "next",
  "BOLTT": "boltt-coin",
  "RC20": "robocalls",
  "JWL": "jewel",
  "ARAW": "araw",
  "GALI": "galilel",
  "ATOM": "cosmos",
  "ZEON": "zeon",
  "MESG": "mesg",
  "XBX": "bitex-global-xbx-coin",
  "XUEZ": "xuez",
  "SAFE": "safe",
  "FEX": "fidex-token",
  "BORA": "bora",
  "DRA": "diruna",
  "NAVY": "boat-pilot-token",
  "LTK": "linktoken",
  "OROX": "cointorox",
  "DOS": "dos-network",
  "ETGP": "ethereum-gold-project",
  "INE": "intellishare",
  "FXC": "flexacoin",
  "PTON": "pton",
  "CELR": "celer-network",
  "XBASE": "eterbase-coin",
  "VRA": "verasity",
  "GPT": "gopower",
  "BHIG": "buck-hath-coin",
  "XQR": "qredit",
  "TFUEL": "theta-fuel",
  "OLXA": "olxa",
  "VANTA": "vanta-network",
  "PUB": "publyto-token",
  "TOP": "top",
  "BUD": "buddy",
  "JCT": "japan-content-token",
  "NEX": "nash-exchange",
  "VEIL": "veil",
  "SHA": "safe-haven",
  "BBGC": "big-bang-game-coin",
  "HYPX": "hypnoxys",
  "DXG": "dexter-g",
  "ORBS": "orbs",
  "MFC": "mfcoin",
  "HLT": "esportbits",
  "XRC": "bitcoin-rhodium",
  "FST": "1irstcoin",
  "XLB": "stellarpay",
  "CSP": "caspian",
  "BOLT": "bolt",
  "XTX": "xtock",
  "VIDT": "v-id",
  "VBK": "veriblock",
  "OBX": "ooobtc-token",
  "WHEN": "when-token",
  "OTO": "otocash",
  "ALLN": "airline-and-life-networking-token",
  "HUDDL": "huddl",
  "MTV": "multivac",
  "UND": "unification",
  "LOCUS": "locus-chain",
  "SFCP": "sf-capital",
  "FNB": "fnb-protocol",
  "PTI": "paytomat",
  "INF": "infinitus-token",
  "UGAS": "ugas",
  "UTS": "utemis",
  "BZKY": "bizkey",
  "CON": "conun",
  "NASH": "neoworld-cash",
  "A": "alpha-token",
  "LIT": "lition",
  "NEW": "newton",
  "BIA": "bilaxy-token",
  "BOTX": "botxcoin",
  "IRIS": "irisnet",
  "VALOR": "valor-token",
  "ENTRC": "entercoin",
  "WEBD": "webdollar",
  "XWP": "swap",
  "ESBC": "esbc",
  "OCE": "oceanex-token",
  "STASH": "bitstash",
  "ARQ": "arqma",
  "QCX": "quickx-protocol",
  "FX": "function-x",
  "WPP": "wpp-token",
  "ICT": "icocalendar-today",
  "BCEO": "bitceo",
  "NAT": "natmin-pure-escrow",
  "MATIC": "matic-network",
  "VOLLAR": "v-dimension",
  "NOW": "now-token",
  "CSPN": "crypto-sports",
  "MAC": "matrexcoin",
  "HYT": "horyoutoken",
  "OKB": "okb",
  "AXE": "axe",
  "KUBO": "kubocoin",
  "XMV": "monero-v",
  "BITC": "bitcash",
  "PEOS": "peos",
  "OCEAN": "ocean-protocol",
  "WGP": "w-green-pay",
  "TTN": "titan-coin",
  "GTN": "glitzkoin",
  "MERI": "merebel",
  "THX": "thorenext",
  "SNTVT": "sentivate",
  "DOGET": "doge-token",
  "DPT": "diamond-platform-token",
  "TAS": "tarush",
  "VJC": "venjocoin",
  "DREP": "drep",
  "TRAT": "tratin",
  "XLMG": "stellar-gold",
  "ATLS": "atlas-token",
  "IDEX": "idex",
  "BQTX": "bqt",
  "TT": "thunder-token",
  "ELET": "elementeum",
  "XCON": "connect-coin",
  "SWIFT": "swiftcash",
  "CNNS": "cnns",
  "SRK": "sparkpoint",
  "GNY": "gny",
  "NNB": "nnb-token",
  "MZK": "muzika",
  "TRP": "tronipay",
  "P2PX": "p2p-global-network",
  "FAB": "fabrk",
  "QWC": "qwertycoin",
  "HNB": "hashnet-biteco",
  "TERA": "tera",
  "AFIN": "asian-fintech",
  "NTR": "netrum",
  "ARRR": "pirate-chain",
  "IOTW": "iotw",
  "EVED": "evedo",
  "ODEX": "one-dex",
  "BOMB": "bomb",
  "RFOX": "redfox-labs",
  "ALV": "alluva",
  "NEAL": "coineal-token",
  "BZE": "bzedge",
  "VDX": "vodi-x",
  "DREAM": "dreamteam-token",
  "RSR": "reserve-rights",
  "TOC": "touchcon",
  "BHD": "bitcoinhd",
  "EUM": "elitium",
  "TRY": "trias",
  "GRAT": "gratz",
  "AYA": "aryacoin",
  "BTC2": "bitcoin2",
  "NUSD": "neutral-dollar",
  "SNL": "sport-and-leisure",
  "CHR": "chromia",
  "TCASH": "tcash",
  "PHV": "phv",
  "LBN": "lucky-block-network",
  "OGO": "origo",
  "BDX": "beldex",
  "VNT": "vnt-chain",
  "LVL": "levelapp-token",
  "WFX": "webflix-token",
  "ALP": "alp-coin",
  "COTI": "coti",
  "EMT": "emanate",
  "SMARTUP": "smartup",
  "GOS": "gosama",
  "IOUX": "iou",
  "BST": "blockstamp",
  "KRI": "krios",
  "MPAY": "menapay",
  "ZNN": "zenon",
  "STPT": "stpt",
  "B91": "b91",
  "BCZ": "bitcoin-cz",
  "IZI": "izichain",
  "SPRK": "sparkster",
  "BQQQ": "bitsdaq",
  "MINX": "innovaminex",
  "XSPC": "spectre-security-coin",
  "MCPC": "mobile-crypto-pay-coin",
  "EOSDT": "eosdt",
  "KTS": "klimatas",
  "USDQ": "usdq",
  "BTCB": "bitcoin-bep2",
  "RAVEN": "raven-protocol",
  "PIA": "futurepia",
  "DAPP": "liquid-apps",
  "DVT": "devault",
  "ALGO": "algorand",
  "JAR": "jarvis",
  "HNST": "honest",
  "MBL": "moviebloc",
  "ARPA": "arpa-chain",
  "MX": "mx-token",
  "CB": "coinbig",
  "CATT": "catex-token",
  "NBOT": "naka-bodhi-token",
  "MGC": "mgc-token",
  "BXK": "bitbook-gambling",
  "OCUL": "oculor",
  "PAR": "parachute",
  "QDAO": "q-dao-governance-token",
  "IGG": "ig-gold",
  "AMPL": "ampleforth",
  "ADN": "aladdin",
  "FO": "fibos",
  "TRV": "trustverse",
  "BYT": "bayan-token",
  "7E": "7eleven",
  "USDK": "usdk",
  "CHZ": "chiliz",
  "CIX100": "cryptoindex-com-100",
  "BURN": "blockburn",
  "GEX": "gexan",
  "SPIN": "spin-protocol",
  "XCHF": "cryptofranc",
  "ETHPLO": "ethplode",
  "MAPR": "maya-preferred-223",
  "SERO": "super-zero",
  "SLV": "silverway",
  "HGO": "hirego",
  "THAR": "thar-token",
  "ERD": "elrond",
  "PDATA": "pdata",
  "BLINK": "blockmason-link",
  "WXT": "wirex-token",
  "PXL": "pixel",
  "DUSK": "dusk-network",
  "URAC": "uranus",
  "SPIKE": "spiking",
  "X42": "x42-protocol",
  "QBX": "qiibee",
  "TMN": "translateme-network-token",
  "FLETA": "fleta",
  "FUZE": "fuze-token",
  "XCM": "coinmetro-token",
  "ETM": "en-tan-mo",
  "XEUR": "xeuro",
  "NPC": "npcoin",
  "IDEAL": "idealcoin",
  "GOLD": "digital-gold",
  "PVT": "pivot-token",
  "TKP": "tokpie",
  "FOR": "the-force-protocol",
  "VD": "vindax-coin",
  "PROM": "prometeus",
  "CCA": "counos-coin",
  "EOST": "eos-trust",
  "NOIZ": "noizchain",
  "BOOM": "boom",
  "DOT": "polkadot-iou",
  "YTA": "yottachain",
  "AKRO": "akropolis",
  "WNL": "winstars-live",
  "BRZ": "brz",
  "BTCF": "bitcoin-fast",
  "CBIX": "cubiex",
  "TFB": "truefeedback",
  "CVCC": "cryptoverificationcoin",
  "BAW": "bawnetwork",
  "AD": "asian-dragon",
  "IMG": "imagecoin",
  "RUNE": "thorchain",
  "BTCT": "bitcoin-token",
  "CREDIT": "credit",
  "LEVL": "levolution",
  "DAPPT": "dapp-token",
  "CPU": "cpuchain",
  "DDK": "ddkoin",
  "GMAT": "gowithmi",
  "SFX": "safex-cash",
  "BGBP": "binance-gbp-stable-coin",
  "VOL": "volume-network",
  "CCH": "coinchase",
  "UOS": "uos-network",
  "NOIA": "noia-network",
  "DYNMT": "dynamite",
  "LNX": "lnx-protocol",
  "PLG": "pledge-coin",
  "SHR": "sharetoken",
  "SWACE": "swace",
  "PCX": "chainx",
  "OPNN": "opennity",
  "XENO": "xenoverse",
  "WIN": "wink-tronbet",
  "BIRD": "birdchain",
  "MB8": "mb8-coin",
  "1UP": "uptrennd",
  "AGRO": "agrocoin",
  "EM": "eminer",
  "BOA": "bosagora",
  "XAC": "general-attention-currency",
  "MCASH": "mcashchain",
  "CREX": "crex-token",
  "GOM": "gomics",
  "FRM": "ferrum-network",
  "YO": "yobit-token",
  "LHT": "lighthouse-token",
  "MBN": "membrana",
  "3DC": "3dcoin",
  "ASG": "asgard",
  "EVT": "everitoken",
  "BPRO": "bitcloud-pro",
  "CUST": "custody-token",
  "UVU": "ccuniverse",
  "ENQ": "enecuum",
  "SON": "simone",
  "ZUC": "zeuxcoin",
  "DEEP": "deepcloud-ai",
  "CBM": "cryptobonusmiles",
  "HINT": "hintchain",
  "CRAD": "cryptoads-marketplace",
  "BTRS": "bitball-treasure",
  "ACU": "aitheon",
  "UAT": "ultralpha",
  "NYE": "newyork-exchange",
  "GT": "gatechain-token",
  "TAN": "taklimakan-network",
  "KICKS": "sessia",
  "COCOS": "cocos-bcx",
  "DEFI": "defi",
  "DTEP": "decoin",
  "SXP": "swipe",
  "TSHP": "12ships",
  "BHT": "bhex-token",
  "BF": "bitforex-token",
  "DAB": "dabanking",
  "LOT": "lukki-operating-token",
  "ZNZ": "zenzo",
  "JOB": "jobchain",
  "IOEX": "ioex",
  "LOL": "loltoken",
  "KGC": "krypton-galaxy-coin",
  "PERL": "perlin",
  "LAD": "ladder-network-token",
  "NBX": "netbox-coin",
  "RPZX": "rapidz",
  "TOKO": "tokoin",
  "VID": "videocoin",
  "TUDA": "tutors-diary",
  "CRON": "cryptocean",
  "BEST": "bitpanda-ecosystem-token",
  "STREAM": "streamit-coin",
  "MIX": "mixmarvel",
  "XPH": "phantom",
  "CLC": "caluracoin",
  "KBOT": "korbot",
  "VNXLU": "vnx-exchange",
  "VIDY": "vidy",
  "VXV": "vectorspace-ai",
  "MTXLT": "tixl",
  "BDP": "bidipass",
  "WBET": "wavesbet",
  "ECO": "ormeus-ecosystem",
  "EGG": "nestree",
  "MB": "minebee",
  "CRN": "chronocoin",
  "KSH": "kahsh",
  "EMRX": "emirex-token",
  "AMIO": "amino-network",
  "NSS": "nss-coin",
  "VENA": "vena",
  "XCT": "xcrypt-token",
  "MIDAS": "midas",
  "VOLTZ": "voltz",
  "DVP": "decentralized-vulnerability-platform",
  "CITY": "city-coin",
  "USDX": "usdx-stablecoin",
  "XDB": "digitalbits",
  "OATH": "oath-protocol",
  "PROB": "probit-token",
  "ACA": "acash-coin",
  "CYBR": "cybr-token",
  "XRM": "aerum",
  "HBAR": "hedera-hashgraph",
  "QQQ": "poseidon-network",
  "BXY": "beaxy",
  "NEWS": "publish",
  "TLOS": "telos",
  "WEC": "wave-edu-coin",
  "NODE": "whole-network",
  "MEXC": "mexc-token",
  "TEP": "tepleton",
  "GDC": "global-digital-content",
  "BAND": "band-protocol",
  "CLR": "color-platform",
  "RALLY": "rally",
  "BUSD": "binance-usd",
  "SOVE": "soverain",
  "ZANO": "zano",
  "GXT": "global-x-change-token",
  "GAP": "gaps",
  "EC": "echoin",
  "CHT": "coinhe-token",
  "IDRT": "rupiah-token",
  "BXC": "bitcoin-classic",
  "BAN": "banano",
  "PAXG": "pax-gold",
  "NEXXO": "nexxo",
  "CIPX": "colletrix",
  "XLAB": "xceltoken-plus",
  "AMON": "amond",
  "BCS": "business-credit-substitute",
  "VLX": "velas",
  "EON": "dimension-chain",
  "BIUT": "bit-trust-system",
  "VERS": "versess-coin",
  "CUT": "cutcoin",
  "ILK": "inlock",
  "ZVC": "zvchain",
  "TRN": "treelion",
  "KAASO": "kaaso",
  "EOSC": "eos-force",
  "QPY": "qpay",
  "1GOLD": "1irstgold",
  "BNY": "bancacy",
  "AZ": "azbit",
  "EBK": "ebakus",
  "HUSD": "husd",
  "TN": "turtlenetwork",
  "DRAGON": "dragon-option",
  "BFX": "bitfex",
  "MDTK": "mdtoken",
  "BTCV": "bitcoinv",
  "VOTE": "agora",
  "DILI": "d-community",
  "SPAZ": "swapcoinz",
  "MOGX": "mogu",
  "ROOBEE": "roobee",
  "VNDC": "vndc",
  "TSR": "tesra",
  "WIKEN": "project-with",
  "EBASE": "eurbase",
  "FN": "filenet",
  "XSR": "xensor",
  "DMME": "dmme",
  "KAPP": "kappi-network",
  "SYM": "symverse",
  "VERA": "vera",
  "EtLyteT": "ethlyte-crypto",
  "NOVA": "nova",
  "DSC": "dash-cash",
  "SUTER": "suterusu",
  "FLG": "folgory-coin",
  "MCH": "meconcash",
  "KAVA": "kava",
  "LINKA": "linka",
  "LAMBS": "lambda-space-token",
  "DAD": "dad-chain",
  "SCH": "schilling-coin",
  "BTZC": "beatzcoin",
  "LKU": "lukiu",
  "MES": "meschain",
  "SOZ": "secrets-of-zurich",
  "BNP": "benepit-protocol",
  "KYD": "know-your-developer",
  "GDR": "guider",
  "NWC": "newscrypto",
  "MLGC": "marshal-lion-group-coin",
  "HX": "hyperexchange",
  "YAP": "yap-stone",
  "ANCT": "anchor",
  "MGX": "margix",
  "FCQ": "fortem-capital",
  "CDL": "coindeal-token",
  "BITN": "bitcoin-and-company-network",
  "AET": "aerotoken",
  "MDM": "medium",
  "JDC": "jd-coin",
  "MZG": "moozicore",
  "KUV": "kuverit",
  "BPX": "bispex",
  "DAI": "multi-collateral-dai",
  "TRB": "tellor",
  "VINCI": "vinci",
  "CKB": "nervos-network",
  "999": "999-coin",
  "LCX": "lcx",
  "ZYN": "zynecoin",
  "CXC": "capital-x-cell",
  "MAP": "marcopolo-protocol",
  "PCM": "precium",
  "ERK": "eureka-coin",
  "JUL": "joule",
  "OURO": "ouroboros",
  "NIRX": "nairax",
  "EXM": "exmo-coin",
  "NST": "newsolution",
  "PEG": "pegnet",
  "TAGZ5": "tagz5",
  "DMTC": "demeter-chain",
  "ARDX": "ardcoin",
  "HGH": "hgh-token",
  "TDPS": "tradeplus",
  "HCA": "harcomia",
  "DAVP": "davion",
  "SCAP": "safecapital",
  "BLOCS": "blocs",
  "ARX": "arcs",
  "TROY": "troy",
  "ARTIS": "artis-turba",
  "SGA": "saga",
  "HEX": "hex",
  "CALL": "global-crypto-alliance",
  "ALLBI": "all-best-ico",
  "OXT": "orchid",
  "ROAD": "road",
  "CMB": "creatanium",
  "KSM": "kusama",
  "HTX": "huptex",
  "STS": "sbank",
  "QURA": "qura-global",
  "LTB": "litbinex-coin",
  "BAZ": "bazooka-token",
  "BFC": "bitcoin-free-cash",
  "BULL": "3x-long-bitcoin-token",
  "HLX": "helex",
  "USDA": "usda",
  "XNC": "xenioscoin",
  "BEPRO": "betprotocol",
  "WOW": "wowsecret",
  "AXL": "axial-entertainment-digital-asset",
  "USDN": "neutrino-dollar",
  "FLT": "flit-token",
  "XTP": "tap",
  "RKN": "rakon",
  "EGR": "egoras",
  "THE": "thenode",
  "APM": "apm-coin",
  "CUR": "curio",
  "PLF": "playfuel",
  "BCB": "building-cities-beyond-blockchain",
  "CBUCKS": "cryptobucks",
  "VMR": "vomer",
  "onLEXpa": "onlexpa",
  "HANA": "hanacoin",
  "NZO": "enzo",
  "IPX": "tachyon-protocol",
  "1AI": "1ai-token",
  "KAM": "bitkam",
  "SURE": "insure",
  "CNB": "coinsbit-token",
  "KRT": "terra-krw",
  "OGN": "origin-protocol",
  "EUSD": "egoras-dollar",
  "HTDF": "orient-walt",
  "NYZO": "nyzo",
  "HP": "heartbout-pay",
  "BEAR": "3x-short-bitcoin-token",
  "WEST": "waves-enterprise",
  "WRX": "wazirx",
  "XAUT": "tether-gold",
  "WDC": "wisdom-chain",
  "KOK": "keystone-of-opportunity-knowledge",
  "XT": "extstock-token",
  "UNOC": "unochain",
  "MTT": "meettoken",
  "GLEEC": "gleec",
  "R2R": "citios",
  "WPX": "wallet-plus-x",
  "MALW": "malwarechain",
  "ETHBEAR": "3x-short-ethereum-token",
  "ETHBULL": "3x-long-ethereum-token"
}

