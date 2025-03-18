unit mainform;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Memo.Types,
  FMX.StdCtrls,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Edit,
  FMX.Controls.Presentation,
  FMX.ListBox,
  FMX.Layouts,
  FMX.Styles;

type
  TMain = class(TForm)
    Air: TStyleBook;
    Amakrits: TStyleBook;
    Aquagraphite: TStyleBook;
    Goldengraphite: TStyleBook;
    ComboBox1: TComboBox;
    Bouton: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    Switch1: TSwitch;
    Label1: TLabel;
    rbStylefromForm: TRadioButton;
    rbStyleManager: TRadioButton;
    rbLoadResource: TRadioButton;
    rbLoadFile: TRadioButton;
    GroupBox1: TGroupBox;
    OpenDialog1: TOpenDialog;
    rbFilename: TRadioButton;
    btnLoad: TButton;
    Label2: TLabel;
    Calypso: TStyleBook;
    StyleVide: TStyleBook;
    Layout1: TLayout;
    LytOpenDialog: TLayout;
    BtnCancel: TButton;
    btnOk: TButton;
    Label3: TLabel;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure rbLoadFileChange(Sender: TObject);
    procedure rbLoadResourceChange(Sender: TObject);
    procedure rbStyleManagerChange(Sender: TObject);
    procedure rbStylefromFormChange(Sender: TObject);
    procedure rbFilenameChange(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure frmOpendialog1btnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure BoutonClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure SetStylebookChilds( S : TStyleBook);
  public
    { Déclarations publiques }
    nbchild : word;
  end;

var
  Main: TMain;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

{TODO : autres vues écrans pour MACOS et IOS pour calypso}

uses
   System.IOUtils, ChildForm;

procedure TMain.BoutonClick(Sender: TObject);
var fc : TChild;
begin
  fc:=TChild.Create(Self);
  fc.parent:=Self; // pour modifier la propriété stylebook en cascade  si non UseStyleManager
  Inc(nbChild);
  fc.Caption:=Format('fenêtre enfant n°%d',[nbchild]);
  fc.StyleBook:=Self.StyleBook;
  fc.Show;
end;

procedure TMain.BtnCancelClick(Sender: TObject);
begin
 LytOpenDialog.Visible:=False;
end;

procedure TMain.btnLoadClick(Sender: TObject);
begin
SetStylebookChilds(nil);
{$IF Defined(MSWINDOWS) OR Defined(LINUX) OR defined(MACOS)}
    if opendialog1.Execute then
      // le switch permettra d'en voir la nécessité
        TStyleManager.SetStyleFromFile(Opendialog1.FileName);
 {$ENDIF}
 {$IF Defined(ANDROID) OR Defined (IOS)} // OR Defined(LINUX) }
//   FrmOpenDialog1.Visible:=true;
   LytOpenDialog.Visible:=true;
 {$ENDIF}
end;

procedure TMain.btnOkClick(Sender: TObject);
begin
{TODO : Autre OS où Opendialog ne fonctionne pas}
{$IF Defined(ANDROID) OR Defined(IOS)}
if ListBox1.ItemIndex>-1  then
begin
  Stylebook:=nil;
  var stylefilename :=Listbox1.Items[Listbox1.ItemIndex];
  {$IFDEF ANDROID}stylefilename:=TPath.Combine(Tpath.GetDocumentsPath,stylefilename);
  {$ENDIF}
  if rbLoadFile.ischecked then TStyleManager.SetStyleFromFile(stylefilename)
  else begin
   // Force une mise à jour de la forme
    Self.UpdateStyleBook;
   // Indique un nom de fichier contenant un style valide
    StyleVide.FileName:=stylefilename;
  // Indique que la forme utilise le composant Stylevide
    StyleBook:=StyleVide;
  // Notifier au StyleManager de redessiner la/les fenêtre(s)
       TStyleManager.UpdateScenes;
   end;
end;
  LytOpenDialog.Visible:=false;
{$ENDIF}
end;

procedure TMain.ComboBox1Change(Sender: TObject);
begin
  if rbStylefromForm.IsChecked // Utilisation de la méthode de Sarina Dupont
                               // le style est contenu dans l'élément de la combobox
     then rbStylefromFormChange(sender);


  if rbStyleManager.IsChecked // Utilisation de TstyleManager
      then rbStyleManagerChange(Sender);
end;

procedure TMain.FormCreate(Sender: TObject);
var Index : Integer;
begin
  nbChild:=0;
  // initialisations de la boite de choix
  ComboBox1.Items.add('défaut');
  // cf. blog Sarina Dupont
  EnumObjects(
    function(AObject: TFmxObject): TEnumProcResult
    begin
      if AObject is TStyleBook AND
         not Sametext(TStyleBook(AObject).Name,'stylevide')
         // rien n'est prévu comme vue spécifique pour LINUX
         // le style calypso chargé sera donc normalement incompatible
         // pourtant, surprise si on commente la ligne calypso.style de windows est compatible !!!
   {$IFDEF LINUX}AND NOT Sametext(TStyleBook(AObject).Name,'calypso') {$ENDIF}
         then
      begin
        Index := ComboBox1.Items.add(TStyleBook(AObject).Name);
        ComboBox1.ListItems[Index].Data := AObject;
      end;
      Result := TEnumProcResult.Continue;
    end);

{$IF Defined(ANDROID) OR Defined(IOS)}
 // Charger les fichiers disponibles
 // ceux qui seront mis au cours du déploiement dans ./assets/internal pour Android
 ListBox1.Items.Clear;
 var sl:=TDirectory.GetFiles(TPath.GetDocumentsPath,'*.style');
 for var s in  SL do ListBox1.Items.Add(extractfilename(s));
 sl:=TDirectory.GetFiles(TPath.GetDocumentsPath,'*.fsf');
 for var s in  SL do ListBox1.Items.Add(extractfilename(s));
{$ENDIF}
end;

procedure TMain.frmOpendialog1btnOkClick(Sender: TObject);
begin
 lytOpendialog.Visible:=False;
end;

procedure TMain.rbStylefromFormChange(Sender: TObject);
begin
  btnLoad.Visible:=(rbLoadFile.IsChecked) OR (rbFilename.IsChecked);
  LytOpenDialog.Visible:=False;
   // cf. blog Sarina Dupont
  if ComboBox1.ItemIndex >= 1 then
    Stylebook := TStyleBook(ComboBox1.ListItems[ComboBox1.ItemIndex].Data)
  else
    Stylebook := nil; // Style par défaut contenu dans les ressources du programme
// mettre à jour stylebook des fenêtres existantes
  SetStylebookChilds(Stylebook);
end;

procedure TMain.rbFilenameChange(Sender: TObject);
begin
  btnLoad.Visible:=(rbLoadFile.IsChecked) OR (rbFilename.IsChecked);
 // Changement de la propriété stylebook
 {$IF defined(MSWINDOWS) OR defined(LINUX) OR defined(MACOS) }
 if rbFileName.IsChecked then
  begin
    SetStylebookChilds(nil);
    if Opendialog1.Execute then
     begin
       // s'assure que le composant Stylevide est bien vide
        StyleVide.Styles.Clear;
         // Indique un nom de fichier contenant un style valide
       StyleVide.FileName:=Opendialog1.FileName;
      // Indique que la forme utilise le composant Stylevide
      // Force une mise à jour de la forme
         TStyleManager.SetStyle(StyleVide.Style);
      // Notifier au StyleManager de redessiner la/les fenêtre(s)
     end
     else StyleVide.Styles.Clear;
   end;
 {$ENDIF}
 {$IF Defined(ANDROID) OR Defined(IOS) }
   LytOpenDialog.Visible:=True;
 {$ENDIF}
end;


procedure TMain.rbLoadFileChange(Sender: TObject);
begin
  btnLoad.Visible:=(rbLoadFile.IsChecked) OR (rbFilename.IsChecked);
  Stylebook := nil;
{$IF Defined(MSWINDOWS) OR Defined(LINUX) OR Defined(MACOS)}
    // s'assure que stylebook est vide
    SetStylebookChilds(nil);

    if rbLoadfile.IsChecked AND OpenDialog1.Execute then
    begin
      if not TStyleManager.SetStyleFromFile(OpenDialog1.FileName) then
        showmessage('Style incompatible');
    end;
{$ENDIF}
{$IF Defined(ANDROID) OR Defined(IOS)}
  LytOpenDialog.Visible:=true;
{$ENDIF}
end;

procedure TMain.rbLoadResourceChange(Sender: TObject);
begin
  btnLoad.Visible:=(rbLoadFile.IsChecked) OR (rbFilename.IsChecked);
  LytOpenDialog.Visible:=False;
  if rbLoadResource.IsChecked then
  begin
    SetStylebookChilds(nil);
    TStyleManager.TrySetStyleFromResource('Blend');
  end;
end;

procedure TMain.rbStyleManagerChange(Sender: TObject);
begin
  btnLoad.Visible:=(rbLoadFile.IsChecked) OR (rbFilename.IsChecked);
  LytOpenDialog.Visible:=False;
  if rbStyleManager.IsChecked then
  begin
    SetStylebookChilds(nil);
    if ComboBox1.ItemIndex >= 1 then
     begin
      // Récupère le StyleBook à appliquer
       var aStyleBook :=FindComponent(ComboBox1.ListItems
        [ComboBox1.ItemIndex].Text);
 {$IFDEF MSWINDOWS}
         TStyleManager.SetStyle(TStyleBook(aStylebook).Style.Clone(self));

{$ELSE}
        // un seul coup
        if TStylebook(aStyleBook).Style<>nil then TStyleManager.SetStyle(TStyleBook(aStyleBook).Style);
 {$ENDIF}
      end
     else TStyleManager.SetStyle(nil);

//        nécessaire ?
//        TStyleManager.UpdateScenes;

    end;
  end;


procedure TMain.SetStylebookChilds(S: TStyleBook);
begin
for var i := 0 to ComponentCount-1 do
  if Components[i] is TChild then
    TForm(Components[i]).StyleBook:=S;
end;

initialization
ReportMemoryLeaksOnShutdown:=DebugHook>0;

end.
