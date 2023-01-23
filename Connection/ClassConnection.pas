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

      constructor Create (Connection: TFDConnection);
      destructor Destroy; Override;

      function getLibFolder(Folder: string): Boolean;
      function getVendorLib(Dll: string): Boolean;
      function CreateFolderBD: string;

      procedure SetConnectDB(Connect: TConnect);
      procedure CreateDB(Database: string='');
      procedure CreateSchema;
      procedure ConnectionDB;
      procedure ActivateConnection(Database: string='');

      function ValidateDatabase: Boolean;
   end;

implementation

var
  FConnect: TConnect;
  Qry: TFDQuery;

{ TConnect }

constructor TConnect.Create(Connection: TFDConnection);
begin
  FConnection := Connection;

  Qry := TFDQuery.Create(nil);
  Qry.Connection := FConnection;
end;

destructor TConnect.Destroy;
begin
  FreeAndNil(Qry);
  inherited;
end;

procedure TConnect.SetConnectDB(Connect: TConnect);
begin
  FConnect := Connect;

  FConnection.Connected := False;
  FConnection.Params.Clear;
  FConnection.Params.Add('DriverID=' + Connect.DriverID);

  case AnsiIndexStr(UpperCase(FConnection.DriverName), ['SQLITE', 'MYSQL', 'FB', 'PG']) of
    0: begin
        FDatabase := CreateFolderBD;
        FConnection.Params.Add('OpenMode=' + 'ReadWrite');
       end;

    1: begin
        FServer   := LoadIni('BANCO', 'Server', '127.0.0.1');
        FUser     := LoadIni('BANCO', 'UserName', 'root');
        FPass     := LoadIni('BANCO', 'Password', 'root');
        FPort     := LoadIni('BANCO', 'Port', '3306');
        FDatabase := LoadIni('BANCO', 'Database', 'db_dados');

        FConnection.Params.Add('Server=' + FServer);
        FConnection.Params.Add('user_name=' + FUser);
        FConnection.Params.Add('password=' + FPass);
        FConnection.Params.Add('port=' + FPort);
        FConnection.Params.Add('database=' + FDatabase);
       end;

    2: begin
        FServer := LoadIni('BANCO', 'Server', '127.0.0.1');
        FUser   := LoadIni('BANCO', 'UserName', 'SYSDBA');
        FPass   := LoadIni('BANCO', 'Password', 'masterkey');
        FPort   := LoadIni('BANCO', 'Port', '3050');

        FConnection.Params.Add('Server='+ FServer);
        FConnection.Params.Add('user_name='+ FUser);
        FConnection.Params.Add('password='+ FPass);
        FConnection.Params.Add('port='+ FPort);
        FConnection.Params.Add('database=' + FDatabase);
       end;

    3: begin
        FServer   := LoadIni('BANCO', 'Server', '127.0.0.1');
        FUser     := LoadIni('BANCO', 'UserName', 'postgres');
        FPass     := LoadIni('BANCO', 'Password', '12345678');
        FPort     := LoadIni('BANCO', 'Port', '5432');
        FDatabase := LoadIni('BANCO', 'Database', 'db_pessoas');
        FSchema   := LoadIni('BANCO', 'Schema', 'db_agenda');

        FConnection.Params.Add('Server=' + FServer);
        FConnection.Params.Add('user_name=' + FUser);
        FConnection.Params.Add('password=' + FPass);
        FConnection.Params.Add('port=' + FPort);
        FConnection.Params.Add('database=' + FDatabase);
        FConnection.Params.Add('schema=' + FSchema);
       end;
  end;

  FConnection.LoginPrompt := False;
  FConnection.Connected := True;
  SaveLog('ClassConnection.SetConnectDB -> Parâmetros de conexão com o banco de dados' + CR +
    FConnection.Params[0] + CR +
    FConnection.Params[1] + CR +
    FConnection.Params[2] + CR +
    FConnection.Params[3] + CR +
    FConnection.Params[4] + CR +
    FConnection.Params[5] + CR +
    FConnection.Params[6]) ;
end;

procedure TConnect.ConnectionDB;
var
  LTexto: string;

begin
  try
    ActivateConnection(FConnect.Database);

    Erro := '';
    SaveLog('ClassConnection.ConnectionDB -> Conexão realizada com sucesso');
  Except
    on E:Exception do
      begin
        lTexto := 'Erro: ' + e.Message + ' Classe: ' + e.ClassName;
        Erro := LTexto;
        SaveLog('ClassConnection.ConnectionDB -> ' + LTexto);
      end;
  end;
end;

function TConnect.ValidateDatabase: Boolean;
begin
  try
    Qry.Close;
    Qry.SQL.Clear;
    Qry.SQL.Add('show databases like ' + QuotedStr(FDatabase));
    SaveLog('ClassConnection.ValidateDatabase: ' + CR + Qry.SQL.Text);
    Qry.Open;

    Result := Qry.RowsAffected > 0;
    FErro := '';
  except
    on e:Exception do
      begin
        FErro := e.ToString;
        Result := False;
      end;
  end;
end;

procedure TConnect.ActivateConnection(Database: string);
begin
  FConnection.Connected := False;
  FConnection.Params.Values['Database'] := Database;
  FConnection.Connected := True;
end;

procedure TConnect.CreateDB(Database: string='');
begin
  try
    ActivateConnection;

    Qry.SQL.Clear;
    Qry.SQL.Add('create database ' + FDatabase);
    Qry.SQL.Add('WITH');
    Qry.SQL.Add('OWNER = postgres');
    Qry.SQL.Add('ENCODING = UTF8');
    Qry.SQL.Add('LC_COLLATE = ' + QuotedStr('Portuguese_Brazil.1252'));
    Qry.SQL.Add('LC_CTYPE = ' + QuotedStr('Portuguese_Brazil.1252'));
    Qry.SQL.Add('TABLESPACE = pg_default');
    Qry.SQL.Add('CONNECTION LIMIT = -1');

    SaveLog('ClassConnection.CreateDatabase: ' + CR + Qry.SQL.Text);

    Qry.Prepare;
    Qry.ExecSQL;

    FErro := '';

    SaveLog('ClassConnection.CreateDatabase: ' + CR + 'Banco de dados ' + FDatabase + ' criado com sucesso');
  except
    on e:Exception do
      begin
        FErro := 'Erro ao criar o banco de dados ' + FDatabase + CR +
          'Erro: ' + CR + e.ToString;
        SaveLog('ClassConnection.CreateDatabase: ' + CR + FErro);
      end;
  end;
end;

procedure TConnect.CreateSchema;
begin
  try
    ActivateConnection(FConnect.Database);

    Qry.SQL.Clear;
    Qry.SQL.Add('create schema if not exists ' + SCHEMA);

    SaveLog('ClassConnection.CreateSchema: ' + CR + Qry.SQL.Text);

    Qry.Prepare;
    Qry.ExecSQL;

    FErro := '';

    SaveLog('ClassConnection.CreateSchema: ' + CR + 'Schema ' + SCHEMA + ' criado com sucesso');
  except
    on e:Exception do
      begin
        FErro := 'Erro ao criar o schema ' + FDatabase + CR +
          'Erro: ' + CR + e.ToString;
        SaveLog('ClassConnection.CreateSchema: ' + CR + FErro);
      end;
  end;
end;

function TConnect.getLibFolder(Folder: string): Boolean;
begin
  Result := True;

  if not DirectoryExists(Folder) then
    begin
      ShowMessage('Pasta ' + Folder + ' não localizada' +#13+ 'Favor verificar!');
      Result := False;
    end;
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

function TConnect.getVendorLib(Dll: String): Boolean;
begin
  Result := True;

  if not (FileExists(Dll)) then
    begin
      ShowMessage('Arquivo ' + Dll + ' não localizada.' +#13+ 'Favor verificar!');
      Result := False;
    end;
end;

end.
