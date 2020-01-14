#!/bin/bash
# stocks.sh  -- Stock and index rates in Bash
# v0.1.4  jan/2020  by mountaineerbr

##defaults
#stock
DEFSTOCK="TSLA"
#don't change the following:
LC_NUMERIC="en_US.UTF-8"

HELP="NAME
	stocks.sh  -- Stock and index rates in Bash


SYNOPSIS
	stocks.sh [-H] [SYMBOL]

	stocks.sh -ip [INDEX]

	stocks.sh -hlv


 	Fetch rates of stocks and indexes from <https://financialmodelingprep.com/>
	public APIs. If no symbol is given, defaults to ${DEFSTOCK}. Stock and
	index symbols are case-insensitive.


LIMITS
	Cryptocurrency rates will not be implemented.

	Stock prices should be updated in realtime, company profiles hourly, 
	historial prices and others daily. See 
	<https://financialmodelingprep.com/developer/docs/>. 

	According to discussion at
	<https://github.com/antoinevulcain/Financial-Modeling-Prep-API/issues/1>:

		\"[..] there are no limit on the number of API requests per day.\"


WARRANTY
	Licensed under the GNU Public License v3 or better and is distributed
	without support or bug corrections.
   	
	This script needs Bash,	cURL or Wget and JQ to work properly.

	That is _not_ advisable to depend solely on this script for serious 
	trading. Do your own research!

	If you found this useful, consider giving me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES

	( 1 ) 	Price of Tesla:
		
		$ stocks.sh TSLA 


	( 2 )   List all symbols and look for oil stocks:

		$ stocks.sh -l | grep Oil


	( 3 )   All major indexes:

		$ stocks.sh -i


	( 4 )   Nasdaq index rate only:

		$ stocks.sh -i .IXIC


OPTIONS
	-h           Show this Help.
	
	-H [SYMBOL]  Historical prices

	-i [INDEX]   List all major indexes or only a single one, if given.
	
	-j           Debug, prints json.

	-l           List supported symbols and their rates.

	-p [SYMBOL]  Profile ticker.  

	-v           Show this script version."

##functions

#historical prices
histf() {
	DATA="$(${YOURAPP} "https://financialmodelingprep.com/api/v3/historical-price-full/${1^^}?serietype=line")"
	#print json? (debug)
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${DATA}"
		exit 0
	fi
	
	HIST="$(jq -r '(.historical[]|"\(.date)  \(.close)")' <<<"${DATA}")"
	printf "%s\n" "${HIST}" | column -et -N'date,close'
	jq -r '"Symbol: \(.symbol)"' <<<"${DATA}"
	printf "Registers: %s\n" "$(wc -l <<<"${HIST}")"

	exit
}

#list stock/index symbols
indexf() {
	DATA="$(${YOURAPP} "https://financialmodelingprep.com/api/v3/majors-indexes")"
	#print json? (debug)
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${DATA}"
		exit 0
	fi
	
	#list one index by symbol
	if jq -er '.majorIndexesList[]|select(.symbol == "'${1^^}'")' <<<"${DATA}" 2>/dev/null; then
		jq -r '.majorIndexesList[]|select(.symbol == "'${1^^}'")|.price' <<<"${DATA}"
	#list all major indexes
	else
		#test if stdout is to tty
		[[ -t 1 ]] && TRIMCOL="-Tname" 
		INDEX="$(jq -r '.majorIndexesList[]|"\(.ticker)=\(.price)=\(.changes)=\(.indexName)"' <<<"${DATA}")"
		sort <<<"${INDEX}" | column -et -s= -N'ticker,price,change,name' ${TRIMCOL}
		printf 'Indexes: %s\n' "$(wc -l <<<"${INDEX}")"
	fi
	
	exit
}

#list stock/index symbols
listf() {
	DATA="$(${YOURAPP} "https://financialmodelingprep.com/api/v3/company/stock/list")"
	#print json? (debug)
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${DATA}"
		exit 0
	fi
	
	#test if stdout is to tty
	[[ -t 1 ]] && TRIMCOL="-Tname" 
	
	LIST="$(jq -r '.symbolsList[]|"\(.symbol)=\(.price)=\(.name)"' <<<"${DATA}")"
	sort <<<"${LIST}" | column -et -s= -N'symbol,price,name' ${TRIMCOL}
	printf 'Symbols: %s\n' "$(wc -l <<<"${LIST}")"
	
	exit
}

#simple profile ticker
profilef() {
	#get data
	#DATA="$(${YOURAPP} "https://financialmodelingprep.com/api/v3/company/profile/${1^^}")"
	DATA="$(cat ~/test)"

	#print json? (debug)
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${DATA}"
		exit 0
	fi
	
	#process tocker data
	jq -r '"Profile ticker for \(.symbol)",
	(.profile|
		"CorpName: \(.companyName)",
		"CEO_____: \(.ceo//empty)",
		"Industry: \(.industry)",
		"Sector__: \(.sector)",
		"Exchange: \(.exchange)",
		"Cap_____: \(.mktCap)",
		"LastDiv_: \(.lastDiv)",
		"Beta____: \(.beta)",
		"Price___: \(.price)",
		"VolAvg__: \(.volAvg)",
		"Range___: \(.range)",
		"Change__: \(.changes)",
		"Change%_: \(.changesPercentage)"
	)' <<<"${DATA}"

	exit
}

#test if stock symbol is valid
testsf() {
	if ${YOURAPP} "https://financialmodelingprep.com/api/v3/company/stock/list" |
		jq -r '.symbolsList[].symbol' | grep -q "${1^^}"; then
		return 0
	else
		printf "Unsupported symbol -- %s\n" "${1^^}" 1>&2
		exit 1
	fi
}

# Parse options
while getopts ":hHijlpv" opt; do
	case ${opt} in
		( h ) #help
			printf "%s\n" "${HELP}"
			exit 0
			;;
		( H ) #historical prices
			HOPT=1
			;;
		( i ) #indexes
			IOPT=1
			;;
		( j ) #debug; print json
			PJSON=1
			;;
		( l ) #list symbols
			LOPT=1
			;;
		( p ) #simple profile ticker
			POPT=1
			;;
		( v ) #version of this script
			grep -m1 '\# v' "${0}"
			exit 0
			;;
		( \? )
			printf "Invalid option: -%s\n" "${OPTARG}" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

#test for must have packages
if ! command -v jq &>/dev/null; then
	printf "JQ is required.\n" 1>&2
	exit 1
fi
if command -v curl &>/dev/null; then
	YOURAPP="curl -sL"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO-"
else
	printf "cURL or Wget is required.\n" 1>&2
	exit 1
fi

##call opt functions
#list symbols
test -n "${LOPT}" && listf
#major indexes (full list or single index)
test -n "${IOPT}" && indexf "${1}"

#set defaults stock symbol if no arg given
if [[ -z "${1}" ]]; then
	set -- "${DEFSTOCK}"
else
	#test symbol
	testsf "${1}"
fi

##call opt functions
#simple company profile ticker
test -n "${POPT}" && profilef "${1}"
#historical prices
test -n "${HOPT}" && histf "${1}"

#default function, get stock/index rate
${YOURAPP} "https://financialmodelingprep.com/api/v3/stock/real-time-price/${1^^}" | jq -r '.price'

exit 

##Dead code

