object TLGServerF: TTLGServerF
  Left = 723
  Top = 284
  Width = 675
  Height = 616
  Caption = 'TLG '#51116#44256' '#49688#51665
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    659
    577)
  PixelsPerInch = 96
  TextHeight = 17
  object Memo1: TMemo
    Left = 18
    Top = 54
    Width = 618
    Height = 247
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button1: TButton
    Left = 18
    Top = 22
    Width = 75
    Height = 25
    Caption = #49436#48260#49884#51089
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 100
    Top = 22
    Width = 75
    Height = 25
    Caption = #49436#48260#51473#51648
    TabOrder = 2
    OnClick = Button2Click
  end
  object Memo2: TMemo
    Left = 17
    Top = 313
    Width = 618
    Height = 247
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object Button3: TButton
    Left = 373
    Top = 22
    Width = 75
    Height = 25
    Caption = #45936#51060#53552#50836#52397
    TabOrder = 4
    OnClick = Button3Click
  end
  object dtYmd: TDateTimePicker
    Left = 268
    Top = 22
    Width = 101
    Height = 25
    Date = 44823.527975405090000000
    Time = 44823.527975405090000000
    TabOrder = 5
  end
  object Id_Tlg_Server: TIdTCPServer
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 12345
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    OnConnect = Id_Tlg_ServerConnect
    OnExecute = Id_Tlg_ServerExecute
    OnDisconnect = Id_Tlg_ServerDisconnect
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    ThreadMgr = IdThreadMgrDefault1
    Left = 468
    Top = 13
  end
  object IdThreadMgrDefault1: TIdThreadMgrDefault
    Left = 499
    Top = 13
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 530
    Top = 13
  end
  object ADOConnection1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=OraOLEDB.Oracle.1;Password=poseye;Persist Security Info' +
      '=True;User ID=oilbank;Data Source=CCTV'
    LoginPrompt = False
    Provider = 'OraOLEDB.Oracle.1'
    Left = 577
    Top = 12
  end
  object qrySQL: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 610
    Top = 11
  end
end
