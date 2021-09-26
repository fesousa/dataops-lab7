import sys
from datetime import datetime

from pyspark.sql import SparkSession
from pyspark.sql.functions import *

if __name__ == "__main__":

    # INICIAR SESSÃO SPARK
    spark = SparkSession\
        .builder\
        .appName("SparkETL")\
        .getOrCreate()

    # LER ARQUIVOS DO S3 ENVIADO COMO PARÃMETRO
    vacinas = spark.read\
                   .option("inferSchema", "true")\
                   .option("header", "true")\
                   .option("sep",";")\
                   .csv(sys.argv[1])    

    # TRANSOFRMAÇÃO DA COLUNA DE DOSE DA VACINA
    vacinas = vacinas.withColumn(
        "dose", when(vacinas.vacina_descricao_dose.contains('1'), '1')
        .when(vacinas.vacina_descricao_dose.contains('2'), '2')
        .otherwise('Única')
    )

    # REMOVER COLUNAS DESNECESSÁRIAS
    # DEIXAR APENAS AS COLUNAS QUE ESTÃO NA LISTA "colunas"
    colunas = [
        "paciente_enumsexobiologico", 
        "estabelecimento_municipio_nome",
        "estabelecimento_uf",  
        "vacina_dataaplicacao", 
        "dose", 
        "vacina_nome"
    ]
    vacinas = vacinas.select([column for column in vacinas.columns if column in colunas])

    # RENOMEAR COLUNAS
    vacinas = vacinas.withColumnRenamed("paciente_enumsexobiologico","sexo")\
                     .withColumnRenamed("estabelecimento_municipio_nome","municipio")\
                     .withColumnRenamed("estabelecimento_uf","uf")\
                     .withColumnRenamed("vacina_dataaplicacao","data_aplicacao")\
                     .withColumnRenamed("vacina_nome","vacina")

    # AGRUPAR E CONTAR REGISTROS
    vacinas = vacinas.groupBy("sexo", "municipio","uf", "data_aplicacao", "vacina").count()
    vacinas = vacinas.withColumnRenamed("count","quantidade")

    vacinas.printSchema()

    print(vacinas.head())

    print("Total number of records: " + str(vacinas.count()))

    # SALVAR NO S3 NO FORMATO PARQUET
    vacinas.write.parquet(sys.argv[2])

# spark-submit spark-etl-vacinas.py s3://dataops-impacta-dados-fernandosousa/input/ s3://dataops-impacta-dados-fernandosousa/output/spark