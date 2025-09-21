-- Como está a distribuição de pedidos ao longo do tempo?
SELECT 
    TO_CHAR(data_pedido, 'YYYY-MM') as mes_ano,
    COUNT(*) as total_pedidos,
    SUM(valor_total) as faturamento_mes,
    AVG(valor_total) as ticket_medio_mes,
    MIN(valor_total) as menor_pedido,
    MAX(valor_total) as maior_pedido
FROM Pedidos
GROUP BY TO_CHAR(data_pedido, 'YYYY-MM')
ORDER BY mes_ano;
