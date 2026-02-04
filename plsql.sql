BEGIN
  FOR i IN 1..100 LOOP

    -- 85% transactions réelles
    IF DBMS_RANDOM.VALUE(1,100) <= 85 THEN
      INSERT INTO bank_transactions_raw VALUES (
        i,
        TRUNC(DBMS_RANDOM.VALUE(100,500)), -- account_id
        ROUND(DBMS_RANDOM.VALUE(5,300), 2), -- amount
        TRUNC(DBMS_RANDOM.VALUE(1,6)), -- transactions_today
        'N', -- country_change
        TRUNC(DBMS_RANDOM.VALUE(0,2)), -- failed_attempts
        TRUNC(DBMS_RANDOM.VALUE(8,22)) -- hour
      );

    -- 15% transactions frauduleuses
    ELSE
      INSERT INTO bank_transactions_raw VALUES (
        i,
        TRUNC(DBMS_RANDOM.VALUE(900,999)), -- account_id
        ROUND(DBMS_RANDOM.VALUE(300,1000), 2), -- amount
        TRUNC(DBMS_RANDOM.VALUE(10,25)), -- transactions_today
        'Y', -- country_change
        TRUNC(DBMS_RANDOM.VALUE(3,10)), -- failed_attempts
        TRUNC(DBMS_RANDOM.VALUE(0,5)) -- hour
      );
    END IF;

  END LOOP;
  COMMIT;
END;
/



--teste de verification des données insérées
SELECT
  CASE
    WHEN amount > 3000 THEN 'FRAUD_LIKE'
    ELSE 'NORMAL_LIKE'
  END AS type,
  COUNT(*)
FROM bank_transactions_raw
GROUP BY
  CASE
    WHEN amount > 3000 THEN 'FRAUD_LIKE'
    ELSE 'NORMAL_LIKE'
  END;









