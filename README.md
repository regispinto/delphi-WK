## 🎯 Teste técnico WK 

Considerações:

* O banco e as tabelas são criadas no Postgre em tempo de execução;
* A aplicação gera o arquivo config.ini (pasta da aplicação) com os parâmetros de conexão;
* Também é gerado um arquivo de log (pasta da aplicação) com os scripts de banco e outros tipos log que auxiliam depuração do código;
  Exemplo : 20230123.log
* Para auxiliar nos meus tests, implementei um TPopupMenu vinculado ao DbGrid, com as opções de popular automaticamente 10 registos na tabela Pessoa
e vicular os mesmos a tabela Endereco, fiz isso apenas para evitar ficar cadastrando registro por registro.
Além dessa opção no TPopupMenu, implementei a opção de excluir todos os registros para refazer os testes.

