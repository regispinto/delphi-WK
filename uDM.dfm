object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 428
  Width = 554
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=PG'
      'Password=12345678'
      'Server=127.0.0.1'
      'User_Name=postgres'
      'Database=db_pessoas')
    ResourceOptions.AssignedValues = [rvAutoConnect]
    ResourceOptions.AutoConnect = False
    TxOptions.Isolation = xiReadCommitted
    LoginPrompt = False
    Transaction = FDTransaction
    UpdateTransaction = FDTransaction
    Left = 64
    Top = 64
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 64
    Top = 168
  end
  object FDPhysPgDriverLink: TFDPhysPgDriverLink
    Left = 64
    Top = 120
  end
  object FDTransaction: TFDTransaction
    Options.Isolation = xiReadCommitted
    Connection = FDConnection
    Left = 64
    Top = 224
  end
end
