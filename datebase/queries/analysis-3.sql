-- Qual o valor total de cada pedido considerando descontos?
SELECT 
    p.id_pedido,
    c.nome AS cliente,
    p.valor_total,
    p.desconto,
    (p.valor_total - p.desconto) AS valor_final,
    CASE 
        WHEN p.desconto > 0 THEN ROUND((p.desconto / p.valor_total) * 100, 2)
        ELSE 0 
    END AS percentual_desconto
FROM Pedidos p
JOIN Clientes c ON p.id_cliente = c.id_cliente;
