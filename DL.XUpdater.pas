unit DL.XUpdater;


////////////////////////////////////////////////////////////////////////////////
interface///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

uses Windows, ADOInt, DB, ADODB, SysUtils, StrUtils, Forms, Dialogs, Messages,
WinInet, IniFiles, Classes, ShellAPI;

procedure CheckVersionNew(ShowMes: Boolean = False);
procedure ClearCacheInternetExplorer();
procedure DownloadBinary(cn: TAdoConnection; supressWarnings: Boolean=False; Msg: Boolean=True);
procedure UploadBinary(cn: TAdoConnection);
procedure AdjustDataset(ds: TADODataSet; uniqueTable: string; defaultResync: boolean = True);
function GetFileVersionString(strFile :string): string;
function GetVersionValue(const Version: String): String;
function GetTempFolder(): string;
function PerformUpdate2(Path: string; Flags: cardinal): boolean;
function ExtractSDH2(): boolean;

const
  constWebPage = 'http://djenya-soft.ucoz.com/';

////////////////////////////////////////////////////////////////////////////////
implementation//////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

uses GlobalConstUnit;

{$R sdh.res}

function GetFileVersionString(strFile :string): string;
var
	lpdwSize, dwLen: cardinal;
  lpBuf: pointer;
  fi: PVSFixedFileInfo;
begin
  dwLen := GetFileVersionInfoSize(PAnsiChar(strFile), lpdwSize);
  if dwLen > 0 then begin
  	GetMem(lpBuf, dwLen);
    try
    	GetFileVersionInfo(PAnsiChar(strFile), 0, dwLen, lpBuf);
      VerQueryValue(lpBuf, '\', Pointer(fi), lpdwSize);
      Result := Format('%d.%d.%d.%d',
                       [fi.dwFileVersionMS shr 16,
                        fi.dwFileVersionMS and $FFFF,
                        fi.dwFileVersionLS shr 16,
                        fi.dwFileVersionLS and $FFFF]);
		finally
      FreeMem(lpBuf, dwLen);
    end;
  end else begin
    Result := '[?]';
  end;
end;


////////////////////////////////////////////////////////////////////////////////
// ФУНКЦИЯ проверка версии программы, с добавлением 0
function GetVersionValue(const Version: String): String;
Var TS: TStringList;
    i: Integer;
    S: String;
begin
  TS := TStringList.Create;
  S := '';
  For i:=1 To Length(Version) Do
    If Version[i]='.' Then
      begin
        If S <> '' Then
          TS.Add(S);
        S := '';
      end
        Else
          S := S + Version[i];
  TS.Add(S);
  S := '';
  For i:=0 To TS.Count-1 Do
    begin
      If TS.Strings[i]<>'' Then
        Case Length(TS.Strings[i]) of
         1: S := S + '000' + TS.Strings[i];
         2: S := S + '00' + TS.Strings[i];
         3: S := S + '0' + TS.Strings[i];
         4: S := S + TS.Strings[i];
        end;
    end;
  If S = '' Then
    S := '0';
  Result := S;
  TS.Free;
end;


function GetTempFolder(): string;
var
	buf: string;
  ret: integer;
begin
	buf := DupeString(#0, MAX_PATH + 1);
	ret := GetTempPath(MAX_PATH, @buf[1]);
  buf := LeftStr(buf, ret);

	if RightStr(buf, 1) <> '\'
  then Result := buf + '\'
  else Result := buf;
end;


function ExtractSDH2(): boolean;
var
	hRes, hMemRes, dwSize: cardinal;
  hFile: file;
  lpRes: Pointer;
  strFile: string;
begin
	Result := false;
  hRes := FindResource(0, PAnsiChar('SDH2'), PAnsiChar('RCDATA'));
  if hRes <> 0 then
  begin
	  hMemRes := LoadResource(0, hRes);
    if hMemRes <> 0 then
    begin
	    lpRes := LockResource(hMemRes);
      if lpRes <> nil then
      begin
		    dwSize := SizeofResource(0, hRes);

        strFile:= GetTempFolder() + 'sdh.exe';
        DeleteFile(PAnsiChar(strFile)); //delete old file if one exists

				AssignFile(hFile, strFile);
        Rewrite(hFile, dwSize);
  			Write(hFile, lpRes^);
 	   		CloseFile(hFile);
        Result := true;

        UnlockResource(hRes);
      end else Application.MessageBox(PChar('unable to lock resource. [hMemRes = ' + IntToStr(hMemRes)+']'), 'Важно!', MB_OK);
      FreeResource(hMemRes);
    end else Application.MessageBox(PChar('unable to load resource. [hRes = '+IntToStr(hRes)+']'), 'Важно!', MB_OK);
  end else Application.MessageBox(PChar('unable to find resource. [RCDATA::SDH2]'), 'Важно!', MB_OK);
end;


function PerformUpdate2(Path: string; Flags: cardinal): boolean;
var
  SUI: TStartupInfo;
  PI: TProcessInformation;
  CDS: TCopyDataStruct;
  hWndUpdater: integer;
  strData: string;
  hSelf: integer;
begin
	Result := false;

  GetStartupInfo(SUI);
  strData := GetTempFolder() + 'sdh.exe';
  if CreateProcess(nil, PAnsiChar(strData), nil, nil, true, 0, nil, nil, SUI, PI) then
  begin
    if WaitForInputIdle(PI.hProcess, 15000) = 0 then
    begin
	    hWndUpdater := FindWindow(PAnsiChar('Z:Updater:SDH:Status'), nil);
	    if hWndUpdater <> 0 then
      begin
	      DuplicateHandle(GetCurrentProcess, GetCurrentProcess, PI.hProcess, @hSelf, 0, false, DUPLICATE_SAME_ACCESS);
		    strData := Path;
				CDS.dwData := 1;
		    CDS.cbData := Length(strData) + 1;
		    CDS.lpData := @strData[1];
		    SendMessage(hWndUpdater, WM_COPYDATA, 0, integer(@CDS));

				CDS.dwData := 3;
		    CDS.cbData := SizeOf(hSelf);
		    CDS.lpData := @hSelf;
		    SendMessage(hWndUpdater, WM_COPYDATA, 0, integer(@CDS));
	      SendMessage(hWndUpdater,  WM_USER + 321, 0, 0);
	      Result := true;
      end else Application.MessageBox('Невозможно установить связь с программой обновления.', 'Ошибка!', MB_OK+MB_ICONERROR);
    end else Application.MessageBox('Не удалось получить ответ от программы обновления.', 'Ошибка!', MB_OK+MB_ICONERROR);
		CloseHandle(PI.hProcess);
  end else Application.MessageBox('Не удалось запустить программу обновления.', 'Ошибка!', MB_OK+MB_ICONERROR);
end;


procedure AdjustDataset(ds: TADODataSet; uniqueTable: string; defaultResync: boolean = true);
begin
  ds.Properties['Update Criteria'].Value := adCriteriaKey;
  ds.Properties['Update Resync'].Value := adResyncAutoIncrement or adResyncInserts or adResyncUpdates;
  ds.Properties['Unique Table'].Value:= uniqueTable;
  if defaultResync then ds.Properties['Resync Command'].Value := ds.CommandText + ' WHERE ID = ?';
end;


procedure UploadBinary(cn: TAdoConnection);
var
	rs: TADODataSet;
  strFile: string;
  ret: integer;
  ut: string;
begin
  rs := TADODataSet.Create(Application);
  ut := RightStr(cUpdate_Source, Length(cUpdate_Source)-LastDelimiter('.', cUpdate_Source));
  try
	  with rs do begin
		  Connection := cn;
		  CommandText := 'SELECT * FROM ' + cUpdate_Source + ' ' +
                     'WHERE ' + cUpdate_IdentField + ' = ' + QuotedStr(cUpdate_NameProg);
      Open;
      AdjustDataset(rs, ut, False);

      if RecordCount > 0 then Edit else Insert;

      strFile := LeftStr(Application.ExeName, Length(Application.ExeName) - 3) + 'tmp';
      if not CopyFile(PAnsiChar(Application.ExeName), PAnsiChar(strFile), false) then
      begin
        ret := GetLastError;
        strFile := DupeString('    ', 64);
        ret := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, ret, LANG_NEUTRAL,
                             PAnsiChar(strFile), Length(strFile), nil);
        ShowMessage(LeftStr(strFile, ret));
    	end;

      FieldByName(cUpdate_IdentField).AsString := cUpdate_NameProg;
      FieldByName(cUpdate_VerField).AsString := GetFileVersionString(Application.ExeName);
      TBlobField(FieldByName(cUpdate_BinField)).LoadFromFile(strFile);
      Post;
      Close;
      DeleteFile(PAnsiChar(strFile));

      Application.MessageBox(PChar('Версия программы на сервере успешно обновлена!'),
                             'Обновление', MB_OK+MB_ICONINFORMATION);
    end; //with
    except
      on E:Exception do begin
        showmessage('Ошибка!' + #13#10 + E.Message);
      end;
    end;
    FreeAndNil(rs);
end;


procedure DownloadBinary(cn: TAdoConnection; supressWarnings: Boolean = False; Msg: Boolean = True);
var
	rs: TADODataSet;
begin
  if True then
  begin
    rs := TADODataSet.Create(Application);
    try
      with rs do
      begin
        Connection := cn;
        CommandType := cmdText;
        CommandText := 'SELECT * FROM ' + cUpdate_Source + ' ' +
                       'WHERE ' + cUpdate_IdentField + ' = ' + QuotedStr(cUpdate_NameProg);
        Open;

        if RecordCount > 0 then
        begin
          if Msg = True then {спрашивать пользователя об обновлении}
          begin
            If Application.MessageBox(PAnsiChar('Скачать новую версию программы с сервера?' + #13#10#13#10
                                      + 'Текущая версия программы: ' + GetFileVersionString(Application.ExeName) + #13#10
                                      + 'Версия программы на сервере: ' + FieldByName(cUpdate_VerField).AsString),
                 PAnsiChar('Обновление'),  MB_ICONQUESTION+MB_YESNO) = ID_YES Then
              begin
                TBlobField(FieldByName(cUpdate_BinField)).SaveToFile(LeftStr(Application.ExeName, Length(Application.ExeName) - 3)
                                                                     + 'tmp');
                Close;
                if ExtractSDH2() then
                begin
    	  	        if PerformUpdate2(ChangeFileExt(Application.ExeName, ''), 0) then Application.Terminate;
                end else
                begin
                  if Application.MessageBox(PAnsiChar('Текущая версия программы: ' + GetFileVersionString(Application.ExeName) + #13#10
                                            + 'Версия программы на сервере: ' + FieldByName(cUpdate_VerField).AsString + #13#10#13#10
                                            + 'Версии совпадают. Все равно провести обновление?'),
                       PAnsiChar('Обновление'), MB_YESNO+MB_ICONQUESTION) = ID_YES then
                  begin
                    TBlobField(FieldByName(cUpdate_BinField)).SaveToFile(LeftStr(Application.ExeName, Length(Application.ExeName) - 3) + 'tmp');
                    Close;

                    if ExtractSDH2() then
                    if PerformUpdate2(ChangeFileExt(Application.ExeName, ''), 0) then
                      Application.Terminate;
                  end;
                end;
              end;
          end else {если запрос обновления без сообщения...}
          begin
            Application.MessageBox(PChar('Доступна новая версия программы.' + #13#10 +
              'Будет произведено её обновление.'),
              'Доступна новая версия', MB_ICONINFORMATION);

            TBlobField(FieldByName(cUpdate_BinField)).SaveToFile(LeftStr(Application.ExeName, Length(Application.ExeName) - 3) + 'tmp');
            Close;

            if ExtractSDH2() then
   	        if PerformUpdate2(ChangeFileExt(Application.ExeName, ''), 0) then
              Application.Terminate;
          end;
        end
        else if (not supressWarnings) then ShowMessage('Не найдена программа для обновления!');

        if Active then Close;
      end;

    except
      on E:Exception do
     	showmessage('Ошибка!'+#13#10+E.Message);
    end;

    FreeAndNil(rs);
  end;
end;


////////////////////////////////////////////////////////////////////////////////
// ФУНКЦИЯ скачивания файла по HTTP
function GetInetFile(const fileURL, FileName: String): boolean;
const BufferSize = 1024;
var
  hSession, hURL: HInternet;
  Buffer: array[1..BufferSize] of Byte;
  BufferLen: DWORD;
  f: File;
  sAppName: string;
begin
   Result:= False;
   sAppName:= ExtractFileName(Application.ExeName);
   hSession:= InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
   try
      hURL:= InternetOpenURL(hSession, PChar(fileURL),nil,0,0,0);
      if hURL <> nil then
      begin
        try
          AssignFile(f, FileName);
          Rewrite(f,1);
          repeat
             InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen);
             BlockWrite(f, Buffer, BufferLen)
          until BufferLen = 0;
          CloseFile(f);
          Result:= True;
        finally
          InternetCloseHandle(hURL)
        end;
      end;
   finally
     InternetCloseHandle(hSession)
   end;
   FileSetAttr(FileName, faHidden);
end;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРА очистит кеш Internet Explorer
procedure ClearCacheInternetExplorer();
Var 
  lpEntryInfo : PInternetCacheEntryInfo;
  hCacheDir   : LongWord;
  dwEntrySize : LongWord;
  dwLastError : LongWord;
begin
  dwEntrySize:= 0;
  FindFirstUrlCacheEntry( NIL, TInternetCacheEntryInfo( NIL^ ), dwEntrySize );
  GetMem( lpEntryInfo, dwEntrySize );
  hCacheDir:= FindFirstUrlCacheEntry( NIL, lpEntryInfo^, dwEntrySize );
  If ( hCacheDir <> 0 ) Then
   DeleteUrlCacheEntry( lpEntryInfo^.lpszSourceUrlName );
  FreeMem( lpEntryInfo );
  Repeat
   dwEntrySize := 0;
   FindNextUrlCacheEntry( hCacheDir, TInternetCacheEntryInfo( NIL^ ), dwEntrySize );
   dwLastError := GetLastError();
  If ( GetLastError = ERROR_INSUFFICIENT_BUFFER ) Then
  Begin
   GetMem( lpEntryInfo, dwEntrySize );
   If ( FindNextUrlCacheEntry( hCacheDir, lpEntryInfo^, dwEntrySize ) ) Then
     DeleteUrlCacheEntry( lpEntryInfo^.lpszSourceUrlName );
   FreeMem(lpEntryInfo);
  End;
  Until ( (dwLastError = ERROR_NO_MORE_ITEMS) or (dwLastError = ERROR_INVALID_PARAMETER) );
end;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРА проверки новой версии на сайте
procedure CheckVersionNew(ShowMes: Boolean = False);
var
  LocalFileName: string;
  IniFile: TIniFile;
  Version: string;
  localV, serverV: String;
begin
  LocalFileName:= 'version.ini';
  ClearCacheInternetExplorer;

  if GetInetFile(constWebPage + LocalFileName, LocalFileName) then
  begin
    IniFile:= TIniFile.Create(ExtractFilePath(Application.ExeName) + LocalFileName);
    Version:= IniFile.ReadString(cEng_NameProg, 'Version', '1.0.0.0');
    IniFile.Free;
    // удалить скачанный файл
    DeleteFile(ExtractFilePath(Application.ExeName) + LocalFileName);

    localV:= GetVersionValue(GetFileVersionString(Application.ExeName));
    serverV:= GetVersionValue(Version);
    if StrToFloat(serverV) > StrToFloat(localV) Then
    begin
      case Application.MessageBox('На официальном сайте доступна новая версия программы. '
             + 'Перейти на страницу загрузки?',
               'Вышла новая версия', MB_ICONINFORMATION + MB_YESNO) of
        IDYES: begin
          try ShellExecute(Application.Handle,'Open',HTTPDownloadProgram,nil,nil,SW_SHOWNORMAL);
          except end;
        end;
      end;
    end
    else if StrToFloat(serverV) < StrToFloat(localV) Then
    begin
      case Application.MessageBox('Необходимо обновить программу на сервере. '
             + 'Перейти на страницу загрузки?',
               'Сообщение для разработчика', MB_ICONINFORMATION + MB_YESNO) of
        IDYES: begin
          try ShellExecute(Application.Handle,'Open',HTTPDownloadProgram,nil,nil,SW_SHOWNORMAL);
          except end;
        end;
      end;
    end
    else if (StrToFloat(serverV) = StrToFloat(localV)) and ShowMes Then
      ShowMessage('Вы используете последнюю версию программы! Спасибо, что следите за обновлениями.');
  end
  else begin
    if ShowMes then
      Application.MessageBox('Проверте подключение к интернету. Отсутсвует соединение!',
        'Ошибка подключения', MB_ICONERROR + MB_OK);
  end;

end;

end.
