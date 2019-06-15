-- agregar sets_adyacentes
create temp sequence if not exists ids; 
select nextval('ids') as id, *
from blqs_de_mzas('mzas', 'adyacencias');

drop sequence ids;
