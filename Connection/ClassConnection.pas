unit ClassConnection;

interface

uses
    IniFiles, SysUtils, Forms, Dialogs, StrUtils, Data.DB, System.Classes,

    FireDAC.Comp.Client,
    FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Def,
    FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.Param, FireDAC.Stan.ExprFuncs,
    FireDAC.Phys, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
    FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.UI.Intf, FireDAC.Phys.Intf,

    FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL,

    FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLiteWrapper.Stat,

    FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Phys.IBWrapper,

    FireDAC.Phys.PGDef, FireDAC.Phys.PG, FireDAC.Phys.PGWrapper,

    uFunctions;

type
   TConnect = class
   private
      FConnection: TFDConnection;
      FObjConnect: TConnect;
      FQry: TFDQuery;
      FPath: string;
      FFileName: string;
      FServer: string;
      FPort: string;
      FDatabase: string;
      FSchema: string;
      FPass: string;
      FUser: string;
      FDriver: string;
      FDriverID: string;
      FOpenMode: string;
      FSection: string;
      FErro: string;
      FLib: string;

   public
      property Connection: TFDConnection read FConnection write FConnection;
      property ObjConnect: TConnect read FObjConnect write FObjConnect;
      property Qry: TFDQuery read FQry write FQry;
      property Path: string read FPath write FPath;
      property FileName: string read FFileName write FFileName;
      property Server: string read FServer write FServer;
      property Port: string read FPort write FPort;
      property Database: string read FDatabase write FDatabase;
      property Schema: string read FSchema write FSchema;
      property Pass: string read FPass write FPass;
      property User: string read FUser write FUser;
      property Driver: string read FDriver write FDriver;
      property DriverID: string read FDriverID write FDriverID;
      property OpenMode: string read FOpenMode write FOpenMode;
      property Section: string read FSection write FSection;
      property Erro: string read FErro write FErro;
      property Lib: string read Flib write Flib;

      constructor Create();
      destructor Destroy; Override;

      function GetLibFolder(Folder: string): Boolean;
      function GetVendorLib(Dll: string): Boolean;
      function CreateFolderBD: string;

      procedure SetConnectDB;
      procedure ExistDB;
      procedure CreateDB(Database: string='');
      procedure CreateSchema;
      procedure ActivateConnection(Database: string='');
      procedure CreateQry;
   end;

implementation

{ TConnect }

constructor TConnect.Create();
begin
end;

destructor TConnect.Destroy;
begin
  inherited;
end;

procedure TConnect.CreateQry;
begin
  Qry := TFDQuery.Create(nil);
  Qry.Connection := FConnection;
end;

procedure TConnect.SetConnectDB;
begin
  FConnection.Connected := False;
  FConnection.Params.Clear;
  FConnection.Params.Add('DriverID=' + FObjConnect.DriverID);

  case AnsiIndexStr(UpperCase(FConnection.DriverName), ['SQLITE', 'MYSQL', 'FB', 'PG']) of
    0: begin
        FDatabase := CreateFolderBD;
        FConnection.Params.Add('OpenMode=' + 'ReadWrite');
       end;

    1: begin
        FServer   := LoadIni('BANCO', 'server', '127.0.0.1');
        FUser     := LoadIni('BANCO', 'user_name', 'root');
        FPass     := LoadIni('BANCO', 'password', 'root');
        FPort     := LoadIni('BANCO', 'port', '3306');
        FDatabase := LoadIni('BANCO', 'database', 'db_dados');

        FConnection.Params.Add('server=' + FServer);
        FConnection.Params.Add('user_name=' + FUser);
        FConnection.Params.Add('password=' + FPass);
        FConnection.Params.Add('port=' + FPort);
        FConnection.Params.Add('database=' + FDatabase);
       end;

    2: begin
        FServer := LoadIni('BANCO', 'server', '127.0.0.1');
        FUser   := LoadIni('BANCO', 'user_name', 'SYSDBA');
        FPass   := LoadIni('BANCO', 'password', 'masterkey');
        FPort   := LoadIni('BANCO', 'port', '3050');

        FConnection.Params.Add('server='+ FServer);
        FConnection.Params.Add('user_name='+ FUser);
        FConnection.Params.Add('password='+ FPass);
        FConnection.Params.Add('port='+ FPort);
        FConnection.Params.Add('database=' + FDatabase);
       end;

    3: begin
        FServer   := LoadIni('BANCO', 'server', '127.0.0.1');
        FUser     := LoadIni('BANCO', 'user_name', 'postgres');
        FPass     := LoadIni('BANCO', 'password', '12345678');
        FPort     := LoadIni('BANCO', 'port', '5432');
        FDatabase := LoadIni('BANCO', 'database', 'db_pessoas');
        FSchema   := 'db_agenda';

        FConnection.Params.Add('server=' + FServer);
        FConnection.Params.Add('user_name=' + FUser);
        FConnection.Params.Add('password=' + FPass);
        FConnection.Params.Add('port=' + FPort);
        FConnection.Params.Add('database=' + FDatabase);
        FConnection.Params.Add('schema=' + FSchema);
       end;
  end;

  FConnection.LoginPrompt := False;

  SaveLog('ClassConnection.SetConnectDB -> Par�metros de conex�o com o banco de dados' + CR +
    FConnection.Params[0] + CR +
    FConnection.Params[1] + CR +
    FConnection.Params[2] + CR +
    FConnection.Params[3] + CR +
    FConnection.Params[4] + CR +
    FConnection.Params[5] + CR +
    FConnection.Params[6]) ;
end;

procedure TConnect.ActivateConnection(Database: string);
begin
  try
    FConnection.Connected := False;
    FConnection.Params.Values['Database'] := Database;
    FConnection.Connected := True;
  except
    on E : EPgNativeException do
      begin
        if AnsiContainsStr(e.Message, 'database "db_pessoas" does not exist') then
        begin
          FObjConnect.Erro := EmptyStr;
          SaveLog('ClassConnection.ValidateDB - ' + e.Message);
        end;

        if AnsiContainsStr(e.Message, 'password authentication failed for user') then
        begin
          FObjConnect.Erro := e.Message + ' ' + e.ClassName;
          SaveLog('ClassConnection.ValidateDB - ' + FObjConnect.Erro);
        end;
      end;
    on E : Exception do
      begin
        FObjConnect.Erro := 'Erro: ' + e.Message + ' Classe: ' + e.ClassName;
        SaveLog('ClassConnection.ValidateDB - ' + FObjConnect.Erro);
      end;
  end;
end;

procedure TConnect.ExistDB;
begin
  try
    Qry.Close;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT datname FROM pg_database');
    Qry.SQL.Add('WHERE datname LIKE ' + QuotedStr(Database));

    SaveLog('ClassConnection.ExistDB: ' + CR + Qry.SQL.Text);

    Qry.Open;

    if Qry.RowsAffected = 0 then
    begin
      FObjConnect.Erro := 'Banco de dados ' + Database + ' n�o existe, deve ser criado...';
      SaveLog('ClassConnection.ExistDB - ' + FObjConnect.Erro);
    end
    else
    begin
      FObjConnect.Erro := '';
      SaveLog('ClassConnection.ExistDB - Banco de dados ' + Database + ' j� existe');
    end;
  except
    on e:Exception do
      FObjConnect.Erro := e.ToString;
  end;
end;

procedure TConnect.CreateDB(Database: string='');
begin
  SaveLog('ClassConnection.CreateDB - Criando Banco de Dados ' + FDatabase + '...');

  ActivateConnection;

  if FObjConnect.Erro <> EmptyStr then
  begin
    try
      Qry.SQL.Clear;
      Qry.SQL.Add('CREATE DATABASE ' + FDatabase);
      Qry.SQL.Add('WITH');
      Qry.SQL.Add('OWNER = postgres');
      Qry.SQL.Add('ENCODING = UTF8');
      Qry.SQL.Add('LC_COLLATE = ' + QuotedStr('Portuguese_Brazil.1252'));
      Qry.SQL.Add('LC_CTYPE = ' + QuotedStr('Portuguese_Brazil.1252'));
      Qry.SQL.Add('TABLESPACE = pg_default');
      Qry.SQL.Add('CONNECTION LIMIT = -1');

      SaveLog('ClassConnection.CreateDB: ' + CR + Qry.SQL.Text);

      Qry.Prepare;
      Qry.ExecSQL;

      FErro := '';

      SaveLog('ClassConnection.CreateDB: Banco de dados ' + FDatabase +
        ' criado com sucesso');
    except
      on e:Exception do
        begin
          FErro := 'Erro ao criar o banco de dados ' + FDatabase + CR +
            'Erro: ' + CR + e.ToString;
          SaveLog('ClassConnection.CreateDatabase: ' + CR + FErro);
        end;
    end;
  end;
end;

procedure TConnect.CreateSchema;
begin
  SaveLog('ClassConnection.CreateSchema - Verificando se Schema ' + SCHEMA + ' existe...');

  ActivateConnection(FObjConnect.Database);

  if FObjConnect.Erro = EmptyStr then
  begin
    try
      Qry.SQL.Clear;
      Qry.SQL.Add('CREATE SCHEMA IF NOT EXISTS ' + SCHEMA);

      SaveLog('ClassConnection.CreateSchema: ' + Qry.SQL.Text);

      Qry.Prepare;
      Qry.ExecSQL;

      FErro := '';
    except
      on e:Exception do
        FErro := 'Erro ao criar o schema ' + FDatabase + CR + 'Erro: ' + e.ToString;
    end;
  end;
end;

function TConnect.GetLibFolder(Folder: string): Boolean;
begin
  Result := DirectoryExists(Folder);
end;

Function TConnect.CreateFolderBD: string;
var
  LPath: String;

begin
  LPath := '\' + FPath;
  CreatePath(LPath);

  LPath := LPath + '\' + FFileName;
  CreateFile(LPath);

  Result := LPath;
end;

function TConnect.GetVendorLib(Dll: String): Boolean;
begin
  Result := FileExists(Dll);
end;

end.
