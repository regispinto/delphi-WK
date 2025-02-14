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

  uFunctions, uMasterFunctions, ClassConnection, ClassCreateTables, ClassPeople;

type
  TDM = class(TDataModule)
    FDConnection: TFDConnection;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
    FDTransaction: TFDTransaction;

    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    function ValidatePostgreSQL: Boolean;

    procedure StartCreateTabels;
    procedure InitializeApplication;
  public
    { Public declarations }
    FConnect: TConnect;
  end;

var
  DM: TDM;
  FMasterClass: TMasterClass;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  FConnect := TConnect.Create();
  FConnect.Connection := FDConnection;
  FConnect.ObjConnect := FConnect;
  FConnect.DriverID := 'PG';

  FConnect.CreateQry;

  FDPhysPgDriverLink.VendorHome := '.\';

  InitializeApplication;

  if FConnect.Erro <> EmptyStr then
  begin
    Application.MessageBox('Ocorreu um erro de conex�o' + CR +
      'Favor verificar!', 'Abertura', MB_ICONWARNING + MB_OK + MB_SYSTEMMODAL);

    SaveLog('uDM.DataModuleCreate - Erro de conex�o' + CR +
      'Erro: ' + FConnect.Erro);

    Application.Terminate;
  end;
end;

procedure TDM.InitializeApplication;
begin
  if ValidatePostgreSQL then
  begin
    if IniParamsNOTExists then
    begin
      CreateFile('Config.ini');
      CreateIniParams(FConnect.DriverID);
    end;

    FConnect.SetConnectDB;
    FConnect.ActivateConnection;

    if FConnect.Erro = EmptyStr then
    begin
      FConnect.ExistDB;

      if FConnect.Erro <> EmptyStr then
        FConnect.CreateDB;

      FConnect.CreateSchema;

      if FConnect.Connection.Connected then
      begin
        FMasterClass := TMasterClass.Create(FConnect);
        //FMasterClass.ObjConnect := FConnect;
      end;

      StartCreateTabels;
    end;
  end;
end;

procedure TDM.StartCreateTabels;
var
  Table: TTables;
begin
  try
    try
      Table := TTables.Create(FMasterClass);
      //Table.ObjConnect := FMasterClass.ObjConnect;
      Table.SetConnection;
      Table.CreateDBTables;
    Except
      on E:Exception do
        raise Exception.Create('Ocorreu um erro ' + CR + e.ToString);
    end;
  finally
    FreeAndNil(Table);
  end;
end;

function TDM.ValidatePostgreSQL: Boolean;
var
  LDll,
  Folder: string;

begin
  SaveLog('Validando exist�ncia das DLLs do PostgreSQL');

  Folder := ExtractFilePath(Application.ExeName);
  LDll := Folder + 'lib\' + 'libpq.dll';

  Result := (FConnect.getLibFolder(Folder) and FConnect.getVendorLib(LDll));

  if Result = False then
    FConnect.Erro := 'DLLs do PostgreSQL n�o foram localizadas. ' + 'Favor verificar!';
end;

end.
