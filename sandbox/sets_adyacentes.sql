
drop table if exists mzas;
create table mzas(
    id integer
);

truncate mzas;
insert into mzas values(1);
insert into mzas values(2);
insert into mzas values(3);
insert into mzas values(4);

drop table if exists adyacencias;
create table adyacencias (
    mza_i integer,
    mza_j integer
);

truncate adyacencias;
insert into adyacencias values (1,2);
insert into adyacencias values (1,3);

create or replace function blqs_de_mzas(mzas text, adyacencias text)
returns table (set_de_mza integer[]) as $$
begin
return query execute
format('    
    with recursive conjuntos as (
        with sets as (
            select Null as set_de_mza
            union
            select array[id] from mzas
            )
        select set_de_mza from sets
        union
        select i.set_de_mza || j.set_de_mza
        from sets i
        inner join conjuntos j
        on not (i.set_de_mza && j.set_de_mza)
    )
    select set_de_mza from conjuntos
    where array_length(set_de_mza,1) = 1
    or array_length(set_de_mza,1) = 2
        and (set_de_mza[1], set_de_mza[2]) in (select * from %2$s)
    or array_length(set_de_mza,1) = 3
        and (set_de_mza[1], set_de_mza[2]) in (select * from %2$s)
        and (set_de_mza[2], set_de_mza[3]) in (select * from %2$s)
    or array_length(set_de_mza,1) = 3
        and (set_de_mza[1], set_de_mza[2]) in (select * from %2$s)
        and (set_de_mza[1], set_de_mza[3]) in (select * from %2$s)
    ', $1, $2);
end
$$ language plpgsql;
--TODO: hacer una function recursiva sobre adyacencias
-- o poner un límite en la cantidad de mzas, lo que me parece mejor

select blqs_de_mzas('mzas', 'adyacencias');


