unit DL.MDIFormChildUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ADODB, DB;

type
  TDLMDIFormChild = class(TForm)
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses DL.MDIFormMainUnit, DL.ADOEx;

{$R *.dfm}

procedure TDLMDIFormChild.FormActivate(Sender: TObject);
begin
  if (Application.MainForm is TDLMDIFormMain) then
    TDLMDIFormMain(Application.MainForm).ActivateTab(Self);
end;

procedure TDLMDIFormChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Application.MainForm is TDLMDIFormMain) then
    with TDLMDIFormMain(Application.MainForm) do
      TabSet.Tabs.Delete(TabSet.Tabs.IndexOfObject(Self));

  Action := caFree;
end;

procedure TDLMDIFormChild.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i: Integer;
begin
  for i:= 0 to ComponentCount - 1 do
  begin
    if (Components[i] Is TDataSet)
    or (Components[i] Is ADODB.TADODataSet) then
    begin
      if (CheckDataSetForSaveData(TDataSet(Components[i])) = IDCANCEL) then
        CanClose := False;
    end;
  end;
end;

end.
