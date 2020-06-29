program DEMO;

uses
  Forms,
  DjenyaLibDialog,
  frmUnitDialog in 'frmUnitDialog.pas' {frm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm, frm);
  Application.Run;
end.
