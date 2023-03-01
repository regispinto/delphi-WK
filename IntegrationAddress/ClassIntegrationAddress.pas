unit ClassIntegrationAddress;

interface

uses
  System.SysUtils, Dialogs, Vcl.Forms, Winapi.Windows,

  FireDAC.Comp.Client,FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.UI, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL,

  uFunctions, ClassConnection, ClassPeople;

  type
    TAddress = Class(TConnect)
      private
        FConnect: TConnect;
        FIdEndereco: Integer;
        FIdPessoa: Integer;
        FDsCEP: string;
        FQryAddress: TFDQuery;
        FErro: string;

      public
        property Connect: TConnect read FConnect write FConnect;
        property IdEndereco: Integer read FIdEndereco write FIdEndereco;
        property IdPessoa: Integer read FIdPessoa write FIdPessoa;
        property DsCEP: string read FDsCEP write FDsCEP;
        property QryAddress: TFDQuery read FQryAddress write FQryAddress;
        property Erro : String read FErro write FErro;

        constructor Create(Connect: TConnect);
        destructor Destroy; Override;

        procedure CreateTableAddress;
        procedure Insert;
        procedure UpDate;
        procedure Search(IdEndereco, IdPessoa: Integer);
        procedure Delete;
    end;

    TIntegrationAddress = Class(TAddress)
      private
        FDsUf : string;
        FNmCidade : string;
        FNmBairro : string;
        FNmLogradouro : string;
        FDsComplemento : string;
        FMemTable: TFDMemTable;

        procedure ClearFieldsIntegration;
      public
        property DsUf: string read FDsUf write FDsUf;
        property NmCidade: string read FNmCidade write FNmCidade;
        property NmBairro: string read FNmBairro write FNmBairro;
        property NmLogradouro: string read FNmLogradouro write FNmLogradouro;
        property DsComplemento: string read FDsComplemento write FDsComplemento;
        property MemTable: TFDMemTable read FMemTable write FMemTable;

        constructor Create(Connect: TConnect);
        destructor Destroy; Override;

        procedure CreateTableIntegrationAddress;
        procedure Insert;
        procedure UpDate;
        procedure Search(IdEndereco: Integer);
        procedure Delete;
    End;

implementation

{ TAddress }

constructor TAddress.Create(Connect: TConnect);
begin
  FConnect := Connect;
end;

destructor TAddress.Destroy;
begin
  inherited;
end;

procedure TAddress.CreateTableAddress;
begin
  try
    FConnect.Connection.StartTransaction;

    with FQryAddress do
    begin
      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE ' + FConnect.Schema + '.endereco (');
      SQL.Add('idendereco bigserial NOT NULL, ');
      SQL.Add('idpessoa int8 NOT NULL, ');
      SQL.Add('dscep varchar(15) NULL, ');
      SQL.Add('CONSTRAINT endereco_pk PRIMARY KEY (idendereco), ');
      SQL.Add('CONSTRAINT endereco_fk_pessoa FOREIGN KEY (idpessoa) REFERENCES ' + FConnect.Schema + '.pessoa (idpessoa) ON DELETE cascade); ');
      SQL.Add('CREATE INDEX endereco_idpessoa ON ' + FConnect.Schema + '.endereco (idpessoa)');

      SaveLog('ClassAddress.CreateTableAddress: ' + CR + SQL.Text);

      Prepare;
      ExecSQL;
    end;

    SaveLog('ClassAddress.CreateTableAddress: Tabela endereco criada com sucesso');
    FConnect.Erro := '';
    FConnect.Connection.Commit;
  except
    on e:Exception do begin
      Erro := 'Erro ao criar a tabela endereco';
      SaveLog('ClassAddress.CreateTableAddress: ' + CR + Erro);
      FConnect.Connection.Rollback;
    end;
  end;
end;

procedure TAddress.Insert;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryAddress do
    begin
      Close;
      SQL.Clear;
      SQL.Add('INSERT INTO ' + FConnect.Schema + '.endereco');
      SQL.Add('(IdPessoa, DsCep) ');
      SQL.Add('VALUES ');
      SQL.Add('(:pIdPessoa, :pDsCep)');

      ParamByName('pIdPessoa').AsInteger := FIdPessoa;
      ParamByName('pDsCep').AsString := FDsCep;

      SaveLog('ClassAddress.Insert: ' + CR + SQL.Text + CR +
        'pIdPessoa: ' + ParamByName('pIdPessoa').AsString + CR +
        'pDsCep: ' + ParamByName('pDsCep').AsString);

      Prepare;
      ExecSQL;
    end;

    FConnect.Erro := '';

    FConnect.Connection.Commit;
  except
    on e: Exception do
      begin
        FConnect.Erro := 'Erro ao inserir endereço (' + IntToStr(FIdEndereco) + ')' + CR +
          'Erro: ' + CR + E.Message;
        SaveLog('ClassAddress.Insert;: ' + CR + Erro);
        FConnect.Connection.Rollback;
      end;
  end;
end;

procedure TAddress.UpDate;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryAddress do
    begin
      Close;
      SQL.Clear;
      SQL.Add('UPDATE ' + FConnect.Schema + '.endereco');
      SQL.Add('SET idpessoa = :pIdPessoa,');
      SQL.Add('dscep = :pDsCep');
      SQL.Add('where IdEndereco = :pIdEndereco');
      SQL.Add('and IdPessoa = :pIdPessoa');

      ParamByName('pIdEndereco').AsInteger := FIdEndereco;
      ParamByName('pIdPessoa').AsInteger := FIdPessoa;
      ParamByName('pDsCep').AsString := FDsCep;

      SaveLog('ClassAddress.UpDate: ' + CR + SQL.Text + CR +
        'pIdEndereco: ' + ParamByName('pIdEndereco').AsString + CR +
        'pIdPessoa: ' + ParamByName('pIdPessoa').AsString + CR +
        'pDsCep: ' + ParamByName('pDsCep').AsString);

      Prepare;
      ExecSQL;
    end;

    FConnect.Erro := '';

    FConnect.Connection.Commit;
  except
    on E:Exception do
      begin
        FConnect.Erro := 'Erro ao alterar registro na tabela endereco' + CR + e.ToString;
        SaveLog('ClassAddress.UpDate: ' + CR + Erro);
        FConnect.Connection.Rollback;
        raise Exception.Create(FConnect.Erro);
      end;
  end;
end;

procedure TAddress.Search(IdEndereco, IdPessoa: Integer);
begin
  try
    with QryAddress do
    begin
      SQL.Clear;
      SQL.Add('SELECT * FROM ' + FConnect.Schema + '.Endereco');
      SQL.Add('where IdEndereco = :pIdIdEndereco');
      SQL.Add('and IdPessoa = :pIdPessoa');

      ParamByName('pIdEndereco').AsInteger := IdEndereco;
      ParamByName('pIdPessoa').AsInteger := IdPessoa;

      SaveLog('ClassAddress.Search: ' + CR + SQL.Text + CR +
        'pIdEndereco: ' + ParamByName('pIdEndereco').AsString + CR +
        'pIdPessoa: ' + ParamByName('pIdPessoa').AsString);

      Open;

      if RecordCount > 0 then
      begin
        FIdEndereco := FieldByName('IdEndereco').AsInteger;
        FIdPessoa := FieldByName('IdPessoa').AsInteger;
        FDsCep := FieldByName('DsCep').AsString;

        FConnect.Erro := '';
      end
      else
        FConnect.Erro := 'Endereço não localizado';
    end;
  except
    on E:Exception do
      raise Exception.Create('Erro ao consultar endereço' + CR + e.ToString);
  end;
end;

procedure TAddress.Delete;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryAddress do
    begin
      Close;
      SQL.Clear;
      SQL.Add('DELETE FROM ' + FConnect.Schema + '.endereco');
      SQL.Add('where IdEndereco = :pIdEndereco');
      SQL.Add('and IdPessoa = :pIdPessoa');

      ParamByName('pIdEndereco').AsInteger := IdEndereco;
      ParamByName('pIdPessoa').AsInteger := IdPessoa;

      SaveLog('ClassIntegrationAddress.Delete: ' + CR + SQL.Text + CR +
          'pIdEndereco: ' + ParamByName('pIdEndereco').AsString + CR +
          'pIPessoa: ' + ParamByName('pIdPessoa').AsString);

      Prepare;
      ExecSQL;
    end;

    FConnect.Erro := '';

    FConnect.Connection.Commit;
  except
    on e: Exception do
      begin
        Erro := 'Erro ao excluir endereço (' + IntToStr(FIdEndereco) + ')' + CR +
          'Erro: ' + CR + E.Message;

        FConnect.Connection.Rollback;
      end;
  end;
end;

{ TIntegrationAddress }

constructor TIntegrationAddress.Create(Connect: TConnect);
begin
  FConnect := Connect;
  FQryAddress := FConnect.Qry;

  ClearFieldsIntegration;
end;

destructor TIntegrationAddress.Destroy;
begin
  QryAddress.Destroy;
  inherited;
end;

procedure TIntegrationAddress.CreateTableIntegrationAddress;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryAddress do
    begin
      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE ' + FConnect.Schema + '.endereco_integracao (');
      SQL.Add('IdEndereco bigint NOT NULL, ');
      SQL.Add('DsUf varchar(50) NULL, ');
      SQL.Add('NmCidade varchar(100) NULL, ');
      SQL.Add('NmBairro varchar(50) NULL, ');
      SQL.Add('NmLogradouro varchar(100) NULL, ');
      SQL.Add('DsComplemento varchar(100) NULL, ');
      SQL.Add('CONSTRAINT enderecointegracao_pk PRIMARY KEY (idendereco), ');
      SQL.Add('CONSTRAINT enderecointegracao_fk_endereco FOREIGN KEY (IdEndereco) REFERENCES '
        + FConnect.Schema + '.endereco (IdEndereco) ON DELETE cascade)');

      SaveLog('ClassIntegrationAddress.CreateTableIntegrationAddress: ' + CR +
        SQL.Text);

      Prepare;
      ExecSQL;
    end;

    SaveLog('ClassIntegrationAddress.CreateTableIntegrationAddress: ' +
      'Tabela endereco_integracao criada com sucesso');

    FConnect.Erro := '';

    FConnect.Connection.Commit;
  except
    on e:Exception do begin
      Erro := 'Erro ao criar a tabela endereco_integracao' + CR + 'Erro: ' + e.ToString;
      SaveLog('ClassIntegrationAddress.CreateTableIntegrationAddress: ' + CR + Erro);

      FConnect.Connection.Rollback;
    end;
  end;
end;

procedure TIntegrationAddress.Insert;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryAddress do
    begin
      Close;
      SQL.Clear;
      SQL.Add('INSERT INTO ' + Fconnect.Schema + '.endereco_integracao');
      SQL.Add('(idendereco, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento) ');
      SQL.Add('VALUES ');
      SQL.Add('(:pIdEndereco, :pDsUf, :pNmCidade, :pNmBairro, :pNmLogradouro, :pDsComplemento)');

      ParamByName('pIdEndereco').AsInteger := FIdEndereco;
      ParamByName('pDsUf').AsString := FDsUf;
      ParamByName('pNmCidade').AsString := FNmCidade;
      ParamByName('pNmBairro').AsString := FNmBairro;
      ParamByName('pNmLogradouro').AsString := FNmLogradouro;
      ParamByName('pDsComplemento').AsString := FDsComplemento;

      SaveLog('ClassIntegrationAddress.Insert: ' + CR + SQL.Text + CR +
        'pIdEndereco: ' + ParamByName('pIdEndereco').AsString + CR +
        'pDsUf: ' + ParamByName('pDsUf').AsString + CR +
        'pNmCidade: ' + ParamByName('pNmCidade').AsString + CR +
        'pNmBairro: ' + ParamByName('pNmBairro').AsString + CR +
        'pNmLogradouro: ' + ParamByName('pNmLogradouro').AsString + CR +
        'pDsComplemento: ' + ParamByName('pDsComplemento').AsString);

      Prepare;
      ExecSQL;
    end;

    FConnect.Erro := '';

    FConnect.Connection.Commit;
  except
    on e: Exception do
      Erro := 'Erro ao inserir integração endereço (' + IntToStr(FIdEndereco) + ')' + CR +
        'Erro: ' + CR + E.Message;
  end;
end;

procedure TIntegrationAddress.UpDate;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryAddress do
    begin
      Close;
      SQL.Clear;
      SQL.Add('UPDATE ' + FConnect.Schema + '.endereco_integracao');
      SQL.Add('SET dsuf = :pDsUf,');
      SQL.Add('NmCidade = :pNmCidade,');
      SQL.Add('NmBairro = :pNmBairro,');
      SQL.Add('NmLogradouro = :pNmLogradouro,');
      SQL.Add('DsComplemento = :pComplemento');
      SQL.Add('where IdEndereco = :pIdEndereco');

      SaveLog('ClassAddress.UpDate: ' + CR + SQL.Text + CR +
        'pIdEndereco: ' + ParamByName('pIdEndereco').AsString + CR +
        'pDsUf: ' + ParamByName('pDsUf').AsString + CR +
        'pNmCidade: ' + ParamByName('pNmCidade').AsString + CR +
        'pNmBairro: ' + ParamByName('pNmBairro').AsString + CR +
        'pNmLogradouro: ' + ParamByName('pNmLogradouro').AsString + CR +
        'pDsComplemento: ' + ParamByName('pDsComplemento').AsString);

      ParamByName('pIdEndereco').AsInteger := FIdEndereco;
      ParamByName('pDsUfs').AsString := FDsUf;
      ParamByName('pNmCidade').AsString := FNmCidade;
      ParamByName('pNmBairro').AsString := FNmBairro;
      ParamByName('pNmLogradouro').AsString := FNmLogradouro;
      ParamByName('pDsComplemento').AsString := FDsComplemento;

      Prepare;
      ExecSQL;

      FConnect.Connection.Commit;
    end;
  except
    on E:Exception do
      begin
        raise Exception.Create('Erro ao alterar endereco' + CR + e.ToString);
        FConnect.Connection.Rollback;
      end;
  end;
end;

procedure TIntegrationAddress.Search(IdEndereco: Integer);
begin
  try
    ClearFieldsIntegration;

    with QryAddress do
    begin
      SQL.Clear;
      SQL.Add('SELECT * FROM ' + FConnect.Schema + '.endereco_integracao');
      SQL.Add('where IdEndereco = :pIdEndereco');
      ParamByName('pIdEndereco').AsInteger := IdEndereco;

      SaveLog('ClassIntegrationAddress.Search: ' + CR + SQL.Text + CR +
        'pIdEndereco: ' + ParamByName('pIdEndereco').AsString);

      Open;

      if RecordCount > 0 then
      begin
        FIdEndereco := FieldByName('IdEndereco').AsInteger;
        FDsUf := FieldByName('DsUf').AsString;
        FNmCidade := FieldByName('NmCidade').AsString;
        FNmBairro := FieldByName('NmBairro').AsString;
        FNmLogradouro := FieldByName('NmLogradouro').AsString;
        FDsComplemento := FieldByName('DsComplemento').AsString;

        FConnect.Erro := ''
      end;
    end;
  except
    on E:Exception do
    begin
      FConnect.Erro := 'Erro ao consultar endereço' + CR + e.ToString;

      SaveLog('ClassIntegrationAddress.Search: Erro: ' + CR + Erro);
    end;
  end;
end;

procedure TIntegrationAddress.ClearFieldsIntegration;
begin
  FIdEndereco := 0;
  FDsUf := EmptyStr;
  FNmCidade := EmptyStr;
  FNmBairro := EmptyStr;
  FNmLogradouro := EmptyStr;
  FDsComplemento := EmptyStr;
  Erro := EmptyStr;
end;

procedure TIntegrationAddress.Delete;
begin
  try
    FConnect.Connection.StartTransaction;

    with QryAddress do
    begin
      Close;
      SQL.Clear;
      SQL.Add('DELETE FROM ' + FConnect.Schema + '.endereco_integracao');
      SQL.Add('where IdEndereco = :pIdEndereco');

      ParamByName('pIdEndereco').AsInteger := IdEndereco;

      SaveLog('ClassIntegrationAddress.Delete: ' + CR + SQL.Text + CR +
        'pIdEndereco: ' + ParamByName('pIdEndereco').AsString);

      Prepare;
      ExecSQL;
    end;

    FConnect.Erro := '';

    FConnect.Connection.Commit;
  except
    on e: Exception do
      begin
        Erro := 'Erro ao excluir endereço integração (' + IntToStr(FIdEndereco) + ')' + CR +
          'Erro: ' + CR + E.ToString;

        FConnect.Connection.Rollback;
      end;
  end;
end;

end.

