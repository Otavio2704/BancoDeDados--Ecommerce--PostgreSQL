-- Existe algum vendedor que também atua como fornecedor?
SELECT 
    v.nome as vendedor_nome,
    v.cnpj as vendedor_cnpj,
    f.razao_social as fornecedor_razao_social,
    f.cnpj as fornecedor_cnpj
FROM Vendedores v
INNER JOIN Fornecedores f ON v.cnpj = f.cnpj
WHERE v.cnpj IS NOT NULL;
