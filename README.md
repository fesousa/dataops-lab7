# DataOps - Laboratório 7

Processmento e Análise de Dados com Amazon EMR

As instruções do laboratório estão em português. Para alterar o idioma, procure a opção na barra inferior do console AWS.


## Objetivos

* Utilizar AWS EMR para ler um arquivo do S3

* Utilizar Apache Hive para fazer consulta nos dados

* Exportar dados para DynamoDB





## Arquitetura da solução

<img src="images/Imagem1.png" width='100%'/>


## Criar um cluster EMR

Amazon EMR é o serviço da AWS que provisiona Hadoop MapReduce e outras soluções de análise de dados em clusters de instâncias AWS. Vamos provisionar um cluster EMR com um nó Principal, que controla as execuções, e dois nós de Serviço, que realmente executam as tarefas.

1. Procure na barra superior pelo serviço `EMR` e clique no serviço para abrir

2.	No menu ao lado esquerdo clique em <img src="images/Imagem2.png" height='25'/>

3.	Clique no botão <img src="images/Imagem3.png" height='25'/> que aparece na parte superior para iniciar a criação de um novo cluster EMR

4.	Na tela de criação do cluster, clique no link <img src="images/Imagem4.png" height='25'/>

5.	O primeiro passo é configurar os softwares (Step 1: Software e etapas)

6.	Em <img src="images/Imagem5.png" height='25'/> selecione as opções:

    a. <img src="images/Imagem6.png" height='25'/>	  
    b. <img src="images/Imagem7.png" height='25'/>
    c. <img src="images/Imagem8.png" height='25'/>
    d. <img src="images/Imagem9.png" height='25'/>

Mantenha os que já estavam selecionados (Hadoop, Hive, Hue e Pig). Pode ser que a versão seja diferente

<img src="images/Imagem10.png" height='200'/>


<div class="footer">
    &copy; 2022 Fernando Sousa
    <br/>
    
Last update: 2022-04-03 16:09:11
</div>