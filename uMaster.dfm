object frmMaster: TfrmMaster
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Base de Pessoas'
  ClientHeight = 513
  ClientWidth = 709
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlDados: TPanel
    Left = 0
    Top = 0
    Width = 709
    Height = 231
    Align = alTop
    Color = clSilver
    ParentBackground = False
    TabOrder = 0
    object lblNatureza: TLabel
      Left = 24
      Top = 14
      Width = 44
      Height = 13
      Caption = 'Natureza'
    end
    object lblDocumento: TLabel
      Left = 183
      Top = 14
      Width = 54
      Height = 13
      Caption = 'Documento'
    end
    object lblNome1: TLabel
      Left = 24
      Top = 58
      Width = 33
      Height = 13
      Caption = 'Nome1'
    end
    object lblNome2: TLabel
      Left = 24
      Top = 104
      Width = 33
      Height = 13
      Caption = 'Nome2'
    end
    object lblCEP: TLabel
      Left = 24
      Top = 150
      Width = 19
      Height = 13
      Caption = 'CEP'
    end
    object lblDateRegistro: TLabel
      Left = 548
      Top = 150
      Width = 66
      Height = 13
      Caption = 'Data Registro'
    end
    object cbxNatureza: TComboBox
      Left = 24
      Top = 32
      Width = 145
      Height = 22
      AutoComplete = False
      Style = csOwnerDrawFixed
      DropDownCount = 2
      TabOrder = 0
      Items.Strings = (
        'F'#237'sica'
        'Jur'#237'dica')
    end
    object btnGravar: TBitBtn
      Left = 477
      Top = 197
      Width = 75
      Height = 25
      Cursor = crHandPoint
      Caption = '&Gravar'
      TabOrder = 6
      TabStop = False
      OnClick = btnGravarClick
    end
    object btnCancelar: TBitBtn
      Left = 558
      Top = 197
      Width = 75
      Height = 25
      Caption = '&Cancelar'
      TabOrder = 7
      TabStop = False
      OnClick = btnCancelarClick
    end
    object dbeDocumento: TDBEdit
      Left = 183
      Top = 32
      Width = 450
      Height = 21
      DataField = 'dsdocumento'
      DataSource = DsMemPeople
      TabOrder = 1
    end
    object dbeNome1: TDBEdit
      Left = 24
      Top = 76
      Width = 609
      Height = 21
      CharCase = ecUpperCase
      DataField = 'nmprimeiro'
      DataSource = DsMemPeople
      TabOrder = 2
    end
    object dbeNome2: TDBEdit
      Left = 24
      Top = 121
      Width = 609
      Height = 21
      CharCase = ecUpperCase
      DataField = 'nmsegundo'
      DataSource = DsMemPeople
      TabOrder = 3
    end
    object dbeCEP: TDBEdit
      Left = 24
      Top = 167
      Width = 507
      Height = 21
      DataField = 'dscep'
      DataSource = DsMemPeople
      TabOrder = 4
    end
    object dtpDataRegistro: TDateTimePicker
      Left = 548
      Top = 167
      Width = 85
      Height = 21
      Date = 44946.000000000000000000
      Time = 0.686789780091203300
      TabOrder = 5
    end
  end
  object stbFooter: TStatusBar
    Left = 0
    Top = 493
    Width = 709
    Height = 20
    Panels = <
      item
        Width = 550
      end
      item
        Width = 50
      end>
  end
  object dbgDados: TDBGrid
    Left = 0
    Top = 272
    Width = 709
    Height = 221
    TabStop = False
    Align = alClient
    Color = clSilver
    DataSource = DsMemPeople
    DrawingStyle = gdsGradient
    FixedColor = clSilver
    GradientStartColor = clMedGray
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgTitleClick, dgTitleHotTrack]
    PopupMenu = pmeOpcoes
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDblClick = dbgDadosDblClick
    OnKeyDown = dbgDadosKeyDown
    Columns = <
      item
        Expanded = False
        FieldName = 'idpessoa'
        Title.Caption = 'IdPessoa'
        Width = 47
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'flnatureza'
        Title.Alignment = taCenter
        Title.Caption = 'Natureza'
        Width = 56
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'dsdocumento'
        Title.Alignment = taCenter
        Title.Caption = 'Documento'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'nmprimeiro'
        Title.Alignment = taCenter
        Title.Caption = 'Nome1'
        Width = 116
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'nmsegundo'
        Title.Alignment = taCenter
        Title.Caption = 'Nome2'
        Width = 192
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'dscep'
        Title.Alignment = taCenter
        Title.Caption = 'CEP'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'dtregistro'
        Title.Alignment = taCenter
        Title.Caption = 'Data'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'IdEndereco'
        Visible = False
      end>
  end
  object pnlOpcoes: TPanel
    Left = 0
    Top = 231
    Width = 709
    Height = 41
    Align = alTop
    TabOrder = 3
    object btnNovo: TBitBtn
      Left = 24
      Top = 7
      Width = 75
      Height = 25
      Cursor = crHandPoint
      Caption = '&Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnEditar: TBitBtn
      Left = 105
      Top = 7
      Width = 75
      Height = 25
      Cursor = crHandPoint
      Caption = '&Editar'
      TabOrder = 1
      OnClick = btnEditarClick
    end
    object btnExcluir: TBitBtn
      Left = 186
      Top = 6
      Width = 75
      Height = 25
      Cursor = crHandPoint
      Caption = 'E&xcluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
  end
  object FDMemTablePeople: TFDMemTable
    AfterScroll = FDMemTablePeopleAfterScroll
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
    FormatOptions.MaxBcdPrecision = 2147483647
    FormatOptions.MaxBcdScale = 1073741823
    ResourceOptions.AssignedValues = [rvPersistent, rvSilentMode]
    ResourceOptions.Persistent = True
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
    UpdateOptions.LockWait = True
    UpdateOptions.FetchGeneratorsPoint = gpNone
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 48
    Top = 312
    object FDMemTablePeopleidpessoa: TLargeintField
      FieldName = 'idpessoa'
    end
    object FDMemTablePeopleflnatureza: TSmallintField
      FieldName = 'flnatureza'
      OnGetText = FDMemTablePeopleflnaturezaGetText
    end
    object FDMemTablePeopledsdocumento: TWideStringField
      FieldName = 'dsdocumento'
    end
    object FDMemTablePeoplenmprimeiro: TWideStringField
      FieldName = 'nmprimeiro'
      Size = 100
    end
    object FDMemTablePeoplenmsegundo: TWideStringField
      FieldName = 'nmsegundo'
      Size = 100
    end
    object FDMemTablePeopledtregistro: TDateField
      FieldName = 'dtregistro'
    end
    object FDMemTablePeopleIdEndereco: TIntegerField
      FieldName = 'IdEndereco'
    end
    object FDMemTablePeopledscep: TWideStringField
      FieldName = 'dscep'
      Size = 15
    end
  end
  object DsMemPeople: TDataSource
    DataSet = FDMemTablePeople
    Left = 136
    Top = 313
  end
  object pmeOpcoes: TPopupMenu
    OnPopup = pmeOpcoesPopup
    Left = 320
    Top = 312
    object tmiInserir: TMenuItem
      Caption = 'Inserir Registros'
      OnClick = tmiInserirClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object tmiExcluir: TMenuItem
      Caption = 'Excluir TODOS registros'
      OnClick = tmiExcluirClick
    end
  end
  object tmeThread: TTimer
    Interval = 10000
    OnTimer = tmeThreadTimer
    Left = 648
    Top = 24
  end
end
