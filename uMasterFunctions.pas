unit uMasterFunctions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.StrUtils,
  Data.DB, Vcl.Grids, FireDAC.Comp.Client, IniFiles, Vcl.Samples.Gauges, Vcl.ComCtrls,

  uFunctions, ClasseViaCep, ClassConnection, ClassPeople, ClassIntegrationAddress;

  type
    TRecords = record
      IdPessoa : Integer;
      flNatureza : Integer;
      dsDocuemtno : string;
      nmPrimeiro : string;
      nmSegundo : string;
      dtRegistro : TDate;
      IdEndereco: Integer;
      dsCep: string;
      Integrado: Integer;
  end;

  type
    TMasterClass = Class(TConnect)
      private
        FObjConnect: TConnect;
        FIntegration: TIntegrationAddress;
        FQry: TFDQuery;
        FDataSource: TDataSource;
        FPeople: TPeople;
        FAddress: TAddress;
        FMemTable: TFDMemTable;
        FNaturePerson: Integer;
        FRegistrationDate: TDate;
        FErro: string;
        FObjSender: TObject;
        FProgressBar: TProgressBar;
        FStatusBar: TStatusBar;
        FCEP: TViaCep;

        procedure AddRecords;
        procedure UpDateRecords;
        procedure ThreadEnd(Sender: TObject);
      public
        property ObjConnect: TConnect read FObjConnect write FObjConnect;
        property Qry: TFDQuery read FQry write FQry;
        property DTSource: TDataSource read FDataSource write FDataSource;
        property People: TPeople read FPeople write FPeople;
        property Address: TAddress read FAddress write FAddress;
        property Integration: TIntegrationAddress read FIntegration write FIntegration;
        property MemTable: TFDMemTable read FMemTable write FMemTable;
        property NaturePerson: Integer read FNaturePerson write FNaturePerson;
        property RegistrationDate: TDate read FRegistrationDate write FRegistrationDate;
        property Erro: string read FErro write FErro;
        property ObjSender: TObject read FObjSender write FObjSender;
        property ProgressBar: TProgressBar read FProgressBar write FProgressBar;
        property StatusBar: TStatusBar read FStatusBar write FStatusBar;
        property CEP: TViaCep read FCEP write FCEP;

        constructor Create(Connect: TConnect);
        destructor Destroy; Override;

        procedure InsertIntoTemporaryTable;
        procedure ProcessUpdate;
        procedure DeleteRecord;
        procedure UpdateData;
        procedure ProcessInsertMultipleRecords;
        procedure ProcessDeleteMultipleRecords;
        procedure ProcessDeleteRecord;
        procedure ThreadExecute;
    End;

implementation

{ TMasterClass }

var
  FRecords: Array of TRecords;

constructor TMasterClass.Create(Connect: TConnect);
begin
  FObjConnect := Connect;

  People := TPeople.Create(FObjConnect);
  People.Schema := FObjConnect.Schema;

  Address := TAddress.Create(FObjConnect);
  Address.Schema := FObjConnect.Schema;

  Integration := TIntegrationAddress.Create(FObjConnect);
  Integration.Schema := FObjConnect.Schema;

  Qry := TFDQuery.Create(Nil);
  Qry.Connection := Connect.Connection;

  DTSource := TDataSource.Create(Nil);
  DTSource.DataSet := MemTable;

  FCEP := TViaCep.Create();
end;

destructor TMasterClass.Destroy;
begin
  inherited;
end;

procedure TMasterClass.InsertIntoTemporaryTable;
begin
  MemTable.Close;
  MemTable.Active := True;

  while NOT Qry.Eof do
  begin
    MemTable.Append;
    MemTable.FieldByName('IdPessoa').AsInteger := Qry.FieldByName('IdPessoa').AsInteger;
    MemTable.FieldByName('FlNatureza').AsString := Qry.FieldByName('FlNatureza').AsString;
    MemTable.FieldByName('DsDocumento').AsString := Qry.FieldByName('DsDocumento').AsString;
    MemTable.FieldByName('NmPrimeiro').AsString := Qry.FieldByName('NmPrimeiro').AsString;
    MemTable.FieldByName('NmSegundo').AsString := Qry.FieldByName('NmSegundo').AsString;
    MemTable.FieldByName('DtRegistro').AsDateTime := Qry.FieldByName('DtRegistro').AsDateTime;
    MemTable.FieldByName('IdEndereco').AsInteger := Qry.FieldByName('IdEndereco').AsInteger;
    MemTable.FieldByName('DsCep').AsString := Qry.FieldByName('DsCep').AsString;
    MemTable.FieldByName('Integrado').AsInteger := Qry.FieldByName('Integrado').AsInteger;
    MemTable.Post;

    Qry.Next;
  end;
  MemTable.First;
  Qry.Close;
end;

procedure TMasterClass.ThreadEnd(Sender: TObject);
begin
  begin
    if Assigned(TThread(Sender).FatalException) then
      ShowMessage('Erro de execução... ' +
        Exception(TThread(Sender).FatalException).Message)
    else
    begin
      StatusBar.Panels[0].Text := '';
      ProgressBar.Position := 0;
      ProgressBar.Visible := False;
    end;
  end;
end;

procedure TMasterClass.ThreadExecute;
var
  LThread: TThread;

begin
  LThread := TThread.CreateAnonymousThread(procedure
  var
    Erro: string;
    x: Integer;

  begin
    FProgressBar.Max := Length(FRecords);
    FProgressBar.Visible := True;

    try
      for x := 0 to Pred(Length(FRecords)) do
      begin
        if FRecords[x].Integrado = 0 then
        begin
          FCEP.SearchZipCode(FRecords[x].dsCep);
          Erro := FCEP.ZipCodeError;
          if Erro = EmptyStr then
          begin
            // Validar se Integração Endereço já existe antes de incluir
            Integration.Search(FRecords[x].IdEndereco);
            Erro := Integration.Erro;

            if Erro = EmptyStr then
            begin
              Integration.IdEndereco := FRecords[x].IdEndereco;
              Integration.DsUf := FCEP.Uf;
              Integration.NmCidade := FCEP.Cidade;
              Integration.NmBairro := FCEP.Bairro;
              Integration.NmLogradouro := FCEP.Logradouro;
              Integration.DsComplemento := FCEP.Complemento;
              Integration.Insert;
            end;
          end;
        end;

        TThread.Synchronize(nil, procedure
        begin
          ProgressBar.Position := x;
          StatusBar.Panels[0].Text := 'Integrando o endereço do CEP ' +
            FRecords[x].dsCep + '...';
        end);
      end;
    except
      on E:Exception do
        raise Exception.Create('Erro de integração das tabelas' + CR +
          'Erro: ' + e.ToString);
    end;
  end);

  LThread.OnTerminate := ThreadEnd;
  LThread.Start;
end;

procedure TMasterClass.ProcessUpdate;
begin
  try
    if MemTable.State in [dsEdit] then
    begin
      People.IdPessoa := MemTable.FieldByName('IdPessoa').AsInteger;
      Address.IdPessoa := MemTable.FieldByName('IdPessoa').AsInteger;
      Address.IdEndereco := MemTable.FieldByName('IdEndereco').AsInteger;
    end;

    MemTable.FieldByName('FlNatureza').AsInteger := FNaturePerson;
    MemTable.FieldByName('DtRegistro').AsDateTime := FRegistrationDate;
  finally
    UpdateData;

    if Erro = EmptyStr then
      MemTable.Post;
  end;
end;

procedure TMasterClass.UpdateData;
var
  Erro: string;

begin
  People.FlNatureza := MemTable.FieldByName('FlNatureza').AsInteger;
  People.DsDocumento := MemTable.FieldByName('DsDocumento').AsString;
  People.NmPrimeiro := MemTable.FieldByName('NmPrimeiro').AsString;
  People.NmSegundo := MemTable.FieldByName('NmSegundo').AsString;
  People.DtRegistro := Trunc(MemTable.FieldByName('DtRegistro').AsDateTime);

  Address.DsCEP := MemTable.FieldByName('DsCEP').AsString;

  case MemTable.State of
    dsInsert:
      begin
        People.Insert;
        People.IdPessoa := ReturnID(FObjConnect.Connection, 'db_agenda.pessoa',
          'IdPessoa');

        if People.Erro = EmptyStr then
          begin
            MemTable.FieldByName('IdPessoa').AsInteger := People.IdPessoa;

            Address.IdPessoa := People.IdPessoa;
            Address.Insert;

            if Address.Erro = EmptyStr then
              begin
                MemTable.FieldByName('IdEndereco').AsInteger := ReturnID(
                  FObjConnect.Connection, 'db_agenda.endereco', 'IdEndereco');

                AddRecords;
              end;
          end;
      end;

    dsEdit:
      begin
        People.UpDate;

        if People.Erro = EmptyStr then
          begin
            Address.UpDate;

            UpDateRecords;
          end;
      end;
  end;
  FErro := Erro;
end;

procedure TMasterClass.ProcessInsertMultipleRecords;
var
  x: Integer;
  Ceps: array[0..9] of Integer;

begin
  try
    if Application.MessageBox(PChar('Serão inseridos 10 registros aleatórios' + CR +
      'Confirma?'), 'Base de Pessoas', MB_ICONQUESTION + MB_YESNO + MB_SYSTEMMODAL) = IDNO then
      Exit;

    Ceps[0] := 21645280;
    Ceps[1] := 23060770;
    Ceps[2] := 23520131;
    Ceps[3] := 21650012;
    Ceps[4] := 23093120;
    Ceps[5] := 23080730;
    Ceps[6] := 20780220;
    Ceps[7] := 20220902;
    Ceps[8] := 22775942;
    Ceps[9] := 23585161;

    for x := 0 to 9 do
    begin
      MemTable.Append;
      MemTable.FieldByName('FlNatureza').AsInteger := 1;
      MemTable.FieldByName('DsDocumento').AsString := 'Doc.' + DupeString('0', 5) + x.ToString;
      MemTable.FieldByName('NmPrimeiro').AsString := 'Primeiro Nome De ' + x.ToString;
      MemTable.FieldByName('NmSegundo').AsString := 'Segundo Nome De ' + x.ToString;
      MemTable.FieldByName('DtRegistro').AsDateTime := Trunc(Now);
      MemTable.FieldByName('DsCEP').AsString := Ceps[x].ToString;

      UpdateData;

      MemTable.FieldByName('IdPessoa').AsInteger := People.IdPessoa;
      MemTable.Post;
    end;
  finally
    MemTable.First;
  end;
end;

procedure TMasterClass.ProcessDeleteMultipleRecords;
begin
  if Application.MessageBox('Confirma a exclusão de TODOS os registros',
    'Base de Pessoas', MB_ICONQUESTION + MB_YESNO + MB_SYSTEMMODAL) = IDYES then
  begin
    MemTable.First;
    Try
      while not MemTable.Eof do
        DeleteRecord;
    Finally
      MemTable.First;
    End;
  end;
end;

procedure TMasterClass.ProcessDeleteRecord;
begin
  if Application.MessageBox('Confirma a exclusão do registro atual',
    'Base de Pessoas', MB_ICONQUESTION + MB_YESNO + MB_SYSTEMMODAL) = IDYES then
  begin
    DeleteRecord;
  end;
end;

procedure TMasterClass.DeleteRecord;
begin
  Try
    People.IdPessoa := MemTable.FieldByName('IdPessoa').AsInteger;
    People.Delete;

    Erro := People.Erro;
  Finally
    if Erro = '' then
      MemTable.Delete
    else
      Application.MessageBox(PChar(Erro), 'Base de Pessoas', MB_ICONWARNING + MB_OK + MB_SYSTEMMODAL);
  End;
end;

procedure TMasterClass.AddRecords;
var
  LRecords: TRecords;
  LText: string;
  x: Integer;

begin
  if Erro = EmptyStr then
    begin
      LRecords.IdPessoa := MemTable.FieldByName('IdPessoa').AsInteger;
      LRecords.flNatureza := MemTable.FieldByName('flNatureza').AsInteger;
      LRecords.dsDocuemtno := MemTable.FieldByName('dsDocumento').AsString;
      LRecords.nmPrimeiro := MemTable.FieldByName('nmPrimeiro').AsString;
      LRecords.nmSegundo := MemTable.FieldByName('nmSegundo').AsString;
      LRecords.dtRegistro := Trunc(MemTable.FieldByName('DtRegistro').AsDateTime);
      LRecords.IdEndereco := MemTable.FieldByName('IdEndereco').AsInteger;
      LRecords.dsCep := MemTable.FieldByName('dscep').AsString;
      LRecords.Integrado := MemTable.FieldByName('Integrado').AsInteger;

      x := Length(FRecords) + 1;

      SetLength(FRecords, x);
      FRecords[Pred(x)] := LRecords;

      LText := LText +
        'IdPessoa: ' + LRecords.IdPessoa.ToString + CR +
        'Natureza: ' + LRecords.flNatureza.ToString + CR +
        'DsDocumento: ' + LRecords.dsDocuemtno + CR +
        'NmPrimeiro: ' + LRecords.nmPrimeiro + CR +
        'NmSegundo: ' + LRecords.nmSegundo + CR +
        'DtRegistro: ' + DateToStr(LRecords.dtRegistro) + CR +
        'IdEndereco: ' + LRecords.IdEndereco.ToString + CR +
        'DsCep: ' +LRecords.dsCep + CR +
        'Integrado: ' + LRecords.Integrado.ToString + CR;

      SaveLog('MasterClass.AddRecords: ' + CR + LText);
    end;
end;

procedure TMasterClass.UpDateRecords;
begin

end;

end.
