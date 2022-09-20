unit TLGClientU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  StdCtrls, URGrids, URMGrid, DB, ADODB, IdThreadComponent;

type
  TForm1 = class(TForm)
    RealGrid1: TRealGrid;
    Button1: TButton;
    Id_Tlg_Client: TIdTCPClient;
    Edit1: TEdit;
    Button2: TButton;
    ADOConnection1: TADOConnection;
    qrySQL: TADOQuery;
    Label1: TLabel;
    edtServerIP: TEdit;
    Label2: TLabel;
    IdThreadComponent1: TIdThreadComponent;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure IdThreadComponent1Run(Sender: TIdCustomThreadComponent);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

////////////////////////////////////////////////////////////////////////////////
// SERVER 立加
procedure TForm1.Button1Click(Sender: TObject);
begin
//  Id_Tlg_Client.Host := 'localhost';

  // Server IP, PORT
  Id_Tlg_Client.Host := edtServerIP.Text;
  Id_Tlg_Client.Port := 12345;

  try
    Id_Tlg_Client.Connect;

    IdThreadComponent1.Active := True;
  except
    on E: Exception do
       ShowMessage(E.Message);
  end;
end;
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// TLG 单捞磐 价脚
procedure TForm1.Button2Click(Sender: TObject);
var
  S: string;
begin
  // W20:05:05:;:01:01:7440.45:87.52:0.00:24.56:00:;:02:01:9756.99:106.04:0.35:33.09:00:;:03:01:19313.18:194.35:0.00:32.72:00:;:04:01:13663.35:144.10:0.04:29.19:00:;:05:01:10411.47:114.08:0.43:30.05:00:;

  if Id_Tlg_Client.Connected = False then
    Button1Click(Sender);

  with qrySQL do
  begin
    Close;
    SQL.Text := ' SELECT TSD_STN_ID, TSD_FACI_NO, TSD_UPDER_ID, TO_CHAR(TSD_ACTL_SRVY_DATE,''YYYYMMDDHH24MISS'') ACTL_DT, '
        + #13 + '        TSD_PRD_CAPA, TSD_PRD_HIGT, TSD_WTR_HIGT, TSD_TMPR, TSD_TLG_IPGO_QTTY '
        + #13 + ' FROM   MSB_TNK_STK_DTL '
        + #13 + ' WHERE  TSD_STN_ID LIKE ''98%'' '
        + #13 + ' AND    TSD_ACTL_SRVY_YMD = ''20220801'' '
        + #13 + ' AND    TO_CHAR(TSD_ACTL_SRVY_DATE,''HH24MI'') = ''1100'' '
        + #13 + ' ORDER BY TSD_STN_ID, TSD_FACI_NO ';
    Open;


    S := 'W20:' + '01:' + FormatFloat('00', RecordCount) + ':;';

    while Not Eof do
    begin
      S := S + ':';
      S := S + FieldByName('TSD_STN_ID').asString   + ':';
      S := S + FieldByName('TSD_FACI_NO').asString  + ':';
      S := S + FieldByName('TSD_UPDER_ID').asString + ':'; // 力前内靛
      S := S + FieldByName('ACTL_DT').asString      + ':';
      S := S + FieldByName('TSD_PRD_CAPA').asString + ':';
      S := S + FieldByName('TSD_PRD_HIGT').asString + ':';
      S := S + FieldByName('TSD_WTR_HIGT').asString + ':';
      S := S + FieldByName('TSD_TMPR').asString     + ':';
      S := S + FieldByName('TSD_TLG_IPGO_QTTY').asString + ':;';

      Next;
    end;

    S := S + '';
    Id_Tlg_Client.WriteLn(S);

    try
//      Id_Tlg_Client.DisConnect;
    except

    end;

  end;
end;
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Server Message 荐脚
procedure TForm1.IdThreadComponent1Run(Sender: TIdCustomThreadComponent);
begin
  Edit1.Text := Id_Tlg_Client.ReadLn();

  if Length(Edit1.Text) < 13 then exit;
  if Copy(Edit1.Text,1,3) <> 'R20' then exit;



  if Edit1.Text = '20220919' then
    Button2Click(Sender);
end;
////////////////////////////////////////////////////////////////////////////////




end.
