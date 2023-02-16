## 🎯 Desafio Técnico

Considerações:

* O banco e as tabelas são criadas no PostgreSQL em tempo de execução;
* A aplicação gera o arquivo config.ini (pasta da aplicação) com os parâmetros de conexão;
* Também é gerado um arquivo de log (pasta da aplicação) com os scripts para criação do banco/tabelas e outros tipos log que auxiliam depuração do código. 
  Nomenclatura do arquivo de log: 20230123.log, onde 20230123 é a data atual invertida, masi a extensão .log;
  
* Para auxiliar nos testes, implementei um TPopupMenu vinculado ao DbGrid com as opções de popular automaticamente 10 registos na tabela Pessoa
e vicular os mesmos a tabela Endereco, fiz isso apenas para evitar ficar cadastrando registro por registro.
Além dessa opção no TPopupMenu, implementei a opção de excluir todos os registros para poder refazer os testes.

* Tela da aplicação

![image](https://user-images.githubusercontent.com/5474103/214058370-a233dd42-d1ab-4be1-806f-faa245168d5e.png)


* Exibição do TPopupMenu

![image](https://user-images.githubusercontent.com/5474103/214072153-cd79a3d2-5345-4be8-8766-0a78ccda662c.png)

* Formulário no modo inserção

![image](https://user-images.githubusercontent.com/5474103/214072679-5e2e9ea2-c9b8-4931-8c78-e49abdd4a826.png)

