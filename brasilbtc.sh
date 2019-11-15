#!/bin/bash
# Brasilbtc.sh -- Puxa Taxas de Bitcoin de Exchanges do Brasil
# v0.3.6  14/nov/2019  by mountaineerbr

# Some defaults
LC_NUMERIC=en_US.UTF-8

## Manual and help
# printf "brasilbtc [código_da_moeda] #Ex: btc, eth ltc"
HELP_LINES="NOME
 	\033[01;36mBrasilbtc.sh -- Puxa Taxas de Bitcoin/Criptos de Exchanges do Brasil\033[00m


SINOPSE
	brasilbtc.sh [-mm] [CÓDIGO_CRIPTO]

	brasilbtc.sh [-hjv]


DESCRIÇÃO
	O script puxa as cotações de algumas agências de câmbio brasileiras. Por
	padrão, puxará as taxas para o Bitcoin. Caso seja fornecida o código de
	outra cripto, os resultados serão exibidos somente caso ela seja supor-
	tada em cada uma das agências de câmbio. Alguns APIs só oferecem cota-
	ções para o Bitcoin.

	Para cotações de Bitcoins, usa-se, também, a API do BitValor, uma empre-
	sa como o CoinGecko ou CoinMarketCap, que analisa algumas agências de
	câmbio	brasileiras.
	
	Somente algumas agências de câmbio são suportadas.

	O nome do script em Bash (Brasilbtc.sh) não tem relação alguma com qual-
	quer agência de câmbio com nome eventualmente parecido!

	São necessários os pacotes cURL ou Wget, JQ, Bash e Coreutils.

	
IMPORTANTE
	Cuidado com agências de câmbio golpistas! Faça seus estudos! Não reco-
	mendamos nenhuma em particular. São suspeitas no momento de meu conhe-
	cimento: 3xBIT, AltasQuantum, NegocieCoins e TemBTC.


GARANTIA
 	Este programa é distribuído sem suporte ou correções de bugs. Licenciado
	sob a GPLv3 e superior.

	Me dê um trocado! =)

          bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


OPÇÕES
		-h 	Mostra esta página de ajuda.

		-j 	Debug.

		-m 	Cotação média e análise das agências de	câmbio;	passando
			duas vezes, imprime somente o valor da média.

		-v 	Mostra versão deste programa.\n"

apiratesf() {
	# Exchanges e Valores
	printf "APIs das agências:\n"

	## 3xBIT
	RATE="$(${YOURAPP} "https://api.exchange.3xbit.com.br/ticker/" | jq -r ".CREDIT_${1^^} | ((.last|tonumber)*(.exchange_rate|tonumber))")"
	test "${RATE//./}" -gt "0" && printf "%'.2f\t3xBIT\n" "${RATE}"
	unset RATE
	#https://github.com/3xbit/docs/blob/master/exchange/public-rest-api-en_us.md
	
	## AtlasQuantum
	test "${1^^}" = "BTC" && printf "%'.2f\tAtlasQuantum\n" "$(${YOURAPP} 'https://19py4colq0.execute-api.us-west-2.amazonaws.com/prod/price' | jq -r '.last')"
	#https://atlasquantum.com/
	
	## BitBlue
	{ test "${1^^}" = "BTC" || test "${1^^}" = "ETH" || test "${1^^}" = "DASH";} &&
	RATE="$(${YOURAPP} "https://bitblue.com/api/transactions?market=${1,,}&currency=brl"|jq '.[].data[0].price')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tBitBlue\n" "${RATE}"
	unset RATE
	#https://bitblue.com/api-docs.php

	## BitCambio
	test "${1^^}" = "BTC" && printf "%'.2f\tBitCambio\n" "$(${YOURAPP} "https://bitcambio_api.blinktrade.com/api/v1/BRL/ticker"| jq -r '.last')"
	#https://bitcambiohelp.zendesk.com/hc/pt-br/articles/360006575172-Documenta%C3%A7%C3%A3o-para-API
	#https://blinktrade.com/docs/?shell#ticker
	
	## BitcoinToYou
	test "${1,,}" = "ltc" && BTYN="_litecoin"
	test "${1,,}" = "btc" || test "${1,,}" = "ltc" &&
	RATE="$(${YOURAPP} "https://api_v1.bitcointoyou.com/ticker${BTYN}.aspx" | jq -r '.ticker.last')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tBitcoinToYou\n" "${RATE}"
	unset RATE
	#https://www.bitcointoyou.com/blog/api-b2u/
	
	## BitcoinTrade
	RATE="$(${YOURAPP} "https://api.bitcointrade.com.br/v2/public/BRL${1^^}/ticker" | jq -r '.data.last')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tBitcoinTrade\n" "${RATE}"
	unset RATE
	#https://apidocs.bitcointrade.com.br/?version=latest#e3302798-a406-4150-8061-e774b2e5eed5
	
	## BitPreço
	RATE="$(${YOURAPP} "https://api.bitpreco.com/${1,,}-brl/ticker" | jq '.last')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tBitPreço\n" "${RATE}"
	unset RATE
	#https://bitpreco.com/api.html

	#BitRecife
	if jq -r '.result[].MarketName' <<< "$(${YOURAPP} "https://exchange.bitrecife.com.br/api/v3/public/getmarkets")" | grep -iq "${1}_BRL"; then
		RATE="$(${YOURAPP} "https://exchange.bitrecife.com.br/api/v3/public/getticker?market=${1^^}_BRL" | jq -r '.result[].Last')"
		printf "%'.2f\tBitRecife\n" "${RATE}"
	fi
	unset RATE
	#https://app.swaggerhub.com/apis-docs/bleu/white-label/3.0.0#/Public%20functions/getMarkets

	## BrasilBitcoin
	RATE="$(${YOURAPP} "https://brasilbitcoin.com.br/API/prices/${1^^}" | jq -r '.last')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tBrasilBitcoin\n" "${RATE}"
	unset RATE
	#
	
	## Braziliex
	RATE="$(${YOURAPP} "https://braziliex.com/api/v1/public/ticker/${1,,}_brl" | jq -r '.last')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tBraziliex\n" "${RATE}"
	unset RATE
	#https://braziliex.com/exchange/api.php
	
	## CoinNext
	test "${1^^}" = "BTC" && CN="1"
	test "${1^^}" = "LTC" && CN="2"
	test "${1^^}" = "ETH" && CN="4"
	test "${1^^}" = "XRP" && CN="6"
	# Get rate functions
	coinnextf() { 
		if [[ "${YOURAPP}" =~ "curl" ]]; then
			curl -s -X POST -d '{"OMSId": 1, "InstrumentId": '"${CN}"', "Depth": 1}' 'https://api.coinext.com.br:8443/AP/GetL2Snapshot'
		else
			wget -qO- --post-data='{"OMSId": 1, "InstrumentId": '"${CN}"', "Depth": 1}' 'https://api.coinext.com.br:8443/AP/GetL2Snapshot'
		fi
	}
	RATE="$(coinnextf | jq '.[0]|.[4]')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tCoinNext\n" "${RATE}"
	unset RATE
	#https://coinext.com.br/api.html
	
	## FlowBTC
	RATE="$(${YOURAPP} "https://publicapi.flowbtc.com.br/v1/ticker/${1^^}BRL" | jq -r '.data.LastTradedPx')"
	test -n "${RATE}" && test "${RATE}" != "0" && test "${RATE}" != "null" && printf "%'.2f\tFlowBTC\n" "${RATE}"
	unset RATE
	#https://www.flowbtc.com.br/api.html
	
	## Foxbit
	RATE="$(${YOURAPP} "https://watcher.foxbit.com.br/api/Ticker/" | jq -r '.[]|"\(.createdDate) \(.currency) \(.sellPrice)"' | sort -rn | grep -im1 "BRLX${1^^}" | cut -d' ' -f3)"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tFoxBit\n" "${RATE}"
	unset RATE
	# With Websocat -- Still cannot get it to work
	# echo '{ "m":0, "i":0, "n":"1", "o":"" }' | websocat "wss://apifoxbitprodlb.alphapoint.com/WSGateway"
	#https://foxbit.com.br/grafico-bitcoin/
	
	## MercadoBitcoin
	RATE="$(${YOURAPP} "https://www.mercadobitcoin.net/api/${1^^}/ticker/" | jq -r '.ticker.last')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tMercadoBitcoin\n" "${RATE}"
	unset RATE
	#https://www.mercadobitcoin.com.br/api-doc/
	
	## NegocieCoins -- Provavelmente é Golpe!
	#printf "%'.2f\tNegocieCoins\n" "$(${YOURAPP} "https://broker.negociecoins.com.br/api/v3/${1,,}brl/ticker" | jq -r '.last')"
	#https://www.negociecoins.com.br/documentacao-api

	#Nanu Exchange
	RATE="$(${YOURAPP} "https://nanu.exchange/public?command=returnTicker")"
	if jq -r 'keys[]' <<< "${RATE}" | grep -iq "BRL_${1}"; then
		printf "%'.2f\tNanu\n" "$(jq -r ".BRL_${1^^}.last" <<< "${RATE}")"
	fi
	unset RATE
	#https://nanu.exchange/documentation

	## NovaDAX
	RATE="$(${YOURAPP} "https://api.novadax.com/v1/market/ticker?symbol=${1^^}_BRL" | jq -r '.data.lastPrice')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tNovaDAX\n" "${RATE}"
	unset RATE
	#https://doc.novadax.com/pt-BR/#get-latest-tickers-for-all-trading-pairs
	
	## NoxBitcoin
	test "${1^^}" = "BTC" && printf "%'.2f\tNoxBitcoin\n" "$(${YOURAPP} 'https://api.nox.trading/ticker/1' | jq -r '.venda')"
	unset RATE
	#https://www.noxbitcoin.com.br/
	
	## TEMBTC
	RATE="$(${YOURAPP} "https://broker.tembtc.com.br/api/v3/${1,,}brl/ticker" | jq -r '.buy')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tTEMBTC\n" "${RATE}"
	unset RATE
	#https://www.tembtc.com.br/api
	
	## OmniTrade
	RATE="$(${YOURAPP} "https://omnitrade.io/api/v2/tickers/${1,,}brl" | jq -r '.ticker.last')"
	test "${RATE//./}" -gt "0" && printf "%'.2f\tOmniTrade\n" "${RATE}"
	unset RATE
	#https://help.omnitrade.io/pt-BR/articles/1572451-apis-como-integrar-seu-sistema
	
	## Walltime
	test "${1^^}" = "BTC" && printf "%'.2f\tWalltime\n" "$(${YOURAPP} "https://s3.amazonaws.com/data-production-walltime-info/production/dynamic/walltime-info.json" | jq -r '(.BRL_XBT.last_inexact)')"
	unset RATE
	#https://walltime.info/api.html#orgaa3116b
}

bitvalorf() {
	## BitValor (Análise de Agências de Câmbio do Brasil)
	if [[ "${1^^}" = "BTC" ]]; then
		printf "API do BitValor:\n"
		# Nome das exchanges analisadas pelo BitValor
		ARN="Arena Bitcoin"
		B2U="BitcoinToYou"
		BAS="Basebit"
		BIV="Bitinvest"
		BSQ="Bitsquare"
		BTD="BitcoinTrade"
		CAM="BitCambio"
		FLW="flowBTC"
		FOX="FoxBit"
		LOC="LocalBitcoins"
		MBT="Mercado Bitcoin"
		NEG="Negocie Coins"
		PAX="Paxful"
		WAL="Walltime"
		BZX="Bitcoin Zero"
		PFY="Payfair"
		# Pegar o JSON uma única vez ( limit: 1 request/min )
		BVJSON=$(${YOURAPP} "https://api.bitvalor.com/v1/ticker.json")
		# Extrair a montar Array com nomes das exchanges
		ENAMES=($(jq -r '.ticker_24h.exchanges | keys[]' <<< "${BVJSON}"))
		# Print nomes e valores das exchanges
		for i in "${ENAMES[@]}"; do
			EFN="$(eval "echo \${$i}")"
			#Or: eval printf "%s'\n'" "\${${i}}"
			printf "%'.2f  %s\t%s\n" "$(jq -r ".ticker_24h.exchanges.${i}.last" <<< "${BVJSON}")" "${i}" "${EFN}"
		done
	fi
	#https://bitvalor.com/api
	#https://unix.stackexchange.com/questions/41406/use-a-variable-reference-inside-another-variable
}

# Pegar somente média
getmediaf() {
	# Get numbers/cotações
	getnf() { sed -E -e "s/^([0-9]+.[0-9]+.[0-9]+)\s.+/\1/" -e '/^[a-zA-Z].+/d';}
	# Get API rates
	RESULTS="$(apiratesf "${1}" 2>/dev/null | tr -d ',')"
	N="$(grep -cE "^[0-9]+" <<< "${RESULTS}")"
	printf "Menores:  \n"
	grep -E "^[0-9]+" <<< "${RESULTS}" | sort -n | head -n3
	printf "Média(n=%s):\n" "${N}"
	printf "%.2f\n" "$(bc -l <<< "($(getnf <<< "${RESULTS}" | paste -sd+))/${N}")"
	printf "Delta(máx/mín):\n"
	MIN="$(getnf <<< "${RESULTS}" | sort -n | head -1)" 
	MAX="$(getnf <<< "${RESULTS}" | sort -n | tail -1)" 
	printf "%.2f %%\n" "$(bc -l <<< "((${MAX}/${MIN})-1)*100")"
	printf "Maiores:\n"
	grep -E "^[0-9]+" <<< "${RESULTS}" | sort -n | tail -n3
}

# Parse options
# If the very first character of the option string is a colon (:) then getopts 
# will not report errors and instead will provide a means of handling the errors yourself.
while getopts ":jhvm" opt; do
  case ${opt} in
    	j ) # DEBUG
		DEBUGOPT=1
      		;;
	m ) # Média somente
		test -n "${MOPT}" && MOPT=2 || MOPT=1
		;;
	h ) # Show Help
		echo -e "${HELP_LINES}"
		exit 0
		;;
	\? )
		echo "Opção inválida: -$OPTARG" 1>&2
		exit 1
		;;
    	v ) # Version of Script
      		head "${0}" | grep -e '# v'
      		exit
      		;;
  esac
done
shift $((OPTIND -1))

# Test if cURL or Wget is available
if command -v curl &>/dev/null; then
	YOURAPP="curl -s"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO-"
else
	printf "cURL ou Wget é requerido.\n" 1>&2
	exit 1
fi

# Veja se há algum argumento
test -z "${1}" && set -- btc

# Debug option
if test -n "${DEBUGOPT}"; then
	printf "Abaixo, as linhas que puxam dados brutos JSON:\n"
	grep -Ei -e "http" < "${0}" | sed -e 's/^[ \t]*//' | sort
	printf "Executar a função \"apiratesf\" sem redireção do STDERR...\n"
	apiratesf ${@}
	exit
fi

# Média opt
if test "${MOPT}" = "1"; then
	printf "Aguarde...\r"
	getmediaf "${1}" | sed -Ee 's/\s+/  /' -e 's/^[0-9]/ &/' -e 's/\./,/'
	exit
# Teste se foram passados -mm
elif test "${MOPT}" = "2"; then
	MOPT=1
	getmediaf "${1}" | sed -Ee 's/\s+/  /' -e 's/\./,/' | grep -A1 "^Média" | tail -n1
	exit
fi

# Função padrão
# Imprimir referência de hora
date
# Pegar cotações disponíveis
{ apiratesf "${1}"; bitvalorf "${1}";} 2>/dev/null | tr ',.' '.,'

exit

