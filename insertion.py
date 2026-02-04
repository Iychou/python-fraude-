conn_clean = cx_Oracle.connect(
    "pdb_clean_admin/oracle@localhost/PDB_CLEAN_SECURE"
)

cursor = conn_clean.cursor()

for _, tx in df.iterrows():
    if is_valid(tx):
        cursor.execute("""
        INSERT INTO bank_transactions_clean
        VALUES (:1, :2, :3, SYSDATE)
        """, (
            tx["transaction_id"],
            tx["account_id"],
            tx["amount"]
        ))

conn_clean.commit()
