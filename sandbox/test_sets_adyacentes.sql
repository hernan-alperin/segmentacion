
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
insert into adyacencias values (2,3);
insert into adyacencias values (2,4);
select sets_de_adys('mzas', 'adyacencias');

