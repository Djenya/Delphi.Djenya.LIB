///<summary>Сервисные функции ADO</summary>
unit DL.Helpers.ADOUnit;

{ $define EhLib}

interface

uses ADODB, Classes, {$ifdef EhLib}DBGridEh,{$endif} DB, ExtCtrls;

type
  TDynamicArray = array of TADODataSet;
  ///<summary>Сервисные функции над набором датасетов</summary>
  TADOFunc = class abstract
    ///<summary>проверка перед сохранением</summary>
    class procedure VerifyIsNull(Fields: array of TField{$ifdef EhLib}; grd: TDBGridEh = nil{$endif}); static;
    ///<summary>Пост датасетов</summary>
    class procedure Save(DSarray: array of TADODataSet; CanBachUpdate: boolean = true); static;
    ///<summary>Cancel датасетов</summary>
    class procedure Cancel(DSarray: array of TADODataSet); static;
    ///<summary>переоткрыть датасеты с сохранением сортировки</summary>
    class procedure Refresh(DSarray: array of TADODataSet; LocateFieldArray: array of Variant); static;
    ///<summary>Пост датасетов</summary>
    class procedure SaveDinArray(DSarray: TDynamicArray; CanBachUpdate: boolean = True); static;
    ///<summary>переоткрыть датасеты с сохранением сортировки</summary>
    class procedure RefreshDinArray(DSarray: TDynamicArray); static;
  end;

  ///<summary>Обработчики событий</summary>
  TADODataSetEvents = class helper for TADODataSet
    ///<summary>Редактирование времени</summary>
    procedure OnSetText_Time(Sender: TField; const Text: string);
  end;

  ///<summary>Сервисные функции</summary>
  TADODataSetHelper = class helper (TADODataSetEvents) for TADODataSet
    ///<summary>фильтрация по контралам на панели</summary>
    procedure FilterFromPanel(pnl: TPanel; OldFilter: string='');
    ///<summary>параметры по контралам на панели</summary>
    procedure ParamsFromPanel(pnl: TPanel);
    ///<summary>настройка</summary>
    procedure Tune;
    procedure BeforeDelete_Question(DataSet: TDataSet);
    ///<summary>Сортировка (при наличии поля SortOrder)</summary>
    function MoveSortRecord(Up: boolean): boolean;
  end;

implementation

uses StrUtils, ADOInt, SysUtils, windows, Variants, Controls,
    {$ifdef EhLib} DBCtrlsEh, {$endif} StdCtrls, Forms;

// переоткрыть датасеты с сохранением сортировки
class procedure TADOFunc.Refresh(DSarray: array of TADODataSet; LocateFieldArray: array of Variant);
var
  DS: TADODataSet;
  LocateField: Variant;

  ASort: string;
  AFiltr: string;
  LocateValue: Variant;
  indexFor: integer;
begin
  indexFor:= 0;
  for DS in DSarray do
  begin
    AFiltr:= '';
    ASort:= DS.Sort;
    if DS.Filtered then
      AFiltr:= DS.Filter;
    DS.Filter:= ''; DS.Filtered:= False;

    LocateField:= LocateFieldArray[indexFor];
    if (LocateField <> Null) and (ds.Active) then
      LocateValue:= ds.FieldByName(LocateField).Value;

    ds.Close;
    ds.Open;
    DS.Filter:= AFiltr;
    if AFiltr <> '' then
      DS.Filtered:= true;
    DS.Sort:=  ASort;

    if LocateField <> Null then
      ds.Locate(LocateField, LocateValue, []);

    Inc(indexFor);
  end;
end;

class procedure TADOFunc.RefreshDinArray(DSarray: TDynamicArray);
var
  DS: TADODataSet;
  ASort: string;
  AFiltr: string;
begin
  for DS in DSarray do
  begin
    ASort:= DS.Sort;
    if DS.Filtered then
      AFiltr:= DS.Filter;
    DS.Filter:= ''; DS.Filtered:= false;
    ds.Close;
    ds.Open;
    DS.Filter:= AFiltr;
    if AFiltr <> '' then
      DS.Filtered:= true;
    DS.Sort:=  ASort;
  end;
end;

// Пост датасетов
class procedure TADOFunc.Save(DSarray: array of TADODataSet; CanBachUpdate: boolean = true);
var DS: TDataSet;
begin
  for DS in DSarray do
    if DS.Active then
    begin
      if DS.State in [dsInsert, dsEdit] then
        DS.Post;
      if CanBachUpdate and (TADODataSet(DS).LockType = ltBatchOptimistic) then
        TADODataSet(DS).UpdateBatch(arAll);
    end;
end;

// Cancel датасетов
class procedure TADOFunc.Cancel(DSarray: array of TADODataSet);
var DS: TDataSet;
begin
  for DS in DSarray do
    if DS.Active then
    begin
      if DS.State in [dsInsert, dsEdit] then
        DS.Cancel;
    end;
end;

class procedure TADOFunc.SaveDinArray(DSarray: TDynamicArray; CanBachUpdate: boolean = true);
var DS: TDataSet;
begin
  for DS in DSarray do
  begin
    if DS.State in [dsInsert, dsEdit] then
      DS.Post;
    if CanBachUpdate and (TADODataSet(DS).LockType = ltBatchOptimistic) then
      TADODataSet(DS).UpdateBatch(arAll);
  end;
end;

// проверка перед сохранением
class procedure TADOFunc.VerifyIsNull;
var
  Field: TField;
  ErrStr: string;
  ErrField: TField;
begin
  ErrField:= nil;
  for Field in Fields do
    if ((Field.IsNull) or (Field.AsString = '')) then
    begin
      if Field.DisplayName <> '.' then
        ErrStr:= ErrStr + Field.DisplayName + ', ';
      {$ifdef EhLib}
        if (ErrField = nil) and Assigned(grd) and grd.Visible
            and Assigned(grd.FieldColumns[Field.FieldName])
            and grd.FieldColumns[Field.FieldName].Visible then
        begin
          ErrField:= Field;
          grd.SelectedField:= ErrField;
        end;
      {$ENDIF}
    end;
  if ErrStr <> '' then
    raise Exception.Create('Перед сохранением заполните поля '
                                          + leftstr(ErrStr, Length(ErrStr)-2));
end;

{ TADODataSetHelper }

procedure TADODataSetHelper.BeforeDelete_Question(DataSet: TDataSet);
begin
  if Application.MessageBox(pchar('Вы уверенны, что хотите удалить эту запись'),
                                pchar('Удаление записи...'),
                                 MB_YESNO+MB_ICONQUESTION
                                 ) <> id_yes then
    abort;
end;

procedure TADODataSetHelper.FilterFromPanel(pnl: TPanel; OldFilter: string);
var
  cntr: TControl;
  i: integer;
  str: string;
begin
  Filtered:= false;
  Filter:= OldFilter;
  for i:=0 to pnl.ControlCount - 1 do
  begin
    cntr:= pnl.Controls[i];
    if cntr.Parent = pnl then
    begin
      str:= '';
      if (cntr is TCustomEdit) and (trim(TCustomEdit(cntr).Text) <> '') then
        str:= ' like ''%' + TCustomEdit(cntr).Text + '%'''
      {$ifdef EhLib}
      else if cntr is TCustomDBDateTimeEditEh then
        str:= ' = ''' + VarToStr(TCustomDBDateTimeEditEh(cntr).Value) + ''''
      {$ENDIF}
      else if cntr is TCheckBox then
        str:= ' = ' + BoolToStr(TCheckBox(cntr).Checked);
      if (str <> '') and (Assigned(FindField(RightStr(cntr.Name, Length(cntr.Name)-3)))) then
        if Filter = '' then
          Filter:= RightStr(cntr.Name, Length(cntr.Name)-3) + str
        else
          Filter:= Filter + ' AND ' + RightStr(cntr.Name, Length(cntr.Name)-3) + str;
    end;
  end;
  Filtered:= Filter <> '';
end;

function TADODataSetHelper.MoveSortRecord(Up: boolean): boolean;
var
  bm: TBookmark;
  CurSort, NewSort: integer;
begin
  Result:= false;
  if Active and (Sort='SortOrder') then
  begin
    if State = dsBrowse then Edit;
    if State in [dsEdit, dsInsert] then Post; 
    if (Up and not bof) or (not Up and not Eof) then
    try
      DisableControls;
      bm:= GetBookmark;
      CurSort:= FieldByName('SortOrder').AsInteger;
      if Up then Prior else Next;
      NewSort:= FieldByName('SortOrder').AsInteger;
      Edit;
      FieldByName('SortOrder').AsInteger:= CurSort;
      try
        Post;
      finally
        if State = dsEdit then Cancel; // Если при посте ошибка, то отменить вставленный SortOrder и выйти
      end;
      GotoBookmark(bm);
      Edit;
      FieldByName('SortOrder').AsInteger:= NewSort;
      Post;
    finally
      EnableControls;
    end;
  end;
end;

procedure TADODataSetHelper.ParamsFromPanel(pnl: TPanel);
var
  cntr: TControl;
  param: TParameter;
  i: integer;
begin
  for i:= 0 to pnl.ControlCount - 1 do
  begin
    cntr:= pnl.Controls[i];
    if cntr.Parent = pnl then
    begin
      param:= Parameters.FindParam(RightStr(cntr.Name, Length(cntr.Name)-3));
      if Assigned(param) then
        if cntr is TPanel then
          ParamsFromPanel(TPanel(cntr))
        {$ifdef EhLib}
        else if cntr is TDBDateTimeEditEh then
          param.Value:= TDBDateTimeEditEh(cntr).Value
        else if cntr is TCustomDBEditEh then
          param.Value:= TCustomDBEditEh(cntr).Value
        {$ENDIF}
        else if cntr is TCustomEdit then
          param.Value:= TCustomEdit(cntr).Text
        else if cntr is TCheckBox then
          param.Value:= TCheckBox(cntr).Checked;
    end;
  end;
end;

procedure TADODataSetHelper.Tune;
var
  Field: TField;
begin
  if not Assigned(BeforeDelete) then BeforeDelete:= BeforeDelete_Question;
  // упрощенное редактирование времени
  for Field in Fields do
    if (Field is TDateTimeField) and not Assigned (Field.OnSetText) then
      Field.OnSetText:= OnSetText_Time;
end;

{ TADODataSetEvents }

procedure TADODataSetEvents.OnSetText_Time(Sender: TField; const Text: string);
begin
  if Sender.IsNull then Sender.Value:= 2;
  try
    // нул
    if Text='' then
      Sender.Value:= null
    // время
    else if Pos('.', Text) = 0 then
      Sender.Value:= Trunc(Sender.Value) + StrToTime(StringReplace(Text, '+', ':', [rfReplaceAll]))
    // дата
    else if (Pos('+', Text) = 0) and (Pos(':', Text) = 0) then
      Sender.Value:= Sender.Value - Trunc(Sender.Value) + StrToDate(Text)
    // усе подряд
    else
      Sender.Value:= StrToDateTime(StringReplace(Text, '+', ':', [rfReplaceAll]));
  except
    raise EConvertError.Create('Не верный формат даты ' + StringReplace(Text, '+', ':', [rfReplaceAll]));
  end;
end;

end.
