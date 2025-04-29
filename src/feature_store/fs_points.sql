WITH tb_pontos_d AS (    
    SELECT idCustomer,

            SUM(pointsTransaction) AS saldoPontosD21,

            SUM(CASE
                    WHEN dtTransaction >= DATE('{date}', '-14 day')
                    THEN pointsTransaction
                    ELSE 0
                END) AS saldoPontosD14,

            SUM(CASE
                    WHEN dtTransaction >= DATE('{date}', '-7 day')
                    THEN pointsTransaction
                    ELSE 0
                END) AS saldoPontosD7,
            
            SUM(CASE
                    WHEN pointsTransaction > 0 THEN pointsTransaction
                    ELSE 0
                END) AS pontosAcumuladosD21,

            SUM(CASE
                    WHEN pointsTransaction > 0 AND
                    dtTransaction >= DATE('{date}', '-14 day')
                    THEN pointsTransaction
                    ELSE 0
                END) AS pontosAcumuladosD14,

            SUM(CASE
                    WHEN pointsTransaction > 0 AND
                    dtTransaction >= DATE('{date}', '-7 day')
                    THEN pointsTransaction
                    ELSE 0
                END) AS pontosAcumuladosD7,

            SUM(CASE
                    WHEN pointsTransaction < 0 THEN pointsTransaction
                    ELSE 0
                END) AS pontosResgatadosD21,

            SUM(CASE
                    WHEN pointsTransaction < 0 AND
                    dtTransaction >= DATE('{date}', '-14 day')
                    THEN pointsTransaction
                    ELSE 0
                END) AS pontosResgatadosD14,
            
            SUM(CASE
                    WHEN pointsTransaction < 0 AND
                    dtTransaction >= DATE('{date}', '-7 day')
                    THEN pointsTransaction
                    ELSE 0
                END) AS pontosResgatadosD7        

    FROM transactions

    WHERE dtTransaction < DATE('{date}')
    AND dtTransaction >= DATE('{date}', '-21 day')

    GROUP BY idCustomer
),

tb_vida AS (
    SELECT t1.idCustomer,
        CAST((SELECT MAX(julianday(dtTransaction)) FROM transactions) - MIN(julianday(dtTransaction)) +1 AS INTEGER) AS diasVida,
        SUM(t2.pointsTransaction) AS saldoPontosVida,
        SUM(CASE
                WHEN t2.pointsTransaction > 0
                THEN t2.pointsTransaction
                ELSE 0 END) AS pontosAcumuladosVida,
        SUM(CASE
                WHEN t2.pointsTransaction < 0
                THEN t2.pointsTransaction
                ELSE 0 END) AS pontosResgatadosVida
        

    FROM tb_pontos_d AS t1
    LEFT JOIN transactions AS t2
    ON t1.idCustomer = t2.idCustomer

    WHERE t2.dtTransaction < DATE('{date}')

    GROUP BY t2.idCustomer
),

tb_join AS (
    SELECT t1.*,
            t2.saldoPontosVida,
            t2.pontosAcumuladosVida,
            t2.pontosResgatadosVida,
            1.0 * t2.pontosAcumuladosVida / t2.diasVida AS pontosPorDia

    FROM tb_pontos_d AS t1
    LEFT JOIN tb_vida AS t2
    ON t1.idCustomer = t2.idCustomer
)

SELECT * FROM tb_join