unit Soko1;

{
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Sokoban, StdCtrls, ShellAPI, IniFiles;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    OpenDlg: TOpenDialog;
    procedure Label2Click(Sender: TObject);
    procedure Soko1Win(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label6Click(Sender: TObject);
  private
    Soko1 : TSoko;
    fLevel:integer;
    Start:TDateTime;
    Next :string;
    procedure LoadFromFile(AFileName:string);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

Const
 help='Sokoban (C) 2000 By Paul TOTH <tothpaul@free.fr>'#13#13+
      'The object of the game is quite simple - you must push all the mines into storage rooms,'#13+
      'preferably in the fewest number of moves and pushes.'#13#13+
      'This program is free software; you can redistribute it and/or'+
      'modify it under the terms of the GNU General Public License'+
      'as published by the Free Software Foundation; either version 2'+
      'of the License, or (at your option) any later version.'#13+
      'This program is distributed in the hope that it will be useful,'+
      'but WITHOUT ANY WARRANTY; without even the implied warranty of'+
      'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the'+
      'GNU General Public License for more details.'#13+
      'You should have received a copy of the GNU General Public License'+
      'along with this program; if not, write to the Free Software'+
      'Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.';

 Levels:array[1..3,0..10] of pchar=
// X = Wall
// * = Mine
// @ = storage room
// ! = player
 ((
  'XXXXXXXXXXXXXXXXXXX',
  'XXXXX...XXXXXXXXXXX',
  'XXXXX*..XXXXXXXXXXX',
  'XXXXX..*XXXXXXXXXXX',
  'XXX..*.*.XXXXXXXXXX',
  'XXX.X.XX.XXXXXXXXXX',
  'X...X.XX.XXXXX..@@X',
  'X.*..*..........@@X',
  'XXXXX.XXX.X!XX..@@X',
  'XXXXX.....XXXXXXXXX',
  'XXXXXXXXXXXXXXXXXXX'
 ),(
  'XXXXXXXXXXXXXXXXXXX',
  'X@@..X.....XXXXXXXX',
  'X@@..X.*..*..XXXXXX',
  'X@@..X*XXXX..XXXXXX',
  'X@@....!.XX..XXXXXX',
  'X@@..X.X..*.XXXXXXX',
  'XXXXXX.XX*.*.XXXXXX',
  'XXX.*..*.*.*.XXXXXX',
  'XXX....X.....XXXXXX',
  'XXXXXXXXXXXXXXXXXXX',
  'XXXXXXXXXXXXXXXXXXX'
 ),(
  'XXXXXXXXXXXXXXXXXXX',
  'XXXXXXXXXXXXXXXXXXX',
  'XXXXXXXXX.....!XXXX',
  'XXXXXXXXX.*X*.XXXXX',
  'XXXXXXXXX.*..*XXXXX',
  'XXXXXXXXXX*.*.XXXXX',
  'XXXXXXXXX.*.X.XXXXX',
  'X@@@@..XX.*..*..XXX',
  'XX@@@....*..*...XXX',
  'X@@@@..XXXXXXXXXXXX',
  'XXXXXXXXXXXXXXXXXXX'
 ));

procedure TForm1.Label2Click(Sender: TObject);
begin
 with TLabel(Sender) do begin
  Font.color:=clPurple;
  Application.ProcessMessages;
  case Tag of
   0:ShellExecute(Handle,nil,'mailto:tothpaul@free.fr',nil,nil,0);
   1:ShowMessage(Help);
   2:ShellExecute(Handle,nil,'http://tothpaul.free.fr',nil,nil,0);
   3:Application.Terminate;
  end;
 end;
end;

procedure TForm1.Soko1Win(Sender: TObject);
begin
 if fLevel<>0 then begin
   ShowMessage('Level complet with '+IntToStr(Soko1.MoveCount)+' moves - '+FormatDateTime('hh:mm:ss',Time-Start));
 end;
 if fLevel<0 then begin
  LoadFromFile(Next);
  exit;
 end;
 inc(fLevel);
 if fLevel<=High(Levels) then begin
  ShowMessage('Entering level '+IntToStr(fLevel));
  Soko1.LoadLevel(Levels[fLevel]);
  Start:=Time;
 end else begin
  ShowMessage(
   'Congratulations !'#13+
   'Send me your own levels, look at Soko1.pas to see how they are build...'
  );
 end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 Soko1:=TSoko.Create(Form1);
 Soko1.Parent:=Form1;
 Soko1.Top:=15;
 fLevel:=0;
end;

procedure TForm1.Label6Click(Sender: TObject);
begin
 if OpenDlg.Execute then LoadFromFile(OpenDlg.FileName);
end;

procedure TForm1.LoadFromFile(AFileName:string);
 var
  s:TStringList;
 begin
  s:=TStringList.Create;
  try
   try
    s.LoadFromFile(AFileName);
    Caption:=s[0];
    Next:=s[12];
    Soko1.LoadStrings(s);
    fLevel:=-1;
   except
    ShowMessage(AFileName);
   end;
  finally;
   s.Free;
  end;
 end;

end.
