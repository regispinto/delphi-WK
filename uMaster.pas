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

  uFunctions, uViaCEP, uMasterFunctions, ClassConnection;

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
    procedure ValidateFields(var Erro: string);
    procedure ThreadExecute;
    procedure ThreadEnd(Sender: TObject);
    procedure DispalyFooter;
  public
    { Public declarations }
  end;

var
  frmMaster: TfrmMaster;

  FConnect: TConnect;
  FMasterClass: TMasterClass;
  LThread: TThread;

implementation

{$R *.dfm}

Uses uDM;

procedure TfrmMaster.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ThreadExecute;
end;

procedure TfrmMaster.FormCreate(Sender: TObject);
begin
  FConnect := DM.FConnect;

  if FConnect.Connection.Connected then
    begin
      FMasterClass := TMasterClass.Create(FConnect);
      FMasterClass.MemTable := FDMemTablePeople;
      FMasterClass.InsertIntoTemporaryTable;
    end;
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
var
  Operation: Integer;
  Erro: string;

begin
  ValidateFields(Erro);

  if Erro = EmptyStr then
  begin
    FMasterClass.NaturePerson := cbxNatureza.ItemIndex;
    FMasterClass.RegistrationDate := dtpDataRegistro.Date;
    FMasterClass.ProcessUpdate;

    if FMasterClass.Erro = EmptyStr then
      ObjectSet;
  end
  else
    Application.MessageBox(PChar(Erro), 'Base de Pessoas', MB_ICONWARNING + MB_OK + MB_SYSTEMMODAL);
end;

procedure TfrmMaster.ValidateFields(var Erro: string);
begin
  if cbxNatureza.ItemIndex = -1 then
  begin
    Erro := 'Favor informar o campo Natureza';
    cbxNatureza.SetFocus;
    Exit;
  end;

  if dbeDocumento.Field.IsNull then
  begin
    Erro := 'Favor informar o campo Documento';
    dbeDocumento.SetFocus;
    Exit;
  end;

  if dbeNome1.Field.IsNull then
  begin
    Erro := 'Favor informar o campo Nome1';
    dbeNome1.SetFocus;
    Exit;
  end;

  if dbeNome2.Field.IsNull then
  begin
    Erro := 'Favor informar o campo Nome2';
    dbeNome2.SetFocus;
    Exit;
  end;

  if dbeCEP.Field.IsNull then
  begin
    Erro := 'Favor informar o campo CEP';
    dbeCEP.SetFocus;
    Exit;
  end;

  if (Length(dbeCEP.Field.AsString) <> 8) then
  begin
    Erro := 'O campo CEP precisa ter exatamente 8 digitos';
    dbeCEP.SetFocus;
    Exit;
  end
  else
  begin
    fViaCep.ConsultarCEP(dbeCEP.Field.AsString);

    if fViaCep.RetornoCEP <> EmptyStr then
    begin
      Erro := fViaCep.RetornoCEP;
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
  ThreadExecute;
end;

procedure TfrmMaster.tmiExcluirClick(Sender: TObject);
begin
  FMasterClass.ProcessDeleteMultipleRecords;
end;

procedure TfrmMaster.ThreadEnd(Sender: TObject);
begin
  if Assigned(TThread(Sender).FatalException) then
    showmessage('Erro de execução ' + Exception(TThread(Sender).FatalException).Message)
  else
  begin
    stbFooter.Panels[0].Text := '';
    tmeThread.Enabled := True;
    pgbProcess.Visible := False;
  end;
end;

procedure TfrmMaster.ThreadExecute;
var
  IdEndereco: Integer;
  Erro: string;

begin
  LThread := TThread.CreateAnonymousThread(procedure
  begin
    tmeThread.Enabled := False;

    // Atualizar a Endereco_Integracao com base nas tabelas Pessoa e Endereco
    FMasterClass.RecordsSearch;

    pgbProcess.Max := FMasterClass.Qry.RecordCount;
    pgbProcess.Visible := True;

    while not FMasterClass.Qry.Eof do
    begin
      SaveLog('uMaster.ThreadExecute - Verificando a integração do CEP: ' +
        FMasterClass.Qry.FieldByName('DsCep').AsString);

      if FMasterClass.Qry.FieldByName('Integrado').IsNull then
      begin
        try
          fViaCep.ConsultarCEP(FMasterClass.Qry.FieldByName('DsCep').AsString);

          Erro := fViaCep.RetornoCEP;

          SaveLog('MasterClassFunctions.ProcessAddressIntergration.FRetornoCEP: ' +
            Erro);

          if Erro = '' then
          begin
            // Validar se Integração Endereço já existe antes de incluir
            IdEndereco := FMasterClass.Qry.FieldByName('IdEndereco').AsInteger;

            FMasterClass.Integration.Search(IdEndereco);
            Erro := FMasterClass.Integration.Erro;

            if (Erro = EmptyStr) and (FMasterClass.Integration.IdEndereco = 0) then
            begin
              FMasterClass.Integration.IdEndereco := IdEndereco;
              FMasterClass.Integration.DsUf := fViaCep.DsUf;
              FMasterClass.Integration.NmCidade := fViaCep.NmCidade;
              FMasterClass.Integration.NmBairro := fViaCep.NmBairro;
              FMasterClass.Integration.NmLogradouro := fViaCep.NmLogradouro;
              FMasterClass.Integration.DsComplemento := fViaCep.DsComplemento;
              FMasterClass.Integration.Insert;

              Erro := FMasterClass.Integration.Erro;
            end;
          end;
        except
          on E:Exception do
              Erro := 'Falha ao pesquisar CEP: ' + FMasterClass.Qry.FieldByName('DsCep').AsString + CR +
                'Erro: ' + e.ToString;
        end;
      end;

      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        pgbProcess.Position := pgbProcess.Position + FMasterClass.Qry.RecNo;

        stbFooter.Panels[0].Text := 'Integrando o endereço do CEP ' +
          FMasterClass.Qry.FieldByName('DsCEP').AsString + '...';
      end);

      FMasterClass.Qry.Next;
    end;
  end);
  LThread.OnTerminate := ThreadEnd;
  LThread.Start;
end;

procedure TfrmMaster.DispalyFooter;
begin
  stbFooter.Panels[1].Text := 'Registro ' + FDMemTablePeople.RecNo.ToString + '/' +
    FDMemTablePeople.RecordCount.ToString;
end;

end.
