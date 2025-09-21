-- Qual a situação do estoque por produto e fornecedor?
SELECT 
    p.nome as produto,
    f.nome_fantasia as fornecedor,
    fp.preco_fornecimento,
    e.quantidade as quantidade_estoque,
    e.localizacao,
    CASE 
        WHEN e.quantidade > 50 THEN 'Alto'
        WHEN e.quantidade BETWEEN 11 AND 50 THEN 'Médio'
        WHEN e.quantidade BETWEEN 1 AND 10 THEN 'Baixo'
        ELSE 'Sem Estoque'
    END as nivel_estoque
FROM Produtos p
LEFT JOIN Fornecedor_Produto fp ON p.id_produto = fp.id_produto
LEFT JOIN Fornecedores f ON fp.id_fornecedor = f.id_fornecedor
LEFT JOIN Estoque e ON p.id_produto = e.id_produto
ORDER BY p.nome, f.nome_fantasia;
