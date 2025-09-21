-- Quais produtos cada fornecedor oferece e a que preço?
SELECT 
    f.razao_social as fornecedor,
    f.nome_fantasia,
    p.nome as produto,
    p.preco as preco_venda,
    fp.preco_fornecimento,
    (p.preco - fp.preco_fornecimento) as margem_lucro,
    ROUND(((p.preco - fp.preco_fornecimento) / p.preco) * 100, 2) as percentual_margem
FROM Fornecedores f
JOIN Fornecedor_Produto fp ON f.id_fornecedor = fp.id_fornecedor
JOIN Produtos p ON fp.id_produto = p.id_produto
ORDER BY f.nome_fantasia, p.nome;
