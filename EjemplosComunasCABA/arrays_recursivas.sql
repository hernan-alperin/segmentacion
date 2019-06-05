
drop table if exists mzas;
create table mzas(
--    conjunto integer,
    set_of_mza integer[]
);

truncate mzas;
insert into mzas values(array[1]);
insert into mzas values(array[2]);
insert into mzas values(array[3]);


select set_of_mza from mzas;

select i.set_of_mza || j.set_of_mza as set_of_mza
from mzas i
inner join mzas j
on not (i.set_of_mza && j.set_of_mza)
;

create table arrays_recursivas as
with recursive conjuntos as (
    select set_of_mza from mzas
    union
    select i.set_of_mza || j.set_of_mza 
    from mzas i
    inner join conjuntos j
    on not (i.set_of_mza && j.set_of_mza)
    )
select * from conjuntos
;

/*
select * from arrays_recursivas;
 set_of_mza 
------------
 {1}
 {2}
 {3}
 {2,1}
 {3,1}
 {1,2}
 {3,2}
 {1,3}
 {2,3}
 {3,2,1}
 {2,3,1}
 {3,1,2}
 {1,3,2}
 {2,1,3}
 {1,2,3}
(15 rows)
*/

