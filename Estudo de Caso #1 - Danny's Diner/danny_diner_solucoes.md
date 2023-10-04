# Estudo de Caso #1 - Danny's Diner
<hr>

## Questões do Estudo de Caso
<hr>

1. Qual é o valor total que cada cliente gastou no restaurante?
2. Quantos dias cada cliente visitou o restaurante?
3. Qual foi o primeiro item do menu comprado por cada cliente?
4. Qual é o item mais comprado no menu e quantas vezes foi comprado por todos os clientes?
5. Qual item foi o mais popular para cada cliente?
6. Qual item foi comprado primeiro pelo cliente depois que ele se tornou membro?
7. Qual item foi comprado logo antes do cliente se tornar membro?
8. Qual é o total de itens e valor gasto para cada membro antes de se tornarem membros?
9. Se cada $1 gasto equivale a 10 pontos e o sushi possui um multiplicador de pontos de 2x - quantos pontos cada cliente teria?
10. Na primeira semana após um cliente aderir ao programa (incluindo a data de adesão), eles ganham pontos 2x em todos os itens, não apenas no sushi - quantos pontos o cliente A e B teriam no final de janeiro?
***

### 1. Qual é o valor total que cada cliente gastou no restaurante?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
SELECT Vendas.id_cliente AS   Cliente ,  SUM(Menu.preço) AS 'Total Gasto'
FROM Vendas
LEFT JOIN Menu
ON Vendas.id_produto = Menu.id_produto
GROUP BY Vendas.id_cliente;
```
</details>

**Passos:**
* Para a questão 1 foi utilizado o LEFT JOIN para unir as tabelas Vendas e Menu.
* A função SUM foi utilizada para calcular o total gasto pelos clientes.
* Ao final foi utilizado o GROUP BY para agregar os resultados por Vendas.id_cliente.

**Resposta:**

|Cliente|Total Gasto|
|:-----:|:---------:|
|   A   |     76    |  
|   B   |     74    |
|   C   |     36    |

O cliente A gastou um total de $76, o cliente B gastou $74 e o cliente C gastou $36.
***

### 2. Quantos dias cada cliente visitou o restaurante?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
SELECT id_cliente AS Cliente ,  COUNT(DISTINCT Menu.preço) AS ‘Dias Visita’
FROM Vendas
GROUP BY id_cliente;
```
</details>

**Passos:**
* Para a questão 2 foi utilizado a função COUNT juntamente com o DISTINCT para contar a quantidade de dias distintos que o cliente visitou o restaurante.
* O GROUP BY foi utilizado para agregar os resultados por id_cliente.

**Resposta:**

|Cliente|Dias Visita|
|:-----:|:---------:|
|   A   |     4     |  
|   B   |     6     |
|   C   |     2     |

O cliente A visitou o restaurante 4 dias, o cliente B visitou 6 dias e o cliente C visitou 2 dias.
***

### 3. Qual foi o primeiro item do menu comprado por cada cliente?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
WITH primeiro_item AS(
SELECT v.id_cliente, 
	     v.data_pedido, 
       	     m.nome_produto, 
               dense_rank() over(partition by id_cliente order by data_pedido) AS Rankings
FROM Vendas as v
LEFT JOIN Menu as m
ON v.id_produto = m.id_produto)

SELECT id_cliente, nome_produto
FROM primeiro_item
WHERE Rankings = 1
GROUP BY id_cliente, nome_produto;
```
</details>

**Passos:**
* Foi criada uma Common Table Expression (CTE) que é um conjunto de resultados nomeados temporário.
* Necessitou-se unir as tabelas Vendas e Menu utilizando LEFT JOIN.
* Foi feito um ranking para saber qual foi o primeiro produto pedido pelo cliente.
* Utilizou-se a cláusula WHERE para poder selecionar somente o valor de ranking 1.
* Agrupou-se os dados pela coluna id_cliente e nome_produto utilizando GROUP BY.

**Resposta:**

|id_cliente|nome_produto|
|:--------:|:----------:|
|   A      |     sushi  |  
|   A      |     curry  |
|   B      |     curry  |
|   C      |     ramen  |


O primeiro item comprado pelo cliente A foi Sushi e Curry, para o cliente B foi Curry e para o cliente C foi Ramen.
***

### 4. Qual é o item mais comprado no menu e quantas vezes foi comprado por todos os clientes?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
SELECT m.nome_produto AS Produto, COUNT(v.id_produto) AS 'Qtd_Comprado'
FROM Vendas AS v
LEFT JOIN Menu AS m
ON v.id_produto = m.id_produto
GROUP BY m.nome_produto
ORDER BY Qtd_Comprado DESC
LIMIT 1;
```
</details>

**Passos:**
* Para a questão 4 foi utilizado a função COUNT para contar a quantidade de produtos vendidos.
* Necessitou-se a união das tabelas Vendas e Menu, utilizando o LEFT JOIN.
* Foi feito o agrupamento por nome_produto utilizando GROUP BY
* Ordenou-se por Qtd_comprado do maior ao menor valor.
* E utilizando o LIMIT 1 para selecionar somente a primeira linha da consulta.

**Resposta:**

|Produto   |Qtd_Comprado|
|:--------:|:----------:|
|   ramen  |     8      |  

O item mais comprado do cardápio foi o Ramen, ele foi comprado 8 vezes.
***

### 5. Qual item foi o mais popular para cada cliente?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
WITH item_popular AS(
SELECT 
v.id_cliente,
    	m.nome_produto,
	COUNT(v.id_produto) AS quantidade,
   	 DENSE_RANK() OVER(PARTITION BY v.id_cliente ORDER BY COUNT(v.id_produto) DESC) AS Ranking
FROM Vendas AS v
LEFT JOIN Menu AS m
ON v.id_produto = m.id_produto
GROUP BY v.id_cliente, m.nome_produto)

SELECT id_cliente, nome_produto, quantidade 
FROM item_popular
WHERE Ranking = 1
ORDER BY id_cliente ASC, quantidade DESC;
```
</details>

**Passos:**
* Foi criada uma Common Table Expression (CTE) que é um conjunto de resultados nomeados temporário.
* Necessitou-se unir as tabelas Vendas e Menu utilizando LEFT JOIN.
* Foi utilizado o COUNT para contar a quantidade de produtos, um ranking para saber qual foi o produto mais pedido pelo cliente.
* Foi necessário o agrupamento por id_cliente e nome_produto utilizando o GROUP BY.
* Utilizou-se a cláusula WHERE para poder selecionar somente o valor de ranking 1.
* Ordenou-se com ORDER BY por id_cliente em ordem alfabética e quantidade em ordem decrescente.

**Resposta:**

|id_cliente|nome_produto|quantidade|
|:--------:|:----------:|:--------:|
|   A      |     ramen  |     3    | 
|   B      |     curry  |     2    |  
|   B      |     sushi  |     2    |
|   B      |     ramen  |     2    |
|   C      |     ramen  |     3    |

O item mais popular para o cliente A foi o Ramen, para o cliente B foi o Curry, Sushi e Ramen, já para o cliente C foi o Ramen.
***

### 6. Qual item foi comprado primeiro pelo cliente depois que ele se tornou membro?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
WITH comprado_primeiro_tornou_membro AS(
SELECT v.id_cliente, v.data_pedido, c.data_adesão, m.nome_produto,
	DENSE_RANK() OVER(PARTITION BY v.id_cliente ORDER BY v.data_pedido) AS Ranking
FROM Vendas AS v
LEFT JOIN Clientes AS c
ON v.id_cliente = c.id_cliente
LEFT JOIN Menu AS m
ON v.id_produto = m.id_produto
WHERE v.data_pedido >c. data_adesão
ORDER BY v.data_pedido)

SELECT id_cliente, nome_produto
FROM comprado_primeiro_tornou_membro
WHERE Ranking = 1;
```
</details>

**Passos:**
* Foi criada uma Common Table Expression (CTE) que é um conjunto de resultados nomeados temporário.
* Necessitou-se unir as tabelas Vendas, Clientes e Menu utilizando LEFT JOIN.
* Foi utilizada funções de janela, para calcular rankings com a função DENSE_RANK.
* Utilizou-se a cláusula WHERE para poder selecionar somente a data_pedido > data_adesão e também para selecionar somente os dados cujo valor de Ranking era 1.
* Ordenou-se com ORDER BY por data_pedido.

**Resposta:**

|id_cliente|nome_produto|
|:--------:|:----------:|
|   A      |     ramen  | 
|   B      |     sushi  |     

O cliente A comprou primeiro o Ramen depois que se tornou membro, já o cliente B comprou primeiro o Sushi depois que se tornou membro.
***

### 7. Qual item foi comprado logo antes do cliente se tornar membro?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
WITH item_comprado_antes_tornar_membro AS(
SELECT v.id_cliente, v.data_pedido, c.data_adesão, m.nome_produto,
	DENSE_RANK() OVER(PARTITION BY v.id_cliente ORDER BY v.data_pedido DESC) AS Ranking
FROM Vendas AS v
LEFT JOIN Clientes AS c
ON v.id_cliente = c.id_cliente
LEFT JOIN Menu AS m
ON v.id_produto = m.id_produto
WHERE v.data_pedido  < c. data_adesão
ORDER BY v.data_pedido)

SELECT id_cliente, data_pedido, data_adesão, nome_produto
FROM item_comprado_antes_tornar_membro
WHERE Ranking = 1;
```
</details>

**Passos:**
* Foi criada uma Common Table Expression (CTE) que é um conjunto de resultados nomeados temporário.
* Necessitou-se unir as tabelas Vendas, Clientes e Menu utilizando LEFT JOIN.
* Foi utilizada funções de janela, para calcular rankings com a função DENSE_RANK.
* Utilizou-se a cláusula WHERE para poder selecionar somente a data_pedido < data_adesão e também para selecionar somente os dados cujo valor de Ranking era 1.
* Ordenou-se com ORDER BY por data_pedido.

**Resposta:**

|id_cliente|data_pedido |data_adesão |nome_produto|
|:--------:|:----------:|:----------:|:----------:|
|   A      |2021-01-01  |2021-01-07  |     sushi  |     
|   A      |2021-01-01  |2021-01-07  |     curry  |
|   B      |2021-01-04  |2021-01-09  |     sushi  |

O cliente A comprou Sushi e Curry pouco antes de tornar-se membro, já o cliente B foi o Sushi pouco antes de tornar-se membro.
***

### 8. Qual é o total de itens e valor gasto para cada membro antes de se tornarem membros?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
WITH total_itens_valor_gasto _antes_tornar_membro AS(
SELECT v.id_cliente, v.data_pedido, c.data_adesão, m.nome_produto, m.preço
FROM Vendas AS v
LEFT JOIN Clientes AS c
ON v.id_cliente = c.id_cliente
LEFT JOIN Menu AS m
ON v.id_produto = m.id_produto
WHERE v.data_pedido  < c. data_adesão
ORDER BY v.data_pedido)

SELECT id_cliente, COUNT(nome_produto) AS ‘Total Itens’, SUM(preço) AS ‘Valor Gasto’
FROM total_itens_valor_gasto _antes_tornar_membro
GROUP BY id_cliente;
```
</details>

**Passos:**
* Foi criada uma Common Table Expression (CTE) que é um conjunto de resultados nomeados temporário.
* Necessitou-se unir as tabelas Vendas, Clientes e Menu utilizando LEFT JOIN.
* Utilizou-se a cláusula WHERE para poder selecionar somente a data_pedido < data_adesão.
* Ordenou-se com ORDER BY por data_pedido.
* Para calcular o total de itens e valor gasto utilizou-se respectivamente o COUNT na coluna nome_produto e o SUM na coluna preço.
* Foi necessário agrupar por id_cliente utilizando o GROUP BY.

**Resposta:**

|id_cliente|Total Itens |Valor Gasto|
|:--------:|:----------:|:---------:|
|   A      |     2      |    25     | 
|   B      |     3      |    40     |  
 
O cliente A comprou 2 itens e gastou um total de $25 antes de se tornar membro, já o cliente B comprou 3 itens e gastou um total de $40 antes de se tornar membro.
***

### 9. Se cada $1 gasto equivale a 10 pontos e o sushi possui um multiplicador de pontos de 2x - quantos pontos cada cliente teria?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
WITH precos_produtos_comprados AS (
SELECT v.id_cliente, m.nome_produto, m.preço,
	CASE
		WHEN m.nome_produto = 'sushi' THEN m.preço * 20
        ELSE m.preço *10
	END AS Pontos
FROM Vendas AS v
LEFT JOIN Menu AS m
ON v.id_produto = m.id_produto)

SELECT id_cliente, SUM(Pontos) AS 'Total Pontos'
FROM precos_produtos_comprados
GROUP BY  id_cliente;
```
</details>

**Passos:**
* Foi criada uma Common Table Expression (CTE) que é um conjunto de resultados nomeados temporário.
* Necessitou-se unir as tabelas Vendas e Menu utilizando LEFT JOIN.
* Para atribuir as condições a nova coluna foi necessário utilizar a cláusula CASE, e assim somar os pontos para os clientes.
* Necessitou-se agrupar os dados por id_cliente utilizando GROUP BY.

**Resposta:**

|id_cliente|Total Pontos|
|:--------:|:----------:|
|   A      |     860    | 
|   B      |     940    |   
|   C      |     360    |  

Com as condições dada na questão o cliente A teria 860 pontos, o cliente B 940 e o cliente C 360.
***

### 10. Na primeira semana após um cliente aderir ao programa (incluindo a data de adesão), eles ganham pontos 2x em todos os itens, não apenas no sushi - quantos pontos o cliente A e B teriam no final de janeiro?

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
WITH programa_semana_adesao  AS(
	select id_cliente, data_adesão,
    DATE_ADD(data_adesão, INTERVAL 6 DAY) AS programa_adesao
    FROM Clientes)

SELECT p.id_cliente,
	SUM(
    CASE
	WHEN v.data_pedido BETWEEN p.data_adesão AND p.programa_adesao THEN m.preço*20
        WHEN v.data_pedido NOT BETWEEN p.data_adesão AND p.programa_adesao THEN m.preço*10
	END) AS pontos_clientes
FROM Menu AS m
LEFT JOIN Vendas AS v
ON m.id_produto = v.id_produto
LEFT JOIN programa_semana_adesao AS p
ON p.id_cliente = v.id_cliente
WHERE v.data_pedido <='2021-01-31' AND v.data_pedido >= p.data_adesão
GROUP BY p.id_cliente
ORDER BY p.id_cliente;
```
</details>

**Passos:**
* Foi criada uma Common Table Expression (CTE) que é um conjunto de resultados nomeados temporário.
* Na CTE foi criada a coluna programa_adesao para pegar a data_adesao e adicionar 6 dias para frente, utilizando a função DATE_ADD
* Na tabela temporaria criada foi feito a coluna ponto_clientes através de condições com CASE e WHEN e essa coluna foi somada.
* Foi feito também joins de tabelas
* Foi necessário fazer group by e order by por id_cliente
* Por fim foi selecionado onde data_pedido menor ou igual a '2021-01-31' e data_pedido maior ou igual a data_adesão.

**Resposta:**

|id_cliente|pontos_clientes|
|:--------:|:-------------:|
|   A      |     1020      | 
|   B      |     320       |   

No final de janeiro o cliente A teria 1020 ponto e o cliente B 320 pontos.


## Questões Bônus
<hr>

As perguntas a seguir estão relacionadas à criação de tabelas de dados básicas que Danny e sua equipe podem usar para obter insights rapidamente sem a necessidade de unir as tabelas subjacentes usando SQL.

### 1. Junte todas as coisas

Recrie a tabela com: id_cliente, data_pedido, nome_produto, preço, membro(sim,não)

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
SELECT v.id_cliente, v.data_pedido, m.nome_produto, m.preço,
	CASE
		WHEN c.data_adesão > v.data_pedido THEN 'Não'
        	WHEN c.data_adesão <= v.data_pedido THEN 'Sim'
        	ELSE 'Não'
	END AS Membro
FROM Vendas AS v
LEFT JOIN Clientes AS c
ON v.id_cliente = c.id_cliente
LEFT JOIN Menu AS m
ON v.id_produto = m.id_produto;
```
</details>

**Resultado:**
| id_cliente  | data_pedido| nome_produto | preço | Membro |
|:----------: |:---------: | :-----------:|:----: |:------:|
| A           | 2021-01-01 | sushi        | 10    | Não    |
| A           | 2021-01-01 | curry        | 15    | Não    |
| A           | 2021-01-07 | curry        | 15    | Sim    |
| A           | 2021-01-10 | ramen        | 12    | Sim    |
| A           | 2021-01-11 | ramen        | 12    | Sim    |
| A           | 2021-01-11 | ramen        | 12    | Sim    |
| B           | 2021-01-01 | curry        | 15    | Não    |
| B           | 2021-01-02 | curry        | 15    | Não    |
| B           | 2021-01-04 | sushi        | 10    | Não    |
| B           | 2021-01-11 | sushi        | 10    | Sim    |
| B           | 2021-01-16 | ramen        | 12    | Sim    |
| B           | 2021-02-01 | ramen        | 12    | Sim    |
| C           | 2021-01-01 | ramen        | 12    | Não    |
| C           | 2021-01-01 | ramen        | 12    | Não    |
| C           | 2021-01-07 | ramen        | 12    | Não    |


***
### 2. Classifique todas as coisas
<hr>

Danny também exige mais informações sobre os rankings produtos do cliente, mas propositalmente não precisa da classificação para compras de não membros, portanto espera rankings valores nulos para os registros quando os clientes ainda não fazem parte do programa de fidelidade.

<details>
  <summary>Clique aqui para ver a solução</summary>

```sql
WITH clientes_data AS (
SELECT v.id_cliente, v.data_pedido, m.nome_produto, m.preço,
	CASE
		WHEN c.data_adesão > v.data_pedido THEN 'Não'
        	WHEN c.data_adesão <= v.data_pedido THEN 'Sim'
        	ELSE 'Não'
	END AS Membro
FROM Vendas AS v
LEFT JOIN Clientes AS c
ON v.id_cliente = c.id_cliente
LEFT JOIN Menu AS m
ON v.id_produto = m.id_produto)

SELECT *,
	CASE
		WHEN Membro = 'Não' then NULL
        	ELSE RANK() OVER(PARTITION BY id_cliente, Membro ORDER BY data_pedido)
        END AS Ranking
FROM clientes_data;
```
</details>

**Resultado:**
| id_cliente  | data_pedido| nome_produto | preço | Membro |Ranking|
|:----------: |:---------: | :-----------:|:----: |:------:|:-----:|
| A           | 2021-01-01 | sushi        | 10    | Não    |NULL   |
| A           | 2021-01-01 | curry        | 15    | Não    |NULL   |
| A           | 2021-01-07 | curry        | 15    | Sim    |1      |
| A           | 2021-01-10 | ramen        | 12    | Sim    |2      |
| A           | 2021-01-11 | ramen        | 12    | Sim    |3      |
| A           | 2021-01-11 | ramen        | 12    | Sim    |3      |
| B           | 2021-01-01 | curry        | 15    | Não    |NULL   |
| B           | 2021-01-02 | curry        | 15    | Não    |NULL   |
| B           | 2021-01-04 | sushi        | 10    | Não    |NULL   |
| B           | 2021-01-11 | sushi        | 10    | Sim    |1      |
| B           | 2021-01-16 | ramen        | 12    | Sim    |2      |
| B           | 2021-02-01 | ramen        | 12    | Sim    |3      |
| C           | 2021-01-01 | ramen        | 12    | Não    |NULL   |
| C           | 2021-01-01 | ramen        | 12    | Não    |NULL   |
| C           | 2021-01-07 | ramen        | 12    | Não    |NULL   |

***