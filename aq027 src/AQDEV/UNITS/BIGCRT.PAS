
{$DEFINE UCOMM_ACTIVE}

 {$R-,I-,S-}

 Unit BigCrt;

 Interface

 Type
     FontType  = Array [1..16] Of Byte;
     ScreenType = Set Of (Mono, Color);

 Const
      SType  : ScreenType = [Color];

 Var
    ScrSeg           : Word;
{$IFDEF UCOMM_ACTIVE}

    BCSP     : Pointer;

{$ENDIF}

 Procedure MirrorLetterY(Var Data : FontType);
 Procedure SetLetter(Ch : Char; Data : FontType);
 Function Pattern(Bin : String) : Byte;
 Procedure WriteXY(XC,YC : Byte; Prnt : String);
 Procedure GotoX(X : Byte);
 Procedure GotoY(Y : Byte);
 Procedure CursorOff;
 Procedure CursorSmall;
 Procedure CursorBig;
 Procedure Center(Lin, Col1, Col2 : Integer; Unique : String);
 Procedure BoxArea(XKor, YKor, XLng, YLng, Sbl, Clr, Bcg : ShortInt);
 Procedure SetCursorSize(siz : Word);
 Function  Attr(Bg, Fg : Byte) : Byte;
 Function  GetChar(xc, yc : Byte) : Char;
 Function  GetAttr(xc, yc : Byte) : Byte;
 Function  CursorSize : Word;
 Function IsMono : Boolean;
 Function CurrentPage : Byte;
 Procedure SetPage(No : Byte);

 Implementation

 Uses
{$IFDEF UCOMM_ACTIVE}
     UComm,
{$ENDIF}
     Strings,
     Dos,
     Crt;

 Var
    sz, x    : Byte;

    Jnk      : String [80];

 Procedure MirrorLetterY;
   Begin;
     For sz := 1 To 8 Do
       Begin;
         Data [17 - sz] := Data [sz] XOR Data [17 - sz];
         Data [sz] := Data [sz] XOR Data [17 - sz];
         Data [17 - sz] := Data [sz] XOR Data [17 - sz];
       End;
   End;

 Procedure SetLetter(Ch : Char; Data : FontType);

   Var
      Regs   : Registers;

   Begin;
     Regs.AX := $1100;
     Regs.ES := Seg(Data [1]);
     Regs.BP := Ofs(Data [1]);
     Regs.CX := 1;
     Regs.DX := Ord(Ch);
     Regs.BX := $1000;
     Intr($10, Regs);
   End;

 Function Pattern(Bin : String) : Byte;

   Var
      sx2    : Word;

      sx, sx3: Byte;

   Begin;
     sx2 := 1;
     sx3 := 0;
     For sx := 8 DownTo 1 Do
       Begin;
         If Bin [sx] = '1' Then
           sx3 := sx3 + sx2;
         sx2 := sx2 * 2;
       End;
     Pattern := sx3;
   End;

 Function Attr(Bg, Fg : Byte) : Byte;
   Begin;
     Attr := (Bg SHL 4) OR Fg;
   End;

 Procedure Center(Lin,Col1,Col2 : Integer;Unique : String);

   Var
      a,
      b,
      c   : Integer;

   Begin;
     a := Length(Unique);
     b := Col2 - Col1 + 1;
     c := b - a;
     GotoXY(Col1 + (c div 2),Lin);
     Write(Unique);
   End;

 Procedure GotoX(X : Byte);
   Begin;
     GotoXY(X,WhereY);
   End;

 Procedure GotoY(Y : Byte);
   Begin;
     GotoXY(WhereX,Y);
   End;

 Procedure WriteXY(XC,YC : Byte;Prnt : String);
   Begin;
     Gotoxy(XC,YC);
     Write(Prnt);
   End;

 Procedure CursorOff;

   Var
      Regs   : Registers;

   Begin
     FillChar(Regs, SizeOf(Regs), 0);
     With Regs Do
       Begin
         AH := $01;
         ch := $20;
         CL := $20;
       End;
     Intr($10, Regs);
   End;

 Procedure CursorSmall;

   Var
      Regs   : Registers;

   Begin
     FillChar(Regs, SizeOf(Regs), 0);
     Regs.AH := $01;
     If SType = [Mono] Then
       With Regs Do
         Begin
           CH := 12;
           CL := 13;
         End
     Else
       With Regs Do
         Begin
           CH := 6;
           CL := 7;
         End;
     Intr($10, Regs);
   End;

 Procedure CursorBig;

   Var
      Regs   : Registers;

   Begin
     FillChar(Regs, SizeOf(Regs), 0);
     Regs.AH := $01;
     Regs.CH := 0;
     If SType = [Mono] Then
       Regs.CL := 13
     Else
       Regs.CL := 7;
     Intr($10, Regs);
   End;

 Procedure BoxArea;

   Var
      SmlInt  : Integer;

      WMin,
      WMax    : Word;

   Begin;
     WMin := WindMin;
     WMax := WindMax;
     Window(Lo(WMin) + XKor + 1, Hi(WMin) + YKor + 1, Lo(WMin) + Pred(XKor + XLng), Hi(WMin) + Pred(YKor + YLng));
     TextAttr := Attr(Bcg, Clr);
     ClrScr;
     Window(Succ(Lo(WMin)), Succ(Hi(WMin)), Succ(Lo(WMax)), Succ(Hi(WMax)));
     If Clr <> -1 Then
       Textcolor(Clr);
     If Bcg <> -1 Then
       Textbackground(Bcg);
     Gotoxy(XKor,YKor);
     If Sbl = 1 Then
       Write('Ú')
     Else
       If Sbl = 2 Then
         Write('É');
     GotoXY(XKor + 1, YKor);
     If Sbl = 1 Then
       Begin;
         Write(Copy(LinBar, 1, XLng - 1));
         GotoXY(XKor + 1, YKor + YLng);
         Write(Copy(LinBar, 1, XLng - 1));
       End
     Else
       If Sbl = 2 Then
         Begin;
           Write(Copy(BigBar, 1, XLng - 1));
           GotoXY(XKor + 1, YKor + YLng);
           Write(Copy(BigBar, 1, XLng - 1));
         End;
     GotoXY(XKor + XLng, YKor);
     If Sbl = 1 Then
       Write('¿')
     Else
       If Sbl = 2 Then
         Write('»');
     If Sbl = 1 Then
       For SmlInt := YKor + 1 to YKor + YLng - 1 Do
         Begin;
           GotoXY(XKor, SmlInt);
           Write(#179);
           GotoXY(XKor + XLng, SmlInt);
           Write(#179);
         End
     Else
       If Sbl = 2 Then
         For SmlInt := YKor + 1 to YKor + YLng - 1 Do
           Begin;
             GotoXY(XKor, SmlInt);
             Write(#186);
             GotoXY(XKor + XLng, SmlInt);
             Write(#186);
           End;
     GotoXY(XKor, YKor + YLng);
     If Sbl = 1 Then
       Write('À')
     Else
       If Sbl = 2 Then
         Write('È');
     Gotoxy(XKor + XLng,YKor + YLng);
     If Sbl = 1 Then
       Write('Ù')
     Else
       If Sbl = 2 Then
         Write('¼');
   End;

 Function GetChar(xc, yc : Byte) : Char;
   Begin
     GetChar := Chr(Mem [ScrSeg:(Pred(xc) * 2) + (Pred(yc) * 160)]);
   End;

 Function GetAttr(xc, yc : Byte) : Byte;
   Begin;
     GetAttr := Mem [ScrSeg:(Pred(xc * 2)) + (Pred(yc) * 160)];
   End;

 Function CursorSize : Word;

   Var
      Regs   : Registers;

   Begin;
     With Regs Do
       Begin;
         Regs.AH := 3;
         Intr($10, Regs);
         CursorSize := CX;
       End;
   End;

 Procedure SetCursorSize(siz : Word);

   Var
      Regs   : Registers;

   Begin;
     With Regs Do
       Begin;
         Regs.AH := 1;
         Regs.CX := siz;
         Intr($10, Regs);
       End;
   End;

 Function IsMono : Boolean;
   Begin;
     IsMono := MemW [$0:$463] = $3B4;
   End;

 Function CurrentPage : Byte;
   Begin;
     CurrentPage := Mem [$0:$463];
   End;

 Procedure SetPage(No : Byte);
   Begin;
     Mem [$0:$463] := No;
   End;

 Begin;
   If IsMono Then
     ScrSeg := $B000
   Else
     ScrSeg := $B800;
{$IFDEF UCOMM_ACTIVE}
   BCSP := Ptr(ScrSeg, 0);
   If BroadCast('BIGCRT', 'All', 'Screen address', @BCSP, 4, False) Then ;
{$ENDIF}
 End.