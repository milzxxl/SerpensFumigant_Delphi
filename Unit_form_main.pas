unit Unit_form_main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects;

type
  Tform_main = class(TForm)
    pnlPrincipal: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure LoopGameStart();
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CreateSnake(SnakePosicaoInicialX,SnakePosicaoInicialY: Single);
    procedure MovementSnake(Sender: TObject);
    function  ReturnRandomPositionX:Single;
    function  ReturnRandomPositionY:Single;
    function  CheckCollision: Boolean;
    function  CheckFoodCollision: Boolean;
    procedure GrowSnake;
    procedure CreateTimer;
    procedure CreateFood;
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
    TMovimentDirection = (mdUp, mdDown, mdLeft, mdRight);
var
  form_main: Tform_main;
  ContinuarMovimento: Boolean;
  SnakeSegments:TList;
  Food: TRectangle;
  Snake:TRectangle;
  SnakeMovimentDirection:TMovimentDirection;
  SnakeWidth: Single;
  GameTimer:TTimer;
  SpeedSnake:integer;
implementation

uses
  FMX.Graphics;

{$R *.fmx}

procedure Tform_main.Button1Click(Sender: TObject);
begin
  if Assigned(Snake) then
  begin
    Snake.Destroy;
    Snake := nil; 
  end;

  LoopGameStart;
end;

procedure Tform_main.Button2Click(Sender: TObject);
begin
  ContinuarMovimento:=false;
end;

function Tform_main.CheckCollision: Boolean;
begin

  if (Snake.Position.X < 0) or
     (Snake.Position.X + Snake.Width > pnlPrincipal.Width) or
     (Snake.Position.Y < 0) or
     (Snake.Position.Y + Snake.Height > pnlPrincipal.Height) then
  begin
    Result := True;
  end;
end;

function Tform_main.CheckFoodCollision: Boolean;
var
  SnakeRect, FoodRect: TRectF;
begin
  Result := False;
  if not Assigned(Snake) or not Assigned(Food) then
    Exit; 
  
  SnakeRect := RectF(Snake.Position.X, Snake.Position.Y, Snake.Position.X + Snake.Width, Snake.Position.Y + Snake.Height);
  FoodRect := RectF(Food.Position.X, Food.Position.Y, Food.Position.X + Food.Width, Food.Position.Y + Food.Height);

  Result := SnakeRect.IntersectsWith(FoodRect);
end;

procedure Tform_main.CreateFood;
begin
if not Assigned(Food) then
  begin
    Food := TRectangle.Create(pnlPrincipal);
    Food.Parent := pnlPrincipal;
    Food.Width := 10;
    Food.Height := 10;
    Food.Fill.Color := TAlphaColors.Red;
  end;

  repeat
    Food.Position.X := Random(Round(pnlPrincipal.Width - Food.Width));
    Food.Position.Y := Random(Round(pnlPrincipal.Height - Food.Height));
  until not CheckFoodCollision;
end;

procedure Tform_main.CreateSnake(SnakePosicaoInicialX,SnakePosicaoInicialY: Single);
begin
  Snake:=TRectangle.Create(Self);
 with Snake do
 begin
  Parent := pnlPrincipal;
    Fill.Kind := TBrushKind.Gradient;
    Fill.Gradient.Style := TGradientStyle.Linear;
    Fill.Gradient.Points[0].Color := TAlphaColors.ForestGreen;
    Fill.Gradient.Points[1].Color := TAlphaColors.DarkGreen;
    XRadius := 5;
    YRadius := 5;
    Width := 30;
    Height := 20;
    Position.X := SnakePosicaoInicialX;
    Position.Y := SnakePosicaoInicialY;
  end;
  if Assigned(SnakeSegments) then
    SnakeSegments.Destroy;

  SnakeSegments:=TList.Create;

  SnakeSegments.Add(Snake);
 end;

procedure Tform_main.CreateTimer;
begin
 if not Assigned(GameTimer) then
  begin
    GameTimer := TTimer.Create(Self);
    GameTimer.Interval := 100;
    GameTimer.OnTimer := MovementSnake;
    GameTimer.Enabled := True;
  end;
end;

procedure Tform_main.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
    case Key of
    vkUp: SnakeMovimentDirection := mdUp;
    vkDown: SnakeMovimentDirection := mdDown;
    vkLeft: SnakeMovimentDirection := mdLeft;
    vkRight: SnakeMovimentDirection := mdRight;
  end;
end;

procedure Tform_main.FormShow(Sender: TObject);
begin
 SnakeWidth:=0;
end;

procedure Tform_main.GrowSnake;
var
  NewSegment: TRectangle;
begin
  NewSegment := TRectangle.Create(pnlPrincipal);

  with NewSegment do
  begin
    Parent := pnlPrincipal;
    Fill.Kind := TBrushKind.Gradient;
    Fill.Gradient.Style := TGradientStyle.Linear;
    Fill.Gradient.Points[0].Color := TAlphaColors.ForestGreen;
    Fill.Gradient.Points[1].Color := TAlphaColors.DarkGreen;
    XRadius := 5;
    YRadius := 5;
    Width := Snake.Width;
    Height := Snake.Height;
    Position.X := TRectangle(SnakeSegments.Last).Position.X;
    Position.Y := TRectangle(SnakeSegments.Last).Position.Y;
  end;
  SnakeSegments.Add(NewSegment);
  NewSegment.Position.X := Snake.Position.X;
  NewSegment.Position.Y := Snake.Position.Y;
end;
procedure Tform_main.LoopGameStart();
begin
//LoopPrincipal
  if not Assigned(Snake) then
    CreateSnake(ReturnRandomPositionX,ReturnRandomPositionY);
 
  if not Assigned(GameTimer) then
   CreateTimer;

  Randomize;
  SpeedSnake:=15;
  CreateFood;
  GameTimer.Enabled:=true;
end;

procedure Tform_main.MovementSnake(Sender: TObject);
  var
  i: Integer;
  PrevX, PrevY, CurrentX, CurrentY: Single;
begin
  if not Assigned(Snake) then
  begin
    ShowMessage('A cobra não existe');
    Exit;
  end;
  if CheckFoodCollision then
  begin
    GrowSnake;
    CreateFood;  
  end;

  if CheckCollision then
  begin
    GameTimer.Enabled := false;
    ShowMessage('Game Over');
    Snake.Destroy;
    Snake:=nil;
    Exit;
  end;

  PrevX := Snake.Position.X;
  PrevY := Snake.Position.Y;

  case SnakeMovimentDirection of
    mdUp: Snake.Position.Y := Snake.Position.Y - SpeedSnake;
    mdDown: Snake.Position.Y := Snake.Position.Y + SpeedSnake;
    mdLeft: Snake.Position.X := Snake.Position.X - SpeedSnake;
    mdRight: Snake.Position.X := Snake.Position.X + SpeedSnake;
  end;


  for i := 1 to SnakeSegments.Count - 1 do
  begin
    CurrentX := TRectangle(SnakeSegments[i]).Position.X;
    CurrentY := TRectangle(SnakeSegments[i]).Position.Y;
    TRectangle(SnakeSegments[i]).Position.X := PrevX;
    TRectangle(SnakeSegments[i]).Position.Y := PrevY;
    PrevX := CurrentX;
    PrevY := CurrentY;
  end;


end;

function Tform_main.ReturnRandomPositionX: Single;
begin
  Result := Random * (pnlPrincipal.Width - SnakeWidth);
end;

function Tform_main.ReturnRandomPositionY: Single;
begin
  Result := Random * (pnlPrincipal.Height - SnakeWidth);
end;

end.
