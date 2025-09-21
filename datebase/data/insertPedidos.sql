-- Inserir Pedidos
INSERT INTO Pedidos (id_cliente, id_vendedor, status_pedido, valor_total, desconto) VALUES 
(1, 1, 'Entregue', 5089.98, 50.00),
(2, 1, 'Enviado', 8999.99, 0.00),
(3, 2, 'Processando', 239.98, 10.00),
(4, NULL, 'Aguardando Pagamento', 899.99, 0.00),
(1, 2, 'Entregue', 149.99, 0.00);
