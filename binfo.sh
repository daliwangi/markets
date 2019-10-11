#!/bin/bash
#
# Binfo.sh -- Bash Interface for Blockchain.info API & Websocket Access
# v0.4.14  2019/10/10  by mountaineerbr

## Some defalts
LC_NUMERIC=en_US.UTF-8

HELP="\"This programme is licensed under the GNU General Public License v3 or better\".

NAME

    Binfo.sh  -- Bash Interface for Blockchain.info & Blockchair.com APIs
    

SYNOPSIS

    binfo.sh  [option]  [block|address|tx|id]

This programme fetches information of Bitcoin blocks, addresses and transactions
from Blockchain.info (same as Blockchain.com) public APIs. It is intended to be
used as a simple Bitcoin blockchain explorer. It only accepts one argument for 
lookup at a time.

Blockchain.info  still  does  not  support segwit addresses. A workaround is to
fetch information from Blockchair.com. Blockchair.com supports segwit and other 
types of addresses.

A note on the websocket stream for receiving notification on new block: it is u-
sual that the websocket connection will drop. Automatic reconnection will occur.

This script needs the latest Bash, cURL, JQ, Websocat and Coreutils.

Give me a nickle!
	bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


Blockchain Organisation and Exploration

The blockchain has four basic levels of organisation:
    
	(0)  Blockchain itself.
	(1)  Block.
	(2)  Address.
	(3)  Transaction.

If you do not have a specific address or transaction to lookup, try fetching the
latest block info (option \"-l\"), and from there you can look up an address by
its transaction ID (with the option \"-t\"). Notice that the latest block takes
a while to process, so you only get transaction IDs at first. For thorough block
information, use option \"-b\" with the block hash. You can also inspect a block
with option \"-n\" and its height number.


ABBREVIATIONS

	Addr             Address
	A,Avg            Average
	AvgBlkS          Average block size
	Bal              Balance
	B,Blk            Block
	BTime,BlkTime    Block time (time between blocks)
	BTC              Bitcoin
	Cap              Capital
	CDD              Coin days destroyed
	Desc             Description
	Diff             Difficulty
	Domin            Dominance
	DSpent           Double spent
	Est              Estimated
	ETA              Estimated Time of arrival
	ETxVol           Estimated transaction volume
	Exa              [10^18]
	F                Fee
	FrTxID           From transaction ID number
	H,Hx             Hash, hashes
	HR               Hash rate
	ID               Identity
	LocalT           Local time
	LockT            Lock time
	MrklRt           Merkle Root
	NDiff            Next difficulty
	NextB            Next block
	Num              Number
	PrevB            Previous block
	PrevId           Previous (block|transaction) ID
	Recv             Received
	RecvT            Receive time
	sat              satoshi
	S                Size
	Suggest.         Suggested
	ToTxID           To transaction ID number
	TPS              Transactions per second
	T                Total, Time
	TTxFees          Total transaction fees
	TxPSec           Transactions per second
	Tx               Transaction
	Unc              Unconfirmed
	Ver              Version
	Vol              Volume


USAGE

	$ binfo.sh  [-e|-h|-i|-l|-m|-o|-v]

	$ binfo.sh  [-a|-b|-c|-n|-s|-t|-u|-x]  [BlockHx|AddressHx|TransactionHx|ID]


EXAMPLES

	(1) Get latest block hash and Transaction indexes:

		binfo.sh -l


	(2) Get full information of the latest block:

		binfo.sh -b


	(3) Information for block by hash

		binfo.sh -b 00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee


	(4) Information for block by height number (genesis block=0):

		binfo.sh -n 0


	(5) Summary address information

		binfo.sh -s 34xp4vRoCGJym3xR7yCVPFHoCNxv4Twseo
		binfo.sh -u 34xp4vRoCGJym3xR7yCVPFHoCNxv4Twseo
		
	
	(6) Complete address information

		binfo.sh -a 34xp4vRoCGJym3xR7yCVPFHoCNxv4Twseo
		binfo.sh -c 34xp4vRoCGJym3xR7yCVPFHoCNxv4Twseo
		
	
	(7) Transaction information
	
		binfo.sh -t a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d
		binfo.sh -x a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d


	(8) Market information

		binfo.sh -i
		binfo.sh -o


Examples note: first block with transaction, genesis block,
	       Binance cold wallet and the pizza transaction.


OPTIONS

    Blockhain
      -i 	Bitcoin blockchain info (24H rolling ticker).
      -o 	Bitcoin blockchain stats/info (from Blockchair).
    Block
      -b 	Block information by hash or id (index number).
      -e 	Socket stream for new blocks (requires Websocat).
      -l 	Latest block summary information.
      -n 	Block information by height.
    Address
      -a 	Address information.
      -c 	Address information from BlockChair.
      -s 	Summary Address information.
      -u 	Summary Address information from Blockchair.
    Transaction
      -t 	Transaction information by hash or id.
      -x 	Transaction information by hash or id from Blockchair.
    Other
      -h 	Help (this textpage).
      -j 	Fetch and print JSON (for debugging).
      -m 	Memory pool (unconfirmed) transaction Addresses and Balance
      		deltas from BlockChair; pipe output to grep a specific address.
      -v        Print version of this script."

## Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit 0
fi

# Parse options
while getopts ":acsnjlmbetuhioxv" opt; do
	case ${opt} in
		a ) # Address info
			ADDOPT=1
		  	;;
		c ) # Blockchair Address info
			CHAIROPT=1
			;;
		s ) # Summary  Address info
			SUMMARYOPT=1
			ADDOPT=1
			;;
		u ) # Summary  Address info (Blockchair)
			SUMMARYOPTB=1
			CHAIROPT=1
			;;
		n ) # Block Height info
			HOPT=1
			;;
		j ) # Print JSON
			PJSON=1
			;;
		l ) # Latest Block info
			LATESTOPT=1
			;;
		b ) # Raw Block info
			RAWOPT=1
			;;
		e ) # Soket mode for new BTC blocks
			SOCKETOPT=1
			;;
		t ) # Transaction info
			TXOPT=1
			;;
		x ) # Transaction info from Blockchair.com
			TXBCHAIROPT=1
			;;
		m ) # Memory Pool Unconfirmed Txs
			UTXOPT=1
			;;
		i ) # 24-H Blockchain Ticker
			BLKCHAINOPT=1
			;;
		o ) # Blockchain Ticker from Blockchair
			BLKCHAINOPTCHAIR=1 
			;;
		h ) # Help
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

# Check function args
if { [[ -n "${ADDOPT}" ]] || [[ -n "${CHAIROPT}" ]] ||
	[[ -n "${TXOPT}" ]] || [[ -n "${TXBCHAIROPT}" ]];} && [[ -z "${1}" ]]; then
	printf "Err: Tx/Addr ID/Hash is needed.\n" 1>&2
	exit 1
fi


## -e Socket stream for new blocks
sstreamf() {
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "Raw JSON will be printed when received...\n" 1>&2
		websocat --text --no-close --ping-interval 20 "wss://ws.blockchain.info/inv" <<< '{"op":"blocks_sub"}'
		exit 0 
	fi
	# Start websocket connection and loop for recconeccting
	while true; do
		printf "New Bitcoin block websocket\n" 1>&2
		websocat --text --no-close --ping-interval 18 "wss://ws.blockchain.info/inv" <<< '{"op":"blocks_sub"}' |
			jq -r '.x | "--------",
			"New block found!",
			"Hash__:",
			"  \(.hash)",
			"MrklRt:",
			"  \(.mrklRoot)",
			"Bits__: \(.bits)\tNonce_: \(.nonce)",
			"Blk_ID: \(.blockIndex)\t\tPrevId: \(.prevBlockIndex)",
			"Height: \(.height)\t\tVer___: \(.version)\tReward:\t\(if .reward == 0 then "??" else .reward end)",
			"Size__: \(.size/1000) KB\tTxs___: \(.nTx)",
			"Output: \(.totalBTCSent/100000000) BTC\tETxVol: \(.estimatedBTCSent/100000000) BTC",
			"Time__: \(.foundBy.time|strftime("%Y-%m-%dT%H:%M:%SZ"))\tLocalT: \(.foundBy.time|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
			"\t\t\t\tRecvT_: \(now|round|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
			"IP____: \(.foundBy.ip)  \tDesc__: \(.foundBy.description)",
			"Link__: \(.foundBy.link)"'
		#{"op":"blocks_sub"}
		#{"op":"unconfirmed_sub"}
		#{"op":"ping"}
		printf "\n\nPress Ctrl+C twice to exit.\n\n" 1>&2
		sleep 2
		N=$(( N + 1 ))
		printf "This is reconnection number %s at %s.\n" "${N}" "$(date "+%Y-%m-%dT%H:%M:%S%Z")" | tee -a /tmp/binfo.sh_connect_retries.log 1>&2
		printf "Log file: /tmp/binfo.sh_connect_retries.log\n" 1>&2
		printf "Let's try reconnecting after some seconds.\n\n" 1>&2
		sleep 8
	done
}
if [[ -n "${SOCKETOPT}" ]]; then
	sstreamf
	# Exits automatically as err
	exit 1
fi

## -l Latest block (Similar to socket stream data )
latestf() {
	# Get JSON ( only has hash, time, block_index, height and txIndexes )
	LBLOCK="$(curl -s https://blockchain.info/latestblock)"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${LBLOCK}"
		exit 0
	fi
	# Print tx indexes first
	TXIDS="$(jq -r '.txIndexes[]' <<< "${LBLOCK}" | sort)"
	printf "Tx Index:\n"
	printf "%s\n" "${TXIDS[@]}" | column
	# Print the other info
	jq -r '. | "Block Hash:","\t\(.hash)",
		"Index_: \(.block_index)","Height: \(.height)",
		"Time__: \(.time | strftime("%Y-%m-%dT%H:%M:%SZ"))",
		"LocalT: \(.time |strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' <<< "${LBLOCK}"
}
if [[ -n "${LATESTOPT}" ]]; then
	latestf
	exit
fi

## -t Raw Tx info
rtxf() {
	# Check if there is a RAWTX from another function already
	if [[ -z "${RAWTX}" ]]; then 
		RAWTX=$(curl -s "https://blockchain.info/rawtx/${1}")
	fi
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${RAWTX}"
		exit 0
	fi
	printf "Transaction Info\n"
	jq -r '. | "--------",
		"TxHash: \(.hash)",
		"Tx ID_: \(.tx_index)\tBlk_ID: \(.block_index)\t\tDSpent: \(.double_spend)",
		"Size__: \(.size) bytes\tLockT_: \(.lock_time)\t\tVer___: \(.ver)",
		"Fee___: \(.fee // "??") sat  \tFee___: \(if .fee == null then "??" else (.fee/.size) end) sat/byte",
		"Relay_: \(.relayed_by//empty)",
		"Time__: \(.time | strftime("%Y-%m-%dT%H:%M:%SZ"))\tLocalT: \(.time |strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
		" From:",
		"  \(.inputs[].prev_out | "\(.addr)  \(if .value == null then "??" else (.value/100000000) end)  \(if .spent == true then "SPENT" else "UNSPENT" end)  FrTxID: \(.tx_index)  \(.addr_tag // "")")",
		" To__:",
		"  \(.out[] | "\(.addr)  \(if .value == null then "??" else (.value/100000000) end)  \(if .spent == true then "SPENT" else "UNSPENT" end)  ToTxID: \(.spending_outpoints // [] | .[] // { "tx_index": "00" } | .tx_index // "")  \(.addr_tag // "")")"' <<< "${RAWTX}"
}
if [[ -n "${TXOPT}" ]]; then
	rtxf "${1}"
	exit
fi

## -b Raw Block info
rblockf() {
	# Check whether input has block hash or
	# whether RAWB is from the hblockf function
	if [[ -z "${RAWB}" ]] && [[ -z "${1}" ]]; then
		printf "Fetching latest block hash...\n" 1>&2
		RAWB="$(curl -s "https://blockchain.info/rawblock/$(curl -s "https://blockchain.info/latestblock" | jq -r '.hash')")"
	elif [[ -z "${RAWB}" ]]; then
		RAWB="$(curl -s "https://blockchain.info/rawblock/${1}")"
	fi
	# print JSON?
	if [[ -n "${PJSON}" ]]; then
		printf "%s\n" "${RAWB}"
		exit 0
	fi
	# Print Txs info
	# Grep txs and call rawtxf function
	RAWTX="$(jq -r '.tx[]' <<< "${RAWB}")"
	rtxf
	# Print Block info
	printf "\n--------\n"
	printf "Block Info\n"
	jq -r '. | "Hash__: \(.hash)",
		"MrklRt: \(.mrkl_root)",
		"PrevB_: \(.prev_block)",
		"NextB_: \(.next_block[])",
		"Time__: \(.time | strftime("%Y-%m-%dT%H:%M:%SZ"))  LocalT: \(.time | strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
		"Bits__: \(.bits)\tNonce_: \(.nonce)",
		"Index_: \(.block_index)   \tVer___: \(.ver)",
		"Height: \(.height)      \tChain_: \(if .main_chain == true then "Main" else "Secondary" end)",
		"Size__: \(.size/1000) KB\tTxs___: \(.n_tx)",
		"Fees__: \(.fee/100000000) BTC",
		"Avg_F_: \(.fee/.size) sat/byte",
		"Relay_: \(.relayed_by // empty)"' <<< "${RAWB}"
	# Calculate total volume
	II=($(jq -r '.tx[].inputs[].prev_out.value // empty' <<< "${RAWB}"))
	OO=($(jq -r '.tx[].out[].value // empty' <<< "${RAWB}"))
	VIN=$(bc -l <<< "(${II[*]/%/+}0)/100000000")
	VOUT=$(bc -l <<< "(${OO[*]/%/+}0)/100000000")
	BLKREWARD=$(printf "%s-%s\n" "${VOUT}" "${VIN}" | bc -l)
	printf "Reward: %'.8f BTC\n" "${BLKREWARD}"
	printf "Input_: %'.8f BTC\n" "${VIN}"
	printf "Output: %'.8f BTC\n" "${VOUT}"
}
if [[ -n "${RAWOPT}" ]]; then
	rblockf "${1}"
	exit
fi


## -n Block info by height
hblockf() {
	RAWBORIG="$(curl -s "https://blockchain.info/block-height/${1}?format=json")"
	RAWB="$(jq -er '.blocks[]' <<< "${RAWBORIG}" 2>/dev/null)" || unset RAWB
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${RAWB}"
		exit 0
	fi
	rblockf
}
if [[ -n "${HOPT}" ]]; then
	hblockf "${1}"
	exit
fi


## -a Address info
raddf() {
	# -s Address Sumary?
	if [[ -n "${SUMMARYOPT}" ]]; then
		SUMADD=$(curl -s "https://blockchain.info/balance?active=${1}")
		# Print JSON?
		if [[ -n  "${PJSON}" ]]; then
			printf "%s\n" "${SUMADD}"
			exit 0
		fi
		# Check for error, then try Blockchair
		if grep -iq  -e "invalid" <<< "${SUMADD}"; then
			printf "Err: <blockchain.com> -- %s\n" "${SUMADD}" 1>&2
			printf "Changing to option \"-u\".\n" 1>&2
			${0} -u "${1}"
			exit
		fi	
		printf "Summary Address Info\n"
		jq -r '"Addr__: \(keys[])",
		"Tx_Num: \(.[].n_tx)",
		"T_Recv: \(.[].total_received) sat  (\(.[].total_received/100000000) BTC)",
		"Bal___: \(.[].final_balance) sat  (\(.[].final_balance/100000000) BTC)"' <<< "${SUMADD}"
		exit 0
	fi
	# Get RAW ADDR
	RAWADD=$(curl -s "https://blockchain.info/rawaddr/${1}")
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${RAWADD}"
		exit 0
	fi
	# Check for error, try Blockchair
	if grep -iq -e "illegal" -e "invalid" <<< "${RAWADD}"; then
		printf "Err: <blockchain.com> -- %s\n" "${RAWADD}" 1>&2
		printf "Changing to option \"-c\".\n" 1>&2
		${0} -c "${1}"
		exit
	fi
	# Tx info
	# Get txs and call rawtxf function
	RAWTX="$(jq -r '.txs[]' <<< "${RAWADD}")"
	rtxf
	printf -- "\n--------\n"
	printf "Address Info\n"
	jq -r '. | "Addr__: \(.address)",
		"Hx160_: \(.hash160)",
		"Tx_Num: \(.n_tx)",
		"T_Recv: \(.total_received) sat  (\(.total_received/100000000) BTC)",
		"T_Sent: \(.total_sent) sat  (\(.total_sent/100000000) BTC)",
		"Bal___: \(.final_balance) sat  (\(.final_balance/100000000) BTC)"' <<< "${RAWADD}"
}
if [[ -n "${ADDOPT}" ]]; then
	raddf "${1}"
	exit
fi

## -c Address Info ( from Blockchair )
chairaddf() {
	# Get address info
	CHAIRADD="$(curl -s "https://api.blockchair.com/bitcoin/dashboards/address/${1}")"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${CHAIRADD}"
		exit 0
	fi
	# -u Summary Address Information ?
	if [[ -n "${SUMMARYOPTB}" ]]; then
		printf "Summary Address Info (Blockchair)\n"
		jq -r '. | "Tx_Num: \(.data[].address.transaction_count)",
		"T_Recv: \(.data[].address.received/100000000) BTC  (\(.data[].address.received_usd|round) USD)",
		"T_Sent: \(.data[].address.spent/100000000) BTC  (\(.data[].address.spent_usd|round) USD)",
		"Bal___: \(.data[].address.balance/100000000) BTC  (\(.data[].address.balance_usd|round) USD)"' <<< "${CHAIRADD}" || return
		exit
	fi
	# Print Tx Hashes (only last 100)
	printf "\nTx Hashes (last 100):\n"
	jq -r '.data[] | "\t\(.transactions[])"' <<< "${CHAIRADD}"
	# Print unspent tx
	printf "\nUnspent Txs:\n"
	jq -er '.data[].utxo[] | "\t\(.transaction_hash)",
		"\t\t\t\tBlk id:\(.block_id)\tValue:\t\(.value/100000000) BTC"' <<< "${CHAIRADD}" || printf "No unspent tx list.\n"
	# Print Address info
	jq -r '. | "",
		"Address: \(.data|keys[])",
		"Type___: \(.data[].address.type)",
		"",
		"Output Counts",
		"T_Recv_: \(.data[].address.output_count)",
		"Unspent: \(.data[].address.unspent_output_count)",
		"Tx_Num_: \(.data[].address.transaction_count)",
		"",
		"Bal____: \(.data[].address.balance/100000000) BTC  (\(.data[].address.balance_usd|round) USD)",
		"T_Recv_: \(.data[].address.received/100000000) BTC  (\(.data[].address.received_usd|round) USD)",
		"Spent__: \(.data[].address.spent/100000000) BTC  (\(.data[].address.spent_usd|round) USD)",
		"",
		"First Received:\t\tLast Received:",
		"  \(.data[].address.first_seen_receiving//"")\t\(.data[].address.last_seen_receiving//"")",
		"First Spent:\t\tLast Spent:",
		"  \(.data[].address.first_seen_spending//"")\t\(.data[].address.last_seen_spending//"")",
		"Updated:\t\tNext Update:",
		"  \(.context.cache.since)Z\t\(.context.cache.until)Z"' <<< "${CHAIRADD}"
}
if [[ -n "${CHAIROPT}" ]]; then
	chairaddf "${1}"
	exit
fi

## -m Memory Pool Unconfirmed Txs ( Mempool )
## Uses blockchain.info and blockchair.com
utxf() {
	printf "All Tx Addresses and balance change in mempool.\n" 1>&2
	MEMPOOL="$(curl -s https://api.blockchair.com/bitcoin/state/changes/mempool)"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${MEMPOOL}"
		exit 0
	fi
	# Print Addresses and balance delta (in satoshi and BTC)
	jq -r '.data | keys_unsorted[] as $k | "\($k)    \(.[$k]) sat    \(.[$k]/100000000) BTC"' <<< "${MEMPOOL}"
	# 100 last blocks:
	printf "\nStats for last 100 blocks\n"
	printf "AvgTx/B: %.0f\n" "$(curl -s https://blockchain.info/q/avgtxnumber)"
	sleep 0.4
	printf "A_BTime: %.2f minutes\n" "$(bc -l <<< "$(curl -s https://blockchain.info/q/interval)/60")"
	sleep 0.4
	printf "Unc_Txs: %s\n" "$(curl -s https://blockchain.info/q/unconfirmedcount)"
	sleep 0.4
	printf "Blk_ETA: %.2f minutes\n" "$(bc -l <<< "$(curl -s https://blockchain.info/q/eta)/60")"
}
if [[ -n "${UTXOPT}" ]]; then
	utxf
	exit
fi

## -x Transaction info from Blockchair.com
txinfobcf() {
	TXCHAIR=$(curl -s "https://api.blockchair.com/bitcoin/dashboards/transaction/${1}")
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${TXCHAIR}"
		exit 0
	fi
	# Test response from server
	if grep -iq "DOCTYPE html" <<< "${TXCHAIR}"; then
		printf "Err: Transaction not found.\n" 1>&2
		exit 1
	fi
	printf "Transaction Info (Blockchair)\n"
	jq -er '.data[].inputs as $i | .data[].outputs as $o | .data[].transaction | "--------",
		"TxHash: \(.hash)",
		"Tx_ID_: \(.id)\tBlk_ID: \(.block_id)\t\(if .is_coinbase == true then "(Coinbase_Tx)" else "" end)",
		"Size__: \(.size) bytes\tLockT_: \(.lock_time)\t\tVer___: \(.version)",
		"Fee___:\t\tF_Rate:",
		"\t\(.fee // "??") sat\t\(.fee_per_kb // "??") sat/KB",
		"\t\(.fee_usd // "??") USD\t\(.fee_per_kb_usd // "??") USD/KB",
		"Time__: \(.time)Z\tLocalT: \(.time | strptime("%Y-%m-%d %H:%M:%S")|mktime|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
		" From:",
		($i[]|"  \(.recipient)  \(.value/100000000)  \(if .is_spent == true then "SPENT" else "UNSPENT" end)"),
		" To__:",
		($o[]|"  \(.recipient)  \(.value/100000000) \(if .is_spent == true then "SPENT" else "UNSPENT" end)  ToTxID: \(.spending_transaction_id)")' <<< "${TXCHAIR}"
}
if [[ -n "${TXBCHAIROPT}" ]]; then
	txinfobcf "${@}"
	exit
fi

## -i 24-H Ticker for the Bitcoin Blockchain
blkinfof() {
	printf "Bitcoin Blockchain General Info\n" 1>&2
	CHAINJSON="$(curl -s https://api.blockchain.info/stats)"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${CHAINJSON}"
		exit 0
	fi
	# Print the 24-H ticker
	jq -r '"Time___: \((.timestamp/1000)|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
		"",
		"Blockchain",
		"TMined_: \(.totalbc/100000000) BTC",
		"Height_: \(.n_blocks_total) blocks",
		"",
		"Rolling 24H Ticker",
		"BlkTime: \(.minutes_between_blocks) min",
		"T_Mined: \(.n_btc_mined/100000000) BTC \(.n_blocks_mined) blocks",
		"Reward_: \((.n_btc_mined/100000000)/.n_blocks_mined) BTC/block",
		"T_Size_: \(.blocks_size/1000000) MB",
		"AvgBlkS: \((.blocks_size/1000)/.n_blocks_mined) KB/block",
		"",
		"Difficulty and Hash Rate",
		"Diff___: \(.difficulty)",
		"HxRate_: \(.hash_rate) hashes/s",
		"Diff/HR: \(.difficulty/.hash_rate)",
		"",
		"Next Retarget",
		"@Height: \(.nextretarget)",
		"Blocks_: -\(.nextretarget-.n_blocks_total)",
		"Days___: -\( (.nextretarget-.n_blocks_total)*.minutes_between_blocks/(60*24))",
		"",
		"Transactions",
		"ETxVol_: \(.estimated_btc_sent/100000000) BTC",
		"ETxVol_: \(.estimated_transaction_volume_usd|round) USD",
		"",
		"Mining Costs",
		"TTxFees: \(.total_fees_btc/100000000) BTC",
		"Revenue: \(.miners_revenue_btc) BTC (\(.miners_revenue_usd|round) USD)",
		"FeeVol% [(TTxFees/Revenue)x100]:",
		"  \(((.total_fees_btc/100000000)/.miners_revenue_btc)*100) %",
		"RevenueVol% [(Revenue/TotalBtcSent)x100]:",
		"  \((.miners_revenue_btc/(.estimated_btc_sent/100000000))*100) %",
		"",
		"Market",
		"Price__: \(.market_price_usd) USD",
		"TxVol__: \(.trade_volume_btc) BTC (\(.trade_volume_usd|round) USD)"' <<< "${CHAINJSON}"
	printf "\nStats for last 100 blocks\n"
	printf "AvgTx/B: %.0f\n" "$(curl -s https://blockchain.info/q/avgtxnumber)"
	sleep 0.4
	printf "Unc_Txs: %s\n" "$(curl -s https://blockchain.info/q/unconfirmedcount)"
	sleep 0.4
	printf "Blk_ETA: %.2f minutes\n" "$(bc -l <<< "$(curl -s https://blockchain.info/q/eta)/60")"
}
if [[ -n "${BLKCHAINOPT}" ]]; then
	blkinfof
	exit
fi

## -o Ticker for the Bitcoin Blockchain from Blockchair (updates every ~5min)
blkinfochairf() {
	printf "Bitcoin Blockchain Stats from Blockchair\n"
	printf "Fetched at %s.\n\n" "$(date "+%Y-%m-%dT%H:%M:%S%Z")"
	CHAINJSON="$(curl -s "https://api.blockchair.com/bitcoin/stats")"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${CHAINJSON}"
		exit 0
	fi
	# Print the 24-H ticker
	jq -r '.data | "Nodes_: \(.nodes)\tBlocks: \(.blocks)",
		"Diff__: \(.difficulty)",
		"T_Txs_: \(.transactions)",
		"OutTxs: \(.outputs)",
		"Supply: \(.circulation/100000000) BTC  (\(.circulation) sat)",
		"",
		"Rolling stats of last 24-H",
		"Block Chain Size: \(.blockchain_size/1000000000) GB  (\(.blockchain_size) bytes)",
		"Blocks___: \(.blocks_24h)  Txs: \(.transactions_24h)",
		"Hash_Rate: \(.hashrate_24h) H/s  (\(.hashrate_24h|tonumber/1000000000000000000) ExaH/s)",
		"Volume___: \(.volume_24h/100000000) BTC  (\(.volume_24h) sat)",
		"Inflation: \(.inflation_24h/100000000) BTC  (\(.inflation_usd_24h) USD)",
		"CoinDaysDestroyed: \(.cdd_24h) BTC/24H",
		"",
		"Largest Transaction",
		"Transaction Hash:",
		"  \(.largest_transaction_24h.hash)",
		"Value_: \(.largest_transaction_24h.value_usd) USD",
		"",
		"Average Tx Fee  : \(.average_transaction_fee_24h) sat  (\(.average_transaction_fee_usd_24h) USD)",
		"Median Tx Fee   : \(.median_transaction_fee_24h) sat  (\(.median_transaction_fee_usd_24h) USD)",
		"Suggested Tx Fee: \(.suggested_transaction_fee_per_byte_sat) sat/byte",
		"",
		"Mempool",
		"Tx_Num: \(.mempool_transactions)",
		"Size__: \(.mempool_size)",
		"TxPSec: \(.mempool_tps) txs/sec",
		"T_Fee_: \(.mempool_total_fee_usd) USD",
		"",
		"Latest",
		"Blk_Hx:",
		"  \(.best_block_hash)",
		"Block_: \(.best_block_height)",
		"Time__: \(.best_block_time)",
		"",
		"Market",
		"Price_: \(.market_price_usd) USD  (\(.market_price_btc) BTC)",
		"Change: \(.market_price_usd_change_24h_percentage) %",
		"Cap___: \(.market_cap_usd) USD",
		"Domin_: \(.market_dominance_percentage) %",
		"",
		"Next Retarget",
		"Date__: \(.next_retarget_time_estimate)UTC",
		"Diff__: \(.next_difficulty_estimate)",
		"",
		"Other Events/Countdowns",
		(.countdowns[]|"Event: \(.event)","TimeLeft: \(.time_left/86400) days")' <<< "${CHAINJSON}"
}
if [[ -n "${BLKCHAINOPTCHAIR}" ]]; then
	blkinfochairf
	exit
fi

# Run -j without any other opt?
if [[ -n "${PJSON}" ]]; then
	printf "Err: option \"-j\" requires more parameters.\n"
	exit 1
fi
## Dead Code

