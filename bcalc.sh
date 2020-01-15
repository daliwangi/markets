#!/bin/bash
# Bcalc.sh -- Simple Calculator Wrapper for Bash
# v0.5.5 jan/2020  by mountaineerbr

## Defaults

#Enable Record file?
#comment out to disable
BCREC=1

#Record file:
RECFILE="${HOME}/.bcalc_record"

#Extensions file:
EXTFILE="${HOME}/.bcalc_extensions"

# Don't change these:
#length of result line
#newer versions of bash accept '0' to disable multiline
export BC_LINE_LENGTH=1000
#make sue numeric locale is set correctly
LC_NUMERIC='en_US.UTF-8'

## Manual and help
HELP_LINES="NAME
	Bcalc.sh -- Simple Calculator Wrapper for Bash


SYNOPSIS
	bcalc.sh  [-cft] [-s'NUM'|-NUM] ['EXPRESSION']

	bcalc.sh  [-n 'SHORT NOTE']

	bcalc.sh  [-cchrv]


DESCRIPTION
	Bcalc.sh uses the powerful Bash Calculator (Bc) with its math library
	and adds some useful features described below.

	A record file is created at '${RECFILE}'
	To disable using a record file set option '-f' or unset BCREC in the 
	script head code, section Defaults. If a record file is available, use 
	of 'ans' (lowercase) in EXPRESSION is swapped by the last result from 
	the record file.

	If no EXPRESSION is given, wait for for Stdin (from pipe) or user input.
	Press 'Ctr+D' to send the EOF signal, as in Bc. If no user EXPRESSION
	was given so far, prints last answer from the record file.

	EXPRESSIONS containing () or * may need escaping with '\\' or \"''\", de-
	pending on your shell.

	The number of decimal plates (scale) of output floating point numbers is
	dependent on user input for all operations except division, as in pure
	Bc. Mathlib scale defaults to 20 plus one uncertainty digit and the sci-
	entific extensions defaults to 100. If option '-s' is not set explicitly,
	trailing zeroes will be trimmed by a special Bc function before being 
	printed to screen.

	Remember that the decimal separator must be a dot '.'. Results with a
	thousands separator can be obtained with option '-t', in which case a
	comma ',' is used as thousands delimiter but decimal precision may be-
	come limited or deteriorated if the resulting value has more than 20 
	decimal plates.


BC MATH LIBRARY
	Bcalc.sh uses Bc with the math library. Useful functions from Bc man:


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
	tific constants and extra math functions such as 'ln' and 'log'. Once 
	downloaded, it will be kept for future use. Download of extensions re-
	quires Wget or cURL and will be placed at '${EXTFILE}'

	Extensions from:

		<http://x-bc.sourceforge.net/scientific_constants.bc>

		<http://x-bc.sourceforge.net/extensions.bc>


BASH ALIASES
	Consider creating a bash alias. Add to your ~/.bashrc:

		alias c='/path/to/bcalc.sh'


	There are two ingenius functions for using pure Bc in Bash:

		c() { echo \"\${*}\" | bc -l;}

		alias c=\"bc -l <<<'\"


	In the latter, user must type a  \"'\" sign after the expression to end
	quoting.


WARRANTY
	Made and tested with Bash 5.0. This programme is distributed without
	support or bug corrections. Licensed under GPLv3 and above.

	If useful, consider giving me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr

	  
USAGE EXAMPLES
		$ bcalc.sh 50.7+9

		$ bcalc.sh '-(100+100/2)*2'

		$ bcalc.sh 2^2+(8-4)

		$ bcalc.sh \\\\(100+100\\\\)/1

		$ bcalc.sh ans+33

		$ bcalc.sh -s2 100/120
		
		$ bcalc.sh 'scale=2;100/120'

		$ bcalc.sh -t -2 50000\\*5

		$ bcalc.sh 'a=5; -a+20'

		$ echo '70000.450000' | bcalc.sh -t2

		$ bcalc.sh -c 'ln(0.3)'

		$ bcalc.sh -c 0.234*na  #'na' is Avogadro's constant

		$ bcalc.sh -n This is my note.


OPTIONS
	-NUM 	Shortcut for scale setting, same as '-sNUM'.

	-c 	Use scientific extensions; pass twice to print extensions.

	-f 	Do not use a record file.

	-h 	Show this help.

	-n 	Add note to last result in the record file.

	-r 	Print record file.

	-s 	Set scale (decimal plates).

	-t 	Thousands separator.

	-v 	Print this script version."


## Functions

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
	#scientific extensions defaults scale=100
	EXT="$(<"${EXTFILE}")"
}


# Parse options
while getopts ":0123456789cfhnrs:tv" opt; do
	case ${opt} in
		( [0-9] ) #scale, same as '-sNUM'
			SCL="${SCL}${opt}"
			;;
		( c ) #load cientific extensions
		      #twice to print cientific extensions
			[[ -z "${CIENTIFIC}" ]] && CIENTIFIC=1 || CIENTIFIC=2
			;;
		( f ) #no record file
			unset BCREC
			;;
		( h ) #show this help
			printf "%s\n" "${HELP_LINES}"
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
			grep -m1 "^# v" "${0}"
			exit 0
			;;
		( \? )
			printf "Invalid option: -%s\n" "${OPTARG}" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

#set more opts
#retest record file option
[[ "${BCREC}" != "1" ]] && unset BREC

## Process Expression
EQ="${*:-$(</dev/stdin)}"
EQ="${EQ//,}"

## Check if there is a Record file available
# otherwise, create and initialise one
if [[ -n "${BCREC}" ]]; then
	#init record file if none
	if [[ ! -f "${RECFILE}" ]]; then
		printf "## Bcalc.sh Record\n1\n" >> "${RECFILE}"
		printf "File initialised: %s\n" "${RECFILE}" 1>&2
	fi

	#add note to record
	if [[ -n "${NOTEOPT}" ]]; then
		notef "${*}"
	fi
	
	#swap 'ans' by last result
	if [[ "${EQ}" =~ ans ]]; then
		ANS=$(tail -n1 "${RECFILE}")
		EQ="${EQ//ans/${ANS}}"
	#if no expression was given at all, grep last result
	elif [[ -z "${EQ}" ]]; then
		EQ="$(tail -n1 "${RECFILE}")"
	fi
#some error handling
elif [[ -n "${NOTEOPT}" ]]; then
	printf "Note function requires a record file.\n" 1>&2
	exit 1
fi

#load cientific extensions?
[[ -n "${CIENTIFIC}" ]] && setcf

#calc result and check expression syntax
if RES="$(bc -l <<<"${EXT};${EQ}")"; then
	[[ -z "${RES}" ]] && exit 1
else
	exit 1
fi

# Print equation to record file?
if [[ -n "${BCREC}" ]]; then
	#grep last result/answer
	LASTRES="$(tail -1 "${RECFILE}")"

	#check for duplicate result
	if [[ "${RES}" != "${LASTRES}" ]]; then
		{
		#print timestamp
		printf "## %s\n## { %s }\n" "$(date "+%FT%T%Z")" "${EQ}"
		
		#print original result
		printf "%s\n" "${RES}"
		} >> "${RECFILE}"
	fi
fi

#format result
#scale
if [[ -n "${SCL}" ]]; then
	RES="$(bc -l <<<"${EXT};scale=${SCL};(${EQ})/1")"
fi

#thousands separator
if [[ -n "${TOPT}" ]]; then
	printf "%'.${SCL:-2}f\n" "${RES}"
	exit
#no formatting
else
	#trim whitespaces
	bc -l <<< "define trunc(x){auto os;scale=${SCL:-100};os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; trunc(${RES})"
	#set a big enough scale for the function, if none given
	#scientific extensions defaults scale=100
	#bc mathlib defaults scale=20
fi

exit

