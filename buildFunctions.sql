drop procedure if exists BuyStock;
delimiter &&
create procedure BuyStock(In pName varchar(60), In sName varchar(60), In amount int(6))

begin

Declare StockAvailable int(6);
Declare sID int(6);
Declare compID int(6);
Declare sellerID int(6);
Declare buyerID int(6);
Declare QuantityStockAvailable int(6);
Declare moneyAvailable decimal(14,2);
Declare moneyRequired decimal(14,2);

select count(*) into StockAvailable
from
(
select SellOrder.StockID, Price, Quantity, Company.CompanyName, Person.AccountID, Person.AccountName
from SellOrder, Stock, Company, Person
where 
  SellOrder.StockID = Stock.StockID and 
  Stock.CompanyID = Company.CompanyID and
  Stock.AccountID = Person.AccountID and
  Company.CompanyName = sName
) T
;

if StockAvailable <> 0
then 
   
  select sum(Quantity) into QuantityStockAvailable
  from SellOrder, Stock, Company, Person
  where 
    SellOrder.StockID = Stock.StockID and 
    Stock.CompanyID = Company.CompanyID and
    Stock.AccountID = Person.AccountID and
    CompanyName = sName
  group by Company.CompanyName  
  ;

  select Balance into MoneyAvailable
  from Person
  where AccountName = pName;
 
  if (StockAvailable = 1 and QuantityStockAvailable >= amount)
  then
    select Price*amount into moneyRequired
    from
    (
      select SellOrder.StockID, Price, Quantity, Company.CompanyName, Person.AccountID , Person.AccountName
      from SellOrder, Stock, Company, Person
      where 
        SellOrder.StockID = Stock.StockID and 
        Stock.CompanyID = Company.CompanyID and
        Stock.AccountID = Person.AccountID and
        Company.CompanyName = sName
    ) T ;
    select AccountID into sellerID
    from
    (
      select SellOrder.StockID, Price, Quantity, Company.CompanyName, Person.AccountID , Person.AccountName
      from SellOrder, Stock, Company, Person
      where 
        SellOrder.StockID = Stock.StockID and 
        Stock.CompanyID = Company.CompanyID and
        Stock.AccountID = Person.AccountID and
        Company.CompanyName = sName
    ) T ;
    select StockID into sID
    from
    (
      select SellOrder.StockID, Price, Quantity, Company.CompanyName, Person.AccountID , Person.AccountName
      from SellOrder, Stock, Company, Person
      where 
        SellOrder.StockID = Stock.StockID and 
        Stock.CompanyID = Company.CompanyID and
        Stock.AccountID = Person.AccountID and
        Company.CompanyName = sName
    ) T ;
    select AccountID into buyerID
    from Person where AccountName = pName;
   
    select CompanyID into compID
    from Company where CompanyName = sName;
    
    select sellerID as SID, sID as StockID;
    if (moneyRequired <= moneyAvailable and QuantityStockAvailable = amount)
    then
      update Person
      set Balance = Balance + moneyRequired
      where AccountID = sellerID;
      update Person
      set Balance = Balance - moneyRequired
      where AccountName = pName;
      delete from SellOrder
      where StockID = sID;
      insert into Stock(CompanyID, AccountID, Quantity) values(compID, buyerID, QuantityStockAvailable);
      delete from Stock
      where StockID = sID;
    end if;
    
  end if;

end if;

end;
&&
delimiter ;

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

DROP procedure if exists DepositFunds;
DROP procedure if exists WithdrawFunds;

create procedure DepositFunds(In pName varchar(60), In amount numeric(14,2))
update Person
set Balance = Balance + amount
where AccountName = pName;

delimiter $$
create procedure WithdrawFunds(In pName varchar(60), In amount numeric(14,2))
begin
  declare funds numeric(14,2);
  select Balance into funds
  from Person
  where AccountName = pName;
  if 
    amount >= funds
  then 
    update Person
    set Balance = 0.00
    where AccountName = pName;
  else
    update Person
    set Balance = Balance - amount
    where AccountName = pName;
    
  end if;
end;
$$
delimiter ;