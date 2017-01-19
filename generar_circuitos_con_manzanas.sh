psql --set=comuna=$1 -f generar_circuitos_con_manzanas.sql #| cut -f 1-5 -d',' | uniq
