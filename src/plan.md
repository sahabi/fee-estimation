we want to find the fee rate that you should use to in order for your tx to be included in the blockchain within a given target number of blocks.

to achieve this we return the lowest fee rate that will with high probability (%95) achieves the objective.

Buckets creation process:

while not enough data points
1- get all current unconfirmed transactions in the mempool
2- update the DB table of unconfirmed transactions
3- get the next block
4- update the DB tables of unconfirmed transactions and confirmed transactions by checking the block


RPC command: getrawmempool
parameters: Format (true)
1- create RawMempool type (done)
2- create functions to retrieve the current mempool (done)
3- function: from the list of txs in the mempool and the latest block filter the list (done)
4- store two lists of transactions in a database:
    1- the list of unconfirmed transactions, their fees and their height
    2- the list of transactions included in the blockchain, their fees, height entered mempool, height entered blockchain and delta heights.
5- function: retrieve unconfirmed transactions from db done
6- function: retrieve confirmed transactions from db done
7- function: confirmed transactions -> Buckets
8- function: update unconfirmed transaction in db
