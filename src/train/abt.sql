WITH tb_fl_churn AS (        
        SELECT  t1.dtRef,
                t1.idCustomer,
                (CASE WHEN t2.idCustomer IS NULL THEN 1 ELSE 0 END) AS flChurn

        FROM fs_general AS t1
        LEFT JOIN fs_general AS t2
        ON t1.idCustomer = t2.idCustomer
        AND t1.dtRef = DATE(t2.dtRef, '-21 day')

        WHERE t1.dtRef < DATE('2024-06-06', '-21 day')
        AND STRFTIME('%d', t1.dtRef) = '01'

        ORDER BY 1, 2
)

SELECT t2.*,
        t3.qtdPontosManha,
        t3.qtdPontosTarde,
        t3.qtdPontosNoite,
        t3.pctPontosManha,
        t3.pctPontosTarde,
        t3.pctPontosNoite,
        t3.qtdTransacoesManha,
        t3.qtdTransacoesTarde,
        t3.qtdTransacoesNoite,
        t3.pctTransacoesManha,
        t3.pctTransacoesTarde,
        t3.pctTransacoesNoite, 
        t4.saldoPontosD21,
        t4.saldoPontosD14,
        t4.saldoPontosD7,
        t4.pontosAcumuladosD21,
        t4.pontosAcumuladosD14,
        t4.pontosAcumuladosD7,
        t4.pontosResgatadosD21,
        t4.pontosResgatadosD14,
        t4.pontosResgatadosD7,
        t4.saldoPontosVida,
        t4.pontosAcumuladosVida,
        t4.pontosResgatadosVida,
        t4.pontosPorDia,
        t5.qtdResgatarPonei,
        t5.qtdChatMessage,
        t5.qtdListaPresença,
        t5.qtdAirflowLover,
        t5.qtdRLover,
        t5.qtdPresençaStreak,
        t5.qtdTrocaPontosStreamElements,
        t5.qtdChurn_5pp,
        t5.qtdChurn_2pp,
        t5.qtdChurn_10pp,
        t5.ptsResgatarPonei,
        t5.ptsChatMessage,
        t5.ptsListaPresença,
        t5.ptsAirflowLover,
        t5.ptsRLover,
        t5.ptsPresençaStreak,
        t5.ptsTrocaPontosStreamElements,
        t5.ptsChurn_5pp,
        t5.ptsChurn_2pp,
        t5.ptsChurn_10pp,
        t5.pctResgatarPonei,
        t5.pctChatMessage,
        t5.pctListaPresença,
        t5.pctAirflowLover,
        t5.pctRLover,
        t5.pctPresençaStreak,
        t5.pctTrocaPontosStreamElements,
        t5.pctChurn_5pp,
        t5.pctChurn_2pp,
        t5.pctChurn_10pp,
        t5.avgChatLive,
        t5.maisComprado,
        t5.menosComprado,
        t6.qtdeDiasD21,
        t6.qtdeDiasD14,
        t6.qtdeDiasD7,
        t6.mediaMinutos,
        t6.somaMinutos,
        t6.minMinutos,
        t6.maxMinutos,
        t6.qtdeTransacoesVida,
        t6.mediaTransacaoDia,
        t1.flChurn

FROM tb_fl_churn AS t1
LEFT JOIN fs_general AS t2
ON t1.idCustomer = t2.idCustomer
AND t1.dtRef = t2.dtRef

LEFT JOIN fs_hour AS t3
ON t1.idCustomer = t3.idCustomer
AND t1.dtRef = t3.dtRef

LEFT JOIN fs_points AS t4
ON t1.idCustomer = t4.idCustomer
AND t1.dtRef = t4.dtRef

LEFT JOIN fs_products AS t5
ON t1.idCustomer = t5.idCustomer
AND t1.dtRef = t5.dtRef

LEFT JOIN fs_transactions AS t6
ON t1.idCustomer = t6.idCustomer
AND t1.dtRef = t6.dtRef