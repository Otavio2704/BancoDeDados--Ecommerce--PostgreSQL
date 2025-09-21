-- Quais são todos os produtos disponíveis com seus preços?
SELECT nome, preco, status_produto 
FROM Produtos 
WHERE status_produto = 'Ativo';
