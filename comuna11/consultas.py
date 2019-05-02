import psycopg2
conn = psycopg2.connect(
            database = "comuna11",
            user = "segmentador",
            password = "rodatnemges",
            host = "172.26.67.239",
            port = "5432")

with open(listado.sql) as file:
  sql = file.read()
print sql

cur = conn.cursor()
cur.execute(sql)

result = cur.fetchall()
print result



