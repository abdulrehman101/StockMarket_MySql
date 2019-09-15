drop procedure if exists SellStock;
drop view if exists info;
drop view if exists minusInfo;
drop view if exists finalInfo;

create view info as 
select StockID, Stock.CompanyID, CompanyName, Stock.AccountID, Quantity, AccountName 
from Stock, Person, Company
where 
  Person.AccountID = Stock.AccountID and
  Stock.CompanyID = Company.CompanyID
Order by StockID
;
create view minusInfo as 
select Stock.StockID, Stock.CompanyID, CompanyName, Stock.AccountID, Quantity, AccountName 
from Stock, Person, Company, SellOrder
where 
  Person.AccountID = Stock.AccountID and
  Stock.CompanyID = Company.CompanyID and
  SellOrder.StockID = Stock.StockID
order by StockID
;
create view finalInfo as
select info.StockID, info.CompanyID, info.CompanyName, info.AccountID, info.Quantity, info.AccountName
from info left join minusInfo using(StockID)
where minusInfo.StockID is NULL
;
delimiter &&

create procedure SellStock(in pName varchar(60), in sName varchar(60),in amount int(8), price numeric(14,2))
begin
  declare numLots int(8);
  declare del int(8);
  declare sID int(8);
  declare number int(8);
  declare CompID int(8);
  declare AccID int(8);
  declare numStockOwned int(8);
  set number = amount;
  select count(*) into numLots
  from finalInfo
  where CompanyName = sName and
        AccountName = pName
  ;
  select sum(Quantity) into numStockOwned
  from finalInfo
  where CompanyName = sName and
        AccountName = pName
  ;
 
  if(numLots > 0 and numStockOwned >= amount and price > 0)
    then
      
    while (number != 0) Do
      select Quantity into del
      from finalInfo
      where
        CompanyName = sName and
        AccountName = pName
      limit 1
      ;
      select StockID into sID
      from finalInfo
      where
        CompanyName = sName and
        AccountName = pName
      limit 1
      ;
      select CompanyID into CompID
      from finalInfo
      where
        CompanyName = sName and
        AccountName = pName
      limit 1
      ;
      select AccountID into AccID
      from finalInfo
      where
        CompanyName = sName and
        AccountName = pName
      limit 1
      ;
      if (number >= del)
      then
        insert into SellOrder(StockID, Price) values(sID, price);
        set number = number - del;
      else
        insert into SellOrder(StockID, Price) values(sID, Price);
        update Stock set Quantity = number 
        where StockID = sID;
        insert into Stock(CompanyID, AccountID, Quantity)
                    values(CompID, AccID, del - number);
        set number = 0;
      end if;
    end while;
  end if;
end;
&&
delimiter ;
