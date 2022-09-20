program TLG_Server;

uses
  Forms,
  TLGServerU in 'TLGServerU.pas' {TLGServerF},
  TLG_ThreadU in 'TLG_ThreadU.pas',
  FS_COM05U0 in 'FS_COM05U0.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTLGServerF, TLGServerF);
  Application.Run;
end.
