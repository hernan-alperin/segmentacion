# -*- coding: utf-8 -*-
import sys
import csv
import psycopg2
from psycopg2 import errorcodes
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from segmentacion import (
        Lado, ColeccionLados, Manzana, ColeccionManzanas,
        Segmento, ColeccionSegmentos, Segmentacion)

import logging

#  The User Data Access Object handles all interactions with the DB.
class DAO:

    # constructor
    def __init__(self):
        self.database = "censo2020"
        self.user = "segmentador"
        self.password = "rodatnemges"
#       self.host = "172.26.67.239"
#       self.host = "172.26.67.64"
        self.host = "localhost"
        self.port = "5432"

    def get_PG_conection_string(self):
        return ("PG:dbname='%s' user='%s' password='%s'"
                % (self.database, self.user, self.password))

    def conectar(self):
        try:
            self.conn = psycopg2.connect(
                             database=self.database,
                             user=self.user,
                             password=self.password
                             )
            logging.info('conectó a database ' + self.database)
        except psycopg2.Error as e:
            logging.error(str(e))
            raise Exception(e)

    def crear_table(self, nombre, columnas):
        # ver si hacerlo así o con try:
        # cambiando la 1ra linea de la consulta CREATE/INSERT INTO
        try:
            cur = self.conn.cursor()
            sql = "CREATE TABLE " + nombre + "("
            for columna, tipo in columnas:
                sql += " " + columna + " " + tipo + ","
            cur.execute(sql[:-1] + ")")
            self.conn.commit()
            logging.info("creó table " + nombre)
        except psycopg2.Error as e:
            if errorcodes.lookup(e.pgcode) == 'DUPLICATE_TABLE':
                # schema already exists
                logging.info("table " + nombre + " ya existente")
            else:
                logging.error("No puede crear table " + nombre
                              + ", Error " + errorcodes.lookup(e.pgcode))
                raise

    def sql_script(self, sql):
        # to use with many lines like shp2pgsql
        logging.info("va a ejecutar:\n" + sql)
        try:
            self.conectar()
            cur = self.conn.cursor()
        except psycopg2.Error as e:
            raise
        try:
            cur.execute(sql)
            self.conn.commit()
            logging.info("SQL script ejecutado con éxito")
        except psycopg2.Error as e:
            if errorcodes.lookup(e.pgcode) == 'ERROR:UNDEFINED_TABLE':
                logging.info("tabla de conteos NO existe."
                             + " Aún no hay datos cargados.")
            else:
                logging.error(errorcodes.lookup(e.pgcode))
                raise
        return cur

    def get_Radios(self, shape):
        # get all the radios in the shape
        # return a list of tuples (prov, depto, frac, radio)
        sql = (
            "select distinct prov, depto, frac, radio"
            + " from segmentacion.adyacencias"
            + " where shape = '" + shape + "'"
            + " order by prov, depto, frac, radio;")
        cur = self.sql_script(sql)
        ppdddffrr = cur.fetchall()
        return ppdddffrr

    def get_ColeccionManzanas(self, prov, depto, frac, radio):
        sql = (
            "select mza, sum(conteo) from segmentacion.conteos"
            + " where prov = " + str(prov)
            + " and depto = " + str(depto)
            + " and frac = " + str(frac)
            + " and radio = " + str(radio)
            + " group by mza "
            )
        manzanas = ColeccionManzanas()
        cur = self.sql_script(sql)
        conteo_por_manzana = cur.fetchall()
        for mza, conteo in conteo_por_manzana:
            manzanas.append(Manzana(mza, conteo))

        sql = (
            "select mza, mza_ady from segmentacion.adyacencias"
            + " where prov = " + str(prov)
            + " and depto = " + str(depto)
            + " and frac = " + str(frac)
            + " and radio = " + str(radio)
            + " and mza != mza_ady"
            + " group by mza, mza_ady"
            )
        cur = self.sql_script(sql)
        adyacencias = cur.fetchall()

        for mza, mza_ady in adyacencias:
            if not manzanas.manzana(mza):
                manzanas.append(Manzana(mza, 0))
                # one manzana that is not in conteo gets 0 viviendas
            if not manzanas.manzana(mza_ady):
                manzanas.append(Manzana(mza_ady, 0))
            ady = manzanas.manzana(mza_ady)
            manzanas.manzana(mza).adyacentes.append(ady)

        return manzanas

    def get_ColeccionLados(self, prov, depto, frac, radio):
        manzanas = self.get_ColeccionManzanas(prov, depto, frac, radio)
        sql = (
            "select mza, lado, conteo from segmentacion.conteos"
            + " where prov = " + str(prov)
            + " and depto = " + str(depto)
            + " and frac = " + str(frac)
            + " and radio = " + str(radio)
            )
        cur = self.sql_script(sql)
        conteo_por_lado = cur.fetchall()
        lados = ColeccionLados()
        for mza, lado, conteo in conteo_por_lado:
            manzana = manzanas.manzana(mza)
            lado_de_manzana = Lado(lado, manzana, conteo)
            manzana.lados.append(lado_de_manzana)
            lados.append(lado_de_manzana)
            # mza objeto

        sql = (
            "select mza, lado, mza_ady, lado_ady from segmentacion.adyacencias"
            + " where prov = " + str(prov)
            + " and depto = " + str(depto)
            + " and frac = " + str(frac)
            + " and radio = " + str(radio)
            )
        cur = self.sql_script(sql)
        adyacencias = cur.fetchall()

        for mza, lado, mza_ady, lado_ady in adyacencias:
            if not lados.lado(lado, mza):
                manzana = manzanas.manzana(mza)
                lado_de_manzana = Lado(lado, manzana, 0)
                manzana.lados.append(lado_de_manzana)
                lados.append(lado_de_manzana)
                # lado not in conteo gets 0 viviendas
            if not lados.lado(lado_ady, mza_ady):
                manzana_ady =  manzanas.manzana(mza_ady)
                ado_de_manzana = Lado(lado_ady, manzana_ady, 0)
                manzana.lados.append(lado_de_manzana)
                lados.append(lado_de_manzana)
            ady = lados.lado(lado_ady, mza_ady)
            lados.lado(lado, mza).adyacentes.append(ady)

        for mza in manzanas:
            ultimo = max(lado.codigo for lado in mza.lados)
            for lado in mza.lados:
                adys = lado.adyacentes
                if 1 < lado.codigo < ultimo:
                    adys.append(lados.lado(lado.codigo - 1, mza.codigo))
                    adys.append(lados.lado(lado.codigo + 1, mza.codigo))
                if 1 == lado.codigo:
                    adys.append(lados.lado(ultimo, mza.codigo))
                    adys.append(lados.lado(lado.codigo + 1, mza.codigo))
                if lado.codigo == ultimo:
                    adys.append(lados.lado(1, mza.codigo))
                    adys.append(lados.lado(lado.codigo - 1, mza.codigo))
        return lados

    def get_listados_por_csv(self, fileName):
        self.listado = []
        try:
            with open(fileName, "rb") as csvFile:
                reader = csv.DictReader(csvFile)
                try:
                    for line in reader:
                        self.listado.append(line)
                except csv.Error as e:
                    raise Exception('file %s, line %d: %s'
                                    % (fileName, reader.line_num, e))
            logging.info("cargó listado de " + fileName)
        except IOError as e:
            logging.error(str(e))
        return self.listado

    def generar_Adyacencias(self, shpTable):
        # genere o inserte en la tabla segmentacion.adyacencias
        # los datos de eAAAAa (shpTable)
        create = """
            create table segmentacion.adyacencias as
            """
        insert = """
            insert into segmentacion.adyacencias
                    (shape, prov, depto, codloc, frac, radio,
                    mza, lado, mza_ady, lado_ady)
            """
        with_query = """
            delete from segmentacion.adyacencias
                where shape = '""" + shpTable + """'::text;
            with mismo_radio as (
                select '""" + shpTable + """'::text as shape,
                    substr(mzad,1,2)::integer as prov,
                    substr(mzad,3,3)::integer as depto,
                    substr(mzai,6,3)::integer as codloc,
                    substr(mzad,9,2)::integer as frac,
                    substr(mzad,11,2)::integer as radio,
                    substr(mzad,13,3)::integer as mza,
                    ladod as lado,
                    substr(mzai,13,3)::integer as mza_ady,
                    ladoi as lado_ady
                from shapes.""" + shpTable + """
                where substr(mzad,1,12) = substr(mzai,1,12)
                )
            """
        select = """
            select shape, prov, depto, codloc, frac, radio,
                mza, lado, mza_ady, lado_ady
            from mismo_radio
            union
            select shape, prov, depto, codloc,
                frac, radio, mza_ady, lado_ady, mza, lado
            from mismo_radio
            order by prov, depto, frac, radio, mza, lado, mza_ady, lado_ady
            ;
            commit;
            """
        try:
            self.sql_script(with_query + insert + select)
        except psycopg2.Error as e:
            if errorcodes.lookup(e.pgcode) == 'UNDEFINED_TABLE':
                logging.warning(" No existe "
                                + "tabla segmentacion.adyacencias")
                try:
                    self.sql_script(create + with_query + select)
                except psycopg2.Error as e:
                    logging.error(" No existe ni puede crear "
                                  + "tabla segmentacion.adyacencias: "
                                  + ", Error " + errorcodes.lookup(e.pgcode))
                    raise  # TODO: crear Class DBError
            else:
                logging.error(" Error insertando "
                              + "en la tabla segmentacion.adyacencias: "
                              + errorcodes.lookup(e.pgcode))
                raise  # TODO: crear Class DBError

    def generar_Conteos(self, shpTable):
        # genere o inserte en la tabla segmentacion.conteos
        # los datos de eAAAAa (shpTable)
        create = """
            create table segmentacion.conteos as
            """
        insert = """
            delete from segmentacion.conteos
                where shape = '""" + shpTable + """'::text;
            insert into segmentacion.conteos
                    (shape, prov, depto, codloc,
                    frac, radio, mza, lado, conteo)
            """
        select = """
                select '""" + shpTable + """', prov, depto, codloc,
                    frac, radio, mza, lado, conteo
                from (
                    select substr(mzai,1,2)::integer as prov,
                        substr(mzai,3,3)::integer as depto,
                        substr(mzai,6,3)::integer as codloc,
                        substr(mzai,9,2)::integer as frac,
                        substr(mzai,11,2)::integer as radio,
                        substr(mzai,13,3)::integer as mza,
                        ladoi as lado, conteoi as conteo
                    from shapes.""" + shpTable + """
                    where conteoi is not Null
                    union
                        select substr(mzad,1,2)::integer as prov,
                        substr(mzad,3,3)::integer as depto,
                        substr(mzad,6,3)::integer as codloc,
                        substr(mzad,9,2)::integer as frac,
                        substr(mzad,11,2)::integer as radio,
                        substr(mzad,13,3)::integer as mza,
                        ladod as lado, conteod as conteo
                    from shapes.""" + shpTable + """
                    where conteod is not Null
                ) as conteos
                order by prov, depto, codloc, frac, radio, mza, lado
            ;
            commit;
            """
        try:
            self.sql_script(insert + select)
        except psycopg2.Error as e:
            if errorcodes.lookup(e.pgcode) == 'UNDEFINED_TABLE':
                logging.warning(" No existe ni puede crear "
                                + "tabla segmentacion.conteos")
                try:
                    self.sql_script(create + select)
                except psycopg2.Error as e:
                    logging.error(" No existe ni puede crear "
                                  + "tabla segmentacion.conteos: "
                                  + ", Error " + errorcodes.lookup(e.pgcode))
                    raise  # TODO: crear Class DBError
            else:
                logging.error(" Error insertando "
                              + "en la tabla segmentacion.conteos: "
                              + errorcodes.lookup(e.pgcode))
                raise  # TODO: crear Class DBError

    def generar_Listados(self, shpTable):
        # genere o inserte en la tabla segmentacion.listados
        # los datos de eAAAAp (shpTable de puntos)
        create = """
            create table segmentacion.listados as
            """
        insert = """
            insert into segmentacion.listados
                    (shape, id, prov, depto, codloc,
                    frac, radio, mza, lado, nombre, numero, piso, conteo)
            """
        fields2int = """
                    prov::integer, depto::integer, codloc::integer,
                    frac::integer, radio::integer, mza::integer, lado::integer
            """
        select = """
                select '""" + shpTable + """'::text as shape, min(gid) as id,
                    """ + fields2int + """,
                    nombre, numero, piso, count(*) as conteo
                from shapes.""" + shpTable + """
                group by """ + fields2int + """, nombre, numero, piso
                order by """ + fields2int + """, nombre, numero, piso
            ;
            """
        try:
            self.sql_script("delete from segmentacion.listados"
                            + " where shape = '" + shpTable + "'::text;")
            self.sql_script(insert + select)
        except psycopg2.Error as e:
            if errorcodes.lookup(e.pgcode) == 'UNDEFINED_TABLE':
                logging.warning(" No existe ni puede crear "
                                + "tabla segmentacion.listados")
                try:
                    self.sql_script(create + select)
                except psycopg2.Error as e:
                    logging.error(" No existe ni puede crear "
                                  + "tabla segmentacion.listados: "
                                  + ", Error " + errorcodes.lookup(e.pgcode))
                    raise  # TODO: crear Class DBError
            else:
                logging.error(" Error insertando "
                              + "en la tabla segmentacion.listados: "
                              + errorcodes.lookup(e.pgcode))
                raise  # TODO: crear Class DBError

    def grabar_Segmentacion(self, shape, segmentacion, frac, radio):
        try:
            for s, segmento in enumerate(segmentacion):
                for manzana in segmento.manzanas:
                    sql = ("update shapes." + shape
                           + " set segmento = " + str(s + 1)
                           + " where frac::integer = " + str(frac)
                           + " and radio::integer = " + str(radio)
                           + " and mza::integer = " + str(manzana.codigo)
                           + "; "
                           )
                    self.sql_script(sql)
        except Exception as e:
            raise e
