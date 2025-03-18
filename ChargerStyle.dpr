program ChargerStyle;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  mainform in 'mainform.pas' {Main},
  ChildForm in 'ChildForm.pas' {Child};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
