#!/bin/bash
# Metal prices in BRL/Grams
# v0.2.5  dec/2019  by mountaineer_br
## Este script somente pega cotações através de outros
## scripts e imprime os resultados em formato de tabelas.

# Ounce in Grams reference
OZ="28.349523125"
oz() { # Add to your ~/.bashrc or ~/.zshrc
	printf "%s\n" "${OZ}" | xclip -selection clipboard
	printf "%s\n" "${OZ}"
}
# Ref : International avoirdupois ounce 	
# https://en.wikipedia.org/wiki/Ounce

## Funções de metais ( em BRL )
cmcouro() { ~/bin/markets/cmc.sh -bg6 xau brl; }
cmcprata() { ~/bin/markets/cmc.sh -bg6  xag brl; }
cgkouro() { ~/bin/markets/cgk.sh -bg6 xau brl; }
cgkprata() { ~/bin/markets/cgk.sh -bg6 xag brl; }
openxouro() { ~/bin/markets/openx.sh -s6 "1/${OZ}" xau brl; }
openxprata() { ~/bin/markets/openx.sh -s6 "1/${OZ}" xag brl; }
clayouro() { ~/bin/markets/clay.sh -g6 xau brl; }
clayprata() { ~/bin/markets/clay.sh -g6 xag brl; }

## USD/BRL Rate & Metais
{
	date "+%Y-%m-%dT%H:%M:%S(%Z)"
	OPENXBRL=$(~/bin/markets/openx.sh -s4 usd brl)
	CLAYBRL=$(~/bin/markets/clay.sh -4 usd brl)
	echo "       Real BRL"
	echo "ERates:  $(~/bin/markets/erates.sh -s4 usd brl)"
	echo "CLay:    ${CLAYBRL}"
	echo "OpenX:   ${OPENXBRL}"
	CMCBRL=$(~/bin/markets/cmc.sh -4 -b usd brl)
	CGKBRL=$(~/bin/markets/cgk.sh -4 -b usd brl)
	echo "CMC:     ${CMCBRL}"
	echo "CGK:     ${CGKBRL}"
	MYCBRL=$(~/bin/markets/myc.sh -s4 usd brl)
	echo "MyC:     ${MYCBRL}"
	echo "Média:   $(echo "scale=4; (${OPENXBRL}+${CMCBRL}+${CGKBRL}+${MYCBRL})/4" | bc -l)"
	echo ""
	## Não irá fazer média com CLay por enquanto
	echo "       Ouro XAU      Prata XAG"
	echo "CLay:  $(clayouro)    $(clayprata)"
	OPENXO="$(openxouro)"
	OPENXP="$(openxprata)"
	echo "OpenX: ${OPENXO}    $OPENXP"
	CMCO="$(cmcouro)"
	CMCP="$(cmcprata)"
	echo "CMC:   ${CMCO}    ${CMCP}"
	CGKO="$(cgkouro)"
	CGKP="$(cgkprata)"
	echo "CGK:   ${CGKO}    ${CGKP}"
	AVGO=$(echo "scale=6; ($CMCO+$CGKO+$OPENXO)/3" | bc -l)
	AVGP=$(echo "scale=6; (($CMCP+$CGKP+$OPENXP)/3)" | bc -l)
	echo "Média: $AVGO    $AVGP"
	echo ""
	parmetal.sh -p
	echo ""
	printf "Ourominas XAU\n"
	ourominas.sh | grep "Ouro Est"
	echo ""
} | tee -a ~/.metais_record


