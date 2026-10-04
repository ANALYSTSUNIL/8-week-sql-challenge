-- ============================================================
-- DANNY'S DINER - CASE STUDY #1
-- 8 WEEK SQL CHALLENGE
-- ============================================================


-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id,
sum(m.price) as total_amount
from sales as s
inner join menu as m
on s.product_id = m.product_id
group by s.customer_id
order by total_amount desc;


-- 2. How many days has each customer visited the restaurant?

select customer_id,
count(distinct order_date) as days
from sales
group by customer_id
order by days desc;


-- 3. What was the first item from the menu purchased by each customer?

select s.customer_id,
m.product_name,
s.order_date
from sales as s
inner join menu as m
on s.product_id = m.product_id
where s.order_date = (
    select min(s2.order_date)
    from sales as s2
    where s2.customer_id = s.customer_id
)
order by s.customer_id;


-- 4. What is the most purchased item on the menu and how many
-- times was it purchased by all customers?

select m.product_name,
count(s.product_id) as order_count
from sales as s
inner join menu as m
on s.product_id = m.product_id
group by m.product_name
order by order_count desc
limit 1;


-- 5. Which item was the most popular for each customer?

with item_count as (
    select s.customer_id,
    m.product_name,
    count(s.product_id) as purchase_count
    from sales as s
    inner join menu as m
    on s.product_id = m.product_id
    group by s.customer_id, m.product_name
),

ranked_items as (
    select customer_id,
    product_name,
    purchase_count,
    dense_rank() over (
        partition by customer_id
        order by purchase_count desc
    ) as item_rank
    from item_count
)

select customer_id,
product_name,
purchase_count
from ranked_items
where item_rank = 1
order by customer_id;


-- 6. Which item was purchased first by the customer
-- after they became a member?

select s.customer_id,
m.product_name,
s.order_date
from sales as s
inner join menu as m
on s.product_id = m.product_id
inner join members as mem
on s.customer_id = mem.customer_id
where s.order_date >= mem.join_date
and s.order_date = (
    select min(s2.order_date)
    from sales as s2
    where s2.customer_id = s.customer_id
    and s2.order_date >= mem.join_date
)
order by s.customer_id;


-- 7. Which item was purchased just before the customer
-- became a member?

select s.customer_id,
m.product_name,
s.order_date
from sales as s
inner join menu as m
on s.product_id = m.product_id
inner join members as mem
on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
and s.order_date = (
    select max(s2.order_date)
    from sales as s2
    where s2.customer_id = s.customer_id
    and s2.order_date < mem.join_date
)
order by s.customer_id;


-- 8. What is the total items and amount spent for each member
-- before they became a member?

select mem.customer_id,
count(s.product_id) as total_items,
sum(m.price) as total_amount
from sales as s
inner join menu as m
on s.product_id = m.product_id
inner join members as mem
on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
group by mem.customer_id
order by mem.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has
-- a 2x points multiplier - how many points would each customer have?

select s.customer_id,
sum(
    case
        when product_name = 'sushi'
            then price * 2 * 10
        else price * 10
    end
) as total_points
from sales as s
inner join menu as m
on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id;


-- 10. In the first week after a customer joins the program
-- (including their join date), they earn 2x points on all items,
-- not just sushi - how many points do customer A and B have
-- at the end of January?

select s.customer_id,
sum(
    case
        when s.order_date between mem.join_date
             and mem.join_date + interval '6 days'
            then price * 2 * 10

        when product_name = 'sushi'
            then price * 2 * 10

        else price * 10
    end
) as total_points
from sales as s
inner join menu as m
on s.product_id = m.product_id
inner join members as mem
on s.customer_id = mem.customer_id
where s.order_date >= '2021-01-01'
and s.order_date < '2021-02-01'
group by s.customer_id
order by s.customer_id;
