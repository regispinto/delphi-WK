unit uMaster;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Mask, Data.DB,
  Vcl.DBCtrls, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  StrUtils, Vcl.Menus, Vcl.Samples.Gauges,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Stan.StorageBin, FireDAC.Stan.Async, FireDAC.DApt,

  uFunctions, ClassConnection, uMasterFunctions, ClasseViaCep;

type
  TfrmMaster = class(TForm)
    FDMemTablePeople: TFDMemTable;
    DsMemPeople: TDataSource;
    pnlDados: TPanel;
    stbFooter: TStatusBar;
    dbgDados: TDBGrid;
    pnlOpcoes: TPanel;
    lblNatureza: TLabel;
    lblDocumento: TLabel;
    lblNome1: TLabel;
    lblNome2: TLabel;
    lblCEP: TLabel;
    cbxNatureza: TComboBox;
    btnNovo: TBitBtn;
    btnGravar: TBitBtn;
    btnCancelar: TBitBtn;
    btnEditar: TBitBtn;
    btnExcluir: TBitBtn;
    dbeDocumento: TDBEdit;
    dbeNome1: TDBEdit;
    dbeNome2: TDBEdit;
    FDMemTablePeopleidpessoa: TLargeintField;
    FDMemTablePeopleflnatureza: TSmallintField;
    FDMemTablePeopledsdocumento: TWideStringField;
    FDMemTablePeoplenmprimeiro: TWideStringField;
    FDMemTablePeoplenmsegundo: TWideStringField;
    FDMemTablePeopledtregistro: TDateField;
    FDMemTablePeopledscep: TWideStringField;
    FDMemTablePeopleIdEndereco: TIntegerField;
    dbeCEP: TDBEdit;
    dtpDataRegistro: TDateTimePicker;
    lblDateRegistro: TLabel;
    pmeOpcoes: TPopupMenu;
    tmiInserir: TMenuItem;
    tmiExcluir: TMenuItem;
    N2: TMenuItem;
    tmeThread: TTimer;
    pgbProcess: TProgressBar;
    FDMemTablePeopleIntegrado: TIntegerField;

    procedure FormCreate(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FDMemTablePeopleflnaturezaGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure btnEditarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure dbgDadosKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnExcluirClick(Sender: TObject);
    procedure FDMemTablePeopleAfterScroll(DataSet: TDataSet);
    procedure dbgDadosDblClick(Sender: TObject);
    procedure tmiInserirClick(Sender: TObject);
    procedure pmeOpcoesPopup(Sender: TObject);
    procedure tmiExcluirClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure tmeThreadTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }

    procedure ObjectSet;
    procedure ValidateFields;
    procedure DispalyFooter;
  public
    { Public declarations }
  end;

var
  frmMaster: TfrmMaster;

implementation

{$R *.dfm}

Uses uDM;

procedure TfrmMaster.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FMasterClass.Qry.Destroy;
  FMasterClass.People.Destroy;
  FMasterClass.DTSource.Destroy;
  FMasterClass.Address.Destroy;
end;

procedure TfrmMaster.FormCreate(Sender: TObject);
begin
  FMasterClass.MemTable := FDMemTablePeople;
  FDMemTablePeople.Active := True;
end;

procedure TfrmMaster.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    if FDMemTablePeople.State in [dsBrowse, dsInactive] then
      frmMaster.Close
    else
      btnCancelarClick(Sender);
  end;
end;

procedure TfrmMaster.FormKeyPress(Sender: TObject; var Key: Char);
  Function CurrentField: Boolean;
  begin
    Result := (activeControl is TDBedit) or
      (activeControl is TComboBox) or
      (activeControl is TDateTimePicker) or
      (activeControl is TBitBtn);
  end;

begin
  if (key= #13) and (CurrentField) then
  begin
    Perform(WM_NextDlgCtl, 0, 0);
    key:= #0;
  end;
end;

procedure TfrmMaster.FormShow(Sender: TObject);
begin
  ObjectSet;
end;

procedure TfrmMaster.btnNovoClick(Sender: TObject);
begin
  FDMemTablePeople.Append;
  ObjectSet;
end;

procedure TfrmMaster.btnEditarClick(Sender: TObject);
begin
  FDMemTablePeople.Edit;
  ObjectSet;
end;

procedure TfrmMaster.btnExcluirClick(Sender: TObject);
begin
  FMasterClass.ProcessDeleteRecord;
end;

procedure TfrmMaster.dbgDadosDblClick(Sender: TObject);
begin
  if FDMemTablePeople.IsEmpty then
    Exit;

  btnEditarClick(Sender);
end;

procedure TfrmMaster.dbgDadosKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_INSERT then btnNovoClick(Sender);
  if FDMemTablePeople.RecordCount > 0 then
  begin
    if Key = VK_RETURN then btnEditarClick(Sender);
    if Key = VK_DELETE then btnExcluirClick(Sender);
  end;
end;

procedure TfrmMaster.btnGravarClick(Sender: TObject);
begin
  ValidateFields;

  if FMasterClass.Erro = EmptyStr then
  begin
    FMasterClass.NaturePerson := cbxNatureza.ItemIndex;
    FMasterClass.RegistrationDate := dtpDataRegistro.Date;
    FMasterClass.ProcessUpdate;

    if FMasterClass.Erro = EmptyStr then
      ObjectSet
  end;

  if FMasterClass.Erro <> EmptyStr then
    Application.MessageBox(PChar(FMasterClass.Erro),
      'Base de Pessoas', MB_ICONWARNING + MB_OK + MB_SYSTEMMODAL);
end;

procedure TfrmMaster.ValidateFields;
begin
  FMasterClass.Erro := EmptyStr;

  if cbxNatureza.ItemIndex = -1 then
  begin
    FMasterClass.Erro := 'Favor informar o campo Natureza';
    cbxNatureza.SetFocus;
    Exit;
  end;

  if dbeDocumento.Field.IsNull then
  begin
    FMasterClass.Erro := 'Favor informar o campo Documento';
    dbeDocumento.SetFocus;
    Exit;
  end;

  if dbeNome1.Field.IsNull then
  begin
    FMasterClass.Erro := 'Favor informar o campo Nome1';
    dbeNome1.SetFocus;
    Exit;
  end;

  if dbeNome2.Field.IsNull then
  begin
    FMasterClass.Erro := 'Favor informar o campo Nome2';
    dbeNome2.SetFocus;
    Exit;
  end;

  if dbeCEP.Field.IsNull then
  begin
    FMasterClass.Erro := 'Favor informar o campo CEP';
    dbeCEP.SetFocus;
    Exit;
  end;

  if (Length(dbeCEP.Field.AsString) <> 8) then
  begin
    FMasterClass.Erro := 'O campo CEP precisa ter exatamente 8 digitos';
    dbeCEP.SetFocus;
    Exit;
  end
  else
  begin
    FMasterClass.CEP.SearchZipCode(dbeCEP.Field.AsString);

    if FMasterClass.CEP.ZipCodeError <> EmptyStr then
    begin
      FMasterClass.Erro := FMasterClass.CEP.ZipCodeError;
      dbeCEP.SetFocus;
      Exit;
    end;
  end;
end;

procedure TfrmMaster.btnCancelarClick(Sender: TObject);
begin
  FDMemTablePeople.Cancel;
  ObjectSet;
end;

procedure TfrmMaster.FDMemTablePeopleAfterScroll(DataSet: TDataSet);
begin
  if frmMaster.Visible then
    ObjectSet;
end;

procedure TfrmMaster.FDMemTablePeopleflnaturezaGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if FDMemTablePeople.RecordCount = 0 then
    Exit;

  case Sender.AsInteger of
     0: Text := 'Fisica';
     1: Text := 'Juridica'
  end;
end;

procedure TfrmMaster.ObjectSet;
var
  Caption: string;
  UpDateStatus,
  BrowseStatus,
  RecordsCount,
  OnOff: Boolean;

begin
  Caption := 'Base de Pessoas';

  UpDateStatus := FDMemTablePeople.State in [dsInsert, dsEdit];
  BrowseStatus := FDMemTablePeople.State in [dsBrowse, dsInactive];
  RecordsCount := FDMemTablePeople.RecordCount > 0;

  pnlDados.Enabled := UpDateStatus;
  btnNovo.Enabled := UpDateStatus = False;

  OnOff := (RecordsCount) and (BrowseStatus);

  btnEditar.Enabled := OnOff;
  btnExcluir.Enabled := OnOff;
  btnGravar.Enabled := UpDateStatus;
  btnCancelar.Enabled := UpDateStatus;

  dbgDados.Enabled := UpDateStatus = False;

  if UpDateStatus then
  begin
    pnlDados.Color := clActiveCaption;

    if FDMemTablePeople.State in [dsInsert] then
    begin
      Caption := Caption + ' - [Inclusão]';

      cbxNatureza.ItemIndex := -1;
      dtpDataRegistro.Date := Trunc(Now);
    end;

    if FDMemTablePeople.State in [dsEdit] then
      Caption := Caption + ' - [Alteração]';

    cbxNatureza.SetFocus;
  end
  else
  begin
    pnlDados.Color := clSilver;

    if RecordsCount then
      cbxNatureza.ItemIndex := FDMemTablePeople.FieldByName('FlNatureza').AsInteger;
    dbgDados.SetFocus;
    DispalyFooter;
  end;
  frmMaster.Caption := Caption;
end;

procedure TfrmMaster.pmeOpcoesPopup(Sender: TObject);
begin
  pmeOpcoes.Items[0].Enabled := FDMemTablePeople.RecordCount = 0;
  pmeOpcoes.Items[2].Enabled := FDMemTablePeople.RecordCount > 0;
end;

procedure TfrmMaster.tmiInserirClick(Sender: TObject);
begin
  FMasterClass.ProcessInsertMultipleRecords;
end;

procedure TfrmMaster.tmeThreadTimer(Sender: TObject);
begin
  if FDMemTablePeople.RecordCount > 0 then
  begin
    tmeThread.Enabled := False;

    FMasterClass.ObjSender := frmMaster;
    FMasterClass.ProgressBar := pgbProcess;
    FMasterClass.StatusBar := stbFooter;

    FMasterClass.ThreadExecute;

    tmeThread.Enabled := True;
  end;
end;

procedure TfrmMaster.tmiExcluirClick(Sender: TObject);
begin
  FMasterClass.ProcessDeleteMultipleRecords;
end;

procedure TfrmMaster.DispalyFooter;
begin
  stbFooter.Panels[1].Text := 'Registro ' + FDMemTablePeople.RecNo.ToString + '/' +
    FDMemTablePeople.RecordCount.ToString;
end;

end.
