
drop table if exists mzas;
create table mzas(
    set_of_mza integer[]
);

truncate mzas;
insert into mzas values(array[1]);
insert into mzas values(array[2]);
insert into mzas values(array[3]);

/*
select set_of_mza from mzas;
 set_of_mza 
------------
 {1}
 {2}
 {3}
(3 rows)
*/

/*
select i.set_of_mza || j.set_of_mza as set_of_mza
from mzas i
inner join mzas j
on not (i.set_of_mza && j.set_of_mza)
;
 set_of_mza 
------------
 {1,2}
 {1,3}
 {2,1}
 {2,3}
 {3,1}
 {3,2}
(6 rows)
*/

drop table if exists arrays_recursivas;
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

create or replace function sets_de_mzas(tbl_name text)
returns table (set_of_mza integer[]) as $$
begin
return query execute
format('    
    with recursive conjuntos as (
        select set_of_mza from %1$s
        union
        select i.set_of_mza || j.set_of_mza
        from %1$s i
        inner join conjuntos j
        on not (i.set_of_mza && j.set_of_mza)
    )
    select * from conjuntos', $1);
end
$$ language plpgsql;

/*
select sets_de_mzas('mzas');
 sets_de_mzas 
--------------
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

drop table if exists adyacencias;
create table adyacencias (
    mza_i integer,
    mza_j integer
);

truncate adyacencias;
insert into adyacencias values (1,2);
insert into adyacencias values (1,3);

create or replace function blqs_de_mzas(tbl_name text)
returns table (set_of_mza integer[]) as $$
begin
return query execute
format('    
    with recursive conjuntos as (
        select set_of_mza from %1$s
        union
        select i.set_of_mza || j.set_of_mza
        from %1$s i
        inner join conjuntos j
        on not (i.set_of_mza && j.set_of_mza)
    )
    select set_of_mza from conjuntos
    where array_length(set_of_mza,1) = 1
    or array_length(set_of_mza,1) = 2
        and (set_of_mza[1], set_of_mza[2]) in (select * from adyacencias)
    or array_length(set_of_mza,1) = 3
        and (set_of_mza[1], set_of_mza[2]) in (select * from adyacencias)
        and (set_of_mza[2], set_of_mza[3]) in (select * from adyacencias)
    or array_length(set_of_mza,1) = 4
        and (set_of_mza[1], set_of_mza[2]) in (select * from adyacencias)
        and (set_of_mza[2], set_of_mza[3]) in (select * from adyacencias)
        and (set_of_mza[3], set_of_mza[4]) in (select * from adyacencias)
    ', $1);
end
$$ language plpgsql;
--TODO: hacer una function recursiva sobre adyacencias
-- o poner un límite en la cantidad de mzas, lo que me parece mejor

/*
select blqs_de_mzas('mzas');
 blqs_de_mzas 
--------------
 {1}
 {2}
 {3}
 {1,2}
 {1,3}
(5 rows)
*/


insert into adyacencias values (2,3);

/*
select blqs_de_mzas('mzas');
 blqs_de_mzas 
--------------
 {1}
 {2}
 {3}
 {1,2}
 {1,3}
 {2,3}
 {1,2,3}
(7 rows)
*/

create or replace function blqs_de_mzas(tbl_name text)
returns table (set_of_mza integer[]) as $$
$$
begin
return query execute
format('    
    select set_of_mza from %1$s
    ', $1);
end
language plpgsql;
