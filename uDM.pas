unit uDM;

interface

uses
  System.SysUtils, System.Classes, StrUtils, Dialogs, Data.DB, Vcl.Forms, Winapi.Windows,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.UI,

  FireDAC.Phys.PGDef, FireDAC.Phys.PG, FireDAC.Phys.PGWrapper,

  uFunctions, ClassConnection, ClassCreateTables, ClassPeople;

type
  TDM = class(TDataModule)
    FDConnection: TFDConnection;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
    FDTransaction: TFDTransaction;

    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    function ValidatePostgre: Boolean;
    procedure StartCreateTabels;
  public
    { Public declarations }
    FConnect: TConnect;

  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  FConnect := TConnect.Create( FDConnection );
  FConnect.DriverID := 'PG';
  FDPhysPgDriverLink.VendorHome := '.\';

  if ValidatePostgre then
  begin
    if IniParamsNOTExists then
    begin
      CreateFile('Config.ini');
      CreateIniParams(FConnect.DriverID);
    end;

    FConnect.SetConnectDB(FConnect);
    FConnect.ExistDB;

    // Se FConnect.ExistDB atribuir valor a FConnect.Erro,
    // significa que o Banco de Dados não existe e deverá ser criado
    if FConnect.Erro <> EmptyStr then
    begin
      FConnect.CreateDB;

      if FConnect.Erro = EmptyStr then
      begin
        FConnect.CreateSchema;

        if FConnect.Erro = EmptyStr then
          StartCreateTabels;
      end;
    end;
  end
  else
  begin
    Application.MessageBox('DLLs relaciondas ao Postgre não foram localizadas' + CR +
      'Favor verificar', 'Base de Pessoas', MB_ICONWARNING + MB_OK + MB_SYSTEMMODAL);
    Application.Terminate;
  end;
end;

procedure TDM.StartCreateTabels;
var
  Table: TTables;
begin
  try
    try
      Table := TTables.Create( FConnect );
      Table.CreateDBTables;
    Except
      on E:Exception do
        raise Exception.Create('Ocorreu um erro ' + CR + e.ToString);
    end;
  finally
    FreeAndNil(Table);
  end;
end;

function TDM.ValidatePostgre: Boolean;
var
  LDll, Folder: string;

begin
  Folder := ExtractFilePath(Application.ExeName);
  LDll := Folder + 'lib\' + 'libpq.dll';

  Result := (FConnect.getLibFolder(Folder) and FConnect.getVendorLib(LDll))
end;

end.
