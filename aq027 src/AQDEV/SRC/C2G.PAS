
 Unit C2G;

 Interface

 Uses
     Dos,
     Crt,
     C2Lib,
     C2X,
     C2Str,
     Keyboard,
     BigMous,
     Graph;

 Type
     Char11       = Array [1..11] Of Char;

 Const
      DirMatrix   : Array [-1..1, -1..1] Of Byte = ((7, 4, 1), (8, 5, 2), (9, 6, 3));

      SaveString  : Char11 = 'AQSAVE0024';
      OldString   : Char11 = 'AQSAVE0023';

      ExitGame    = 0;
      NewGame     = 1;
      LoadedGame  = 2;

 Type
     Game         = Object
{$I GAMEVARS.PAS}
                      Constructor Init;
                      Procedure Play;
                      Procedure MakeOverViewColours;
                      Procedure InitPalette;
                      Procedure SetUpWaveMachine;
                      Procedure KillWaveMachine;
                      Procedure BitInit;
                      Procedure SaveGame(Var dst : File);
                      Procedure CityStatus(ci : Word);
                      Procedure CollectField(cx, cy, cc : Word);
                      Procedure CollectResources;
                      Procedure CutStores;
                      Procedure GrowCities;
                      Procedure HandleSocieties;
                      Procedure HandleUnits;
                      Procedure CleanUnitList;
                      Procedure ControlUnit(Var z : Word);
                      Procedure AddCity(nx, ny : Word; Nm : String; o : Byte);
                      Procedure LayDownArms(ui : Word);
                      Procedure UnLoadUnits(x, y : Word);
                      Procedure ReleaseUnit(ui : Word);
                      Procedure MoveUnit(ui : Word; d : Byte; Show : Boolean);
                      Procedure AutoMove(z : Word);
                      Function UnitsLeft : Word;
                      Function LocateImpResX(i, r : Word) : Word;
                      Function LocateUnitResX(i, r : Word) : Word;
                      Function CityCanBuildUnit(ci, i : Word) : Boolean;
                      Procedure CityBuildUnit(ci, i : Word);
                      Function CityCanBuildImpr(ci, i : Word) : Boolean;
                      Procedure CityBuildImpr(ci, i : Word);
                      Procedure PrimitiveAICycle;
                      Procedure CivilizedAICycle;
                      Destructor Done;
                    End;

 Var
    TwinGame      : ^_Game;

    C2Game        : Game;

    InitStatus,
    WaveCounter,
    WaveColour    : Byte;

    Save1C        : Pointer;

 Implementation

 {$F+}

 Procedure BlinkUnit;
   Begin;
     With C2Game Do
       Begin;
         With Un [UnitPointer] Do
           Case Map.ShadowGet(X, Y) AND shCity Of

                    0: Map.Display(X, Y, (X - SX) * 16, (Y - SY) * 16);
               shCity: If C [TwinGame^.LocateCity(X, Y)]^.Improv AND
                       (_imStockage OR _imEarthenRamp OR _imCityWalls OR _imFortification) <> 0 Then
                         Map.Ti^ [133].Display((X - SX) * 16, (Y - SY) * 16)
                       Else
                         Map.Ti^ [129].Display((X - SX) * 16, (Y - SY) * 16);

           End;
         Kbd.IntDelay(200);
         TwinGame^.DisplayUnit(UnitPointer);
         Kbd.IntDelay(200);
       End;
   End;

 {$F-}

 Procedure Game.MakeOverViewColours;

   Var
      l, m, o,
      i, j        : Word;

      PalTab      : Array [0..255] Of Word;

      RangeScore  : Array [0..15] Of Word;

   Begin;
     For i := 1 To MaxTiles Do
       Begin;
         FillChar(PalTab, SizeOf(PalTab), 0);
         FillChar(RangeScore, SizeOf(RangeScore), 0);
         For j := 1 To 16 Do
           For o := 1 To 16 Do
             Begin;
               Inc(PalTab [Map.Ti^ [i].BitMap [j, o]]);
               Inc(RangeScore [Map.Ti^ [i].BitMap [j, o] DIV 16]);
             End;
         o := 0;
         l := 0;
         For j := 0 To 15 Do
           If RangeScore [j] > o Then
             Begin;
               o := RangeScore [j];
               l := j;
             End;
         m := l * 16;
         o := 0;
         l := 0;
         For j := 0 To 15 Do
           If PalTab [m + j] > o Then
             Begin;
               o := PalTab [o + j];
               l := j;
             End;
         OvrVwCol [i] := m + l;
       End;
   End;

 {$F+}

 Procedure WaveMachine;   Interrupt;
   Begin;
     Inc(WaveCounter);
     If WaveCounter < 6 Then
       Exit
     Else
       If DeadManButton > 60 Then
         Begin;
{           SetInt($1C, Save1C);
           FillChar(Screen, SizeOf(Screen), 0);
           PW^.PenColour := White;
           PW^.SoftWrite(10, 10, 'POST-MORTEM HOOK ACTIVATED: ');
           PW^.SoftWrite(10, 20, 'ATTEMPTING SHUTDOWN...');
           PW^.SoftWrite(10, 30, '(IO-RESULT: ' + NumToStr(IOResult) + ')');
           C2Game.Done;
           Halt;}
         End;
     Inc(DeadManButton);
     WaveCounter := 0;
     RGBPal(WaveColour, 0, 0, 32);
     Inc(WaveColour);
     If WaveColour = 144 Then
       WaveColour := 140;
     RGBPal(WaveColour, 0, 0, 63);
   End;

 {$F-}

 Procedure Game.SetUpWaveMachine;
   Begin;
     DeadManButton := 0;
     GetIntVec($1C, Save1C);
     SetIntVec($1C, @WaveMachine);
     WaveColour := 142;
     WaveCounter := 0;
   End;

 Procedure Game.KillWaveMachine;
   Begin;
     SetIntVec($1C, Save1C);
   End;

 Procedure Game.InitPalette;

   Procedure MakeFade(Start, MxR, MxG, MxB : Byte);

     Var
        R, G, B     : Byte;

        i           : Word;

     Begin;
       R := 0;
       G := 0;
       B := 0;
       For i := Start To Start + 15 Do
         Begin;
           Inc(R, (MxR - R) DIV Succ(Start + 15 - i));
           If R > 63 Then
             R := 63;
           Inc(G, (MxG - G) DIV Succ(Start + 15 - i));
           If G > 63 Then
             G := 63;
           Inc(B, (MxB - B) DIV Succ(Start + 15 - i));
           If B > 63 Then
             B := 63;
           RGBPal(i, R, G, B);
         End;
     End;

   Begin;
     MakeFade(16, 63, 0, 0);            { RED                      }
     MakeFade(32, 0, 63, 0);            { GREEN                    }
     MakeFade(48, 0, 0, 63);            { BLUE                     }
     MakeFade(64, 63, 0, 63);           { PURPLE                   }
     MakeFade(80, 0, 63, 63);           { CYAN                     }
     MakeFade(240, 63, 63, 0);          { YELLOW                   }
     MakeFade(112, 63, 63, 63);         { GRAY                     }
     MakeFade(144, 48, 32, 16);         { BROWN                    }
     MakeFade(160, 16, 32, 48);         { DARK BLUE                }
     MakeFade(176, 32, 48, 16);         { ARMY GREEN               }
     MakeFade(192, 16, 48, 32);         { DARK GREEN               }
     MakeFade(208, 64, 48, 48);         { PINK SKIN                }
     MakeFade(224, 64, 32, 32);         { TANNED SKIN              }
     RGBPal(128, 40, 0, 0);
     RGBPal(142, 0, 0, 63);             { CYCLED COLOR: WAVE/WATER }
     RGBPal(143, 0, 0, 32);             { CYCLED COLOR: WATER      }
     RGBPal(141, 0, 0, 32);             { CYCLED COLOR: WATER      }
     RGBPal(140, 0, 0, 32);             { CYCLED COLOR: WATER      }
     SetUpWaveMachine;
   End;

 Procedure Game.BitInit;

   Var
      i, j        : Byte;

   Begin;
     FillChar(Bits, SizeOf(Bits), 0);
     For i := 0 To 255 Do
       For j := 0 To 7 Do
         If Pow [j] AND i > 0 Then
           Inc(Bits [i]);
   End;

 Constructor Game.Init;

   Procedure LoadUnits(ufn, gfn : String);

     Var
        src            : Text;

        gfx            : File;

        i              : Word;

     Begin;
       Assign(src, ufn);
       Assign(gfx, gfn);
       Reset(src);
       ReadLn(src);
       Reset(gfx, 1);
       Seek(gfx, 521);                            { Size of useless header }
       GetMem(U, SizeOf(UnitArray));
       For i := 1 To MaxUnitTypes Do
         U^ [i].Init(src, gfx);
       Close(src);
       Close(gfx);
     End;

   Procedure LoadAdvances(afn : String);

     Var
        src            : Text;

        i              : Word;

     Begin;
       Assign(src, afn);
       Reset(src);
       ReadLn(src);
       GetMem(Adv, SizeOf(AdvanceArray));
       For i := 1 To MaxAdvances Do
         Adv^ [i].Init(src);
       Close(src);
     End;

   Procedure LoadImprovements(ifn : String);

     Var
        src       : Text;

        i, p      : Word;

     Begin;
       Assign(src, ifn);
       Reset(src);
       ReadLn(src);
       p := 1;
       For i := 1 To MaxImprovements Do
         Imp [i].Init(src, p);
       Close(src);
     End;

   Procedure LoadResPics(rpfn : String);

     Var
        src  : File;

        b1,
        buf  : Array [1..16, 1..16] Of Byte;

        i,
        j, l : Word;

     Begin;
       Assign(src, rpfn);
       Reset(src, 1);
       Seek(src, 521);                            { Size of useless header }
       For i := 0 To MaxResources DIV 4 Do
         Begin;
           BlockRead(src, b1, SizeOf(b1));
           For j := 1 To 16 Do
             For l := 1 To 16 Do
               buf [j, l] := b1 [l, j];
           If i * 4 + 1 <= MaxResources Then
             For j := 1 To 8 Do
               For l := 1 To 8 Do
                 ResPic [i * 4 + 1, j, l] := buf [j, l];
           If i * 4 + 2 <= MaxResources Then
             For j := 1 To 8 Do
               For l := 1 To 8 Do
                 ResPic [i * 4 + 2, j, l] := buf [j + 8, l];
           If i * 4 + 3 <= MaxResources Then
             For j := 1 To 8 Do
               For l := 1 To 8 Do
                 ResPic [i * 4 + 3, j, l] := buf [j, l + 8];
           If i * 4 + 4 <= MaxResources Then
             For j := 1 To 8 Do
               For l := 1 To 8 Do
                 ResPic [i * 4 + 4, j, l] := buf [j + 8, l + 8];
         End;
       For i := 1 To MaxRoads Do
         Begin;
           BlockRead(src, b1, SizeOf(b1));
           For j := 1 To 16 Do
             For l := 1 To 16 Do
               Begin;
                 Road [i, j, l] := b1 [l, j];
               End;
         End;
       R := @Road;
       Close(src);
     End;

   Procedure LoadResources(resfn : String);

     Var
        src  : Text;

        i    : Word;

     Begin;
       Assign(src, resfn);
       Reset(src);
       ReadLn(src);
       For i := 1 To MaxResources Do
         Res [i].Init(src);
       Close(src);
     End;

   Procedure LoadResX(rxfn : String);

     Var
        src  : Text;

        i    : Word;

     Begin;
       Assign(src, rxfn);
       Reset(src);
       ReadLn(src);
       For i := 1 To MaxResTrans Do
         ResX [i].Init(src);
       Close(src);
     End;

   Procedure LoadUBRR(ubfn : String);

     Var
        src  : Text;

        i    : Word;

     Begin;
       Assign(src, ubfn);
       Reset(src);
       ReadLn(src);
       For i := 1 To MaxUBResReq Do
         UnitBuildRR [i].Init(src);
       Close(src);
     End;

   Procedure LoadIBRR(ibfn : String);

     Var
        src  : Text;

        i    : Word;

     Begin;
       Assign(src, ibfn);
       Reset(src);
       ReadLn(src);
       For i := 1 To MaxIBResReq Do
         ImprBuildRR [i].Init(src);
       Close(src);
     End;

   Procedure LoadIBAR(ibafn : String);

     Var
        src  : Text;

        i    : Word;

     Begin;
       Assign(src, ibafn);
       Reset(src);
       ReadLn(src);
       For i := 1 To MaxIBAdvReq Do
         ImprBuildAR [i].Init(src);
       Close(src);
     End;

   Procedure LoadUBAR(ubafn : String);

     Var
        src  : Text;

        i    : Word;

     Begin;
       Assign(src, ubafn);
       Reset(src);
       ReadLn(src);
       For i := 1 To MaxUBAdvReq Do
         UnitBuildAR [i].Init(src);
       Close(src);
     End;

   Procedure LoadCivilizations(fn : String);

     Var
        src            : Text;

        i              : Word;

     Begin;
       Assign(src, fn);
       Reset(src);
       ReadLn(src);
       For i := 1 To MaxCivilizations Do
         CivInfo [i].Init(src);
       Close(src);
     End;

   Procedure LoadConfig(cfn : String);

     Var
        Jk        : String;

        i         : Word;

        src       : Text;

     Begin;
       Assign(src, cfn);
       Reset(src);
       Repeat
        ReadLn(src, Jk);
        Jk := UpStr(Trim(' ', Jk));
        If (Jk <> '') And (Jk [1] <> '%') Then
          If (Copy(Jk, 1, 3) = 'MAP') Then
            Begin;
              Delete(Jk, 1, 3);
              Jk := Trim(' ', Jk);
              If (Copy(Jk, 1, 4) = 'FULL') Then
                Begin;
                  Delete(Jk, 1, 4);
                  LeftX := 1;
                  RightX := 320;
                  LowerY := 1;
                  UpperY := 200;
                End
              Else
                If (Copy(Jk, 1, 6) = 'RANDOM') Then
                  Begin;
                    Delete(Jk, 1, 6);
                    RightX := GetInt(Jk);
                    UpperY := GetInt(Jk);
                    LeftX := Succ(Random(320 - RightX));
                    LowerY := Succ(Random(200 - UpperY));
                    RightX := RightX + LeftX;
                    UpperY := UpperY + LowerY;
                  End
              Else
                If (Copy(Jk, 1, 4) = 'AREA') Then
                  Begin;
                    Delete(Jk, 1, 4);
                    LeftX := GetInt(Jk);
                    LowerY := GetInt(Jk);
                    RightX := GetInt(Jk);
                    UpperY := GetInt(Jk);
                  End
              Else
                If (Copy(Jk, 1, 6) = 'SELECT') Then
                  Begin;
                    Delete(Jk, 1, 6);
                    LeftX := 0;
                    LowerY := 0;
                    RightX := 0;
                    UpperY := 0;
                  End;
            End
          Else
            If (Copy(Jk, 1, 12) = 'CIVSELECTION') Then
              Begin;
                Delete(Jk, 1, 12);
                Jk := Trim(' ', Jk);
                If (Copy(Jk, 1, 6) = 'RANDOM') Then
                  Begin;
                    Delete(Jk, 1, 6);
                    CivSelection := 1;
                    HumanCivs := GetInt(Jk);
                  End
                Else
                  If (Copy(Jk, 1, 10) = 'CONFIGURED') Then
                    Begin;
                      Delete(Jk, 1, 10);
                      CivSelection := 0;
                      HumanCivs := 0;
                      For i := 1 To MaxCivilizations Do
                        CivInfo [i].Control := 0;         { Not Available }
                      Repeat
                       i := GetInt(Jk);
                       If (i <= MaxCivilizations) And (i > 0) Then
                         Begin;
                           If Copy(Jk, 1, 4) = ':LCP' Then
                             Begin;
                               Delete(Jk, 1, 1);
                               CivInfo [i].Control := 2
                             End
                           Else
                             If Copy(Jk, 1, 4) = ':LCS' Then
                               Begin;
                                 Delete(Jk, 1, 1);
                                 CivInfo [i].Control := 3
                               End
                           Else
                             If Copy(Jk, 1, 3) = ':LH' Then
                               CivInfo [i].Control := 1
                           Else
                             If Copy(Jk, 1, 3) = ':NA' Then
                               CivInfo [i].Control := 0;
                           Delete(Jk, 1, 3);
                         End;
                      Until (Jk = '');
                    End
                Else
                  If (Copy(Jk, 1, 6) = 'MANUAL') Then
                    CivSelection := 2;
              End
          Else
            If (Copy(Jk, 1, 8) = 'SHOWCIVS') Then
              Begin;
                Delete(Jk, 1, 8);
                Jk := Trim(' ', Jk);
                If Copy(Jk, 1, 2) = 'NO' Then
                  ShowCivs := False
                Else
                  If Copy(Jk, 1, 3) = 'YES' Then
                    ShowCivs := True;
              End
          Else
            If (Copy(Jk, 1, 9) = 'ENDOFTURN') Then
              Begin;
                Delete(Jk, 1, 9);
                Jk := Trim(' ', Jk);
                If Copy(Jk, 1, 2) = 'NO' Then
                  EndOfTurn := False
                Else
                  If Copy(Jk, 1, 3) = 'YES' Then
                    EndOfTurn := True;
              End
          Else
            If (Copy(Jk, 1, 4) = 'VEIL') Then
              Begin;
                Delete(Jk, 1, 4);
                Jk := Trim(' ', Jk);
                If Copy(Jk, 1, 2) = 'NO' Then
                  Hide := False
                Else
                  If Copy(Jk, 1, 3) = 'YES' Then
                    Hide := True;
              End
          Else
            If (Copy(Jk, 1, 10) = 'SHOWSTATUS') Then
              Begin;
                Delete(Jk, 1, 10);
                Jk := Trim(' ', Jk);
                If Copy(Jk, 1, 2) = 'NO' Then
                  ShowStatus := 0
                Else
                  If Copy(Jk, 1, 7) = 'PARTIAL' Then
                    ShowStatus := 1
                Else
                  If Copy(Jk, 1, 4) = 'FULL' Then
                    ShowStatus := 2;
              End
          Else
            If (Copy(Jk, 1, 6) = 'INFORM') Then
              Begin;
                Delete(Jk, 1, 6);
                Jk := Trim(' ', Jk);
                If Copy(Jk, 1, 4) = 'NONE' Then
                  WantNotice := 0
                Else
                  If Copy(Jk, 1, 7) = 'PARTIAL' Then
                    WantNotice := 1
                Else
                  If Copy(Jk, 1, 4) = 'FULL' Then
                    WantNotice := 2;
              End
          Else
            If (Copy(Jk, 1, 10) = 'AIANNOUNCE') Then
              Begin;
                Delete(Jk, 1, 10);
                Jk := Trim(' ', Jk);
                If Copy(Jk, 1, 3) = 'YES' Then
                  CompMov := True
                Else
                  If Copy(Jk, 1, 2) = 'NO' Then
                    CompMov := False;
              End
       Until (EOF(src));
       Close(src);
     End;

   Procedure SelectMap(mfn : String);

     Var
        src       : File;

        buf       : ^XYMapArray;

        i, j      : Word;

     Begin;
       FillChar(Screen, SizeOf(Screen), Blue);
       W.PenColour := Yellow;
       W.BkGColour := DarkGray;
       W.WkShadowWrite(30, 70, UpStr('           Selecting an area of the map'));
       W.PenColour := White;
       W.WkShadowWrite(30, 90, UpStr('In the following screen use the arrow keys to move'));
       W.WkShadowWrite(30, 97, UpStr(' the selection pane. Resizing may be performed by'));
       W.WkShadowWrite(30, 104, UpStr('        combining SHIFT with an arrow key.'));
       W.PenColour := LightCyan;
       W.WkShadowWrite(30, 128, UpStr('             Press ENTER to continue'));
       ReadLn;
       Assign(src, mfn);
       Reset(src, 1);
       Seek(src, 673);                          { Skip the useless header }
       GetMem(buf, SizeOf(XYMapArray));
       BlockRead(src, buf^, SizeOf(XYMapArray));
       Close(src);
       For i := 1 To 320 Do
         For j := 1 To 200 Do
           Case buf^ [i, j] Of

             17..20,
             40..60: Screen [j, i] := Blue;
           Else
             Screen [j, i] := Green;

         End;
       FreeMem(buf, SizeOf(XYMapArray));
       If ShowCivs Then
         For i := 1 To MaxCivilizations Do
           With CivInfo [i] Do
             If ((CivSelection = 0) And (Control <> 0)) Or (CivSelection <> 0) Then
               Screen [StartY, StartX] := Red;
       LeftX := 107;
       RightX := 134;
       LowerY := 35;
       UpperY := 90;
       SetWriteMode(XORPut);
       SetColor(Yellow);
       Repeat
        Repeat
         Rectangle(LeftX, LowerY, LeftX + RightX, LowerY + UpperY);
         Kbd.IntDelay(100);
         Rectangle(LeftX, LowerY, LeftX + RightX, LowerY + UpperY);
         Kbd.IntDelay(100);
        Until Kbd.Pressed;
        Kbd.GetKey;
        Case Kbd.Press Of

          UpKey: If LowerY > 0 Then
                   Dec(LowerY);
          DnKey: If LowerY + UpperY < 199 Then
                   Inc(LowerY);
          LfKey: If LeftX > 0 Then
                   Dec(LeftX);
          RtKey: If LeftX + RightX < 319 Then
                   Inc(LeftX);
          Else
            Case Kbd.PressCh [1] Of

              '8': If (UpperY > 0) Then
                     Dec(UpperY);
              '2': If (LowerY + UpperY) < 199 Then
                     Inc(UpperY);
              '4': If (RightX > 0) Then
                     Dec(RightX);
              '6': If (LeftX + RightX) < 319 Then
                     Inc(RightX);

            End;

        End;
       Until (Kbd.Press = Enter);
       RightX := Succ(LeftX + RightX);
       UpperY := Succ(LowerY + UpperY);
       Inc(LowerY);
       Inc(LeftX);
       SetWriteMode(CopyPut);
     End;

   Procedure CivLine(i : Word);

     Var
        Jk   : String;

        y    : Word;

     Begin;
       y := Pred(i) * 6 + 3;
       With CivInfo [i] Do
         Begin;
           If Colour <> 0 Then
             Begin;
               W.PenColour := White;
               W.BkGColour := Black;
             End
           Else
             Begin;
               W.PenColour := LightGray;
               W.BkGColour := Black;
             End;
           Case i Of

              1..10: Jk := 'sF';
             11..20: Jk := 'cF';
             21..30: Jk := 'aF';

           End;
           If i MOD 10 <> 0 Then
             Jk := ' ' + Jk + NumToStr(i MOD 10) + ':'
           Else
             Jk := Jk + '10:';
           W.WkShadowWrite(20, y + 2, Jk);
           If Colour <> 0 Then
             SetFillStyle(SolidFill, Colour)
           Else
             SetFillStyle(SolidFill, Blue);
           Bar(11, y, 14, y + 5);
           W.WkShadowWrite(50, y + 2, UpStr(Name));
           SetFillStyle(SolidFill, Blue);
           Bar(160, y, 285, y + 5);
           W.WkShadowWrite(162, y + 2, Status [Control]);
         End;
     End;

   Procedure SelectCivs;

     Var
        i, j      : Word;

     Begin;
       SetFillStyle(SolidFill, Blue);
       Bar(0, 0, 319, 199);
       W.PenColour := Yellow;
       W.BkGColour := Black;
       W.WkShadowWrite(20, 190, 'SELECT PARTICIPATING CIVILIZATIONS');
       Kbd.ClearAreas;
       TwinGame^.Button(250, 187, 'TAB: DONE', Tab);
       For i := 1 To MaxCivilizations Do
         Begin;
           CivLine(i);
           Kbd.HotArea(10, Pred(i) * 6 + 2, 305, Pred(i) * 6 + 7, Pred(i) + sF1);
         End;
       Repeat
        Repeat
         Kbd.GetKey;
         Case Kbd.Press Of

            sF1
             ..
           aF10: Begin;
                   i := Succ(Kbd.Press - sF1);
                   If CivInfo [i].Colour <> 0 Then
                    Begin;
                      Inc(CivInfo [i].Control);
                      If CivInfo [i].Control > MaxControls Then
                        CivInfo [i].Control := 0;
                      CivLine(i);
                    End;
                 End;

         End;
        Until (Kbd.Press = TAB);
        j := 0;
        For i := 1 To MaxCivilizations Do
          If CivInfo [i].Control = 1 Then
            Inc(j);
        If j = 0 Then
          SplitLiner('AT LEAST ONE CIVILIZATION MUST BE HUMAN-CONTROLLED.');
       Until (j > 0);
     End;

   Procedure SelectMapAndCivilizations;

     Var
        i, j      : Word;

     Begin;
       If RightX = 0 Then
         SelectMap(MapFileName);
       For i := 1 To MaxCivilizations Do
         With CivInfo [i] Do
           If (StartX <= LeftX + 1) Or (StartX >= RightX - 1) Or (StartY <= LowerY + 1) Or (StartY >= UpperY - 1) Then
             Begin;
               Control := 0;                                { Not Active }
               Colour := 0;
             End
           Else
             Begin;
               If (CivSelection <> 0) Then
                 Case Primitive Of

                    True: Control := 2;                   { Local Computer }
                   False: Control := 3;                   { Ditto }

                 End;
               Dec(StartX, Pred(LeftX));
               Dec(StartY, Pred(LowerY));
             End;
       Case CivSelection Of

         1: Begin;
              j := 0;
              For i := 1 To MaxCivilizations Do
                If (CivInfo [i].Control = 2) Or (CivInfo [i].Control = 3) Then
                  Inc(j);
              If j < HumanCivs Then
                Begin;
                  For i := 1 To MaxCivilizations Do
                    If (CivInfo [i].Control = 2) Or (CivInfo [i].Control = 3) Then
                      CivInfo [i].Control := 1            { Local Human }
                End
              Else
                For i := 1 To HumanCivs Do
                  Repeat
                   j := Succ(Random(MaxCivilizations));
                   If (CivInfo [j].Control = 2) Or (CivInfo [j].Control = 3) Then
                     Begin;
                       CivInfo [j].Control := 1;          { Local Human }
                       j := 0;
                     End;
                  Until (j = 0);
            End;
         2: SelectCivs;

       End;
     End;

   Procedure DrawIntroBox;
     Begin;
       SetFillStyle(SolidFill, LightGray);
       Bar(100, 58, 220, 155);
       Frame3D(105, 63, 215, 150);
       FrameReverse3D(99, 57, 221, 156);
       W.PenColour := White;
       W.BkGColour := Black;
       W.ShadowWrite(123, 70, 'ANTIQUITY v0.27');
       W.ShadowWrite(114, 80, 'COMPILED 26-OCT-95');
       W.ShadowWrite(120, 100, 'THIS IS FREEWARE');
       W.ShadowWrite(117, 106, 'BY KRISTOFFER AND');
       W.ShadowWrite(117, 112, 'SUNE NILAUS OLSEN');
       W.ShadowWrite(128, 125, 'ALPHA VERSION');
       W.ShadowWrite(111, 131, 'USE AT YOUR OWN RISK');
       W.ShadowWrite(128, 143, 'PLEASE WAIT...');
     End;

   Var
      i           : LongInt;

      Y, M, D     : Word;

      src         : File;

      Li          : StringLList;

      Ch          : Char11;

   Begin;
     TwinGame := @Self;
     Randomize;
     Kbd.Init;
     If (OpenGraph(VGA, VGA256, '') <> 0) Then
       Begin;
         WriteLn('Could not enter graphics mode. Perhaps "VGA256.BGI" is missing?');
         Halt;
       End;
     InitPalette;
     PFWidth := 20;
     PFHeight := 11;
     W.Init(FontFileName);
     PW := @W;
     BitInit;
     DrawIntroBox;
     Kbd.IntDelay(2000);
     Kbd.Clear;
     Li.Init;
     Li.Add('NEW GAME');
     Li.Add('LOAD OLD GAME');
     ClearDevice;
     i := Select('ANTIQUITY v0.27', 15, Li);
     If Li.Get(1) <> Message Then
       i := i;
     Li.Done;
     Case i Of

       1: InitStatus := NewGame;
       2: InitStatus := LoadedGame;
       Else
         InitStatus := ExitGame;

     End;
     ClearDevice;
     DrawIntroBox;
     If (InitStatus <> ExitGame) Then
       Begin;
         LoadCivilizations(CivInfoFileName);
         LoadConfig(ConfigFileName);
         LoadUnits(UnitFileName, UnitGfxFileName);
         LoadAdvances(AdvanceFileName);
         LoadResPics(ResPicFileName);
         LoadResources(ResourceFileName);
         LoadResX(ResTransFileName);
         LoadUBRR(UBResReqFileName);
         LoadIBRR(IBResReqFileName);
         LoadUBAR(UBAdvReqFileName);
         LoadIBAR(IBAdvReqFileName);
         LoadImprovements(ImprovementFileName);
         FillChar(C, SizeOf(C), 0);
         FillChar(Un, SizeOf(Un), 0);
       End;
     If InitStatus = NewGame Then
       Begin;
         New(CN, Init);
         CityNames := CN;
         SelectMapAndCivilizations;
         ClearDevice;
         DrawIntroBox;
         CivPointer := 1;
         Year := -4000;
         C2Lib.Y := Year;
         BZ := Adv^ [resBronzeWorking].ResYear;
         IR := Adv^ [resIronWorking].ResYear;
         Map.Init(LeftX, LowerY, RightX, UpperY, MapFileName);
         FillChar(PFMatrix, SizeOf(PFMatrix), 0);
         New(K, Init(Map.Width, Map.Height));
         New(UM, Init);
         New(N, Init);
         New(Msg, Init);
         For i := 1 To MaxCivilizations Do
           With CivInfo [i] Do
             Begin;
               Ready(K, UM, N);
               If Control <> 0 Then
                 TwinGame^.AddUnit(StartX, StartY, 1, i);
             End;
       End
     Else
       If InitStatus = LoadedGame Then
         Begin;
           Assign(src, Request('ENTER NAME OF FILE TO LOAD', 8, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') + '.AQ');
           Reset(src, 1);
           BlockRead(src, Ch, SizeOf(Ch));
           If (IOResult <> 0) Or ((Ch <> SaveString) And (Ch <> OldString)) Then
             Begin;
               ClearDevice;
               W.BkGColour := Black;
               W.PenColour := White;
               W.HardWrite(10, 10, 'ERROR WHILE TRYING TO READ FROM SAVEFILE: GAME ABORTED.');
               GotoXY(1, 10);
               InitStatus := ExitGame;
             End
           Else
             Begin;
               DirectVideo := False;
               ClearDevice;
               DrawIntroBox;
               For i := 1 To MaxCivilizations Do
                 CivInfo [i].Load(src);
               BlockRead(src, UnitPointer, SizeOf(UnitPointer));
               BlockRead(src, PFWidth, SizeOf(PFWidth) * 2);
               BlockRead(src, SX, SizeOf(SX) * 2);
               BlockRead(src, PFMatrix, SizeOf(PFMatrix));
               New(K, Load(src));
               If Ch <> OldString Then
                 New(UM, Load(src))
               Else
                 New(UM, OldLoad(src));
               New(N, Load(src));
               New(CN, Load(src));
               CityNames := CN;
               BlockRead(src, MaxUnitsUsed, SizeOf(MaxUnitsUsed));
               For i := 1 To MaxUnitsUsed Do
                 Un [i].Load(src);
               BlockRead(src, MaxCitiesUsed, SizeOf(MaxCitiesUsed));
               For i := 1 To MaxCitiesUsed Do
                 New(C [i], Load(src));
               Map.Load(src);
               BlockRead(src, Year, SizeOf(Year));
               BlockRead(src, CivPointer, SizeOf(CivPointer));
               If (Ch <> OldString) Then
                 New(Msg, Load(src))
               Else
                 New(Msg, Init);
               Close(src);
               Y := Year;
               BZ := Adv^ [resBronzeWorking].ResYear;
               IR := Adv^ [resIronWorking].ResYear;
               Map.LoadTerrain(TerrainFileName);
               SX := $FFFF;
               SY := $FFFF;
             End;
         End;
     If InitStatus <> ExitGame Then
       MakeOverViewColours;
   End;

 Procedure Game.MoveUnit;

   Var
      BkUp        : Array [0..15, 0..15] Of Byte;

      nx, ny, l,
      ox, oy, i, j: Integer;

   Begin;
     If ui = 0 Then
       Exit;
     With Un [ui] Do
       Begin;
         ox := X;
         oy := Y;
       End;
     With Un [ui] Do
       Begin;
         Case d Of

           7: With TwinGame^ Do
                i := PlaceUnit(ui, x - 1, y - 1, Owner, EnemyUnits(ox, oy, Owner), Show);
           8: With TwinGame^ Do
                i := PlaceUnit(ui, x, y - 1, Owner, EnemyUnits(ox, oy, Owner), Show);
           9: With TwinGame^ Do
                i := PlaceUnit(ui, x + 1, y - 1, Owner, EnemyUnits(ox, oy, Owner), Show);
           6: With TwinGame^ Do
                i := PlaceUnit(ui, x + 1, y, Owner, EnemyUnits(ox, oy, Owner), Show);
           3: With TwinGame^ Do
                i := PlaceUnit(ui, x + 1, y + 1, Owner, EnemyUnits(ox, oy, Owner), Show);
           2: With TwinGame^ Do
                i := PlaceUnit(ui, x, y + 1, Owner, EnemyUnits(ox, oy, Owner), Show);
           1: With TwinGame^ Do
                i := PlaceUnit(ui, x - 1, y + 1, Owner, EnemyUnits(ox, oy, Owner), Show);
           4: With TwinGame^ Do
                i := PlaceUnit(ui, x - 1, y, Owner, EnemyUnits(ox, oy, Owner), Show);

         End;
         Case i Of

           1: Dec(MovesLeft, 10);
           2: Exit;

         End;
         If (ox = x) And (y = oy) Then
           Exit;
         If Map.ShadowGet(x, y) AND shRoaded <> 0 Then
           Dec(MovesLeft, Map.TerGet(x, y)^.MoveCost DIV 2)
         Else
           Dec(MovesLeft, Map.TerGet(x, y)^.MoveCost);
       End;
     TwinGame^.RemoveUnit(ox, oy);
     If Show Then
       With Un [ui] Do
         Begin;
           If Map.ShadowGet(ox, oy) AND shCity = 0 Then
             Map.Display(ox, oy, (ox - SX) * 16, (oy - SY) * 16)
           Else
             If C [TwinGame^.LocateCity(ox, oy)]^.Improv AND
                (_imStockage OR _imEarthenRamp OR _imCityWalls OR _imFortification) <> 0 Then
               Map.Ti^ [133].Display((ox - SX) * 16, (oy - SY) * 16)
           Else
             Map.Ti^ [129].Display((ox - SX) * 16, (oy - SY) * 16);
           nx := (x - SX) SHL 4;
           ny := (y - SY) SHL 4;
           ox := (ox - SX) SHL 4;
           oy := (oy - SY) SHL 4;
           i := (nx - ox) DIV UnitMoveFrames;
           j := (ny - oy) DIV UnitMoveFrames;
           Repeat
            ox := ox + i;
            oy := oy + j;
            For l := oy To oy + 15 Do
              Move(Screen [l, ox], BkUp [l - oy], 16);
            U^ [UType].Display(ox, oy, CivInfo [Owner].Colour, NIL);
            Delay(UnitMoveDelay);
            For l := oy To oy + 15 Do
              Move(BkUp [l - oy], Screen [l, ox], 16);
           Until (ox DIV UnitMoveFrames = nx DIV UnitMoveFrames) And (oy DIV UnitMoveFrames = ny DIV UnitMoveFrames);
           Kbd.Clear;
         End;
   End;

 Procedure Game.ReleaseUnit;
   Begin;
     With Un [ui] Do
       Begin;
         Case Map.TerGet(x, y)^.TCtype Of

           2, 3: If U^ [Un [ui].UType].ActionCaps AND CarryUnits = 0 Then
                   Begin;
                     Un [ui].Status := stTransported;
                     Un [ui].MovesLeft := 10;
                   End
                 Else
                   Un [ui].Status := stReady;
           Else
             Un [ui].Status := stReady;

         End;
       End;
   End;

 Procedure Game.AddCity;

   Var
      i, j   : Word;

      s      : Byte;

   Begin;
     If (Map.TerGet(nx, ny)^.ITR <> 0) Then
       Map.Put(nx, ny, Map.TerGet(nx, ny)^.ITR);
     Map.ShadowSet(nx, ny, shCity OR shIrrigated OR shRoaded);
     s := 0;
     For i := nx - 1 To nx + 1 Do
       For j := ny - 1 To ny + 1 Do
         s := s OR Pow [Pred(Map.TerGet(i, j)^.TCType)];
     i := TwinGame^.LocateCity(0, 0);
     If i > MaxCitiesUsed Then
       MaxCitiesUsed := i;
     New(C [i], Init(nx, ny, Nm, o, s));
     With CivInfo [o] Do
       Begin;
         Inc(BuiltCities);
         If BuiltCities < 3 Then
           C [i]^.Stores [rTools] := 30;
         If BuiltCities = 1 Then
           C [i]^.Population := 49;
       End;
   End;

 Procedure Game.LayDownArms;

   Var
      i      : Word;

      Eth    : Array [1..MaxCivilizations] Of Word;

   Begin;
     With Un [ui] Do
       Begin;
         If Map.ShadowGet(x, y) AND shCity = 0 Then
           Exit;
         Case UType Of

            1,
            3,
            4,
           42
           ..
           58: Exit;

         End;
         With C [TwinGame^.LocateCity(x, y)]^ Do
           If ((Improv AND _imMinorAqueduct = 0) And (Population > 90))
           Or ((Improv AND _imMajorAqueduct = 0) And (Population > 290)) Then
             Exit
           Else
             Begin;
               For i := 1 To MaxCivilizations Do
                 Eth [i] := Round(EthnicDist [i] * (Population / 100));
               Inc(Eth [Owner], 10);
               Inc(Population, 10);
               For i := 1 To MaxCivilizations Do
                 EthnicDist [i] := Round(Eth [i] / (Population / 100));
             End;
       End;
     TwinGame^.KillUnit(ui, False);
   End;

 Function Game.LocateImpResX;

   Var
      j      : Word;

   Begin;
     j := 0;
     Repeat
      Inc(j);
     Until (j > MaxIBResReq) Or (ImprBuildRR [j].Pr = i);
     If j > MaxIBResReq Then
       Begin;
         LocateImpResX := 0;
         Exit;
       End;
     Repeat
      With ImprBuildRR [j] Do
        If (Re = r) Then
          Begin;
            LocateImpResX := Amount;
            Exit;
          End;
      Inc(j);
     Until (j > MaxIBResReq) Or (ImprBuildRR [j].Pr <> i);
     LocateImpResX := 0;
   End;

 Function Game.LocateUnitResX;

   Var
      j      : Word;

   Begin;
     j := 0;
     Repeat
      Inc(j);
     Until (j > MaxUBResReq) Or (UnitBuildRR [j].Pr = i);
     If j > MaxUBResReq Then
       Begin;
         LocateUnitResX := 0;
         Exit;
       End;
     Repeat
      With UnitBuildRR [j] Do
        If (Re = r) Then
          Begin;
            LocateUnitResX := Amount;
            Exit;
          End;
      Inc(j);
     Until (j > MaxUBResReq) Or (UnitBuildRR [j].Pr <> i);
     LocateUnitResX := 0;
   End;

 Function Game.CityCanBuildUnit;

   Var
      j      : Word;

   Begin;
     CityCanBuildUnit := False;
     If CivInfo [C [ci]^.Owner].Wealth < U^ [i].Cost Then
       Exit;
     With C [ci]^ Do
       Begin;
         Case i Of

           47
           ..
           53,
           57,
           58: If Surroundings AND (tOcean OR tCoast) = 0 Then
                 Exit;

         End;
         j := 0;
         Repeat
          Inc(j);
         Until (j > MaxUBAdvReq) Or (UnitBuildAR [j].Pr = i);
         If j <= MaxUBAdvReq Then
           Repeat
            With UnitBuildAR [j] Do
              If (CivInfo [Owner].Knowledge [Ad] < ScoreReq) Then
                Exit;
            Inc(j);
           Until (j > MaxUBAdvReq) Or (UnitBuildAR [j].Pr <> i);
       End;
     With C [ci]^ Do
       Begin;
         j := 0;
         Repeat
          Inc(j);
         Until (j > MaxUBResReq) Or (UnitBuildRR [j].Pr = i);
         If j > MaxUBResReq Then
           Begin;
             CityCanBuildUnit := True;
             Exit;
           End;
         Repeat
          With UnitBuildRR [j] Do
            If (Stores [Re] < Amount) Then
              Exit;
          Inc(j);
         Until (j > MaxUBResReq) Or (UnitBuildRR [j].Pr <> i);
       End;
     CityCanBuildUnit := True;
   End;

 Procedure Game.CityBuildUnit;

   Var
      j      : Word;

   Begin;
     With C [ci]^ Do
       Begin;
         j := 0;
         Repeat
          Inc(j);
         Until (j > MaxUBResReq) Or (UnitBuildRR [j].Pr = i);
         If j > MaxUBResReq Then
           Exit;
         Repeat
          With UnitBuildRR [j] Do
            Dec(Stores [Re], Amount);
          Inc(j);
         Until (j > MaxUBResReq) Or (UnitBuildRR [j].Pr <> i);
         Dec(CivInfo [Owner].Wealth, U^ [i].Cost);
       End;
   End;

 Function Game.CityCanBuildImpr;

   Var
      j      : Word;

      l      : LongInt;

   Begin;
     CityCanBuildImpr := False;
     If CivInfo [C [ci]^.Owner].Wealth < Imp [i].Cost Then
       Exit;
     With C [ci]^ Do
       Begin;
         l := Pow [Pred(i)];
         If (l = _imDocks) Or (l = _imShipYard) Then
           Begin;
             If Surroundings AND (tCoast OR tRiver OR tOcean) = 0 Then
               Exit;
           End
         Else
           If (l = _imGreatShipYard) Then
             Begin;
               If Surroundings AND (tCoast OR tOcean) = 0 Then
                 Exit;
             End;
         j := 0;
         Repeat
          Inc(j);
         Until (j > MaxIBAdvReq) Or (ImprBuildAR [j].Pr = i);
         If j <= MaxIBAdvReq Then
           Repeat
            With ImprBuildAR [j] Do
              If (CivInfo [Owner].Knowledge [Ad] < ScoreReq) Then
                Exit;
            Inc(j);
           Until (j > MaxIBAdvReq) Or (ImprBuildAR [j].Pr <> i);
       End;
     With C [ci]^ Do
       Begin;
         j := 0;
         Repeat
          Inc(j);
         Until (j > MaxIBResReq) Or (ImprBuildRR [j].Pr = i);
         If j > MaxIBResReq Then
           Begin;
             CityCanBuildImpr := True;
             Exit;
           End;
         Repeat
          With ImprBuildRR [j] Do
            If (Stores [Re] < Amount) Then
              Exit;
          Inc(j);
         Until (j > MaxIBResReq) Or (ImprBuildRR [j].Pr <> i);
       End;
     CityCanBuildImpr := True;
   End;

 Procedure Game.CityBuildImpr;

   Var
      j      : Word;

   Begin;
     With C [ci]^ Do
       Begin;
         j := 0;
         Repeat
          Inc(j);
         Until (j > MaxIBResReq) Or (ImprBuildRR [j].Pr = i);
         If j > MaxIBResReq Then
           Exit;
         Repeat
          With ImprBuildRR [j] Do
            Dec(Stores [Re], Amount);
          Inc(j);
         Until (j > MaxIBResReq) Or (ImprBuildRR [j].Pr <> i);
         Dec(CivInfo [Owner].Wealth, Imp [i].Cost);
       End;
   End;

 Procedure Game.CityStatus;

   Var
      ImpArray  : Array [1..MaxImprovements] Of Boolean;

      BackDrop  : Array [1..40, 1..96] Of Byte;

      src       : File;

   Procedure DisplayField(x, y : Word; o : Byte; ci : Word);

     Var
        i    : Word;

     Begin;
       If (o = rFood) And (Map.ShadowGet(x, y) AND shIrrigated <> 0) Then
         i := Round(Map.TerGet(x, y)^.ResourceYield [o] * 1.5 + 0.49)
       Else
         i := Map.TerGet(x, y)^.ResourceYield [o];
{       If (o = rFood) Then
         i := Round(i * (1 + (CivInfo [CivPointer].CasteBonus [caPeasants] / 100)));}
       W.PenColour := Yellow;
       W.BkGColour := Black;
       W.ShadowWrite(25 + 16 * (x - C [ci]^.x), 46 + 16 * (y - C [ci]^.y), NumToStr(i));
     End;

   Procedure DisplayResourceYield(ci : Word; o : Byte);

     Var
        AP,
        i, j,
        l, m : Word;

     Begin;
       AP := sF1 - 1;
       With C [ci]^ Do
         Begin;
           Frame3D(2, 23, 51, 72);
           For j := y - 1 To y + 1 Do
             For i := x - 1 To x + 1 Do
               Begin;
                 Map.TiGet(i, j)^.Display(3 + (i - Pred(x)) * 16, 24 + (j - Pred(y)) * 16);
                 If (i - x + 2 * (j - y) <> 0) Then
                   Begin;
                     Inc(AP);
                     Kbd.HotArea(3 + (i - Pred(x)) * 16, 24 + (j - Pred(y)) * 16,
                                 3 + (i - Pred(x)) * 16 + 15, 24 + (j - Pred(y)) * 16 + 15,
                                 AP);
                   End;
                 If Map.ShadowGet(i, j) AND shIrrigated <> 0 Then
                   Begin;
                     For l := 3 + (i - Pred(x)) * 16 To 3 + (i - Pred(x)) * 16 + 15 Do
                       For m := 24 + (j - Pred(y)) * 16 To 24 + (j - Pred(y)) * 16 + 15 Do
                         Case Screen [m, l] Of

                           32
                           ..
                           42: Inc(Screen [m, l], 5);

                         End;
                   End;
               End;
           SetLineStyle(DottedLn, 0, NormWidth);
           SetColor(White);
           Line(18, 23, 18, 71);
           Line(34, 23, 34, 71);
           Line(2, 40, 50, 40);
           Line(2, 56, 50, 56);
           SetLineStyle(SolidLn, 0, NormWidth);
           For i := 0 To 7 Do
             Case ResExp AND Pow [i] Of

                 1: DisplayField(x - 1, y - 1, o, ci);
                 2: DisplayField(x, y - 1, o, ci);
                 4: DisplayField(x + 1, y - 1, o, ci);
                 8: DisplayField(x - 1, y, o, ci);
                16: DisplayField(x + 1, y, o, ci);
                32: DisplayField(x - 1, y + 1, o, ci);
                64: DisplayField(x, y + 1, o, ci);
               128: DisplayField(x + 1, y + 1, o, ci);

             End;
           DisplayField(x, y, o, ci);
         End;
     End;

   Procedure DisplayStores(ci : Word; o : Byte);

     Var
        i    : Word;

     Procedure PlaceStoreBox(x, y, ci : Word; i : Byte; Bk : Boolean);

       Var
          l, j    : Word;

       Begin;
         SetColor(DarkGray);
         x := x + (Pred(i) MOD 13) * 17;
         y := y + (i DIV 14) * 23;
         Rectangle(x, y, x + 17, y + 19);
         Line(x, y + 11, x + 17, y + 11);
         If i <= MaxRawResources Then
           Kbd.HotArea(x, y, x + 17, y + 11, 200 + i);
         SetFillStyle(SolidFill, Black);
         Bar(x + 1, y + 12, x + 16, y + 18);
         W.PenColour := White;
         W.BkGColour := Black;
         Case C [ci]^.Stores [i] Of

             1
            ..
             9: W.HardWrite(x + 13, y + 14, NumToStr(C [ci]^.Stores [i]));
            10
            ..
            99: W.HardWrite(x + 8, y + 14, NumToStr(C [ci]^.Stores [i]));
           100
            ..
           200: W.HardWrite(x + 3, y + 14, NumToStr(C [ci]^.Stores [i]));

         End;
         For l := 1 To 8 Do
           For j := 1 To 8 Do
             Case ResPic [i, l, j] Of


                 0
                ..
                 9,
                11
                ..
               255: Screen [j + y + 1, l + x + 4] := ResPic [i, l, j];
                10: If Bk Then
                      Screen [j + y + 1, l + x + 4] := ResPic [i, l, j]
                    Else
                      Screen [j + y + 1, l + x + 4] := LightGray;

             End;
       End;

     Begin;
       For i := 1 To 26 Do
         PlaceStoreBox(54, 23, ci, i, i = o);
       SetColor(White);
       Line(54, 23, 54, 23 + 10);
       Line(54, 23, 54 + 13 * 17, 23);

       Line(54, 46, 54, 46 + 10);
       Line(54, 46, 54 + 13 * 17, 46);
     End;

   Procedure CityDraw(x, y : Word; p : Byte);
     Begin;
       x := 3 + Pred(x) * 16;
       y := 116 + Pred(y) * 16;
       Case p Of

         0: Map.Ti^ [1].Display(x, y);
         Else
           PCt^ [p].Display(x, y);

       End;
     End;

   Procedure DisplayCity(ci : Word);

     Var
        i, j, l, m: Word;

        CDMatrix  : Array [1..6, 1..5] Of Byte;

     Begin;
       FillChar(CDMatrix, SizeOf(CDMatrix), 0);
       FillChar(ImpArray, SizeOf(ImpArray), 0);
       For i := 1 To MaxImprovements Do
         If C [ci]^.Improv AND Pow [Pred(i)] <> 0 Then
           Begin;
             ImpArray [i] := True;
             ImpArray [Imp [i].ParentImp] := False;
           End;
       If (ImpArray [impStockage]) Then
         For i := 1 To 6 Do
           CDMatrix [i, 5] := Imp [impStockage].PicOffSet
       Else
         If (ImpArray [impEarthenRamp]) Then
           For i := 1 To 6 Do
             CDMatrix [i, 5] := Imp [impEarthenRamp].PicOffSet
       Else
         If (ImpArray [impCityWalls]) Then
           For i := 1 To 6 Do
             CDMatrix [i, 5] := Imp [impCityWalls].PicOffSet
       Else
         If (ImpArray [impFortification]) Then
           For i := 1 To 6 Do
             CDMatrix [i, 5] := Imp [impFortification].PicOffSet;
       If (ImpArray [impDocks]) Then
         Begin;
           CDMatrix [5, 1] := Imp [impDocks].PicOffSet;
           CDMatrix [6, 1] := Imp [impDocks].PicOffSet + 1;
         End;
       If (ImpArray [impGreatShipYard]) Then
         Begin;
           CDMatrix [5, 2] := Imp [impGreatShipYard].PicOffSet;
           CDMatrix [6, 2] := Imp [impGreatShipYard].PicOffSet + 1;
         End
       Else
         If (ImpArray [impShipYard]) Then
           CDMatrix [6, 2] := Imp [impShipYard].PicOffSet;
       For i := impStockage To impFortification Do
         ImpArray [i] := False;
       ImpArray [impDocks] := False;
       ImpArray [impGreatShipYard] := False;
       ImpArray [impShipYard] := False;
       j := Succ(C [ci]^.X MOD 6);
       l := Succ(C [ci]^.Y MOD 5);
       For i := 1 To MaxImprovements - 2 Do
         If (ImpArray [i]) And (Imp [i].PicLength = 2) Then
           Begin;
             If (CDMatrix [j, l] <> 0) Or (6 - Pred(j) < Imp [i].PicLength)
                Or ((Imp [i].PicLength > 1) And (CDMatrix [j + 1, l] <> 0)) Then
               Repeat
                Inc(j);
                If j > 6 Then
                  Begin;
                    Inc(l);
                    j := 1;
                    If l > 5 Then
                      Begin;
                        j := 1;
                        l := 1;
                      End;
                  End;
               Until (CDMatrix [j, l] = 0) And ((Imp [i].PicLength = 1) Or
                     ((6 - Pred(j) >= Imp [i].PicLength) And (CDMatrix [j + 1, l] = 0)));
             For m := j To j + Pred(Imp [i].PicLength) Do
               CDMatrix [m, l] := Imp [i].PicOffSet + m - j;
             ImpArray [i] := False;
           End;
       For i := 1 To MaxImprovements - 2 Do
         If (ImpArray [i]) Then
           Begin;
             If (CDMatrix [j, l] <> 0) Or (6 - Pred(j) < Imp [i].PicLength)
                Or ((Imp [i].PicLength > 1) And (CDMatrix [j + 1, l] <> 0)) Then
               Repeat
                Inc(j);
                If j > 6 Then
                  Begin;
                    Inc(l);
                    j := 1;
                    If l > 5 Then
                      Begin;
                        j := 1;
                        l := 1;
                      End;
                  End;
               Until (CDMatrix [j, l] = 0) And ((Imp [i].PicLength = 1) Or
                     ((6 - Pred(j) >= Imp [i].PicLength) And (CDMatrix [j + 1, l] = 0)));
             For m := j To j + Pred(Imp [i].PicLength) Do
               CDMatrix [m, l] := Imp [i].PicOffSet + m - j;
             ImpArray [i] := False;
           End;
       Frame3D(2, 75, 99, 196);
       SetFillStyle(SolidFill, Black);
       Bar(3, 76, 98, 195);
       For i := 1 To 40 Do
         Move(BackDrop [i], Screen [i + 75, 3], 96);
       For i := 1 To 6 Do
         For j := 1 To 5 Do
           Begin;
             CityDraw(i, j, 0);
             CityDraw(i, j, CDMatrix [i, j]);
           End;
       For i := 1 To MaxImprovements Do
         If C [ci]^.Improv AND Pow [Pred(i)] <> 0 Then
           Begin;
             ImpArray [i] := True;
             ImpArray [Imp [i].ParentImp] := False;
           End;
       If (ImpArray [impMinorAqueduct]) Then
         For i := 1 To 3 Do
           PCt^ [Imp [impMinorAqueduct].PicOffSet].Display(3 + Pred(i) * 16, 100)
       Else
         If (ImpArray [impMajorAqueduct]) Then
           For i := 1 To 3 Do
             PCt^ [Imp [impMajorAqueduct].PicOffSet].Display(3 + Pred(i) * 16, 100);
     End;

   Procedure DisplayUnits(ci : Word);

     Var
        i, j      : Word;

     Begin;
       Frame3D(102, 70, 262, 110);
       i := 0;
       j := 0;
       Repeat
        With C [ci]^ Do
          i := TwinGame^.LocateUnit(x, y, i);
        If (i <= MaxUnitsUsed) Then
          With Un [i] Do
            Begin;
              U^ [UType].Display(104 + j * 20, 72, CivInfo [CivPointer].Colour, NIL);
              If j < 8 Then
                Kbd.HotArea(104 + j * 20, 72, 104 + j * 20 + 15, 72 + 15, cF1 + j);
              W.PenColour := CivInfo [Owner].Colour XOR 54;
              W.BkGColour := Black;
              W.ShadowPlot(104 + j * 20 + 6, 72 + 10, StatusChar [Status]);
              Inc(j);
            End;
       Until (i > MaxUnitsUsed) Or (j = 8);
       Repeat
        With C [ci]^ Do
          i := TwinGame^.LocateUnit(x, y, i);
        If (i <= MaxUnitsUsed) Then
          With Un [i] Do
            Begin;
              U^ [UType].Display(104 + (j - 8) * 20, 92, CivInfo [CivPointer].Colour, NIL);
              W.PenColour := CivInfo [Owner].Colour XOR 54;
              W.BkGColour := Black;
              W.ShadowPlot(104 + (j - 8) * 20 + 6, 92 + 10, StatusChar [Status]);
              Inc(j);
            End;
       Until (i > MaxUnitsUsed) Or (j = 8);
     End;

   Procedure DisplayImpr;

     Var
        i, j      : Word;

     Begin;
       Frame3D(2, 75, 99, 196);
       SetFillStyle(SolidFill, LightGray);
       Bar(3, 76, 98, 195);
       i := 77;
       W.PenColour := White;
       W.BkGColour := Black;
       For j := 1 To MaxImprovements Do
         If ImpArray [j] Then
           Begin;
             W.WkShadowWrite(5, i + 1, UpStr(Copy(Imp [j].Name, 1, 19)));
             Inc(i, 6);
           End;
     End;

   Procedure DisplayProduction(ci : Word);

     Var
        Jk   : String;

     Begin;
       SetFillStyle(SolidFill, LightGray);
       Bar(102, 115, 262, 135);
       Frame3D(102, 115, 262, 135);
       Kbd.HotArea(102, 115, 262, 135, F8);
       W.PenColour := Yellow;
       W.BkGColour := Black;
       With C [ci]^ Do
         Case Hi(Activity) AND 127 Of

           0: Begin;
                W.WkShadowWrite(105, 118, 'IDLE');
              End;
           1: Begin;
                W.WkShadowWrite(105, 118, 'IMPROVING CITY');
                W.PenColour := LightCyan;
                W.WkShadowWrite(105, 124, '(' + UpStr(Imp [Lo(Activity)].Name) + ')');
                Case Imp [Lo(Activity)].PicLength Of

                  1: Begin;
                       Map.Ti^ [1].Display(240, 117);
                       PCt^ [Imp [Lo(Activity)].PicOffSet].Display(240, 117);
                     End;
                  2: Begin;
                       Map.Ti^ [1].Display(225, 117);
                       PCt^ [Imp [Lo(Activity)].PicOffSet].Display(225, 117);
                       Map.Ti^ [1].Display(240, 117);
                       PCt^ [Succ(Imp [Lo(Activity)].PicOffSet)].Display(240, 117);
                     End;

                End;
              End;
           2: Begin;
                W.WkShadowWrite(105, 118, 'CONSTRUCTING VESSEL');
                W.PenColour := LightCyan;
                W.WkShadowWrite(105, 124, '(' + UpStr(Copy(U^ [Lo(Activity)].Name, 1, 23)) + ')');
                U^ [Lo(Activity)].Display(240, 117, CivInfo [CivPointer].Colour, NIL);
              End;
           3: Begin;
                W.WkShadowWrite(105, 118, 'MANUFACTURING RESOURCES');
                W.PenColour := LightCyan;
                W.WkShadowWrite(105, 124, '(' + UpStr(Copy(Res [ResX [Lo(Activity)].InR].Name, 1, 13) + ' > '
                                              + Copy(Res [ResX [Lo(Activity)].OutR].Name, 1, 13)) + ')');
              End;
           4: Begin;
                W.WkShadowWrite(105, 118, 'TRAINING MEN');
                W.PenColour := LightCyan;
                W.WkShadowWrite(105, 124, '(' + UpStr(Copy(U^ [Lo(Activity)].Name, 1, 23)) + ')');
                U^ [Lo(Activity)].Display(240, 117, CivInfo [CivPointer].Colour, NIL);
              End;
           5: Begin;
                W.WkShadowWrite(105, 118, 'PRODUCTION SUSPENDED');
              End;

         End;
       With C [ci]^ Do
         Case Hi(Activity) AND 127 Of

           1,
           2,
           3,
           4: Begin;
                W.PenColour := Magenta;
                Jk := 'PRGR: ' + NumToStr(Progress) + ' OF ' + NumToStr(Goal);
                W.WkShadowWrite(105, 130, Jk);
                W.PenColour := White;
                If (Hi(Activity) AND 127 < 3) Then
                  W.WkShadowWrite(105 + Length(Jk) * 5, 130,
                                  ' (' + NumToStr(Succ((Goal - Progress) DIV (Production))) + ' R)');
              End;

         End;
     End;

   Procedure DisplayTriggers(ci : Word);

     Var
        Li   : StringLList;

        l    : LongInt;

        i    : Word;

     Begin;
       Li.Init;
       l := CivInfo [C [ci]^.Owner].BlockId;
       i := 0;
       Repeat
        i := UM^.Locate(l, ci OR uCityTrigger, i);
        If i <= UM^.MaxUsed Then
          With UM^.Block [i] Do
            Li.Add(Pad(Res [Hi(Data [1])].Name, ' ', 21)
                   + PadL(NumToStr(Lo(Data [1])), ' ', 3)
                   + ' P:' + PadL(NumToStr(Data [2]), ' ', 6)
                   + ' T:' + PadL(NumToStr(Lo(Data [3])), ' ', 3));
       Until (i >= UM^.MaxUsed);
       Select('TRADE TRIGGERS', 39, Li);
       Li.Done;
     End;

   Procedure AddImp(i : Word; Var Ti, Li : StringLList; ci : Word);

     Var
        Jk   : String;

     Begin;
       With C [ci]^ Do
         If (Improv AND Pow [Pred(i)] = 0) Then
           Begin;
             If ((Imp [i].ParentImp = 0) Or (Improv AND Pow [Pred(Imp [i].ParentImp)] <> 0))
             And (CityCanBuildImpr(ci, i)) And (CivInfo [Owner].Wealth >= Imp [i].Cost) Then
               Begin;
                 Jk := NumToStr(LocateImpResX(i, rTimber)) + 'T/' +
                       NumToStr(LocateImpResX(i, rStone)) + 'S/' +
                       NumToStr(Imp [i].Cost) + 'C/' +
                       NumToStr(Succ(Imp [i].ProdReq DIV Production)) + 'R';
                 Li.Add(Pad(Imp [i].Name, ' ', 20) + PadL(Jk, ' ', 20));
                 Ti.Add(NumToStr(i));
               End;
           End;
     End;

   Procedure AddVes(i : Word; Var Ti, Li : StringLList; ci : Word);

     Var
        Jk   : String;

     Begin;
       With C [ci]^ Do
         If (Population > 1) And (Improv AND Pow [Pred(U^ [i].ImpReq)] <> 0) And (CityCanBuildUnit(ci, i))
         And (CivInfo [Owner].Wealth >= U^ [i].Cost) Then
           Begin;
             Jk := NumToStr(LocateImpResX(i, rTimber)) + 'T/' +
                   NumToStr(U^ [i].Cost) + 'C/' +
                   NumToStr(Succ(Imp [i].ProdReq DIV Production)) + 'R';
             Li.Add(Pad(U^ [i].Name, ' ', 20) + PadL(Jk, ' ', 15));
             Ti.Add(NumToStr(i));
           End;
     End;

   Procedure AddResX(i : Word; Var Ti, Li : StringLList; ci : Word);

     Var
        j    : Word;

     Begin;
       If ((ResX [i].OutR = rTrndHorses) And (C [ci]^.Improv AND _imStables <> 0))
       Or ((ResX [i].InR = rTrndHorses) And (C [ci]^.Improv AND _imSchoolOfRiding <> 0)) Then
         Begin;
           Li.Add(Res [ResX [i].InR].Name + ' > ' + Res [ResX [i].OutR].Name);
           Ti.Add(NumToStr(i));
           Exit;
         End;
       With C [ci]^ Do
         If (Improv AND Pow [Pred(ResX [i].ImpReq)] <> 0) Then
           Begin;
             j := 0;
             Repeat
              Inc(j);
             Until (UnitBuildRR [j].Re = ResX [i].OutR) Or (j > MaxUBResReq);
             If (j <= MaxUBResReq) Then
               If TwinGame^.CivCanBuildUnit(UnitBuildRR [j].Pr, CivPointer) = False Then
                 Exit;
             Li.Add(Res [ResX [i].InR].Name + ' > ' + Res [ResX [i].OutR].Name);
             Ti.Add(NumToStr(i));
           End;
     End;

   Procedure AddReg(i : Word; Var Ti, Li : StringLList; ci : Word);
     Begin;
       With C [ci]^ Do
         If (CityCanBuildUnit(ci, i)) And (CivInfo [Owner].Wealth >= U^ [i].Cost)
            And ((Population > 10) Or ((U^ [i].ActionCaps AND (Diplomacy OR CarryGoods) <> 0) And (Population > 1))) Then
           Begin;
             Li.Add(U^ [i].Name);
             Ti.Add(NumToStr(i));
           End;
     End;

   Const
        None           = 0;
        Some           = 1;
        Full           = 2;

   Var
      NeedsUpdate,
      ResourceShown    : Byte;

      Li, Ti           : StringLList;

      a,
      i, j,
      l, m             : Word;

      GfxOn            : Boolean;

      Jk               : String [60];

   Begin;
     If IOResult <> 0 Then ;
     GfxOn := True;
     GetMem(PCt, 64*256);
     Assign(src, CityGfxFileName);
     Reset(src, 1);
     Seek(src, 521);
     For i := 1 To 64 Do
       PCt^ [i].Init(src);
     Close(src);
     If C [ci]^.Population DIV 50 < 8 Then
       Assign(src, CityBackFileName + NumToStr(C [ci]^.Population DIV 50) + '.GFX')
     Else
       Assign(src, CityBackFileName + '8.GFX');
     Reset(src, 1);
     BlockRead(src, BackDrop, SizeOf(BackDrop));
     Close(src);
     ResourceShown := 1;
     NeedsUpdate := Full;
     Repeat
      Kbd.ClearAreas;
      With C [ci]^ Do
        Begin;
          SetFillStyle(SolidFill, LightGray);
          If NeedsUpdate = 2 Then
            Bar(0, 0, 319, 199);

          Bar(3, 2, 79, 8);
          Frame3D(2, 1, 80, 9);
          W.PenColour := CivInfo [Owner].Colour;
          W.BkGColour := Black;
          If ci = CivInfo [C [ci]^.Owner].ScienceCity Then
            W.WkShadowWrite(5, 4, CN^.ExpandStr(NameIdx, NameLen) + '*')
          Else
            W.WkShadowWrite(5, 4, CN^.ExpandStr(NameIdx, NameLen));

          Frame3D(83, 1, 201, 9);
          W.WkShadowWrite(86, 4, 'POPULATION:');
          W.PenColour := Yellow;
          If Population < 1000 Then
            W.WkShadowWrite(146, 4, NumToStr(Population) + ',000')
          Else
            W.WkShadowWrite(146, 4, NumToStr(Population DIV 1000) + ','
                                    + PadL(NumToStr(Population MOD 1000), '0', 3)
                                    + ',000');

          Bar(3, 13, 73, 19);
          Frame3D(2, 12, 74, 20);
          W.PenColour := CivInfo [Owner].Colour;
          W.WkShadowWrite(5, 15, 'PROD: ');
          W.PenColour := Yellow;
          If Activity AND 32768 <> 0 Then
            W.WkShadowWrite(35, 15, 'REPEAT')
          Else
            W.WkShadowWrite(35, 15, 'SINGLE');
          Kbd.HotArea(2, 12, 74, 20, F3);

          Bar(78, 13, 274, 19);
          Frame3D(77, 12, 275, 20);
          With UM^ Do
            Begin;
              i := Locate(CivInfo [Owner].BlockId, ci OR uCityProdEvent, 0);
              If i <= MaxUsed Then
                Case Block [i].Data [1] Of

                         cpeSentry: Jk := 'Sentry unit';
                        cpeFortify: Jk := 'Fortify unit';
                           cpeGoto: With C [Block [i].Data [2]]^ Do
                                      Jk := 'Goto ' + CN^.ExpandStr(NameIdx, NameLen);
                  cpeGotoAndSentry: With C [Block [i].Data [2]]^ Do
                                      Jk := 'Goto ' + CN^.ExpandStr(NameIdx, NameLen) + ' and sentry';

                End
              Else
                Jk := 'No commands';
              W.WkShadowWrite(80, 15, UpStr(Jk));
            End;
          Kbd.HotArea(77, 12, 275, 20, F9);

          Frame3D(279, 1, 317, 184);
          For i := 1 To 30 Do
            Begin;
              If CivInfo [i].Control <> 0 Then
                Begin;
                  W.PenColour := CivInfo [i].Colour;
                  Case EthnicDist [i] Of

                      1
                     ..
                     99: Begin;
                           W.WkShadowWrite(282, 5 + 6 * Pred(i), UpStr(Copy(CivInfo [i].Name, 1, 3)));
                           W.PenColour := Yellow;
                           W.WkShadowWrite(302, 5 + 6 * Pred(i), NumToStr(EthnicDist [i]) + '%');
                         End;
                    100: Begin;
                           W.WkShadowWrite(282, 5 + 6 * Pred(i), UpStr(Copy(CivInfo [i].Name, 1, 3)));
                           W.PenColour := Yellow;
                           W.WkShadowWrite(302, 5 + 6 * Pred(i), UpStr('All'));
                         End;

                  End;
                End;
            End;

          DisplayResourceYield(ci, ResourceShown);
          DisplayStores(ci, ResourceShown);
          If NeedsUpdate < 3 Then
            Begin;
              If GfxOn Then
                DisplayCity(ci)
              Else
                DisplayImpr;
              Kbd.HotArea(2, 75, 99, 196, F4);
              DisplayUnits(ci);
              DisplayProduction(ci);
            End;
        End;
      TwinGame^.BWButton(102, 190, 'F9: COMMANDS', F9);
      TwinGame^.BWButton(176, 180, 'F8: CHANGE', F8);
      TwinGame^.BWButton(102, 180, 'F6: RESOURCE', F6);
      TwinGame^.BWButton(176, 170, 'F5: CENTRE', F5);
      TwinGame^.BWButton(102, 170, 'F4: GFX/TXT ', F4);
      TwinGame^.BWButton(176, 160, 'F3: REPEAT', F3);
      TwinGame^.BWButton(102, 160, 'F2: TRIGGERS', F2);
      TwinGame^.BWButton(260, 190, 'ESC: EXIT', ESC);
      NeedsUpdate := None;
      Repeat
       Kbd.GetKey;
       Case Kbd.Press Of

           F2: DisplayTriggers(ci);
           F3: Begin;
                 With C [ci]^ Do
                   Activity := NOT (Activity AND 32768) AND (Activity OR 32768);
                 NeedsUpdate := Some;
               End;
           F4: Begin;
                 GfxOn := NOT GfxOn;
                 NeedsUpdate := Some;
               End;
           F5: Begin;
                 If CivInfo [C [ci]^.Owner].ScienceCity = 0 Then
                   CivInfo [C [ci]^.Owner].ScienceCity := ci
                 Else
                   If CivInfo [C [ci]^.Owner].ScienceCity = ci Then
                     CivInfo [C [ci]^.Owner].ScienceCity := -3;
                 NeedsUpdate := Some;
               End;
           F6: Begin;
                 Li.Init;
                 For i := 1 To MaxRawResources Do
                   Li.Add(Res [i].Name);
                 i := Select('RESOURCE TO MAP', 16, Li);
                 If i <> 0 Then
                   ResourceShown := i;
                 Li.Done;
                 NeedsUpdate := Some;
               End;
           F8: Begin;
                 NeedsUpdate := None;
                 With Li Do
                   Begin;
                     Li.Init;
                     Li.Add('Suspend Production');
                     Li.Add('List Requirements');
                     Li.Add('Improve City');
                     Li.Add('Construct Vessel');
                     Li.Add('Manufacture Resources');
                     Li.Add('Train Men');
                   End;
                 i := Select('ACTIVITY', 21, Li);
                 Li.Done;
                 Case i Of

                   2: Begin;
                        TwinGame^.Requirements;
                        NeedsUpdate := Full;
                        Kbd.Press := 0;
                      End;
                   3: Begin;
                        Li.Init;
                        Ti.Init;
                        For i := 1 To MaxImprovements Do
                          AddImp(i, Ti, Li, ci);
                        i := Select('IMPROVEMENT', 40, Li);
                        If i <> 0 Then
                          With C [ci]^ Do
                            Begin;
                              Activity := $0100 OR StrToInt(Ti.Get(i)) OR (Activity AND 32768);
                              Progress := 0;
                              Goal := Imp [StrToInt(Ti.Get(i))].ProdReq;
                              CityBuildImpr(ci, StrToInt(Ti.Get(i)));
                            End;
                        Li.Done;
                        Ti.Done;
                      End;
                   4: Begin;
                        Li.Init;
                        Ti.Init;
                        For i := 42 To 53 Do
                          AddVes(i, Ti, Li, ci);
                        For i := 56 To 58 Do
                          AddVes(i, Ti, Li, ci);
                        i := Select('VESSEL', 35, Li);
                        If i <> 0 Then
                          With C [ci]^ Do
                            Begin;
                              Activity := $0200 OR StrToInt(Ti.Get(i)) OR (Activity AND 32768);
                              CityBuildUnit(ci, Lo(Activity));
                              Progress := 0;
                              With U^ [Lo(Activity)] Do
                                Goal := MaxMove + Attack + Defense + Capacity * 10;
                            End;
                        Ti.Done;
                        Li.Done;
                      End;
                   5: Begin;
                        Li.Init;
                        Ti.Init;
                        For i := 1 To MaxResTrans Do
                          AddResX(i, Ti, Li, ci);
                        i := Select('TRANSFORMATION', 31, Li);
                        If i <> 0 Then
                          With C [ci]^ Do
                            Begin;
                              Activity := $0300 OR StrToInt(Ti.Get(i)) OR (Activity AND 32768);
                              Progress := 0;
                              Goal := StrToInt(Request(UpStr('How many?'), 2, '0123456789'));
                            End;
                        Ti.Done;
                        Li.Done;
                      End;
                   6: Begin;
                        Li.Init;
                        Ti.Init;
                        Li.Add('Walking');
                        Li.Add('Mounted');
                        Li.Add('Warhorse-mounted');
                        i := Select('TYPE OF UNIT', 16, Li);
                        Li.Done;
                        If i <> 0 Then
                          Begin;
                            Case i Of

                              1: Begin;
                                   AddReg(1, Ti, Li, ci);
                                   AddReg(3, Ti, Li, ci);
                                   For i := 5 To 8 Do
                                     AddReg(i, Ti, Li, ci);
                                   For i := 17 To 20 Do
                                     AddReg(i, Ti, Li, ci);
                                   For i := 29 To 32 Do
                                     AddReg(i, Ti, Li, ci);
                                   AddReg(54, Ti, Li, ci);
                                 End;
                              2: Begin;
                                   AddReg(4, Ti, Li, ci);
                                   For i := 9 To 12 Do
                                     AddReg(i, Ti, Li, ci);
                                   For i := 21 To 24 Do
                                     AddReg(i, Ti, Li, ci);
                                   For i := 33 To 36 Do
                                     AddReg(i, Ti, Li, ci);
                                   AddReg(55, Ti, Li, ci);
                                 End;
                              3: Begin;
                                   For i := 13 To 16 Do
                                     AddReg(i, Ti, Li, ci);
                                   For i := 25 To 28 Do
                                     AddReg(i, Ti, Li, ci);
                                   For i := 37 To 40 Do
                                     AddReg(i, Ti, Li, ci);
                                 End;

                            End;
                            i := Select('TRAIN..', 20, Li);
                            If i <> 0 Then
                              Begin;
                                i := StrToInt(Ti.Get(i));
                                With C [ci]^ Do
                                  If (Improv AND impBarracks = 0) Or (U^ [i].ActionCaps <> 0) Then
                                    Begin;
                                      Activity := $0400 OR i OR (Activity AND 32768);
                                      CityBuildUnit(ci, Lo(Activity));
                                      Progress := 0;
                                      Goal := 3;
                                    End
                                  Else
                                    Begin;
                                      CityBuildUnit(ci, i);
                                      Dec(Population, 1);
                                      TwinGame^.AddUnit(x, y, i, Owner);
                                    End;
                              End;
                            Ti.Done;
                            Li.Done;
                          End;
                      End;
                   1: With C [ci]^ Do
                        Begin;
                          Activity := $0500;
                          Progress := 0;
                          Goal := 0;
                        End;

                 End;
                 If NeedsUpdate = None Then
                   NeedsUpdate := Some;
               End;
           F9: Begin;
                 Li.Init;
                 Li.Add('None');
                 Li.Add('Sentry');
                 Li.Add('Fortify');
                 Li.Add('Goto..');
                 Li.Add('Goto.. and sentry');
                 i := Select('INITIAL COMMANDS', 18, Li);
                 Li.Done;
                 If i <> 0 Then
                   Begin;
                     j := UM^.Locate(CivInfo [C [ci]^.Owner].BlockId, ci OR uCityProdEvent, 0);
                     If j <= UM^.MaxUsed Then
                       With UM^ Do
                         FillChar(Block [j], SizeOf(Block [j]), 0);
                     Case i Of

                       2: UM^.AddUnitInfo(CivInfo [C [ci]^.Owner].BlockId,
                                          ci, uCityProdEvent,
                                          cpeGoto, 0, 0);
                       3: UM^.AddUnitInfo(CivInfo [C [ci]^.Owner].BlockId,
                                          ci, uCityProdEvent,
                                          cpeFortify, 0, 0);
                       4: Begin;
                            Li.Init;
                            Ti.Init;
                            j := 0;
                            For i := 1 To MaxCitiesUsed Do
                              If (C [i]^.Owner = C [ci]^.Owner) And (i <> ci) And (j < 30) Then
                                Begin;
                                  With C [i]^ Do
                                    Li.Add(Copy(CN^.ExpandStr(NameIdx, NameLen), 1, 20));
                                  Ti.Add(NumToStr(i));
                                  Inc(j);
                                End;
                            i := Select('GOTO..', 20, Li);
                            If i <> 0 Then
                              i := StrToInt(Ti.Get(i));
                            Li.Done;
                            Ti.Done;
                            If i <> 0 Then
                              UM^.AddUnitInfo(CivInfo [C [ci]^.Owner].BlockId,
                                              ci, uCityProdEvent,
                                              cpeGoto, i, 0);
                          End;
                       5: Begin;
                            Li.Init;
                            Ti.Init;
                            j := 0;
                            For i := 1 To MaxCitiesUsed Do
                              If (C [i]^.Owner = C [ci]^.Owner) And (i <> ci) And (j < 30) Then
                                Begin;
                                  With C [i]^ Do
                                    Li.Add(Copy(CN^.ExpandStr(NameIdx, NameLen), 1, 20));
                                  Ti.Add(NumToStr(i));
                                  Inc(j);
                                End;
                            i := Select('GOTO..', 20, Li);
                            If i <> 0 Then
                              i := StrToInt(Ti.Get(i));
                            Li.Done;
                            Ti.Done;
                            If i <> 0 Then
                              UM^.AddUnitInfo(CivInfo [C [ci]^.Owner].BlockId,
                                              ci, uCityProdEvent,
                                              cpeGotoAndSentry, i, 0);
                          End;

                     End;
                   End;
                 NeedsUpdate := Some;
               End;
          201
           ..
          226: Begin;
                 ResourceShown := Kbd.Press - 200;
                 NeedsUpdate := Some;
               End;
          sF1
           ..
          sF8: Begin;
                 i := Pow [Kbd.Press - sF1];
                 If (i AND C [ci]^.ResExp = 0) Then
                   Begin;
                     If Bits [C [ci]^.ResExp] < C [ci]^.ResExpFields Then
                       Begin;
                         C [ci]^.ResExp := C [ci]^.ResExp OR i;
{                         DisplayResourceYield(ci, ResourceShown);}
                         NeedsUpdate := Some;
                       End;
                   End
                 Else
                   Begin;
                     C [ci]^.ResExp := C [ci]^.ResExp AND NOT i;
{                     DisplayResourceYield(ci, ResourceShown);}
                     NeedsUpdate := Some;
                   End;
               End;
          cF1
           ..
          cF8: Begin;
                 i := Succ(Kbd.Press - cF1);
                 l := 0;
                 For j := 1 To i Do
                   With C [ci]^ Do
                     l := TwinGame^.LocateUnit(x, y, l);
                 If (l <= MaxUnitsUsed) Then
                   With Un [l] Do
                     Begin;
                       Case Status Of

                         stTransported,
                         stSentried,
                         stFortified,
                         stSentrying,
                         stFortifying: Begin;
                                         Status := stReady;
                                         DisplayUnits(ci);
                                       End;
                         Else
                           If (U^ [UType].ActionCaps AND CarryGoods <> 0) Then
                             Begin;
                               Li.Init;
                               Li.Add('Transport..');
                               i := UM^.Locate(CivInfo [Owner].BlockId, l OR uGoods, 0);
                               With UM^.Block [i] Do
                                 For j := 1 To U^ [UType].Capacity Do
                                   Case Hi(Data [j]) Of

                                     0: Begin;
                                          Li.Add('Load slot ' + NumToStr(j));
                                        End;
                                     Else
                                       Begin;
                                         Li.Add('Unload ' + NumToStr(Lo(Data [j])) + ' ' + Res [Hi(Data [j])].Name);
                                       End;

                               End;
                               j := Select('CARAVAN', 31, Li);
                               Li.Done;
                               If j > 1 Then
                                 Begin;
                                   Dec(j);
                                   With UM^.Block [i] Do
                                     Case Hi(Data [j]) Of

                                       0: Begin;
                                            Li.Init;
                                            Ti.Init;
                                            For m := 1 To MaxResources Do
                                              If C [ci]^.Stores [m] > 0 Then
                                                Begin;
                                                  Li.Add(Pad(Res [m].Name, ' ', 21) +
                                                         PadL(NumToStr(C [ci]^.Stores [m]), ' ', 3));
                                                  Ti.Add(NumToStr(m));
                                                End;
                                            m := Select('LOAD..', 24, Li);
                                            Li.Done;
                                            If m > 0 Then
                                              Begin;
                                                m := StrToInt(Ti.Get(m));
                                                l := StrToInt(Request('AMOUNT', 3, '0123456789'));
                                                If (l > 0) And (l <= C [ci]^.Stores [m]) Then
                                                  Begin;
                                                    Data [j] := (m SHL 8) OR Lo(l);
                                                    Dec(C [ci]^.Stores [m], l);
                                                  End;
                                              End;
                                            Ti.Done;
                                            NeedsUpdate := Some;
                                          End;
                                       Else
                                         Begin;
                                           Inc(C [ci]^.Stores [Hi(Data [j])], Lo(Data [j]));
                                           Data [j] := 0;
                                           NeedsUpdate := Some;
                                         End;

                                     End
                                 End
                               Else
                                 If (j = 1) Then
                                   Begin;
                                     Li.Init;
                                     Li.Add('RELOCATE (100%)');
                                     Li.Add('SHARE (50%)');
                                     m := Select('TRANSPORT', 15, Li);
                                     Li.Done;
                                     Li.Init;
                                     Li.Add('None');
                                     For i := 1 To MaxResources Do
                                       Li.Add(Res [i].Name);
                                     j := Pred(Select('RESOURCE FROM HERE', 18, Li));
                                     Li.Done;
                                     Li.Init;
                                     Ti.Init;
                                     a := 0;
                                     For i := 1 To MaxCitiesUsed Do
                                       If (C [i]^.Owner = C [ci]^.Owner) And (i <> ci) And (a < 30) Then
                                         With C [i]^ Do
                                           Begin;
                                             Li.Add(Copy(CN^.ExpandStr(NameIdx, NameLen), 1, 20));
                                             Ti.Add(NumToStr(i));
                                             Inc(a);
                                           End;
                                     If a > 0 Then
                                       a := Select('OTHER CITY', 20, Li);
                                     If a <> 0 Then
                                       a := StrToInt(Ti.Get(a));
                                     Ti.Done;
                                     Li.Done;
                                     Li.Init;
                                     Li.Add('None');
                                     For i := 1 To MaxResources Do
                                       Li.Add(Res [i].Name);
                                     i := Pred(Select('RESOURCE FROM THERE', 19, Li));
                                     Li.Done;
                                     If m = 1 Then
                                       m := uLevelRoute
                                     Else
                                       If m = 2 Then
                                         m := uDrainRoute;
                                     If (m <> 0) And (j < MaxResources)
                                     And (i < MaxResources) And (a > 0) Then
                                       UM^.AddUnitInfo(CivInfo [C [ci]^.Owner].BlockId,
                                                       l, m,
                                                       ci, a,
                                                       (Lo(j) SHL 8) OR Lo(i));
                                   End;
                             End
                         Else
                           If (U^ [UType].ActionCaps AND Diplomacy <> 0) Then
                             Begin;
                               i := UnitPointer;
                               UnitPointer := l;
                               TwinGame^.Empower;
                               UnitPointer := i;
                               NeedsUpdate := Some;
                             End;
                       End;
                     End;
               End;
          Enter,
          ESC: NeedsUpdate := Full;

       End;
      Until (NeedsUpdate <> None);
     Until (Kbd.Press = ESC) Or (Kbd.Press = Enter);
     FreeMem(PCt, 64*256);
     Kbd.ClearAreas;
   End;

 Procedure Game.CollectField;

   Var
      i           : Word;

      b           : Byte;

   Begin;
     b := Map.ShadowGet(cx, cy);
     If b AND shExploited = 0 Then
       With C [cc]^ Do
         Begin;
           If b AND shIrrigated <> 0 Then
             Inc(Stores [rFood], Round(Map.TerGet(cx, cy)^.ResourceYield [rFood] / 2 + 0.49));
           Inc(Stores [rFood], Round(Map.TerGet(cx, cy)^.ResourceYield [rFood]
               * (CivInfo [CivPointer].CasteBonus [caPeasants] / 100)));
           For i := 1 To MaxRawResources Do
             Inc(Stores [i], Map.TerGet(cx, cy)^.ResourceYield [i]);
           Map.ShadowSet(cx, cy, shExploited);
         End;
   End;

 Procedure Game.CutStores;

   Var
      i, ci  : Word;

   Begin;
     For ci := 1 To MaxCitiesUsed Do
       If C [ci]^.Owner <> 0 Then
         With C [ci]^ Do
           Begin;
             For i := 1 To MaxResources Do
               If (Stores [i] > 100) And (Improv AND _imWareHouse = 0) Then
                 Stores [i] := 100
               Else
                 If (Stores [i] > 200) Then
                   Stores [i] := 200;
             If (Improv AND _imGranary = 0) Then
               Stores [rFood] := 0;
           End;
   End;

 Procedure Game.CollectResources;

   Var
      i, j, l: Word;

   Begin;
     For i := 1 To MaxCitiesUsed Do
       With C [i]^ Do
         Begin;
           l := Stores [rFood];
           CollectField(x, y, i);
           For j := 0 To 7 Do
             Case ResExp AND Pow [j] Of

                 1: CollectField(x - 1, y - 1, i);
                 2: CollectField(x, y - 1, i);
                 4: CollectField(x + 1, y - 1, i);
                 8: CollectField(x - 1, y, i);
                16: CollectField(x + 1, y, i);
                32: CollectField(x - 1, y + 1, i);
                64: CollectField(x, y + 1, i);
               128: CollectField(x + 1, y + 1, i);

             End;
           Inc(Stores [rFood], Round((Stores [rFood] - l) * (1 + CivInfo [CivPointer].CasteBonus [caPeasants] / 100)));
         End;
   End;

 Procedure Game.GrowCities;

   Var
      a, b,
      i, j, l: Word;

   Begin;
     For i := 1 To MaxCivilizations Do
       CivInfo [i].Population := 0;
     For i := 1 To MaxCitiesUsed Do
       With C [i]^ Do
         Begin;
           Case Hi(Activity) AND 127 Of

             1: Begin;
                  j := Production;
                  j := j * (1 + CivInfo [CivPointer].CasteBonus [caArtisans]);
                  Inc(Progress, j);
                  If Progress >= Goal Then
                    Begin;
                      Improv := Improv OR Pow [Pred(Lo(Activity))];
{                      Dec(Improv, Pow [Pred(Imp [Lo(Activity)].ParentImp)]);}
                      N^.AddNotice(CivInfo [CivPointer].NoticeId,
                                   nImprProduced, CivPointer,
                                   i, Lo(Activity), 0);
                      Activity := 0 OR (Activity AND 32768);
                      Progress := 0;
                      Goal := 0;
                    End;
                End;
             2: Begin;
                  j := Production;
                  j := j * (1 + CivInfo [CivPointer].CasteBonus [caArtisans]);
                  Inc(Progress, j);
                  If (Progress >= Goal) Then
                    Begin;
                      Dec(Population);
                      j := TwinGame^.AddUnit(x, y, Lo(Activity), Owner);
                      N^.AddNotice(CivInfo [CivPointer].NoticeId,
                                   nUnitProduced, CivPointer,
                                   i, Lo(Activity), 0);
                      TwinGame^.InitialOrders(i, j);
                      If (Activity AND 32768 = 0) Or (CityCanBuildUnit(i, Lo(Activity)) = False) Then
                        Begin;
                          Activity := 0;
                          Progress := 0;
                          Goal := 0;
                        End
                      Else
                        Begin;
                          Progress := 0;
                          CityBuildUnit(i, Lo(Activity));
                        End;
                    End;
                End;
             3: Begin;
                  j := Production;
                  j := j * (1 + CivInfo [CivPointer].CasteBonus [caArtisans]);
                  j := j DIV ResX [Lo(Activity)].ProdReq;
                  If Progress + j > Goal Then
                    Dec(j, (Progress + j) - Goal);
                  While (j > 0) And (Stores [ResX [Lo(Activity)].InR] > ResX [Lo(Activity)].Ratio) Do
                    Begin;
                      Inc(Stores [ResX [Lo(Activity)].OutR]);
                      Dec(Stores [ResX [Lo(Activity)].InR], ResX [Lo(Activity)].Ratio);
                      Dec(j);
                      Inc(Progress);
                    End;
                  If Progress = Goal Then
                    Begin;
                      N^.AddNotice(CivInfo [CivPointer].NoticeId,
                                   nResManufactured, CivPointer,
                                   i, Lo(Activity), Goal);
                      If Activity AND 32768 = 0 Then
                        Begin;
                          Activity := 0;
                          Progress := 0;
                          Goal := 0;
                        End
                      Else
                        Progress := 0;
                    End;
                End;
             4: Begin;
                  Inc(Progress);
                  If Progress = Goal Then
                    Begin;
                      Case U^ [Lo(Activity)].ActionCaps AND (CarryGoods OR Diplomacy) Of

                        0: Dec(Population, 10);
                        Else
                          Dec(Population, 1);

                      End;
                      j := TwinGame^.AddUnit(x, y, Lo(Activity), Owner);
                      N^.AddNotice(CivInfo [CivPointer].NoticeId,
                                   nUnitProduced, CivPointer,
                                   i, Lo(Activity), 0);
                      TwinGame^.InitialOrders(i, j);
                      If (Activity AND 32768 = 0) Or (CityCanBuildUnit(i, Lo(Activity)) = False) Then
                        Begin;
                          Activity := 0;
                          Progress := 0;
                          Goal := 0;
                        End
                      Else
                        Begin;
                          Progress := 0;
                          CityBuildUnit(i, Lo(Activity));
                        End;
                    End;
                End;

           End;
           If TwinGame^.EthnicUnrest(i) = False Then
             Begin;
               If CivInfo [owner].ScienceCity <> i Then
                 Inc(CivInfo [Owner].Wealth, Taxes)
               Else
                 If CivInfo [Owner].ResActivity <> 0 Then
                   Begin;
                     b := CivInfo [Owner].Knowledge [CivInfo [Owner].ResActivity];
                     j := Round(Taxes * (1 + (CivInfo [Owner].CasteBonus [caScholars] / 100)));
                     Inc(CivInfo [Owner].Knowledge [CivInfo [Owner].ResActivity], j);
                     If (CivInfo [Owner].Control = 3) Or (CivInfo [Owner].Control = 1) Then
                       TwinGame^.NewDiscoveries(b, Owner);
                   End;
             End;
           a := ResExpFields;
           j := Round(Population * 0.03 + 0.49);
           If (j > 3) Then
             Inc(Population, 3)
           Else
             Inc(Population, j);
           If (Population > 100) And (Improv AND _imMinorAqueduct = 0) Then
             Population := 100
           Else
             If (Population > 300) And (Improv AND _imMajorAqueduct = 0) Then
               Population := 300;
           j := FoodReq;
           If Improv AND _imGranary = 0 Then
             Begin;
               If j > Stores [rFood] Then
                 Begin;
                   If Population > 20 Then
                     Dec(Population, 20 * (j - Stores [rFood]))
                   Else
                     Population := 1;
                   j := Stores [rFood];
                 End;
               Dec(Stores [rFood], j);
             End;
           b := ResExpFields;
           If (a < b) And (Bits [a] < 8) And (Bits [ResExp] < b) Then
             Begin;
               Repeat
                j := Random(8);
               Until (ResExp AND Pow [j] = 0);
               ResExp := ResExp OR Pow [j];
             End
           Else
             If (Bits [ResExp] > ResExpFields) Then
               Begin;
                 Repeat
                  Repeat
                   j := Random(8);
                  Until (ResExp AND Pow [j] <> 0);
                  ResExp := ResExp AND (NOT Pow [j]);
                 Until (Bits [ResExp] = ResExpFields);
               End;
           Inc(CivInfo [Owner].Population, Population);
         End;
   End;

 Procedure Game.HandleSocieties;

   Var
      i, j   : Word;

      l, m   : Real;

   Begin;
     For i := 1 To MaxCivilizations Do
       If CivInfo [i].Control <> 0 Then
         With CivInfo [i] Do
           Begin;
             If ScienceCity < 0 Then
               Inc(ScienceCity);
             If NLP < 0 Then
               Begin;
                 Inc(NLP);
                 For j := 1 To MaxCastes Do
                   CasteBonus [j] := 0;
               End
             Else
               Begin;
                 m := 0;
                 For j := 1 To MaxCitiesUsed Do
                   If C [j]^.Owner = i Then
                     Begin;
                       Case C [j]^.Improv AND (_imArchives
                                            OR _imLibrary
                                            OR _imMainLibrary) Of

                                         0: l := 0;
                               _imArchives: l := 0.25;
                               _imArchives
                             OR _imLibrary: l := 0.50;
                               _imArchives
                             OR _imLibrary
                         OR _imMainLibrary: l := 0.75;

                       End;
                       Case C [j]^.Improv AND (_imTutorsResid
                                            OR _imSchool) Of

                         _imTutorsResid: l := l + 0.50;
                         _imTutorsResid
                          OR _imSchool: l := l + 1.25;

                       End;
                       l := l * (C [j]^.Population / Population);
                       m := m + l;
                     End;
                 m := m + 1;
                 m := m * ((Knowledge [resLiteracy] / Adv^ [resLiteracy].MaxRes) * 33);
                 NLP := Round(m / 6);
                 For j := 1 To MaxCastes Do
                   Case CasteRank [j] Of

                     1: CasteBonus [j] := NLP * 3;
                     2: CasteBonus [j] := NLP * 2;
                     3: CasteBonus [j] := NLP * 1;
                     Else
                       CasteBonus [j] := 0;

                   End;
               End;
           End;
   End;

 Procedure Game.PrimitiveAICycle;
   Var
      i, x1, x2   : Word;

      St          : String [40];

      P           : Pointer;

   Begin;
     If CompMov Then
       Begin;
         St := 'The ' + CivInfo [CivPointer].Name + ' tribes are moving';
         SetFillStyle(SolidFill, LightGray);
         x2 := Length(St) * 5 + 10;
         x1 := (320 - x2) DIV 2;
         x2 := x2 + x1;
         P := GetArea(x1 - 1, 49, x2 + 1, 61);
         Bar(x1, 50, x2, 60);
         FrameReverse3D(x1 - 1, 49, x2 + 1, 61);
         PW^.PenColour := White;
         PW^.BkGColour := DarkGray;
         PW^.ShadowWrite(x1 + 5, 54, UpStr(St));
       End;

     HandleUnits;
     For i := 1 To MaxUnitsUsed Do
       If Un [i].Owner = CivPointer Then
         Begin;
           UnitPointer := i;
         End;
     If CompMov Then
       PutArea(P);
   End;

 Procedure Game.CivilizedAICycle;
   Var
      i, x1, x2   : Word;

      St          : String [40];

      P           : Pointer;

   Begin;
     If CompMov Then
       Begin;
         St := 'The ' + CivInfo [CivPointer].Name + ' civilization is moving';
         SetFillStyle(SolidFill, LightGray);
         x2 := Length(St) * 5 + 10;
         x1 := (320 - x2) DIV 2;
         x2 := x2 + x1;
         P := GetArea(x1 - 1, 49, x2 + 1, 61);
         Bar(x1, 50, x2, 60);
         FrameReverse3D(x1 - 1, 49, x2 + 1, 61);
         PW^.PenColour := White;
         PW^.BkGColour := DarkGray;
         PW^.ShadowWrite(x1 + 5, 54, UpStr(St));
       End;

     HandleUnits;
     For i := 1 To MaxUnitsUsed Do
       If Un [i].Owner = CivPointer Then
         Begin;
           UnitPointer := i;
         End;
     If CompMov Then
       PutArea(P);
   End;

 Function Game.UnitsLeft;

   Var
      i, j        : Word;

   Begin;
     j := 0;
     For i := 1 To MaxUnitsUsed Do
       With Un [i] Do
         If (Owner = CivPointer) And (X > 0) And (MovesLeft > 0)
         And ((Status = stReady) Or
              (Status = stTransported) Or
              (Status = stGotoing) Or
              (Status = stGotoingAndSentry)) Then
           Inc(j);
     UnitsLeft := j;
   End;

 Procedure Game.UnLoadUnits;

   Var
      i      : Word;

   Begin;
     i := 0;
     Repeat
      i := TwinGame^.LocateUnit(x, y, i);
      With U^ [Un [i].UType] Do
        If (ActionCaps AND CarryGoods = 0) And (ActionCaps AND CarryUnits = 0) And (Un [i].Status = stSentried) Then
          ReleaseUnit(i);
     Until (i > MaxUnitsUsed);
   End;

 Procedure Game.HandleUnits;

   Var
      i, j, f,
      l, m, o     : Word;

      a           : LongInt;

   Begin;
     For i := 1 To MaxUnitsUsed Do
       With Un [i] Do
         If (Owner = CivPointer) And (X > 0) And (Status <> stSentried) Then
           Begin;
             If (Status <> stFortified) And (Status <> stTransported) And (InitStatus <> LoadedGame) Then
               Inc(MovesLeft, U^ [UType].MaxMove)
             Else
               MovesLeft := 10;
             If (MovesLeft > 0) And (Status <> stTransported)
                                And (Status <> stFortified)
                                And (Status <> stGotoing)
                                And (Status <> stGotoingAndSentry) Then
               Begin;
                 f := 0;
                 If Status <> stForting Then
                   Status := stReady
                 Else
                   Begin;
                     TwinGame^.KillUnit(i, False);
                     f := 1;
                   End;
               End;
             If f <> 0 Then
  { Supplies } Case UType Of

                 5..40: Begin;
                          With Un [i] Do
                            For j := x - 1 To x + 1 Do
                              For l := y - 1 To y + 1 Do
                                Begin;
                                  m := Map.ShadowGet(j, l);
                                  If (m AND shCity <> 0) Then
                                    Begin;
                                      m := TwinGame^.LocateCity(j, l);
                                      If C [m]^.Stores [rFood] > 0 Then
                                        Begin;
                                          SuppliesLeft := 6;
                                          Dec(C [m]^.Stores [rFood]);
                                          j := x + 1;
                                          l := y + 1;
                                        End;
                                    End
                                  Else
                                    If (m And shUnit <> 0) Then
                                      Begin;
                                        m := 0;
                                        Repeat
                                         m := TwinGame^.LocateUnit(j, l, m);
                                        Until (m > MaxUnitsUsed) Or ((U^ [Un [m].UType].ActionCaps AND CarryGoods <> 0)
                                        And (Un [m].Owner = Owner));
                                        If m < MaxUnitsUsed Then
                                          Begin;
                                            o := UM^.Locate(CivInfo [Owner].BlockId, m OR uGoods, o);
                                            If (o <= UM^.MaxUsed) Then
                                              Begin;
                                                If (Hi(UM^.Block [o].Data [1]) = rFood) And
                                                   (Lo(UM^.Block [o].Data [1]) > 0) Then
                                                  Begin;
                                                    SuppliesLeft := 6;
                                                    m := Lo(UM^.Block [o].Data [1]);
                                                    Dec(m);
                                                    If m = 0 Then
                                                      UM^.Block [o].Data [1]:= 0
                                                    Else
                                                      UM^.Block [o].Data [1] := $0100 OR Lo(m);
                                                    j := x + 1;
                                                    l := y + 1;
                                                  End
                                                Else
                                                  If (Hi(UM^.Block [o].Data [2]) = rFood)
                                                  And (Lo(UM^.Block [o].Data [2]) > 0) Then
                                                    Begin;
                                                      SuppliesLeft := 6;
                                                      m := Lo(UM^.Block [o].Data [2]);
                                                      Dec(m);
                                                      If m = 0 Then
                                                        UM^.Block [o].Data [2]:= 0
                                                      Else
                                                        UM^.Block [o].Data [2] := $0100 OR Lo(m);
                                                      j := x + 1;
                                                      l := y + 1;
                                                    End;
                                              End;
                                          End;
                                      End;
                                End;
                          Dec(SuppliesLeft, 1);
                          If SuppliesLeft < 0 Then
                            Begin;
                              N^.AddNotice(CivInfo [CivPointer].NoticeId,
                                           nUnitStarved, CivPointer,
                                           Un [i].UType, Un [i].x, Un [i].y);
                              If (U^ [Un [i].UType].ActionCaps AND CarryUnits <> 0)
                              And (Map.ShadowGet(Un [i].x, Un [i].y) AND shCity = 0) Then
                                TwinGame^.AttackUnit(0, i, False, KillEmAll)
                              Else
                                TwinGame^.AttackUnit(0, i, False, KillOnly1);
                            End;
                        End;

               End;
             If (CivInfo [CivPointer].BuiltCities > 0) And (f = 0) Then
{ Cost }       Case UType Of

                  1,
                  5
                 ..
                 40,
                 42
                 ..
                 53,
                 56
                 ..
                 58: Begin;
                       Dec(CivInfo [CivPointer].Wealth, U^ [UType].Cost);
                       If CivInfo [CivPointer].Wealth < 0 Then
                         Begin;
                           CivInfo [CivPointer].Wealth := 0;
                           N^.AddNotice(CivInfo [CivPointer].NoticeId,
                                        nUnitNotPaid, CivPointer,
                                        Un [i].UType, Un [i].x, Un [i].y);
                           If (U^ [Un [i].UType].ActionCaps AND CarryUnits <> 0)
                           And (Map.ShadowGet(Un [i].x, Un [i].y) AND shCity = 0) Then
                             TwinGame^.AttackUnit(0, i, False, KillEmAll)
                           Else
                             TwinGame^.AttackUnit(0, i, False, KillOnly1);
                           TwinGame^.KillUnit(i, False);
                         End;
                     End;

               End;
           End
         Else
           If (Owner = CivPointer) And (X > 0) Then
             Begin;
               MovesLeft := 10;
             End;
     a := CivInfo [CivPointer].BlockId;
     With UM^ Do
       Begin;
         LoadBlock(a);
         For i := 1 To MaxUsed Do
           With Block [i] Do
             If UnitId AND uCityTrigger <> 0 Then
               Begin;
                 Data [3] := Hi(Data [3]) SHL 8 OR Pred(Lo(Data [3]));
                 If Lo(Data [3]) = 0 Then
                   Begin;
                     Inc(CivInfo [CivPointer].Wealth, Data [2]);
                     N^.AddNotice(CivInfo [CivPointer].NoticeId,
                                  nTriggerExpired, Hi(Data [3]),
                                  Data [1], Data [2], UnitId AND (NOT uCityTrigger));
                     FillChar(Block [i], SizeOf(Block [i]), 0);
                     If i = MaxUsed Then
                       Begin;
                         Dec(MaxUsed);
                         Dec(i);
                       End;
                   End;
               End;
       End;
     InitStatus := NewGame;
   End;

 Procedure Game.SaveGame;

   Var
      l      : LongInt;

      i      : LongInt;

      Ch     : Char11;

      Buf    : Pointer;

   Begin;
     Ch := SaveString;
     BlockWrite(dst, Ch, SizeOf(Ch));
     GetMem(Buf, 4096);
     BlockWrite(dst, CivInfo, MaxCivilizations * SizeOf(Civilization));
     BlockWrite(dst, UnitPointer, SizeOf(UnitPointer));
     BlockWrite(dst, PFWidth, SizeOf(PFWidth));
     BlockWrite(dst, PFHeight, SizeOf(PFHeight));
     BlockWrite(dst, SX, SizeOf(SX));
     BlockWrite(dst, SY, SizeOf(SY));
     BlockWrite(dst, PFMatrix, SizeOf(PFMatrix));
     BlockWrite(dst, K^.KnownMapSizeInBytes, 10);
     K^.FlushKnownMap;
     l := FileSize(K^.kf);
     Seek(K^.kf, 0);
     K^.CurrentMapId := MaxLongInt;
     BlockWrite(dst, l, SizeOf(l));
     Repeat
      BlockRead(K^.kf, Buf^, 4096);
      BlockWrite(dst, Buf^, 4096);
      Dec(l, 4096);
     Until (l <= 4096);
     BlockRead(K^.kf, Buf^, l);
     BlockWrite(dst, Buf^, l);
     UM^.FlushBlock;
     l := FileSize(UM^.umf);
     Seek(UM^.umf, 0);
     UM^.CurrentBlId := MaxLongInt;
     BlockWrite(dst, l, SizeOf(l));
     Repeat
      BlockRead(UM^.umf, Buf^, 4096);
      BlockWrite(dst, Buf^, 4096);
      Dec(l, 4096);
     Until (l <= 4096);
     BlockRead(UM^.umf, Buf^, l);
     BlockWrite(dst, Buf^, l);
     N^.FlushN;
     l := FileSize(N^.nmf);
     Seek(N^.nmf, 0);
     N^.CurrentId := MaxLongInt;
     BlockWrite(dst, l, SizeOf(l));
     Repeat
      BlockRead(N^.nmf, Buf^, 4096);
      BlockWrite(dst, Buf^, 4096);
      Dec(l, 4096);
     Until (l <= 4096);
     BlockRead(N^.nmf, Buf^, l);
     BlockWrite(dst, Buf^, l);
     BlockWrite(dst, CN^, SizeOf(ZMachine));
     BlockWrite(dst, MaxUnitsUsed, SizeOf(MaxUnitsUsed));
     For l := 1 To MaxUnitsUsed Do
       BlockWrite(dst, Un [l], SizeOf(GameUnit));
     BlockWrite(dst, MaxCitiesUsed, SizeOf(MaxCitiesUsed));
     For i := 1 To MaxCitiesUsed Do
       BlockWrite(dst, C [i]^, SizeOf(City));
     BlockWrite(dst, Map.Width, SizeOf(Map.Width));
     BlockWrite(dst, Map.Height, SizeOf(Map.Height));
     BlockWrite(dst, Map.Shadow^, Map.Width * Map.Height);
     BlockWrite(dst, Map.Body^, Map.Width * Map.Height);
     BlockWrite(dst, Year, SizeOf(Year));
     BlockWrite(dst, CivPointer, SizeOf(CivPointer));
     Msg^.Save(dst);
     FreeMem(Buf, 4096);
   End;

 Procedure Game.ControlUnit;

   Var
      mct,
      i, j, l, m  : Word;

      a, b, d     : Integer;

      nx, ny      : Integer;

      Jk          : String [80];

      Ch          : Char;

      fil         : Text;

      Li, Ti      : StringLList;

      Loaded      : Boolean;

      ClickMode,
      GoToMode    : Byte;

      src         : File;

      PFM, PF2    : Array [0..21, 0..12] Of Word;

   Begin;
     Loaded := False;
     UnitPointer := z;
     ClickMode := 0;
     GoToMode := 0;
     With Un [z] Do
       Repeat
        If UnitPointer > 0 Then
          Begin;
            If (SX = $FFFF) Or ((X <= SX) Or (Y <= SY) Or (X >= SX + PFWidth - 1) Or (Y >= SY + PFHeight - 1)) Then
                Begin;
                  If (ClickMode = 0) And (GoToMode = 0) Then
                    Begin;
                      TwinGame^.PanPlayField(X, Y);
                      TwinGame^.DrawPlayField;
                      Kbd.IdleProc := BlinkUnit;
                    End
                  Else
                    Begin;
                      TwinGame^.DrawPlayField;
                      Kbd.IdleProc := NIL;
                    End;
                End
            Else
              Begin;
                TwinGame^.DrawPlayField;
                Kbd.IdleProc := BlinkUnit;
              End;
          End
        Else
          Begin;
            If (SX = $FFFF) And (ClickMode = 0) And (GoToMode = 0) Then
              TwinGame^.PanPlayField(CivInfo [CivPointer].StartX, CivInfo [CivPointer].StartY);
            TwinGame^.DrawPlayField;
            Kbd.IdleProc := NIL;
          End;
        Kbd.ClearAreas;
        Kbd.HotArea(0, 178, 319, 199, Enter);
        Kbd.HotArea(0, 0, 319, 176, 256);
        Kbd.GetKey;
        Case Kbd.Press Of

             F1: Begin;
                   ListCommands;
                   TwinGame^.ClearPlayField;
                   TwinGame^.ClearStatus;
                   TwinGame^.DrawPlayField;
                 End;
             F2: Begin;
                   Jk := Request('ENTER NAME OF SAVE-FILE', 8, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'#27);
                   If (Jk <> #27) And (Jk <> '') Then
                     Begin;
                       Assign(src, Jk + '.AQ');
                       Rewrite(src, 1);
                       If IOResult = 0 Then
                         Begin;
                           SaveGame(src);
                           Close(src);
                         End;
                     End;
                 End;
             F3: Begin;
                   InitPalette;
                 End;
             F4: TwinGame^.CasteMenu;
             F5: TwinGame^.ScienceMenu;
             F6: Begin;
                   For i := 1 To Map.Width Do
                     For j := 1 To Map.Height Do
                       K^.MakeKnown(CivInfo [CivPointer].KnownId, i, j);
                   TwinGame^.DrawPlayField;
                 End;
             F7: If Request(UpStr('Are you sure?'), 1, 'YN'#27) <> 'Y' Then
                   Begin;
                     Kbd.Press := 0;
                     Kbd.PressCh := '';
                   End;
             F8: Begin;
                   TwinGame^.Requirements;
                   TwinGame^.ClearPlayField;
                   TwinGame^.ClearStatus;
                   TwinGame^.DrawPlayField;
                 End;
             F9: Begin;
                   ClearDevice;
                   W.PenColour := LightCyan;
                   For i := 1 To 66 Do
                     W.HardWrite(160 * (i DIV 33) + 1, i MOD 33 * 6, NumToStr(i) + '  ' + UpStr(U^ [i].Name));
                   Repeat Until Readkey <> '';
                   i := StrToInt(Request(UpStr('Enter unit type:'), 2, '0123456789'));
                   If (i > 0) And (i <= MaxUnitTypes) Then
                     Begin;
                       j := StrToInt(Request(UpStr('Enter X (' + NumToStr(Un [UnitPointer].x) + '):'),
                                             3, '0123456789'));
                       If j = 0 Then
                         j := Un [UnitPointer].X;
                       l := StrToInt(Request(UpStr('Enter Y (' + NumToStr(Un [UnitPointer].y) + '):'),
                                             3, '0123456789'));
                       If l = 0 Then
                         l := Un [UnitPointer].Y;
                       m := StrToInt(Request(UpStr('Enter O (' + NumToStr(Un [UnitPointer].owner) + '):'),
                                             2, '0123456789'));
                       If m = 0 Then
                         m := Un [UnitPointer].Owner;
                       TwinGame^.AddUnit(j, l, i, m);
                     End;
                   ClearDevice;
                   TwinGame^.DrawPlayField;
                 End;
            sF8: Begin;
                   FillChar(PFM, SizeOf(PFM), $FF);
                   For i := 1 To 20 Do
                     For j := 1 To 11 Do
                       Begin;
                         PFM [i, j] := Map.TerGet(Pred(i + SX), Pred(j + SY))^.MoveCost;
                         If Pow [Map.TerGet(Pred(i + SX), Pred(j + SY))^.TCType]
                            AND U^ [Un [UnitPointer].UType].TerrainCaps = 0 Then
                           PFM [i, j] := $FFFF;
                       End;
                   For i := 1 To 20 Do
                     For j := 1 To 11 Do
                       If PFM [i, j] <> $FFFF Then
                         Begin;
                           a := Abs(20 - i);
                           b := Abs(11 - j);
                           If a > b Then
                             Inc(PFM [i, j], a * 10)
                           Else
                             Inc(PFM [i, j], b * 10);
                         End;
                   For i := 1 To 20 Do
                     For j := 1 To 11 Do
                       If PFM [i, j] <> $FFFF Then
                         W.SoftWrite(Pred(i) * 16 + 2, Pred(j) * 16 + 2, NumToStr(PFM [i, j]))
                       Else
                         W.SoftWrite(Pred(i) * 16 + 2, Pred(j) * 16 + 2, '!!!');
                   Repeat Until Readkey <> '';
                   mct := $8000;
                   i := 2;
                   j := 2;
                   Repeat
                    PFM [i, j] := mct;
                    Inc(mct);
                    l := $FFFF;
                    m := i;
                    d := j;
                    For a := -1 To 1 Do
                      For b := -1 To 1 Do
                        If PFM [i + a, j + b] < l Then
                          Begin;
                            m := i + a;
                            d := j + b;
                            l := PFM [m, d];
                          End;
                    If PFM [m, d] >= $8000 Then
                      PFM [i, j] := $FFFF;
                    SetColor(Green);
                    Circle(Pred(m) * 16 + 8, Pred(d) * 16 + 8, 7);
                    Delay(1000);
                    i := m;
                    j := d;
                   Until ((i = 20) And (j = 11)) Or (Keypressed);
                   Repeat Until Readkey <> '';
                   FillChar(PFM, SizeOf(PFM), 0);
                 End;
            ESC,
            F10: Begin;
                   Li.Init;
                   Li.Add('Unit..');
                   Li.Add('Save game');
                   Li.Add('Research..');
                   Li.Add('Castes..');
                   Li.Add('View Map');
                   Li.Add('Options..');
                   Li.Add('About');
                   Li.Add('Help');
                   Li.Add('Quit');
                   i := Select('MAIN MENU', 10, Li);
                   Li.Done;
                   Case i Of

                     1: Begin;
                          Li.Init;
                          Li.Add('Goto     shift-(G)');
                          Li.Add('Sentry         (s)');
                          Li.Add('Fortify        (f)');
                          Li.Add('Unload   shift-(U)');
                          Li.Add('Irrigate       (i)');
                          Li.Add('Build Roads    (r)');
                          Li.Add('Build City     (c)');
                          Li.Add('Wait           (w)');
                          Li.Add('Rest           ( )');
                          Li.Add('Disband  shift-(D)');
                          Li.Add('Lay Down Arms  (l)');
                          Li.Add('Massacre shift-(M)');
                          Li.Add('Empower  shift-(E)');
                          i := Select('COMMAND', 18, Li);
                          Case i Of

                             1: Begin;
                                  Kbd.NextKey := Ord('G');
                                  GoToMode := 3;
                                End;
                             2: Kbd.NextKey := Ord('s');
                             3: Kbd.NextKey := Ord('f');
                             4: Kbd.NextKey := Ord('U');
                             5: Kbd.NextKey := Ord('i');
                             6: Kbd.NextKey := Ord('r');
                             7: Kbd.NextKey := Ord('c');
                             8: Kbd.NextKey := Ord('w');
                             9: Kbd.NextKey := Ord(' ');
                            10: Kbd.NextKey := Ord('D');
                            11: Kbd.NextKey := Ord('l');
                            12: Kbd.NextKey := Ord('M');
                            13: Kbd.NextKey := Ord('E');

                          End;
                          Li.Done;
                        End;
                     2: Kbd.NextKey := F2;
                     6: Begin;
                          Li.Init;
                          If EndOfTurn Then
                            Li.Add('Disable End of turn')
                          Else
                            Li.Add('Enable End of turn');
                          If Hide Then
                            Li.Add('Disable Red Veil')
                          Else
                            Li.Add('Enable Red Veil');
                          If CompMov Then
                            Li.Add('No AI announcement')
                          Else
                            Li.Add('Show AI announcement');
                          Case ShowStatus Of

                            0: Li.Add('No Status');
                            1: Li.Add('Partial Status');
                            2: Li.Add('Full Status');

                          End;
                          Case WantNotice Of

                            0: Li.Add('No Notices');
                            1: Li.Add('Some Notices');
                            2: Li.Add('All Notices');

                          End;
                          i := Select('OPTIONS', 20, Li);
                          Case i Of

                            1: EndOfTurn := NOT EndOfTurn;
                            2: Hide := NOT Hide;
                            3: CompMov := NOT CompMov;
                            4: Begin;
                                 Inc(ShowStatus);
                                 If ShowStatus > 2 Then
                                   ShowStatus := 0;
                               End;
                            5: Begin;
                                 Inc(WantNotice);
                                 If WantNotice > 2 Then
                                   WantNotice := 0;
                               End;

                          End;
                        End;
                     3: Kbd.NextKey := F5;
                     4: Kbd.NextKey := F4;
                     5: Kbd.NextKey := Ord('O');
                     7: Begin;
                          AboutGame;
                          TwinGame^.ClearPlayField;
                          TwinGame^.ClearStatus;
                          TwinGame^.DrawPlayField;
                        End;
                     8: Begin;
                          ListCommands;
                          TwinGame^.ClearPlayField;
                          TwinGame^.ClearStatus;
                          TwinGame^.DrawPlayField;
                        End;
                     9: Kbd.NextKey := F7;

                   End;
                 End;
          HmKey
             ..
          PDKey: Begin;
                   If (ClickMode <> 0) Or (GoToMode <> 0) Then
                     Begin;
                       TwinGame^.PanPlayField(x, y);
                       TwinGame^.ClearPlayField;
                       TwinGame^.DrawPlayField;
                     End;
                   Case Kbd.Press Of

                     UpKey: If Pred(Y) > 1 Then
                              MoveUnit(UnitPointer, 8, True);
                     DnKey: If Succ(Y) < Map.Height Then
                              MoveUnit(UnitPointer, 2, True);
                     LfKey: If Pred(X) > 1 Then
                              MoveUnit(UnitPointer, 4, True);
                     RtKey: If Succ(X) < Map.Width Then
                              MoveUnit(UnitPointer, 6, True);
                     HmKey: If (Pred(Y) > 1) And (Pred(X) > 1) Then
                              MoveUnit(UnitPointer, 7, True);
                     PUKey: If (Pred(Y) > 1) And (Succ(X) < Map.Width) Then
                              MoveUnit(UnitPointer, 9, True);
                     PDKey: If (Succ(Y) < Map.Height) And (Succ(X) < Map.Width) Then
                              MoveUnit(UnitPointer, 3, True);
                     EnKey: If (Succ(Y) < Map.Height) And (Pred(X) > 1) Then
                              MoveUnit(UnitPointer, 1, True);

                   End;
                 End;
            256: Begin;
                   i := fMous.X DIV 16;
                   j := fMous.Y DIV 16;
                   Case Map.ShadowGet(SX + i, SY + j) AND (shUnit OR shCity) Of

                     shCity,
                     shCity OR shUnit: Begin;
                                         l := TwinGame^.LocateCity(SX + i, SY + j);
                                         If C [l]^.Owner = CivPointer Then
                                           Begin;
                                             CityStatus(l);
                                             TwinGame^.ClearPlayField;
                                             TwinGame^.DrawPlayField;
                                           End;
                                       End;
                               shUnit: Begin;
                                         l := TwinGame^.LocateUnit(SX + i, SY + j, 0);
                                         If Un [l].Owner = CivPointer Then
                                           Begin;
                                             Li.Init;
                                             Ti.Init;
                                             Repeat
                                              If (Un [l].Status = stSentried) Or (Un [l].Status = stFortified) Then
                                                Begin;
                                                  Case Un [l].Status Of

                                                     stSentried: Li.Add(Pad(UpStr(U^ [Un [l].UType].Name), ' ', 21)
                                                                 + '(S) SUP: ' + NumToStr(Un [l].SuppliesLeft));
                                                    stFortified: Li.Add(Pad(UpStr(U^ [Un [l].UType].Name), ' ', 21)
                                                                 + '(F) SUP: ' + NumToStr(Un [l].SuppliesLeft));

                                                  End;
                                                  Ti.Add(NumToStr(l));
                                                End;
                                              l := TwinGame^.LocateUnit(SX + i, SY + j, l);
                                             Until (l > MaxUnitsUsed);
                                             If Li.Elements > 1 Then
                                               Begin;
                                                 l := Select('RELEASE..', 31, Li);
                                                 If l <> 0 Then
                                                   Begin;
                                                     l := StrToInt(Ti.Get(l));
                                                     ReleaseUnit(l);
                                                   End;
                                               End
                                             Else
                                               If Li.Elements = 1 Then
                                                 ReleaseUnit(StrToInt(Ti.Get(1)));
                                             Li.Done;
                                             Ti.Done;
                                             TwinGame^.ClearPlayField;
                                             TwinGame^.DrawPlayField;
                                           End;
                                       End;
                                    0: If GoToMode = 0 Then
                                         Begin;
                                           nx := i + SX;
                                           ny := j + SY;
                                           TwinGame^.PanPlayField(nx, ny);
                                           TwinGame^.DrawPlayField;
                                           ClickMode := 2;
                                         End
                                       Else
                                         If K^.IsKnown(CivInfo [CivPointer].KnownId, i + SX, j + SY) Then
                                           Begin;
                                             Status := stGotoing;
                                             UM^.AddUnitInfo(CivInfo [Owner].BlockId, z, uGoto, i + SX, j + SY, 0);
                                             Kbd.PressCh := 'W';
                                           End
                   End;
                 End;
          Else
            Case Kbd.PressCh [1] Of

              ' ': Un [UnitPointer].MovesLeft := 0;
              'G': If UnitPointer > 0 Then
                     GotoMode := 2;
              'R': Begin;
                     TwinGame^.ClearStatus;
                     m := ShowStatus;
                     ShowStatus := 0;
                     W.PenColour := Yellow;
                     W.BkGColour := DarkGray;
                     W.ShadowWrite(10, 180, 'RELEASE MODE ENTERED');
                     W.PenColour := White;
                     W.BkGColour := DarkGray;
                     W.ShadowWrite(10, 190, 'N)EXT     R)ELEASE     S)TOP');
                     i := 0;
                     Repeat
                      Repeat
                       Inc(i);
                      Until (((Un [i].Status = stSentried) Or (Un [i].Status = stFortified))
                      And (Un [i].Owner = CivPointer)) Or (i > MaxUnitsUsed);
                      If i <= MaxUnitsUsed Then
                        With Un [i] Do
                          Begin;
                            TwinGame^.PanPlayField(x, y);
                            TwinGame^.DrawPlayField;
                            Repeat
                             Repeat
                              Map.Display(X, Y, (X - SX) * 16, (Y - SY) * 16);
                              Kbd.IntDelay(60);
                              TwinGame^.DisplayUnit(i);
                              Kbd.IntDelay(60);
                             Until Keypressed;
                             Ch := UpCase(Readkey);
                            Until (Pos(Ch, 'NRS') > 0);
                            If Ch = 'S' Then
                              i := MaxUnitsUsed
                            Else
                              If Ch = 'R' Then
                                ReleaseUnit(i);
                          End;
                     Until (i >= MaxUnitsUsed);
                     FillChar(Screen, SizeOf(Screen), 0);
                     ShowStatus := m;
                     TwinGame^.PanPlayField(Un [UnitPointer].X, Un [UnitPointer].Y);
                     TwinGame^.DrawPlayField;
                   End;
              '.': Begin;
                     TwinGame^.ClearStatus;
                     m := ShowStatus;
                     ShowStatus := 0;
                     i := 0;
                     Repeat
                      Repeat
                       Inc(i);
                      Until (C [i]^.Owner = CivPointer) Or (i > MaxCitiesUsed);
                      If i <= MaxCitiesUsed Then
                        With C [i]^ Do
                          Begin;
                            TwinGame^.PanPlayField(x, y);
                            TwinGame^.DrawPlayField;
                            TwinGame^.ClearStatus;
                            W.PenColour := Yellow;
                            W.BkGColour := DarkGray;
                            W.ShadowWrite(10, 180, 'INSPECT CITY MODE ENTERED');
                            W.PenColour := White;
                            W.BkGColour := DarkGray;
                            W.ShadowWrite(10, 190, 'N)EXT     I)NSPECT     S)TOP');
                            Repeat
                             SetWriteMode(XORPut);
                             SetColor(128);
                             Repeat
                              Rectangle((X - SX) * 16, (Y - SY) * 16, (X - SX) * 16 + 15, (Y - SY) * 16 + 15);
                              Kbd.IntDelay(60);
                              Rectangle((X - SX) * 16, (Y - SY) * 16, (X - SX) * 16 + 15, (Y - SY) * 16 + 15);
                              Kbd.IntDelay(60);
                             Until Keypressed;
                             Ch := UpCase(Readkey);
                             SetWriteMode(CopyPut);
                            Until (Pos(Ch, 'NIS') > 0);
                            If Ch = 'S' Then
                              i := MaxCitiesUsed
                            Else
                              If Ch = 'I' Then
                                CityStatus(i);
                          End;
                     Until (i >= MaxCitiesUsed);
                     FillChar(Screen, SizeOf(Screen), 0);
                     ShowStatus := m;
                     TwinGame^.PanPlayField(Un [UnitPointer].X, Un [UnitPointer].Y);
                     TwinGame^.DrawPlayField;
                   End;
              's': If UnitPointer > 0 Then
                     Begin;
                       Un [UnitPointer].MovesLeft := 0;
                       Un [UnitPointer].Status := stSentried;
                     End;
              'E': If (UnitPointer > 0) And (U^ [Un [UnitPointer].UType].ActionCaps AND Diplomacy <> 0) Then
                     TwinGame^.Empower;
              'M': If (UnitPointer > 0) Then
                     With Un [UnitPointer] Do
                       If (Map.ShadowGet(x, y) AND shCity <> 0) Then
                         Case Un [UnitPointer].UType Of

                            5
                           ..
                           41: Begin;
                                 j := TwinGame^.LocateCity(x, y);
                                 If C [j]^.Population > 10 Then
                                   With C [j]^ Do
                                     Begin;
                                       Li.Init;
                                       Ti.Init;
                                       For i := 1 To MaxCivilizations Do
                                         If (EthnicDist [i] > 0) And (i <> Owner) Then
                                           Begin;
                                             Li.Add(Pad(UpStr(CivInfo [i].Name), ' ', 16)
                                                    + Pad(NumToStr(EthnicDist [i]), ' ', 3));
                                             Ti.Add(NumToStr(i));
                                           End;
                                       If Li.Elements > 0 Then
                                         Begin;
                                           i := Select('SELECT FRACTION', 20, Li);
                                           i := StrToInt(Ti.Get(i));
                                           TwinGame^.Massacre(j, i, CivPointer, True);
                                         End;
                                       Li.Done;
                                       Ti.Done;
                                     End;
                               End;

                         End;
              'f': If UnitPointer > 0 Then
                     Begin;
                       Un [UnitPointer].MovesLeft := 0;
                       Un [UnitPointer].Status := stFortified;
                     End;
              'l': If (UnitPointer > 0) Then
                     LayDownArms(UnitPointer);
              'D': If UnitPointer > 0 Then
                     TwinGame^.KillUnit(UnitPointer, True);
              'U': If UnitPointer > 0 Then
                     With Un [UnitPointer] Do
                       Begin;
                         If U^ [UType].ActionCaps AND CarryUnits <> 0 Then
                           UnLoadUnits(x, y);
                         MovesLeft := 0;
                       End;
              'i',
              'r',
              'b',
              'c': If UnitPointer > 0 Then
                     Begin;
                       UpSelf(Kbd.PressCh);
                       i := Pow [Pred(Pos(Kbd.PressCh, TerrainChanges))];
                       With Un [UnitPointer] Do
                         If (i AND U^ [UType].ActionCaps <> 0)
                            And (i AND Map.TerGet(x, y)^.ActionCaps AND i <> 0)
                            AND (i AND Map.ShadowGet(x, y) AND i = 0) Then
                           Begin;
                             If (i = 1) And (Map.TerGet(x, y)^.ITR <> 0) Then
                               Map.Put(x, y, Map.TerGet(x, y)^.ITR)
                             Else
                               Map.ShadowSet(x, y, i);
                             i := Pos(Kbd.PressCh [1], TerrainChanges);
                             Dec(MovesLeft, (10 * TCTimeRequired [i] * Map.TerGet(x, y)^.MoveCost) DIV 10);
                             If MovesLeft < 0 Then
                               Status := i
                             Else
                               If i = 4 Then
                                 Begin;
                                   Jk := Request(UpStr('Name your city'), 15, CN^.Tab + CN^.Tab2 + #27);
                                   If (Jk = '') And (CivInfo [CivPointer].Primitive = False) Then
                                     Begin;
                                       If IOResult <> 0 Then ;
                                       Assign(fil, CityFileName);
                                       Reset(fil);
                                       Repeat
                                        ReadLn(fil, Jk);
                                       Until (Jk = CivInfo [CivPointer].Name) Or (IOResult <> 0);
                                       For i := 1 To CivInfo [CivPointer].NamedCities + 1 Do
                                         ReadLn(fil, Jk);
                                       If (Jk = '') Or (IOResult <> 0) Then
                                         Jk := 'CITY'
                                       Else
                                         Inc(CivInfo [CivPointer].NamedCities);
                                       Close(fil);
                                     End
                                   Else
                                     If (Jk = '') Then
                                       Jk := 'VILLAGE';
                                   If (Jk = #27) Then
                                     Map.ShadowClear(x, y, Pow [Pred(Pos(Kbd.PressCh, TerrainChanges))])
                                   Else
                                     Begin;
                                       AddCity(x, y, UpStr(Jk), CivPointer);
                                       TwinGame^.KillUnit(UnitPointer, False);
                                     End;
                                 End;
                           End;
                     End;
              'O': Begin;
                     FillChar(Screen, SizeOf(Screen), Black);
                     For i := 1 To Map.Width Do
                       For j := 1 To Map.Height Do
                         If K^.IsKnown(CivInfo [CivPointer].KnownId, i, j) Then
                           Screen [j, i] := OvrVwCol [Map.Get(i, j)];
                     W.PenColour := White;
                     W.BkGColour := Black;
                     W.HardWrite(10, 190, UpStr('Press F10 to return to the game...'));
                     Kbd.ClearAreas;
                     Kbd.Clear;
                     Kbd.IdleProc := NIL;
                     Kbd.HotArea(0, 0, 319, 199, F10);
                     Repeat
                      Kbd.GetKey;
                     Until (Kbd.Press = F10);
                     FillChar(Screen, SizeOf(Screen), Black);
                     TwinGame^.DrawPlayField;
                   End;

            End;

        End;
        If ClickMode > 0 Then
          Dec(ClickMode);
        If GotoMode > 0 Then
          Dec(GotoMode);
       Until (Loaded) Or (MovesLeft <= 0) Or (Status <> stReady) Or (X = 0)
             Or (Kbd.Press = F7) Or (Kbd.Press = Enter) Or ((UpCase(Kbd.PressCh [1]) = 'W') And (UnitPointer > 0));
     If Loaded Then
       Exit;
     With Un [z] Do
       If (MovesLeft < 0) And ((Status = stReady) Or (Status = stTransported)) Then
         Status := stMoving;
     If Kbd.Press = F7 Then
       Begin;
         UnitPointer := MaxUnitsUsed;
         z := UnitPointer;
       End;
   End;

 Procedure Game.AutoMove;

   Var
      MoveMatrix  : Array [-1..1, -1..1] Of Word;

      i, j, x2, y2: Integer;

      l, m        : Word;

   Begin;
     UnitPointer := z;
     With Un [z] Do
       If TwinGame^.EnemyUnits(x, y, Owner) Then
         Begin;
           Status := stReady;
           i := UM^.Locate(CivInfo [Owner].BlockID, z OR uGoTo, 0);
           UM^.Block [i].UnitID := 0;
           Exit;
         End;
     With Un [z] Do
       Begin;
         Repeat
          TwinGame^.PanPlayField(x, y);
          TwinGame^.DrawPlayField;
          i := UM^.Locate(CivInfo [Owner].BlockID, z OR uGoTo, 0);
          x2 := UM^.Block [i].Data [1];
          y2 := UM^.Block [i].Data [2];
          For i := x - 1 To x + 1 Do
            For j := y - 1 To y + 1 Do
              If Pow [Map.TerGet(i, j)^.TCtype] AND U^ [UType].TerrainCaps = 0 Then
                MoveMatrix [i - x, j - y] := $FFFF
              Else
                Begin;
                  MoveMatrix [i - x, j - y] := Map.TerGet(i, j)^.MoveCost;
                  If Abs(x2 - i) > Abs(x2 - x) Then
                    MoveMatrix [i - x, j - y] := MoveMatrix [i - x, j - y] + 30
                  Else
                    If Abs(x2 - i) < Abs(x2 - x) Then
                      MoveMatrix [i - x, j - y] := MoveMatrix [i - x, j - y] - 2;
                  If Abs(y2 - j) > Abs(y2 - y) Then
                    MoveMatrix [i - x, j - y] := MoveMatrix [i - x, j - y] + 30
                  Else
                    If Abs(y2 - j) < Abs(y2 - y) Then
                      MoveMatrix [i - x, j - y] := MoveMatrix [i - x, j - y] - 2;
                End;
          MoveMatrix [0, 0] := $FFF8;
          Repeat
           l := 5;
           m := $FFF0;
           For i := -1 To 1 Do
             For j := -1 To 1 Do
               If (MoveMatrix [i, j] < m) And (DirMatrix [i, j] <> 5) Then
                 Begin;
                   m := MoveMatrix [i, j];
                   l := DirMatrix [i, j];
                 End;
           If (l <> 5) And (m <= 30) Then
             Begin;
               m := MovesLeft;
               MoveUnit(z, l, True);
               If m = MovesLeft Then
                 Begin;
                   For i := -1 To 1 Do
                     For j := -1 To 1 Do
                       If DirMatrix [i, j] = l Then
                         MoveMatrix [i, j] := $FFFF;
                 End;
             End
           Else
             Status := stReady;
           If (x = x2) And (y = y2) Or (Status = stReady) Then
             Begin;
               If (Status = stGotoingAndSentry) Then
                 Status := stSentried
               Else
                 Status := stReady;
               i := UM^.Locate(CivInfo [Owner].BlockID, z OR uGoTo, 0);
               UM^.Block [i].UnitID := 0;
             End;
          Until (MovesLeft < m) Or (MovesLeft <= 0) Or (Status = stReady) Or (Status = stSentried);
         Until (MovesLeft <= 0) Or (Status = stReady) Or (Status = stSentried);
       End;
   End;

 Procedure Game.CleanUnitList;

   Var
      i      : Word;

   Begin;
     i := Succ(MaxUnitsUsed);
     Repeat
      Dec(i);
     Until (Un [i].x <> 0);
     MaxUnitsUsed := i;
   End;

 Procedure Game.Play;

   Var
      Jk     : String [320 DIV 5];

      m,
      z, i, j: Word;

      T      : Boolean;

   Begin;
     FillChar(Screen, SizeOf(Screen), Black);
     TwinGame^.DrawPlayField;
     TwinGame^.DisplayStatus;
     Repeat
      Kbd.Press := 0;
      If CivPointer = 1 Then
        Begin;
          CollectResources;
          GrowCities;
          CutStores;
          HandleSocieties;
          CleanUnitList;
        End;
      Case CivInfo [CivPointer].Control Of

        0: Inc(CivPointer);
        1: Begin;
             HandleUnits;
             If (Hide) Then
               Begin;
                 FillChar(Screen, SizeOf(Screen), LightRed);
                 W.PenColour := White;
                 W.BkGColour := Black;
                 Jk := 'THE ' + UpStr(CivInfo [CivPointer].Name) + ' CIVILIZATION IS NEXT TO MOVE';
                 W.ShadowWrite((320 - Length(Jk) * 5) DIV 2, 50, Jk);
                 W.ShadowWrite(118, 70, '* PRESS ANY KEY *');
                 Kbd.Clear;
                 Kbd.IdleProc := BlinkWait;
                 Kbd.GetKey;
                 FillChar(Screen, SizeOf(Screen), Black);
               End;
             TwinGame^.PresentNotices;
             N^.LoadN(CivInfo [CivPointer].NoticeId);
             N^.ClearN(CivInfo [CivPointer].NoticeId, N^.MaxUsed);
             j := 0;
             m := 0;
             For i := 1 To MaxCitiesUsed Do
               With C [i]^ Do
                 If (Owner = CivPointer) Then
                   Begin;
                     Inc(j);
                     Case Hi(Activity) AND 127 Of

                       0: CityStatus(i);
                       5: Inc(m);

                     End;
                   End;
             If (m = j) And (EndOfTurn = False) And (UnitsLeft = 0) And (j > 0) Then
               Begin;
                 EndOfTurn := True;
                 T := True;
               End
             Else
               T := False;
             SX := $FFFF;
             SY := $FFFF;
             With CivInfo [CivPointer] Do
               If ((ResActivity = 0) Or (Knowledge [ResActivity] >= Adv^ [ResActivity].MaxRes))
               And (ScienceCity > 0) Then
                 TwinGame^.SelectResearch;
             Repeat
              If UnitsLeft > 0 Then
                Begin;
                  For z := 1 To MaxUnitsUsed Do
                    With Un [z] Do
                      If (Owner = CivPointer) And (X > 0) And (MovesLeft > 0) Then
                        Case Status Of

                               stReady,
                               stTransported: ControlUnit(z);
                          stGotoingAndSentry,
                                   stGotoing: AutoMove(z);
                        End;
                End
              Else
                If EndOfTurn Then
                  Begin;
                    z := 0;
                    ControlUnit(z);
                  End;
             Until (Kbd.Press = F7) Or ((UnitsLeft = 0) And ((EndOfTurn = False) Or (Kbd.Press = Enter)));
             If T Then
               EndOfTurn := False;
             Inc(CivPointer);
           End;
        2: Begin;
             PrimitiveAICycle;
             Inc(CivPointer);
           End;
        3: Begin;
             CivilizedAICycle;
             Inc(CivPointer);
           End;

      End;
      If Kbd.Press <> F7 Then
        Begin;
          If CivPointer > MaxCivilizations Then
            Begin;
              CivPointer := 1;
              For i := 1 To MaxCitiesUsed Do
                With C [i]^ Do
                  Begin;
                    Map.ShadowClear(x, y, shExploited);
                    For m := 0 To 7 Do
                      Case ResExp AND Pow [m] Of

                          1: Map.ShadowClear(x - 1, y - 1, shExploited);
                          2: Map.ShadowClear(x, y - 1, shExploited);
                          4: Map.ShadowClear(x + 1, y - 1, shExploited);
                          8: Map.ShadowClear(x - 1, y, shExploited);
                         16: Map.ShadowClear(x + 1, y, shExploited);
                         32: Map.ShadowClear(x - 1, y + 1, shExploited);
                         64: Map.ShadowClear(x, y + 1, shExploited);
                        128: Map.ShadowClear(x + 1, y + 1, shExploited);

                      End;
                  End;
              Case Year Of

                -4000
                   ..
                -3010: Inc(Year, 10);
                -3000
                   ..
                -2010: Inc(Year, 10);
                -2000
                   ..
                -1002: Inc(Year, 2);
                -1000
                   ..
                  500: Inc(Year);

              End;
              If (Year = Adv^ [resBronzeWorking].ResYear) Or (Year = Adv^ [resIronWorking].ResYear) Then
                Begin;
                  Y := Year;
                  BZ := Adv^ [resBronzeWorking].ResYear;
                  IR := Adv^ [resIronWorking].ResYear;
                  Map.LoadTerrain(TerrainFileName);
                  If (Year < Adv^ [resIronWorking].ResYear) Then
                    j := nBronzeAge
                  Else
                    j := nIronAge;
                  For i := 1 To MaxCivilizations Do
                    If CivInfo [i].Control > 0 Then
                      N^.AddNotice(CivInfo [i].NoticeId, j, i, 0, 0, 0);
                End;
            End;
        End;
     Until Kbd.Press = F7;
   End;

 Destructor Game.Done;

   Var
      i           : Word;

   Begin;
     KillWaveMachine;
     CloseGraph;
     Map.Done;
     Kbd.Done;
     FreeMem(Adv, SizeOf(AdvanceArray));
     Dispose(CN);
     FreeMem(U, SizeOf(UnitArray));
     For i := 1 To MaxCitiesUsed Do
       If C [i] <> NIL Then
         Dispose(C [i]);
     Dispose(K, Done);
     Dispose(UM, Done);
     Dispose(N, Done);
     Dispose(Msg, Done);
   End;

 End.