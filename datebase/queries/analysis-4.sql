-- Quais são os produtos mais caros do catálogo?
SELECT nome, preco, id_categoria
FROM Produtos 
WHERE status_produto = 'Ativo'
ORDER BY preco DESC, nome ASC;
