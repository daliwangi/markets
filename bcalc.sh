#!/bin/bash
# Bcalc.sh -- Easy Calculator for Bash
# v0.4.37  2019/dec/06  by mountaineerbr

## Defaults
#Record file:
RECFILE="${HOME}/.bcalc_record"
#Extensions file:
EXTFILE="${HOME}/.bcalc_extensions"
#Number of decimal plates:
#Bc mathlib defaults is 20 (plus one uncertainty digit)
SCLDEF=20
#Enable Record file?
BCREC=1  #enable=1 (defaults), disable=0

# Don't change this
LC_NUMERIC="en_US.UTF-8"

## Manual and help
HELP_LINES="NAME
 	\033[01;36mBcalc.sh -- Easy Calculator for Bash\033[00m


SYNOPSIS
	bcalc.sh  [-cft] [-s'NUM'|-NUM] ['EQUATION']
	
	bcalc.sh  [-n 'SHORT NOTE']

	bcalc.sh  [-cchrv]


DESCRIPTION
	Bcalc.sh uses the powerful Bash Calculator (Bc) and adds some useful 
	features.

	A record file is created at \"${RECFILE}\".
	To disable using a record file set option \"-f\" or BCREC=0 in the 
	script head code, section Defaults. If a record file can is available,
	use of \"ans\" in EXPRESSION is swapped by the last result from record
	file. 
	
	If no EXPRESSION is given, wait for Stdin (from pipe) or user input. 
	Press \"Ctr+D\" to send the EOF signal. If input is empty, prints last
	answer from record.

	Equations containing () with backslashes may need escaping with \"\" or ''.

	Decimal separator must be a dot \".\". Number of decimal plates (scale)
	can be set with option \"-s\". Results with thousands separator can be 
	printed with option \"-t\" in which case a comma \",\" is used.


BC MATH LIBRARY
	Bcalc.sh uses Bc with the math library. From Bc man page:       


		The math  library  defines the following functions:

		s (x)  The sine of x, x is in radians.

		c (x)  The cosine of x, x is in radians.

		a (x)  The arctangent of x, arctangent returns radians.

		l (x)  The natural logarithm of x.

		e (x)  The exponential function of raising e to the value x.

		j (n,x)
		       The Bessel function of integer order n of x.


SCIENTIFIC EXTENSION
	
	The scientific option will try to download a copy of a table of scien-
	tific constants and extra math functions such as ln and log to 
	\"${EXTFILE}\"
	Once downloaded, it is kept for future use. Download of extensions re-
	quires Wget or cURL.

	Extensions from:

		<http://x-bc.sourceforge.net/scientific_constants.bc>
		
		<http://x-bc.sourceforge.net/extensions.bc>


BASH ALIAS
	Consider creating a bash alias. Add to your ~/.bashrc:
	
		alias c=\"/path/to/bcalc.sh\"

	
	There are two ingenius ways for using native Bc with Bash.

		c() { echo \"\${*}\" | bc -l;}
		
		alias c=\"bc -l <<<'\"
	

	In the latter, user must type a  '  sign to end expression.
	

USAGE EXAMPLES
			$ bcalc.sh 50.7+9

			$ bcalc.sh '(100+100/2)*2' 

			$ bcalc.sh 2^2+(8-4)

			$ bcalc.sh \\\\(100+100\\\\)/1

			$ bcalc.sh -0.2*10
			
			$ bcalc.sh ans+33
			
			$ bcalc.sh -s2 100/120

			$ bcalc.sh -t -2 50000*5

			$ echo '70000.450000' | bcalc.sh -t2
			
			$ bcalc.sh -c 'ln(0.3)'
			
			$ bcalc.sh -c 0.234*na   #\"na\" is Avogadro's constant

			$ bcalc.sh 'a=5; -a+20'

			$ bcalc.sh -n This is my note.


BUGS
	Made and tested with Bash 5.0. This programme is distributed without 
	support or bug corrections. Licensed under GPLv3 and above.

	Give me a nickle! =)
        

	  bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


OPTIONS
		-NUM 	Shortcut for scale setting, same as \"-sNUM\".

		-c 	Use scientific extensions; pass twice to print exten-
			sions.
    		
		-f 	Do not use a record file.

    		-h 	Show this help.

		-n 	Add note to last result record; it should be used after 
			an answer is recorded to record file.
    		
		-r 	Print results record.
    		
		-s 	Set scale (decimal plates); defaults=${SCLDEF}; Bc only
			uses this scale setting if there is a division operation.

		-t 	Thousands separator.

		-v 	Print this script version."


## Functions
# Scientific Extension Function
setcf() {
	#test if extensions file exists, if not download it from the internet
	if ! [[ -f "${EXTFILE}" ]]; then
		#test for cURL or Wget
		if command -v curl &>/dev/null; then
			YOURAPP="curl"
		elif command -v wget &>/dev/null; then
			YOURAPP="wget -O-"
		else
			printf "cURL or Wget is required.\n" 1>&2
			exit 1
		fi
		#download extensions
		{ ${YOURAPP} "http://x-bc.sourceforge.net/scientific_constants.bc"
			printf "\n"
			${YOURAPP} "http://x-bc.sourceforge.net/extensions.bc"
			printf "\n";} > "${EXTFILE}"
	fi
	#print extension file?
	if [[ "${CIENTIFIC}" -eq 2 ]]; then
		cat "${EXTFILE}"
		exit
	fi
	#set extensions for use with Bc
	EXT="$(cat "${EXTFILE}")"
}

# Add Note function
notef() {
	if [[ -n "${*}" ]]; then
		sed -i "$ i\>> ${*}" "${RECFILE}"
		exit 0
	else
		printf "Note is empty.\n" 1>&2
		exit 1
	fi
}
# https://superuser.com/questions/781558/sed-insert-file-before-last-line
# http://www.yourownlinux.com/2015/04/sed-command-in-linux-append-and-insert-lines-to-file.html

# Calc expression funtions
res0f() { bc -l <<<"${EXT};${EQ}";}
res3f() { bc -l <<<"${EXT};scale=${SCL};${EQ}/1;";}


# Parse options
while getopts ":cfhnrs:tv1234567890" opt; do
	case ${opt} in
		( [0-9] ) #scale, same as '-sNUM'
			SCL="${SCL}${opt}"
			;;
		( c ) #run calc with cientific extensions
		    #print cientific extensions ?
			[[ -z "${CIENTIFIC}" ]] && CIENTIFIC=1 || CIENTIFIC=2
			PEXT=1
			;;
		( f ) #no record file
			BCREC=0
			;;
		( h ) #show this help
			echo -e "${HELP_LINES}"
			exit
			;;
		( n ) #disable record file
			NOTEOPT=1
			;;
		( r ) #print record
			if [[ -f "${RECFILE}" ]]; then
				cat "${RECFILE}"
				exit 0
			else
				printf "No record file.\n" 1>&2
				exit 1
			fi
			;;
		( s ) #scale (decimal plates)
			SCL="${OPTARG}"
			;;
		( t ) #thousands separator
			TOPT=1
			;;
		( v ) #show this script version
			head "${0}" | grep -e "^# v"
			exit 0
			;;
		( \? )
	     		break
			;;
	esac
done
shift $((OPTIND -1))

## Check if there is a Record file available
# otherwise, create and initialise one
if [[ "${BCREC}" -eq 1 ]] && [[ ! -f "${RECFILE}" ]]; then
	printf "## Bcalc.sh Record\n1\n" >> "${RECFILE}"
	printf "File initialised: %s\n" "${RECFILE}" 1>&2
fi

## Add note to record
if [[ -n "${NOTEOPT}" ]]; then
	if [[ -f "${RECFILE}" ]]; then
		notef "${*}"
	else
		printf "Note function requires a record file.\n" 1>&2
		exit 1
	fi
fi

## Set scale
[[ -z ${SCL} ]] && SCL="${SCLDEF}"
## Load cientific extensions?
[[ -n "${CIENTIFIC}" ]] && setcf

## Process Expression
EQ="${*:-$(</dev/stdin)}"
EQ="${EQ//,}"

# If BCREC is true, try to grep last answer
if [[ -n "${BCREC}" ]]; then
	#swap 'ans' by last result
	if [[ "${EQ}" =~ ans ]]; then 
		ANS=$(tail -n1 "${RECFILE}")
		EQ="${EQ//ans/(${ANS})}"
	#if no expression at all, grep last result
	elif [[ -z "${EQ}" ]]; then
		EQ="$(tail -n1 "${RECFILE}")"
	fi
fi

## Calc result and check expression syntax
RES="$(res0f 2>/dev/null)"; RES1="$(res0f 2>&1 1>/dev/null)"
if [[ -n "${RES1}" ]]; then
	printf "%s\n" "${RES1}"
	exit 1
else
	RES3="$(res3f 2>/dev/null)"
fi

# Print equation to record file?
if [[ "${BCREC}" -eq 1 ]]; then
	if [[ "${RES}" != $(tail -1 "${RECFILE}") ]]; then
		#print timestamp
		printf "## %s\n## { %s }\n" "$(date "+%FT%T%Z")" "${EQ}" 1>> "${RECFILE}"
		#print original result
		printf "%s\n" "${RES}" >> "${RECFILE}"
	fi
fi

## Format result and print
if [[ -n "${TOPT}" ]]; then
	#thousands separator
	printf "%'.${SCL}f\n" "${RES3:-${RES}}"
else
	printf "%s\n" "${RES3:-${RES}}"
fi

exit

