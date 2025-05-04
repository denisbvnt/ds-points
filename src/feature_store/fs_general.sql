WITH tb_rfv AS (
    SELECT '{date}' AS dtRef,
        idCustomer,

        CAST(julianday((SELECT MAX(dtTransaction) FROM transactions)) - MAX(julianday(dtTransaction))
            AS INTEGER) + 1 AS recenciaDias,

        COUNT(DISTINCT DATE(dtTransaction)) AS frequenciaDias,

        SUM(CASE
                WHEN pointsTransaction > 0 THEN pointsTransaction
            END) AS valorPoints

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

tb_idade AS (

    SELECT

        t1.idCustomer,

        CAST(julianday((SELECT MAX(dtTransaction) FROM tb_rfv)) - MIN(julianday(t2.dtTransaction))
                AS INTEGER) + 1 AS idadeBaseDias

    FROM tb_rfv AS t1

    LEFT JOIN transactions AS t2
    ON t1.idCustomer = t2.idCustomer

    GROUP BY t2.idCustomer

)

SELECT t1.*,
     t2.idadeBaseDias,
     t3.flEmail

FROM tb_rfv AS t1

LEFT JOIN tb_idade AS t2
ON t1.idCustomer = t2.idCustomer

LEFT JOIN customers AS t3
ON t1.idCustomer = t3.idCustomer