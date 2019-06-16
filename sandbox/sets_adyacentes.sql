CREATE OR REPLACE FUNCTION array_sort (ANYARRAY)
RETURNS ANYARRAY LANGUAGE SQL
AS $$
SELECT ARRAY(SELECT unnest($1) ORDER BY 1)
$$;
--https://stackoverflow.com/questions/2913368/sorting-array-elements

create or replace function sets_de_adys(
    compnts text, 
    adyacencias text)
returns table (set_compnt integer[]) as $$
begin
return query execute
format('
    with recursive conjuntos as (
        with sets as (
            select Null as set_compnt
            union
            select array[id] from %1$s
            )
        select set_compnt from sets
        union
        select i.set_compnt || j.set_compnt
        from sets i
        inner join conjuntos j
        on not (i.set_compnt && j.set_compnt)
        --and i.set_compnt[1] < all(j.set_compnt) 
    )
    select distinct array_sort(set_compnt) as blq from conjuntos
    where array_length(set_compnt,1) = 1
    or array_length(set_compnt,1) >= 2
        and (set_compnt[1], set_compnt[2]) in (select * from %2$s)
    or array_length(set_compnt,1) >= 3
        and ((set_compnt[1], set_compnt[3]) in (select * from %2$s)
          or (set_compnt[2], set_compnt[3]) in (select * from %2$s)
            )
    or array_length(set_compnt,1) >= 4
        and ((set_compnt[1], set_compnt[4]) in (select * from %2$s)
          or (set_compnt[2], set_compnt[4]) in (select * from %2$s)
          or (set_compnt[3], set_compnt[4]) in (select * from %2$s)
            )
    or array_length(set_compnt,1) >= 5
        and ((set_compnt[1], set_compnt[5]) in (select * from %2$s)
          or (set_compnt[2], set_compnt[5]) in (select * from %2$s)
          or (set_compnt[3], set_compnt[5]) in (select * from %2$s)
          or (set_compnt[4], set_compnt[5]) in (select * from %2$s)
            )
    or array_length(set_compnt,1) >= 6
        and ((set_compnt[1], set_compnt[6]) in (select * from %2$s)
          or (set_compnt[2], set_compnt[6]) in (select * from %2$s)
          or (set_compnt[3], set_compnt[6]) in (select * from %2$s)
          or (set_compnt[4], set_compnt[6]) in (select * from %2$s)
          or (set_compnt[5], set_compnt[6]) in (select * from %2$s)
            )
    
    order by blq
    ', $1, $2);
end
$$ language plpgsql;
--TODO: hacer una function recursiva sobre adyacencias
-- o poner un límite en la cantidad de compnts, lo que me parece mejor

