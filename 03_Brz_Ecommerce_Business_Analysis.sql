--====================================================================================================================================================================
-- 								preguntas a responder con consultas y vistas
--====================================================================================================================================================================

--===================================
-- 3.1 clientes y mercado
--===================================

-- 3.1.1. Which states or cities have the highest customer concentration?
USE [brz_ecomerce];

select  top 10
        estado, 
        sum(cant_clientes) as cant_clientes
from vw_info_zonas
group by estado
order by sum(cant_clientes) desc;

-- 3.1.2. How does new customer growth change over time?

with primeras_compras as (
    select 
        customer_id,
        min(fecha_compra) as fecha_primer_compra
    from vw_orders_detail
    group by customer_id
),
clientes_mensuales as (
    select
        year(fecha_primer_compra) as anio_compra,
        month(fecha_primer_compra) as mes_compra,
        count(customer_id) as nuevos_clientes
    from primeras_compras
    group by year(fecha_primer_compra), month(fecha_primer_compra)
),
clientes_lag as (
    select  
        anio_compra,
        mes_compra,
        nuevos_clientes,
        lag(nuevos_clientes) over (order by anio_compra, mes_compra) as clientes_mes_anterior
    from clientes_mensuales
)
select *,
       case 
            when clientes_mes_anterior is null then null
            when clientes_mes_anterior = 0 then null
            else ((nuevos_clientes - clientes_mes_anterior) * 100.0) / clientes_mes_anterior
       end as porcentaje_crecimiento
from clientes_lag
order by anio_compra, mes_compra;
go

-- 3.1.3. Which cities contribute the highest order volume?

select  top 10
        ciudad, 
        sum(cant_clientes) as cant_clientes
from vw_info_zonas
group by ciudad
order by sum(cant_clientes) desc;

--===================================
-- 3.2. Sales and Products
--===================================

-- 3.2.1. Which product categories sell the most and which have the lowest turnover?

-- Categories with the most items sold
select  top 10 
        categoria_producto,     
        sum(total_unidades_vendidas) cant_unidades_vendidas
from vw_info_producto
group by categoria_producto
order by cant_unidades_vendidas desc;

-- Categories with the fewest items sold
select  top 10 
        categoria_producto,     
        sum(total_unidades_vendidas) cant_unidades_vendidas
from vw_info_producto
group by categoria_producto
order by cant_unidades_vendidas asc;

-- 3.2.2. What is the average order value per customer and per order?

-- Average order value per customer
select  customer_id,
        sum(total_compra_cliente)/nullif(sum(total_productos_comprados),0) as ticket_promedio_cliente
from vw_info_clientes
group by customer_id
ORDER BY ticket_promedio_cliente desc;


-- Average order value per order

select o.order_id,
       sum(op.payment_value)/nullif(count(oi.order_item_id),0) as ticket_promedio
from order_payments as op
inner join orders as o on o.order_id = op.order_id
inner join order_item as oi on oi.order_id = o.order_id
group by o.order_id
order by ticket_promedio desc;

-- 3.2.3. Which products have the highest estimated sales value after freight costs?

select  top 10
        vp.product_id,
        sum(vp.total_acumulado_real)as total_venta,
        sum(oi.freight_value) as total_flete,
        sum(vp.total_acumulado_real) - sum(oi.freight_value) as total_acumulado_menos_flete
from vw_info_producto as vp
left join order_item as oi on oi.product_id = vp.product_id
group by vp.product_id
order by total_acumulado_menos_flete desc;

/* 
Nota:
El campo total_acumulado_real representa el pago total realizado por el cliente a nivel de orden,
obtained by aggregating the information available in the payments table.
Because the dataset does not provide the paid value or cost for each individual item,
product-level analyses are estimates that use the order payment total and subtract
the accumulated freight cost for the included products.

This approach identifies products with the highest revenue concentration,
while respecting the data model limitations and avoiding duplicate calculations.
*/

-- 3.2.4. What percentage of sales comes from the top 10 categories?

-- hecho con with
with rankedcategorias as (
    select 
        categoria_producto,
        sum(total_acumulado_real) as totalventas,
        row_number() over (order by sum(total_acumulado_real) desc) as rn
    from vw_info_producto
    group by categoria_producto
)
select 
    sum(case when rn <= 10 then totalventas else 0 end) * 100.0 / sum(totalventas) as porcentajetop10,
    sum(case when rn > 10 then totalventas else 0 end) * 100.0 / sum(totalventas) as porcentajeresto
from rankedcategorias;
go

-- hecho con subconsulta
select 
        sum(case when rn > 10 then totalventas else 0 end) * 100.0 / sum(totalventas) as porcentaje_top10,
        sum(case when rn <= 10 then totalventas else 0 end) * 100.0 / sum(totalventas) as porcentaje_resto
from(
    select
        categoria_producto,
        sum(total_acumulado_real) as totalventas,
        row_number() over(order by sum(total_acumulado_real) desc) as rn
    from vw_info_producto
    group by categoria_producto
) as ranked;

--===================================
-- 3.3. Sellers
--===================================

-- 3.3.1. Which sellers handle the highest number of orders?

select top 10
        seller_id,
        count(distinct order_id) as cantidad_ordenes,
        dense_rank() over(order by count(distinct order_id) desc) as rango
from vw_orders_detail
group by seller_id;

select  top 10
        seller_id,
        sum(cant_ordenes) as cant_ordenes,
        dense_rank() over(order by  sum(cant_ordenes) desc) as rango
from vw_info_vendedores
group by seller_id;

 /*
 nota:
 gracias a este query:
 
 select	
        seller_id,
        count(distinct order_id) as cantidad_ordenes,
        dense_rank() over(order by count(order_id) desc) as rango
from vw_orders_detail
where seller_id is null
group by seller_id;

se observo que hay 833 ordenes las cuales no tienen seller_id
*/

-- 3.3.2. What is the market concentration and sales share of the top 10 sellers?

with rango_vendedores as (
    select  seller_id,
            sum(total_ventas) as total_venta,
            sum(cant_ordenes) as cant_ordenes,
            row_number() over(order by sum(total_ventas) desc) as rn
    from vw_info_vendedores
    group by seller_id
)
select 
        sum(case when rn <= 10 then total_venta else 0 end) * 100.0 / sum(total_venta) as '% top 10 vendedores',
        sum(case when rn <= 10 then cant_ordenes else 0 end) as 'cant. ordenes % top 10',
        sum(case when rn > 10 then total_venta else 0 end) * 100.0 / sum(total_venta) as '% resto de vendedores',
        sum(case when rn > 10 then cant_ordenes else 0 end) as 'cant. ordenes de resto vendedores'
from rango_vendedores
go
-- 3.3.3. Which sellers have the best delivery-time performance?

--with con row_number:
with vendedores as (
    select	
        seller_id,
        datediff(day, fecha_compra, fecha_entrega_cliente) as dias_de_entrega
    from vw_orders_detail
    where seller_id is not null
      and fecha_compra is not null
      and fecha_entrega_cliente is not null
      and datediff(day, fecha_compra, fecha_entrega_cliente) > 0
)
select top 10 seller_id,
       avg(dias_de_entrega) as promedio_dia_entrega,
       row_number() over(order by avg(dias_de_entrega)) as ranking
from vendedores
group by seller_id
order by promedio_dia_entrega;

--with con dense_rank:
with vendedores as (
    select	
        seller_id,
        datediff(day, fecha_compra, fecha_entrega_cliente) as dias_de_entrega
    from vw_orders_detail
    where seller_id is not null
      and fecha_entrega_cliente is not null
      and fecha_compra is not null
      and datediff(day, fecha_compra, fecha_entrega_cliente) > 0
)
select
    seller_id,
    avg(dias_de_entrega) as promedio_dias_entrega,
    dense_rank() over (order by avg(dias_de_entrega)) as ranking
from vendedores
group by seller_id
order by promedio_dias_entrega asc;

--===================================
-- 3.4. Logistics and Delivery
--===================================

-- 3.4.1. What is the average delivery time by state and product category?

--tiempo promedio de entrega por estado
select  estado,
        avg(cant_dias_prom_de_entrega) as dias_prom_de_entrega
FROM vw_info_zonas
group by estado
order by  dias_prom_de_entrega;

-- tiempo promedio de entrega por categoria de producto

select  categoria_producto,
        avg(datediff(day,fecha_compra,fecha_entrega_cliente)) as dia_prom_de_entrega
from vw_orders_detail
where categoria_producto is not null
group by categoria_producto;

--tiempo promedio de netrega por estado y y categoria

select  estado_cliente,
        categoria_producto,
        avg(datediff(day,fecha_compra,fecha_entrega_cliente)) as dia_prom_de_entrega
from vw_orders_detail
group by estado_cliente,categoria_producto;

-- 3.4.2. What percentage of orders are delivered within the estimated time?

with tiempo as (
    select 
        order_id,
        DATEDIFF(DAY,order_purchase_timestamp,order_delivered_customer_date) as tiempo_prom_entrega_dias,
        DATEDIFF(DAY,order_purchase_timestamp,order_estimated_delivery_date) as tiempo_prom_entrega_estimada_dias
    from orders
    where order_purchase_timestamp is not null
    and order_delivered_customer_date is not null
    and order_estimated_delivery_date is not null
)
select 
    count(*) as total_ordenes,
    sum(case when tiempo_prom_entrega_dias <= tiempo_prom_entrega_estimada_dias then 1 else 0 end) as ordenes_a_tiempo,
    sum(case when tiempo_prom_entrega_dias > tiempo_prom_entrega_estimada_dias then 1 else 0 end) as ordenes_fuera_tiempo,
    sum(case when tiempo_prom_entrega_dias <= tiempo_prom_entrega_estimada_dias then 1 else 0 end) * 100.0 / count(*) as porcentaje_a_tiempo,
    sum(case when tiempo_prom_entrega_dias > tiempo_prom_entrega_estimada_dias  then 1 else 0 end) * 100.0 / count(*) as porcentaje_fuera_tiempo
from tiempo
go
-- 3.4.3. Which states or cities have the highest percentage of late deliveries?

-- Highest late-delivery percentage grouped by city
with orden_ciudad as (
    select  
        o.order_id,
        s.seller_city as ciudad,
        min(datediff(day, o.order_purchase_timestamp, o.order_delivered_customer_date)) as dias_entrega,
        min(datediff(day, o.order_purchase_timestamp, o.order_estimated_delivery_date)) as dias_estimados
    from orders as o
    inner join order_item as oi on oi.order_id = o.order_id
    inner join sellers as s on s.seller_id = oi.seller_id
    where o.order_purchase_timestamp is not null
    and o.order_delivered_customer_date is not null
    and o.order_estimated_delivery_date is not null
    group by o.order_id, s.seller_city
)
select 
    ciudad,
    count(*) as total_ordenes,
    sum(case when dias_entrega > dias_estimados then 1 else 0 end) as ordenes_fuera_tiempo,
    sum(case when dias_entrega > dias_estimados then 1 else 0 end) * 100.0 / count(*) as porcentaje_fuera_tiempo
from orden_ciudad
group by ciudad
order by porcentaje_fuera_tiempo desc;

-- Highest late-delivery percentage grouped by state
with orden_estado as (
    select  
        o.order_id,
        s.seller_state as estado,
        min(datediff(day, o.order_purchase_timestamp, o.order_delivered_customer_date)) as dias_entrega,
        min(datediff(day, o.order_purchase_timestamp, o.order_estimated_delivery_date)) as dias_estimados
    from orders as o
    inner join order_item as oi on oi.order_id = o.order_id
    inner join sellers as s on s.seller_id = oi.seller_id
    where o.order_purchase_timestamp is not null
    and o.order_delivered_customer_date is not null
    and o.order_estimated_delivery_date is not null
    group by o.order_id, s.seller_state
)
select 
    estado,
    count(*) as total_ordenes,
    sum(case when dias_entrega > dias_estimados then 1 else 0 end) as ordenes_fuera_tiempo,
    sum(case when dias_entrega > dias_estimados then 1 else 0 end) * 100.0 / count(*) as porcentaje_fuera_tiempo
from orden_estado
group by estado
order by porcentaje_fuera_tiempo desc;

--===================================
-- 3.5. Payments and Billing
--===================================

-- 3.5.1. Which payment methods are most used by customers?

select 
        metodo_pago,
        sum(veces_usado) veces_usado
from vw_info_pagos
group by metodo_pago
order by veces_usado desc;

-- 3.5.2. What is the average transaction value by payment type?

with agrupar_order_pago as(
    select 
            o.order_id,
            op.payment_type as metodo_pago,
            op.payment_value as valor_pago
    from orders as o
    left join order_payments as op on op.order_id = o.order_id
    where op.payment_type is not null
    and op.payment_value is not null
)
select 
        metodo_pago,
        AVG(valor_pago) prom_pago
from agrupar_order_pago
group by metodo_pago
order by prom_pago desc
go

-- 3.5.3. What percentage of orders are paid in installments versus one payment?
with pagos_acumulados as (
select 
        order_id,
        count(payment_sequential) as cantidad_pagos 
from order_payments
group by order_id
)
select
        SUM(case  when cantidad_pagos > 1 then 1 else 0 end) as cant_ordenes_pago_cuotas,
        SUM(case  when cantidad_pagos > 1 then 1 else 0 end) * 100.0/count(cantidad_pagos) as porcentaje_ordenes_pago_cuotas,
        SUM(case  when cantidad_pagos = 1 then 1 else 0 end) as cant_ordenes_pago_unicos,
        SUM(case  when cantidad_pagos = 1 then 1 else 0 end) * 100.0/count(cantidad_pagos) as porcentaje_ordenes_pago_unicos,
        count(cantidad_pagos) as total_ordenes
from pagos_acumulados;
go

--===================================
-- 3.6. Customer Satisfaction
--===================================

-- 3.6.1. What is the average review score by customer state?

with review_estado as (
select  o.order_id,
        c.customer_state as estado,
        orv.review_score
from  orders as o
inner join customer as c on c.customer_id = o.customer_id
inner join order_reviews as orv on orv.order_id = o.order_id
)
select 
        estado,
        avg(review_score) as puntaje_promedio
from review_estado
group by estado;

/*
NOTE - Average review score by state:
- This query calculates the average review_score grouped by customer state.
- It identifies the states with the highest and lowest customer satisfaction.
- A CTE organizes the data before grouping it by state.
- Result: ranking of states by average review score.
*/

-- 3.6.2. Which categories have the highest level of returns or negative reviews?


with agrupar_categoria_review as (
        select 
                o.order_id,
                vp.categoria_producto,
                orv.review_score
        from orders as o
        inner join order_item as oi on oi.order_id = o.order_id
        inner join vw_info_producto as vp on vp.product_id = oi.product_id
        inner join order_reviews as orv on orv.order_id = o.order_id
        where vp.categoria_producto is not null 
        and orv.review_score is not null 
),
puntaje as(
    select  
            categoria_producto,
            AVG(review_score) as puntaje_promedio
    from agrupar_categoria_review
    group by categoria_producto
)
select *,
       case 
            when puntaje_promedio = 5 then 'Excelente'
            when puntaje_promedio = 4 then 'Muy bueno'
            when puntaje_promedio = 3 then 'Bueno'
            when puntaje_promedio = 2 then 'No tan bueno'
            else 'Malo'
        end as calificacion
from puntaje
order by puntaje_promedio asc;

/*
NOTE - Categories with negative reviews:
- Grouping by category revealed null values in review_score or category.
    Only valid data is therefore included to keep results consistent.
- En el primer CTE pueden aparecer registros aparentemente duplicados, pero en realidad no lo son: 
    the order_reviews table contains a review_id that identifies multiple reviews associated
    with one order. Each review_id represents a separate evaluation and is treated
    as an independent value.
- This behavior is handled by calculating the average review_score by category,
    integrating all valid reviews to reflect the actual satisfaction trend.
- The query classifies categories by average score using qualitative labels
    (Excellent, Very Good, Good, Below Average, Poor), making negative reviews
    and returns easier to interpret.
*/

-- 3.6.3. Is there a relationship between delivery times and customer satisfaction?
with tiempo_satisfaccion as (
    select  o.order_id,
            c.customer_state,
            c.customer_city,
            datediff(day,o.order_purchase_timestamp,o.order_delivered_customer_date) as tiempo_entrega,
            orv.review_score
    from orders as o
    inner join customer as c on c.customer_id = o.customer_id
    inner join  order_reviews as orv on orv.order_id = o.order_id
    where datediff(day,o.order_purchase_timestamp,o.order_delivered_customer_date) is not null
    and orv.review_score is not null
    and orv.review_score > 0

)
select
      case 
            when tiempo_entrega between 0 and 5 then '0-5 dias'
            when tiempo_entrega between 6 and 10 then '6-10 dias'
            when tiempo_entrega between 11 and 20 then '11-20 dias'
            when tiempo_entrega between 21 and 30 then '21-30 dias'
            else '30+ dias'
      end as rango_tiempo_entrega,
      count(distinct order_id) as cant_ordenes,
      avg(tiempo_entrega) as prom_tiempo_entrega,
      avg(review_score) as prom_review
from tiempo_satisfaccion
group by case 
            when tiempo_entrega between 0 and 5 then '0-5 dias'
            when tiempo_entrega between 6 and 10 then '6-10 dias'
            when tiempo_entrega between 11 and 20 then '11-20 dias'
            when tiempo_entrega between 21 and 30 then '21-30 dias'
            else '30+ dias'
      end
order by rango_tiempo_entrega

/*
NOTE - Relationship between delivery times and satisfaction:
- This query groups orders into delivery-time ranges (0-5, 6-10, 11-20, 21-30, 30+ days).
- It calculates average delivery days and average review scores for each range.
- It shows whether faster deliveries are associated with better reviews and whether long waits affect satisfaction.
- count(distinct order_id) prevents duplicates and keeps metrics reliable.
*/

--=========================================
-- fin del script
--=========================================