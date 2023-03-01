unit ClassPeople;

interface

uses
  System.SysUtils, Dialogs, Vcl.Forms, Winapi.Windows,

  FireDAC.Comp.Client,FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.UI, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL,

  uFunctions , ClassConnection;

  type
    TPeople = Class(TConnect)
      private
        FConnect: TConnect;
        FIdPessoa: Integer;
        FFlNatureza: Integer;
        FDsDocumento: string;
        FNmPrimeiro: string;
        FNmSegundo: string;
        FDtRegistro: TDate;
        FQryPeople: TFDQuery;
        FErro: string;

      public
        property Connect: TConnect read FConnect write FConnect;
        property IdPessoa: Integer read FIdPessoa write FIdPessoa;
        property FlNatureza: Integer read FFlNatureza write FFlNatureza;
        property DsDocumento: string read FDsDocumento write FDsDocumento;
        property NmPrimeiro: string read FNmPrimeiro write FNmPrimeiro;
        property NmSegundo: string read FNmSegundo write FNmSegundo;
        property DtRegistro: TDate read FDtRegistro write FDtRegistro;
        property QryPeople: TFDQuery read FQryPeople write FQryPeople;
        property Erro : String read FErro write FErro;

        constructor Create(Connect: TConnect);
        destructor Destroy; Override;

        procedure CreateTablePeople;
        procedure Insert;
        procedure UpDate;
        procedure Search(Where: string='');
        procedure Delete;
    end;

implementation

{ TPeople }

constructor TPeople.Create(Connect: TConnect);
begin
  FConnect := Connect;
end;

destructor TPeople.Destroy;
begin
  inherited;
end;

procedure TPeople.CreateTablePeople;
begin
  try
    FConnect.Connection.StartTransaction;

    with FQryPeople do
    begin
      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE ' + FConnect.Schema + '.pessoa (');
      SQL.Add('idpessoa bigserial NOT NULL, ');
      SQL.Add('flnatureza int2 NOT NULL, ');
      SQL.Add('dsdocumento varchar (20) NOT NULL, ');
      SQL.Add('nmprimeiro varchar(100) NOT NULL, ');
      SQL.Add('nmsegundo varchar(100) NOT NULL, ');
      SQL.Add('dtregistro date NULL, ');
      SQL.Add('CONSTRAINT pessoa_pk PRIMARY KEY (idpessoa))');

      SaveLog('ClassPeople.CreateTablePeople: ' + CR + SQL.Text);

      Prepare;
      ExecSQL;
    end;

    SaveLog('ClassPeople.CreateTablePessoa: Tabela PESSOA criada com sucesso');

    FConnect.Erro := '';

    FConnect.Connection.Commit;
  except
    on e:Exception do begin
      Erro := 'Erro ao criar a tabela PESSOA';
      SaveLog('ClassPeople.CreateTablePessoa: ' + FErro + CR +
        'Erro: ' + e.ToString);

      FConnect.Connection.Rollback;
    end;
  end;
end;

procedure TPeople.Insert;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryPeople do
    begin
      Close;
      SQL.Clear;
      SQL.Add('INSERT INTO ' + FConnect.Schema + '.pessoa');
      SQL.Add('(FlNatureza, DsDocumento, NmPrimeiro, NmSegundo, DtRegistro) ');
      SQL.Add('VALUES ');
      SQL.Add('(:pFlNatureza, :pDsDocumento, :pNmPrimeiro, :pNmSegundo, :pDtRegistro)');

      ParamByName('pFlNatureza').AsInteger := FFlNatureza;
      ParamByName('pDsDocumento').AsString := FDsDocumento;
      ParamByName('pNmPrimeiro').AsString := FNmPrimeiro;
      ParamByName('pNmSegundo').AsString := FNmSegundo;
      ParamByName('pDtRegistro').AsDate := FDtRegistro;

      SaveLog('ClassPeople.Insert: ' + CR + SQL.Text + CR +
        'pFlNatureza: ' + ParamByName('pFlNatureza').AsString + CR +
        'pDsDocumento: ' + ParamByName('pDsDocumento').AsString + CR +
        'pNmPrimeiro: ' + ParamByName('pNmPrimeiro').AsString + CR +
        'pNmSegundo: ' + ParamByName('pNmSegundo').AsString + CR +
        'pDtRegistro: ' + ParamByName('pDtRegistro').AsString);

      Prepare;
      ExecSQL;
    end;

    FConnect.Erro := '';

    FConnect.Connection.Commit;
  except
    on e: Exception do
      begin
        Erro := 'Erro ao inserir PESSOA (' + IntToStr(FIdPessoa) + ')';
        SaveLog('ClassPeople.Insert: ' + Erro + CR + 'Erro: ' + E.Message);
        FConnect.Connection.Rollback;
      end;
  end;
end;

procedure TPeople.Update;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryPeople do
    begin
      Close;
      SQL.Clear;
      SQL.Add('UPDATE ' + FConnect.Schema + '.pessoa');
      SQL.Add('SET FlNatureza = :pFlNatureza, ');
      SQL.Add('DsDocumento = :pDsDocumento, ');
      SQL.Add('NmPrimeiro = :pNmPrimeiro, ');
      SQL.Add('NmSegundo = :pNmSegundo, ');
      SQL.Add('DtRegistro = :pDtRegistro');
      SQL.Add('where IdPessoa = :pIdPessoa');

      ParamByName('pIdPessoa').AsInteger := FIdPessoa;
      ParamByName('pFlNatureza').AsInteger := FlNatureza;
      ParamByName('pDsDocumento').AsString := FDsDocumento;
      ParamByName('pNmPrimeiro').AsString := FNmPrimeiro;
      ParamByName('pNmSegundo').AsString := FNmSegundo;
      ParamByName('pDtRegistro').AsDateTime := FDtRegistro;

      SaveLog('ClassPeople.UpDate: ' + CR + SQL.Text + CR +
        'pIdPessoa: ' + ParamByName('pIdPessoa').AsString + CR +
        'pFlNatureza: ' + ParamByName('pFlNatureza').AsString + CR +
        'pDsDocumento: ' + ParamByName('pDsDocumento').AsString + CR +
        'pNmPrimeiro: ' + ParamByName('pNmPrimeiro').AsString + CR +
        'pNmSegundo: ' + ParamByName('pNmSegundo').AsString + CR +
        'pDtRegistro: ' + ParamByName('pDtRegistro').AsString);

      Prepare;
      ExecSQL;
    end;

    FConnect.Connection.Commit;
  except
    on E:Exception do
      begin
        raise Exception.Create('Erro ao alterar PESSOA' + CR + e.ToString);
        FConnect.Connection.Rollback;
      end;
  end;
end;

procedure TPeople.Search(Where: String='');
begin
  try
    with QryPeople do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT * FROM ' + FConnect.Schema + '.pessoa');

      if not Where.IsEmpty then begin
        SQL.Add('where IdPessoa = :pIdPessoa');
        ParamByName('pIdPessoa').AsString := Where;
      end;

      SaveLog('ClassPeolple.Search: ' + CR + SQL.Text + CR +
        'pIdPessoa: ' + ParamByName('pIdPessoa').AsString);

      Open;

      if RecordCount > 0 then
      begin
        FIdPessoa    := FieldByName('IdPessoa').AsInteger;
        FFlNatureza  := FieldByName('FlNatureza').AsInteger;
        FDsDocumento := FieldByName('DsDocumento').AsString;
        FNmPrimeiro  := FieldByName('NmPrimeiro').AsString;
        FNmSegundo   := FieldByName('FNmSegundo').AsString;
        FDtRegistro  := FieldByName('FNmSegundo').AsDateTime;
        FErro        := '';
      end
      else
        FErro := 'Pessoa não localizada';
    end;
  except
    on E:Exception do
      raise Exception.Create('Erro ao pesquisar PESSOA' + CR + e.ToString);
  end;
end;

procedure TPeople.Delete;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryPeople do
    begin
      Close;
      SQL.Clear;
      SQL.Add('DELETE FROM ' + FConnect.Schema + '.pessoa');
      SQL.Add('where IdPessoa = :pIdPessoa');
      ParamByName('pIdPessoa').AsInteger := FIdPessoa;

      SaveLog('ClassPeople.Delete: ' + CR + SQL.Text + CR +
        'pIdPessoa: ' + ParamByName('pIdPessoa').AsString);

      Prepare;
      ExecSQL;
    end;

    FConnect.Erro := '';

    FConnect.Connection.Commit;
  except
    on e: Exception do
      begin
        Erro := 'Erro ao excluir pessoa (' + IntToStr(FIdPessoa) + ')' + CR +
          'Erro: ' + CR + E.Message;
        QryPeople.Connection.Rollback;
      end;
  end;
end;

end.

