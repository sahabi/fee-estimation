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
1. create RawMempool type (done)
2. create functions to retrieve the current mempool (done)
3. create function to retrieve the latest block (done)
4. from the mempool create a list of unconfirmed transactions (done)
5. from the mempool and the latest block create a list of confired transactions (done)
6. function: from the list of txs in the mempool and the latest block filter the list (done)
7. store two lists of transactions in a database:
    1- the list of unconfirmed transactions, their fees and their height (done)
    2- list of transactions included in the blockchain, their fees, height entered mempool, height entered blockchain and delta heights. (done)
8. function: retrieve unconfirmed transactions from db (done)
9. function: retrieve confirmed transactions from db (done)
10. function: confirmed transactions -> Buckets
11. function: update unconfirmed transaction in db
