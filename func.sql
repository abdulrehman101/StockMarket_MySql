drop function if exists naam;

delimiter $$

create function naam(pName varchar(50))
returns integer
begin
  declare b int(6) default 1;
  select Balance into b from Person where AccountName = pName;
  if b > 0
  then return 1;
  else
  return 0;
  end if;
end;
$$
delimiter ;
select naam('gumNaam');