drop trigger if exists val;

delimiter $$
create trigger val
before insert
on Person
  For each row
  if new.AccountName is NUll
  then 
  set new.AccountName = 'Unknown';
  end if;
$$
delimiter ;
drop trigger if exists v;

delimiter $$
create trigger v
before update
on Person
  For each row
  if new.Balance > (select Balance from Person where AccountID = new.AccountID )
  then 
  signal SQLSTATE '45000'
  set message_text = 'negative amount';
  end if;
$$
delimiter ;
drop trigger if exists a;

delimiter $$
create trigger a
after update
on Person
  For each row
  begin 
  set new.AccountName = substring(AccountName,1,3);
  end;
$$
delimiter ;

/*drop trigger if exists vul;

delimiter $$
create trigger vul
referencing new row as nrow;
after update
on Person
  For each row
  when (nrow.Balance < 0)
  begin
    update Person
    set Balance = 0;
    where AccountID = nrow.AccountID;
  end;
$$
delimiter ;
delimiter $$
create trigger vul
after update
on Person
  For each row
  if (new.AccountID < 0)
  then
  begin atomic
  update Person
  set new.AccountID = 22
  where AccountID = new.AccountID;
  end if;
$$
delimiter ;*/


