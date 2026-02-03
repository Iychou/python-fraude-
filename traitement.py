import pandas as pd

# Chargement du fichier
df = pd.read_csv("bank_transactions_raw_results.csv", sep=";")

# Vérification des colonnes
print(df.columns)


def is_valid(tx):
    score = 0

    if tx["amount"] > 3000:
        score += 2
    if tx["transactions_today"] > 10:
        score += 1
    if tx["country_change"] == 'Y':
        score += 2
    if tx["failed_attempts"] >= 3:
        score += 2
    if tx["hour"] < 6:
        score += 1

    return score < 5


df["statut_valide"] = df.apply(is_valid, axis=1)

print(df.head())

# Sauvegarde finale
df.to_csv("resultats_finaux.csv", index=False)
#---------------------------------------------


import cx_Oracle
import pandas as pd

dsn = cx_Oracle.makedsn("localhost", 1521, service_name="ORCLPDB1")
conn = cx_Oracle.connect(
    user="bank_user",
    password="bank_password",
    dsn=dsn
)

print("Connected to Oracle Database")
query = """
SELECT
    id,
    amount,
    transactions_today,
    country_change,
    failed_attempts,
    hour
FROM bank_transactions_raw
"""
df = pd.read_sql(query, conn)
print("Data loaded from Oracle")

def is_valid(tx):
    score = 0

    if tx["amount"] > 3000:
        score += 2
    if tx["transactions_today"] > 10:
        score += 1
    if tx["country_change"] == 'Y':
        score += 2
    if tx["failed_attempts"] >= 3:
        score += 2
    if tx["hour"] < 6:
        score += 1

    return score < 5   


df["is_valid"] = df.apply(is_valid, axis=1)
clean_df = df[df["is_valid"] == True]

print(f"Valid transactions: {len(clean_df)}")

cursor = conn.cursor()

insert_sql = """
INSERT INTO bank_transactions_clean (
    id,
    amount,
    transactions_today,
    country_change,
    failed_attempts,
    hour
) VALUES (:1, :2, :3, :4, :5, :6)
"""

for _, row in clean_df.iterrows():
    cursor.execute(
        insert_sql,
        (
            int(row["id"]),
            float(row["amount"]),
            int(row["transactions_today"]),
            row["country_change"],
            int(row["failed_attempts"]),
            int(row["hour"])
        )
    )

conn.commit()

print("Clean data inserted successfully")

cursor.close()
conn.close()
print("Oracle connection closed")
