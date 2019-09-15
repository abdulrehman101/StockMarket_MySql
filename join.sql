select SellOrder.StockID, CompanyID, AccountID, Quantity,LotID, Price
from Stock join SellOrder on SellOrder.StockID = Stock.StockID
;

select SellOrder.StockID, CompanyID, AccountID, Quantity,LotID, Price
from Stock join SellOrder using (StockID)
;

select SellOrder.StockID, CompanyID, AccountID, Quantity,LotID, Price
from Stock left outer join SellOrder using (StockID)
;
select SellOrder.StockID, CompanyID, AccountID, Quantity,LotID, Price
from Stock right outer join SellOrder using (StockID)
;