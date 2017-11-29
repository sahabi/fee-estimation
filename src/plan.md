### Objective

We want to find the fee rate that you should use to in order for your tx to be included in the blockchain within a given target number of blocks.

### Development Plan

To achieve the above objective, we return the lowest fee rate that will with high probability (%95) achieves the objective.

- [ ] build a daemon for running the db update process for unconfirmed and confirmed txs:
  
    forever:
      - [ ] get all current unconfirmed txs in the mempool
        - [x] Function: retrieve the current mempool     
      - [ ] update the unconfirmed txs in db
        - [x] Function: from the mempool create unconfirmed txs
        - [x] Function: write new unconfirmed txs to db
      - [ ] fetch unconfirmed txs from db
        - [x] Function: retrieve unconfirmed txs from db
      - [ ] get the next block
        - [x] Function: retrieve the latest block 
      - [ ] update db for unconfirmed and confirmed txs by checking txs in block
        - [x] Function: from the mempool and the latest block create a list of confirmed txs 
        - [x] Functions: write list of confirmed txs to db. 
      - [ ] wait for 5 minutes

- [ ] build the bucket creation and update process

  - [x] Function: retrieve confirmed txs from db 
  - [ ] Function: confirmed txs -> Buckets
  - [ ] Function: update unconfirmed txn in db




### Testing Plan
