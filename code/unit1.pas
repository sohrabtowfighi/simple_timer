unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, fpexprpars;

type

  { TForm1 }

  TForm1 = class(TForm)
    Countdown: TLabel;
    RunTimer: TButton;
    TestSound: TButton;
    Timer2: TTimer;
    TimeSec: TEdit;
    Label1: TLabel;
    RunningLabel: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure RunTimerClick(Sender: TObject);
    procedure TestSoundClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { private declarations }
    status: Boolean;
    runlabelshift: Integer;
    timeleft: integer;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Inherited;
  // false upon init
  status := False;
  runlabelshift := 22;
  timeleft := 0;
  Self.DoubleBuffered:=True;
end;

procedure TForm1.TestSoundClick(Sender: TObject);
begin
  // Run the windows beep
  SysUtils.beep();
  Timer1.Enabled := False;
  status := False;
  RunTimer.Caption := 'Run Timer';
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  TestSoundClick(Sender);
  TestSound.Visible := True;
  RunningLabel.Caption := 'Done';
  Timer2.Enabled := False;
  Countdown.Visible := False;
  Runninglabel.Left :=  Runninglabel.Left + runlabelshift;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  timeleft := Trunc(timeleft - (Timer2.Interval)/1000);
  Countdown.Visible := True;
  Countdown.Caption := 'Time Left: ' + IntToStr(timeleft);
end;

procedure TForm1.RunTimerClick(Sender: TObject);
var
  parsed: String;
  floata: Double;
  FParser: TFPExpressionParser;
begin
  // Try as float
  // Then try as parsed
  FParser := TFPExpressionParser.Create(nil);
  try
    FParser.Builtins := [bcMath];
    FParser.Expression := TimeSec.Text;
    parsed := FloatToStr(ArgToFloat(FParser.Evaluate));
    if TryStrToFloat(TimeSec.Text,floata) then
      parsed := TimeSec.Text;
    if RunningLabel.Caption = 'Done' then
    begin
        RunningLabel.Caption := 'Running!';
        RunningLabel.Left := RunningLabel.Left - runlabelshift;
    end;
    if TryStrToFloat(TimeSec.Text,floata) then
      parsed := TimeSec.Text;
    if (TryStrToFloat(parsed,floata)) and
        (StrToFloat(parsed) > 0) and
        (StrToFloat(parsed) < 1E6+1) then
    begin
      // Start the timer and activate the activatedtext
      Timer1.Interval := Trunc(StrToFloat(parsed)*1000);
      timeleft := Trunc(StrToFloat(parsed));
      status := not status;
      Timer1.Enabled := status;
      Timer2.Enabled := status;
      RunningLabel.Visible := status;
      if status = True then
      begin
        RunTimer.Caption := 'Stop Timer';
        TestSound.Visible := False;
      end;
      if status = False then
      begin
        RunTimer.Caption := 'Run Timer';
        TestSound.Visible := True;
        //Countdown.Visible := False;
      end;
    end
    else
    begin
      if (StrToFloat(parsed) > 1E6) then
       ShowMessage('Input too large - 1E6 limit');
    end;
   except
     Countdown.Visible := False;
   end;
   FParser.Free;
end;


end.
