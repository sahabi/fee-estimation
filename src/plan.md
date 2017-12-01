### Objective

We want to find the fee rate that you should use to in order for your tx to be included in the blockchain within a given target number of blocks.

### Development Plan

To achieve the above objective, we return the lowest fee rate that will with high probability (%95) achieves the objective.

- [x] build a priodic process for updating the confirmed txs db table:
  
  forever:
  - [x] fetch unconfirmed txs from db
    - [x] Function: retrieve unconfirmed txs from db
  - [x] get the next block
    - [x] Function: retrieve the latest block 
  - [x] update db for unconfirmed txs by checking txs in block
    - [x] Function: from the mempool and the latest block create a list of confirmed txs 
    - [x] Functions: write list of confirmed txs to db. 
  - [x] wait for 5 minutes


- [x] build a priodic process for updating the unconfirmed txs db table:
  
  forever:
  - [x] get all current unconfirmed txs in the mempool
    - [x] Function: retrieve the current mempool     
  - [x] update the unconfirmed txs in db
    - [x] Function: from the mempool create unconfirmed txs
    - [x] Function: write new unconfirmed txs to db

- [ ] build a priodic process for updating the buckets db table

  - [x] Function: retrieve the lastest confirmed txs from db 
  - [ ] Function: latest confirmed txs -> current buckets -> new buckets

- [ ] build the estimation algorithm
  
  - [ ] Function: target -> buckets -> fee

- [ ] build the ui

- [ ] deploy the website



### Testing Plan
