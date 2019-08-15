# markets
<b>SUMMARY:</b>

Related to crypto and bank currency markets. Run them with "-h" for a Help Page.

These scripts use the latest version of Bash. Other packages that may be required to run some functions are:

Curl, JQ, Websocat and Lolcat.

Check below for script descriptions, download and run basic instructions.

-------------------------------------------------------------------------------------------------

<b>SUMÁRIO:</b>

ESTE REPOSITÓRIO é relacionado com mercados de cripto e de moedas de banco centrais.

Rode os scripts com "-h" para ver uma página de Ajuda (em Inglês).

Esses scripts usam a última versão do Bash. Outros pacotes que precisam estar presentes

no sistema para que todas as funções trabalhem corretamente são:

Curl, JQ, Websocat and Lolcat.

-------------------------------------------------------------------------------------------------

<b>INDEX</b>:

<b>bcalc.sh --</b> Simple Bash calculator that uses bc and keeps a record of results;

<b>binance.sh --</b> Crypto converter and access Binance public API, prices, book depth, coin ticker;

<b>binfo.sh --</b> Blockchain Explorer for Bitcoin; uses Blockchain.info & BlockChair.com public APIs;

<b>bitstamp.sh --</b> Access Bitstamp live price roll API;

<b>cgk.sh --</b> [RELEASED!] Currency converter using CoingGecko.com public API, market ticker;

<b>clay.sh --</b> Central bank currency, precious metal and (BTC) crypto converter using CurrencyLayer.com API;

<b>cmc.sh --</b> [instruction manual needs improvement!!] Currency converter using CoinMarketCap.com API, market ticker [will show more info soon for alts!];

<b>erates.sh --</b> Currency converter using ExchangeRatesAPI.io public API;

<b>myc.sh --</b> Central bank currency converter using MyCurrency.net public API;

<b>openx.sh --</b> Central bank currency converter using OpenExchangeRates.org API.

-------------------------------------------------------------------------------------------------

<b>INSTRUÇÕES BÁSICAS:</b>

No Ubuntu 19.04, pode-se instalar os pacotes curl, jq e lolcat facilmente dos repos oficiais.

Já o pacote websocat é um pouco mais complicado. Teria que construir do código fonte.

Achei um script que pode tentar instalar o websocat automaticamente no Ubuntu:

https://gist.github.com/mingliangguo/635345dcd6b603da337d4c71792bd330


No Arch, o curl já deve vir instalado por padrão. O jq você acha nos repos oficiais, assim como o lolcat.

O websocat se encontra no AUR.


Para fazer o download do script, abra/visualize-o no Github e depois clique com o botão

direito do mouse em cima do botão RAW e escolher a opção "Salvar Link Como...".

Depois de feito o download (por exemplo, em ~/Downloads/binance.sh), será necessário marcar o script

como executável. No GNOME, clicar com o botao direito em cima do arquivo > Propriedades > Permissões 

e selecionar a caixa "Permitir execução do arquivo como programa".

ou

$ chmod +x ~/Downloads/binance.sh

Então, caminhe até a pasta onde script se encontra.

$ cd ~/Downloads


Para executá-lo, não se esqueça de adeicionar ./ antes do nome do script:

$ ./binance.sh

ou

$ bash binance.sh


Nada impede que se crie atalhos de bash em ~/.bashrc para os scripts (aliases)
ou ainda que se os mova para pasta /bin ou para alguma outra pasta no seu PATH.

-------------------------------------------------------------------------------------------------

<b>BASIC INSTRUCTIONS:</b>

On Ubuntu 19.04, you can install curl, jq and lolcat packages easily from the official repos.

The websocat package is a little more complicated. It would be necessary to build from source code.

I found a script that can try to build and install websocat automatically on Ubuntu:

https://gist.github.com/mingliangguo/635345dcd6b603da337d4c71792bd330


In Arch, curl should already be installed by default. You find jq and lolcat in the official repos.

Websocat is at AUR.


Download the script by viewing it on Github. Then, right-click on the RAW button and

choose "Save Link As ..." option.


Once downloaded (eg ~ / Downloads / binance.sh), you will need to mark the script

as executable. In GNOME, right-click on the file > Properties> Permissions

and check the "Allow executing file as programme" box.

or

$ chmod + x ~ / Downloads / binance.sh


Then cd to the folder where the script is located.

$ cd ~ / Downloads


To execute it, be sure to add ./ before the script name:

$ ./binance.sh

or

$ bash binance.sh


Nothing prevents you from creating bash aliases in ~ / .bashrc for these scripts

or move them to the /bin folder or some other folder under your PATH.

-------------------------------------------------------------------------------------------------
<b>Me lance um trocado!
   Give me a nickle! =)</b>

bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr

