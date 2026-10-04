# Modelos de importacao de contas a pagar

Use estes arquivos nas abas de contas a pagar do app:

- `contas_a_pagar_granja.*`: importar na aba de contas a pagar da granja.
- `contas_a_pagar_pessoal.*`: importar na aba de contas a pagar pessoal.

Colunas aceitas:

- `descricao`: nome da conta.
- `categoria`: tipo da conta, como `Fatura de cartão`, `Boleto`, `Compra parcelada`.
- `valor`: valor de cada parcela ou da conta unica.
- `valor_total`: valor total da compra parcelada. Quando preenchido com `parcelas`, o app divide o total.
- `vencimento`: vencimento da primeira conta/parcela.
- `parcelas`: quantidade de parcelas. Se vazio, usa `1`.
- `forma_pagamento`: cartao, banco, boleto, PIX ou outra referencia.
- `observacao`: observacao livre.

Datas aceitas: `DD/MM/AAAA` ou `AAAA-MM-DD`.
Valores aceitos: `803,78`, `R$ 803,78`, `803.78` ou `80.378,00`.
