#!/bin/bash
#
# clay.sh -- <currencylayer.com> currency rates api access
# v0.4.11  feb/2020  by mountaineerbr

#your own personal api key
#CLAYAPIKEY=''

#defaults
#number of decimal plates (scale):
SCLDEFAULTS=20   #bash calculator defaults is 20 plus one uncertainty digit

#don't change these
LC_NUMERIC='en_US.UTF-8'
#troy ounce to gram ratio
TOZ='31.1034768'

#manual and help
#usage: clay.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	Clay.sh -- Currency Converter
		   CurrencyLayer.com API Access


SYNOPSIS

	clay.sh [-tg] [-sNUM] [AMOUNT] FROM_CURRENCY TO_CURRENCY

	clay.sh [-hjlv]


DESCRIPTION
	This programme fetches updated currency rates from the internet	and can
	convert any amount of one supported currency into another.

	Free plans should get currency updates daily only. It supports very few 
	cyrpto currencies. Please, access <https://currencylayer.com/> and sign
	up for a free private API key.

	Bash Calculator uses a dot '.' as decimal separtor. Default precision
	is ${SCLDEFAULTS}, plus an uncertainty digit.

		
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
	TOZ that will hold the GRAM/OZ constant:
	
		TOZ=\"${TOZ}\"
	
	
	To get \e[0;33;40mAMOUNT\033[00m of EUR in grams of Gold, just multiply AMOUNT by
	the \"GRAM/OUNCE\" constant.

		$ clay.sh \"\e[0;33;40mAMOUNT\033[00m*31.1\" eur xau 


	One EUR in grams of Gold:

		$ clay.sh \"\e[1;33;40m1\033[00m*31.1\" eur xau 
		
		$ clay.sh -g 1 eur xau 


	To get \e[0;33;40mAMOUNT\033[00m of grams of Gold in EUR, just divide AMOUNT by
	the \"GRAM/OUNCE\" constant.

		$ clay.sh \"\e[0;33;40m[amount]\033[00m/31.1\" xau usd 
	

	One gram of Gold in EUR:
			
		$ clay.sh \"\e[1;33;40m1\033[00m/31.1\" xau eur 
		
		$ clay.sh -g 1 xau eur 


API KEY
	Please create a free API key and add it to the script source-code or set
	it as an environment variable as 'CLAYAPIKEY'.


WARRANTY
	Licensed under the GNU Public License v3 or better. This programme is 
	distributed without support or bug corrections.

	If you found this script useful, consider giving me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES
		
		(1) One Canadian Dollar in US Dollar, two decimal plates:

			$ clay.sh -s2 1 cad usd

			$ clay.sh -2 cad usd


		(2) 50 Djiboutian Franc in Chinese Yuan with three decimal 
		    plates (scale):

			$ clay.sh -s3 50 djf cny

		(3) One CAD in JPY using math expression in AMOUNT:
			
			$ clay.sh -2 '(3*15.5)+40.55' cad jpy


OPTIONS
	-NUM 	  Shortcut for scale setting, same as '-sNUM'.

	-g 	  Use grams instead of troy ounces; only for precious metals.
		
	-h 	  Show this help.

	-j 	  Debug; print JSON.

	-l 	  List supported currencies.

	-s NUM    Set decimal plates; defaults=${SCLDEFAULTS}.

	-t 	  Print timestamp.
	
	-v 	  Show this programme version."

#precious metals in grams?
ozgramf() {	
	#troy ounce to gram
	#currencylayer does not support platinum(xpt) and palladium(xpd) yet
	if [[ -n "${GRAMOPT}" ]]; then
		if grep -qi -e 'XAU' -e 'XAG' <<<"${1}"; then
			FMET=1
		fi
		if grep -qi -e 'XAU' -e 'XAG' <<<"${2}"; then
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
while getopts ':1234567890lghjs:tv' opt; do
	case ${opt} in
		( [0-9] ) #scale, same as '-sNUM'
			SCL="${SCL}${opt}"
			;;
		( l ) #list available currencies
			LIST="$(curl -s 'https://currencylayer.com/site_downloads/cl-currencies-table.txt' | sed -e 's/<[^>]*>//g' -e 's/^[ \t]*//' -e '/^$/d'| sed -e '$!N;s/\n/ /')"
			printf '%s\n' "${LIST}"
			printf 'Currencies: %s\n' "$(($(wc -l <<<"${LIST}")-1))" 
			exit 0
			;;
		( g ) #gram opt
			GRAMOPT=1
			;;
		( h ) #help
			echo -e "${HELP_LINES}"
			exit 0
			;;
		( j ) #print json
			PJSON=1
			;;
		( s ) #decimal plates
			SCL=${OPTARG}
			;;
		( t ) #print Timestamp with result
			TIMEST=1
			;;
		( v ) #version
			grep -m1 '# v' "${0}"
			exit
			;;
		( \? )
			printf 'Invalid option: -%s\n' "$OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

#check for any arg
if [[ -z "${*}" ]]; then
	printf 'Run with -h for help.\n' 1>&2
	exit 1
fi

#check for api key
if [[ -z "${CLAYAPIKEY}" ]]; then
	printf 'Create a free api key and set it in the script or export it as an environment variable.\n' 1>&2
	exit 1
fi

#set default scale if no custom scale
if [[ -z ${SCL} ]]; then
	SCL=${SCLDEFAULTS}
fi

#set equation arquments
if ! [[ ${1} =~ [0-9] ]]; then
	set -- 1 "${@:1:2}"
fi

if [[ -z ${3} ]]; then
	set -- "${@:1:2}" USD
fi

#get json once
CLJSON="$(curl -s "http://www.apilayer.net/api/live?access_key=${CLAYAPIKEY}")"

#print json?
if [[ -n ${PJSON} ]]; then
	printf '%s\n' "${CLJSON}"
	exit 0
#test for error
elif [[ "$(jq -r '.success' <<<"${CLJSON}")" = false ]]; then
	jq -r '.error|.code//empty,.info//empty' <<<"${CLJSON}"
	exit 1
fi

#get currency rates
if ! [[ ${2^^} = USD && ${3^^} = USD ]]; then
	FROMCURRENCY=$(jq ".quotes.USD${2^^}" <<< "${CLJSON}")
	TOCURRENCY=$(jq ".quotes.USD${3^^}" <<< "${CLJSON}")
elif [[ ${2^^} = USD ]]; then
	FROMCURRENCY=1
	TOCURRENCY=$(jq ".quotes.USD${3^^}" <<< "${CLJSON}")
elif [[ ${3^^} = USD ]]; then
	FROMCURRENCY=$(jq ".quotes.USD${2^^}" <<< "${CLJSON}")
	TOCURRENCY=1
fi

#transform 'e' to '*10^'
if [[ "${FROMCURRENCY}" =~ e ]]; then
	FROMCURRENCY=$(sed 's/[eE]/*10^/g' <<< "${FROMCURRENCY}")
fi
if [[ "${TOCURRENCY}" =~ e ]]; then
	TOCURRENCY=$(sed 's/[eE]/*10^/g' <<< "${TOCURRENCY}") 
fi

#print timestamp?
if [[ -n ${TIMEST} ]]; then
	JSONTIME=$(jq '.timestamp' <<< "${CLJSON}")
	date -d@"$JSONTIME" '+#%FT%T%Z'
fi

#precious metals in grams?
ozgramf "${2}" "${3}"

#calc equation and print result
bc -l <<< "scale=${SCL};(((${1})*${TOCURRENCY}/${FROMCURRENCY})${GRAM}${TOZ})/1;"

