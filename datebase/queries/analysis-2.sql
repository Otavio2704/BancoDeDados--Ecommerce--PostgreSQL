-- Quais clientes são Pessoa Jurídica e estão localizados em São Paulo?
SELECT c.nome, c.email, c.razao_social, e.cidade 
FROM Clientes c
JOIN Enderecos e ON c.id_cliente = e.id_cliente
WHERE c.tipo_cliente = 'PJ' AND e.cidade = 'São Paulo';
