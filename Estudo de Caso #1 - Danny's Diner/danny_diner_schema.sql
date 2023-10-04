-- Criando o banco de dados:
create database dannys_diner;

-- Conectando ao banco de dados:
use dannys_diner;

-- Criando as tabelas:
create table Vendas (
	id_cliente varchar(1),
    data_pedido date,
    id_produto integer);
    
create table Clientes(
	id_cliente varchar(1),
    data_adesão date);
    
create table Menu(
	id_produto integer,
    nome_produto varchar(5),
    preço integer);

-- Inserindo dados nas tabelas:
insert into Vendas (id_cliente, data_pedido, id_produto)
values 
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

insert into Clientes (id_cliente, data_adesão)
values 
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

insert into Menu (id_produto, nome_produto, preço)
values 
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
