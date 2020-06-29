unit DjenyaLibDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, frxpngimage, StdCtrls;

type
  TfrmMessage = class(TForm)
    lblCaption: TLabel;
    ImgMask: TImage;
    Img: TImage;
    bt0: TImage;
    bt1: TImage;
    bt2: TImage;
    lblCaptionS: TLabel;
    lblTextS: TLabel;
    lblText: TLabel;
    bt3: TImage;
    procedure FormCreate(Sender: TObject);
    procedure lblCaptionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt0MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt0MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt0Click(Sender: TObject);
    procedure bt1Click(Sender: TObject);
    procedure bt2Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bt3Click(Sender: TObject);
    procedure bt3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    // ����� ��� ����������� ������ ������
    SetFocusYes,
    SetFocusNo,
    SetFocusOk,
    SetFocusCancel: Boolean;

    Exit : Boolean;
    IndexCombination : Integer;
    procedure CheckVisibleFocusImage;
    procedure InputMassiv;
    procedure GetFocusOK;
    procedure GetFocusYES;
    procedure GetFocusNO;
    procedure GetFocusCANCEL;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}
{$R MessageImg.res}

type
  TSaveRedir = packed record
     Addr: Pointer;
     Bytes: array[0..4] of Byte;
  end;
  PSaveRedir = ^TSaveRedir;

  TMyButton = packed record
    X, Y : Integer;
    VisibleB : Boolean;
  end;

var
  S: TSaveRedir;
  VMas: array[0..3] of array[0..3] of TMyButton;

{$region ' ������� � ���������� ������ '}

  // �������� BMP �� ��������
procedure LoadBMPImage (Image: TBitmap; NameSection: string; NameImageRes: string);
var
  m: TStream;
begin
  m := TResourceStream.Create(HInstance, NameImageRes, pchar(NameSection));
  m.Position:=0;
  Image.LoadFromStream(m);
  m.Free;
end;

  // �������� PNG �� ��������
procedure LoadPNGImage(Image: TImage; NameSection: string; NameImageRes: string);
var m: TStream;
    b: TPNGObject;
begin
 try
  m := TResourceStream.Create(HInstance, NameImageRes, pchar(NameSection));
  m.Position:=0;
  b:=TPNGObject.Create;
  b.LoadFromStream(m);
  Image.Picture.Assign(b);
 finally
  m.Free;
  b.Free;
 end;
end;

  // ���������� ������ ����� �� ��������
function CreateBitmapRgn(DC: hDC; Bitmap: hBitmap; TransClr: TColorRef): hRgn;
var
  bmInfo: Windows.TBitmap;               // ��������� BITMAP WinAPI
  W, H: Integer;                 // ������ � ������ ������
  bmDIB: hBitmap;                // ���������� ������������ ������
  bmiInfo: BITMAPINFO;           // ��������� BITMAPINFO WinAPI
  lpBits, lpOldBits: PRGBTriple; // ��������� �� ��������� RGBTRIPLE WinAPI
  lpData: PRgnData;              // ��������� �� ��������� RGNDATA WinAPI
  X, Y, C, F, I: Integer;        // ���������� ������
  Buf: Pointer;                  // ���������
  BufSize: Integer;              // ������ ���������
  rdhInfo: TRgnDataHeader;       // ��������� RGNDATAHEADER WinAPI
  lpRect: PRect;                 // ��������� �� TRect (RECT WinAPI)
begin
  Result := 0;
  //���� ����� �� �����, �������
  if Bitmap = 0 then Exit;

  //������ ������� ������
  GetObject(Bitmap, SizeOf(bmInfo), @bmInfo);
  //��������� ��������� BITMAP
  W:=bmInfo.bmWidth;
  H:=bmInfo.bmHeight;
  //���������� �������� � ������
  I:=(W*3)-((W*3) div 4)*4;
  if I<>0 then
    I:=4-I;

  //���������: ����� Windows Bitmap �������� ����� �����, ������ ������ ������
  //����������� �������� ������� �� �� ��������� 4.
  //��� 32-� ������ ������� ����� ����� ������ �� ����.

  //��������� BITMAPINFO ��� �������� � CreateDIBSection

  bmiInfo.bmiHeader.biWidth:=W;            // ������
  bmiInfo.bmiHeader.biHeight:=H;           // ������
  bmiInfo.bmiHeader.biPlanes:=1;           // ������ 1
  bmiInfo.bmiHeader.biBitCount:=24;        // ��� ����� �� �������
  bmiInfo.bmiHeader.biCompression:=BI_RGB; // ��� ����������
  bmiInfo.bmiHeader.biSizeImage:=0;        // ������ �� �����, ������ � ����
  bmiInfo.bmiHeader.biXPelsPerMeter:=2834; // �������� �� ����, ���.
  bmiInfo.bmiHeader.biYPelsPerMeter:=2834; // �������� �� ����, ����.
  bmiInfo.bmiHeader.biClrUsed:=0;          // ������� ���, ��� � ����
  bmiInfo.bmiHeader.biClrImportant:=0;     // �� ��
  bmiInfo.bmiHeader.biSize:=SizeOf(bmiInfo.bmiHeader); // ������ ���������
  bmDIB:=CreateDIBSection(DC, bmiInfo, DIB_RGB_COLORS,
  Pointer(lpBits), 0, 0);
  //������� ����������� ����� WxHx24, ��� �������, � ��������� lpBits ��������
  //����� ������� ����� ����� ������. bmDIB - ���������� ������

  //��������� ������ ����� ������ BITMAPINFO ��� �������� � GetDIBits

  bmiInfo.bmiHeader.biWidth:=W;            // ������
  bmiInfo.bmiHeader.biHeight:=H;           // ������
  bmiInfo.bmiHeader.biPlanes:=1;           // ������ 1
  bmiInfo.bmiHeader.biBitCount:=24;        // ��� ����� �� �������
  bmiInfo.bmiHeader.biCompression:=BI_RGB; // ��� ���������
  bmiInfo.bmiHeader.biSize:=SizeOf(bmiInfo.bmiHeader); // ������ ���������
  GetDIBits(DC, Bitmap, 0, H-1, lpBits, bmiInfo, DIB_RGB_COLORS);
  //������������ �������� ����� � ��� � ��� ������������ �� ������ lpBits

  lpOldBits:=lpBits; //���������� ����� lpBits

  //������ ������ - ������������ ����� ���������������, ����������� ���
  //�������� �������
  C:=0; //������� ����
  //������ ����� �����
  for Y:=H-1 downto 1 do
  begin
    X:=0;
    //�� 0 �� ������-1
    while X <= W - 1 do
    begin
      //���������� ��������� ����, ���������� ���������� � ���������
      while (RGB(lpBits.rgbtRed, lpBits.rgbtGreen,
      lpBits.rgbtBlue)=TransClr) and (X <=  W - 1)do
      begin
        Inc(lpBits);
        X:=X+1;
      end;
      //���� ����� �� ���������� ����, �� �������, ������� ����� � ���� �� ����
      if RGB(lpBits.rgbtRed, lpBits.rgbtGreen,
      lpBits.rgbtBlue)<>TransClr then
      begin
        while (RGB(lpBits.rgbtRed, lpBits.rgbtGreen,
        lpBits.rgbtBlue)<>TransClr) and (X <= W - 1) do
        begin
          Inc(lpBits);
          X:=X+1;
        end;
        //����������� ������� ���������������
        C:=C+1;
      end;
    end;
    //��� ����������, ���������� ��������� ��������� �� ��������� 4
    PChar(lpBits):=PChar(lpBits)+I;
  end;

  lpBits:=lpOldBits; //��������������� �������� lpBits

  //��������� ��������� RGNDATAHEADER
  rdhInfo.iType:=RDH_RECTANGLES;     // ����� ������������ ��������������
  rdhInfo.nCount:=C;                 // �� ����������
  rdhInfo.nRgnSize:=0;               // ������ �������� ������ �� �����
  rdhInfo.rcBound:=Rect(0, 0, W, H); // ������ �������
  rdhInfo.dwSize:=SizeOf(rdhInfo);   // ������ ���������

  //�������� ������ ��� �������� RGNDATA:
  //����� RGNDATAHEADER � ����������� �� ���������������
  BufSize:=SizeOf(rdhInfo)+SizeOf(TRect)*C;
  GetMem(Buf, BufSize);
  //������ ��������� �� ���������� ������
  lpData:=Buf;
  //������� � ������ RGNDATAHEADER
  lpData.rdh:=rdhInfo;

  //���������� ������ ����������������
  lpRect:=@lpData.Buffer; //������ �������������
  for Y:=H-1 downto 1 do
  begin
    X:=0;
    while X <= W - 1 do
    begin
      while (RGB(lpBits.rgbtRed, lpBits.rgbtGreen,
      lpBits.rgbtBlue)=TransClr) and (X <= W - 1) do
      begin
        Inc(lpBits);
        X:=X+1;
      end;
      if RGB(lpBits.rgbtRed, lpBits.rgbtGreen,
      lpBits.rgbtBlue)<>TransClr then
      begin
        F:=X;
        while (RGB(lpBits.rgbtRed, lpBits.rgbtGreen,
        lpBits.rgbtBlue)<>TransClr) and (X <= W - 1) do
        begin
          Inc(lpBits);
          X:=X+1;
        end;
        lpRect^:=Rect(F, Y, X, Y+1); //������� ����������
        Inc(lpRect); //��������� � ����������
      end;
    end;
    PChar(lpBits):=PChar(lpBits)+I;
  end;

  //����� ��������� ���������� ��������� RGNDATA ����� ��������� ������.
  //������������� ��� �� �����, ������ � nil, ��������� ������
  //��������� ��������� � �� ����.

  //������� ������
  Result:=ExtCreateRegion(nil, BufSize, lpData^);

  //������ ��������� RGNDATA ������ �� �����, �������
  FreeMem(Buf, BufSize);
  //��������� ����� ���� �������
  DeleteObject(bmDIB);
end;

procedure RedirectCall(FromAddr, ToAddr: Pointer; SaveRedir: PSaveRedir);
var
  OldProtect: Cardinal;
  NewCode: packed record
    JMP: Byte;
    Distance: Integer;
  end;
begin
  if not VirtualProtect(FromAddr, 5, PAGE_EXECUTE_READWRITE, OldProtect) then RaiseLastWin32Error;

  if Assigned(SaveRedir) then
  begin
    SaveRedir^.Addr := FromAddr;
    Move(FromAddr^, SaveRedir^.Bytes, 5);
  end;

  NewCode.JMP := $E9;
  NewCode.Distance := PChar(ToAddr) - PChar(FromAddr) - 5;
  Move(NewCode, FromAddr^, 5);

  if not VirtualProtect(FromAddr, 5, OldProtect, OldProtect) then RaiseLastWin32Error;
end;

{$endregion}

procedure UndoRedirectCall(const SaveRedir: TSaveRedir);
var
  OldProtect: Cardinal;
begin
  if not VirtualProtect(SaveRedir.Addr, 5, PAGE_EXECUTE_READWRITE, OldProtect) then RaiseLastWin32Error;
  Move(SaveRedir.Bytes, SaveRedir.Addr^, 5);
  if not VirtualProtect(SaveRedir.Addr, 5, OldProtect, OldProtect) then RaiseLastWin32Error;
end;

function MyNewMessageBox(Self: TApplication; const TextA, CaptionM: PChar;
   Flags: Longint): Integer;
const
  mbOk = 0;
  mbOkCancel = 1;
  mbYesNoCancel = 3;
  mbYesNo = 4;
var
  i : Integer;
  Im : TImage;
begin
  with TfrmMessage.Create(Self) do
  begin
    InputMassiv;

    lblCaption.Caption := CaptionM;
    lblCaptionS.Caption := lblCaption.Caption;
    lblText.Caption := TextA;
    lblTextS.Caption := lblText.Caption;

    // -----------------        ��������� � ��         ----------------- //
    if (Flags = mbOk)
     //+������
     or (Flags = mbOk + 16)  or (Flags = mbOk + 32) or (Flags = mbOk + 48)
     or (Flags = mbOk + 64) or (Flags = mbOk + 240)
     //+������ �� ���������
     or (Flags = mbOk + 256) or (Flags = mbOk + 512) or (Flags = mbOk + 768)
     //+���������
     or (Flags = mbOk + 16 + 256) or (Flags = mbOk + 16 + 512) or (Flags = mbOk + 16 + 768)
     or (Flags = mbOk + 32 + 256) or (Flags = mbOk + 32 + 512) or (Flags = mbOk + 32 + 768)
     or (Flags = mbOk + 48 + 256) or (Flags = mbOk + 48 + 512) or (Flags = mbOk + 48 + 768)
     or (Flags = mbOk + 64 + 256) or (Flags = mbOk + 64 + 512) or (Flags = mbOk + 64 + 768)
     or (Flags = mbOk + 240 + 256) or (Flags = mbOk + 240 + 512) or (Flags = mbOk + 240 + 768)
    then begin
      IndexCombination := 0;
      GetFocusOK;
    end
    else
    // -----------------    ��������� � ��-������     ----------------- //
    if (Flags = mbOkCancel)
     //+������
     or (Flags = mbOkCancel + 16)  or (Flags = mbOkCancel + 32) or (Flags = mbOkCancel + 48)
     or (Flags = mbOkCancel + 64) or (Flags = mbOkCancel + 240)
     //+������ �� ���������
     or (Flags = mbOkCancel + 256) or (Flags = mbOkCancel + 512) or (Flags = mbOkCancel + 768)
     //+���������
     or (Flags = mbOkCancel + 16 + 256) or (Flags = mbOkCancel + 16 + 512) or (Flags = mbOkCancel + 16 + 768)
     or (Flags = mbOkCancel + 32 + 256) or (Flags = mbOkCancel + 32 + 512) or (Flags = mbOkCancel + 32 + 768)
     or (Flags = mbOkCancel + 48 + 256) or (Flags = mbOkCancel + 48 + 512) or (Flags = mbOkCancel + 48 + 768)
     or (Flags = mbOkCancel + 64 + 256) or (Flags = mbOkCancel + 64 + 512) or (Flags = mbOkCancel + 64 + 768)
     or (Flags = mbOkCancel + 240 + 256) or (Flags = mbOkCancel + 240 + 512) or (Flags = mbOkCancel + 240 + 768)
    then begin
      IndexCombination := 1;
      GetFocusOK;
    end
    else
    // -----------------     ��������� � ��-���      ----------------- //
    if (Flags = mbYesNo)
     //+������
     or (Flags = mbYesNo + 16)  or (Flags = mbYesNo + 32) or (Flags = mbYesNo + 48)
     or (Flags = mbYesNo + 64) or (Flags = mbYesNo + 240)
     //+������ �� ���������
     or (Flags = mbYesNo + 256) or (Flags = mbYesNo + 512) or (Flags = mbYesNo + 768)
     //+���������
     or (Flags = mbYesNo + 16 + 256) or (Flags = mbYesNo + 16 + 512) or (Flags = mbYesNo + 16 + 768)
     or (Flags = mbYesNo + 32 + 256) or (Flags = mbYesNo + 32 + 512) or (Flags = mbYesNo + 32 + 768)
     or (Flags = mbYesNo + 48 + 256) or (Flags = mbYesNo + 48 + 512) or (Flags = mbYesNo + 48 + 768)
     or (Flags = mbYesNo + 64 + 256) or (Flags = mbYesNo + 64 + 512) or (Flags = mbYesNo + 64 + 768)
     or (Flags = mbYesNo + 240 + 256) or (Flags = mbYesNo + 240 + 512) or (Flags = mbYesNo + 240 + 768)
    then begin
      IndexCombination := 2;
      GetFocusYES;
    end
    else
    // ----------------- ��������� � ��-���-������  ----------------- //
    if (Flags = mbYesNoCancel)
     //+������
     or (Flags = mbYesNoCancel + 16)  or (Flags = mbYesNoCancel + 32) or (Flags = mbYesNoCancel + 48)
     or (Flags = mbYesNoCancel + 64) or (Flags = mbYesNoCancel + 240)
     //+������ �� ���������
     or (Flags = mbYesNoCancel + 256) or (Flags = mbYesNoCancel + 512) or (Flags = mbYesNoCancel + 768)
     //+���������
     or (Flags = mbYesNoCancel + 16 + 256) or (Flags = mbYesNoCancel + 16 + 512) or (Flags = mbYesNoCancel + 16 + 768)
     or (Flags = mbYesNoCancel + 32 + 256) or (Flags = mbYesNoCancel + 32 + 512) or (Flags = mbYesNoCancel + 32 + 768)
     or (Flags = mbYesNoCancel + 48 + 256) or (Flags = mbYesNoCancel + 48 + 512) or (Flags = mbYesNoCancel + 48 + 768)
     or (Flags = mbYesNoCancel + 64 + 256) or (Flags = mbYesNoCancel + 64 + 512) or (Flags = mbYesNoCancel + 64 + 768)
     or (Flags = mbYesNoCancel + 240 + 256) or (Flags = mbYesNoCancel + 240 + 512) or (Flags = mbYesNoCancel + 240 + 768)
    then begin
      IndexCombination := 3;
      GetFocusYES;
    end;

    CheckVisibleFocusImage;

    for i := 0 to 3 do
    begin
      Im := Nil;
      Im := TImage(FindComponent('bt' + IntToStr(i)));
      if Assigned(Im) then
      begin
        Im.Left := VMas[IndexCombination][i].X;
        Im.Top := VMas[IndexCombination][i].Y;
        Im.Visible := VMas[IndexCombination][i].VisibleB;
      end;
    end;

    ShowModal;

    case ModalResult of
      mrYes : Result := ID_YES;
      mrNo : Result := ID_NO;
      mrOk : Result := ID_OK;
    end;

    Free;
  end;
end;

procedure TfrmMessage.bt3Click(Sender: TObject);
begin
  Exit := True;
  ModalResult := mrCancel;
end;

procedure TfrmMessage.bt3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then LoadPNGImage(TImage(Sender),'BT','CANCELDOWN');
end;

procedure TfrmMessage.bt3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if SetFocusCancel then LoadPNGImage(TImage(Sender), 'BT', 'CANCELFOCUS')
    else LoadPNGImage(TImage(Sender), 'BT', 'CANCEL');
  end;
end;

procedure TfrmMessage.bt2Click(Sender: TObject);
begin
  Exit := True;
  ModalResult := mrNo;
end;

procedure TfrmMessage.bt2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then LoadPNGImage(TImage(Sender), 'BT', 'NODOWN');
end;

procedure TfrmMessage.bt2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if SetFocusNo then LoadPNGImage(TImage(Sender), 'BT', 'NOFOCUS')
    else LoadPNGImage(TImage(Sender), 'BT', 'NO');
  end;
end;

procedure TfrmMessage.bt0Click(Sender: TObject);
begin
  Exit := True;
  ModalResult := mrOk;
end;

procedure TfrmMessage.bt0MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then LoadPNGImage(TImage(Sender), 'BT', 'OKDOWN');
end;

procedure TfrmMessage.bt0MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if SetFocusOk then LoadPNGImage(TImage(Sender), 'BT', 'OKFOCUS')
    else LoadPNGImage(TImage(Sender), 'BT', 'OK');
  end;
end;

procedure TfrmMessage.bt1Click(Sender: TObject);
begin
  Exit := True;
  ModalResult := mrYes;
end;

procedure TfrmMessage.bt1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then LoadPNGImage(TImage(Sender), 'BT', 'YESDOWN');
end;

procedure TfrmMessage.bt1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if SetFocusYes then LoadPNGImage(TImage(Sender), 'BT', 'YESFOCUS')
    else LoadPNGImage(TImage(Sender), 'BT', 'YES');
  end;
end;

procedure TfrmMessage.CheckVisibleFocusImage;
begin
  if SetFocusOk then LoadPNGImage(bt0, 'BT', 'OKFOCUS')
  else LoadPNGImage(bt0,'BT','OK');

  if SetFocusYes then LoadPNGImage(bt1, 'BT', 'YESFOCUS')
  else LoadPNGImage(bt1,'BT','YES');

  if SetFocusNo then LoadPNGImage(bt2,'BT','NOFOCUS')
  else LoadPNGImage(bt2,'BT','NO');

  if SetFocusCancel then LoadPNGImage(bt3,'BT','CANCELFOCUS')
  else LoadPNGImage(bt3,'BT','CANCEL');
end;

procedure TfrmMessage.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Exit = False then CanClose := False
  else CanClose := True;
end;

procedure TfrmMessage.FormCreate(Sender: TObject);
var
  Reg: HRGN;
  bmp: TBitmap;
begin
  Exit := False;

  ImgMask.Top := 0; ImgMask.Left := 0;
  bmp := TBitMap.Create;
  LoadBMPImage(bmp, 'IMAGE', 'M');
  LoadBMPImage(Img.Picture.Bitmap, 'IMAGE', 'P');
  self.Height := Img.Height;
  self.Width := Img.Width;
  Img.Top := 0; Img.Left := 0;

  Reg := CreateBitmapRgn(bmp.Canvas.Handle, bmp.Handle, clWhite);
  SetWindowRgn(self.Handle, Reg, true);
  DeleteObject(Reg);
  if Assigned(bmp) then bmp.Free;

  // ���������
  lblCaption.Top := 3;
  lblCaption.Left := 0;
  lblCaption.Width := Img.Width;

  // ���� ���������
  lblCaptionS.Top := lblCaption.Top + 2;
  lblCaptionS.Left := lblCaption.Left + 2;
  lblCaptionS.Width := lblCaption.Width;

  // ����� ���������
  lblText.Top := 40;
  lblText.Left := 5;
  lblText.Height := 80;
  lblText.Width := Img.Width - 10;

  // ���� ������ ���������
  lblTextS.Top := lblText.Top + 1;
  lblTextS.Left := lblText.Left + 1;
  lblTextS.Width := lblText.Width;
  lblTextS.Height := lblText.Height;
end;

procedure TfrmMessage.GetFocusCANCEL;
begin
  SetFocusOK := False;
  SetFocusYes := False;
  SetFocusNo := False;
  SetFocusCancel := True;
end;

procedure TfrmMessage.GetFocusNO;
begin
  SetFocusOK := False;
  SetFocusYes := False;
  SetFocusNo := True;
  SetFocusCancel := False;
end;

procedure TfrmMessage.GetFocusOK;
begin
  SetFocusOK := True;
  SetFocusYes := False;
  SetFocusNo := False;
  SetFocusCancel := False;
end;

procedure TfrmMessage.GetFocusYES;
begin
  SetFocusOK := False;
  SetFocusYes := True;
  SetFocusNo := False;
  SetFocusCancel := False;
end;

procedure TfrmMessage.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_LEFT) or (Key = VK_RIGHT) then
  begin
    if IndexCombination = 1 then
    begin
      if SetFocusOk then  GetFocusCANCEL
      else if SetFocusCancel then GetFocusOK;
    end
    else
    if IndexCombination = 2 then
    begin
      if SetFocusYes then GetFocusNO
      else if SetFocusNo then GetFocusYES;
    end
    else
    if IndexCombination = 3 then
    begin
      if Key = VK_LEFT then
      begin
        if SetFocusYes then GetFocusCANCEL
        else if SetFocusNo then GetFocusYES
        else if SetFocusCancel then GetFocusNO;
      end;
      if Key = VK_RIGHT then
      begin
        if SetFocusYes then GetFocusNO
        else if SetFocusNo then GetFocusCANCEL
        else if SetFocusCancel then GetFocusYES;
      end;
    end;

    CheckVisibleFocusImage;
  end;

  if Key = 13 then
  begin
    if SetFocusOk then bt0Click(bt0)
    else if SetFocusYes then bt1Click(bt1)
    else if SetFocusNo then bt2Click(bt2)
    else if SetFocusCancel then bt3Click(bt3)
  end;
end;

procedure TfrmMessage.InputMassiv;
var
  XLeft,
  XCenter,
  XRight,
  XLeftBt3,
  XRightBt3,
  Y: Integer;
begin
  // ���������� ���������
  XLeft := (Img.Width div 2) - bt0.Width;
  XCenter := (Img.Width - bt0.Width) div 2;
  XRight := Img.Width div 2;
  XLeftBt3 := (Img.Width - (bt0.Width * 3)) div 2;
  XRightBt3 := ((Img.Width - bt0.Width) div 2) + bt0.Width;
  Y := Img.Height - bt0.Height - 5;

 // -----------------        ��������� � ��         ----------------- //
  // - ������ ��
  VMas[0][0].X := XCenter;  VMas[0][0].Y := Y; VMas[0][0].VisibleB := True;
  // - ������ Yes
  VMas[0][1].VisibleB := False;
  // - ������ No
  VMas[0][2].VisibleB := False;
  // - ������ Cancel
  VMas[0][3].VisibleB := False;

 // -----------------    ��������� � ��-������     ----------------- //
  // - ������ ��
  VMas[1][0].X := XLeft; VMas[1][0].Y := Y; VMas[1][0].VisibleB := True;
  // - ������ Yes
  VMas[1][1].VisibleB := False;
  // - ������ No
  VMas[1][2].VisibleB := False;
  // - ������ Cancel
  VMas[1][3].X := XRight; VMas[1][3].Y := Y; VMas[1][3].VisibleB := True;

 // -----------------     ��������� � ��-���      ----------------- //
  // - ������ ��
  VMas[2][0].VisibleB := False;
  // - ������ Yes
  VMas[2][1].X := XLeft; VMas[2][1].Y := Y; VMas[2][1].VisibleB := True;
  // - ������ No
  VMas[2][2].X := XRight; VMas[2][2].Y := Y; VMas[2][2].VisibleB := True;
  // - ������ Cancel
  VMas[2][3].VisibleB := False;

 // ----------------- ��������� � ��-���-������  ----------------- //
  // - ������ ��
  VMas[3][0].VisibleB := False;
  // - ������ Yes
  VMas[3][1].X := XLeftBt3; VMas[3][1].Y := Y; VMas[3][1].VisibleB := True;
  // - ������ No
  VMas[3][2].X := XCenter; VMas[3][2].Y := Y; VMas[3][2].VisibleB := True;
  // - ������ Cancel
  VMas[3][3].X := XRightBt3; VMas[3][3].Y := Y; VMas[3][3].VisibleB := True;
end;

procedure TfrmMessage.lblCaptionMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012,0);
end;



initialization
  RedirectCall(@TApplication.MessageBox, @MyNewMessageBox, @S);

finalization
  UndoRedirectCall(S);

end.
