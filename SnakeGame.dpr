program SnakeGame;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit_form_main in 'Unit_form_main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tform_main, form_main);
  Application.Run;
end.
