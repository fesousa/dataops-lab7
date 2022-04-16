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


7. Em <img src="images/Imagem11.png" height='25'/> selecione as duas opções disponíveis para importar o catálogo de dados do Glue

<img src="images/Imagem12.png" height='130'/>

8. Va até o final da página e clique em <img src="images/Imagem13.png" height='25'/>

9.	A próximo passo é a configuração do Hardware (Step2: Hardware). 

    9.1. Na seção <img src="images/Imagem14.png" height='25'/> clique nas opções `Spot` na última coluna para os nós `Principal` e `Serviços`. Assim economizaremos com a execução de instâncias EC2 para o cluster EMR.
    A configuração cria 1 nó principal (master) e 2 nós de serviço (core). O nó principal distribui as tarefas e os nós de serviço são responsáveis por executá-las.

    <img src="images/Imagem15.png" height='200'/>

    9.2. Clique em <img src="images/Imagem16.png" height='25'/> no final da página

10.	Na próxima tela (Step 3 – Configurações gerais do cluster), configure o seguinte:

    10.1. Nome do cluster: `ClusterVacinas`

    10.2. Clique em <img src="images/Imagem17.png" height='25'/>

11.	Na próxima tela (Step 4 - Segurança), em <img src="images/Imagem18.png" height='25'/> selecione <img src="images/Imagem19.png" height='25'/>

12.	Clique em <img src="images/Imagem20.png" height='25'/>

13.	 Aguarde até que o cluster seja criado, quando o status estiver mostrando `Aguardando`. Clique em <img src="images/Imagem21.png" height='25'/> no canto superior direito, de vez em quando, para atualizar. O processo pode levar até 20 minutos.

<img src="images/Imagem22.png" height='200'/>

14.	Enquanto o cluster inicia vamos configurar o grupo de segurança para poder acessar a instância principal do cluster EMR a partir de uma conexão SSH no CloudShell

    14.1. Na tela de detalhes do cluster EMR (tela aberta depois que o cluster foi criado) procure pela seção "Segurança e acesso" e identifique a propriedade "“"Grupos de segurança para o Principal"

    <img src="images/Imagem23.png" height='200'/>

    14.2. Clique no link ao lado da propriedade, que começa com sg- para abrir o grupo de segurança (security group)

    14.3. Na nova tela identifique o grupo de segurança com o valor `ElasticMapReduce-master` na coluna `Nome do grupo de segurança`. Clique no checkbox para selecioná-lo

    <img src="images/Imagem24.png" height='200'/>


    14.4. Nas abas da parte inferior, selecione a aba <img src="images/Imagem25.png" height='25'/>

    <img src="images/Imagem26.png" height='200'/>


    14.5. Clique em <img src="images/Imagem27.png" height='25'/>

    14.6. Na nova tela, clique em <img src="images/Imagem28.png" height='25'/>

    14.7. Na nova regra habilite a porta 22 (SSH) com as seguintes configurações:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a. Intervalo de portas: 22

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b. Origem: <img src="images/Imagem29.png" height='25'/>

&nbsp;&nbsp;&nbsp;&nbsp;14.8. Clique novamente em <img src="images/Imagem30.png" height='25'/> para adicionar mais uma regra

&nbsp;&nbsp;&nbsp;&nbsp;14.9. Na nova regra habilite a porta 9443 com as seguintes configurações:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a.	Intervalo de portas: 9443

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b.	Origem: <img src="images/Imagem31.png" height='25'/>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Obs: Habilitando a regra somente para `Meu IP`, será retornado o IP atual da sua re-de. Caso não consiga conectar no Jupyter Notebook nas próximas partes do lab, faça o procedimento de liberar a porta 9443 novamente, para pegar seu novo IP

&nbsp;&nbsp;&nbsp;&nbsp;14.10. Clique em  <img src="images/Imagem32.png" height='25'/>

&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/Imagem33.png" height='180'/>

15.	Volte para o EMR e veja se já está com o status `Aguardando`

<img src="images/Imagem34.png" height='180'/>
 
16.	Para finalizar, conecte na instância utilizando o CloudShell. Siga os passos abaixo, se ficar alguma dúvida consulte o [Laboratório 4](https://github.com/fesousa/dataops-lab4) para mais detalhes

    16.1. Ainda no EMR, copie o endereço da propriedade `DNS público principal`. Deve ser algo parecido com o seguinte: `ec2-52-55-234-193.compute-1.amazonaws.com`

    <img src="images/Imagem35.png" height='180'/>
 
    16.2. No console da AWS acesse ao CloudShell clicando em <img src="images/Imagem36.png" height='25'/> na barra superior

    16.3. Aguarde o terminal ser iniciado e verifique se o arquivo `labsuser.pem` existe executando o comando `ls`

    <img src="images/Imagem37.png" height='150'/>
 
    Caso não tenha o arquivo, veja no [Laboratório 4](https://github.com/fesousa/dataops-lab4)como fazer o upload.

    16.4. Acesso o cluster do EMR via SSH, similar como fez para conectar na instância EC2 do Jenkins. O comando é o seguinte:

    ```bash
    ssh -i labsuser.pem hadoop@<DNS_EMR>
    ```

    Troque `<DNS_EMR>` pelo endereço copiado no passo 16.1

    16.5. Depois de executado o comando, digite `yes` para confirma a conexão

    <img src="images/Imagem38.png" height='200'/>
 
    16.6. Você deverá ver o seguinte no CloudShell

    <img src="images/Imagem39.png" height='200'/>
 






<div class="footer">
    &copy; 2022 Fernando Sousa
    <br/>
    
Last update: 2022-04-03 16:09:11
</div>