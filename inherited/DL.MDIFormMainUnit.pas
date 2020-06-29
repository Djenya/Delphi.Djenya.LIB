unit DL.MDIFormMainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PropStorageEh, ExtCtrls, Menus, StdCtrls, Tabs, ActnList, Registry,
  DL.DataModul, ComCtrls, AppEvnts;

type
  TDLMDIFormMain = class(TForm)
    cmdListMain: TActionList;
    cmdCheckVersionsServer: TAction;
    cmdUpdate: TAction;
    cmdUpload: TAction;
    cmdfrmAbout: TAction;
    pnlMainFooter: TPanel;
    lblHintCtrlTab: TLabel;
    TabSet: TTabSet;
    lblHintServer: TStaticText;
    lblHintLogin: TStaticText;
    imgBackground: TImage;
    mMain: TMainMenu;
    N6: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N2: TMenuItem;
    N12: TMenuItem;
    N11: TMenuItem;
    N3: TMenuItem;
    N10: TMenuItem;
    TimerCheckUpdate: TTimer;
    RegPSMEhDjenyaSoft: TRegPropStorageManEh;
    N1: TMenuItem;
    N14: TMenuItem;
    cmdConnect: TAction;
    cmdChangeUser: TAction;
    cmdReconnect: TAction;
    cmdChangeUser1: TMenuItem;
    cmdReconnect1: TMenuItem;
    StatusTimer: TTimer;
    ApplicationEvents: TApplicationEvents;
    MainStatusBar: TStatusBar;
    cmdCreatePopupMenu: TAction;
    procedure cmdCheckVersionsServerExecute(Sender: TObject);
    procedure cmdUpdateExecute(Sender: TObject);
    procedure cmdUploadExecute(Sender: TObject);
    procedure TimerCheckUpdateTimer(Sender: TObject);
    procedure cmdfrmAboutExecute(Sender: TObject);
    procedure TabSetChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure N9Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmdConnectExecute(Sender: TObject);
    procedure cmdChangeUserExecute(Sender: TObject);
    procedure cmdReconnectExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure StatusTimerTimer(Sender: TObject);
    procedure ApplicationEventsHint(Sender: TObject);
    procedure cmdCreatePopupMenuExecute(Sender: TObject);
  private
    { Private declarations }
    function CheckVersions: string;
    function GetVersionValue(const Version: String): string;

    class var FDataModul: TDLdmMain;
  public
    { Public declarations }
    procedure ActivateTab(frm: TForm);
    procedure CreateChildForm(var NameForm; ClassForm: TFormClass); OverLoad;
    procedure CreateChildForm(Classform: TFormClass); OverLoad;

    class property DataModul: TDLdmMain read FDataModul write FDataModul;
  end;

implementation

uses DL.XUpdater, DL.frmUpdater, DL.RegStorage, GlobalConstUnit,
  DL.frmSplashUnit, DL.frmAboutUnit;

resourcestring
  RES_INPUT_LANGUAGE = 'Язык ввода: %s';
  RES_UNKNOW_LANGUAGE = 'не опредеделен';

{$R *.dfm}

function TDLMDIFormMain.CheckVersions: string;
// функция проверки версии на сервере(если там версия выше - скачать, если ниже - выложить)...
var lV, sV: String;
begin
  Result := '<>';

  try
    with FDataModul.sqlUpdateProgram do
    begin
      Close;
      CommandText := 'select ' + cUpdate_VerField + ' ' +
                     'from ' + cUpdate_Source + ' ' +
                     'where ' + cUpdate_IdentField + ' = ' + QuotedStr(cUpdate_NameProg);
      Open;

      lv := GetVersionValue(GetFileVersionString(Application.ExeName));
      sv := GetVersionValue(FieldByName(cUpdate_VerField).AsString);

      if StrToFloat(sV) > StrToFloat(lv) Then
        Result := '>'
      else if StrToFloat(sv) < StrToFloat(lv) Then
        Result := '<'
      else if StrToFloat(sv) = StrToFloat(lv) Then
        Result := '=';
      Close;
    end;
  except
  end;
end;

procedure TDLMDIFormMain.ActivateTab(frm: TForm);
// активация закладки формы *
var
  j: Integer;
begin
  for j := 0 to TabSet.Tabs.Count - 1 do
    if TabSet.Tabs.Objects[j] = frm then
      TabSet.TabIndex := j;
end;

procedure TDLMDIFormMain.TabSetChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
// переход по TabSet *
begin
  try
    TForm(TabSet.Tabs.Objects[NewTab]).Show;
  except
    TabSet.Tabs.Delete(NewTab);
  end;
end;

procedure TDLMDIFormMain.CreateChildForm(ClassForm: TFormClass);
// создание дочерней формы *
var
  frm: TForm;
  i: integer;
begin
  // перебираем все дочерние формы
  for i := MDIChildCount - 1 downto 0 do
  begin
    // если нашли форму
    if (MDIChildren[i] is ClassForm) then
    begin
      frm := TForm(MDIChildren[i]);
       // отображаем ее на экране
      if frm.WindowState = wsMinimized then
        frm.WindowState := wsMaximized;
      frm.Show;
      ActivateTab(frm);
      Exit; // и выходим из процедуры
    end;
  end;
  // иначе создаем форму
  frm := TForm(ClassForm.Create(Self));
  TabSet.Tabs.AddObject(frm.Caption, frm);
  ActivateTab(frm);
end;

procedure TDLMDIFormMain.CreateChildForm(var NameForm; ClassForm: TFormClass);
// создание дочерней формы с экземляром класса *
var
  frm: TForm;
  i: integer;
begin
  // перебираем все дочерние формы
  for i := MDIChildCount - 1 downto 0 do
  begin
    // если нашли форму
    if (MDIChildren[i] is ClassForm) then
    begin
      frm := TForm(MDIChildren[i]);
       // отображаем ее на экране
      if frm.WindowState = wsMinimized then
        frm.WindowState := wsMaximized;
      frm.Show;
      ActivateTab(frm);
      Exit; // и выходим из процедуры
    end;
  end;
  // иначе создаем форму
  frm := TForm(ClassForm.Create(Self));
  TForm(NameForm) := frm;
  TabSet.Tabs.AddObject(frm.Caption, frm);
  ActivateTab(frm);
end;

procedure TDLMDIFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// Подтверждение выхода *
begin
  if Application.MessageBox('Завершить работу приложения?','Завершение работы...'
                           , MB_YESNO + MB_ICONQUESTION) = ID_NO then CanClose := False;
end;

procedure TDLMDIFormMain.FormCreate(Sender: TObject);
begin
  RegPSMEhDjenyaSoft.Path := cRegNode + cEng_NameProg;
  cmdCreatePopupMenu.Execute;

  if (Screen.Height < 600) or (Screen.Width < 800) then
  begin
    Application.MessageBox(PChar('Установлено слишком маленькое разрешение экрана!'
                           + #10#13 + 'Измените его пожалуйста не меньше чем 800x600.'),
                           PChar('Запуск не удался...'), MB_OK + MB_ICONERROR);
    Application.Terminate;
    Exit;
  end;

  LoadJPGToImage(imgBackground, 'FRMMAIN', 'IMAGE_MAIN');

  RegProp.RootKey := HKEY_CURRENT_USER;
  RegProp.OpenKey(RegPSMEhDjenyaSoft.Path, True);

  cmdConnect.Execute;
end;

procedure TDLMDIFormMain.FormShow(Sender: TObject);
begin
  // проверка версии приложения
  TimerCheckUpdate.Enabled := True;

  lblHintLogin.Caption := '  ' + LoginTunes.Login + '  ';
  lblHintServer.Caption := '  ' + LoginTunes.WorkServer + '  ';
  Self.Caption := cRus_NameProg + ' [v.' + GetFileVersionString(Application.ExeName) + ']';
end;

function TDLMDIFormMain.GetVersionValue(const Version: String): String;
// проверка версии программы, с добавлением 0
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

procedure TDLMDIFormMain.N9Click(Sender: TObject);
begin
  Close;
end;

procedure TDLMDIFormMain.StatusTimerTimer(Sender: TObject);
var
  Layout: array [0.. KL_NAMELENGTH] of Char;
  LangID: cardinal;
begin

  with MainStatusBar do begin
    Panels[0].Text := FormatDateTime('dd.mm.yyyy', Date());
    Panels[1].Text := FormatDateTime('hh:nn', Now());

    // отображаем язык ввода
    try
      GetKeyboardLayoutName(Layout);
      LangID := StrToInt('$' + string(Layout));
      LangID := Languages.IndexOf(LangID);
      Panels[2].Text := Format(RES_INPUT_LANGUAGE, [Languages.Ext[LangID]]);
      //Panels[3].Text := Format(RES_INPUT_LANGUAGE, [RES_UNKNOW_LANGUAGE]);
    except
      Panels[2].Text := Format(RES_INPUT_LANGUAGE, [RES_UNKNOW_LANGUAGE]);
    end;

    if Odd(GetKeyState(VK_NUMLOCK)) then
      Panels[3].Text := 'NUM'
    else
      Panels[3].Text := '';

    if Odd(GetKeyState(VK_CAPITAL)) then
      Panels[4].Text := 'CAPS'
    else
      Panels[4].Text := '';


    if Odd(GetKeyState(VK_SCROLL)) then
      Panels[5].Text := 'SCROLL'
    else
      Panels[5].Text := '';

    if LoginTunes.dboAdmin then
      Panels[6].Text := 'db_owner'
    else Panels[6].Text := ''
  end;
end;

procedure TDLMDIFormMain.TimerCheckUpdateTimer(Sender: TObject);
// всплывающая панель с информацией о доступном обновлении программы
begin
  if not Assigned(DLfrmUpdate) then
  begin
    if CheckVersions = '>' then
    begin
      TDLfrmUpdate.DataModul := FDataModul;
      DLfrmUpdate := TDLfrmUpdate.Create(Self);
      ShowWindow(DLfrmUpdate.Handle, SW_SHOWNOACTIVATE);
    end;
  end;
end;

procedure TDLMDIFormMain.ApplicationEventsHint(Sender: TObject);
begin
  MainStatusBar.Panels[7].Text := Application.Hint;
end;

procedure TDLMDIFormMain.cmdChangeUserExecute(Sender: TObject);
// смена пользователя *
var i: Integer;
begin
  Self.Visible := False;

  // перебираем все дочерние формы
  for i := MDIChildCount - 1 downto 0 do
    TForm(MDIChildren[i]).Close;

  cmdConnect.Execute;
end;

procedure TDLMDIFormMain.cmdCheckVersionsServerExecute(Sender: TObject);
var res: string;
begin
  res := CheckVersions;
  if res = '>' then cmdUpdate.Execute
  else if res = '<' then cmdUpload.Execute
  else if res = '=' then Application.MessageBox('Новой версии не обнаружено...',
                          'Обновление', MB_ICONINFORMATION+MB_OK);
end;

procedure TDLMDIFormMain.cmdConnectExecute(Sender: TObject);
// процедура для предворительных настроек запуска программы *
var res: string;
begin
  with TDLfrmSplash.СreateLogin(Self, FDataModul.cnMain, FDataModul.cnReport) do
  begin
    Visible := False;
    case ShowModal of
      mrOk:
      begin
        Self.Enabled := True;
        Self.Visible := True;
      end;
      mrCancel:
      begin
        Application.Terminate;
        Abort; Exit;
      end
    end;
    Free;
  end;

  // сохранение пароля(с шифрованием)
  if RegProp.ValueExists('SavePas') then
  begin
    if RegProp.ReadBool('SavePas') = True then
    begin
      RegProp.WriteString('NameUser', LoginTunes.Login);
      RegProp.WriteString('PasswordUser', ShifrPassword(LoginTunes.Password))
    end;
  end;

  // проверка обновлений
  res := CheckVersions;
  if res = '>' then cmdUpdate.Execute
  else if res = '<' then cmdUpload.Execute;
end;

procedure TDLMDIFormMain.cmdCreatePopupMenuExecute(Sender: TObject);
var
  i, j: Integer;
  pmMain: TPopupMenu;
  mi, msub: TMenuItem;
begin
  pmMain:= TPopupMenu.Create(self);
  with pmMain do
  begin
    Images:= mMain.Images;
    for i:= 0 to mMain.Items.Count - 1 do
    begin
      mi:= TMenuItem.Create(self);
      with mi do
      begin
        Caption:= mMain.Items[i].Caption;
        Action:= mMain.Items[i].Action;
        OnClick:= mMain.Items[i].OnClick;
        ImageIndex:= mMain.Items[i].ImageIndex;
        Visible:= mMain.Items[i].Visible;

        for j:= 0 to mMain.Items[i].Count - 1 do
        begin
          msub:= TMenuItem.Create(self);
          with msub do
          begin
            Caption := mMain.Items[i].Items[j].Caption;
            Action := mMain.Items[i].Items[j].Action;
            OnClick := mMain.Items[i].Items[j].OnClick;
            ImageIndex := mMain.Items[i].Items[j].ImageIndex;
            Visible:= mMain.Items[i].Items[j].Visible;
          end;
          Insert(j, msub);
        end; {for j}
      end; {with mi}
      Items.Insert(i, mi);
    end; {for i}
  end; {with pmMain}

  imgBackground.PopupMenu:= pmMain;
end;

procedure TDLMDIFormMain.cmdfrmAboutExecute(Sender: TObject);
// создание формы "О разработчике" *
begin
  with TDLfrmAbout.Create(Self) do
  begin
    lblNameProgram.Font.Color := cColorLblAbout;
    lblNameProgram.Caption := cRus_NameProg;
    ShowModal;
    Free;
  end;
end;

procedure TDLMDIFormMain.cmdReconnectExecute(Sender: TObject);
var
  i: Integer;
  isTerminate: Boolean;
  res: string;
begin
  isTerminate := False;

  if not ConnectionServer(FDataModul.cnMain, LoginTunes.WorkServer, LoginTunes.WorkDB, LoginTunes.Login, LoginTunes.Password) then
    isTerminate := True;

  if (Trim(LoginTunes.ReportServer) <> '') and (Trim(LoginTunes.ReportDB) <> '') then
  begin
    if not ConnectionServer(FDataModul.cnReport, LoginTunes.ReportServer, LoginTunes.ReportDB, LoginTunes.Login, LoginTunes.Password) then
      isTerminate := True;
  end;

  if isTerminate then
  begin
    Application.MessageBox(pchar('Cервер не доступен! Обратитесь к разработчику.' + #10#13#10#13
                           + 'Приложение будет закрыто!!!'),
      'Ошибка подключения', MB_ICONWARNING + MB_OK);
    Application.Terminate; Abort; Exit;
  end
  else begin
    // перебираем все дочерние формы
    for i := MDIChildCount - 1 downto 0 do
      TForm(MDIChildren[i]).Close;

    // проверка обновлений
    res := CheckVersions;
    if res = '>' then cmdUpdate.Execute
    else if res = '<' then cmdUpload.Execute;
  end;
end;

procedure TDLMDIFormMain.cmdUpdateExecute(Sender: TObject);
// скачать программу с сервера
begin
  if LoginTunes.dboAdmin then
    DownloadBinary(FDataModul.cnMain, True, True)
  else
    DownloadBinary(FDataModul.cnMain, True, False);
end;


procedure TDLMDIFormMain.cmdUploadExecute(Sender: TObject);
// загрузить программу на сервер
begin
  if LoginTunes.dboAdmin then
  begin
    If Application.MessageBox('Загрузить новую версию программы на сервер?',
       pchar('Обновление'),
       MB_ICONQUESTION+MB_YESNO) = ID_YES Then UploadBinary(FDataModul.cnMain);
  end;
end;


end.
