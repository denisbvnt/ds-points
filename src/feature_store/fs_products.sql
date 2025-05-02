WITH tb_transaction_products AS (
    SELECT DATE((SELECT MAX(dtTransaction) FROM transactions)) AS dtRef,
            t1.*,
            t2.NameProduct,
            t2.QuantityProduct
            
    FROM transactions AS t1
    LEFT JOIN transactions_product AS t2
    ON t1.idTransaction = t2.idTransaction

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

tb_share AS (
SELECT dtRef,
        idCustomer,
        CAST(SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdResgatarPonei,
        CAST(SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdChatMessage,
        CAST(SUM(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdListaPresença,
        CAST(SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdAirflowLover,
        CAST(SUM(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdRLover,
        CAST(SUM(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdPresençaStreak,
        CAST(SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdTrocaPontosStreamElements,
        CAST(SUM(CASE WHEN NameProduct = 'Churn_5pp' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdChurn_5pp,
        CAST(SUM(CASE WHEN NameProduct = 'Churn_2pp' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdChurn_2pp,
        CAST(SUM(CASE WHEN NameProduct = 'Churn_10pp' THEN QuantityProduct ELSE 0 END) AS NUMERIC) AS qtdChurn_10pp,
        CAST(SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsResgatarPonei,
        CAST(SUM(CASE WHEN NameProduct = 'ChatMessage' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsChatMessage,
        CAST(SUM(CASE WHEN NameProduct = 'Lista de presença' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsListaPresença,
        CAST(SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsAirflowLover,
        CAST(SUM(CASE WHEN NameProduct = 'R Lover' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsRLover,
        CAST(SUM(CASE WHEN NameProduct = 'Presença Streak' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsPresençaStreak,
        CAST(SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsTrocaPontosStreamElements,
        CAST(SUM(CASE WHEN NameProduct = 'Churn_5pp' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsChurn_5pp,
        CAST(SUM(CASE WHEN NameProduct = 'Churn_2pp' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsChurn_2pp,
        CAST(SUM(CASE WHEN NameProduct = 'Churn_10pp' THEN pointsTransaction ELSE 0 END) AS NUMERIC) AS ptsChurn_10pp,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctResgatarPonei,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctChatMessage,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctListaPresença,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctAirflowLover,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctRLover,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctPresençaStreak,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctTrocaPontosStreamElements,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'Churn_5pp' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctChurn_5pp,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'Churn_2pp' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctChurn_2pp,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'Churn_10pp' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS NUMERIC) AS pctChurn_10pp,
        CAST(1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / COUNT(DISTINCT DATE(dtTransaction)) AS NUMERIC) AS avgChatLive



FROM tb_transaction_products

GROUP BY idCustomer
),

tb_group AS (SELECT idCustomer,
        NameProduct,
        SUM(QuantityProduct) AS qtde,
        SUM(pointsTransaction) AS pontos

FROM tb_transaction_products

GROUP BY idCustomer, NameProduct
),

tb_rn AS (SELECT *,
        ROW_NUMBER() OVER (PARTITION BY idCustomer ORDER BY qtde DESC, pontos DESC) AS descRnQtde,
        ROW_NUMBER() OVER (PARTITION BY idCustomer ORDER BY qtde ASC, pontos ASC) AS ascRnQtde

FROM tb_group

ORDER BY idCustomer
),

tb_product_max AS (
    SELECT *
    FROM tb_rn
    WHERE descRnQtde = 1
),

tb_product_min AS (
    SELECT *
    FROM tb_rn
    WHERE ascRnQtde = 1
)

SELECT t1.*,
       t2.NameProduct AS maisComprado,
       t3.NameProduct AS menosComprado

FROM tb_share AS t1
LEFT JOIN tb_product_max AS t2
ON t1.idCustomer = t2.idCustomer
LEFT JOIN tb_product_min AS t3
ON t2.idCustomer = t3.idCustomer
