/usr/pgsql-9.5/bin/shp2pgsql -W latin1 -s 22183 -d shapes/$1 shapes.$1 | python shp2table.py
