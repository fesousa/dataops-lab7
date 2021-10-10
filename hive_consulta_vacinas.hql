USE vacinas_database;

DROP TABLE IF EXISTS vacinas_analytics_dados;
CREATE EXTERNAL TABLE vacinas_analytics_dados (
    data_aplicacao STRING, 
    quantidade_ac  BIGINT,
    quantidade_rr  BIGINT)
STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler'
LOCATION '/user/data'
TBLPROPERTIES (
    "dynamodb.table.name" = "vacinas",
    "dynamodb.column.mapping" = "data_aplicacao:data_aplicacao,quantidade_ac:quantidade_ac,quantidade_rr:quantidade_rr");

INSERT OVERWRITE TABLE vacinas_analytics_dados
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