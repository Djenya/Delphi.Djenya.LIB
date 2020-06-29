unit DL.frmReferenceUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, GridsEh, DBGridEh, DB, StdCtrls, ActnList, Buttons,
  DBGridEhGrouping, Mask, DBCtrlsEh, DateUtils, DBLookupEh, ADODB, DBCtrls,
  ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, DBAxisGridsEh;

type
  TDLfrmReference = class(TForm)
    pnlButon: TPanel;
    pnlFilter: TPanel;
    pnlContent: TPanel;
    dsContent: TDataSource;
    btnCancel: TButton;
    btnOk: TButton;
    Label1: TLabel;
    edtFilter: TEdit;
    btnFind: TButton;
    mnActionList: TActionList;
    dbNavigatorContent: TDBNavigator;
    cmdSave: TAction;
    cmdCancel: TAction;
    cmdRefresh: TAction;
    grdContent: TDBGridEh;
    procedure grdContentSortMarkingChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtFilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cmdRefreshExecute(Sender: TObject);
    procedure edtFilterChange(Sender: TObject);
    procedure cmdSaveExecute(Sender: TObject);
    procedure cmdCancelExecute(Sender: TObject);
    procedure grdContentDblClick(Sender: TObject);
  private
    DataSet: TADODataSet;
    NameParametrFilter: string;
    isReadOnly: Boolean;
    procedure OnKeyPress_Lookup(Sender: TObject; var Key: Char);
  public
    constructor СreateReference(AOwner: TComponent; RO: Boolean; Asql: TADODataSet;
      ANameParametrFilter: string; AVisiblePnlButton: Boolean = True);
  end;

const
  cColorReadOnly = $00F4FFFF;

implementation

{$R *.dfm}

uses StrUtils;

{ TfrmReference }

procedure TDLfrmReference.cmdCancelExecute(Sender: TObject);
begin
  if DataSet.State in [dsInsert, dsEdit] then DataSet.Cancel;
end;

procedure TDLfrmReference.cmdRefreshExecute(Sender: TObject);
begin
  try
    DataSet.DisableControls;
    DataSet.Close;
    DataSet.Parameters.ParamByName(NameParametrFilter).Value := edtFilter.Text;
    DataSet.Open;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TDLfrmReference.cmdSaveExecute(Sender: TObject);
begin
  if isReadOnly = False then
  begin
    if DataSet.State in [dsInsert, dsEdit] then DataSet.Post;
  end;
end;

procedure TDLfrmReference.edtFilterChange(Sender: TObject);
begin
  if pnlFilter.Visible then cmdRefresh.Execute;
end;

procedure TDLfrmReference.edtFilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //Двигаемся по гриду
  with grdContent do
    case Key of
      $21: begin Key:=0; Perform($0115, SB_PAGEUP, 0); (Sender as TWinControl).SetFocus; end;
      $22: begin Key:=0; Perform($0115, SB_PAGEDOWN, 0); (Sender as TWinControl).SetFocus; end;   //PAGE UP key
      $23: begin Key:=0; Perform($0115, SB_BOTTOM, 0); (Sender as TWinControl).SetFocus; end;
      $24: begin Key:=0; Perform($0115, SB_TOP, 0); (Sender as TWinControl).SetFocus; end;
      $26: begin Key:=0; Perform($0100, $26 {SB_LINEUP}, 0); (Sender as TWinControl).SetFocus; end;
      $28: begin Key:=0; Perform($0100, $28 {SB_LINEDOWN}, 0); (Sender as TWinControl).SetFocus; end;
    end;
  // По энтеру рефреш или выбор или автовставка или на грид
  if Key = VK_RETURN then
  begin
    Key:= 0;
    cmdSave.Execute;
    if (pnlButon.Visible) and (btnOk.Enabled) then btnOk.Click // выбрать данные
    else grdContent.SetFocus; // перейти на грид
  end;
end;

procedure TDLfrmReference.OnKeyPress_Lookup(Sender: TObject; var Key: Char);
var
  handled: boolean;
  column: TColumnEh;
begin
  if (Sender is TDBGridEh) and (Sender as TDBGridEh).DataSource.DataSet.Active and
        not TDBGridEh(Sender).ReadOnly then
  begin
    column:= TDBGridEh(Sender).Columns[TDBGridEh(Sender).SelectedIndex];
    if (Key = '.') or (Key=',') then
      if not (column.Field is TStringField) then      
        Key:= DecimalSeparator;
    // кнопка
    if (Key = #10) and Assigned(column.OnEditButtonClick) then
    begin
      column.Field.FocusControl;
      column.OnEditButtonClick(Sender, handled);
      Key:= #0;
      exit;
    // лукап
    end else // кнопка
    if (Key > #27) and Assigned(column.OnEditButtonClick) and (column.ReadOnly) then
    begin
      column.Field.FocusControl;
      column.OnEditButtonClick(Sender, handled);
      exit;
    end else if (Key = #10) and (column.Field.FieldKind = fkLookup) then
    begin
      column.Field.FocusControl;
      column.DropDown;
      Key:= #0;
      exit;
    // дата
    end else if (Key = #10) and (column.Field.FieldKind = fkData) then
    begin
      column.Field.FocusControl;
      column.DropDown;
      Key:= #0;
      exit;
    // пиклист
    end else if (Key = #10) and (column.PickList.Count > 0) then
    begin
      column.Field.FocusControl;
      column.DropDown;
      Key:= #0;
      exit;
    end;
  end;
end;

procedure TDLfrmReference.FormCreate(Sender: TObject);
var
  i: integer;
begin
  try
    DataSet.Close;
    DataSet.Parameters.ParamByName(NameParametrFilter).Value := '';
    DataSet.Open;
  except
    Application.MessageBox(pchar('Не найден параметр "' + NameParametrFilter + '". Поток данных не был открыт!'),
                           pchar('Ошибка инициализации справочника'), MB_ICONERROR+MB_OK);
    Abort; Exit;
  end;
  dsContent.DataSet := DataSet;

  with grdContent do
  begin
    Flat:= True;
    FooterColor:= cColorReadOnly;
    UseMultiTitle:= True;
    Options:= Options - [dgConfirmDelete];
    Options:= Options - [dgTabs];
    OptionsEh:= OptionsEh + [dghEnterAsTab];
    // сортировка
    OptionsEh:= OptionsEh + [dghAutoSortMarking];
    OptionsEh:= OptionsEh + [dghMultiSortMarking];
    // только чтение
    ReadOnly := isReadOnly;
    if ReadOnly then
    begin
      Options:= Options - [dgEditing];
      //Options:= Options - [dgIndicator];
      Options:= Options + [dgRowSelect];
    end else begin
      Options:= Options + [dgEditing];
      //Options:= Options + [dgIndicator];
      Options:= Options - [dgRowSelect];
      Options:= Options + [dgEditing];
    end;

    ColumnDefValues.Title.TitleButton:= SortLocal;
    for i:= 0 to Columns.Count - 1 do
    with Columns[i] do
    begin
      AlwaysShowEditButton:= True;
      if (Color = clWindow) or (Color = cColorReadOnly) then
      begin
        // раскрасить если уже не раскрашено
        if ReadOnly or not Assigned(Field) or Field.ReadOnly
        then Color:= cColorReadOnly
        else Color:= clWindow;
      end;
    end;
    // обработка нажатия клавиш на лукапном поле
    if not ReadOnly and (not Assigned(OnKeyPress)) then
      OnKeyPress:= OnKeyPress_Lookup;
    Font.Color:= clWindowText;
  end;

  with dbNavigatorContent do
  begin
    if isReadOnly
    then VisibleButtons :=  VisibleButtons - [nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
    else VisibleButtons :=  VisibleButtons + [nbInsert, nbDelete, nbEdit, nbPost, nbCancel];
  end;
end;


procedure TDLfrmReference.grdContentDblClick(Sender: TObject);
begin
  if pnlButon.Visible and btnOk.Enabled then btnOk.Click;
end;

procedure TDLfrmReference.grdContentSortMarkingChanged(Sender: TObject);
//сортировка грида при щелчке на его заголовке
var
  i: integer;
  s: string;
begin
 if (Sender is TDBGridEh) then
  with TDBGridEh(Sender) do
  begin
   for i := 0 to SortMarkedColumns.Count - 1 do
    if SortMarkedColumns[i].Title.SortMarker = smUpEh then
    begin
     if SortMarkedColumns[i].Field.FieldKind = fkLookup then
      s := s + SortMarkedColumns[i].FieldName + '_LookupSort DESC, '
     else s := s + SortMarkedColumns[i].FieldName + ' DESC, '
    end
     else
      if SortMarkedColumns[i].Field.FieldKind = fkLookup then
       s := s + SortMarkedColumns[i].FieldName + '_LookupSort, '
      else s := s + SortMarkedColumns[i].FieldName + ', ';

   if s <> '' then s := Copy(s, 1, Length(s) - 2);

   (DataSource.DataSet as TADODataSet).Sort := s
  end;
end;

constructor TDLfrmReference.СreateReference(AOwner: TComponent; RO: Boolean; Asql: TADODataSet;
  ANameParametrFilter: string;  AVisiblePnlButton: Boolean = True);
begin
  inherited Create(AOwner);

  isReadOnly := RO;
  DataSet := Asql;
  NameParametrFilter := ANameParametrFilter;
  pnlButon.Visible := AVisiblePnlButton;
end;

end.
