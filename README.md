# markets
![ScreenShot](https://github.com/mountaineerbr/markets/blob/master/git_screenshot1.png)
Fig. 1. Running scripts: binance.sh, bitfinex.sh, binfo.sh, bitstamp.sh, cgk.sh, cmc.sh, etc.

---

<b>SUMMARY</b>

This is a repo related to crypto, bank currency and stock markets.

Run the script with '-h' for a help page. Check below for script descriptions, download and basic instructions to run them.

These scripts use the latest version of Bash. Other packages that may be required to run some functions are Curl/Wget, Jq, Websocat and Lolcat.

---

<b>SUMÁRIO</b>

Este repo é relacionado com mercados de cripto, de moedas de banco centrais e ações. Rode os scripts com '-h' para uma página de ajuda.

Esses scripts usam a última versão do Bash. Outros pacotes que podem precisar estar presentes para rodar algumas funções são Curl/Wget, Jq, Websocat and Lolcat.

---

<b>INDEX / ÍNDICE</b>

<b>alpha.sh</b> -- Stocks and currency rates from <alphaavantage.co>, most popular yahoo finance api alternative; get your free API key.

<b>bakkt.sh --</b> Price and contract/volume tickers from bakkt public api.

<b>binance.sh --</b>  Binance public API, crypto converter, prices, book depth, coin ticker.

<b>binfo.sh --</b> Blockchain explorer for bitcoin; uses <blockchain.info> and <blockchair.com> public apis; notification on new block found.

<b>bitstamp.sh --</b> Bitstamp exchange public api for live trade prices/info.

<b>bitfinex.sh --</b> Bitfinex exchange public api for live trade prices.

<b>brasilbtc.sh --</b> Fetches bitcoin rates from brazilian exchanges public apis. Puxa cotações de bitcoin de agências de câmbio brasileiras de apis públicas;

<b>cgk.sh --</b> <Coinggecko.com> public api, currency converter, market ticker, cryptocurrency ticker. This is my favorite everyday-use script for all-currency rates!

<b>clay.sh --</b> <Currencylayer.com> api, central bank currency, precious metal and cryptocurrency converter.

<b>cmc.sh --</b>  <Coinmarketcap.com> api, currency converter, market ticker.

<b>erates.sh --</b> <Exchangeratesapi.io> public api, currency converter (same API as Alexander Epstein's Bash-Snippets/currency).

<b>foxbit.sh --</b> FoxBit public API rates. Acesso ao api público da Foxbit para cotações.

<b>hgbrasil.sh --</b> Bovespa and tax rates. Cotações de ações da Bovespa e índices e taxas (CDI e SELIC) do api da hg brasil.

<b>myc.sh --</b> <Mycurrency.net> public api, central bank currency converter.

<b>openx.sh --</b> <Openexchangerates.org> api, central bank currency converter.

<b>ourominas.sh --</b> Ourominas (precious metals exchange) rates public api. Pega taxas da api pública da Ouro Minas.

<b>parmetal.sh --</b> Parmetal (precious metals exchange) rates public api. Pega taxas da api pública da Parmetal.

<b>stocks.sh --</b> <Financialmodelingprep.com> public api latest and historical stock rates

<b>uol.sh --</b> Fetches rates from uol service provider public api. Puxa dados de páginas da api pública do uol economia.

<b>yahooFinanceSymbols.txt</b> -- Some yahoo finance stock symbols. Alguns símbolos do yahoo finance.

<b>whalealert.sh --</b> Latest whale transactions from <whale-alert.io> api.

---

<b>API KEYS / CHAVES DE API</b>

Please create free API keys to use with these scripts.

Por favor, crie chaves de API grátis para usar com esses scripts.</b>
  
---

<b>ALSO CHECK / TAMBÉM VEJA</b>

<b>bcalc.sh -- </b> Bash calculator wrapper that keeps a record of results

<https://github.com/mountaineerbr/scripts/blob/master/bcalc.sh>

Alexander Epstein's 'currency_bash-snipet.sh'; uses the same API as 'erates.sh'

<https://github.com/alexanderepstein>

MiguelMota's 'Cointop' for crypto currency tickers

<https://github.com/miguelmota/cointop>

8go's 'CoinBash.sh' for CoinMarketCap simple tickers (a little outdated)

<https://github.com/8go/coinbash> 

Brandleesee's 'Mop: track stocks the hacker way'

<https://github.com/mop-tracker/mop>

---

<b>IMPORTANT / IMPORTANTE</b>

None of these scripts are supposed to be used under truly professional constraints. Do your own research!

Nenhum desses scripts deve ser usado em meio profissional sem análise prévia. Faça sua própria pesquisa!

---

<b>BASIC INSTRUCTIONS</b>

On Ubuntu 19.04, you can install curl, jq and lolcat packages easily from the official repos. The websocat package may be a little more complicated..

To download a script, view it on Github. Then, right-click on the 'Raw' button and choose 'Save Link As ...' option. Once downloaded (eg ~/Downloads/binance.sh), you will need to mark the script as executable. In GNOME, right-click on the file > Properties > Permissions and check the 'Allow executing file as programme' box, or

<i>$ chmod +x ~/Downloads/binance.sh</i>

Then cd to the folder where the script is located.

<i>$ cd ~/Downloads</i>

To execute it, be sure to add './' before the script name:

<i>$ ./binance.sh
  
$ bash binance.sh</i>

Alternatively, you can clone this entire repo.

<i>$ cd Downloads

$ git clone https://github.com/mountaineerbr/markets.git

$ chmod +x ~/Downloads/markets/*.sh</i>

You can use bash aliases to individual scripts or place them under your PATH.

---

<b>INSTRUÇÕES BÁSICAS</b>

No Ubuntu 19.04, pode-se instalar os pacotes curl, jq e lolcat facilmente dos repos oficiais. Já o pacote websocat pode ser um pouco mais complicado..

Para fazer o download de um script, abra-o/visualize-o no Github e depois clique com o botão direito do mouse em cima do botão 'Raw' e escolha a opção 'Salvar Link Como...'. Depois de feito o download (por exemplo, em ~/Downloads/binance.sh), será necessário marcar o script como executável. No GNOME, clicar com o botão direito em cima do arquivo > Propriedades > Permissões e selecionar a caixa 'Permitir execução do arquivo como programa', ou

<i>$ chmod +x ~/Downloads/binance.sh</i>

Então, caminhe até a pasta onde script se encontra.

<i>$ cd ~/Downloads</i>

Para executá-lo, não se esqueça de adicionar './' antes do nome do script:

<i>$ ./binance.sh

$ bash binance.sh</i>

Alternativeamente, você pode clonar este repo inteiro.

<i>$ cd Downloads

$ git clone https://github.com/mountaineerbr/markets.git

$ chmod +x ~/Downloads/markets/*.sh</i>

Você pode fazer bash aliases individuais para os scripts ou colocar os scripts sob seu PATH.

---

<b>If useful, consider giving me a nickle! =)
  
Se foi útil, considere me lançar um trocado!</b>

bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr
