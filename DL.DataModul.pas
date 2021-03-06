unit DL.DataModul;

interface

uses
  SysUtils, Classes, XPMan, DB, ADODB, ImgList, Controls, Graphics, ExtCtrls,
  Windows, jpeg, frxpngimage, DL.libSystemInfo;

type
  // ��� �������� ���. � ������������
  TLoginTune = record
    WorkDB: string;
    WorkServer: string;
    ReportDB: string;
    ReportServer: string;

    Login: string;
    Password: string;

    dboAdmin: Boolean;
  end;

type
  TDLdmMain = class(TDataModule)
    cnMain: TADOConnection;
    sqlUpdateProgram: TADODataSet;
    sqlReport: TADODataSet;
    XPManifest1: TXPManifest;
    ImageList1: TImageList;
    cnReport: TADOConnection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  CONNECTION_STRING =
	  'Provider=SQLOLEDB.1;' +
		'Persist Security Info=True;' +
		'Initial Catalog=%s;' +
		'Data Source=%s;' +
    'Workstation ID=%s;';

var
  LoginTunes: TLoginTune;

//****************************************************************************//

function ConnectionServer(cnName: TADOConnection; ServerName, DBName: string; LoginName, PasStr: string): Boolean;
function ShifrPassword(StringX: string): string;
function CreateBitmapRgn(DC: hDC; Bitmap: hBitmap; TransClr: TColorRef): hRgn;
procedure LoadBmpToBitmap(Bitmap: Graphics.TBitmap; NameSection: string; NameImageRes: string);
procedure LoadJPGToImage(Image: TImage; NameSection: string; NameImageRes: string);
procedure LoadPNGToImage(Image: TImage; NameSection: string; NameImageRes: string);

implementation

{$R *.dfm}

function ConnectionServer(cnName: TADOConnection; ServerName, DBName: string; LoginName, PasStr: string): Boolean;
begin
  try
    cnName.Connected := False;
    cnName.LoginPrompt := False;
    cnName.ConnectionString := Format(CONNECTION_STRING,
                                      [DBName,
                                       ServerName,
                                       TCompInfo.GetCompName]);
    cnName.Open(LoginName, PasStr);
    Result := True;
  except
    Result := False;
  end;
end;

function ShifrPassword(StringX: string): string;
var
  i : integer;
  pasXOR: String;
begin
  for i := 1 to Length(StringX) do
    pasXOR := pasXOR + AnsiChar((ord(StringX[i]) xor ord('�')));
  Result := PasXor;
end;

{$region ' �������� �� �������� � ���������� ������� �� Bitmap'}

procedure LoadBmpToBitmap(Bitmap: Graphics.TBitmap; NameSection: string; NameImageRes: string);
// �������� bmp �� ����� ������� *
var m: TStream;
    b: Graphics.TBitmap;
begin
  try
    m := TResourceStream.Create(HInstance, NameImageRes, pchar(NameSection));
    m.Position := 0;
    b := Graphics.TBitmap.Create;
    b.LoadFromStream(m);
    Bitmap.Assign(b);
  finally
    m.Free;
    b.Free;
  end;
end;

procedure LoadJPGToImage(Image: TImage; NameSection: string; NameImageRes: string);
var m: TStream;
    b: TJPEGImage;
begin
  try
    m := TResourceStream.Create(HInstance, NameImageRes, pchar(NameSection));
    m.Position := 0;
    b := TJPEGImage.Create();
    b.LoadFromStream(m);
    Image.Picture.Assign(b);
  finally
    m.Free;
    b.Free;
  end;
end;

procedure LoadPNGToImage(Image: TImage; NameSection: string; NameImageRes: string);
//�������� ��� �� ��������
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

function CreateBitmapRgn(DC: hDC; Bitmap: hBitmap; TransClr: TColorRef): hRgn;
var
  bmInfo: Windows.TBitmap;       // ��������� BITMAP WinAPI
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
  Result:=0;
  //���� ����� �� �����, �������
  if Bitmap=0 then
    Exit;

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

{$endregion}


end.
