
 {$R-,I-,S-}

 Unit BigGraph;

 Interface

 Const
      VGA256 : Integer = 255;

 Function OpenGraph(gd, gm : Integer; Pth : String) : Integer;
 Function GfxCard : Byte;
 Procedure RGBPal(no, red, green, blue : Byte);
 Procedure Darken(x1, y1, x2, y2 : Word);
 Procedure ShrinkX(y, x1, x2, dy : Word);
 Procedure FullViewPort;
 Procedure Fill(xc, yc : Word; cMin, cMax : Byte);
 Procedure Pattern(XKor, YKor : Word; BinFlt : String);
 Procedure VGAScroll(y : Word);
 Procedure R3D(bA,bB,bC,sa,sb,bD,bE,bF,sd,se : Boolean);
 Procedure R3DFrame;
 Procedure R3DClear;
 Procedure GraphReadLn(xc, yc : Word; Var Ms : String; MxLng : Byte);
 Procedure MixRGB(cl, mx1, mx2 : Byte);

 Implementation

 Uses
     Crt,
     Graph;

 Var
    Dvs, Stage    : Byte;

    AutoPtr       : Pointer;

    Is256         : Boolean;

    SavePal256    : Array [0..255] Of Record
                                        R, G, B : Byte;
                                      End;

    SavePal16     : Array [0..15] Of Record
                                       R, G, B : Byte;
                                     End;

 {$F+}

 Function DetectVGA256 : Integer;
   Begin;
     DetectVGA256 := 0;
   End;

 {$F-}

 Function OpenGraph;
   Begin;
     If (gd = VGA) And (gm = VGA256) Then
       Begin;
         AutoPtr := @DetectVGA256;
         gd := InstallUserDriver('VGA256', AutoPtr);
         gd := Detect;
         InitGraph(gd, gm, Pth);
         Is256 := True;
       End
     Else
       InitGraph(gd, gm, Pth);
     OpenGraph := GraphResult;
   End;

 Function GfxCard;

   Var
      gd, gm : Integer;

   Begin;
     DetectGraph(gd, gm);
     GfxCard := gd;
   End;

 Procedure VGAScroll(y : Word);
   Begin;
     InLine($8B/$9E/y/
            $55/
            $89/$E5/
            $B8/$40/$00/
            $8E/$C0/
            $26/
            $8B/$16/$63/$00/
            $80/$C2/$06/
            $EC/
            $A8/$08/
            $74/$FB/
            $EC/
            $A8/$08/
            $75/$FB/
            $FA/
            $80/$EA/$06/
            $88/$FC/
            $B0/$0C/
            $EF/
            $88/$DC/
            $FE/$C0/
            $EF/
            $FB/
            $89/$EC/
            $5D);
   End;

 Procedure RGBPal(no, red, green, blue : Byte);
   Begin;
{     SetRGBPalette(no, red, green, blue);
     If Is256 Then
       With SavePal256 [no] Do
         Begin;
           r := red;
           g := green;
           b := blue;
         End
     Else
       With SavePal16 [no] Do
         Begin;
           r := red;
           g := green;
           b := blue;
         End;}
     Port [$3C8] := no;
     Port [$3C9] := red;
     Port [$3C9] := green;
     Port [$3C9] := blue;
   End;

 Procedure Darken(x1, y1, x2, y2 : Word);

   Var
      x, y   : Word;

   Begin;
     For x := x1 To x2 Do
       For y := y1 To y2 Do
         Case GetPixel(x, y) Of

           8..255: PutPixel(x, y, GetPixel(x, y) - 8);

         End;
   End;

 Procedure ShrinkX;

   Var
      hl2,
      s, hl  : Word;

   Begin;
     hl := Pred((x2 - x1) DIV 2) + x1;
     hl2 := Succ((x2 - x1) DIV 2) + Succ(x1);
     For s := x1 To hl Do
       PutPixel(s + 1, dy, GetPixel(s, y));
     For s := x2 DownTo hl2 Do
       PutPixel(s - 1, dy, GetPixel(s, y));
   End;

 Procedure FullViewPort;
   Begin;
     SetViewPort(0, 0, GetMaxX, GetMaxY, False);
   End;

 Procedure Fill(xc, yc : Word; cMin, cMax : Byte);

   Var
      RemC,
      Colr   : Byte;

      jx2, LoY,
      jx, jy : Word;

   Begin;
     RemC := GetPixel(xc, yc);
     jy := yc;
     Repeat
      Dec(jy)
     Until (GetPixel(xc, jy) <> 0) Or (jy = 0);
     LoY := jy;
     Colr := cMin;
     For jy := Succ(LoY) To yc Do
       Begin;
         SetColor(Colr);
         jx := xc;
         jx2 := xc;
         Repeat
          Dec(jx);
         Until (GetPixel(jx, jy) <> RemC) Or (jx = 0);
         Repeat
          Inc(jx2);
         Until (GetPixel(jx2, jy) <> RemC) Or (jx2 = GetMaxX);
         Line(Succ(jx), jy, Pred(jx2), jy);
         Inc(Colr);
         If Colr > cMax Then
           Colr := cMin;
       End;
     Repeat
      Inc(jy)
     Until (GetPixel(xc, jy) <> RemC) Or (jy >= GetMaxY);
     LoY := jy;
     If LoY = Succ(GetMaxY) Then
       Exit;
     For jy := Succ(yc) To Pred(LoY) Do
       Begin;
         SetColor(Colr);
         jx := xc;
         jx2 := xc;
         Repeat
          Dec(jx);
         Until (GetPixel(jx, jy) <> RemC) Or (jx = 0);
         Repeat
          Inc(jx2);
         Until (GetPixel(jx2, jy) <> RemC) Or (jx2 = GetMaxX);
         Line(Succ(jx), jy, Pred(jx2), jy);
         Inc(Colr);
         If Colr > cMax Then
           Colr := cMin;
       End;
   End;

 Procedure Pattern(XKor, YKor : Word; BinFlt : String);
   Begin;
     For Dvs := 1 to Length(BinFlt) Do
       Case BinFlt [Dvs] Of

         ' ': PutPixel(XKor - 1 + Dvs, YKor, 0);
         '1': PutPixel(XKor - 1 + Dvs, YKor, 1);
         '2': PutPixel(XKor - 1 + Dvs, YKor, 2);
         '3': PutPixel(XKor - 1 + Dvs, YKor, 3);
         '4': PutPixel(XKor - 1 + Dvs, YKor, 4);
         '5': PutPixel(XKor - 1 + Dvs, YKor, 5);
         '6': PutPixel(XKor - 1 + Dvs, YKor, 6);
         '7': PutPixel(XKor - 1 + Dvs, YKor, 7);
         '8': PutPixel(XKor - 1 + Dvs, YKor, 8);
         '9': PutPixel(XKor - 1 + Dvs, YKor, 9);
         'A': PutPixel(XKor - 1 + Dvs, YKor, 10);
         'B': PutPixel(XKor - 1 + Dvs, YKor, 11);
         'C': PutPixel(XKor - 1 + Dvs, YKor, 12);
         'D': PutPixel(XKor - 1 + Dvs, YKor, 13);
         'E': PutPixel(XKor - 1 + Dvs, YKor, 14);
         'F': PutPixel(XKor - 1 + Dvs, YKor, 15);

       End;
   End;

  Procedure R3D(bA,bB,bC,sa,sb,bD,bE,bF,sd,se : Boolean);

    Procedure Check(Id : Boolean);
      Begin;
          Case Stage Of

            1 : If sd then
                  Begin;
                    Line(21,31,30,40);
                    Line(30,40,30,99);
                   End;
            2 : If se then
                  Begin;
                    Line(99,31,90,40);
                    Line(90,40,90,99);
                  End;
            3 : If bE then
                  Begin;
                    Line(30,40,90,40);
                    If (Not sd) and (Not bD) then Line(30,40,30,99);
                    If (Not se) and (Not bF) then Line(90,40,90,99);
                  End;
            4 : If (sa) and (Not bE) then
                  Begin;
                    Line(30,40,40,50);
                    Line(40,50,40,99);
                    If (Not bD) and (Not sd) then Line(30,40,30,99);
                  End;
            5 : If (sb) and (Not bE) then
                  Begin;
                    Line(90,40,80,50);
                    Line(80,50,80,99);
                    If (Not se) and (Not bF) then Line(90,40,90,99);
                  End;
            6 : If bD then
                  Begin;
                    Line(21,40,30,40);
                    Line(30,40,30,99);
                  End;
            7 : If bF then
                  Begin;
                    Line(99,40,90,40);
                    Line(90,40,90,99);
                  End;
            8 : If bB then
                  Begin;
                    Line(40,50,80,50);
                    If (Not sa) and (Not bA) then Line(40,50,40,99);
                    If (Not sb) and (Not bC) then Line(80,50,80,99);
                  End;
            9 : If bA then
                  Begin;
                    Line(30,50,40,50);
                    Line(40,50,40,99);
                    If (Not bD) and (Not sd) then Line(21,50,30,50);
                  End;
           10 : If bC then
                  Begin;
                    Line(90,50,80,50);
                    Line(80,50,80,99);
                    If (Not se) and (Not bF) then Line(99,50,90,50);
                  End;

          End;
        Inc(Stage);
      End;

    Begin
      Stage := 1;
      Check(sd);
      Check(se);
      Check(bE);
      If Not bE then
        Begin;
          Check(sa);
          Check(sb);
        End
      Else Stage := Stage + 2;
      If Not sD then Check(bD)
      Else Inc(Stage);
      If Not se then Check(bF)
      Else Inc(Stage);
      If Not bE then Check(bB)
      Else Inc(Stage);
      If (Not sa) and (Not bE) then Check(bA)
      Else Inc(Stage);
      If (Not sb) and (Not bE) then Check(bC)
      Else Inc(Stage);
    End;

  Procedure R3DFrame;
    Begin;
      Rectangle(20, 20, 100, 100);
    End;

  Procedure R3DClear;
    Begin;
      SetViewPort(21, 21, 99, 99, False);
      ClearViewPort;
      SetViewPort(0, 0, 319, 199, False);
    End;

  Procedure GraphReadLn;
    Begin;
      Ms := '';
      Repeat
       Ms := Ms + Readkey;
       If (Ms [Length(Ms)] = #8) Then
         Begin;
           Delete(Ms, Length(Ms) - 1, 2);
           SetViewPort(xc + (Length(Ms) * 8), yc, xc + (Length(Ms) * 8) + 8, yc + 8, False);
           ClearViewPort;
           FullViewPort;
         End
       Else
         If (Length(Ms) > MxLng) And (Ms [Length(Ms)] <> #13) Then
           Delete(Ms, Length(Ms), 1)
       Else
         If Ms [Length(Ms)] <> #13 Then
           OutTextXY(xc + (Pred(Length(Ms)) * 8), yc, Ms [Length(Ms)]);
      Until Ms [Length(Ms)] = #13;
      Delete(Ms, Length(Ms), 1);
    End;

 Procedure MixRGB(cl, mx1, mx2 : Byte);
   Begin;
     If Is256 Then
       RGBPal(cl, (SavePal256 [mx1].r + SavePal256 [mx2].r) DIV 2,
                  (SavePal256 [mx1].g + SavePal256 [mx2].g) DIV 2,
                  (SavePal256 [mx1].b + SavePal256 [mx2].b) DIV 2);
   End;

 Begin
   Is256 := False;
 End.