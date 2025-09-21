-- Qual a performance das transportadoras nas entregas?
SELECT 
    transportadora,
    COUNT(*) as total_entregas,
    AVG(valor_frete) as frete_medio,
    COUNT(CASE WHEN status_entrega = 'Entregue' THEN 1 END) as entregas_concluidas,
    COUNT(CASE WHEN status_entrega IN ('Em Trânsito', 'Saiu para Entrega') THEN 1 END) as entregas_pendentes,
    ROUND((COUNT(CASE WHEN status_entrega = 'Entregue' THEN 1 END)::DECIMAL / COUNT(*)) * 100, 2) as taxa_sucesso
FROM Entregas
GROUP BY transportadora
ORDER BY taxa_sucesso DESC;
