unit frmUnitDialog;

interface

uses
  Windows, Messages, Forms, StdCtrls, Classes, Controls;

type
  Tfrm = class(TForm)
    bt0: TButton;
    bt2: TButton;
    bt3: TButton;
    bt1: TButton;
    procedure bt0Click(Sender: TObject);
    procedure bt2Click(Sender: TObject);
    procedure bt3Click(Sender: TObject);
    procedure bt1Click(Sender: TObject);
  end;

var frm: Tfrm;

implementation

{$R *.dfm}

procedure Tfrm.bt0Click(Sender: TObject);
begin
  Application.MessageBox('�������� ����� ���������',
    '��� �������� ��������� �0',
    MB_OK);
end;

procedure Tfrm.bt2Click(Sender: TObject);
begin
  Application.MessageBox('�������� ����� ���������' + #10#13
                       + '������ 2' + #10#13
                       + '������ 3' + #10#13
                       + '������ 4',
    '��� �������� ��������� �2',
    MB_YESNO);
end;

procedure Tfrm.bt3Click(Sender: TObject);
begin
  Application.MessageBox('�������� ����� ���������',
    '��� �������� ��������� �3',
    MB_YESNOCANCEL);
end;

procedure Tfrm.bt1Click(Sender: TObject);
begin
  Application.MessageBox('�������� ����� ���������',
    '��� �������� ��������� �1',
    MB_OKCANCEL + MB_ICONERROR);
end;

end.
