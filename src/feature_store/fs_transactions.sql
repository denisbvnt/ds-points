WITH tb_transactions AS (
    SELECT '{date}' AS dtRef,
            *
    FROM transactions
    WHERE 
    CASE 
        WHEN (SELECT COUNT(*) FROM transactions
            WHERE dtTransaction < DATE('{date}') AND dtTransaction >= DATE('{date}', '-21 day')) = 0
            THEN dtTransaction < (SELECT MAX(dtTransaction) FROM transactions)
            AND dtTransaction >= DATE((SELECT MAX(dtTransaction) FROM transactions), '-21 day')
        ELSE
            dtTransaction < DATE('{date}')
            AND dtTransaction >= DATE('{date}', '-21 day')
    END
),

tb_freq AS (
    SELECT dtRef,
        idCustomer,
        CAST(COUNT(DISTINCT DATE(dtTransaction)) AS NUMERIC) AS qtdeDiasD21,
        CAST(COUNT(
            DISTINCT CASE
                WHEN dtTransaction < DATE(
                    (
                        SELECT MAX(dtTransaction)
                        FROM transactions
                    )
                )
                AND dtTransaction >= DATE(
                    (
                        SELECT MAX(dtTransaction)
                        FROM transactions
                    ),
                    '-14 day'
                ) THEN DATE(dtTransaction)
            END
        ) AS NUMERIC) AS qtdeDiasD14,
        CAST(COUNT(
            DISTINCT CASE
                WHEN dtTransaction < DATE(
                    (
                        SELECT MAX(dtTransaction)
                        FROM transactions
                    )
                )
                AND dtTransaction >= DATE(
                    (
                        SELECT MAX(dtTransaction)
                        FROM transactions
                    ),
                    '-7 day'
                ) THEN DATE(dtTransaction)
            END
        ) AS NUMERIC) AS qtdeDiasD7
    FROM tb_transactions
    GROUP BY idCustomer
),

tb_minutos_dia AS (
    SELECT idCustomer,
        DATE(DATETIME(dtTransaction), '-3 hour') AS dtTransactionDate,
        MIN(DATETIME(dtTransaction)) AS dtIni,
        MAX(DATETIME(dtTransaction)) AS dtFim,
        24 * 60 * (JULIANDAY(MAX(DATETIME(dtTransaction, '-3 hour'))) -
        JULIANDAY(MIN(DATETIME(dtTransaction, '-3 hour')))) AS minutosDia

    FROM tb_transactions

    GROUP BY idCustomer, dtTransactionDate
),

tb_hours AS (
    SELECT idCustomer,
            CAST(AVG(minutosDia) AS NUMERIC) AS mediaMinutos,
            CAST(SUM(minutosDia) AS NUMERIC) AS somaMinutos,
            CAST(MIN(minutosDia) AS NUMERIC) AS minMinutos,
            CAST(MAX(minutosDia) AS NUMERIC) AS maxMinutos

    FROM tb_minutos_dia

    GROUP BY idCustomer
),

tb_vida AS (
    SELECT idCustomer,
        CAST(COUNT(DISTINCT idTransaction) AS NUMERIC) AS qtdeTransacoesVida,
        CAST(1.0 * COUNT(DISTINCT idTransaction) / (MAX(JULIANDAY(DATE((SELECT MAX(dtTransaction) FROM transactions)))) -
        MIN(JULIANDAY(dtTransaction)))  AS NUMERIC) AS mediaTransacaoDia
    
    FROM transactions
    
    WHERE dtTransaction < '{date}'

    GROUP BY idCustomer
),

tb_join AS (    
    SELECT t1.*,
            t2.mediaMinutos,
            t2.somaMinutos,
            t2.minMinutos,
            t2.maxMinutos,
            t3.qtdeTransacoesVida,
            t3.mediaTransacaoDia

    FROM tb_freq AS t1
    LEFT JOIN tb_hours AS t2
    ON t1.idCustomer = t2.idCustomer

    LEFT JOIN tb_vida AS t3
    ON t2.idCustomer = t3.idCustomer
)

SELECT *
FROM tb_join