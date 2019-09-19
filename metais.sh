#!/bin/bash
# Metal prices in BRL/Grams
# v0.2  18//set/2019  by mountaineer_br

# Ounce in Grams reference
OZ="28.349523125"
oz() {
	printf "%s\n" "${OZ}" | xclip -selection clipboard
	printf "%s\n" "${OZ}"
}
# Ref : International avoirdupois ounce 	
# https://en.wikipedia.org/wiki/Ounce

## Funções de metais ( em BRL )
cmcouro() { echo "$(~/_Scripts/markets/cmc.sh -bs6 "1/${OZ}" xau brl)" | bc -l; }
cmcprata() { echo "$(~/_Scripts/markets/cmc.sh -bs6 "1/${OZ}" xag brl)" | bc -l; }
cgkouro() { echo "$(~/_Scripts/markets/cgk.sh -bs6 "1/${OZ}" xau brl)" | bc -l; }
cgkprata() { echo "$(~/_Scripts/markets/cgk.sh -bs6 "1/${OZ}" xag brl)" | bc -l; }
openxouro() { echo "scale=6; $(~/_Scripts/markets/openx.sh xau brl)/${OZ}" | bc -l; }
openxprata() { echo "scale=6; $(~/_Scripts/markets/openx.sh xag brl)/${OZ}" | bc -l; }
clayouro() { echo "scale=6; $(~/_Scripts/markets/clay.sh xau brl)/${OZ}" | bc -l; }
clayprata() { echo "scale=6; $(~/_Scripts/markets/clay.sh xag brl)/${OZ}" | bc -l; }

## USD/BRL Rate & Metais
(
echo ""
date "+%Y-%m-%dT%H:%M:%S(%Z)"
echo ""
OPENXBRL=$(~/_Scripts/markets/openx.sh usd brl)
CLAYBRL=$(~/_Scripts/markets/clay.sh usd brl)
echo "       Real BRL"
echo ""
echo "ERates:  $(~/_Scripts/markets/erates.sh -s6 usd brl)"
echo "CLay:    ${CLAYBRL}"
echo "OpenX:   ${OPENXBRL}"
CMCBRL=$(~/_Scripts/markets/cmc.sh -s4 -b usd brl)
CGKBRL=$(~/_Scripts/markets/cgk.sh -s4 -b usd brl)
echo "CMC:     ${CMCBRL}"
echo "CGK:     ${CGKBRL}"
MYCBRL=$(~/_Scripts/markets/myc.sh -s4 usd brl)
echo "MyC:     ${MYCBRL}"
echo ""
echo "Média:   $(echo "scale=4; (${OPENXBRL}+${CMCBRL}+${CGKBRL}+${MYCBRL})/4" | bc -l)"
echo ""
## Não irá fazer média com CLay por enquanto
echo "       Ouro XAU      Prata XAG"
echo ""
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
echo ""
echo "Média: $AVGO    $AVGP"
echo ""
) | tee -a ~/.metais_record

