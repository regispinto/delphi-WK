unit uMasterFunctions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.StrUtils,
  Data.DB, Vcl.Grids, FireDAC.Comp.Client, IniFiles, Vcl.Samples.Gauges,

  FireDAC.Phys.MySQL,

  uFunctions, uViaCEP, ClassConnection, ClassPeople, ClassIntegrationAddress;

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

        constructor Create(Connect: TConnect);
        destructor Destroy; Override;

        procedure InsertIntoTemporaryTable;
        procedure ProcessUpdate;
        procedure DeleteRecord;
        procedure UpdateData(Operation: Integer);
        procedure ProcessInsertMultipleRecords;
        procedure ProcessDeleteMultipleRecords;
        procedure ProcessDeleteRecord;
        procedure RecordsSearch;
    End;

implementation

{ TMasterClass }

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
end;

destructor TMasterClass.Destroy;
begin
  inherited;
end;

procedure TMasterClass.InsertIntoTemporaryTable;
begin
  RecordsSearch;

  MemTable.Close;
  MemTable.Active := True;

  while NOT Qry.Eof do
  begin
    MemTable.Append;
    MemTable.FieldByName('IdPessoa').AsInteger    := Qry.FieldByName('IdPessoa').AsInteger;
    MemTable.FieldByName('FlNatureza').AsString   := Qry.FieldByName('FlNatureza').AsString;
    MemTable.FieldByName('DsDocumento').AsString  := Qry.FieldByName('DsDocumento').AsString;
    MemTable.FieldByName('NmPrimeiro').AsString   := Qry.FieldByName('NmPrimeiro').AsString;
    MemTable.FieldByName('NmSegundo').AsString    := Qry.FieldByName('NmSegundo').AsString;
    MemTable.FieldByName('DtRegistro').AsDateTime := Qry.FieldByName('DtRegistro').AsDateTime;
    MemTable.FieldByName('IdEndereco').AsInteger  := Qry.FieldByName('IdEndereco').AsInteger;
    MemTable.FieldByName('DsCep').AsString        := Qry.FieldByName('DsCep').AsString;
    MemTable.Post;

    Qry.Next;
  end;
  MemTable.First;
  Qry.Close;
end;

procedure TMasterClass.RecordsSearch;
begin
  try
    Qry.Close;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT ');
    Qry.SQL.Add('p.IdPessoa,');
    Qry.SQL.Add('FlNatureza,');
    Qry.SQL.Add('DsDocumento,');
    Qry.SQL.Add('NmPrimeiro,');
    Qry.SQL.Add('NmSegundo,');
    Qry.SQL.Add('DtRegistro,');
    Qry.SQL.Add('e.IdEndereco,');
    Qry.SQL.Add('DsCEP,');
    Qry.SQL.Add('ei.idendereco Integrado');
    Qry.SQL.Add('FROM ' + FObjConnect.Schema + '.pessoa p');
    Qry.SQL.Add('LEFT JOIN ' + FObjConnect.Schema + '.endereco e ON e.idpessoa = p.idpessoa');
    Qry.SQL.Add('LEFT JOIN ' + FObjConnect.Schema + '.endereco_integracao ei ON ei.idendereco = e.idendereco');
    Qry.SQL.Add('where ei.idendereco is null');
    Qry.SQL.Add('ORDER BY p.idpessoa ASC');
    SaveLog('MasterClass.RecordsSearch: ' + CR + Qry.SQL.Text);

    Qry.Open;
  except
    on E:Exception do
      raise Exception.Create('Erro ao pesquisar base de dados' + CR + e.ToString);
  end;
end;

procedure TMasterClass.ProcessUpdate;
var
  Operation: Integer;
  Erro: string;

begin
  try
    // Default é Inserção
    Operation := 1;

    if MemTable.State in [dsEdit] then
    begin
      People.IdPessoa := MemTable.FieldByName('IdPessoa').AsInteger;
      Address.IdPessoa := People.IdPessoa;
      Address.IdEndereco := MemTable.FieldByName('IdEndereco').AsInteger;

      Operation := 2;
    end;

    MemTable.FieldByName('FlNatureza').AsInteger := FNaturePerson;
    MemTable.FieldByName('DtRegistro').AsDateTime := FRegistrationDate;
  finally
    UpdateData(Operation);

    if MemTable.State in [dsInsert] then
      MemTable.FieldByName('IdPessoa').AsInteger := People.IdPessoa;

    MemTable.Post;
  end;
end;

procedure TMasterClass.UpdateData(Operation: Integer);
var
  Erro: string;

begin
  People.FlNatureza := MemTable.FieldByName('FlNatureza').AsInteger;
  People.DsDocumento := MemTable.FieldByName('DsDocumento').AsString;
  People.NmPrimeiro := MemTable.FieldByName('NmPrimeiro').AsString;
  People.NmSegundo := MemTable.FieldByName('NmSegundo').AsString;
  People.DtRegistro := Trunc(MemTable.FieldByName('DtRegistro').AsDateTime);

  case Operation of
    1: Begin
        People.Insert;
        People.IdPessoa := ReturnID(FObjConnect.Connection, 'db_agenda.pessoa',
          'IdPessoa');
       End;
    2: People.UpDate;
  end;

  Erro := People.Erro;

  if Erro = EmptyStr then
  begin
    Address.DsCEP := MemTable.FieldByName('DsCEP').AsString;

    case Operation of
      1: begin
          Address.IdPessoa := People.IdPessoa;
          Address.Insert;
         end;

      2: Address.UpDate;
    end;

    Erro := Address.Erro;
  end;

  if Erro <> EmptyStr then
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

      UpdateData(1);

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
    // Delete Record da tabela temporária
    if Erro = '' then
      MemTable.Delete
    else
      Application.MessageBox(PChar(Erro), 'Base de Pessoas', MB_ICONWARNING + MB_OK + MB_SYSTEMMODAL);
  End;
end;

end.
