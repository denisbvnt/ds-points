WITH tb_transactions AS (
    SELECT *
    FROM transactions
    WHERE dtTransaction < DATE('{date}')
        AND dtTransaction >= DATE('{date}', '-21 day')
),

tb_freq AS (
    SELECT idCustomer,
        COUNT(DISTINCT DATE(dtTransaction)) AS qtdeDiasD21,
        COUNT(
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
        ) AS qtdeDiasD14,
        COUNT(
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
        ) AS qtdeDiasD7
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
            AVG(minutosDia) AS mediaMinutos,
            SUM(minutosDia) AS somaMinutos,
            MIN(minutosDia) AS minMinutos,
            MAX(minutosDia) AS maxMinutos

    FROM tb_minutos_dia

    GROUP BY idCustomer
),

tb_vida AS (
    SELECT idCustomer,
        COUNT(DISTINCT idTransaction) AS qtdeTransacoesVida,
        1.0 * COUNT(DISTINCT idTransaction) / (MAX(JULIANDAY('{date}')) -
        MIN(JULIANDAY(dtTransaction))) AS mediaTransacaoDia
    
    FROM transactions
    
    WHERE dtTransaction < DATE('{date}')

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

SELECT '{date}' AS dtRef,
        *
FROM tb_join