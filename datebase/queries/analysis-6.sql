-- Quantos pedidos foram feitos por cada cliente e qual o status de entrega?
SELECT 
    c.nome AS cliente,
    c.tipo_cliente,
    COUNT(DISTINCT p.id_pedido) as total_pedidos,
    SUM(p.valor_total) as valor_total,
    STRING_AGG(DISTINCT p.status_pedido, ', ') as status_pedidos,
    STRING_AGG(DISTINCT e.status_entrega, ', ') as status_entregas
FROM Clientes c
LEFT JOIN Pedidos p ON c.id_cliente = p.id_cliente
LEFT JOIN Entregas e ON p.id_pedido = e.id_pedido
GROUP BY c.id_cliente, c.nome, c.tipo_cliente
ORDER BY total_pedidos DESC;
