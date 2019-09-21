#!/usr/bin/bash
# Brasilbtc.sh -- Puxa Taxas de Bitcoin de Exchanges do Brasil
# v0.2.1  21/09/2019  by mountaineerbr

# Some defaults
LC_NUMERIC=en_US.UTF-8

## Manual and help
# printf "brasilbtc [código_da_moeda] #Ex: btc, eth ltc"
HELP_LINES="NOME
 	\033[01;36mBrazilbtc.sh -- Puxa Taxas de Bitcoin de Exchanges do Brasil\033[00m


SINOPSE
	$ brasilbtc.sh                    #Padrão: btc (Bitcoin)
	
	$ brasilbtc.sh [código_da_moeda]
	        Ex: btc, ltc, eth, dash, etc.


DESCRIÇÃO
	Este programa puxa taxas/cotações de algumas agências de câmbio brasileiras.
	Por padrão, puxarã as taxas para o Bitcoin. Caso seja fornecida uma outra
	moeda, os resultados dependerão se a moeda solicitada é suportada em cada
	exchange. Além disso, alguns APIs só puxam cotações para o Bitcoin.

	Para cotações de Bitcoins, usa-se, também, a API do BitValor, uma empresa
	como o CoinGecko ou CoinMarketCap, que analisa algumas agências de câmbio
	brasileiras.
	
	No momento, somente algumas agências de câmbio são suportadas.
	
	IMPORTANTE: Cuidado com agências de câmbio golpistas! Faça seus estudos!
		    Não recomendamos nenhuma em particular. São suspeitas
		    no momento: NegocieCoins e 3xBIT.

	São necessários os pacotes cURL, JQ, Bash e Coreutils.


OPÇÕES
		-h 	Mostra esta Ajuda.

		-j 	Imprime linhas do script que puxam dados brutos
			dos servidores;	para debugging.

		-v 	Mostra versão deste programa.


BUGS
 	Este programa é distribuído sem suporte ou correções de bugs.
	Licenciado sob a GPLv3 e superior.
	Me dê um trocado! =)
          bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr
		"
# Parse options
# If the very first character of the option string is a colon (:) then getopts 
# will not report errors and instead will provide a means of handling the errors yourself.
while getopts ":jhv" opt; do
  case ${opt} in
    	j ) # Grab JSON
		printf "\nAbaixo, as linhas que puxam dados brutos JSON:\n\n"
		grep -E -o -i -e "curl.+" -e "websocat.+" <"${0}" | sed -e 's/^[ \t]*//' | sort
		exit
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

# Veja se há algum argumento
test -z "${1}" && set -- btc

## Avoid errors being printed (check last line)
(

# Imprimir referência de hora
date

# Exchanges e Valores
printf "Valores diretamente das APIs:\n"

## 3xBIT
printf "%'.2f\t3xBIT\n" "$(curl -s --request GET https://api.exchange.3xbit.com.br/ticker/ | jq -r ".CREDIT_${1^^} | ((.last|tonumber)*(.exchange_rate|tonumber))")"
#https://github.com/3xbit/docs/blob/master/exchange/public-rest-api-en_us.md

## AtlasQuantum
test "${1^^}" = "BTC" && printf "%'.2f\tAtlasQuantum\n" "$(curl -s 'https://19py4colq0.execute-api.us-west-2.amazonaws.com/prod/price' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' -H 'Accept: */*' -H 'Accept-Language: en-GB,pt-BR;q=0.8,en-US;q=0.5,en;q=0.3' --compressed -H 'Origin: https://atlasquantum.com' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Referer: https://atlasquantum.com/' -H 'TE: Trailers'| jq -r '.[]'|tr -d 'R$.'|tr ',' '.')"
#https://atlasquantum.com/


## BitBlue
printf "%'.2f\tBitBlue\n" "$(curl -s --request GET "https://bitblue.com/api/transactions?market=${1,,}&currency=brl"|jq '.[].data[0].price')"
#https://bitblue.com/api-docs.php

## BitCambio
if [[ "${1,,}" = "btc" ]]; then
	printf "%'.2f\tBitCambio\n" "$(curl -s "https://bitcambio_api.blinktrade.com/api/v1/BRL/ticker"| jq -r '.last')"
fi
#https://bitcambiohelp.zendesk.com/hc/pt-br/articles/360006575172-Documenta%C3%A7%C3%A3o-para-API
#https://blinktrade.com/docs/?shell#ticker

## BitPreço
printf "%'.2f\tBitPreço\n" "$(curl -s "https://api.bitpreco.com/${1,,}-brl/ticker" | jq '.last')"
#https://bitpreco.com/api.html

## BitcoinToYou
if [[ "${1,,}" = "btc" ]] || [[ "${1,,}" = "ltc" ]] ; then
	test "${1,,}" = "btc"
	test "${1,,}" = "ltc" && BTYN="_litecoin"
	printf "%'.2f\tBitcoinToYou\n" "$(curl -s https://api_v1.bitcointoyou.com/ticker${BTYN}.aspx | jq -r '.ticker.last')"
fi
#https://www.bitcointoyou.com/blog/api-b2u/

## BitcoinTrade
printf "%'.2f\tBitcoinTrade\n" "$(curl -s https://api.bitcointrade.com.br/v2/public/BRL${1^^}/ticker | jq -r '.data.last')"
#https://apidocs.bitcointrade.com.br/?version=latest#e3302798-a406-4150-8061-e774b2e5eed5

## BrasilBitcoin
printf "%'.2f\tBrasilBitcoin\n" "$(curl -s --location --request GET "https://brasilbitcoin.com.br/API/prices/${1^^}" | jq -r '.last')"
#

## Braziliex
printf "%'.2f\tBraziliex\n" "$(curl -s  https://braziliex.com/api/v1/public/ticker/${1,,}_brl| jq -r '.last')"
#https://braziliex.com/exchange/api.php

## CoinNext
test "${1^^}" = "BTC" && CN="1"
test "${1^^}" = "LTC" && CN="2"
test "${1^^}" = "ETH" && CN="4"
test "${1^^}" = "XRP" && CN="6"
printf "%'.2f\tCoinNext\n" "$(curl -s -X POST -d '{"OMSId": 1, "InstrumentId": '"${CN}"', "Depth": 1}' -H 'Content-type: application/json' 'https://api.coinext.com.br:8443/AP/GetL2Snapshot'|jq '.[0]|.[4]')"
#https://coinext.com.br/api.html

## FlowBTC
printf "%'.2f\tFlowBTC\n" "$(curl -s  --request GET "https://publicapi.flowbtc.com.br/v1/ticker/${1^^}BRL"|jq -r '.data.LastTradedPx')"
#https://www.flowbtc.com.br/api.html

## MercadoBitcoin
printf "%'.2f\tMercadoBitcoin\n" "$(curl -s https://www.mercadobitcoin.net/api/${1^^}/ticker/ | jq -r '.ticker.last')"
#https://www.mercadobitcoin.com.br/api-doc/

## NegocieCoins -- Provavelmente é Golpe!
#printf "%'.2f\tNegocieCoins\n" "$(curl -s https://broker.negociecoins.com.br/api/v3/${1,,}brl/ticker | jq -r '.last')"
#https://www.negociecoins.com.br/documentacao-api

## NovaDAX
printf "%'.2f\tNovaDAX\n" "$(curl -s "https://api.novadax.com/v1/market/ticker?symbol=${1^^}_BRL" | jq -r '.data.lastPrice')"
#https://doc.novadax.com/pt-BR/#get-latest-tickers-for-all-trading-pairs

## NoxBitcoin
test "${1^^}" = "BTC" && printf "%'.2f\tNoxBitcoin\n" "$(curl -s 'https://api.nox.trading/ticker/1' | jq -r '.venda')"
#https://www.noxbitcoin.com.br/

## OmniTrade
printf "%'.2f\tOmniTrade\n" "$(curl -s https://omnitrade.io/api/v2/tickers/${1,,}brl | jq -r '.ticker.last')"
#https://help.omnitrade.io/pt-BR/articles/1572451-apis-como-integrar-seu-sistema

## Walltime
if [[ "${1,,}" = "btc" ]]; then
	printf "%'.2f\tWalltime\n" "$(curl -s https://s3.amazonaws.com/data-production-walltime-info/production/dynamic/walltime-info.json | jq -r '(.BRL_XBT.last_inexact)')"
fi
#https://walltime.info/api.html#orgaa3116b

## BitValor (Análise de Agências de Câmbio do Brasil)
if [[ "${1^^}" = "BTC" ]]; then
	printf "\nBitValor:\n"
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
	BVJSON=$(curl -s https://api.bitvalor.com/v1/ticker.json)
	# Extrair a montar Array com nomes das exchanges
	ENAMES=($(printf "%s\n" "${BVJSON}" | jq -r '.ticker_24h.exchanges | keys[]'))
	# Print nomes e valores das exchanges
	for i in "${ENAMES[@]}"; do
		EFN="$(eval "echo \${$i}")"
		#Or: eval printf "%s'\n'" "\${${i}}"
		printf "%'.2f  %s\t%s\n" "$(printf "%s\n" "${BVJSON}" | jq -r ".ticker_24h.exchanges.${i}.last")" "${i}" "${EFN}"
	done
fi
#https://bitvalor.com/api
#https://unix.stackexchange.com/questions/41406/use-a-variable-reference-inside-another-variable

## Avoid errors being printed
) 2>/dev/null

