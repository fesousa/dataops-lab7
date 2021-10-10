-- apontar para vacinas_database
USE vacinas_database;

-- remover tabela vacinas_dynamo, caso exista
DROP TABLE IF EXISTS vacinas_dynamo;

-- criar tabela vacinas_dynamo, que aponta para a tabela vacinas no dynamo
CREATE EXTERNAL TABLE vacinas_dynamo(
    data_aplicacao STRING, 
    quantidade_ac  BIGINT,
    quantidade_rr  BIGINT)
STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler'
LOCATION '/user/data'
TBLPROPERTIES (
    "dynamodb.table.name" = "vacinas_uf_data",
    "dynamodb.column.mapping" = "data_aplicacao:data_aplicacao,quantidade_ac:quantidade_ac,quantidade_rr:quantidade_rr"
);

-- inserir dados de contagem de vacinas por data e UF na tabela do DynamoDB
INSERT OVERWRITE TABLE vacinas_dynamo
select 
    data_aplicacao, 
    IF(uf_list["AC"] is null, 0, uf_list["AC"]) as quantidade_ac,
  IF(uf_list["RR"] is null, 0, uf_list["RR"]) as quantidade_rr  
from (
    select 
        data_aplicacao, 
        str_to_map(concat_ws(',',collect_list(concat_ws(':',uf,cast(quantidade as string)))),',',':') as uf_list
    from (
        select 
            count(1) as quantidade, 
            regexp_replace(estabelecimento_uf, '"',"") as uf,  
            regexp_replace(vacina_dataaplicacao, '"',"") as data_aplicacao 
        from vacinas_input
        group by estabelecimento_uf, vacina_dataaplicacao
    ) x group by data_aplicacao
) y;