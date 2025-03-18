unit ChildForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.Edit, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation,
  FMX.Layouts;

type
  TChild = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    Memo1: TMemo;
    BtnClose: TButton;
    Edit1: TEdit;
    Switch1: TSwitch;
    CheckBox1: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnCloseClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Child: TChild;

implementation

{$R *.fmx}

procedure TChild.BtnCloseClick(Sender: TObject);
begin
Close;
end;

procedure TChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Action:=TCloseAction.caFree;
end;

end.
