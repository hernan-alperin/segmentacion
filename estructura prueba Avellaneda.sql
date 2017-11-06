halpe=# \d segmenta.viv035
                                           Tabla «segmenta.viv035»
  Columna   |         Tipo          |                              Modificadores
------------+-----------------------+-------------------------------------------------------------------------
 gid        | integer               | not null valor por omisión nextval('segmenta.viv035_gid_seq'::regclass)
 prov       | character varying(2)  |
 dpto       | character varying(3)  |
 frac       | character varying(2)  |
 radio      | character varying(2)  |
 codloc10   | character varying(3)  |
 mza10      | character varying(3)  |
 lado10     | character varying(2)  |
 clado10    | character varying(17) |
 objectid   | double precision      |
 nomb_calle | character varying(48) |
 numero     | double precision      |
 num        | integer               |
 street     | character varying(12) |
 codigoc    | character varying(6)  |
 codigo     | integer               |
 av_add     | character varying(12) |
 av_status  | character varying(1)  |
 av_score   | integer               |
 av_side    | character varying(1)  |
 geom       | geometry(Point,22185) |
Índices:
    "viv035_pkey" PRIMARY KEY, btree (gid)
    "viv035_geom_idx" gist (geom)

halpe=# \d segmenta.eb035p
                                              Tabla «segmenta.eb035p»
  Columna  |             Tipo             |                              Modificadores
-----------+------------------------------+-------------------------------------------------------------------------
 gid       | integer                      | not null valor por omisión nextval('segmenta.eb035p_gid_seq'::regclass)
 area      | double precision             |
 perimeter | double precision             |
 eb035_    | double precision             |
 eb035_id  | double precision             |
 prov      | character varying(2)         |
 codmuni   | character varying(4)         |
 nommuni   | character varying(43)        |
 codent    | character varying(2)         |
 noment    | character varying(40)        |
 depto     | character varying(3)         |
 codloc    | character varying(3)         |
 nomloc    | character varying(40)        |
 frac      | character varying(2)         |
 radio     | character varying(2)         |
 mza       | character varying(3)         |
 mzatxt    | smallint                     |
 cen01     | character varying(7)         |
 tmza      | smallint                     |
 geom      | geometry(MultiPolygon,22185) |
Índices:
    "eb035p_pkey" PRIMARY KEY, btree (gid)
    "eb035p_geom_idx" gist (geom)

halpe=# \d segmenta.eb035a
                                               Tabla «segmenta.eb035a»
 Columna  |              Tipo               |                              Modificadores
----------+---------------------------------+-------------------------------------------------------------------------
 gid      | integer                         | not null valor por omisión nextval('segmenta.eb035a_gid_seq'::regclass)
 fnode_   | double precision                |
 tnode_   | double precision                |
 lpoly_   | double precision                |
 rpoly_   | double precision                |
 length   | double precision                |
 eb035_   | double precision                |
 eb035_id | double precision                |
 codigo   | integer                         |
 ancho    | smallint                        |
 anchomed | double precision                |
 nombre   | character varying(40)           |
 nom_nor  | character varying(40)           |
 ladoi    | smallint                        |
 ladod    | smallint                        |
 desdei   | integer                         |
 desded   | integer                         |
 hastai   | integer                         |
 hastad   | integer                         |
 mzai     | character varying(17)           |
 mzad     | character varying(17)           |
 conteoi  | double precision                |
 conteod  | double precision                |
 codigoc  | character varying(6)            |
 ld       | smallint                        |
 geom     | geometry(MultiLineString,22185) |
Índices:
    "eb035a_pkey" PRIMARY KEY, btree (gid)
    "eb035a_geom_idx" gist (geom)

