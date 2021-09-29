-- homework
use classicmodels;

select orders.orderNumber,
priceEach,
quantityOrdered,
productName,
productLine,
city,
country,
orderDate from orders
    inner join orderdetails o on orders.orderNumber = o.orderNumber
    inner join products p on o.productCode = p.productCode
    inner join customers c on orders.customerNumber = c.customerNumber;