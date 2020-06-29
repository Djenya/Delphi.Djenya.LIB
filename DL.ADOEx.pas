unit DL.ADOEx;

interface

uses Windows, Messages, SysUtils, DB, Forms, Classes, Graphics, Controls,
  ExtCtrls, StdCtrls, ADODB, ADOInt, Variants, StrUtils, DL.ADOXMLParserUnit;

type
  TADODataSet = class;

  ///<summary>��������� - ���������� ��� ��������� ��������� ����</summary>
  TChangeFieldProc = procedure (Sender: TADODataSet; var ADOXMLField: TADOXMLFields) of object;

  ///<summary>ADO ������� � ��� �������������</summary>
  ///<remarks>
  ///  ��������� ������������ ��-� ���������� ����� �����. ����, ����
  ///  ���������� � commandtext; ��������� ��������� ������������
  ///  ��-� ����� ����� ���������� � XML (UseXML)
  ///</remarks>
  TADODataSet = class (ADODB.TADODataSet)
  private
    ///<summary>�������, �����. ������������ � ��������.</summary>
    Catalog, Schema: string;
    ///<summary> ������ �����������, ��������� ���������</summary>
    procedure SetCommandText(const Value: WideString);
    ///<summary>������� � ��������� XML</summary>
    procedure ChangeXML(FileName: string);
    function GetCommandText: WideString;
    function ReplaceLookupString(Str: WideString): WideString;
  protected
    FrozenScrool: boolean;
    FOldCommandText: string;
    FLastBufer: array of variant;
    FCopyBufer: array of variant;
    ///<summary> ��������� �������....</summary>
    procedure SetActive(Value: Boolean); override;
    procedure DoBeforeScroll; override;
    procedure DoAfterPost; override;
    procedure CopyLastField;
    ///<summary>������ is null �� =</summary>
    procedure SetFilterText(const Value: string); override;
  public
    ///<summary>������� ������� (--UC=...)</summary>
    UniqueCatalog: string;
    ///<summary>���������� ������� (--US=...)</summary>
    UniqueSchema: string;
    ///<summary>���������� ������� (--UT=...)</summary>
    UniqueTable: string;
    ///<summary>������� ������� (--RC=...)</summary>
    ResyncCommand: string;
    ///<summary>�������� ���������������� ���� (--AI=1, �� ���������)</summary>
    UseAutoIncrement: boolean;
    ///<summary>�������� ����� ������� � XML (--XML=1)</summary>
    UseXML: boolean;
    ///<summary>��������� ������������ ��-� ���� (��� useXML=1)</summary>
    OnChangeXMLField: TChangeFieldProc;
    ///<summary>��������� ���������� ��� �������� � Instead Of ��������</summary>
    procedure ChangeFieldPatern_InsteadOfView(Sender: TADODataSet; var ADOXMLField: TADOXMLFields);
    ///<summary>��������� ���������� ��� ������� ������ �������� �������������� (SQLServer2005)</summary>
    procedure ChangeFieldPatern_FixAutoIncrementBag(Sender: TADODataSet; var ADOXMLField: TADOXMLFields);
    ///<summary>��������� ���������� ��� ������� ������ �������� ����� (SQLServer2005)</summary>
    procedure ChangeFieldPatern_FixKeyFieldBag(Sender: TADODataSet; var ADOXMLField: TADOXMLFields);
    ///<summary>��������� ���������� ��� ������� ������ �������� �������������� (SQLServer2005)</summary>
    procedure ChangeFieldPatern_Null(Sender: TADODataSet; var ADOXMLField: TADOXMLFields);
    ///<summary>����������� ���� � �����</summary>
    procedure CopyFields;
    ///<summary>��������� ���� ���������� �� ������</summary>
    procedure PasteCopingFields(Fields: array of TField; OnlyIfNull: boolean=true);
    ///<summary>��������� ���� ���������� �� ������</summary>
    procedure PasteCopingFieldsStr(Fields: array of ShortString; OnlyIfNull: boolean=true);
    ///<summary>��������� ���� ���������� ����������</summary>
    procedure PasteLastFields(Fields: array of TField);
    ///<summary>��������� ���� ���������� ����������</summary>
    procedure PasteLastFieldsStr(Fields: array of ShortString);
    ///<summary>������� �� ��������� ������, � LastBufer �������� ������� �������� ����� ���������� ��������</summary>
    ///<remark>������������ ���� insert ������ ��������� ������ ���� �������</remark>
    procedure FrozenNext;
    ///<summary>�������� ���� �� ������ (���� ������ �����, ����� �������)</summary>
    function LastValue(FieldName: WideString): variant;
    ///<summary>���������� ���������� (������)</summary>
    procedure ProtectSort(ASort: WideString);
  published
    ///<summary>������ commandtext, ���������� ������� � ����������
    ///  ���������� UniqueTable, ResyncCommand, UseAutoIncrement, UseXML</summary>
    property CommandText: WideString read GetCommandText write SetCommandText;
    property OriginalCommandText: string read FOldCommandText;
  end;

function CheckDataSetForSaveData(DataSet: TDataSet) : integer;

implementation

resourcestring
  RES_Q_SAVE_DATA = '��������� ������ ��� �� ���� ���������.'#13'��������� ��������� ����� ���������?';
  RES_ER_POST = '�� ������� ��������� ��������� ���������';
  RES_Q_EXIT = '��� ����� ������� ��������?';

var
  TempDir: string;
  TempDirP: PChar;

function CheckDataSetForSaveData(DataSet: TDataSet): Integer;
//���� ���������� 0 �� ������ ������ ������
var res: Integer;
begin
  if DataSet.State in [dsEdit, dsInsert] then
  begin
    res := Application.MessageBox(
             PChar(RES_Q_SAVE_DATA),
             '��������������', MB_YESNOCANCEL + MB_ICONEXCLAMATION);
    case res of
      IDYES:
      begin
        try
          DataSet.Post;
          Result := IDYES;
        except
          case Application.MessageBox(
               PChar(RES_ER_POST + #10#13 + RES_Q_EXIT),
               '������ ����������...', MB_YESNO + MB_ICONQUESTION) of
            ID_NO: Result := IDCANCEL;
            ID_YES:
            begin
              DataSet.Cancel;
              Result := IDNO;
            end;
          end;
        end;
      end;
      IDNO:
      begin
        DataSet.Cancel;
        Result := IDNO;
      end;
      IDCancel: Result := IDCANCEL;
    end;
  end;
end;

{ TADODataSet }

function TADODataSet.GetCommandText: WideString;
begin
  result:= inherited GetCommandText;
end;

procedure TADODataSet.SetCommandText(const Value: WideString);
  function GetParam(param: string): shortstring;
  var
    posbeg, posend: integer;
  begin
    posbeg:= Pos('--'+param+'=', Value);
    if posbeg > 0 then
    begin
      posbeg:= posbeg + 3 + Length(param);
      posend:= PosEx(#13#10, Value, posbeg);
      if posend = 0 then posend:= Length(Value) + 1;
      result:= MidStr(Value, posbeg, posend-posbeg);
    end else result:= '';
  end;
begin
  UniqueCatalog:=GetParam('UC');
  UniqueTable:=GetParam('UT');
  UniqueSchema:=GetParam('US');
  ResyncCommand:=GetParam('RC');
  UseXML:= GetParam('XML')='1';
  UseAutoIncrement:= not (GetParam('AI')='0');
  // ������ �� ������ ������ ������ - ������� �������, ���� ��� � � ��������
  // �������!!!
   FOldCommandText:= StringReplace(Value, '--RC=' + ResyncCommand, '', [rfReplaceAll]) + #13#10;
 inherited SetCommandText(FOldCommandText + #13#10);
end;

procedure TADODataSet.SetFilterText(const Value: string);
begin
  inherited SetFilterText(ReplaceStr(ReplaceStr(Value, 'IS NOT NULL', '<> null'), 'IS NULL', '= null'));
end;

procedure TADODataSet.SetActive(Value: Boolean);
var
  FileName: string;
  Oldactive: boolean;
begin
  FrozenScrool:= false;
  Oldactive:= Active;
  inherited SetActive(Value);
  if Oldactive <> Value then
  begin
    // ��������
    if not Value and UseXML then
    begin
      // ����������� ����������� ���� ��� xml
      CommandType:= cmdText;
      inherited SetCommandText(FOldCommandText);
      Finalize(FLastBufer);
      Finalize(FCopyBufer);
    end;
    // ��������
    if Value and Assigned(Properties) then
    begin
      // ������ ���������
      if UniqueCatalog <> '' then
        Properties['Unique Catalog'].Value:= UniqueCatalog;
      if UniqueTable <> '' then
        Properties['Unique Table'].Value:= UniqueTable;
      if UniqueSchema <> '' then
        Properties['Unique Schema'].Value:= UniqueSchema;
      if ResyncCommand <> '' then
        Properties['Resync Command'].Value:= ResyncCommand;
      Properties['Update Resync'].Value:= adResyncInserts + adResyncUpdates;
      if UseAutoIncrement then
        Properties['Update Resync'].Value:= Properties['Update Resync'].Value
                                        + adResyncAutoIncrement;
      Properties['Update Criteria'].Value:= adCriteriaKey;
      // ���������� XML �� ���������
      if UseXML and not Assigned(OnChangeXMLField) then OnChangeXMLField:= ChangeFieldPatern_InsteadOfView;
      // �������� ����� XML
      if UseXML then
      begin
        // xml
        FileName:= TempDir + 'XMLcash\' + FormatDateTime('nnsszzz', time) + Name + '.xml';
        CreateDir(ExtractFileDir(FileName));
        SaveToFile(FileName, pfXML);
        inherited SetActive(false);
        ChangeXML(FileName);
        CommandType:= cmdFile;
        inherited SetCommandText(FileName);
        inherited SetActive(true);
        {$ifndef debug}
        DeleteFile(pchar(FileName));
        {$endif}
      end;
      SetLength(FLastBufer, FieldCount);
      SetLength(FCopyBufer, FieldCount);
      CopyLastField;
    end;
    if not value then
    begin
      SetLength(FLastBufer, 0);
    end;
  end;
end;

// ������ XML, �������� ���������� ��� ��������� ���������
procedure TADODataSet.ChangeXML(FileName: string);
var
  XML: TADOXMLFields;
begin
  try
    {$IFDEF OldDelphi} XML:= TADOXMLFields.Create; {$ENDIF}
    XML.LoadXML(FileName);
    while XML.NextField do
    begin
      if Assigned(OnChangeXMLField) then
        OnChangeXMLField(Self, XML);
    end;
  finally
    XML.SaveXML;
    {$IFDEF OldDelphi} FreeAndNil(XML) {$ENDIF}
  end;
end;

procedure TADODataSet.DoAfterPost;
begin
  inherited;
  CopyLastField;
end;

procedure TADODataSet.DoBeforeScroll;
begin
  inherited;
  if not FrozenScrool then CopyLastField;
  FrozenScrool:= false;
end;

// ������������ ���� insert ������ ��������� ������ ���� �������
procedure TADODataSet.FrozenNext;
begin
  Next;
  FrozenScrool:= true;
end;

function TADODataSet.LastValue(FieldName: WideString): variant;
begin
  result:= null;
  if Length(FLastBufer) = FieldCount then
  begin
    result:= FLastBufer[FindField(FieldName).Index];
  end;
end;

// ����������� ���� � �����
procedure TADODataSet.CopyFields;
var
  Field: TField;
  i: integer;
begin
  if RecordCount > 0 then
    if Length(FCopyBufer) = FieldCount then
      for I := 0 to Fields.Count - 1 do
      begin
        Field:= Fields[i];
        //FCopyBufer[Field.Index]:= Field.Value;
        FCopyBufer[i]:= Field.Value;
      end;
end;

// ��������� ���� ���������� �� ������
procedure TADODataSet.PasteCopingFields(Fields: array of TField;
  OnlyIfNull: boolean);
var
  Field: TField;
  ro: boolean;
  i: integer;
begin
  if Active and (State in [dsEdit, dsInsert]) then
    for I := 0 to Length(Fields) - 1 do
    begin
      Field:= Fields[i];
      if Field.DataSet = Self then
        if Field.IsNull or not OnlyIfNull then
        begin
          ro:= Field.ReadOnly;
          Field.ReadOnly:= false;
          if not VarIsClear(FCopyBufer[Field.Index]) then
            Field.Value:= FCopyBufer[Field.Index];
          Field.ReadOnly:= ro;
        end;
    end;
end;

// ��������� ���� ���������� �� ������
procedure TADODataSet.PasteCopingFieldsStr(Fields: array of ShortString;
  OnlyIfNull: boolean);
var
  Field: TField;
  i: integer;
  ro: boolean;
begin
  if Active and (State in [dsEdit, dsInsert]) then
    for i:= 0 to length(Fields) - 1 do
    begin
      Field:= FieldByName(Fields[i]);
      if Field.IsNull or not OnlyIfNull then
      begin
        ro:= Field.ReadOnly;
        Field.ReadOnly:= false;
        if not VarIsClear(FCopyBufer[Field.Index]) then
          Field.Value:= FCopyBufer[Field.Index];
        Field.ReadOnly:= ro;
      end;
    end;
end;

procedure TADODataSet.CopyLastField;
var
  Field: TField;
  i: integer;
begin
  if RecordCount > 0 then
    if Length(FLastBufer) = FieldCount then
    try
      for I := 0 to Fields.Count - 1 do
      begin
        Field:= Fields[i];
        //FLastBufer[Field.Index]:= Field.Value;
        FLastBufer[i]:= Field.Value;
      end;
    except
    end;
end;

// ��������� ���� ���������� ����������
procedure TADODataSet.PasteLastFields(Fields: array of TField);
var
  Field: TField;
  ro: boolean;
  i: integer;
begin
  if Active and (State in [dsEdit, dsInsert]) then
    for I := 0 to Length(Fields) - 1 do
    begin
      Field:= Fields[i];
      if Field.DataSet = Self  then
      begin
        ro:= Field.ReadOnly;
        Field.ReadOnly:= false;
        if not VarIsClear(FLastBufer[Field.Index]) then
          Field.Value:= FLastBufer[Field.Index];
        Field.ReadOnly:= ro;
      end;
    end;
end;

// ��������� ���� ���������� ����������
procedure TADODataSet.PasteLastFieldsStr(Fields: array of ShortString);
var
  Field: TField;
  i: integer;
  ro: boolean;
begin
  if Active and (State in [dsEdit, dsInsert]) then
    for i:= 0 to length(Fields) - 1 do
    begin
      Field:= FieldByName(Fields[i]);
      ro:= Field.ReadOnly;
      Field.ReadOnly:= false;
      if not VarIsClear(FLastBufer[Field.Index]) then
        Field.Value:= FLastBufer[Field.Index];
      Field.ReadOnly:= ro;
    end;
end;

procedure TADODataSet.ProtectSort(ASort: WideString);
begin
  Sort:= ReplaceLookupString(ASort);
end;

function TADODataSet.ReplaceLookupString(Str: WideString): WideString;
var
  Field: TField;
begin
  Result:= Str;
  for Field in Fields do
    if (Field.FieldKind = fkLookup) and (RightStr(Field.FieldName, 4)='_lkp') then
      Result:= ReplaceStr(Result, Field.FieldName, LeftStr(Field.FieldName, Length(Field.FieldName)-4));
end;

// ������ ��� ������� ���� ������ �������� faAutoIncrement � 2005
procedure TADODataSet.ChangeFieldPatern_FixAutoIncrementBag(Sender: TADODataSet;
  var ADOXMLField: TADOXMLFields);
begin
  if ADOXMLField.GetAtribute(faName) = 'id' then
  begin
    ADOXMLField.SetAtribute(faKey, 'true');
    ADOXMLField.SetAtribute(faAutoIncrement, 'true');
  end;
end;

// ������ ��� ���������� �������� � insteadof ��������
procedure TADODataSet.ChangeFieldPatern_FixKeyFieldBag(Sender: TADODataSet;
  var ADOXMLField: TADOXMLFields);
begin
  if ADOXMLField.GetAtribute(faName) = 'id' then
  begin
    ADOXMLField.SetAtribute(faKey, 'true');
  end;
end;

procedure TADODataSet.ChangeFieldPatern_InsteadOfView(Sender: TADODataSet; var ADOXMLField: TADOXMLFields);
var
  NameField: string;
begin
  with ADOXMLField do
  begin
    NameField:= GetAtribute(faName);
    // �������� ����
    // ������ ���� �� ���������� ����� ��� ���������� ����� � ��������!!!
    if NameField = 'id' then
    begin
      if Sender.UniqueTable <> '' then
        SetAtribute(faTable, Sender.UniqueTable); //only 2005
      SetAtribute(faKey, 'true');
      SetAtribute(faAutoIncrement, 'true');
      SetAtribute(faColumn, 'id');
      Catalog:= GetAtribute(faCatalog);
      if Sender.UniqueSchema = '' then
        Schema:= GetAtribute(faSchema)
      else Schema:= Sender.UniqueSchema;
    end else if (leftStr(NameField, 4) <> 'calc') then
    begin
      // �� ��������������
      if Sender.UniqueTable <> '' then
        SetAtribute(faTable, Sender.UniqueTable); //only 2005
      SetAtribute(faColumn, NameField);
      if Catalog <> '' then  //only 2005
        SetAtribute(faCatalog, Catalog);
      if Schema <> '' then  //only 2005
        SetAtribute(faSchema, Schema);
      SetAtribute(faWritable, 'true');
    end else begin // ��������������
      DelAtribute(faWritable);
    end;
  end;
end;

procedure TADODataSet.ChangeFieldPatern_Null(Sender: TADODataSet;
  var ADOXMLField: TADOXMLFields);
begin

end;

initialization
  TempDirP:='';
  try
    GetMem(TempDirP, MAX_PATH);
    GetTempPath(MAX_PATH,TempDirP);
    TempDir:=StrPas(TempDirP);
    finally
    FreeMem(TempDirP);
  end;

finalization

end.
