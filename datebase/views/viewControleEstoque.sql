-- View para Controle de Estoque
CREATE VIEW vw_controle_estoque AS
SELECT 
    p.id_produto,
    p.nome as produto,
    cat.nome as categoria,
    e.quantidade,
    e.localizacao,
    v.nome as vendedor_responsavel,
    CASE 
        WHEN e.quantidade = 0 THEN 'CRÍTICO'
        WHEN e.quantidade <= 10 THEN 'BAIXO'
        WHEN e.quantidade <= 50 THEN 'MÉDIO'
        ELSE 'ALTO'
    END as nivel_estoque
FROM Produtos p
LEFT JOIN Estoque e ON p.id_produto = e.id_produto
LEFT JOIN Categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN Vendedores v ON e.id_vendedor = v.id_vendedor;
