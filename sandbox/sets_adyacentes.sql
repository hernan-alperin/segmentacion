CREATE OR REPLACE FUNCTION array_sort (ANYARRAY)
RETURNS ANYARRAY LANGUAGE SQL
AS $$
SELECT ARRAY(SELECT unnest($1) ORDER BY 1)
$$;
--https://stackoverflow.com/questions/2913368/sorting-array-elements

drop function sets_de_adys(text, text);
create or replace function sets_de_adys(
    compnts text, 
    adyacencias text)
returns table (set_compnt integer[]) as $$
begin
return query execute
format('
    with recursive conjuntos as (
        with sets as (
            select array[id] as set_compnt from %1$s
            )
        select set_compnt from sets
        union
        select i.set_compnt || j.set_compnt
        from sets i
        inner join conjuntos j
        on not (i.set_compnt && j.set_compnt) 
        and ((i.set_compnt[1]) in (select mza_i from %2$s where mza_j = any (j.set_compnt))
          or (i.set_compnt[1]) in (select mza_j from %2$s where mza_i = any (j.set_compnt)))
    )
    select distinct array_sort(set_compnt) as blq from conjuntos
    order by blq
    ', $1, $2);
end
$$ language plpgsql;
--TODO: hacer una function recursiva sobre adyacencias
-- o poner un límite en la cantidad de compnts, lo que me parece mejor

