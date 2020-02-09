#!/bin/bash
#
# metals.sh -- <metals-api.com> precious metal rates api access
# v0.1  feb/2020  by mountaineerbr

#your own personal api key
#METALSAPIKEY=''

#defaults
#number of decimal plates (scale):
SCLDEFAULTS=20   #bash calculator defaults is 20 plus one uncertainty digit

#don't change these
LC_NUMERIC='en_US.UTF-8'
#troy ounce to gram ratio
TOZ='31.1034768'

#manual and help
HELP_LINES="NAME
 	metals.sh -- precious metal rates api access from <metals-api.com>


SYNOPSIS

	metals.sh [-tg] [-sNUM] [AMOUNT] FROM_CURRENCY TO_CURRENCY

	metals.sh [-hjlv]


DESCRIPTION
	This programme fetches updated precious metals and bank currency rates 
	from <metals-api.com> and can convert any amount of one supported cur-
	rency into another.

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

		$ metals.sh \"\e[0;33;40mAMOUNT\033[00m*31.1\" eur xau 


	One EUR in grams of Gold:

		$ metals.sh \"\e[1;33;40m1\033[00m*31.1\" eur xau 
		
		$ metals.sh -g 1 eur xau 


	To get \e[0;33;40mAMOUNT\033[00m of grams of Gold in EUR, just divide AMOUNT by
	the \"GRAM/OUNCE\" constant.

		$ metals.sh \"\e[0;33;40m[amount]\033[00m/31.1\" xau usd 
	

	One gram of Gold in EUR:
			
		$ metals.sh \"\e[1;33;40m1\033[00m/31.1\" xau eur 
		
		$ metals.sh -g 1 xau eur 


API KEY AND LIMITS
	Please create a free API key and add it to the script source-code or set
	it as an environment variable as 'METALSAPIKEY'.

	The free plan should get currency updates every hour only it has a limit
	of 50 requests per month. Please, access <https://metals-api.com/register>
	and sign up for a free private API key.


WARRANTY
	Licensed under the GNU Public License v3 or better. This programme is 
	distributed without support or bug corrections.

	If you found this script useful, consider giving me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


BUGS
	There seems to be some bugs with the API, so it was not possible to im-
	plement historical rates nor rate time series.

	Server returns returns an error page for rhodium XRH but it should be 
	supported as per API documentation. Temporary server error?


USAGE EXAMPLES
		(1) One ounce troy of silver in USD

			$ metals.sh xag

			$ metals.sh 1 xag usd

		
		(2) One Canadian Dollar in US Dollar, two decimal plates:

			$ metals.sh -s2 1 cad usd

			$ metals.sh -2 cad usd


		(3) 50 Djiboutian Franc in Chinese Yuan with three decimal 
		    plates (scale):

			$ metals.sh -s3 50 djf cny


		(4) One CAD in JPY using math expression in AMOUNT:
			
			$ metals.sh -2 '(3*15.5)+40.55' cad jpy


OPTIONS
	-NUM 	  Shortcut for scale setting, same as '-sNUM'.

	-g 	  Use grams instead of troy ounces; only for precious metals.
		
	-h 	  Show this help.

	-j 	  Debug; print JSON.

	-l 	  List supported currencies.

	-s NUM    Set decimal plates; defaults=${SCLDEFAULTS}.

	-t 	  Print timestamp.
	
	-v 	  Show this programme version."

#list symbols
listf() {
	#list
	LIST="$(curl -s "https://metals-api.com/api/symbols?access_key=$METALSAPIKEY"|jq -r 'keys[] as $k | "\($k) \(.[$k])"')"
	printf '%s\n' "${LIST}"
	printf 'Symbols: %s\n' "$(wc -l <<<"${LIST}")"
	exit
}

#check for error response
errf() {
	if [[ "$(jq -r '.success' <<<"${JSON}" 2>/dev/null)" = false ]]; then
		jq -r '.error.info' <<<"${JSON}" 1>&2
		exit 1
	elif grep -oi 'Whoops, looks like something went wrong.' <<<"${JSON}" 1>&2; then
		exit 1
	fi
}

#precious metals in grams?
ozgramf() {	
	#troy ounce to gram
	#currencylayer does not support platinum(xpt) and palladium(xpd) yet
	if [[ -n "${GRAMOPT}" ]]; then
		if grep -qi -e XAU -e XAG -e XPD -e XPT -e XRH <<<"${1}"; then
			FMET=1
		fi
		if grep -qi -e XAU -e XAG -e XPD -e XPT -e XRH <<<"${2}"; then
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
			LISTOPT=1
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

#call opt functions
[[ -n "${LISTOPT}" ]] && listf


#check for any arg
if [[ -z "${*}" ]]; then
	printf 'Run with -h for help.\n' 1>&2
	exit 1
fi

#check for api key
if [[ -z "${METALSAPIKEY}" ]]; then
	printf 'Create a free api key and set it in the script or export it as an environment variable.\n' 1>&2
	exit 1
fi

#set default scale if no custom scale
if [[ -z ${SCL} ]]; then
	SCL=${SCLDEFAULTS}
fi

#set equation arquments
if ! [[ ${1} =~ [0-9] ]]; then
	set -- 1 "${@}"
fi

if [[ ! "${3^^}" =~ ^[A-Z]+$  ]]; then
	set -- "${@:1:2}" USD "${@:3}"
fi

#historical price? -- does not seem to work
#[[ -n "${4}" ]] && DATE="&end_date=${4//\//-}"

#get json once
JSON="$(curl -sL "http://metals-api.com/api/convert?access_key=${METALSAPIKEY}&from=${2^^}&to=${3^^}")"
#&amount=1
#&date=YYY-MM-DD -- does not seem to work

#print json?
if [[ -n ${PJSON} ]]; then
	printf '%s\n' "${JSON}"
	exit 0
fi

#test for error
errf

#get rate
RATE="$(jq -r '.info.rate' <<<"${JSON}")"

#transform 'e' to '*10^'
RATE=$(sed 's/[eE]/*10^/g' <<< "${RATE}")

#print timestamp?
if [[ -n ${TIMEST} ]]; then
	JSONTIME="$(jq '.info.timestamp' <<< "${JSON}")"
	date -d@"$JSONTIME" '+#%FT%T%Z'
fi

#precious metals in grams?
ozgramf "${2}" "${3}"

#calc equation and print result
bc -l <<< "scale=${SCL};(((${1})*${RATE})${GRAM}${TOZ})/1;"

