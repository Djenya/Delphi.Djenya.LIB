unit DL.AppOnce;

interface

uses
   SysUtils, Windows;


type
  TAppInfo = packed record
    HMainWindow: THandle;
  end;

procedure AppRunCheckInit(const AppIdent: String);
function AppRunCheck: boolean;

procedure AppRunCheckSetAppInfo(const AppInfo: TAppInfo);
procedure AppRunCheckGetAppInfo(var AppInfo: TAppInfo);


implementation

const
  FileMapSize = SizeOf(TAppInfo);

var
  hFileMapObj: THandle;
  FileMapObjCreateError: Cardinal;
  lpBaseAddress: Pointer;

procedure AppRunCheckInit(const AppIdent: String);
begin
  // ������� ����������� ����� � ������ (� ���� ��������)
  hFileMapObj := CreateFileMapping(
      INVALID_HANDLE_VALUE
    , nil
    , PAGE_READWRITE
    , 0
    , FileMapSize
    , PChar(AppIdent));

  FileMapObjCreateError := GetLastError();


end;

procedure AppRunCheckClose();
begin
  CloseHandle(hFileMapObj);
end;

function AppRunCheck: boolean;
begin
  result := FileMapObjCreateError = ERROR_ALREADY_EXISTS;
end;

procedure AppRunCheckSetAppInfo(const AppInfo: TAppInfo);
begin
  if FileMapObjCreateError = 0 then
  begin
    // ���������� ���� �� �������� ������������ �������� ��� ������
    lpBaseAddress := MapViewOfFile(hFileMapObj, FILE_MAP_WRITE, 0, 0, 0);

    // ����������� ������� �������
    CopyMemory(lpBaseAddress, @AppInfo, SizeOf(AppInfo));

    // ��������� ����������� ����� �� �������� ������������ ��������
    UnmapViewOfFile(lpBaseAddress);

    lpBaseAddress := nil;
  end;
end;

procedure AppRunCheckGetAppInfo(var AppInfo: TAppInfo);
begin
  // ����������� ��� ���������� (������� ������ ���������)
  if (FileMapObjCreateError = ERROR_ALREADY_EXISTS) then
  begin
    // ���������� ���� �� �������� ������������ �������� ��� ������
    lpBaseAddress := MapViewOfFile(hFileMapObj, FILE_MAP_READ, 0, 0, 0);

    CopyMemory(@AppInfo, lpBaseAddress, SizeOf(AppInfo));

    // ��������� ����������� ����� �� �������� ������������ ��������
    UnmapViewOfFile(lpBaseAddress);

    lpBaseAddress := nil;
  end;
end;

initialization

finalization
  AppRunCheckClose;

end.
