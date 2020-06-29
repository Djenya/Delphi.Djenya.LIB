unit DL.frmAboutUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ExtCtrls, StdCtrls;

type
  TDLfrmAbout = class(TForm)
    ImagePicture: TImage;
    lblNameProgram: TLabel;
    lblSNameProgram: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ImagePictureClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses DL.XUpdater, DL.DataModul, GlobalConstUnit;

{$R *.dfm}

procedure TDLfrmAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AnimateWindow(handle, 200, AW_BLEND or AW_HIDE);
end;

procedure TDLfrmAbout.FormCreate(Sender: TObject);
var Reg: HRGN;
    bmp: TBitmap;
begin
  //установление региона формы по картинке
  bmp:= TBitMap.Create;
  LoadBmpToBitmap(bmp,'FRMABOUT','MASK_A');
  Reg:= CreateBitmapRgn(bmp.Canvas.Handle, bmp.Handle, clWhite);
  SetWindowRgn(self.Handle, Reg, true);
  DeleteObject(Reg);
  if Assigned(bmp) then
    bmp.Free;

  //загрузка картинки
  bmp:= TBitMap.Create;
  LoadBmpToBitmap(bmp,'FRMABOUT','IMAGE_A');
  ImagePicture.Picture.Bitmap.Assign(bmp);

  lblNameProgram.Font.Color:= cColorLblAbout;
  lblNameProgram.Caption:= cRus_NameProg;
end;

procedure TDLfrmAbout.FormShow(Sender: TObject);
begin
  with lblNameProgram do
  begin
    Caption := Caption + ' [v.' + GetFileVersionString(Application.ExeName) + ']';
    Top:= 145;
    Left:= 64;
    Height:= 90;
    Width:= 244;
  end;
  with lblSNameProgram do
  begin
    AutoSize:= lblNameProgram.AutoSize;
    Alignment:= lblNameProgram.Alignment;
    Height:= lblNameProgram.Height;
    Width:= lblNameProgram.Width;
    Top:= lblNameProgram.Top + 1;
    Left:= lblNameProgram.Left + 1;
    Font.Name:= lblNameProgram.Font.Name;
    Font.Size:= lblNameProgram.Font.Size;
    Font.Color:= clBtnFace;
    Caption:= lblNameProgram.Caption;
  end;
  lblNameProgram.BringToFront;

  Top:= trunc(screen.Height / 2)  - trunc(height / 2);
  Left:= trunc(screen.Width / 2) - trunc(width / 2);
  AnimateWindow(Handle, 200, AW_CENTER or AW_SLIDE);
end;

procedure TDLfrmAbout.ImagePictureClick(Sender: TObject);
begin
  Close;
end;


end.
