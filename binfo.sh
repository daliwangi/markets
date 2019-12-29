#!/bin/bash
# Binfo.sh -- Bash Interface for Blockchain.info API & Websocket Access
# v0.5.24  2019/dec  by mountaineerbr

## Some defalts
LC_NUMERIC=en_US.UTF-8

HELP="NAME
    binfo.sh  -- Bitcoin Explorer for Bash
    		 Bash Interface for Blockchain.info & Blockchair.com APIs
    

SYNOPSIS
	$ binfo.sh  [-aass \"AddressHx\"]
	
	$ binfo.sh  [-b \"BlockHx|ID\"] [-n \"BlockHeight\"]
	
	$ binfo.sh  [-tt \"TransactionHx|ID\"]
	
	$ binfo.sh  [-ehiilmv]


	This programme fetches information of Bitcoin blocks, addresses and 
	transactions from Blockchain.info (same as Blockchain.com) public APIs.
	It is intended to be used as a simple Bitcoin blockchain explorer. It 
	only accepts one argument for lookup at a time.

	Blockchain.info still does not support segwit addresses. On the other
	hand, Blockchair.com supports segwit and other types of addresses.

	Websocket connections are expected to drop ocasionally. Automatic recon-
	nection will be tried.


WARRANTY
	Licensed under the GNU Public License v3 or better and is distributed
	without support or bug corrections.

	This script needs the latest Bash, cURL or Wget, JQ, Websocat and
	Coreutils.
	
	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr



BLOCKCHAIN STRUCTURE

	The blockchain has four basic levels of organisation:
    
		(0)  Blockchain itself.
		(1)  Block.
		(2)  Address.
		(3)  Transaction.

	If you do not have a specific address or transaction to lookup, try 
	fetching the latest block hash and transaction info (option \"-l\").
	Note that the latest block takes a while to process, so you only get
	transaction IDs at first. For thorough block information, use option \"-b\"
	with the block hash. You can also inspect a block with option \"-n\" 
	and its height number.


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
	Recv_T           Received local time
	sat              satoshi
	S                Size
	Suggest.         Suggested
	ToTxID           To transaction ID number
	TPS              Transactions per second
	T                Total, Time
	T_Left           Time left
	TTxFees          Total transaction fees
	Tx/sec           Transactions per second
	Tx               Transaction
	Unconf           Unconfirmed
	Ver              Version
	Vol              Volume


USAGE EXAMPLES
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
	
	
	(6) Complete address information

		binfo.sh -a 34xp4vRoCGJym3xR7yCVPFHoCNxv4Twseo
	
	
	(7) Transaction information
	
		binfo.sh -t a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d
	

	(8) Market information from Blockchair

		binfo.sh -ii


Note: 	First block with transaction, genesis block, Binance cold wallet and
	the pizza transaction.


OPTIONS
    Blockhain
      -i 	Bitcoin blockchain info (24H rolling ticker); pass twice to use
      		Blockchair.com.
    Block
      -b 	Block information by hash or ID.
      -e 	Socket stream for new blocks.
      -l 	Latest block summary information.
      -n 	Block information by height.
    Address
      -a 	Address information; twice to use Blockchair.
      -s 	Summary address information; twice to use Blockchair.
    Transaction
      -t 	Transaction information by hash or ID; twice to use Blockchair.
    Other
      -h 	Show this help.
      -j 	Debug; print JSON.
      -m 	Memory pool unconfirmed transaction addresses and balance deltas
      		from Blockchair.
      -v        Print script version."

## Functions
## -e Socket stream for new blocks
sstreamf() {
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "JSON from last block.\n" 1>&2
		websocat --text "wss://ws.blockchain.info/inv" <<< "{'op':'ping_block'}"
		exit 0 
	fi
	#trap sigint ctrl+c
	trap 'exit' SIGINT
	# Start websocket connection and loop for recconeccting
	while true; do
		printf "New-block-found notification stream\n" 1>&2
		websocat --text --no-close --ping-interval 18 "wss://ws.blockchain.info/inv" <<< '{"op":"blocks_sub"}' |
			jq -r '.x | "--------",
			"New block found!",
			"Hash__:",
			"  \(.hash)",
			"MrklRt:",
			"  \(.mrklRoot)",
			"Bits__: \(.bits)\t\tNonce_: \(.nonce)",
			"Height: \(.height)\t\t\tDiff__: \(.difficulty)",
			"Txs___: \(.nTx)\t\t\tVer___: \(.version)",
			"Size__: \(.size) (\(.size/1000)_KB)\tWeight: \(.weight)",
			"Output: \(.totalBTCSent/100000000) BTC\tETxVol: \(.estimatedBTCSent/100000000) BTC",
			"Time__: \(.time|strftime("%Y-%m-%dT%H:%M:%SZ"))",
			"LocalT: \(.time|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))\tRecv_T: \(now|round|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"'
		N=$((++N))
		printf 'Log: /tmp/binfo.sh.reconnects.log\n' 1>&2
		printf 'Reconnection #%s at %s.\n' "${N}" "$(date "+%Y-%m-%dT%H:%M:%S%Z")" | tee -a /tmp/binfo.sh_connect_retries.log 1>&2
		sleep 4
	done
	#"Blk_ID: \(if .blockIndex == 0 then empty else .blockIndex end)\t\tPrevId: \(.prevBlockIndex)",
	#"Reward:\t\(if .reward == 0 then empty else .reward end)",
	#"FoundByTime: \(if .foundBy.time == 0 then empty else .foundBy.time|strftime("%Y-%m-%dT%H:%M:%SZ") end)",
	#"IP____: \(if .foundBy.ip == empty then empty else .foundBy.ip end)  Desc__: \(.foundBy.description)",
	#"Link__: \(if .foundBy.link == empty then empty else .foundBy.link end)"'
	#{"op":"blocks_sub"}
	#{"op":"unconfirmed_sub"}
	#{"op":"ping"}
}

## -l Latest block (Similar to socket stream data )
latestf() {
	# Get JSON ( only has hash, time, block_index, height and txIndexes )
	LBLOCK="$(${YOURAPP} "https://blockchain.info/latestblock")"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "JSON from the lastest block function.\n" 1>&2
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

## -i 24-H Ticker for the Bitcoin Blockchain
blkinfof() {
	printf "Bitcoin Blockchain General Info\n"
	CHAINJSON="$(${YOURAPP} "https://api.blockchain.info/stats")"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "JSON from the 24H ticker function.\n" 1>&2
		printf "%s\n" "${CHAINJSON}"
		exit 0
	fi
	# Print the 24-H ticker
	jq -r '"Time___: \((.timestamp/1000)|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
		"",
		"Blockchain",
		"T_Mined: \(.totalbc/100000000) BTC",
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
	# Some more stats
	printf "\nMempool\n"
	printf "Unconf_Txs: %s\n" "$(${YOURAPP} "https://blockchain.info/q/unconfirmedcount")"
	printf "Block_ETA_: %.2f minutes\n" "$(bc -l <<< "$(${YOURAPP} "https://blockchain.info/q/eta")/60")"
	printf "Last 100 blocks\n"
	printf "Avg_Txs/B_: %.0f\n" "$(${YOURAPP} "https://blockchain.info/q/avgtxnumber")"
	printf "Avg_B_Time: %.2f minutes\n" "$(bc -l <<< "$(${YOURAPP} "https://blockchain.info/q/interval")/60")"
}

## -ii Ticker for the Bitcoin Blockchain from Blockchair (updates every ~5min)
blkinfochairf() {
	printf "Bitcoin Blockchain Stats from Blockchair\n"
	printf "Fetched at %s.\n\n" "$(date "+%Y-%m-%dT%H:%M:%S%Z")"
	CHAINJSON="$(${YOURAPP} "https://api.blockchair.com/bitcoin/stats")"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "JSON from the chair 24H ticker function.\n" 1>&2
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
		"Average_Tx_Fee__: \(.average_transaction_fee_24h) sat  (\(.average_transaction_fee_usd_24h) USD)",
		"Median_Tx_Fee___: \(.median_transaction_fee_24h) sat  (\(.median_transaction_fee_usd_24h) USD)",
		"Suggested_Tx_Fee: \(.suggested_transaction_fee_per_byte_sat) sat/byte",
		"",
		"Mempool",
		"Tx_Num: \(.mempool_transactions)",
		"Size__: \(.mempool_size)",
		"Tx/sec: \(.mempool_tps)",
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
		(.countdowns[]|"Event_: \(.event)","T_Left: \(.time_left/86400) days")' <<< "${CHAINJSON}"
		## SPECIAL function for the Halving!!
		HTIME="$(jq -r '.data.countdowns[]|select(.event=="Reward halving").time_left' <<<"${CHAINJSON}")"
		if [[ -n "${HTIME}" ]]; then
			printf '\n'
			cat <<-!
			Bitcoin Reward Halving
			Est. local time @ block 630000
			$(date --date="${HTIME} sec")
			!
		fi
}

## -m -u Memory Pool Unconfirmed Txs ( Mempool )
## Uses blockchain.info and blockchair.com
utxf() {
	printf "Mempool unconfirmed transactions.\n" 1>&2
	printf "Addresses and balance deltas.\n" 1>&2
	MEMPOOL="$(${YOURAPP} "https://api.blockchair.com/bitcoin/state/changes/mempool")"
	#MEMPOOL2="$(${YOURAPP} "https://api.blockchair.com/bitcoin-cash/mempool/transactions")"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "JSON from the mempool function.\n" 1>&2
		printf "%s\n" "${MEMPOOL}"
		exit 0
	fi
	# Print Addresses and balance delta (in satoshi and BTC)
	jq -r '.data | keys_unsorted[] as $k | "\($k)      \(.[$k])      \(.[$k]/100000000)  BTC"' <<< "${MEMPOOL}"
	jq -r '.context.cache.since' <<< "${MEMPOOL}"
	printf "Results____: %s\n" "$(jq -r '.context.results' <<<"${MEMPOOL}")"
	#curl -s "https://api.blockchair.com/bitcoin/mempool/transactions" | jq -r '.context.total_rows'
	TOTALDELTA="$(jq -r '.data[]|tostring|match("^[1-9][0-9]+")|.string' <<<"${MEMPOOL}" | paste -sd+ | bc -l)"
	TOTALDELTA="$(bc -l <<<"${TOTALDELTA}/100000000")"
	printf "Total_Value: %.8f  BTC\n" "${TOTALDELTA}"
}

## -b Raw Block info
rblockf() {
	# Check whether input has block hash or
	# whether RAWB is from the hblockf function
	if [[ -z "${RAWB}" ]] && [[ -z "${1}" ]]; then
		printf "Fetching latest block hash...\n" 1>&2
		RAWB="$(${YOURAPP} "https://blockchain.info/rawblock/$(${YOURAPP} "https://blockchain.info/latestblock" | jq -r '.hash')")"
	elif [[ -z "${RAWB}" ]]; then
		RAWB="$(${YOURAPP} "https://blockchain.info/rawblock/${1}")"
	fi
	# print JSON?
	if [[ -n "${PJSON}" ]]; then
		printf "JSON from the raw block info function.\n" 1>&2
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

## -n Block info by height
hblockf() {
	RAWBORIG="$(${YOURAPP} "https://blockchain.info/block-height/${1}?format=json")"
	RAWB="$(jq -er '.blocks[]' <<< "${RAWBORIG}" 2>/dev/null)" || unset RAWB
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "JSON from the heigh/n block info function.\n" 1>&2
		printf "%s\n" "${RAWB}"
		exit 0
	fi
	rblockf
}

## -a Address info
raddf() {
	# -s Address Sumary?
	if [[ -n "${SUMMARYOPT}" ]]; then
		SUMADD=$(${YOURAPP} "https://blockchain.info/balance?active=${1}")
		# Print JSON?
		if [[ -n  "${PJSON}" ]]; then
			printf "JSON from the summary address function.\n" 1>&2
			printf "%s\n" "${SUMADD}"
			exit 0
		fi
		# Check for error, then try Blockchair
		if grep -iq -e "err:" -e "illegal" -e "invalid" -e "Checksum does not validate" <<< "${SUMADD}"; then
			printf "Err: <blockchain.com> -- %s\n" "${SUMADD}" 1>&2
			printf "Trying with Blockchair...\n" 1>&2
			chairaddf "${1}"
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
	RAWADD=$(${YOURAPP} "https://blockchain.info/rawaddr/${1}")
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "JSON from the address function.\n" 1>&2
		printf "%s\n" "${RAWADD}"
		exit 0
	fi
	# Check for error, try Blockchair
	if grep -iq -e "err:" -e "illegal" -e "invalid" -e "Checksum does not validate" <<< "${RAWADD}"; then
		printf "Err: <blockchain.com> -- %s\n" "${RAWADD}" 1>&2
		printf "Trying with Blockchair...\n" 1>&2
		chairaddf "${1}"
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

## -aa Address Info ( from Blockchair )
chairaddf() {
	# Get address info
	CHAIRADD="$(${YOURAPP} "https://api.blockchair.com/bitcoin/dashboards/address/${1}")"
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "JSON from the chair address function.\n" 1>&2
		printf "%s\n" "${CHAIRADD}"
		exit 0
	fi
	# -u Summary Address Information ?
	if [[ -n "${SUMMARYOPT}" ]]; then
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
		"\t  Blk id: \(.block_id)  Value: \(.value/100000000) BTC"' <<< "${CHAIRADD}" || printf "No unspent tx list.\n"
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

## -t Raw Tx info
rtxf() {
	# Check if there is a RAWTX from another function already
	if [[ -z "${RAWTX}" ]]; then 
		RAWTX=$(${YOURAPP} "https://blockchain.info/rawtx/${1}")
	fi
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		# only if from tx opts explicitly
		printf "JSON from the tx function.\n" 1>&2
		printf "%s\n" "${RAWTX}"
		exit 0
	fi
	printf "Transaction Info\n"
	# Test for no Tx info received, maybe there is no tx done at an address
	if ! jq -e '.hash' <<<"${RAWTX}" 1>/dev/null 2>&1; then 
		printf "No transactions\n"
		return 1
	fi
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

## -tt Transaction info from Blockchair.com
txinfobcf() {
	TXCHAIR=$(${YOURAPP} "https://api.blockchair.com/bitcoin/dashboards/transaction/${1}")
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "JSON from the chair tx function.\n" 1>&2
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


## Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit 0
fi
# Must have packages
if ! command -v jq &>/dev/null; then
	printf "JQ is required.\n" 1>&2
	exit 1
fi
if command -v curl &>/dev/null; then
	YOURAPP="curl -s"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO-"
else
	printf "cURL or Wget is required.\n" 1>&2
	exit 1
fi

# Parse options
while getopts ":abehijlmnsutv" opt; do
	case ${opt} in
		a ) # Address info
			test -z "${ADDOPT}" && ADDOPT=info || ADDOPT=chair
		  	;;
		b ) # Raw Block info
			RAWOPT=1
			;;
		e ) # Soket mode for new BTC blocks
			STREAMOPT=1
			;;
		h ) # Help
			echo -e "${HELP}"
			exit 0
			;;
		i ) # 24-H Blockchain Ticker
			test -z "${BLKCHAINOPT}" && BLKCHAINOPT=info || BLKCHAINOPT=chair
			;;
		j ) # Print JSON
			PJSON=1
			;;
		l ) # Latest Block info
			latestf
			exit
			;;
		m|u ) # Memory Pool Unconfirmed Txs
			MEMOPT=1
			;;
		n ) # Block Height info
			HOPT=1
			;;
		s ) # Summary  Address info
			SUMMARYOPT=1
			test -z "${ADDOPT}" && ADDOPT=info || ADDOPT=chair
			;;
		t ) # Transaction info
			test -z "${TXOPT}" && TXOPT=info || TXOPT=chair
			;;
		v ) # Version of Script
			head "${0}" | grep -e '# v'
			exit 0
			;;
		\? )
			printf "Invalid Option: -%s\n" "${OPTARG}" 1>&2
			exit 1
			;;
	 esac
done
shift $((OPTIND -1))

# Check function args
if { [[ -n "${ADDOPT}" ]] || [[ -n "${TXOPT}" ]];} && [[ -z "${1}" ]]; then
	printf "Err: Tx/Addr ID/Hash is needed.\n" 1>&2
	exit 1
fi

# Call opts
# New block stream
if [[ -n "${STREAMOPT}" ]]; then
	sstreamf
	exit
# Blockchain information / stats
elif [[ "${BLKCHAINOPT}" = info ]]; then
	blkinfof
	exit
elif [[ "${BLKCHAINOPT}" = chair ]]; then
	blkinfochairf
	exit
# Blocks
elif [[ -n "${HOPT}" ]]; then
	hblockf "${1}"
	exit
elif [[ -n "${RAWOPT}" ]]; then
	rblockf "${1}"
	exit
# Addresses
elif [[ "${ADDOPT}" = info ]]; then
	raddf "${1}"
	exit
elif [[ "${ADDOPT}" = chair ]]; then
	chairaddf "${1}"
	exit
# Transactions
elif [[ "${TXOPT}" = info ]]; then
	rtxf "${1}"
	exit
elif [[ "${TXOPT}" = chair ]]; then
	txinfobcf "${@}"
	exit
elif [[ -n "${MEMOPT}" ]]; then
	utxf
	exit
fi

