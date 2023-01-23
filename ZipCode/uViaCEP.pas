unit uViaCEP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.Bind.Components,
  Data.Bind.ObjectScope,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,

  REST.Types, REST.Response.Adapter, REST.Client,

  uFunctions;

type
  TfViaCep = class(TForm)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    MemTableCEP: TFDMemTable;
  private
    FDsUf: string;
    FNmCidade: string;
    FNmLogradouro: string;
    FNmBairro: string;
    FDsComplemento: string;
    FRetornoCEP: string;
    { Private declarations }
  public
    { Public declarations }

    property DsUf: string read FDsUf write FDsUf;
    property NmCidade: string read FNmCidade write FNmCidade;
    property NmBairro: string read FNmBairro write FNmBairro;
    property NmLogradouro: string read FNmLogradouro write FNmLogradouro;
    property DsComplemento: string read FDsComplemento write FDsComplemento;
    property RetornoCEP: string read FRetornoCEP write FRetornoCEP;

    procedure ConsultarCEP(CEP: string);
  end;

var
  fViaCEP: TfViaCEP;

implementation

{$R *.dfm}

{ TfViaCep }

procedure TfViaCep.ConsultarCEP(CEP: string);
begin
  try
    RESTRequest1.Resource := CEP + '/json';

    SaveLog('uViaCEP.BaseURL: ' + RESTClient1.BaseURL + CR +
      'Resource: ' + RESTRequest1.Resource);

    RESTRequest1.Execute;

    SaveLog('uViaCEP.StatusCode: ' + RESTRequest1.Response.StatusCode.ToString);

    if RESTRequest1.Response.StatusCode = 200 then
    begin
      FRetornoCEP := '';

      if RESTRequest1.Response.Content.IndexOf('erro') > 0 then
        FRetornoCEP := 'CEP '+ CEP +' não localizado'
      else
      begin
        DsUf := MemTableCEP.FieldByName('uf').AsString;
        NmCidade := MemTableCEP.FieldByName('localidade').AsString;
        NmBairro := MemTableCEP.FieldByName('bairro').AsString;
        NmLogradouro := MemTableCEP.FieldByName('logradouro').AsString;
        DsComplemento := MemTableCEP.FieldByName('complemento').AsString;
      end;
    end;
  except
    on E:Exception do
      FRetornoCEP := 'Erro ao pesquisar CEP ' + CR +
        'Erro: ' + e.Message;
  end;
end;

end.
