--- Create two pluggable databases: one for mixed data and one for clean
CREATE PLUGGABLE DATABASE PDB_MIXED
ADMIN USER pdb_mixed_admin IDENTIFIED BY oracle
FILE_NAME_CONVERT = ('pdbseed', 'pdb_mixed');
--
CREATE PLUGGABLE DATABASE PDB_CLEAN_SECURE
ADMIN USER pdb_clean_admin IDENTIFIED BY oracle
FILE_NAME_CONVERT = ('pdbseed', 'pdb_clean_secure');

ALTER PLUGGABLE DATABASE PDB_MIXED OPEN;
ALTER PLUGGABLE DATABASE PDB_CLEAN_SECURE OPEN;

ALTER SESSION SET CONTAINER = PDB_MIXED;

--create table to hold raw bank transactions
CREATE TABLE bank_transactions_raw (
    transaction_id NUMBER,
    account_id NUMBER,
    amount NUMBER,
    transactions_today NUMBER,
    country_change CHAR(1),
    failed_attempts NUMBER,
    transaction_hour NUMBER
);

--create wallet and encryption key for secure pluggable database
ALTER SESSION SET CONTAINER = PDB_CLEAN_SECURE;
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE '/opt/oracle/wallet'
IDENTIFIED BY walletpass;

---open the keystore
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN
IDENTIFIED BY walletpass;

---create encryption key
ADMINISTER KEY MANAGEMENT SET KEY
IDENTIFIED BY walletpass WITH BACKUP;

ALTER SESSION SET CONTAINER = PDB_CLEAN_SECURE;
--create tablespace with encryption
CREATE TABLESPACE ts_secure_data
DATAFILE 'ts_secure_data01.dbf' SIZE 100M
ENCRYPTION USING 'AES256'
DEFAULT STORAGE(ENCRYPT);


--create table and indexes in the encrypted tablespace
CREATE TABLE bank_transactions_clean (
    transaction_id NUMBER,
    account_id NUMBER,
    amount NUMBER,
    transaction_date DATE
)

TABLESPACE ts_secure_data;
CREATE INDEX idx_account_id ON bank_transactions_clean(account_id)
TABLESPACE ts_secure_data;
CREATE INDEX idx_transaction_date ON bank_transactions_clean(transaction_date)
TABLESPACE ts_secure_data;