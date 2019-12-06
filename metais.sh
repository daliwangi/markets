#!/bin/bash
# Metal prices in BRL/Grams
# v0.2.4  06/dec/2019  by mountaineer_br
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
cmcouro() { ~/_scripts/markets/cmc.sh -bg6 xau brl; }
cmcprata() { ~/_scripts/markets/cmc.sh -bg6  xag brl; }
cgkouro() { ~/_scripts/markets/cgk.sh -bg6 xau brl; }
cgkprata() { ~/_scripts/markets/cgk.sh -bg6 xag brl; }
openxouro() { ~/_scripts/markets/openx.sh -s6 "1/${OZ}" xau brl; }
openxprata() { ~/_scripts/markets/openx.sh -s6 "1/${OZ}" xag brl; }
clayouro() { ~/_scripts/markets/clay.sh -g6 xau brl; }
clayprata() { ~/_scripts/markets/clay.sh -g6 xag brl; }

## USD/BRL Rate & Metais
{
date "+%Y-%m-%dT%H:%M:%S(%Z)"
OPENXBRL=$(~/_scripts/markets/openx.sh -s4 usd brl)
CLAYBRL=$(~/_scripts/markets/clay.sh -4 usd brl)
echo "       Real BRL"
echo "ERates:  $(~/_scripts/markets/erates.sh -s4 usd brl)"
echo "CLay:    ${CLAYBRL}"
echo "OpenX:   ${OPENXBRL}"
CMCBRL=$(~/_scripts/markets/cmc.sh -4 -b usd brl)
CGKBRL=$(~/_scripts/markets/cgk.sh -4 -b usd brl)
echo "CMC:     ${CMCBRL}"
echo "CGK:     ${CGKBRL}"
MYCBRL=$(~/_scripts/markets/myc.sh -s4 usd brl)
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
} | tee -a ~/.metais_record


