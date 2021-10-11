unit Sokoban;

{ Sokoban component for Delphi 2+ (C)2K by Paul TOTH <tothpaul@free.fr>
  http://tothpaul.free.fr
}
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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

Const
 maxx=19;
 maxy=11;

type
  TBoard=array[0..maxx-1,0..maxy-1] of byte;

  TMove=(mNone,mNorth,mSouth,mEast,mWest);

  TSoko = class(TCustomControl)
  private
   fBoard:TBoard;
   fEndOfGame:boolean;
   fMoveCount:integer;
   fMaxX:integer;
   fMaxY:integer;
   fCellX:integer;
   fCellY:integer;
   fPlayerX:integer;
   fPlayerY:integer;
   fMouseX:integer;
   fMouseY:integer;
   fMove:TMove;
   fMines:integer;
   fDock:integer;
   EOnNewGame:TNotifyEvent;
   EOnWin:TNotifyEvent;
   procedure SetCell(X,Y:integer;State:integer);
   procedure WMSetCursor(Var Msg:TWMSetCursor); message wm_setcursor;
   procedure WMGetDlgCode(Var Msg:TWMGetDlgCode); message wm_getdlgcode;
  protected
   procedure Paint; override;
   procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
   procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
   procedure KeyDown(var Key: Word; Shift: TShiftState); override;
   procedure Play;
  public
   constructor Create(AOwner:TComponent); override;
   procedure LoadLevel(Level:array of PChar);
   procedure LoadStrings(S:TStringList);
   property EndOfGame:boolean read fEndOfGame;
   property MoveCount:integer read fMoveCount;
  published
   property OnNewGame:TNotifyEvent read EOnNewGame write EOnNewGame;
   property OnWin:TNotifyEvent read EOnWin write EOnWin;
   property TabStop;
   property OnMouseDown;
   property OnMouseUp;
   property OnKeyDown;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('MySoft.Fun', [TSoko]);
end;

{$R SOKOBAN.RES}

Var
 Images:HBitmap;
 Cursors:array[TMove] of HCursor;

Const
 //TMove=(mNone,mNorth,mSouth,mEast,mWest);
 Delta:array[TMove] of record dx,dy:integer end=(
 (dx:0;dy:0), (dx:0;dy:-1), (dx:0;dy:+1), (dx:+1;dy:0), (dx:-1;dy:0)
 );

 Hello:array[0..10] of PChar=(
  'XXXXXXXXXXXXXXXXXXX',
  'XXXXXXXXXXXXXXXXXXX',
  'XX@@@XXX@XX@X@XX@XX',
  'X@XXXXX@X@X@X@X@X@X',
  'XX@@@XX@X@X@@XX@X@X',
  'XXXXX@X@X@X@X@X@X@X',
  'XX@@@XXX@XX@X@XX@XX',
  'XXXXXXXXXXXXXXXXXXX',
  'X!.......*.......@X',
  'XXXXXXXXXXXXXXXXXXX',
  'XXXXXXXXXXXXXXXXXXX'
 );

Constructor TSoko.Create(AOwner:TComponent);
 begin
  inherited Create(AOwner);
  LoadLevel(Hello);
  fMines:=1;
  TabStop:=true;
 end;

Procedure TSoko.Paint;
 var
  dc:HDC;
  mx,my:integer;
 begin
  dc:=CreateCompatibleDC(Canvas.Handle);
  SelectObject(dc,Images);
  for mx:=0 to maxx-1 do
   for my:=0 to maxy-1 do
    BitBlt(Canvas.Handle,16*mx,16*my,16,16,DC,0,16*fBoard[mx,my],SRCCOPY);
  DeleteDC(dc);
 end;

Procedure TSoko.LoadLevel(Level:Array of PChar);
 var
  x,y:integer;
 begin
  fMaxY:=High(Level)+1;
  fMaxX:=StrLen(Level[0]);
  Width:=16*fMaxX;
  Height:=16*fMaxY;
  fEndOfGame:=False;
  fMoveCount:=0;
  fDock:=0;
  fMines:=0;
  FillChar(fBoard,SizeOf(fBoard),0);
  for y:=0 to MaxY-1 do begin
   for x:=0 to MaxX-1 do begin
    fBoard[x,y]:=Pos(Level[y][x],{.}'@**!!X');
    case fBoard[x,y]of
     2 : inc(fMines);
     4 : begin fPlayerX:=X; fPlayerY:=Y; end;
    end;
   end;
  end;
  Invalidate;
  if Assigned(EOnNewGame) then EOnNewGame(Self);
 end;

procedure TSoko.LoadStrings(S:TStringList);
 var
  x,y:integer;
 begin
//  fMaxY:=s.Count;
//  fMaxX:=Length(s[0]);
//  Width:=16*fMaxX;
//  Height:=16*fMaxY;
  fEndOfGame:=False;
  fMoveCount:=0;
  fDock:=0;
  fMines:=0;
  FillChar(fBoard,SizeOf(fBoard),0);
  for y:=0 to MaxY-1 do begin
   for x:=0 to MaxX-1 do begin
    fBoard[x,y]:=Pos(s[y+1][x+1],{.}'@**!!X');
    case fBoard[x,y]of
     2 : inc(fMines);
     4 : begin fPlayerX:=X; fPlayerY:=Y; end;
    end;
   end;
  end;
  Invalidate;
  if Assigned(EOnNewGame) then EOnNewGame(Self);
 end;

procedure TSoko.MouseMove(Shift: TShiftState; X, Y: Integer);
 begin
  fMouseX:=X div 16;
  fMouseY:=Y div 16;
  inherited MouseMove(Shift,X,Y);
 end;

procedure TSoko.WMSetCursor(Var Msg:TWMSetCursor);
 var
  dy:integer;
 begin
  dy:=fPlayerY-fMouseY;
  fMove:=mNone;
  if fBoard[fMouseX,fMouseY]<4 then begin
   case fPlayerX-fMouseX of
    -1: if dy=0 then fMove:=mEast;
     0: case dy of
         -1 : fMove:=mSouth;
         +1 : fMove:=mNorth;
        end;
    +1: if dy=0 then fMove:=mWest;
   end;
  end;
  SetCursor(Cursors[fMove]);
 end;

procedure TSoko.WMGetDlgCode(Var Msg:TWMGetDlgCode);
 begin
  inherited;
  Msg.Result:=Msg.Result or dlgc_WantArrows;
 end;

procedure TSoko.SetCell(X,Y:integer;State:integer);
 Var
  R:TRect;
 begin
  if (x<0)or(x>=maxx)or(y<0)or(y>=maxy) then exit;
  if fBoard[x,y]=3 then dec(fDock);
  fBoard[X,Y]:=fBoard[X,Y]+State;
  if fBoard[x,y]=3 then inc(fDock);
  R.Left:=16*X; R.Right:=R.Left+16;
  R.Top :=16*Y; R.Bottom:=R.Top+16;
  InvalidateRect(Handle,@R,False);
 end;

procedure TSoko.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
 begin
  inherited MouseDown(Button,Shift,X,Y);
  if fEndOfGame then exit;
  if fMove=mNone then exit;
  fCellX:=X div 16;
  fCellY:=Y div 16;
  Play;
 end;

procedure TSoko.KeyDown(var Key: Word; Shift: TShiftState);
 var
  dx,dy:integer;
 begin
  inherited KeyDown(Key,Shift);
  if fEndOfGame then exit;
  case key of
   vk_up    : fMove:=mNorth;
   vk_down  : fMove:=mSouth;
   vk_left  : fMove:=mWest;
   vk_right : fMove:=mEast;
   else exit;
  end;
  dx:=Delta[fMove].dx;
  dy:=Delta[fMove].dy;
  fCellX:=fPlayerX+dx;
  fCellY:=fPlayerY+dy;
  if fBoard[fCellX,fCellY]>=4 then begin
   Beep;
   exit;
  end;
  Play;
 end;

procedure TSoko.Play;
 var
  dx,dy:integer;
 begin
  dx:=Delta[fMove].dx;
  dy:=Delta[fMove].dy;
  if fBoard[fCellX,fCellY]>1 then begin
   if fBoard[fCellX+dx,fCellY+dy]<2 then begin
    SetCell(fCellX+dx,fCellY+dy,+2);
    SetCell(fCellX,fCellY,-2);
   end else begin
    Beep;
    exit;
   end;
  end;
  SetCell(fCellX,fCellY,+4);
  SetCell(fPlayerX,fPlayerY,-4);
  fPlayerX:=fCellX;
  fPlayerY:=fCellY;
  inc(fMoveCount);
  if fDock=fMines then begin
   fEndOfGame:=True;
   if Assigned(EOnWin) then EOnWin(Self) else begin
   end;
  end;
 end;

initialization
 Randomize;
 Images:=LoadBitmap(HInstance,'SOKOBAN');;
 Cursors[mNone] :=Screen.Cursors[crDefault];
 Cursors[mNorth]:=LoadCursor(HInstance,'NORTH');
 Cursors[mSouth]:=LoadCursor(HInstance,'SOUTH');
 Cursors[mEast ]:=LoadCursor(HInstance,'EAST');
 Cursors[mWest ]:=LoadCursor(HInstance,'WEST');
finalization
 DeleteObject(Images);
 DeleteObject(Cursors[mNorth]);
 DeleteObject(Cursors[mSouth]);
 DeleteObject(Cursors[mEast]);
 DeleteObject(Cursors[mWest]);
end.
