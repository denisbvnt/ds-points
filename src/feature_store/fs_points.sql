WITH tb_pontos_d AS (    
    SELECT DATE((SELECT MAX(dtTransaction) FROM transactions)) AS dtRef,
        idCustomer,

        CAST(SUM(pointsTransaction) AS NUMERIC) AS saldoPontosD21,

        CAST(SUM(CASE
                WHEN dtTransaction >= DATE((SELECT MAX(dtTransaction) FROM transactions), '-14 day')
                THEN pointsTransaction
                ELSE 0
            END) AS NUMERIC) AS saldoPontosD14,

        CAST(SUM(CASE
                WHEN dtTransaction >= DATE((SELECT MAX(dtTransaction) FROM transactions), '-7 day')
                THEN pointsTransaction
                ELSE 0
            END) AS NUMERIC) AS saldoPontosD7,

        CAST(SUM(CASE
                WHEN pointsTransaction > 0 THEN pointsTransaction
                ELSE 0
            END) AS NUMERIC) AS pontosAcumuladosD21,

        CAST(SUM(CASE
                WHEN pointsTransaction > 0 AND
                dtTransaction >= DATE((SELECT MAX(dtTransaction) FROM transactions), '-14 day')
                THEN pointsTransaction
                ELSE 0
            END) AS NUMERIC) AS pontosAcumuladosD14,

        CAST(SUM(CASE
                WHEN pointsTransaction > 0 AND
                dtTransaction >= DATE((SELECT MAX(dtTransaction) FROM transactions), '-7 day')
                THEN pointsTransaction
                ELSE 0
            END) AS NUMERIC) AS pontosAcumuladosD7,

        CAST(SUM(CASE
                WHEN pointsTransaction < 0 THEN pointsTransaction
                ELSE 0
            END) AS NUMERIC) AS pontosResgatadosD21,

        CAST(SUM(CASE
                WHEN pointsTransaction < 0 AND
                dtTransaction >= DATE((SELECT MAX(dtTransaction) FROM transactions), '-14 day')
                THEN pointsTransaction
                ELSE 0
            END) AS NUMERIC) AS pontosResgatadosD14,

        CAST(SUM(CASE
                WHEN pointsTransaction < 0 AND
                dtTransaction >= DATE((SELECT MAX(dtTransaction) FROM transactions), '-7 day')
                THEN pointsTransaction
                ELSE 0
            END) AS NUMERIC) AS pontosResgatadosD7        

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

    GROUP BY idCustomer
),

tb_vida AS (
    SELECT t1.idCustomer,
        CAST((SELECT MAX(julianday(dtTransaction)) FROM transactions) - MIN(julianday(dtTransaction)) +1 AS INTEGER) AS diasVida,
        CAST(SUM(t2.pointsTransaction) AS NUMERIC) AS saldoPontosVida,
        CAST(SUM(CASE
                WHEN t2.pointsTransaction > 0
                THEN t2.pointsTransaction
                ELSE 0 END) AS NUMERIC) AS pontosAcumuladosVida,
        CAST(SUM(CASE
                WHEN t2.pointsTransaction < 0
                THEN t2.pointsTransaction
                ELSE 0 END) AS NUMERIC) AS pontosResgatadosVida
        

    FROM tb_pontos_d AS t1
    LEFT JOIN transactions AS t2
    ON t1.idCustomer = t2.idCustomer

    WHERE t2.dtTransaction < DATE((SELECT MAX(dtRef) FROM tb_pontos_d))

    GROUP BY t2.idCustomer
),

tb_join AS (
    SELECT  t1.*,
            t2.saldoPontosVida,
            t2.pontosAcumuladosVida,
            t2.pontosResgatadosVida,
            1.0 * t2.pontosAcumuladosVida / t2.diasVida AS pontosPorDia

    FROM tb_pontos_d AS t1
    LEFT JOIN tb_vida AS t2
    ON t1.idCustomer = t2.idCustomer
)

SELECT * FROM tb_join