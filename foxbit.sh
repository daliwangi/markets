#!/bin/bash
# Foxbit.sh -- Pegar taxas de criptos pelo API da FoxBit
# v0.2.4  22/oct/2019  by mountaineer_br

HELP="GARANTIA
	Este programa/script é software livre e está licenciado sob a Licença 
	Geral Pública v3 ou superior do GNU. Sua distribuição não oferece supor-
	te nem correção de bugs.

	O script precisa do Bash, JQ e Websocat.


SINOPSE
	foxbit.sh [-hv] [-iNUM] [CÓDIGO_CRIPTOMOEDA]	


 	O Foxbit.sh pega as cotações de criptomoedas diretamente da API da 
	FoxBit. Como o acesso é através de um Websocket, a conexão fica aberta 
	e quando houver alguma atualização por parte do servidor, ele nos man-
	dará no canal já aberto.

	A opção padrão gera um ticker com estatísticas do último período de tem-
	po (6 horas), ou seja o ticker sempre tem as estatísticas das últimas 
	negociações que ocorreram nessa última janela de tempo, e o preço mais 
	atualizado.

	Se nenhum parâmetro for especificado, BTC é usado. Para ver o ticket de
	outras moedas, especificar o nome da moeda no primeiro argumento.

	Os tickeres que a FoxBit oferece são:
	
		BTC 	BRL
		LTC 	ETH
		TUSD 	XRP
	

	O intervalo de tempo dos tickeres pode ser mudado. O padrão é de 24 ho-
	ras (24h). Os intervalos suportados são somente os seguintes:

		Intervalos 	Equivalente em segundos
		 1m		60 	
		30m		1800 	
	 	 1h  		3600 	
	 	 6h  		21600 	
		12h  		43200 	
		24h  		86400 	


LIMITES
	Segundo os documentos de API:

		\"rate limit: 500 requisições à cada 5 min\"

		<https://foxbit.com.br/api/>


EXEMPLOS DE USO

		Ticker rolante do Ethereum:

		$ foxbit.sh ETH


		Ticker rolante da Litecoin das últimas 6 horas:

		$ foxbit.sh -i 6h LTC

		
		Somente as atualizações de preço do Bitcoin:

		$ foxbit.sh -p
		
		$ foxbit.sh -p BTC


OPÇÕES
	-i 	Intervalo de tempo do ticker rolante; padrão=24h.

	-h 	Mostra esta Ajuda.
	
	-p 	Preço somente.

	-v 	Mostra a versão deste script."



# Test if JQ and Websocat are available
if ! command -v jq &>/dev/null; then
	printf "JQ is required.\n" 1>&2
	exit 1
elif ! command -v websocat &>/dev/null; then
	printf "Websocat is required.\n" 1>&2
	exit 1
fi

# Defaults
ID=1;IDNAME=BTC
INT=86400

# Parse options
while getopts ":hvi:p" opt; do
	case ${opt} in
		i ) # Interval
			INT="${OPTARG}"
			case ${OPTARG} in
				1m|1min)
					INT=60
					;;
				30m|30min)
					INT=1800
					;;
				1h|1hora)
					INT=3600
					;;
				6h|6horas)
					INT=21600
					;;
				12h|12horas)
					INT=43200
					;;
				24h|24horas)
					INT=86400
					;;
			esac
			if ! grep -q -e "^60$" -e "^1800$" -e "^3600$" -e "^21600$" -e "^43200$" -e "^86400$" <<<"${INT}"; then
				printf "Intervalo não suportado!\n" 1>&2
				INT=86400
			fi
			echo $INT
			exit
			;;
		h ) # Help
			head "${0}" | grep -e '# v'
			echo -e "${HELP}"
			exit 0
			;;
		p ) # Preço somente
			POPT=1
			;;
		v ) # Version of Script
			head "${0}" | grep -e '# v'
			exit 0
			;;
		\? )
			echo "Invalid Option: -$OPTARG" 1>&2
			exit 1
			;;
	 esac
done
shift $((OPTIND -1))

# Get Product ID
if [[ -n "${1}" ]]; then
	case "${1^^}" in
		BTC)
			ID=1
			IDNAME=BTC
			;;
		BRL)
			ID=2
			IDNAME=BRL
			;;
		LTC)
			ID=3
			IDNAME=LTC
			;;
		ETH)
			ID=4
			IDNAME=ETH
			;;
		TUSD)
			ID=5
			IDNAME=TUSD
			;;
		XRP)
			ID=6
			IDNAME=XRP
			;;
		*)
			printf "Cripto indisponível: %s.\n" "${1^^}" 1>&2
			exit 1
			;;
	esac
fi

## *Only* Price of Instrument
pricef () {
	websocat -nt --ping-interval 20 "wss://apifoxbitprodlb.alphapoint.com/WSGateway" <<< '{"m":0,"i":4,"n":"SubscribeTicker","o":"{\"OMSId\":1,\"InstrumentId\":'${ID}',\"Interval\":60,\"IncludeLastCount\":1}"}' | jq --unbuffered -r '.o' | jq --unbuffered -r '.[]|.[7]'
}
if [[ -n "${POPT}" ]]; then
	pricef
	exit
fi

## Price of Instrument
statsf () {
	printf "Estatísticas Rolantes\n"
	websocat -nt --ping-interval 20 "wss://apifoxbitprodlb.alphapoint.com/WSGateway" <<< '{"m":0,"i":4,"n":"SubscribeTicker","o":"{\"OMSId\":1,\"InstrumentId\":'${ID}',\"Interval\":'${INT}',\"IncludeLastCount\":1}"}' | jq --unbuffered -r '.o' |
		jq --unbuffered -r --arg IDNA "${IDNAME}" '.[] | "InstrumentID: \(.[8]) (\($IDNA))",
			"Hora Inicial: \((.[9]/1000) | strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
			"Hora Final  : \((.[0]/1000) | strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
			"Intervalo   : \((.[0]-.[9])/1000) secs (\((.[0]-.[9])/3600000) h)",
			"Alta   : \(.[1])",
			"Baixa  : \(.[2])  Variação: \(.[1]-.[2])",
			"Abert. : \(.[3])",
			"Fecham.: \(.[4])  Variação: \(.[3]-.[4])",
			"Volume : \(.[5])",
			"Spread : \(.[7]-.[6])",
			"Oferta : \(.[6])",
			"Demanda: \(.[7])"'
}
#Defaul opt
statsf
exit

:<<COMMENT
[
    {
        "EndDateTime": 0, // POSIX format
        "HighPX": 0,
        "LowPX": 0,
        "OpenPX": 0,
        "ClosePX": 0,
        "Volume": 0,
        "Bid": 0,
        "Ask": 0,
        "InstrumentId": 1,
        "BeginDateTime": 0 // POSIX format
    }
]
COMMENT

## Products
productsf() {

 websocat "wss://apifoxbitprodlb.alphapoint.com/WSGateway" <<<'{"m":0,"i":10,"n":"GetProducts","o":"{\"OMSId\":1}"}' | jq -r '.o' | jq -r '.'

}
#productsf

:<<COMMENT
Product ID 	Product
1 		BTC
2 		BRL
3 		LTC
4 		ETH
5 		TUSD
6 		XRP
COMMENT


## ?
#websocat "wss://apifoxbitprodlb.alphapoint.com/WSGateway" <<< '{"m":0,"i":12,"n":"GetInstruments","o":"{"OMSId":1}"}' | jq -r '.'

