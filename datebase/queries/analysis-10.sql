-- Quais são as formas de pagamento mais utilizadas e seus valores?
SELECT 
    fp.nome as forma_pagamento,
    COUNT(pg.id_pagamento) as total_transacoes,
    SUM(pg.valor_pagamento) as valor_total,
    AVG(pg.valor_pagamento) as valor_medio,
    COUNT(CASE WHEN pg.status_pagamento = 'Aprovado' THEN 1 END) as transacoes_aprovadas
FROM Formas_Pagamento fp
LEFT JOIN Pagamentos pg ON fp.id_forma_pagamento = pg.id_forma_pagamento
GROUP BY fp.id_forma_pagamento, fp.nome
HAVING COUNT(pg.id_pagamento) > 0
ORDER BY valor_total DESC;
