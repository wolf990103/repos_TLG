unit FS_COM05U0;

interface

uses
  Controls, Classes, Dialogs, SysUtils, Messages, Forms, Windows, ShellApi; //, GExDebugControl;

const
  W20 = 'W20';  // TLG 상세 재고

  {전문구분자}
  PS = '';
  ES = '';
  REQ = '';
  ACK = '';
  NAK = '';
  WS  = ':';
  RS  = ';';
  SYN = '';
  FS = Chr(28);
  SH = Chr(35);
var
  Card_Msg:  string = '';

  // ZEROONE SC Firmware UPDATE
  ScFirmData : Array of string;             // Firmware 데이터
  ScFirmDataCnt : integer;                  // Array 수
  ScFirmDataPoint : integer;                // 전송 포인트

  function GetCommand(SrcStr:string; StartPos:Integer; Num:Integer):string;
  function GetWord(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean) : string;
  function SimpleGetWord(SrcStr : string; Num : Integer): string;
  function GetRow(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean) : string;
  function GetWordC(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean) : string;
  function GetRowWordFS(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean) : string;
  function GetRowWordSepChar(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean; SepChar:Char) : string;
  procedure GetVAT(var VATy, VAT: real);
  function GetWordPsEs(SrcStr : string) : String;
  function GetWordPsEs2(SrcStr : string) : String;
  function GetWordSynEs(SrcStr : string) : String;
  function GetLRC(SrcStr : string) : String;            // LRC 계산
  function GetLRC_TS171(SrcStr : string) : String;            // LRC 계산

  procedure ReadSCFirmware(g_FOSFolder : string);
  //procedure ReadSCFirmware();       // ZEROONE SC Firmware Update
  procedure ParseDelimited(const sl : TStrings; const value : string; const delimiter : string);
  procedure FileCopy( const Source, Dest : String);
implementation

procedure ParseDelimited(const sl : TStrings; const value : string; const delimiter : string);
var
   dx : integer;
   ns : string;
   txt : string;
   delta : integer;
begin
   delta := Length(delimiter) ;
   txt := value + delimiter;
   sl.BeginUpdate;
   sl.Clear;
   try
     while Length(txt) > 0 do
     begin
       dx := Pos(delimiter, txt) ;
       ns := Copy(txt,0,dx-1) ;
       sl.Add(ns) ;
       txt := Copy(txt,dx+delta,MaxInt) ;
     end;
   finally
     sl.EndUpdate;
   end;
end;

procedure GetVAT(var VATy, VAT: real);
begin
  VAT  := VATy;               //과세 합계금액
  VATy := Trunc((VATy / 1.1)+0.5);  //공급가액 산출
  VAT  := VAT - VATy;         //부가세 = 과세합계금액 - 공급가액
end;


function GetString(SrcStr:string; var StartPos:Integer; Num:Integer; SepChar:Char; EndChar:Char; var Found:Boolean) : string;
var
  i,count,len : integer;
  TempStr     : string;
begin
  Found := False;
  if (SrcStr = '') or (StartPos < 1) or ( Num < 1) then
  begin
    exit;
  end;
  //
  Found := True;
  len   := Length(SrcStr);
  Count := 0; //찾은갯수를 찾는 변수
  i     := StartPos;
  //
  While count < num do
  begin
    if SrcStr[i] = SepChar then
    begin
      Inc(Count);
      Inc(i);
      While SrcStr[i] <> EndChar do
      begin
        if (Count = num) then
        begin
          TempStr := TempStr + SrcStr[i];
        end;
        Inc(i);
        if i > len then
        begin
          Found := False;
          exit;
        end;
      end;
      Dec(i);
    end;
    Inc(i);
    if i > len then
    begin
      Found := False;
      exit;
    end;
  end;
  StartPos := i;
  Result   := TempStr;
end;

// Sep ~ End 까지의 스트링을 리턴
function GetStringV2(SrcStr:string; var StartPos:Integer; Num:Integer; SepChar:Char; EndChar:Char; var Found:Boolean) : string;
var
  i,count,len : integer;
  TempStr     : string;
begin
  Found := False;
  if (SrcStr = '') or (StartPos < 1) or ( Num < 1) then
  begin
    exit;
  end;
  //
  Found := True;
  len   := Length(SrcStr);
  Count := 0; //찾은갯수를 찾는 변수
  i     := StartPos;
  //
  While i < len do
  begin
    if SrcStr[i] = SepChar then
    begin
      Inc(Count);
      Inc(i);
      While SrcStr[i] <> EndChar do
      begin
        if i <= len then
        begin
          TempStr := TempStr + SrcStr[i];
        end;
        Inc(i);
      end;
    end;
    Inc(i);
  end;
  StartPos := i;
  Result   := TempStr;
end;

function GetStringC(SrcStr:string; var StartPos:Integer; Num:Integer; SepChar:Char; var Found:Boolean) : string;
var
  i,count,len : integer;
  TempStr     : string;
begin
  Found := False;
  if (SrcStr = '') or (StartPos < 1) or ( Num < 1) then
  begin
    exit;
  end;
  //
  Found := True;
  len   := Length(SrcStr);
  Count := 0; //찾은갯수를 찾는 변수
  i     := StartPos;
  //
  While count < num do
  begin
    if SrcStr[i] = SepChar then
    begin
      Inc(Count);
      Inc(i);
      While SrcStr[i] <> SepChar do
      begin
        if (Count = num) then
        begin
          TempStr := TempStr + SrcStr[i];
        end;
        Inc(i);
        if i > len then
        begin
          Found := False;
          exit;
        end;
      end;
      Dec(i);
    end;
    Inc(i);
    if i > len then
    begin
      Found := False;
      exit;
    end;
  end;
  StartPos := i;
  Result   := TempStr;
end;

function GetCommand(SrcStr:string;StartPos:Integer; Num:Integer):string;
var
  TempStr : string;
begin
  if (SrcStr = '') or (StartPos < 1) or ( Num < 1) then
  begin
    exit;
  end;

  TempStr := Copy(SrcStr,StartPos,Num);
  Result  := TempStr;
end;

function SimpleGetWord(SrcStr : string; Num : Integer) : string;
var
  StartPos : Integer;
  Found : Boolean;
begin
  StartPos := 1;
  Result   := GetString(SrcStr,StartPos,Num,WS,ES,Found);
end;

// STX에서 ETX까지의 문자열
function GetWordPsEs(SrcStr : string) : String;
var
  StartPos : Integer;
  Found : Boolean;
  Num : Integer;
begin
  StartPos := 1;
  Num := Length(SrcStr);
  Result := GetStringV2(SrcStr, StartPos, Num, PS, ES, Found);
end;

// STX에서 ETX까지의 문자열 (STX, ETX 포함)
function GetWordPsEs2(SrcStr : string) : String;
var
  StartPos : Integer;
  Found : Boolean;
  Num : Integer;
  sData : String;
begin
  StartPos := 1;
  Num := Length(SrcStr);
  sData := GetStringV2(SrcStr, StartPos, Num, PS, ES, Found);

  if sData <> '' then sData := PS + sData + ES;
  Result := sData;
end;

// SYN에서 ETX까지의 문자열
function GetWordSynEs(SrcStr : string) : String;
var
  StartPos : Integer;
  Found : Boolean;
  Num : Integer;
begin
  StartPos := 1;
  Num := Length(SrcStr);
  Result := GetStringV2(SrcStr, StartPos, Num, SYN, ES, Found);
end;

function GetWord(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean) : string;
begin
  Result := GetString(SrcStr,StartPos,Num,WS,ES,Found);
end;

function GetWordC(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean) : string;
begin
  Result := GetStringC(SrcStr,StartPos,Num,WS,Found);
end;

function GetRow(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean) : string;
begin
  Result := GetStringC(SrcStr,StartPos,Num,RS,Found);
end;

function GetRowWordFS(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean) : string;
begin
  Result := GetStringC(SrcStr,StartPos,Num,FS,Found);
end;

function GetRowWordSepChar(SrcStr : string; var StartPos : Integer; Num : Integer; var Found : Boolean; SepChar:Char) : string;
begin
  Result := GetStringC(SrcStr,StartPos,Num,SepChar,Found);
end;

function GetLRC(SrcStr : string) : String;
var
  BCC : byte;
  i   : integer;
begin
  BCC := Integer(SrcStr[1]);

  for i := 2 to Length(SrcStr) do begin
    BCC := BCC XOR Integer(SrcStr[i]);
  end;

//  showmessage(char(bcc));

  BCC := BCC OR $20;

  result := char(BCC);
end;

function GetLRC_TS171(SrcStr : string) : String;
var
  BCC : byte;
  i   : integer;
begin
  BCC := Integer(SrcStr[1]);

  for i := 1 to Length(SrcStr) do begin
    BCC := BCC XOR Integer(SrcStr[i]);
  end;

//  showmessage(char(bcc));

  BCC := BCC OR $20;

  result := char(BCC);
end;


procedure ReadSCFirmware(g_FOSFolder : string);
var
  fp: TextFile;
  filename: string;
  S : string;
begin
  if g_FOSFolder = '' then
    g_FOSFolder := 'C:\HDO_FOS\';

  filename := g_FOSFolder + 'SCUPLOAD\sc.a90';

  ScFirmDataCnt := 0;
  ScFirmDataPoint := 0;
  
  SetLength(ScFirmData, 4096);

  if FileExists(filename) then
  try
    AssignFile(fp, filename);
    Reset(fp);
    while not Eof(fp) do
    begin
      Readln(fp, S);
      if Trim(S) = '' then
        break;
      ScFirmData[ScFirmDataCnt] := S;
      ScFirmDataCnt := ScFirmDataCnt + 1;
//      GSendInteger('SC', 'ScFirmDataCnt', ScFirmDataCnt);
    end;
  finally
    CloseFile(fp);
  end;
end;

procedure FileCopy( const Source, Dest : String);
var
  S, T : TFileStream;
begin
  S := TFileStream.Create( Source,fmOpenRead);
  T := TFileStream.Create( Dest, fmOpenWrite or fmCreate) ;
  T.CopyFrom(S,S.Size);
  T.Free;
  S.Free;
end;


end.

