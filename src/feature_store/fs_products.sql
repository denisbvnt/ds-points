WITH tb_transaction_products AS (
    SELECT t1.*,
           t2.NameProduct,
           t2.QuantityProduct
            
    FROM transactions AS t1
    LEFT JOIN transactions_product AS t2
    ON t1.idTransaction = t2.idTransaction

    WHERE t1.dtTransaction < DATE('{date}')
    AND t1.dtTransaction >= DATE('{date}', '-21 day')
),

tb_share AS (
SELECT idCustomer,
        SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) AS qtdResgatarPonei,
        SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) AS qtdChatMessage,
        SUM(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) AS qtdListaPresença,
        SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) AS qtdAirflowLover,
        SUM(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) AS qtdRLover,
        SUM(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) AS qtdPresençaStreak,
        SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) AS qtdTrocaPontosStreamElements,
        SUM(CASE WHEN NameProduct = 'Churn_5pp' THEN QuantityProduct ELSE 0 END) AS qtdChurn_5pp,
        SUM(CASE WHEN NameProduct = 'Churn_2pp' THEN QuantityProduct ELSE 0 END) AS qtdChurn_2pp,
        SUM(CASE WHEN NameProduct = 'Churn_10pp' THEN QuantityProduct ELSE 0 END) AS qtdChurn_10pp,
        
        SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN pointsTransaction ELSE 0 END) AS ptsResgatarPonei,
        SUM(CASE WHEN NameProduct = 'ChatMessage' THEN pointsTransaction ELSE 0 END) AS ptsChatMessage,
        SUM(CASE WHEN NameProduct = 'Lista de presença' THEN pointsTransaction ELSE 0 END) AS ptsListaPresença,
        SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN pointsTransaction ELSE 0 END) AS ptsAirflowLover,
        SUM(CASE WHEN NameProduct = 'R Lover' THEN pointsTransaction ELSE 0 END) AS ptsRLover,
        SUM(CASE WHEN NameProduct = 'Presença Streak' THEN pointsTransaction ELSE 0 END) AS ptsPresençaStreak,
        SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN pointsTransaction ELSE 0 END) AS ptsTrocaPontosStreamElements,
        SUM(CASE WHEN NameProduct = 'Churn_5pp' THEN pointsTransaction ELSE 0 END) AS ptsChurn_5pp,
        SUM(CASE WHEN NameProduct = 'Churn_2pp' THEN pointsTransaction ELSE 0 END) AS ptsChurn_2pp,
        SUM(CASE WHEN NameProduct = 'Churn_10pp' THEN pointsTransaction ELSE 0 END) AS ptsChurn_10pp,

        1.0 * SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctResgatarPonei,
        1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctChatMessage,
        1.0 * SUM(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctListaPresença,
        1.0 * SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctAirflowLover,
        1.0 * SUM(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctRLover,
        1.0 * SUM(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctPresençaStreak,
        1.0 * SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctTrocaPontosStreamElements,
        1.0 * SUM(CASE WHEN NameProduct = 'Churn_5pp' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctChurn_5pp,
        1.0 * SUM(CASE WHEN NameProduct = 'Churn_2pp' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctChurn_2pp,
        1.0 * SUM(CASE WHEN NameProduct = 'Churn_10pp' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctChurn_10pp,

        1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / COUNT(DISTINCT DATE(dtTransaction)) AS avgChatLive



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

SELECT '{date}' AS dtRef,
       t1.*,
       t2.NameProduct AS maisComprado,
       t3.NameProduct AS menosComprado

FROM tb_share AS t1
LEFT JOIN tb_product_max AS t2
ON t1.idCustomer = t2.idCustomer
LEFT JOIN tb_product_min AS t3
ON t2.idCustomer = t3.idCustomer
