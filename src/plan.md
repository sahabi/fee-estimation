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
- [x] Type: RawMempool
- [x] Function: retrieve the current mempool 
- [x] Function: retrieve the latest block 
- [x] Function: from the mempool create a list of unconfirmed transactions 
- [x] Function: from the mempool and the latest block create a list of confired transactions 
- [x] Function: from the list of txs in the mempool and the latest block filter the list 
- [x] Functions: store two lists of transactions in a database:
    - [x] the list of unconfirmed transactions, their fees and their height 
    - [x] list of transactions included in the blockchain, their fees, height entered mempool, height entered blockchain and delta heights. 
- [x] Function: retrieve unconfirmed transactions from db
- [x] Function: retrieve confirmed transactions from db 
- [] function: confirmed transactions -> Buckets
- [] function: update unconfirmed transaction in db
