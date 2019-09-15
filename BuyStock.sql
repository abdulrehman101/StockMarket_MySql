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

