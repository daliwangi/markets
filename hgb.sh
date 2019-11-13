#!/bin/bash
# HG Brasil -- Cotações
# v0.2.4  13/nov/2019  by mountaineer_br


# *Sua* chave privada (grátis) do HG Brasil
#HGBAPIKEY=""


HELP="Visão Geral :  $ hgb
Cotação Ação:  $ hgb -a [código_ação]
Procurar por símbolo de ação em <https://hgbrasil.com/status/finance>.
Variável para sua chave de API 'HGBAPIKEY=\"\"'"

# Cotações do HG Brasil Finança - Visão Geral do Mercado
hgb() {
	## API Público
	# Puxar JSON
	local HQRES="$(curl -s https://api.hgbrasil.com/finance)"
	# Moedas
	printf "HG Brasil\nVisão Geral do Mercado\n"
	printf "\nMoedas:\n"
	printf "%s\n" "${HQRES}" |
		jq -r '.results.currencies[]' | tail -n +2 |
		jq -r '"\(.name)  [\(.variation)%]","  ==> C: \(.buy)  V: \(.sell//" ")"'
	# Bolsas
	printf "\nBolsas:\n"
	printf "%s\n" "${HQRES}" |
		jq -r '.results.stocks[] | "\(.name)  [\(.variation)%]","  ==> \(.points//empty)"'
	printf "\nTaxas:\n"
		wget -qO- "https://api.hgbrasil.com/finance/taxes?key=${HGBAPIKEY}" |
			jq -r '.|"\(.by)  \(.results[].date)",
				"CDI: \(.results[].cdi)  SELIC: \(.results[].selic)",
				"Daily factor: \(.results[].daily_factor)"'
}

# -a Cotações do HQ Brasil Finança - Uma Ação/Ativo específico
hga() {
	# Puxar JSON
	local HQRES="$(curl -s "https://api.hgbrasil.com/finance/stock_price?key=${HGBAPIKEY}&symbol=${1,,}")"
	# Mais checagem de erro
	if [[ "$(printf "%s\n" "${HQRES}" | jq -r ".results.${1^^}.error")" = "true" ]]; then
		printf "%s\n" "${HQRES}" | jq -r ".results.${1^^}.message"
		exit 1
	fi
	# Imprime resultado
	printf "%s\n" "${HQRES}" |
		jq -r '.results."'${1^^}'" | "\(.symbol)  \(.name)",
		"Preço: \(.price)  Delta: \(.change_percent)",
		"MCap: \(.market_cap)",
		"Abertura: \(.market_time.open)  Fechamento: \(.market_time.close)",
		"Update: \(.updated_at)"'
}


# Parse Options
# Check for no arguments or options in input
if [[ "${1}" = "-h" ]]; then
	echo "${HELP}"
	exit 0
elif [[ -z "${HGBAPIKEY}" ]]; then
	printf "Por favor, crie uma chave de API grátis e adicione no código-fonte do script.\n" 1>&2
	exit 1
elif ! [[ "${*}" =~ [a-zA-Z]+ ]]; then
	hgb
	exit
elif [[ "${1}" = "-a" ]]; then
	test -z "${2}" && echo "Need a stock name." && exit 1
	hga "${2}"
	exit
elif [[ "${1}" = "-v" ]]; then
      head "${0}" | grep -e '# v'
      exit
fi

