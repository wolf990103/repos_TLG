unit TLGServerU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdAntiFreezeBase, IdAntiFreeze, StdCtrls, IdThreadMgr,
  IdThreadMgrDefault, IdBaseComponent, IdComponent, IdTCPServer, DB, ADODB,
  CoolTrayIcon, ComCtrls;

type
  TTLGServerF = class(TForm)
    Id_Tlg_Server: TIdTCPServer;
    IdThreadMgrDefault1: TIdThreadMgrDefault;
    Memo1: TMemo;
    IdAntiFreeze1: TIdAntiFreeze;
    Button1: TButton;
    Button2: TButton;
    Memo2: TMemo;
    ADOConnection1: TADOConnection;
    qrySQL: TADOQuery;
    Button3: TButton;
    dtYmd: TDateTimePicker;
    procedure Id_Tlg_ServerExecute(AThread: TIdPeerThread);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Id_Tlg_ServerConnect(AThread: TIdPeerThread);
    procedure Id_Tlg_ServerDisconnect(AThread: TIdPeerThread);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure pMsgProcess(AThread: TIdPeerThread; sMsg: String);
    procedure pid_Tlg_Server_Process(AThread: TIdPeerThread; sMsg: string);
    procedure getTLGData(AThread: TIdPeerThread; Msg: String);
  end;

var
  TLGServerF: TTLGServerF;

implementation

uses TLG_ThreadU, IdTCPConnection, FS_COM05U0, IdIOHandlerSocket,
  IdSocketHandle;

{$R *.dfm}

{ TForm1 }


procedure TTLGServerF.Id_Tlg_ServerExecute(AThread: TIdPeerThread);
var
  sMsg: string;
  TLGThread: TLG_Thread;
begin
  sMsg := AThread.Connection.ReadLn();

  if Trim(sMsg) = '' then exit;

  try
    TLGThread := TLG_Thread.Create(AThread, sMsg);
    TLGThread.FreeOnTerminate := True;
  except

  end;
end;

procedure TTLGServerF.pid_Tlg_Server_Process(AThread: TIdPeerThread; sMsg: string);
var
  Msg         : string;
  Command     : string;
  StartPos    : integer;
  Found       : Boolean;
  i           : integer;
begin
  try
    Msg := sMsg;
    Memo1.Lines.Add(Msg);


    if Memo1.Lines.Count > 500 then Memo1.Lines.Clear;
    if Memo2.Lines.Count > 500 then Memo2.Lines.Clear;

  except

  end;


  try
    Msg := sMsg;

    if Trim(Msg) <> '' then
    begin
      Command := GetCommand(Msg,2,3);

      if Command = W20 then getTLGData(AThread, Msg);
    end;
  except
    on E: Exception do
    begin
      try AThread.Connection.Disconnect; except end;
    end;
  end;
end;


procedure TTLGServerF.getTLGData(AThread: TIdPeerThread; Msg: String);
var
  Command    : String;
  COMM_NO    : string;
  STN_ID     : Array of String;
  TANK_NO    : Array of String;
  PRD_CD     : Array of String;
  ACTL_DT    : Array of String;
  CAPA       : Array of String;
  HEI        : Array of String;
  WHEI       : Array of String;
  TEMPE      : Array of String;
  STAT       : Array of String;
  RowFound   : Boolean;
  WordFound  : Boolean;
  Found      : Boolean;
  StartPos   : Integer;
  RowSchPos  : Integer;
  WordSchPos : Integer;
  rCnt       : Integer;
  i          : Integer;
  sYMD, sHH24MI, sPreYMD : string;
begin
  StartPos := 1;
  COMM_NO  := GetWordC(Msg,StartPos,1,Found);
  rCnt     := StrToInt(GetWordC(Msg ,StartPos,1,Found));
  //----------------------------------------------------------------------------

  SetLength(STN_ID,  rCnt);  //주유소코드
  SetLength(TANK_NO, rCnt);  //탱크번호
  SetLength(PRD_CD,  rCnt);  //제품코드
  SetLength(ACTL_DT, rCnt);  //실측일시
  SetLength(CAPA,    rCnt);  //용량
  SetLength(HEI,     rCnt);  //높이
  SetLength(WHEI,    rCnt);  //수분높이
  SetLength(TEMPE,   rCnt);  //온도
  SetLength(STAT,    rCnt);  //상태

//  sYMD    := FormatDateTime('YYYYMMDD',Now);
  sPreYMD := FormatDatetime('yyyyMMdd',Now-1);
  sHH24MI := FormatDatetime('hhnn', Now);
  //----------------------------------------------------------------------------
  for i:=0 to rCnt-1 do
  begin
    STN_ID[i]  := '';
    TANK_NO[i] := '';
    PRD_CD[i]  := '';
    ACTL_DT[i] := '';
    CAPA[i]    := '';
    HEI[i]     := '';
    WHEI[i]    := '';
    TEMPE[i]   := '';
    STAT[i]    := '';
  end;
  //----------------------------------------------------------------------------
  RowSchPos := 1;
  for i:=0 to rCnt-1 do
  begin
    Command := GetRow(Msg,RowSchPos,1,RowFound);
    if RowFound = False then
    begin
      Break;
    end;
    WordSchPos := 1;
    STN_ID[i]  := GetWordC(Command,WordSchPos,1,WordFound);
    TANK_NO[i] := GetWordC(Command,WordSchPos,1,WordFound);
    PRD_CD[i]  := GetWordC(Command,WordSchPos,1,WordFound);
    ACTL_DT[i] := GetWordC(Command,WordSchPos,1,WordFound);
    sYmd       := Copy(ACTL_DT[i],1,8);
    CAPA[i]    := GetWordC(Command,WordSchPos,1,WordFound);
    HEI[i]     := GetWordC(Command,WordSchPos,1,WordFound);
    WHEI[i]    := GetWordC(Command,WordSchPos,1,WordFound);
    TEMPE[i]   := GetWordC(Command,WordSchPos,1,WordFound);
    STAT[i]    := GetWordC(Command,WordSchPos,1,WordFound);

    Memo2.Lines.Add(STN_ID[i]  + ' ' +
                    TANK_NO[i] + ' ' +
                    PRD_CD[i]  + ' ' +
                    ACTL_DT[i] + ' ' +
                    CAPA[i]    + ' ' +
                    HEI[i]     + ' ' +
                    WHEI[i]    + ' ' +
                    TEMPE[i]   + ' ' +
                    STAT[i]);



    with qrySQL do
    begin
      Close;
      SQL.Text :=  ' INSERT INTO MSB_TNK_STK_DTL         '
           + #13 + ' (      TSD_STN_ID,                  '
           + #13 + '        TSD_FACI_NO,                 '
           + #13 + '        TSD_ACTL_SRVY_YMD,           '
           + #13 + '        TSD_ACTL_SRVY_DATE,          '
           + #13 + '        TSD_PRD_CAPA,                '
           + #13 + '        TSD_PRD_HIGT,                '
           + #13 + '        TSD_WTR_HIGT,                '
           + #13 + '        TSD_TMPR,                    '
           + #13 + '        TSD_REGANT_ID,               '
           + #13 + '        TSD_REG_DATE,                '
           + #13 + '        TSD_IPGO_CNFRM_YN,           '
           + #13 + '        TSD_UPDER_ID  )              '
           + #13 + ' SELECT '''+STN_ID[i]+''',           '
           + #13 + '        '''+TANK_NO[i]+''',          '
           + #13 + '        '''+sYMD+''',                '
           + #13 + '        TO_DATE('''+ACTL_DT[i]+''',''YYYYMMDDHH24MISS''), '
           + #13 + '        '+CAPA[i]+',                 '
           + #13 + '        '+HEI[i]+',                  '
           + #13 + '        '+WHEI[i]+',                 '
           + #13 + '        '+TEMPE[i]+',                '
           + #13 + '        ''HDO_POS'',                 '
           + #13 + '        SYSDATE,                     '
           + #13 + '        ''N'',                       '
           + #13 + '        '''+PRD_CD[i]+'''            '
           + #13 + ' FROM   DUAL '
           + #13 + ' WHERE  NOT EXISTS ( SELECT TSD_STN_ID '
           + #13 + '                     FROM   MSB_TNK_STK_DTL '
           + #13 + '                     WHERE  TSD_STN_ID = '''+STN_ID[i]+''' '
           + #13 + '                     AND    TSD_FACI_NO = '''+TANK_NO[i]+''' '
           + #13 + '                     AND    TSD_ACTL_SRVY_YMD = '''+sYmd+''' '
           + #13 + '                     AND    TO_CHAR(TSD_ACTL_SRVY_DATE,''YYYYMMDDHH24MISS'') = '''+ACTL_DT[i]+''' '
           + #13 + '                   ) ';


(*
      Close;
      SQL.Text :=  ' INSERT INTO MSB_TNK_STK_DTL         '
           + #13 + ' (      TSD_STN_ID,                  '
           + #13 + '        TSD_FACI_NO,                 '
           + #13 + '        TSD_ACTL_SRVY_YMD,           '
           + #13 + '        TSD_ACTL_SRVY_DATE,          '
           + #13 + '        TSD_PRD_CAPA,                '
           + #13 + '        TSD_PRD_HIGT,                '
           + #13 + '        TSD_WTR_HIGT,                '
           + #13 + '        TSD_TMPR,                    '
           + #13 + '        TSD_REGANT_ID,               '
           + #13 + '        TSD_REG_DATE,                '
           + #13 + '        TSD_IPGO_CNFRM_YN,           '
           + #13 + '        TSD_UPDER_ID  )              '
           + #13 + ' VALUES                              '
           + #13 + ' (      '''+STN_ID[i]+''',           '
           + #13 + '        '''+TANK_NO[i]+''',          '
           + #13 + '        '''+sYMD+''',                '
           + #13 + '        TO_DATE('''+ACTL_DT[i]+''',''YYYYMMDDHH24MISS''), '
           + #13 + '        '+CAPA[i]+',                 '
           + #13 + '        '+HEI[i]+',                  '
           + #13 + '        '+WHEI[i]+',                 '
           + #13 + '        '+TEMPE[i]+',                '
           + #13 + '        ''HDO_POS'',                 '
           + #13 + '        SYSDATE,                     '
           + #13 + '        ''N'',                       '
           + #13 + '        '''+PRD_CD[i]+'''            '
           + #13 + ' )                                   ';
*)
      try
        execSQL;
      except
        Memo2.Lines.Text := SQL.Text;
      end;
    end;
  end;


(*
  with qrySQL do
  begin
    for i:=0 to rCnt-1 do
    begin
      Clear;
      SQL.Text :=  ' INSERT INTO MSB_TNK_STK_DTL         '
           + #13 + ' (      TSD_STN_ID,                  '
           + #13 + '        TSD_FACI_NO,                 '
           + #13 + '        TSD_ACTL_SRVY_YMD,           '
           + #13 + '        TSD_ACTL_SRVY_DATE,          '
           + #13 + '        TSD_PRD_CAPA,                '
           + #13 + '        TSD_PRD_HIGT,                '
           + #13 + '        TSD_WTR_HIGT,                '
           + #13 + '        TSD_TMPR,                    '
           + #13 + '        TSD_REGANT_ID,               '
           + #13 + '        TSD_REG_DATE,                '
           + #13 + '        TSD_IPGO_CNFRM_YN  )         '
           + #13 + ' VALUES                              '
           + #13 + ' (      '''+STN_ID[i]+''',           '
           + #13 + '        '''+TANK_NO[i]+''',          '
           + #13 + '        '''+sYMD+''',                '
           + #13 + '        SYSDATE,                     '
           + #13 + '        '+CAPA[i]+',                 '
           + #13 + '        '+HEI[i]+',                  '
           + #13 + '        '+WHEI[i]+',                 '
           + #13 + '        '+TEMPE[i]+',                '
           + #13 + '        ''HDO_POS'',                 '
           + #13 + '        SYSDATE,                     '
           + #13 + '        ''N''                        '
           + #13 + ' )                                   ';
      try
        execSQL;
      except

      end;

      // 2010-01-13 : 24시 마감시 TLG재고를 잘못 가져오는 현상으로 인해 30분마다 수신받는 TLG의 자료를 재고테이블에 저장한다.
      if sHH24MI = '0030' then
      begin
        Clear;
        SQL.Text := ' SELECT * FROM BMA_TNK_HIST                 '
            + #13 + ' WHERE  TSK_STN_ID = '''+g_STNID+'''        '
            + #13 + ' AND    TSK_TNK_NO = '''+TANK_NO[i]+'''     '
            + #13 + ' AND    TSK_ACTL_SRVY_YMD = '''+sPreYMD+''' '; // sPreYMD: 하루전의 TLG재고가 있는지 확인해서
        Open;

        if isEmpty = True then // 일마감 TLG재고량이 테이블에 없다면.. 익일 00시30분의 탱크별 재고를 TLG재고테이블에 저장한다.
        begin
          Clear;
          Text := ' INSERT INTO BMA_TNK_HIST '
                + ' ( TSK_STN_ID,            '
                + '   TSK_TNK_NO,            '
                + '   TSK_ACTL_SRVY_YMD,     '
                + '   TSK_TLG_QTTY )         '
                + ' VALUES                   '
                + ' ( '''+g_STNID+''',       '
                + '   '''+TANK_NO[i]+''',    '
                + '   '''+sPreYMD+''',       '
                + '     '+CAPA[i]+' )        ';
          try
            ExecSQL;
          except
          end;
        end;
      end;
    end;
  end;
*)
end;


procedure TTLGServerF.pMsgProcess(AThread: TIdPeerThread; sMsg: String);
begin
  try
    pid_Tlg_Server_Process(AThread, sMsg);
  except
    on E: Exception do
    begin

    end;
  end;
end;

procedure TTLGServerF.Button1Click(Sender: TObject);
begin
  Id_Tlg_Server.Active := True;
end;

procedure TTLGServerF.Button2Click(Sender: TObject);
begin
  Id_Tlg_Server.Active := False;
end;

procedure TTLGServerF.Id_Tlg_ServerConnect(AThread: TIdPeerThread);
var
  sIP: string;
begin

  sIP := AThread.Connection.Socket.Binding.PeerIP;
  Memo1.Lines.Add(sIP + ': Client 접속');


end;

procedure TTLGServerF.Id_Tlg_ServerDisconnect(AThread: TIdPeerThread);
var
  sIP: string;
begin

  sIP := AThread.Connection.Socket.Binding.PeerIP;
  Memo1.Lines.Add(sIP + ': Client 접속 해제');
end;

procedure TTLGServerF.Button3Click(Sender: TObject);
var
  tmpList      : TList;
//  contexClient : TidPeerThread;
  i            : integer;
begin
  tmpList  := Id_Tlg_Server.Threads.LockList;

  try
    for i:=0 to tmpList.Count-1 do
    begin
      TIdPeerThread(tmpList.Items[i]).Connection.WriteLn('R20: ' + FormatDatetime('yyyyMMdd',dtYmd.Datetime));

    end;

  finally
    Id_Tlg_Server.Threads.UnlockList;
  end;
end;

end.
