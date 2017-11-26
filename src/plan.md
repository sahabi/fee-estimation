we want to find the fee rate that you should use to in order for your tx to be included in the blockchain within a given target number of blocks.

to achieve this we return the lowest fee rate that will with high probability (%95) achieves the objective.

first we get all current unspent transactions

RPC command: getrawmempool
parameters: Format (true)
1- create RawMempool type (done)
2- create functions to retrieve the current mempool (done)
3- from the list of txs of the current mempool and the latest block generate a list of confirmed transactions
4- 
