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
