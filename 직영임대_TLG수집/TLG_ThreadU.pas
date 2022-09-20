unit TLG_ThreadU;

interface

uses
  Classes, IdTCPServer, Windows;

type
  TLG_Thread = class(TThread)
  private
    { Private declarations }
    g_thThread : TIdPeerThread;
    g_sMsg     : String;
  protected
    procedure Execute; override;
    procedure setInitialize;
  public
    constructor Create(AThread: TIdPeerThread; sMsg: String);
  end;

var
  FTLock : TRTLCriticalSection;


implementation

uses TLGServerU;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TLG_Thread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TLG_Thread }

constructor TLG_Thread.Create(AThread: TIdPeerThread; sMsg: String);
begin
  g_thThread := AThread;
  g_sMsg     := sMsg;

  FreeOnTerminate := true;
  inherited Create(false);
end;

procedure TLG_Thread.Execute;
begin
  EnterCriticalSection( FTLock );
  { Place thread code here }
  try
    Synchronize(setInitialize);
    FreeOnTerminate := true;
  finally
    LeaveCriticalSection( FTLock );
  end;
end;

procedure TLG_Thread.setInitialize;
begin
//  TLGServerF.pMsgProcess(g_thThread, g_sMsg);
  TLGServerF.pid_Tlg_Server_Process(g_thThread, g_sMsg);
end;

initialization
  InitializeCriticalSection(FTLock);

finalization
  DeleteCriticalSection(FTLock);

end.
