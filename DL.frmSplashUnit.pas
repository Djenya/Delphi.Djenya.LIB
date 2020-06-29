unit DL.frmSplashUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ADODB, Winsock, ExtCtrls,
  PropFilerEh, PropStorageEh, DBCtrlsEh, Registry;

type
  TDLfrmSplash = class(TForm)
    edLogin: TEdit;
    edPassword: TEdit;
    btok: TBitBtn;
    btCancel: TBitBtn;
    imgSplash: TImage;
    lblVersion: TLabel;
    lblIP: TLabel;
    lblIPCaption: TLabel;
    PanelLP: TPanel;
    cbSavePas: TCheckBox;
    lblSavePsw: TLabel;
    imgIconProg: TImage;
    lblName: TLabel;
    btnCustomCon: TBitBtn;
    lblHostName: TLabel;
    lblHostNameCaption: TLabel;
    lblNameS: TLabel;
    lblLogin: TLabel;
    lblPsw: TLabel;
    lblCopyright: TLabel;
    lblLoginS: TLabel;
    lblPswS: TLabel;
    procedure btokClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PanelLPMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbSavePasClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblSavePswClick(Sender: TObject);
    procedure btnCustomConClick(Sender: TObject);
  private
    { Private declarations }
    LcnMain, LcnReport: TADOConnection;
  public
    { Public declarations }
    constructor СreateLogin(aowner: TComponent; AcnMain, AcnReport: TADOConnection);
  end;

implementation

uses ShellAPI, DL.RegStorage, DL.frmConnectOptionsUnit, GlobalConstUnit,
  DL.DataModul, DL.LibSysteminfo;

{$R *.dfm}

procedure TDLfrmSplash.btnCustomConClick(Sender: TObject);
begin
  with TDLfrmConnectOptions.Create(Self) do
  begin
    try
      if RegProp.ValueExists('WorkServer')
      then edWorkServer.Text := RegProp.ReadString('WorkServer')
      else edWorkServer.Text := cWorkServer;

      if RegProp.ValueExists('ReportServer')
      then edReportServer.Text := RegProp.ReadString('ReportServer')
      else edReportServer.Text := cReportServer;

      if RegProp.ValueExists('WorkDB')
      then edWorkDB.Text := RegProp.ReadString('WorkDB')
      else edWorkDB.Text := cWorkDB;

      if RegProp.ValueExists('ReportDB')
      then edReportDB.Text := RegProp.ReadString('ReportDB')
      else edReportDB.Text := cReportDB;

      if ShowModal = mrOk then
      begin
        RegProp.WriteString('WorkServer', edWorkServer.Text);
        RegProp.WriteString('WorkDB', edWorkDB.Text);
        RegProp.WriteString('ReportServer', edReportServer.Text);
        RegProp.WriteString('ReportDB', edReportDB.Text);
      end;
    finally
      Free;
    end;
  end;
end;

procedure TDLfrmSplash.btokClick(Sender: TObject);
begin
  if Trim(edLogin.Text) = '' then
  begin
    Application.MessageBox(pchar('Поле с именем пользователя не заполнено.'
                           + #10#13 + 'Не достаточно сведений для подключения!'
                           + #10#13#10#13 + 'Пожалуйста введите Логин (на латинице)...'),
      'Ошибка авторизации', MB_ICONSTOP + MB_OK);
    edLogin.SetFocus;
    Abort; Exit;
  end;

  if Trim(edPassword.Text) = '' then
  begin
    Application.MessageBox(pchar('Поле с паролем не заполнено.'
                           + #10#13 + 'Не достаточно сведений для подключения!'
                           + #10#13#10#13 + 'Пожалуйста введите пароль доступа...'),
      'Ошибка авторизации', MB_ICONSTOP + MB_OK);
    edPassword.SetFocus;
    Abort; Exit;
  end;

  if RegProp.ValueExists('WorkServer') then LoginTunes.WorkServer := RegProp.ReadString('WorkServer')
  else LoginTunes.WorkServer := cWorkServer;

  if RegProp.ValueExists('ReportServer') then LoginTunes.ReportServer := RegProp.ReadString('ReportServer')
  else LoginTunes.ReportServer := cReportServer;

  if RegProp.ValueExists('WorkDB') then LoginTunes.WorkDB := RegProp.ReadString('WorkDB')
  else LoginTunes.WorkDB := cWorkDB;

  if RegProp.ValueExists('ReportDB') then LoginTunes.ReportDB := RegProp.ReadString('ReportDB')
  else LoginTunes.ReportDB := cReportDB;

  if not ConnectionServer(LcnMain, LoginTunes.WorkServer, LoginTunes.WorkDB, edLogin.Text, edPassword.Text) then
  begin
    if Application.MessageBox(pchar('Ошибка подключения ' + edLogin.Text
                              + #10#13 + 'Или основной сервер не доступен!' + #10#13#10#13
                              + 'Изменить параметры подключения???'),
         'Ошибка подключения', MB_ICONERROR + MB_YESNO) = IDYES then btnCustomCon.Click;
    Abort; Exit;
  end;

  // подключилось к Основному серваку идём дальше
  // если в программе есть Сервер для отчетов, то подключиться и к нему
  if (Trim(LoginTunes.ReportServer) <> '') and (Trim(LoginTunes.ReportDB) <> '') then
  begin
    if not ConnectionServer(LcnReport, LoginTunes.ReportServer, LoginTunes.ReportDB, edLogin.Text, edPassword.Text) then
    begin
      if Application.MessageBox(pchar('Ошибка подключения ' + edLogin.Text
                                + #10#13 + 'Или сервер отчётов не доступен!' + #10#13#10#13
                                + 'Изменить параметры подключения???'),
           'Ошибка подключения', MB_ICONERROR + MB_YESNO) = IDYES then btnCustomCon.Click;
      Abort; Exit;
    end;
  end;

  // записать логин и пароль в глобальные переменные
  LoginTunes.Login := edLogin.Text;
  LoginTunes.Password := edPassword.Text;

  // если dbo Сервера или Основной БД, то записать параметр True
  LoginTunes.dboAdmin := LcnMain.Execute('select cast((isnull(IS_SRVROLEMEMBER(''serveradmin''),0)|'
    + 'isnull(IS_MEMBER(''db_Owner''), 0)) as bit)').Fields[0].Value;

  ModalResult := mrOk;
end;

procedure TDLfrmSplash.cbSavePasClick(Sender: TObject);
begin
  RegProp.WriteBool('SavePas', cbSavePas.Checked);
  if RegProp.ReadBool('SavePas') = False then RegProp.DeleteKey('PasswordUser');
end;

procedure TDLfrmSplash.FormCreate(Sender: TObject);
begin
  //иконка приложения и картинка фона
  imgIconProg.Picture.Icon.Handle := ExtractIcon(HInstance, Pchar(Paramstr(0)), 0);
  LoadJPGToImage(imgSplash, 'FRMSPLASH', 'IMAGE_S');

  //разукрасить под выбранный константой цвет
  lblName.Font.Color := cColorLblSplash;
  lblVersion.Font.Color := cColorLblSplash;
  lblIPCaption.Font.Color := cColorLblSplash;
  lblIP.Font.Color := cColorLblSplash;
  lblHostNameCaption.Font.Color := cColorLblSplash;
  lblHostName.Font.Color := cColorLblSplash;
  lblLogin.Font.Color := cColorLblSplash - 30;
  lblPsw.Font.Color := cColorLblSplash - 30;
  lblCopyright.Font.Color := cColorLblSplash - 20;
  lblSavePsw.Font.Color := cColorLblSplash;

  lblName.Caption := cRus_NameProg + ' (' + cEng_NameProg + ')';
  with lblNameS do
  begin
    AutoSize := lblName.AutoSize; Alignment:= lblName.Alignment;
    Height:= lblName.Height; Width:= lblName.Width;
    Top:= lblName.Top + 1; Left:= lblName.Left + 1;
    Font.Name:= lblName.Font.Name; Font.Size:= lblName.Font.Size;
    Font.Color:= clSilver; Font.Style:= lblName.Font.Style;
    Caption:= lblName.Caption;
  end;
  with lblLoginS do
  begin
    AutoSize:= lblLogin.AutoSize; Alignment:= lblLogin.Alignment;
    Height:= lblLogin.Height; Width := lblLogin.Width;
    Top:= lblLogin.Top + 1; Left:= lblLogin.Left + 1;
    Font.Name := lblLogin.Font.Name; Font.Size:= lblLogin.Font.Size;
    Font.Color:= clSilver; Font.Style:= lblLogin.Font.Style;
    Caption:= lblLogin.Caption;
  end;
  with lblPswS do
  begin
    AutoSize:= lblPsw.AutoSize; Alignment:= lblPsw.Alignment;
    Height:= lblPsw.Height; Width:= lblPsw.Width;
    Top:= lblPsw.Top + 1; Left:= lblPsw.Left + 1;
    Font.Name:= lblPsw.Font.Name; Font.Size:= lblPsw.Font.Size;
    Font.Color:= clSilver; Font.Style:= lblPsw.Font.Style;
    Caption:= lblPsw.Caption;
  end;


  with TAppInfo.Create do
  begin
    lblVersion.Caption := 'Версия ' + Version;
    Free;
  end;
  with TCompInfo.Create do
  begin
    lblIP.Caption := GetIP; // отображает IP-адрес
    lblHostName.Caption := GetCompName; //отображает хост(имя) компьютера
    Free;
  end;

  if RegProp.ValueExists('SavePas') then
  begin
    cbSavePas.Checked := RegProp.ReadBool('SavePas');

    if RegProp.ReadBool('SavePas') = True then
    begin
      if RegProp.ValueExists('NameUser') then edLogin.Text := RegProp.ReadString('NameUser');

      if RegProp.ValueExists('PasswordUser') then
        edPassword.text := ShifrPassword(RegProp.ReadString('PasswordUser'));
    end;
  end;
end;

procedure TDLfrmSplash.FormShow(Sender: TObject);
begin
  if edLogin.Text = '' then edLogin.SetFocus
  else edPassword.SetFocus;
end;

procedure TDLfrmSplash.lblSavePswClick(Sender: TObject);
begin
  cbSavePas.Checked := not cbSavePas.Checked;
  cbSavePasClick(self);
end;

procedure TDLfrmSplash.PanelLPMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //----------Перетаскивание формы по нажатию----------//
  Screen.Cursor := crSizeAll;
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012,0);
  Screen.Cursor := crDefault;
end;

constructor TDLfrmSplash.СreateLogin(aOwner: TComponent;
  AcnMain, AcnReport: TADOConnection);
begin
  inherited Create(aOwner);

  LcnMain := AcnMain;
  LcnReport := AcnReport;
end;

end.
