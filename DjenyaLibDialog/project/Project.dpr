program Project;

uses
  Forms,
  DjenyaLibDialog in 'DjenyaLibDialog.pas' {frmMessage};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
