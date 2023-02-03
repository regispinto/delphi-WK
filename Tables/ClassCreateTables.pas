unit ClassCreateTables;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.StrUtils,
  Data.DB, Vcl.Grids, FireDAC.Comp.Client, IniFiles,
  FireDAC.Phys.MySQL,

  uFunctions, ClassConnection, ClassPeople, ClassIntegrationAddress;

  type
    TTables = Class(TConnect)
      private
        FQry: TFDQuery;

        procedure setConnection;
      public
        property Qry: TFDQuery read FQry write FQry;

        constructor Create(Connection: TConnect);
        destructor Destroy; Override;

        procedure CreateDBTables;
        procedure getTables;
    End;

implementation

{ TTables }

var
  FConnect: TConnect;
  QryTable: TFDQuery;
  People: TPeople;
  Address: TAddress;
  Integration: TIntegrationAddress;

constructor TTables.Create(Connection: TConnect);
begin
  FConnect := Connection;

  setConnection;

  QryTable := TFDQuery.Create(Nil);
  QryTable.Connection := FConnect.Connection;

  People := TPeople.Create(FConnect);
  Address := TAddress.Create(Connection);
  Integration := TIntegrationAddress.Create(Connection);
end;

destructor TTables.Destroy;
begin
  QryTable.Destroy;
  inherited;
end;

procedure TTables.CreateDBTables;
begin
  getTables;

  if QryTable.Locate('table_name', 'pessoa', []) then
  begin
    SaveLog('Tables.CreateDBTables: ' + 'QryTable.Locate(table_name, pessoa, [])');
    SaveLog('Tables.CreateDBTables: ' + 'Tabela pessoa já existe');
  end
  else
  begin
    People.CreateTablePeople;

    if People.Erro  <> EmptyStr then
    begin
      Application.MessageBox(PChar(People.Erro + '. Favor verificar'),
        'Base de Pessoas', MB_ICONERROR + MB_SYSTEMMODAL);
      Application.Terminate;
    end;
  end;
  //
  if QryTable.Locate('table_name', 'endereco', []) then
  begin
    SaveLog('Tables.CreateDBTables: ' + 'QryTable.Locate(table_name, endereco, [])');
    SaveLog('Tables.CreateDBTables: ' + 'Tabela endereco já existe');
  end
  else
  begin
    Address.CreateTableAddress;

    if Address.Erro <> EmptyStr then
    begin
      Application.MessageBox(PChar(Address.Erro + '. Favor verificar'),
        'Base de Pessoas', MB_ICONERROR + MB_SYSTEMMODAL);
      Application.Terminate;
    end;
  end;
  //
  if QryTable.Locate('table_name', 'endereco_integracao', []) then
  begin
    SaveLog('Tables.CreateDBTables: ' + 'QryTable.Locate(table_name, endereco_integracao, [])');
    SaveLog('Tables.CreateDBTables: ' + 'Tabela endereco_integracao já existe');
  end
  else
  begin
    Integration.CreateTableIntegrationAddress;

    if Integration.Erro <> EmptyStr then
    begin
      Application.MessageBox(PChar(Integration.Erro + '. Favor verificar'),
        'Base de Pessoas', MB_ICONERROR + MB_SYSTEMMODAL);
      Application.Terminate;
    end;
  end;
end;

procedure TTables.getTables;
begin
  try
    setConnection;

    QryTable.Close;
    QryTable.SQL.Clear;
    QryTable.SQL.Add('SELECT table_name FROM information_schema.tables');
    QryTable.SQL.Add('where table_schema = ' + QuotedStr(FConnect.Schema) + ' and ');
    QryTable.SQL.Add('table_type = ' + QuotedStr('BASE TABLE'));

    SaveLog('ClassCreateTables.getTables: ' + CR + QryTable.SQL.Text);

    QryTable.Open;
  except
    on E:Exception do
      raise Exception.Create('Ocorreu um erro ' + CR + e.ToString);
  end;
end;

procedure TTables.setConnection;
begin
  FConnect.Connection.Connected := False;
  FConnect.Database := FConnect.Database;
  FConnect.Connection.Connected := True;
end;

end.
