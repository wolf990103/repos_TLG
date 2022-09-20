program TLG_Client;

uses
  Forms,
  TLGClientU in 'TLGClientU.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
