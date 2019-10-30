#!/bin/bash
# Metal prices in BRL/Grams
# v0.2.2  27/set/2019  by mountaineer_br
## Este script somente pega cotações através de outros
## scripts e imprime os resultados em formato de tabelas.

# Ounce in Grams reference
OZ="28.349523125"
oz() {
	printf "%s\n" "${OZ}" | xclip -selection clipboard
	printf "%s\n" "${OZ}"
}
# Ref : International avoirdupois ounce 	
# https://en.wikipedia.org/wiki/Ounce

## Funções de metais ( em BRL )
cmcouro() { ~/_scripts/markets/cmc.sh -bs6 "1/${OZ}" xau brl; }
cmcprata() { ~/_scripts/markets/cmc.sh -bs6 "1/${OZ}" xag brl; }
cgkouro() { ~/_scripts/markets/cgk.sh -bs6 "1/${OZ}" xau brl; }
cgkprata() { ~/_scripts/markets/cgk.sh -bs6 "1/${OZ}" xag brl; }
openxouro() { echo "scale=6; $(~/_scripts/markets/openx.sh xau brl)/${OZ}" | bc -l; }
openxprata() { echo "scale=6; $(~/_scripts/markets/openx.sh xag brl)/${OZ}" | bc -l; }
clayouro() { echo "scale=6; $(~/_scripts/markets/clay.sh xau brl)/${OZ}" | bc -l; }
clayprata() { echo "scale=6; $(~/_scripts/markets/clay.sh xag brl)/${OZ}" | bc -l; }

## USD/BRL Rate & Metais
(
echo ""
date "+%Y-%m-%dT%H:%M:%S(%Z)"
echo ""
OPENXBRL=$(~/_scripts/markets/openx.sh usd brl)
CLAYBRL=$(~/_scripts/markets/clay.sh usd brl)
echo "       Real BRL"
echo ""
echo "ERates:  $(~/_scripts/markets/erates.sh -s6 usd brl)"
echo "CLay:    ${CLAYBRL}"
echo "OpenX:   ${OPENXBRL}"
CMCBRL=$(~/_scripts/markets/cmc.sh -s4 -b usd brl)
CGKBRL=$(~/_scripts/markets/cgk.sh -s4 -b usd brl)
echo "CMC:     ${CMCBRL}"
echo "CGK:     ${CGKBRL}"
MYCBRL=$(~/_scripts/markets/myc.sh -s4 usd brl)
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

