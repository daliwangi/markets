#!/bin/bash
# Foxbit.sh -- Pegar taxas de criptos pelo API da FoxBit
# v0.1.1  22/oct/2019  by mountaineer_br

HELP="GARANTIA
	Este programa/script é software livre e está licenciado sob a Licença 
	Geral Pública v3 ou superior do GNU. Sua distribuição não oferece supor-
	te nem correção de bugs.

	O script precisa do Bash, JQ e Websocat.


SINOPSE
	foxbit.sh [-hv] [-iNUM] [CÓDIGO_CRYPTOMOEDA]	


 	O Foxbit.sh pegar taxas de criptomoedas diretamente da API da FoxBit.
	É gerado um ticker com estatísticas do último período de tempo especifi-
	cado (padrão=21600 segundos -- 6 horas), ou seja o ticker sempre tem as
	estatísticas das últimas compras/vendas da janela de tempo.

	Se nenhum parâmetro for especificado, BTC é usado. Para ver o ticket de
	outras moedas, especificar o nome da moeda no primeiro argumento.

	Os tickeres que a FoxBit oferece são:
	
		BTC 	BRL
		LTC 	ETH
		TUSD 	XRP
	

	O intervalo de tempo dos tickeres pode ser mudado. Os intervalos supor-
	tados são (em segundos), somente:

		60 	(1 min)
		21600 	(6  h )
		43200 	(12 h )
		86400 	(24 h )


EXEMPLO DE USO

		$ foxbit.sh -i 86400 ETH


OPÇÕES
	-i 	Intervalo de tempo do ticker rolante; padrão=21600.
	-h 	Mostra esta Ajuda.
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
INT=21600

# Parse options
while getopts ":hvi:" opt; do
	case ${opt} in
		i ) # Interval
			if grep -q -e "^60$" -e "^21600$" -e "^43200$" -e "^86400$" <<<"${OPTARG}"; then
				INT="${OPTARG}"
			else
				printf "Intervalo não suportado!\n" 1>&2
			fi
			;;
		h ) # Help
			head "${0}" | grep -e '# v'
			echo -e "${HELP}"
			exit 0
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
			IDNAME=RXP
			;;
		*)
			printf "Indisponível.\n" 1>&2
			exit 1
			;;
	esac
fi

## Price of Instrument
printf "Estatísticas Rolantes\n"
websocat "wss://apifoxbitprodlb.alphapoint.com/WSGateway" <<< '{"m":0,"i":4,"n":"SubscribeTicker","o":"{\"OMSId\":1,\"InstrumentId\":'${ID}',\"Interval\":'${INT}',\"IncludeLastCount\":1}"}' | jq -r '.o' |
	jq -r --arg IDNA "${IDNAME}" '.[] | "InstrumentID: \(.[8]) (\($IDNA))",
		"Stats Start Time: \((.[9]/1000) | strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
		"Stats End Time  : \((.[0]/1000) | strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
		"Stats Interval  : \((.[0]-.[9])/1000) secs (\((.[0]-.[9])/3600000) h)",
		"HighPX : \(.[1])",
		"LowPX  : \(.[2])",
		"OpenPX : \(.[3])",
		"ClosePX: \(.[4])",
		"Volume : \(.[5])",
		"Bid: \(.[6])",
		"Ask: \(.[7])"'

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

