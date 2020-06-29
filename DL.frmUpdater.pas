unit DL.frmUpdater;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, ADODB, DB, StdCtrls, Buttons, DL.DataModul, DL.MDIFormMainUnit;

type
  TDLfrmUpdate = class(TForm)
    Image1: TImage;
    CloseButton: TSpeedButton;
    imgIconProg: TImage;
    TimerS: TTimer;
    lblCaption: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblVLocal: TLabel;
    lblVServer: TLabel;
    DownloadButton: TSpeedButton;
    CancelBotton: TSpeedButton;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerSTimer(Sender: TObject);
    procedure DownloadButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CancelBottonClick(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseLeave(Sender: TObject);
  private
    LeftCur, LeftMin: Integer;
    FFormMain: TDLMDIFormMain;
    class var FDataModul: TDLdmMain;
  public
    class property DataModul: TDLdmMain read FDataModul write FDataModul;
  end;

var
  DLfrmUpdate: TDLfrmUpdate;

implementation

uses ShellAPI, GlobalConstUnit, DL.XUpdater;

{$R *.dfm}

procedure TDLfrmUpdate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AnimateWindow(Handle, 500, AW_HOR_POSITIVE or AW_HIDE);
  Action := caFree;
  DLfrmUpdate := Nil;
end;

procedure TDLfrmUpdate.FormCreate(Sender: TObject);
var Reg: HRGN;
    bmp: TBitmap;
begin
  if Application.MainForm is TDLMDIFormMain then
    FFormMain := TDLMDIFormMain(Application.MainForm)
  else begin
    FFormMain := nil;
    Self.Close;
  end;

  //установление региона формы по картинке
  bmp := TBitMap.Create;
  LoadBmpToBitmap(bmp, 'FRMUPDATE', 'MASK_U');
  Reg := CreateBitmapRgn(bmp.Canvas.Handle, bmp.Handle, clWhite);
  SetWindowRgn(self.Handle, Reg, true);
  DeleteObject(Reg);
  if Assigned(bmp) then
    bmp.Free;

  //загрузка картинки
  bmp := TBitMap.Create;
  LoadBmpToBitmap(bmp, 'FRMUPDATE', 'IMAGE_U');
  Image1.Picture.Bitmap.Assign(bmp);

  lblCaption.Caption:= 'ƒоступна нова€ верси€ программы' + #10#13 + '"' + cEng_NameProg + '"';
  // версии продуктов, подт€нуть из переменных
  lblVLocal.Caption := GetFileVersionString(Application.ExeName);
  with FDataModul.sqlUpdateProgram do
  begin
    if Active = False then Open;
    lblVServer.Caption := FieldByName(cUpdate_VerField).AsString;
  end;

  // иконка приложени€
  imgIconProg.Picture.Icon.Handle := ExtractIcon(HInstance, Pchar(Paramstr(0)), 0);
  imgIconProg.Top := (Image1.Height div 2) - (imgIconProg.Height div 2);
  imgIconProg.BringToFront;

  // плавное отображение формы(выезжание)
  Top  := Screen.WorkAreaHeight - Height - 25;
  Left := Screen.WorkAreaWidth;
  LeftCur := Left;
  LeftMin := Screen.WorkAreaWidth - Width - 5;
  TimerS.Enabled := True;
end;

procedure TDLfrmUpdate.FormMouseLeave(Sender: TObject);
begin
  Self.AlphaBlend := True;
end;

procedure TDLfrmUpdate.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ((X >= 0) and (X <= Self.Width)) and
     ((Y >= 0) and (Y <= Self.Height)) then
  begin
    Self.AlphaBlend := False;
  end;
end;

procedure TDLfrmUpdate.DownloadButtonClick(Sender: TObject);
begin
  DownloadBinary(FDataModul.cnMain, True, False);
  Close;
end;

// ѕолучаем высоту "“аскЅара"
function TaskBarHeight: integer;
var
  hTB: HWND;
  TBRect: TRect;
begin
  hTB:= FindWindow('Shell_TrayWnd', '');
  if hTB = 0 then
    Result := 0
  else begin
    GetWindowRect(hTB, TBRect);
    Result := TBRect.Bottom - TBRect.Top;
  end;
end;


procedure TDLfrmUpdate.CancelBottonClick(Sender: TObject);
begin
  FFormMain.TimerCheckUpdate.Enabled := False;
  Close;
end;

procedure TDLfrmUpdate.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TDLfrmUpdate.TimerSTimer(Sender: TObject);
begin
  if LeftCur >= LeftMin then
  begin
    Left := LeftCur;
    LeftCur := LeftCur - 30;
  end
  else TimerS.Enabled := False;
end;

end.
