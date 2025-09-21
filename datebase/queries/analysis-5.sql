-- Quais clientes fizeram pedidos com valor total superior a R$ 1000?
SELECT 
    c.nome,
    c.tipo_cliente,
    COUNT(p.id_pedido) as total_pedidos,
    SUM(p.valor_total) as valor_total_compras,
    AVG(p.valor_total) as ticket_medio
FROM Clientes c
JOIN Pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nome, c.tipo_cliente
HAVING SUM(p.valor_total) > 1000
ORDER BY valor_total_compras DESC;
