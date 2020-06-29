///<summary>������ ADOXML ��� ������ � ���������� �����</summary>
unit DL.ADOXMLParserUnit;

{$IFDEF VER150} {$DEFINE OldDelphi} {$ENDIF} // ��� 7

interface

uses ADODB, Classes, DB;

type
  ///<summary>���� ��������� ����</summary>
  TFieldAtributes=(faName, faCatalog, faSchema, faTable, faColumn
                , faKey, faAutoIncrement, faWritable);

const
  cStrFieldAtributes: array [TFieldAtributes] of string =
                  ('name', 'rs:basecatalog', 'rs:baseschema'
                  , 'rs:basetable', 'rs:basecolumn', 'rs:keycolumn'
                  , 'rs:autoincrement', 'rs:writeunknown');
  cBegSchema='<s:Schema id=''RowsetSchema''>';
  cEndSchema='</s:Schema>';
  cBegAtributes='<s:AttributeType ';
  cEndAtributes='>';

type
  ///<summary>������ ADOXML ��� ������ � ���������� �����</summary>
  TADOXMLFields = {$IFDEF OldDelphi} class {$ELSE} record {$ENDIF}
  private
    XMLstr: string;
    FFileName: string;
    FStream: TFileStream;
    beginSchema, endSchema: integer;
    beginCurField, endCurField: integer;
    function EOF: boolean;
    function FindAtribute(const FieldAtribut: TFieldAtributes;
                  out begAtr, endAtr: integer): boolean;
    procedure RecalcEndPos;
  public
    ///<summary>��������� XML</summary>
    procedure LoadXML(const AFileName: string);
    ///<summary>��������� ����������������� ����</summary>
    procedure SaveXML;
    ///<summary>������� � ������ �����</summary>
    procedure SeekBegin;
    ///<summary>�������� ��������� ����</summary>
    function NextField: boolean;
    ///<summary>������ �������</summary>
    function GetAtribute(const FieldAtribut: TFieldAtributes): string;
    ///<summary>������� �������</summary>
    procedure DelAtribute(const FieldAtribut: TFieldAtributes);
    ///<summary>���������� �������</summary>
    procedure SetAtribute(const FieldAtribut: TFieldAtributes; Value: string);
  end;

  EADOXMLParcerError = class (EParserError)
  end;

implementation

uses StrUtils, ADOInt, SysUtils, windows, Variants;

{ TADOXMLFields }

// ������� �������
procedure TADOXMLFields.DelAtribute(const FieldAtribut: TFieldAtributes);
var
  begAtr, endAtr: integer;
begin
  if FindAtribute(FieldAtribut, begAtr, EndAtr) then
    Delete(XMLstr, begAtr-Length(cStrFieldAtributes[FieldAtribut]+'=''')
              , EndAtr-begAtr+Length(cStrFieldAtributes[FieldAtribut]+'=''')+1);
  RecalcEndPos;
end;

// ����� �� ������� ����� (� ������)
function TADOXMLFields.EOF: boolean;
begin
  result:= (beginCurField > endSchema) or (beginCurField <= Length(cBegAtributes));
end;

// ����� ������ ��������
function TADOXMLFields.FindAtribute(const FieldAtribut: TFieldAtributes;
  out begAtr, endAtr: integer): boolean;
begin
  if EOF then raise EADOXMLParcerError.Create('������� �� ����� ���� ��������');
  begAtr:= PosEx(cStrFieldAtributes[FieldAtribut]+'=''', XMLstr, beginCurField)
          + Length(cStrFieldAtributes[FieldAtribut]+'=''');
  result:= (begAtr>Length(cStrFieldAtributes[FieldAtribut]+'=''')) and
      (begAtr<endCurField);
  if result then
    endAtr:= PosEx('''', XMLstr, begAtr);
end;

// �������� �������� ��������
function TADOXMLFields.GetAtribute(const FieldAtribut: TFieldAtributes): string;
var
  begAtr, endAtr: integer;
begin
  if FindAtribute(FieldAtribut, begAtr, EndAtr) then
    Result:=MidStr(XMLstr, begAtr, EndAtr-begAtr);
end;

// ��������� ����
procedure TADOXMLFields.LoadXML(const AFileName: string);
begin
  if not Assigned(FStream) then FreeAndNil(FStream);
  FFileName:= AFileName;
  FStream:= TFileStream.Create(AFileName, fmOpenReadWrite);
  SetLength(XMLstr, FStream.Size);
  FStream.ReadBuffer(XMLstr[1], FStream.Size);
  SeekBegin;
end;

// �������� ��������� ����
function TADOXMLFields.NextField: boolean;
begin
  // ������ �����
  if endSchema=0 then
    raise EADOXMLParcerError.Create('���� �� �������� ���� ����� �������� ������.');
  beginCurField:= PosEx(cBegAtributes, XMLstr, endCurField) + Length(cBegAtributes);
  result:= not EOF;
  if result then
  begin
    endCurField:= PosEx(cEndAtributes, XMLstr, beginCurField);
  end;
end;

// �������� ����� ���� � �����
procedure TADOXMLFields.RecalcEndPos;
begin
  endSchema:= PosEx(cEndSchema, XMLstr, beginSchema);
  endCurField:= PosEx(cEndAtributes, XMLstr, beginCurField);
end;

// ��������� �� ����
procedure TADOXMLFields.SaveXML;
begin
  try
    FStream.Size:= Length(XMLstr);
    FStream.Seek(0, soFromBeginning);
    FStream.WriteBuffer(XMLstr[1], Length(XMLstr));
    beginSchema:= 0; endSchema:= 0; beginCurField:= 0; endCurField:= 0;
  finally
    FreeAndNil(FStream);
  end;
end;

// ������� �� ������
procedure TADOXMLFields.SeekBegin;
begin
  beginSchema:= Pos(cBegSchema, XMLstr) + Length(cBegSchema);
  endSchema:= PosEx(cEndSchema, XMLstr, beginSchema);
  beginCurField:= 0; endCurField:= beginSchema;
end;

// ���������� �������
procedure TADOXMLFields.SetAtribute(const FieldAtribut: TFieldAtributes;
  Value: string);
var
  begAtr, endAtr: integer;
begin
  if FindAtribute(FieldAtribut, begAtr, EndAtr) then
  begin
    Delete(XMLstr, begAtr, endAtr-begAtr);
    Insert(Value, XMLstr, begAtr);
  end else
    Insert(' ' + cStrFieldAtributes[FieldAtribut] + '=''' + Value + ''''
            , XMLstr, endCurField);
  RecalcEndPos;
end;

end.
