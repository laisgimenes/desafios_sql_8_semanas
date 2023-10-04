-- Perguntas do Estudo de Caso:
select * from Vendas;
select * from Clientes;
select * from Menu;

-- Qual é o valor total que cada cliente gastou no restaurante?
select Vendas.id_cliente as Cliente, sum(Menu.preço) as 'Total Gasto'
from Vendas
left join Menu
on Vendas.id_produto = Menu.id_produto
group by Vendas.id_cliente;

select 
	Vendas.id_cliente,
    sum(Menu.preço) as 'Total Gasto'
from dannys_diner.Vendas
join dannys_diner.Menu
	on Vendas.id_produto = Menu.id_produto
group by Vendas.id_cliente
order by Vendas.id_cliente;

-- Quantos dias cada cliente visitou o restaurante?
select id_cliente as Cliente, count(distinct data_pedido) as 'Dias visita'
from Vendas
group by id_cliente;

select 
	id_cliente,
    count(distinct data_pedido) as 'Qdt_Visitas'
from Vendas
group by id_cliente;


-- Qual foi o primeiro item do menu comprado por cada cliente?
with primeiro_item as(
select v.id_cliente, 
	   v.data_pedido, 
       m.nome_produto, 
       dense_rank() over(partition by id_cliente order by data_pedido) as Rankings
from Vendas as v
left join Menu as m
on v.id_produto = m.id_produto)

select id_cliente, nome_produto
from primeiro_item
where Rankings = 1
group by id_cliente, nome_produto;


with Vendas_Ordenadas as (
	select
		Vendas.id_cliente,
        Vendas.data_pedido,
        Menu.nome_produto,
        dense_rank() over(
			partition by Vendas.id_cliente
            order by Vendas.data_pedido) as ranking
	from dannys_diner.Vendas
    inner join dannys_diner.Menu
		on Vendas.id_produto = Menu.id_produto)
select
	id_cliente,
    nome_produto
from vendas_Ordenadas
where ranking = 1
group by id_cliente, nome_produto;

-- Qual é o item mais comprado no menu e quantas vezes foi comprado por todos os clientes?
select m.nome_produto as Produto, count(v.id_produto) as 'Qtd_Comprado'
from Vendas as v
left join Menu as m
on v.id_produto = m.id_produto
group by m.nome_produto
order by Qtd_Comprado desc
limit 1;

select
	Menu.nome_produto,
    count(Vendas.id_produto) as 'Qtd_Vezes_Comprada'
from dannys_diner.Vendas
join dannys_diner.Menu
	on Vendas.id_produto = Menu.id_produto
group by Menu.nome_produto
order by Qtd_Vezes_Comprada desc
limit 1;

-- Qual item foi o mais popular para cada cliente?
with item_popular as(
select 
	v.id_cliente,
    m.nome_produto,
	count(v.id_produto) as quantidade,
    dense_rank() over(partition by v.id_cliente order by count(v.id_produto) desc) as Ranking
from Vendas as v
left join Menu as m
on v.id_produto = m.id_produto
group by v.id_cliente, m.nome_produto)

select id_cliente, nome_produto, quantidade 
from item_popular
where Ranking = 1
order by id_cliente asc, quantidade desc;

-- Qual item foi comprado primeiro pelo cliente depois que ele se tornou membro?
with comprado_primeiro_tornou_membro as(
select v.id_cliente, v.data_pedido, c.data_adesão, m.nome_produto,
	dense_rank() over(partition by v.id_cliente order by v.data_pedido) as Ranking
from Vendas as v
left join Clientes as c
on v.id_cliente = c.id_cliente
left join Menu as m
on v.id_produto = m.id_produto
where v.data_pedido > c.data_adesão
order by v.data_pedido)

select id_cliente, nome_produto
from comprado_primeiro_tornou_membro
where Ranking = 1;

-- Qual item foi comprado logo antes do cliente se tornar membro?
with item_comprado_antes_tornar_membro as (
select v.id_cliente, v.data_pedido, c.data_adesão, m.nome_produto,
	dense_rank() over(partition by v.id_cliente order by v.data_pedido desc) as Ranking
from Vendas as v
left join Clientes as c
on v.id_cliente = c.id_cliente
left join Menu as m
on v.id_produto = m.id_produto
where v.data_pedido < c.data_adesão
order by v.data_pedido)

select id_cliente, data_pedido, data_adesão, nome_produto
from item_comprado_antes_tornar_membro
where Ranking = 1;

-- Qual é o total de itens e valor gasto para cada membro antes de se tornarem membros?
with total_itens_valor_gasto_antes_tornar_membro as (
select v.id_cliente, v.data_pedido, c.data_adesão, m.nome_produto, m.preço
from Vendas as v
left join Clientes as c
on v.id_cliente = c.id_cliente
left join Menu as m
on v.id_produto = m.id_produto
where v.data_pedido < c.data_adesão
order by v.data_pedido)

select id_cliente, count(nome_produto) as 'Total Itens', sum(preço) as 'Valor Gasto'
from total_itens_valor_gasto_antes_tornar_membro
group by id_cliente;

-- Se cada $1 gasto equivale a 10 pontos e o sushi possui um multiplicador de pontos de 2x - quantos pontos cada cliente teria?
with precos_produtos_comprados as (
select v.id_cliente, m.nome_produto, m.preço,
	case
		when m.nome_produto = 'sushi' then m.preço * 20
        else m.preço *10
	end as Pontos
from Vendas as v
left join Menu as m
on v.id_produto = m.id_produto)

select id_cliente, sum(Pontos) as 'Total Pontos'
from precos_produtos_comprados
group by id_cliente
order by sum(Pontos);

-- Na primeira semana após um cliente aderir ao programa (incluindo a data de adesão), eles ganham pontos 2x em todos os itens, 
-- não apenas no sushi - quantos pontos o cliente A e B teriam no final de janeiro?
with programa_semana_adesao  as(
	select id_cliente, data_adesão,
    date_add(data_adesão, interval 6 day) as programa_adesao
    from Clientes)

select p.id_cliente,
	sum(
    case
		when v.data_pedido between p.data_adesão and p.programa_adesao then m.preço*20
        when v.data_pedido not between p.data_adesão and p.programa_adesao then m.preço*10
	end) as pontos_clientes
from Menu as m
left join Vendas as v
on m.id_produto = v.id_produto
left join programa_semana_adesao as p
on p.id_cliente = v.id_cliente
where v.data_pedido <='2021-01-31' and v.data_pedido >= p.data_adesão
group by p.id_cliente
order by p.id_cliente;

-- pergunta bonus 1
select v.id_cliente, v.data_pedido, m.nome_produto, m.preço,
	case
		when c.data_adesão > v.data_pedido then 'Não'
        when c.data_adesão <= v.data_pedido then 'Sim'
        else 'Não'
	end as Membro
from Vendas as v
left join Clientes as c
on v.id_cliente = c.id_cliente
left join Menu as m
on v.id_produto = m.id_produto;

-- pergunta bonus 2
with clientes_data as (
select v.id_cliente, v.data_pedido, m.nome_produto, m.preço,
	case
		when c.data_adesão > v.data_pedido then 'Não'
        when c.data_adesão <= v.data_pedido then 'Sim'
        else 'Não'
	end as Membro
from Vendas as v
left join Clientes as c
on v.id_cliente = c.id_cliente
left join Menu as m
on v.id_produto = m.id_produto)

select *,
	case
		when Membro = 'Não' then NULL
        else rank() over(partition by id_cliente, Membro order by data_pedido)
        end as Ranking
from clientes_data;