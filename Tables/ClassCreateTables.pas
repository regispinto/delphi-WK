unit ClassCreateTables;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.StrUtils,
  Data.DB, Vcl.Grids, FireDAC.Comp.Client, IniFiles,
  FireDAC.Phys.MySQL,

  uFunctions, ClassPeople, ClassIntegrationAddress, uMasterFunctions;

  type
    //TTables = Class(TMasterClass)
    TTables = Class
      private
      public
        constructor Create(MasterClass: TMasterClass);
        destructor Destroy; Override;

        procedure CreateDBTables;
        procedure GetTables;
        procedure SetConnection;
    End;

implementation

{ TTables }
Var
  FMasterClass: TMasterClass;

constructor TTables.Create(MasterClass: TMasterClass);
begin
  FMasterClass := MasterClass;
end;

destructor TTables.Destroy;
begin
  inherited;
end;

procedure TTables.CreateDBTables;
begin
  GetTables;

  if FMasterClass.ObjConnect.Qry.Locate('table_name', 'pessoa', []) then
    SaveLog('Tables.CreateDBTables: ' + 'Qry.Locate(table_name, pessoa, []) - ' +
      'Tables.CreateDBTables: ' + 'Tabela pessoa já existe')
  else
  begin
    FMasterClass.People.CreateTablePeople;

    if FMasterClass.People.Erro <> EmptyStr then
    begin
      Application.MessageBox(PChar(FMasterClass.People.Erro + '. Favor verificar'),
        'Base de Pessoas', MB_ICONERROR + MB_SYSTEMMODAL);
      Application.Terminate;
    end;
  end;

  if FMasterClass.ObjConnect.Qry.Locate('table_name', 'endereco', []) then
    SaveLog('Tables.CreateDBTables: ' + 'Qry.Locate(table_name, endereco, []) - ' +
      'Tables.CreateDBTables: ' + 'Tabela endereco já existe')
  else
  begin
    FMasterClass.Address.CreateTableAddress;

    if FMasterClass.Address.Erro <> EmptyStr then
    begin
      Application.MessageBox(PChar(FMasterClass.Address.Erro + '. Favor verificar'),
        'Base de Pessoas', MB_ICONERROR + MB_SYSTEMMODAL);
      Application.Terminate;
    end;
  end;

  if FMasterClass.ObjConnect.Qry.Locate('table_name', 'endereco_integracao', []) then
    SaveLog('Tables.CreateDBTables: ' + 'Qry.Locate(table_name, endereco_integracao, []) - ' +
      'Tables.CreateDBTables: ' + 'Tabela endereco_integracao já existe')
  else
  begin
    FMasterClass.Integration.CreateTableIntegrationAddress;

    if FMasterClass.Integration.Erro <> EmptyStr then
    begin
      Application.MessageBox(PChar(FMasterClass.Integration.Erro + '. Favor verificar'),
        'Base de Pessoas', MB_ICONERROR + MB_SYSTEMMODAL);
      Application.Terminate;
    end;
  end;
end;

procedure TTables.GetTables;
begin
  try
    SetConnection;

    with FMasterClass.ObjConnect.Qry do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT table_name FROM information_schema.tables');
      SQL.Add('where table_schema = ' + QuotedStr(FMasterClass.ObjConnect.Schema) + ' and ');
      SQL.Add('table_type = ' + QuotedStr('BASE TABLE'));

      SaveLog('ClassCreateTables.getTables: ' + CR + SQL.Text);

      Open;
    end;
  except
    on E:Exception do
      raise Exception.Create('Ocorreu um erro ' + CR + e.ToString);
  end;
end;

procedure TTables.SetConnection;
begin
  FMasterClass.ObjConnect.Connection.Connected := False;
  //ObjConnect.Database             := ObjConnect.Database;
  FMasterClass.ObjConnect.Connection.Connected := True;
end;

end.
