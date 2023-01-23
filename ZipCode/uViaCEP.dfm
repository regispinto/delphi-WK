object fViaCep: TfViaCep
  Left = 0
  Top = 0
  Caption = 'ViaCep'
  ClientHeight = 468
  ClientWidth = 255
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object RESTClient1: TRESTClient
    BaseURL = 'http://viacep.com.br/ws'
    Params = <>
    Left = 104
    Top = 40
  end
  object RESTRequest1: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTClient1
    Params = <>
    Resource = '91220260/json'
    Response = RESTResponse1
    Left = 104
    Top = 88
  end
  object RESTResponse1: TRESTResponse
    Left = 104
    Top = 208
  end
  object RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter
    Dataset = MemTableCEP
    FieldDefs = <>
    Response = RESTResponse1
    TypesMode = Rich
    Left = 104
    Top = 144
  end
  object MemTableCEP: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable]
    UpdateOptions.LockWait = True
    UpdateOptions.FetchGeneratorsPoint = gpNone
    UpdateOptions.CheckRequired = False
    Left = 104
    Top = 280
  end
end
