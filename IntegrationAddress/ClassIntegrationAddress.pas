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
    TAddress = Class
      private
        FConnect    : TFDConnection;
        FDatabase   : string;
        FSchema     : string;
        FIdEndereco : Integer;
        FIdPessoa   : Integer;
        FDsCEP      : string;
        FErro       : string;
      public
        property Connect: TFDConnection read FConnect write FConnect;
        property Database: string read FDatabase write FDatabase;
        property Schema: string read FSchema write FSchema;
        property IdEndereco: Integer read FIdEndereco write FIdEndereco;
        property IdPessoa: Integer read FIdPessoa write FIdPessoa;
        property DsCEP: string read FDsCEP write FDsCEP;
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

Var
  QryAddress: TFDQuery;

constructor TAddress.Create(Connect: TConnect);
begin
  FConnect := Connect.Connection;
  FDatabase := Connect.Database;
  FSchema := Connect.Schema;

  QryAddress := TFDQuery.Create(nil);
  QryAddress.Connection := FConnect;
end;

destructor TAddress.Destroy;
begin
  QryAddress.Destroy;
  inherited;
end;

procedure TAddress.CreateTableAddress;
begin
  try
    FConnect.StartTransaction;

    QryAddress.Close;
    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('CREATE TABLE ' + FSchema + '.endereco (');
    QryAddress.SQL.Add('idendereco bigserial NOT NULL, ');
    QryAddress.SQL.Add('idpessoa int8 NOT NULL, ');
    QryAddress.SQL.Add('dscep varchar(15) NULL, ');
    QryAddress.SQL.Add('CONSTRAINT endereco_pk PRIMARY KEY (idendereco), ');
    QryAddress.SQL.Add('CONSTRAINT endereco_fk_pessoa FOREIGN KEY (idpessoa) REFERENCES ' + FSchema + '.pessoa (idpessoa) ON DELETE cascade); ');
    QryAddress.SQL.Add('CREATE INDEX endereco_idpessoa ON ' + FSchema + '.endereco (idpessoa)');

    SaveLog('ClassAddress.CreateTableAddress: ' + CR + QryAddress.SQL.Text);

    QryAddress.Prepare;
    QryAddress.ExecSQL;

    SaveLog('ClassAddress.CreateTableAddress: Tabela endereco criada com sucesso');

    Erro := '';

    FConnect.Commit;
  except
    on e:Exception do begin
      Erro := 'Erro ao criar a tabela endereco' + CR + 'Erro: ' + e.ToString;
      SaveLog('ClassAddress.CreateTableAddress: ' + CR + Erro);

      FConnect.Rollback;
    end;
  end;
end;

procedure TAddress.Insert;
begin
  try
    FConnect.StartTransaction;

    QryAddress.Close;
    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('INSERT INTO ' + FSchema + '.endereco');
    QryAddress.SQL.Add('(IdPessoa, DsCep) ');
    QryAddress.SQL.Add('VALUES ');
    QryAddress.SQL.Add('(:pIdPessoa, :pDsCep)');

    QryAddress.ParamByName('pIdPessoa').AsInteger := FIdPessoa;
    QryAddress.ParamByName('pDsCep').AsString := FDsCep;

    SaveLog('ClassAddress.Insert: ' + CR + QryAddress.SQL.Text + CR +
      'pIdPessoa: ' + QryAddress.ParamByName('pIdPessoa').AsString + CR +
      'pDsCep: ' + QryAddress.ParamByName('pDsCep').AsString);

    QryAddress.Prepare;
    QryAddress.ExecSQL;

    Erro := '';

    FConnect.Commit;
  except
    on e: Exception do
      begin
        Erro := 'Erro ao inserir endereço (' + IntToStr(FIdEndereco) + ')' + CR +
          'Erro: ' + CR + E.Message;

        FConnect.Rollback;
      end;
  end;
end;

procedure TAddress.UpDate;
begin
  try
    FConnect.StartTransaction;

    QryAddress.Close;
    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('UPDATE ' + FSchema + '.endereco');
    QryAddress.SQL.Add('SET idpessoa = :pIdPessoa,');
    QryAddress.SQL.Add('dscep = :pDsCep');
    QryAddress.SQL.Add('where IdEndereco = :pIdEndereco');
    QryAddress.SQL.Add('and IdPessoa = :pIdPessoa');

    QryAddress.ParamByName('pIdEndereco').AsInteger := FIdEndereco;
    QryAddress.ParamByName('pIdPessoa').AsInteger := FIdPessoa;
    QryAddress.ParamByName('pDsCep').AsString := FDsCep;

    SaveLog('ClassAddress.UpDate: ' + CR + QryAddress.SQL.Text + CR +
      'pIdEndereco: ' + QryAddress.ParamByName('pIdEndereco').AsString + CR +
      'pIdPessoa: ' + QryAddress.ParamByName('pIdPessoa').AsString + CR +
      'pDsCep: ' + QryAddress.ParamByName('pDsCep').AsString);

    QryAddress.Prepare;
    QryAddress.ExecSQL;

    FConnect.Commit;
  except
    on E:Exception do
      begin
        raise Exception.Create('Erro ao alterar endereco' + CR + e.ToString);
        FConnect.Rollback;
      end;
  end;
end;

procedure TAddress.Search(IdEndereco, IdPessoa: Integer);
begin
  try
    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('SELECT * FROM ' + FSchema + '.Endereco');
    QryAddress.SQL.Add('where IdEndereco = :pIdIdEndereco');
    QryAddress.SQL.Add('and IdPessoa = :pIdPessoa');

    QryAddress.ParamByName('pIdEndereco').AsInteger := IdEndereco;
    QryAddress.ParamByName('pIdPessoa').AsInteger := IdPessoa;

    SaveLog('ClassAddress.Search: ' + CR + QryAddress.SQL.Text + CR +
      'pIdEndereco: ' + QryAddress.ParamByName('pIdEndereco').AsString + CR +
      'pIdPessoa: ' + QryAddress.ParamByName('pIdPessoa').AsString);

    QryAddress.Open;

    if QryAddress.RecordCount > 0 then
    begin
      FIdEndereco := QryAddress.FieldByName('IdEndereco').AsInteger;
      FIdPessoa := QryAddress.FieldByName('IdPessoa').AsInteger;
      FDsCep := QryAddress.FieldByName('DsCep').AsString;
      FErro := '';
    end
    else
      FErro := 'Endereço não localizado';
  except
    on E:Exception do
      raise Exception.Create('Erro ao consultar endereço' + CR + e.ToString);
  end;
end;

procedure TAddress.Delete;
begin
  try
    FConnect.StartTransaction;

    QryAddress.Close;
    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('DELETE FROM ' + FSchema + '.endereco');
    QryAddress.SQL.Add('where IdEndereco = :pIdEndereco');
    QryAddress.SQL.Add('and IdPessoa = :pIdPessoa');

    QryAddress.ParamByName('pIdEndereco').AsInteger := IdEndereco;
    QryAddress.ParamByName('pIdPessoa').AsInteger := IdPessoa;

    SaveLog('ClassIntegrationAddress.Delete: ' + CR + QryAddress.SQL.Text + CR +
        'pIdEndereco: ' + QryAddress.ParamByName('pIdEndereco').AsString + CR +
        'pIPessoa: ' + QryAddress.ParamByName('pIdPessoa').AsString);

    QryAddress.Prepare;
    QryAddress.ExecSQL;

    Erro := '';

    FConnect.Commit;
  except
    on e: Exception do
      begin
        Erro := 'Erro ao excluir endereço (' + IntToStr(FIdEndereco) + ')' + CR +
          'Erro: ' + CR + E.Message;

        FConnect.Rollback;
      end;
  end;
end;

{ TIntegrationAddress }

constructor TIntegrationAddress.Create(Connect: TConnect);
begin
  FConnect := Connect.Connection;
  FDatabase := Connect.Database;
  FSchema := Connect.Schema;

  QryAddress := TFDQuery.Create(nil);
  QryAddress.Connection := FConnect;

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
    FConnect.StartTransaction;

    QryAddress.Close;
    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('CREATE TABLE ' + FSchema + '.endereco_integracao (');
    QryAddress.SQL.Add('IdEndereco bigint NOT NULL, ');
    QryAddress.SQL.Add('DsUf varchar(50) NULL, ');
    QryAddress.SQL.Add('NmCidade varchar(100) NULL, ');
    QryAddress.SQL.Add('NmBairro varchar(50) NULL, ');
    QryAddress.SQL.Add('NmLogradouro varchar(100) NULL, ');
    QryAddress.SQL.Add('DsComplemento varchar(100) NULL, ');
    QryAddress.SQL.Add('CONSTRAINT enderecointegracao_pk PRIMARY KEY (idendereco), ');
    QryAddress.SQL.Add('CONSTRAINT enderecointegracao_fk_endereco FOREIGN KEY (IdEndereco) REFERENCES ' + FSchema + '.endereco (IdEndereco) ON DELETE cascade)');

    SaveLog('ClassIntegrationAddress.CreateTableIntegrationAddress: ' + CR + QryAddress.SQL.Text);

    QryAddress.Prepare;
    QryAddress.ExecSQL;

    SaveLog('ClassIntegrationAddress.CreateTableIntegrationAddress: Tabela endereco_integracao criada com sucesso');

    Erro := '';

    FConnect.Commit;
  except
    on e:Exception do begin
      Erro := 'Erro ao criar a tabela endereco_integracao' + CR + 'Erro: ' + e.ToString;
      SaveLog('ClassIntegrationAddress.CreateTableIntegrationAddress: ' + CR + Erro);

      FConnect.Rollback;
    end;
  end;
end;

procedure TIntegrationAddress.Insert;
begin
  try
    FConnect.StartTransaction;

    QryAddress.Close;
    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('INSERT INTO ' + FSchema + '.endereco_integracao');
    QryAddress.SQL.Add('(idendereco, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento) ');
    QryAddress.SQL.Add('VALUES ');
    QryAddress.SQL.Add('(:pIdEndereco, :pDsUf, :pNmCidade, :pNmBairro, :pNmLogradouro, :pDsComplemento)');

    QryAddress.ParamByName('pIdEndereco').AsInteger := FIdEndereco;
    QryAddress.ParamByName('pDsUf').AsString := FDsUf;
    QryAddress.ParamByName('pNmCidade').AsString := FNmCidade;
    QryAddress.ParamByName('pNmBairro').AsString := FNmBairro;
    QryAddress.ParamByName('pNmLogradouro').AsString := FNmLogradouro;
    QryAddress.ParamByName('pDsComplemento').AsString := FDsComplemento;

    SaveLog('ClassIntegrationAddress.Insert: ' + CR + QryAddress.SQL.Text + CR +
      'pIdEndereco: ' + QryAddress.ParamByName('pIdEndereco').AsString + CR +
      'pDsUf: ' + QryAddress.ParamByName('pDsUf').AsString + CR +
      'pNmCidade: ' + QryAddress.ParamByName('pNmCidade').AsString + CR +
      'pNmBairro: ' + QryAddress.ParamByName('pNmBairro').AsString + CR +
      'pNmLogradouro: ' + QryAddress.ParamByName('pNmLogradouro').AsString + CR +
      'pDsComplemento: ' + QryAddress.ParamByName('pDsComplemento').AsString);

    QryAddress.Prepare;
    QryAddress.ExecSQL;

    Erro := '';

    FConnect.Commit;
  except
    on e: Exception do
      Erro := 'Erro ao inserir integração endereço (' + IntToStr(FIdEndereco) + ')' + CR +
        'Erro: ' + CR + E.Message;
  end;
end;

procedure TIntegrationAddress.UpDate;
begin
  try
    FConnect.StartTransaction;

    QryAddress.Close;
    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('UPDATE ' + FSchema + '.endereco_integracao');
    QryAddress.SQL.Add('SET dsuf = :pDsUf,');
    QryAddress.SQL.Add('NmCidade = :pNmCidade,');
    QryAddress.SQL.Add('NmBairro = :pNmBairro,');
    QryAddress.SQL.Add('NmLogradouro = :pNmLogradouro,');
    QryAddress.SQL.Add('DsComplemento = :pComplemento');
    QryAddress.SQL.Add('where IdEndereco = :pIdEndereco');

    SaveLog('ClassAddress.UpDate: ' + CR + QryAddress.SQL.Text + CR +
      'pIdEndereco: ' + QryAddress.ParamByName('pIdEndereco').AsString + CR +
      'pDsUf: ' + QryAddress.ParamByName('pDsUf').AsString + CR +
      'pNmCidade: ' + QryAddress.ParamByName('pNmCidade').AsString + CR +
      'pNmBairro: ' + QryAddress.ParamByName('pNmBairro').AsString + CR +
      'pNmLogradouro: ' + QryAddress.ParamByName('pNmLogradouro').AsString + CR +
      'pDsComplemento: ' + QryAddress.ParamByName('pDsComplemento').AsString);

    QryAddress.ParamByName('pIdEndereco').AsInteger := FIdEndereco;
    QryAddress.ParamByName('pDsUfs').AsString := FDsUf;
    QryAddress.ParamByName('pNmCidade').AsString := FNmCidade;
    QryAddress.ParamByName('pNmBairro').AsString := FNmBairro;
    QryAddress.ParamByName('pNmLogradouro').AsString := FNmLogradouro;
    QryAddress.ParamByName('pDsComplemento').AsString := FDsComplemento;

    QryAddress.Prepare;
    QryAddress.ExecSQL;

    FConnect.Commit;
  except
    on E:Exception do
      begin
        raise Exception.Create('Erro ao alterar endereco' + CR + e.ToString);
        FConnect.Rollback;
      end;
  end;
end;

procedure TIntegrationAddress.Search(IdEndereco: Integer);
begin
  try
    ClearFieldsIntegration;

    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('SELECT * FROM ' + FSchema + '.endereco_integracao');
    QryAddress.SQL.Add('where IdEndereco = :pIdEndereco');
    QryAddress.ParamByName('pIdEndereco').AsInteger := IdEndereco;

    SaveLog('ClassIntegrationAddress.Search: ' + CR + QryAddress.SQL.Text + CR +
      'pIdEndereco: ' + QryAddress.ParamByName('pIdEndereco').AsString);

    QryAddress.Open;

    if QryAddress.RecordCount > 0 then
    begin
      FIdEndereco := QryAddress.FieldByName('IdEndereco').AsInteger;
      FDsUf := QryAddress.FieldByName('DsUf').AsString;
      FNmCidade := QryAddress.FieldByName('NmCidade').AsString;
      FNmBairro := QryAddress.FieldByName('NmBairro').AsString;
      FNmLogradouro := QryAddress.FieldByName('NmLogradouro').AsString;
      FDsComplemento := QryAddress.FieldByName('DsComplemento').AsString;
      Erro := ''
    end;
  except
    on E:Exception do
    begin
      Erro := 'Erro ao consultar endereço' + CR + e.ToString;
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
    FConnect.StartTransaction;

    QryAddress.Close;
    QryAddress.SQL.Clear;
    QryAddress.SQL.Add('DELETE FROM ' + FSchema + '.endereco_integracao');
    QryAddress.SQL.Add('where IdEndereco = :pIdEndereco');

    QryAddress.ParamByName('pIdEndereco').AsInteger := IdEndereco;

    SaveLog('ClassIntegrationAddress.Delete: ' + CR + QryAddress.SQL.Text + CR +
      'pIdEndereco: ' + QryAddress.ParamByName('pIdEndereco').AsString);

    QryAddress.Prepare;
    QryAddress.ExecSQL;

    Erro := '';

    FConnect.Commit;
  except
    on e: Exception do
      begin
        Erro := 'Erro ao excluir endereço integração (' + IntToStr(FIdEndereco) + ')' + CR +
          'Erro: ' + CR + E.ToString;

        FConnect.Rollback;
      end;
  end;
end;

end.

