-- Inserir Entregas
INSERT INTO Entregas (id_pedido, id_endereco_entrega, codigo_rastreio, transportadora, status_entrega, data_envio, data_entrega_prevista, valor_frete) VALUES 
(1, 1, 'BR123456789', 'Correios', 'Entregue', '2024-01-15 10:00:00', '2024-01-17', 15.90),
(2, 2, 'BR987654321', 'Transportadora XYZ', 'Em Trânsito', '2024-01-20 14:30:00', '2024-01-25', 25.50),
(3, 3, 'BR456789123', 'Correios', 'Saiu para Entrega', '2024-01-22 09:15:00', '2024-01-24', 12.80),
(5, 1, 'BR789123456', 'Correios', 'Entregue', '2024-01-10 11:20:00', '2024-01-12', 8.90);
