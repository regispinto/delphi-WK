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

  uFunctions, ClassConnection;

  type
    TPeople = Class(TConnect)
      private
        FConnection  : TFDConnection;
        FDatabase    : string;
        FSchema      : string;
        FIdPessoa    : Integer;
        FFlNatureza  : Integer;
        FDsDocumento : string;
        FNmPrimeiro  : string;
        FNmSegundo   : string;
        FDtRegistro  : TDate;
        FErro        : string;
      public
        property Connection: TFDConnection read FConnection write FConnection;
        property Database: string read FDatabase write FDatabase;
        property Schema: string read FSchema write FSchema;
        property IdPessoa: Integer read FIdPessoa write FIdPessoa;
        property FlNatureza: Integer read FFlNatureza write FFlNatureza;
        property DsDocumento: string read FDsDocumento write FDsDocumento;
        property NmPrimeiro: string read FNmPrimeiro write FNmPrimeiro;
        property NmSegundo: string read FNmSegundo write FNmSegundo;
        property DtRegistro: TDate read FDtRegistro write FDtRegistro;
        property Erro : String read FErro write FErro;

        constructor Create(Connection: TConnect);
        destructor Destroy; Override;

        procedure CreateTablePeople;
        procedure Insert;
        procedure UpDate;
        procedure Search(Where: string='');
        procedure Delete;
    end;

implementation

{ TPeople }

var
  QryPeople: TFDQuery;

constructor TPeople.Create(Connection: TConnect);
begin
  FConnection := Connection.Connection;
  FDatabase := Connection.Database;
  FSchema := Connection.Schema;

  QryPeople := TFDQuery.Create(nil);
  QryPeople.Connection := FConnection;
end;

destructor TPeople.Destroy;
begin
  FreeAndNil(QryPeople);
  inherited;
end;

procedure TPeople.CreateTablePeople;
begin
  try
    FConnection.StartTransaction;

    QryPeople.Close;
    QryPeople.SQL.Clear;
    QryPeople.SQL.Add('CREATE TABLE ' + FSchema + '.pessoa (');
    QryPeople.SQL.Add('idpessoa bigserial NOT NULL, ');
    QryPeople.SQL.Add('flnatureza int2 NOT NULL, ');
    QryPeople.SQL.Add('dsdocumento varchar (20) NOT NULL, ');
    QryPeople.SQL.Add('nmprimeiro varchar(100) NOT NULL, ');
    QryPeople.SQL.Add('nmsegundo varchar(100) NOT NULL, ');
    QryPeople.SQL.Add('dtregistro date NULL, ');
    QryPeople.SQL.Add('CONSTRAINT pessoa_pk PRIMARY KEY (idpessoa))');

    SaveLog('ClassPeople.CreateTablePeople: ' + CR + QryPeople.SQL.Text);

    QryPeople.Prepare;
    QryPeople.ExecSQL;

    SaveLog('ClassPeople.CreateTablePessoa: Tabela pessoa criada com sucesso');

    Erro := '';

    FConnection.Commit;
  except
    on e:Exception do begin
      Erro := 'Erro ao criar a tabela pessoa' + CR + 'Erro: ' + e.ToString;
      SaveLog('ClassPeople.CreateTablePessoa: ' + CR + Erro);

      FConnection.Rollback;
    end;
  end;
end;

procedure TPeople.Insert;
begin
  try
    FConnection.StartTransaction;

    QryPeople.Close;
    QryPeople.SQL.Clear;
    QryPeople.SQL.Add('INSERT INTO ' + FSchema + '.pessoa');
    QryPeople.SQL.Add('(FlNatureza, DsDocumento, NmPrimeiro, NmSegundo, DtRegistro) ');
    QryPeople.SQL.Add('VALUES ');
    QryPeople.SQL.Add('(:pFlNatureza, :pDsDocumento, :pNmPrimeiro, :pNmSegundo, :pDtRegistro)');

    QryPeople.ParamByName('pFlNatureza').AsInteger := FFlNatureza;
    QryPeople.ParamByName('pDsDocumento').AsString := FDsDocumento;
    QryPeople.ParamByName('pNmPrimeiro').AsString := FNmPrimeiro;
    QryPeople.ParamByName('pNmSegundo').AsString := FNmSegundo;
    QryPeople.ParamByName('pDtRegistro').AsDate := FDtRegistro;

    SaveLog('ClassPeople.Insert: ' + CR + QryPeople.SQL.Text + CR +
      'pFlNatureza: ' + QryPeople.ParamByName('pFlNatureza').AsString + CR +
      'pDsDocumento: ' + QryPeople.ParamByName('pDsDocumento').AsString + CR +
      'pNmPrimeiro: ' + QryPeople.ParamByName('pNmPrimeiro').AsString + CR +
      'pNmSegundo: ' + QryPeople.ParamByName('pNmSegundo').AsString + CR +
      'pDtRegistro: ' + QryPeople.ParamByName('pDtRegistro').AsString);

    QryPeople.Prepare;
    QryPeople.ExecSQL;

    Erro := '';

    FConnection.Commit;
  except
    on e: Exception do
      begin
        Erro := 'Erro ao inserir pessoa (' + IntToStr(FIdPessoa) + ')' + CR +
          'Erro: ' + E.Message;

        SaveLog('ClassPeople.Insert: ' + Erro);
        FConnection.Rollback;
      end;
  end;
end;

procedure TPeople.Update;
begin
  try
    FConnection.StartTransaction;

    QryPeople.Close;
    QryPeople.SQL.Clear;
    QryPeople.SQL.Add('UPDATE ' + FSchema + '.pessoa');
    QryPeople.SQL.Add('SET FlNatureza = :pFlNatureza, ');
    QryPeople.SQL.Add('DsDocumento = :pDsDocumento, ');
    QryPeople.SQL.Add('NmPrimeiro = :pNmPrimeiro, ');
    QryPeople.SQL.Add('NmSegundo = :pNmSegundo, ');
    QryPeople.SQL.Add('DtRegistro = :pDtRegistro');
    QryPeople.SQL.Add('where IdPessoa = :pIdPessoa');

    QryPeople.ParamByName('pIdPessoa').AsInteger := FIdPessoa;
    QryPeople.ParamByName('pFlNatureza').AsInteger := FlNatureza;
    QryPeople.ParamByName('pDsDocumento').AsString := FDsDocumento;
    QryPeople.ParamByName('pNmPrimeiro').AsString := FNmPrimeiro;
    QryPeople.ParamByName('pNmSegundo').AsString := FNmSegundo;
    QryPeople.ParamByName('pDtRegistro').AsDateTime := FDtRegistro;

    SaveLog('ClassPeople.UpDate: ' + CR + QryPeople.SQL.Text + CR +
      'pIdPessoa: ' + QryPeople.ParamByName('pIdPessoa').AsString + CR +
      'pFlNatureza: ' + QryPeople.ParamByName('pFlNatureza').AsString + CR +
      'pDsDocumento: ' + QryPeople.ParamByName('pDsDocumento').AsString + CR +
      'pNmPrimeiro: ' + QryPeople.ParamByName('pNmPrimeiro').AsString + CR +
      'pNmSegundo: ' + QryPeople.ParamByName('pNmSegundo').AsString + CR +
      'pDtRegistro: ' + QryPeople.ParamByName('pDtRegistro').AsString);

    QryPeople.Prepare;
    QryPeople.ExecSQL;

    FConnection.Commit;
  except
    on E:Exception do
      begin
        raise Exception.Create('Erro ao alterar pessoa' + CR + e.ToString);
        FConnection.Rollback;
      end;
  end;
end;

procedure TPeople.Search(Where: String='');
begin
  try
    QryPeople.SQL.Clear;
    QryPeople.SQL.Add('SELECT * FROM ' + FSchema + '.pessoa');

    if not Where.IsEmpty then begin
      QryPeople.SQL.Add('where IdPessoa = :pIdPessoa');
      QryPeople.ParamByName('pIdPessoa').AsString := Where;
    end;

    SaveLog('ClassPeolple.Search: ' + CR + QryPeople.SQL.Text + CR +
      'pIdPessoa: ' + QryPeople.ParamByName('pIdPessoa').AsString);

    QryPeople.Open;

    if QryPeople.RecordCount > 0 then
    begin
      FIdPessoa    := QryPeople.FieldByName('IdPessoa').AsInteger;
      FFlNatureza  := QryPeople.FieldByName('FlNatureza').AsInteger;
      FDsDocumento := QryPeople.FieldByName('DsDocumento').AsString;
      FNmPrimeiro  := QryPeople.FieldByName('NmPrimeiro').AsString;
      FNmSegundo   := QryPeople.FieldByName('FNmSegundo').AsString;
      FDtRegistro  := QryPeople.FieldByName('FNmSegundo').AsDateTime;
      FErro        := '';
    end
    else
      FErro := 'Pessoa não localizada';
  except
    on E:Exception do
      raise Exception.Create('Erro ao pesquisar pessoa' + CR + e.ToString);
  end;
end;

procedure TPeople.Delete;
begin
  try
    FConnection.StartTransaction;

    QryPeople.Close;
    QryPeople.SQL.Clear;
    QryPeople.SQL.Add('DELETE FROM ' + FSchema + '.pessoa');
    QryPeople.SQL.Add('where IdPessoa = :pIdPessoa');
    QryPeople.ParamByName('pIdPessoa').AsInteger := FIdPessoa;

    SaveLog('ClassPeople.Delete: ' + CR + QryPeople.SQL.Text + CR +
      'pIdPessoa: ' + QryPeople.ParamByName('pIdPessoa').AsString);

    QryPeople.Prepare;
    QryPeople.ExecSQL;

    Erro := '';

    FConnection.Commit;
  except
    on e: Exception do
      begin
        Erro := 'Erro ao excluir pessoa (' + IntToStr(FIdPessoa) + ')' + CR +
          'Erro: ' + CR + E.Message;
        FConnection.Rollback;
      end;
  end;
end;

end.

