# markets
Related to crypto and bank currency markets. Run them with "-h" for a Help Page.

These scripts use the latest version of Bash. Other packages that may be required to run some functions are:

Curl, JQ, Websocat and Lolcat.

Check below for script descriptions, download and run basic instructions.

-------------------------------------------------------------------------------------------------
ESTE REPOSITÓRIO é relacionado com mercados de cripto e de moedas de banco centrais.

Rode os scripts com "-h" para ver uma página de Ajuda (em Inglês).

Esses scripts usam a última versão do Bash. Outros pacotes que precisam estar presentes

no sistema para que todas as funções trabalhem corretamente são:

Curl, JQ, Websocat and Lolcat.

-------------------------------------------------------------------------------------------------

No Ubuntu 19.04, pode-se instalar os pacotes curl, jq e lolcat facilmente dos repos oficiais.
Já o pacote websocat é um pouco mais complicado. Teria que construir do código fonte.
Achei um script que pode tentar instalar o websocat automaticamente no Ubuntu:
https://gist.github.com/mingliangguo/635345dcd6b603da337d4c71792bd330

No Arch, o curl já deve vir instalado por padrão. O jq você acha nos repos oficiais, assim como o lolcat.
O websocat se encontra no AUR.

-------------------------------------------------------------------------------------------------

On Ubuntu 19.04, you can install curl, jq and lolcat packages easily from the official repos.
The websocat package is a little more complicated. It would be necessary to build from source code.
I found a script that can try to build and install websocat automatically on Ubuntu:
https://gist.github.com/mingliangguo/635345dcd6b603da337d4c71792bd330

In Arch, curl should already be installed by default. You find jq and lolcat in the official repos.
Websocat is at AUR.

-------------------------------------------------------------------------------------------------

bcalc.sh -- Simple Bash calculator that uses bc and keeps a record of results;

binance.sh -- Crypto converter and access Binance public API, prices, book depth, coin ticker;

binfo.sh -- Blockchain Explorer for Bitcoin; uses Blockchain.info & BlockChair.com public APIs;

bitstamp.sh -- Access Bitstamp live price roll API;

cgk.sh -- Currency converter using CoingGecko.com public API, market ticker;

clay.sh -- Central bank currency, precious metal and (BTC) crypto converter using CurrencyLayer.com API;

cmc.sh -- Currency converter using CoinMarketCap.com API, market ticker;

erates.sh -- Currency converter using ExchangeRatesAPI.io public API;

myc.sh -- Central bank currency converter using MyCurrency.net public API;

openx.sh -- Central bank currency converter using OpenExchangeRates.org API.
