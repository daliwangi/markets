#!/usr/bin/bash
#
# Bcalc.sh -- Easy Calculator for Bash
# v0.2.2   2019/jul/17     by mountaineerbr

## Manual and help
HELP_LINES="NAME
 	\033[01;36mBcalc.sh -- Easy Calculator for Bash\033[00m


SYNOPSIS
	bcalc.sh \e[0;33;40m[options]\033[00m \e[0;31;40m[equation]\033[00m
	
	bcalc.sh \e[0;33;40m[options]\033[00m


DESCRIPTION
	Bcalc.sh uses the powerful Bash Calculator and adds some useful features
	for use within Bash.

	It creates a Record file at ~/.bcalc_record. Use of \"ans\" in new 
	expression greps last result from Record.

	The extensions option will try to download a copy of a table of
	values of scientific variables and extra math functions to ~/.bcalc_extensions
	in a format readable by Bash Calculator ( bc ).


		Usage examples:	

		
			$ bcalc.sh 50.7+9

			$ bcalc.sh \"(100+100/2)*2\" 

			$ bcalc.sh 2^2+(8-4)

			$ bcalc.sh -s2 100/120

			$ bcalc.sh \\\(100+100\\\\)/1

			$ bcalc.sh -0.2*10
			
			$ bcalc.sh ans+33
			
			$ bcalc.sh -g -s4 50000*5

			$ bcalc.sh -t 1/10000000

		
		Define variables for use in the equation:
		
			$ bashc.sh \"s=5; -s+20\"


		Use of cientific constants.
		Discover how many molecules in 0.234 M of solution:
			
			$ bashc.sh -c 0.234*na


	You may need escape equations containing () with backslashes, \"\" or ''.

	Also, you may consider creating a bash alias to this script for easier use
	of the calc functions it offers. A suggestion to add to you ~/.bashrc :
	alias c=\"/home/path/to/bcalc.sh\"

	Floating numbers with a comma in the input have it swapped to a dot
	automatically for processing. Print format does use local LC_NUMERIC.

	Noughts are truncated automatically. Grouping \"-g\" option merely adds
	thousand separtors and prints answer with two decimal plates, unless
	otherwise specifiec with \"-s\".
		    
	Results may round, depending on the scale setting.


OPTIONS
		-c 	Run calc with extensions;
			it enables use of many cientific constants and
			disables options \"-g\" and \"-s\".
    		
		-e 	Print cientific extensions;
			Only works with \"-c\" opt.
    		
		-g 	Group thousands; if no expression is given, uses last answer.

    		-h 	Show this help.

		-n 	Add Note to Record;
			Useful to tag previous result for later manual consult;
			It should be used after a new result computed.
			Should not be used together with a equation, as it will
			not be calculated in any way.
    		
		-r 	Print calc Record.
    		
		-s 	Set scale ( decimal plates ); if no expression is given,
			uses last answer.
		
		-t 	Truncation of trailling noughts
			( Does not work in cientific mode; also it throws syntax
			errors if you define variables for equations ).


BUGS
	Made and tested with Bash 5.0.
 	This programme is distributed without support or bug corrections.
	Licensed under GPLv3 and above.
		"
# Parse options
while getopts ":ceghnrs:t" opt; do
  case ${opt} in
    c ) # Run calc with cientific extensions
	CIENTIFIC=1
	;;
    e ) # Print cientific extensions
	PEXT=1
	;;
    g ) # Group thousands
	GROUP=1
	;;
    h ) # Show Help
	echo -e "${HELP_LINES}"
	exit
	;;
    n ) # Add comment to Record
	NOTE=1
	;;
    r ) # Print record
	cat ~/.bcalc_record
	exit
	;;
    s ) # Scale ( decimal plates )
    	SCL="${OPTARG}"
	;;
    t ) # Nought Truncation function
	TR=1
	;;
    \? )
	break
  esac
done
shift $((OPTIND -1))

## Add Note function
if [[ -n "${NOTE}" ]];then
	sed -i "$ i\>> NOTE: ${*}" ~/.bcalc_record
	# https://superuser.com/questions/781558/sed-insert-file-before-last-line
	# http://www.yourownlinux.com/2015/04/sed-command-in-linux-append-and-insert-lines-to-file.html
	exit
fi

## Check if there is a Record file available
## Otherwise, create an empty one
if ! [[ -e ~/.bcalc_record ]]; then
	printf "## Bcalc.sh Record\n\n" >> ~/.bcalc_record
fi

## Scientific Extension Function
cientificf() {
	# Grab extensions and scientific constants
	if ! [[ -e ~/.bcalc_extensions ]]; then
		curl -s http://x-bc.sourceforge.net/scientific_constants.bc > ~/.bcalc_extensions
		printf "\n" >> ~/.bcalc_extensions
		curl -s http://x-bc.sourceforge.net/extensions.bc >> ~/.bcalc_extensions
		printf "\n" >> ~/.bcalc_extensions
	fi
	if [[ -n "${PEXT}" ]]; then
		less ~/.bcalc_extensions
		exit
	elif [[ -n ${GROUP} || -n ${SCL} ]]; then
		printf "Ignoring options \"-g\" and/or \"-s\"...\n" 1>&2
	fi

	# Grep last ans
	if printf "%s\n" "${*}" | grep ans &> /dev/null; then 
		ANS=$(tail -1 ~/.bcalc_record)
		EQ=$(printf "%s\n" "${*}" | sed -e "s/ans/(${ANS})/" -e "s/,/./")
	else
		EQ=$(printf "%s\n" "${*}" | sed 's/,/./g')
	fi


	# Calculate Results
	## Try to execute expression ( get a Result )
	RES=$(printf "%s; %s\n" "$(cat ~/.bcalc_extensions)" "${EQ}" | bc -l)

	## Check if equation syntax is valid
	if [[ -z "${RES}" ]]; then
		exit 1
	fi
	## Calc Record -- Timestamp and show result
	## If result is the same as last result, do not print it to Record again
	if ! [[ ${RES} = $(tail -1 ~/.bcalc_record) ]]; then
		## Print timestamp in Record
		printf "## %s\n## { %s }\n" "$(date "+%FT%T%Z")" "${EQ}" 1>> ~/.bcalc_record
		## Print original result to Record (default bc mathlib scale is 20)
		printf "%s\n" "${RES}" >> ~/.bcalc_record
	fi
	## Print result to STDOUT
	printf "%s\n" "${RES}"
	exit
	}
if [[ -n "${CIENTIFIC}" ]]; then
	cientificf "${*}"
fi		

## Grep last answer result from calc Record and prepare equation
if printf "%s\n" "${*}" | grep ans &> /dev/null; then 
	ANS=$(tail -1 ~/.bcalc_record)
	EQ=$(printf "%s\n" "${*}" | sed -e "s/ans/(${ANS})/" -e "s/,/./")
else
	EQ=$(printf "%s\n" "${*}" | sed 's/,/./g')
fi

# If you just want to format last result ( -s and/or -g )
if [[ -z ${*} ]] && [[ -n ${SCL} || -n ${GROUP} ]]; then
	printf "Formatting last answer...\n" >&2
	EQ="$(tail -1 ~/.bcalc_record)"
fi

## Check if equation syntax is valid
if [[ -z $(printf "%s\n" "${EQ}" | bc -l) ]]; then
	exit 1
fi

## Check if your locale uses a comma or dot for decimal separation
if [[ -z $(printf "%f\n" "1" | grep "\.") ]]; then
	COMMA=1
fi

## Calculate result
## If result is the same as last result, do not print it to Record again
if ! [[ $(printf "%s\n" "${EQ}" | bc -l) = $(tail -1 ~/.bcalc_record) ]]; then
	## Print timestamp in Record
	printf "## %s\n## { %s }\n" "$(date "+%FT%T%Z")" "${EQ}" 1>> ~/.bcalc_record
	## Print original result to Record (default bc mathlib scale is 20)
	printf "%s\n" "${EQ}" | bc -l >> ~/.bcalc_record
fi

## Format viewing result ( scale and thousands grouping )
# Set thousands grouping and scale
# Will format numbers according to your locale
if [[ -n ${GROUP} && -n ${SCL} ]]; then
	if [[ -z ${COMMA} ]]; then
		# Maximum Scale Result - printf cannot get more decimals than 58
		MXS="$(printf "scale=50; (%s)/1\n" "${EQ}" | bc -l)"
	else
		MXS="$(printf "scale=50; (%s)/1\n" "${EQ}" | bc -l | sed 's/\./\,/')"
	fi
	printf "%'.${SCL}f\n" "${MXS}"
	exit
# Set only thousands grouping
elif [[ -n ${GROUP} ]]; then
	if [[ -z ${COMMA} ]]; then
		printf "%'.2f\n" "$(printf "%s\n" "${EQ}" | bc -l)"
	else
		printf "%'.2f\n" "$(printf "%s\n" "${EQ}" | bc -l | sed 's/\./\,/')"
	fi
	exit
fi
# Set only scale
if [[ -z ${SCL} ]]; then
		SCL=20
fi
if [[ -n "${TR}" ]]; then
	TFUNC="define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}"
	printf "%s; scale=%s; trunc((%s)/1)\n" "${TFUNC}" "${SCL}" "${EQ}" | bc -l
else
	printf "scale=%s; %s/1\n" "${SCL}" "${EQ}" | bc -l

fi

# printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; trunc(%s/1)\n" "${EQ}" | bc -l

