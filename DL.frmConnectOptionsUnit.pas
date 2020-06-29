unit DL.frmConnectOptionsUnit;

interface

uses
  Forms,
  StdCtrls,
  Controls,
  Classes,
  Buttons, ExtCtrls;

type
  TDLfrmConnectOptions = class(TForm)
    pnlWork: TPanel;
    pnlReport: TPanel;
    pnlButton: TPanel;
    btnCancel: TBitBtn;
    btnDefault: TBitBtn;
    btnOk: TBitBtn;
    lblReportDb: TLabel;
    edReportDB: TEdit;
    edReportServer: TEdit;
    lblReportServer: TLabel;
    edWorkDB: TEdit;
    edWorkServer: TEdit;
    lblEditServer: TLabel;
    lblEditDataBase: TLabel;
    procedure btnDefaultClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses GlobalConstUnit, SysUtils;

{$R *.dfm}

procedure TDLfrmConnectOptions.btnDefaultClick(Sender: TObject);
begin
  edWorkServer.Text := cWorkServer;
  edWorkDB.Text := cWorkDB;
  edReportServer.Text := cReportServer;
  edReportDB.Text := cReportDB;
end;

procedure TDLfrmConnectOptions.FormShow(Sender: TObject);
begin
  // если не указаны данные Сервера или Бд для отчетов, то скрыть соотв. панель
  if (Trim(edReportServer.Text) = '') or (Trim(edReportDB.Text) = '') then
    pnlReport.Visible := False;
end;

end.
