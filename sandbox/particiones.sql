-- agregar sets_adyacentes
create temp sequence if not exists ids; 
select nextval('ids') as id, *
from sets_de_adys('mzas', 'adyacencias');

drop sequence ids;
