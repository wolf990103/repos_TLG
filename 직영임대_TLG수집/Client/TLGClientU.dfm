object Form1: TForm1
  Left = 511
  Top = 311
  Width = 588
  Height = 409
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 56
    Height = 13
    Caption = 'Server '#51452#49548
  end
  object Label2: TLabel
    Left = 16
    Top = 72
    Width = 77
    Height = 13
    Caption = 'Server Message'
  end
  object RealGrid1: TRealGrid
    Left = 11
    Top = 113
    Width = 550
    Height = 247
    TabOrder = 0
    Columns = <>
    Groups = <>
    Footers = <>
    Headers.Lines.CellColor = clBlack
    Headers.Lines.LevelColor = clBlack
    Headers.ColHeight = 21
    Headers.GrpHeight = 42
    FixedStyle.Lines.CellColor = clBlack
    FixedStyle.Lines.LevelColor = clBlack
    Indicators.Font.Charset = DEFAULT_CHARSET
    Indicators.Font.Color = clWindowText
    Indicators.Font.Height = -11
    Indicators.Font.Name = 'Arial'
    Indicators.Font.Style = []
    Lines.HorzColor = clGray
    ColRowHeight = 18
    GrpRowHeight = 36
    ColFixedCount = 0
    GrpFixedCount = 0
  end
  object Button1: TButton
    Left = 203
    Top = 11
    Width = 75
    Height = 25
    Caption = 'connect'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 99
    Top = 68
    Width = 460
    Height = 21
    TabOrder = 2
    Text = 'Edit1'
  end
  object Button2: TButton
    Left = 283
    Top = 11
    Width = 75
    Height = 25
    Caption = 'TLG send'
    TabOrder = 3
    OnClick = Button2Click
  end
  object edtServerIP: TEdit
    Left = 79
    Top = 13
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'localhost'
  end
  object Id_Tlg_Client: TIdTCPClient
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 0
    Left = 368
    Top = 11
  end
  object ADOConnection1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=OraOLEDB.Oracle.1;Password=msdv;Persist Security Info=T' +
      'rue;User ID=smms;Data Source=mis10'
    LoginPrompt = False
    Provider = 'OraOLEDB.Oracle.1'
    Left = 428
    Top = 14
  end
  object qrySQL: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 459
    Top = 14
  end
  object IdThreadComponent1: TIdThreadComponent
    OnRun = IdThreadComponent1Run
    Left = 398
    Top = 12
  end
end
