
 Unit C2X;

 Interface

 Uses
     Crt,
     Keyboard,
     C2Str,
     Graph,
     C2Lib;

 Type
     _Game        = Object
{$I GAMEVARS.PAS}
                      Procedure NewDiscoveries(b : Word; cp : Byte);
                      Procedure BWButton(x, y : Word; S : String; KC : Word);
                      Procedure Button(x, y : Word; S : String; KC : Word);
                      Procedure Requirements;
                      Procedure CasteMenu;
                      Procedure SelectResearch;
                      Procedure ScienceMenu;
                      Function GetGameDate : String;
                      Function EnemyUnits(x, y : Word; o : Byte) : Boolean;
                      Function CalculatePrice(ResD, Ci : Word) : Word;
                      Function AttackPreparations : Boolean;
                      Function LocateUnitDiscriminative(fx, fy : Word; Disc : Boolean) : Word;
                      Procedure RemoveUnit(x, y : Word);
                      Procedure KillUnit(ui : Word; Show : Boolean);
                      Function LocateCity(fx, fy : Word) : Word;
                      Procedure Massacre(ci : Word; m, a : Byte; No : Boolean);
                      Function EthnicUnRest(ci : Word) : Boolean;
                      Function AttackUnit(atui, dfui : Word; Show, kea : Boolean) : Byte;
                      Function PlaceUnit(ui, nx, ny : Word; o : Byte; ChkEn, Show : Boolean) : Byte;
                      Function PointUnit(ui : Word) : GameUnitPtr;
                      Function LocateUnit(fx, fy, ofs : Word) : Word;
                      Function AddUnit(nx, ny : Word; ut, o : Byte) : Word;
                      Procedure CreateRefugees(ci : Word; o, a : Byte);
                      Procedure CreatePartisans(ci : Word; o, a : Byte);
                      Procedure ClearPlayField;
                      Procedure DisplayUnit(ui : Word);
                      Procedure PanPlayField(x, y : Word);
                      Procedure ClearStatus;
                      Procedure DisplayStatus;
                      Procedure SubEmpower(a : Word; Var b, d : Word);
                      Procedure Empower;
                      Procedure DrawPlayField;
                      Function DecodeUEmp(empid : Word; d2, d3 : Word) : String;
                      Function DecodeNEmp(nid : Word; d2, d3 : Word) : String;
                      Procedure PresentNotices;
                      Function CivCanBuildUnit(i : Word; cp : Byte) : Boolean;
                      Function CivCanBuildImpr(i : Word; cp : Byte) : Boolean;
                      Procedure InitialOrders(ci, ui : Word);
                    End;

 Implementation

 Function _Game.GetGameDate;
   Begin;
     If Year < 0 Then
       GetGameDate := NumToStr(Year * -1) + ' BC'
     Else
       GetGameDate := NumToStr(Year) + ' AD';
   End;

 Procedure _Game.BWButton;
   Begin;
     FrameReverse3D(x, y, x + 8 + Length(S) * 5, y + 8);
     W.PenColour := DarkGray;
     W.BkGColour := White;
     W.WkShadowWrite(x + 4, y + 3, S);
     Kbd.HotArea(x, y, x + 8 + Length(S) * 5, y + 8, KC);
   End;

 Procedure _Game.Button;
   Begin;
     FrameReverse3D(x, y, x + 8 + Length(S) * 5, y + 8);
     W.PenColour := LightCyan;
     W.BkGColour := Black;
     W.WkShadowWrite(x + 4, y + 3, S);
     Kbd.HotArea(x, y, x + 8 + Length(S) * 5, y + 8, KC);
   End;

 Procedure _Game.Requirements;

   Var
      src    : Text;

      T, Jk  : String;

      oy,
      Y, MY, m,
      i, j, l: Word;

      STi,
      SLi,
      Ti, Li : StringLList;

   Begin;
     ClearDevice;
     SetFillStyle(SolidFill, LightBlue);
     Bar(103, 0, 319, 199);
     SetFillStyle(SolidFill, LightBlue);
     Bar(0, 0, 102, 199);
     Frame3D(128, 8, 302, 152);
     SLi.Init;
     STi.Init;
     For i := 1 To MaxUnitTypes - 13 Do
       Begin;
         SLi.Add(Pad(UpStr(U^ [i].Name), ' ', 20));
         STi.Add('1;' + NumToStr(i));
       End;
     For i := 1 To MaxImprovements Do
       Begin;
         SLi.Add(Pad(UpStr(Imp [i].Name), ' ', 20));
         STi.Add('2;' + NumToStr(i));
       End;
     Li.Init;
     Ti.Init;
     For i := 1 To SLi.Elements Do
       Begin;
         T := Dup(#255, 20);
         l := 0;
         For j := 1 To SLi.Elements Do
           If SLi.Get(j) < T Then
             Begin;
               T := SLi.Get(j);
               l := j;
             End;
         Li.Add(T);
         Ti.Add(STi.Get(l));
         SLi.SetS(l, Dup(#255, 20));
       End;
     SLi.Done;
     STi.Done;
     MY := 0;
     Y := 1;
     Kbd.ClearAreas;
     Button(106, 2, 'UP', PUKey);
     Button(106, 190, 'DOWN', PDKey);
     Button(140, 190, 'SELECT', Enter);
     Button(260, 190, 'ESC: EXIT', ESC);
     W.PenColour := 125;
     W.BkGColour := LightBlue;
     For i := 1 To 33 Do
       Begin;
         W.HardWrite(3, Pred(i) * 6 + 3, Li.Get(i + MY));
         Kbd.HotArea(1, Pred(i) * 6 + 1, 102, Pred(i) * 6 + 1 + 6, 255 + i);
       End;
     SetColor(White);
     Line(103, 0, 103, 199);
     Repeat
      W.BkGColour := Red;
      W.PenColour := White;
      W.HardWrite(3, Pred(Y) * 6 + 3, Li.Get(Y + MY));
      Kbd.GetKey;
      W.PenColour := 125;
      W.BkGColour := LightBlue;
      W.HardWrite(3, Pred(Y) * 6 + 3, Li.Get(Y + MY));
      Case Kbd.Press Of

        UpKey: If (Y = 1) Then
                 Begin;
                   If (MY > 0) Then
                     Begin;
                       Dec(MY);
                       For i := 198 DownTo 7 Do
                         Move(Screen [i - 6, 1], Screen [i, 1], 100);
                       Kbd.Clear;
                     End;
                 End
               Else
                 Dec(Y);
        DnKey: If (Y = 33) Then
                 Begin;
                   If (Y + MY < Li.Elements) Then
                     Begin;
                       Inc(MY);
                       For i := 2 To 192 Do
                         Move(Screen [i + 6, 1], Screen [i, 1], 100);
                       Kbd.Clear;
                     End;
                 End
               Else
                 Inc(Y);
        PDKey: Begin;
                 Y := 33;
                 If Y + MY < Li.Elements Then
                     Begin;
                       Inc(MY);
                       For i := 2 To 192 Do
                         Move(Screen [i + 6, 1], Screen [i, 1], 100);
                       Kbd.Clear;
                     End;
               End;
        PUKey: Begin;
                 Y := 1;
                 If (MY > 0) Then
                   Begin;
                     Dec(MY);
                     For i := 198 DownTo 7 Do
                       Move(Screen [i - 6, 1], Screen [i, 1], 100);
                     Kbd.Clear;
                   End;
               End;
          256
           ..
          288: Begin;
                 Y := Kbd.Press - 255;
                 Kbd.NextKey := Enter;
               End;
          ESC: i := 0;
        Enter: Begin;
                 SetFillStyle(SolidFill, LightBlue);
                 Bar(129, 9, 301, 151);
                 Frame3D(128, 8, 302, 152);
                 i := Y + MY;
                 T := Ti.Get(Y + MY);
                 W.BkGColour := LightBlue;
                 Case GetInt(T) Of

                   1: Begin;
                        W.PenColour := Yellow;
                        l := GetInt(T);
                        W.HardWrite(131, 11, 'COST: ' + NumToStr(U^ [l].Cost));
                        If U^ [l].ImpReq <> 0 Then
                          Begin;
                            W.HardWrite(131, 17, 'REQ: ' + UpStr(Imp [U^ [l].ImpReq].Name));
                            oy := 29;
                          End
                        Else
                          oy := 23;
                        W.PenColour := LightCyan;
                        For j := 1 To MaxUBAdvReq Do
                          If UnitBuildAR [j].Pr = l Then
                            Begin;
                              m := UnitBuildAR [j].Ad;
                              W.HardWrite(131, oy, Pad(UpStr(Adv^ [m].Name), ' ', 20)
                                          + ' ' + PadL(NumToStr(UnitBuildAR [j].ScoreReq), ' ', 4)
                                          + PadL(' (' + NumToStr(CivInfo [CivPointer].Knowledge [m]) + ')', ' ', 7));
                              Inc(oy, 6);
                            End;
                        If oy > 23 Then
                          Inc(oy, 6);
                        W.PenColour := White;
                        For j := 1 To MaxUBResReq Do
                          If UnitBuildRR [j].Pr = l Then
                            Begin;
                              m := UnitBuildRR [j].Re;
                              W.HardWrite(131, oy, Pad(UpStr(Res [m].Name), ' ', 20)
                                          + ' ' + PadL(NumToStr(UnitBuildRR [j].Amount), ' ', 3));
                              Inc(oy, 6);
                            End;
                        Inc(oy, 6);
                        W.PenColour := Yellow;
                        With U^ [l] Do
                          Begin;
                            W.HardWrite(131, oy, 'ATT: ' + PadL(NumToStr(Attack), ' ', 2) + '  '
                                               + 'DEF: ' + PadL(NumToStr(Defense), ' ', 2) + '  '
                                               + 'MOV: ' + PadL(NumToStr(MaxMove), ' ', 2) + '  '
                                               + 'CAP: ' + NumToStr(Capacity));
                            Inc(oy, 12);
                            W.PenColour := LightCyan;
                            If ActionCaps AND CarryGoods <> 0 Then
                              Begin;
                                W.HardWrite(131, oy, 'CARRIES GOODS');
                                Inc(oy, 6);
                              End;
                            If ActionCaps AND CarryUnits <> 0 Then
                              Begin;
                                W.HardWrite(131, oy, 'CARRIES UNITS');
                                Inc(oy, 6);
                              End;
                            If ActionCaps AND Diplomacy <> 0 Then
                              Begin;
                                W.HardWrite(131, oy, 'PERFORMS DIPLOMACY');
                                Inc(oy, 6);
                              End;
                            If ActionCaps AND shIrrigated <> 0 Then
                              Begin;
                                W.HardWrite(131, oy, 'IRRIGATES');
                                Inc(oy, 6);
                              End;
                            If ActionCaps AND shRoaded <> 0 Then
                              Begin;
                                W.HardWrite(131, oy, 'MAKES ROADS');
                                Inc(oy, 6);
                              End;
                            If ActionCaps AND shForted <> 0 Then
                              Begin;
                                W.HardWrite(131, oy, 'BUILDS FORTS');
                                Inc(oy, 6);
                              End;
                            If ActionCaps AND shCity <> 0 Then
                              Begin;
                                W.HardWrite(131, oy, 'BUILDS CITIES');
                                Inc(oy, 6);
                              End;
                          End;
                      End;
                   2: Begin;
                        W.PenColour := Yellow;
                        l := GetInt(T);
                        W.HardWrite(131, 11, 'COST: ' + NumToStr(Imp [l].Cost));
                        If Imp [l].ParentImp <> 0 Then
                          Begin;
                            W.HardWrite(131, 17, 'REQ: ' + UpStr(Imp [Imp [l].ParentImp].Name));
                            oy := 29;
                          End
                        Else
                          oy := 23;
                        W.PenColour := LightCyan;
                        For j := 1 To MaxIBAdvReq Do
                          If ImprBuildAR [j].Pr = l Then
                            Begin;
                              m := ImprBuildAR [j].Ad;
                              W.HardWrite(131, oy, Pad(UpStr(Adv^ [m].Name), ' ', 20)
                                          + ' ' + PadL(NumToStr(ImprBuildAR [j].ScoreReq), ' ', 4)
                                          + PadL(' (' + NumToStr(CivInfo [CivPointer].Knowledge [m]) + ')', ' ', 7));
                              Inc(oy, 6);
                            End;
                        If oy > 23 Then
                          Inc(oy, 6);
                        W.PenColour := White;
                        For j := 1 To MaxIBResReq Do
                          If ImprBuildRR [j].Pr = l Then
                            Begin;
                              m := ImprBuildRR [j].Re;
                              W.HardWrite(131, oy, Pad(UpStr(Res [m].Name), ' ', 20)
                                          + ' ' + PadL(NumToStr(ImprBuildRR [j].Amount), ' ', 3));
                              Inc(oy, 6);
                            End;
                        Inc(oy, 6);
                        W.PenColour := Yellow;
                        W.HardWrite(131, oy, 'ALLOWS:');
                        Inc(oy, 6);
                        For j := 1 To MaxResTrans Do
                          If ResX [j].ImpReq = l Then
                            With ResX [j] Do
                              Begin;
                                W.HardWrite(131, oy, ' ' + UpStr(Copy(Res [InR].Name, 1, 15)) + ' > '
                                                   + UpStr(Copy(Res [OutR].Name, 1, 15)));
                                Inc(oy, 6);
                              End;
                        W.HardWrite(131, oy, '---');
                        Inc(oy, 6);
                        If Not Kbd.Pressed Then
                          Begin;
                            Assign(src, DescriptFileName);
                            Reset(src);
                            If Not Kbd.Pressed Then
                              Repeat
                               ReadLn(src, Jk);
                              Until (Jk = UpStr(Imp [l].Name)) Or (EOF(src));
                            W.PenColour := 125;
                            If (Not Kbd.Pressed) And (Not EOF(src)) Then
                              Repeat
                               ReadLn(src, Jk);
                               If (Jk <> '!') And (Not EOF(src)) Then
                                 W.HardWrite(131, oy, UpStr(Jk));
                               Inc(oy, 6);
                              Until (Jk = '!') Or (EOF(src));
                            Close(src);
                          End;
                      End;

                 End;
               End;

      End;
     Until (i = 0);
     Li.Done;
     Ti.Done;
   End;

 Procedure _Game.NewDiscoveries;

   Var
      a      : Word;

   Begin;
     For a := 1 To MaxUBAdvReq Do
       With UnitBuildAR [a] Do
         With CivInfo [CP] Do
           If (Ad = ResActivity) And (ScoreReq > b) And (ScoreReq <= Knowledge [ResActivity]) Then
             If CivCanBuildUnit(UnitBuildAR [a].Pr, CP) Then
               N^.AddNotice(NoticeId,
                            nCanProduce, CP,
                            2, UnitBuildAR [a].Pr, 0);
     For a := 1 To MaxIBAdvReq Do
       With ImprBuildAR [a] Do
         With CivInfo [CP] Do
           If (Ad = ResActivity) And (ScoreReq > b) And (ScoreReq <= Knowledge [ResActivity]) Then
             If CivCanBuildImpr(ImprBuildAR [a].Pr, CP) Then
               N^.AddNotice(NoticeId,
                            nCanProduce, CP,
                            1, ImprBuildAR [a].Pr, 0);
   End;

 Procedure _Game.SelectResearch;

   Var
      Li, Ti : StringLList;

      i      : Word;

   Begin;
     With CivInfo [CivPointer] Do
       Begin;
         Li.Init;
         Ti.Init;
         For i := 1 To MaxAdvances Do
           If (Knowledge [i] < Adv^ [i].MaxRes) And (Year >= Adv^ [i].ResYear) Then
             Begin;
               If (i <> CivInfo [CivPointer].ResActivity) Then
                 Li.Add(' ' + Adv^ [i].Name)
               Else
                 Li.Add('*' + Adv^ [i].Name);
               Ti.Add(NumToStr(i));
             End;
         i := Select('RESEARCH..', 20, Li);
         If i <> 0 Then
           Begin;
             ResActivity := StrToInt(Ti.Get(i));
           End;
         Ti.Done;
         Li.Done;
       End;
   End;

 Procedure _Game.CasteMenu;

   Var
      i      : Word;

      Jk     : String;

      P      : Pointer;

   Begin;
     Kbd.IdleProc := NIL;
     P := GetArea(99, 49, 221, 131);
     Repeat
      SetFillStyle(SolidFill, LightGray);
      Bar(100, 50, 220, 130);
      FrameReverse3D(99, 49, 221, 131);
      W.PenColour := LightCyan;
      W.BkGColour := Black;
      W.ShadowWrite(145, 53, 'CASTES');
      W.PenColour := White;
      W.BkGColour := DarkGray;
      W.ShadowWrite(105, 64, 'CASTE       BONUS  RANK');
      For i := 1 To MaxCastes Do
        Begin;
          W.PenColour := DarkGray;
          W.BkGColour := White;
          Case i Of

            1: Jk := 'WARRIORS     ';
            2: Jk := 'MERCHANTS    ';
            3: Jk := 'SCHOLARS     ';
            4: Jk := 'ARTISANS     ';
            5: Jk := 'PEASANTS     ';

          End;
          If CivInfo [CivPointer].CasteRank [i] < 4 Then
            Jk := Jk + PadL(NumToStr(CivInfo [CivPointer].CasteBonus [i]), ' ', 3) + '%'
          Else
            Jk := Jk + '  - ';
          Jk := Jk + '   (' + NumToStr(CivInfo [CivPointer].CasteRank [i]) + ')';
          W.WkShadowWrite(105, 67 + i * 6, Jk);
        End;
      Kbd.ClearAreas;
      BWButton(110, 110, 'F9: CHANGE ORDERING', F9);
      BWButton(160, 120, 'ESC: EXIT', ESC);
      Kbd.GetKey;
      Case Kbd.Press Of

        F9: Begin;
              Jk := Request('ENTER NEW ORDERING', 5, 'WMSAP'#27);
              If Length(Jk) = 5 Then
                Begin;
                  For i := 1 To 5 Do
                    Case Jk [i] Of

                      'W': CivInfo [CivPointer].CasteRank [caWarriors] := i;
                      'M': CivInfo [CivPointer].CasteRank [caMerchants] := i;
                      'S': CivInfo [CivPointer].CasteRank [caScholars] := i;
                      'A': CivInfo [CivPointer].CasteRank [caArtisans] := i;
                      'P': CivInfo [CivPointer].CasteRank [caPeasants] := i;

                    End;
                  CivInfo [CivPointer].NLP := -3;
                  FillChar(CivInfo [CivPointer].CasteBonus, SizeOf(CivInfo [CivPointer].CasteBonus), 0);
                End;
            End;

      End;
     Until (Kbd.Press = ESC);
     PutArea(P);
   End;

 Procedure _Game.ScienceMenu;

   Var
      Li, Ti : StringLList;

      i, j, m: Word;

      Ch     : Char;

   Begin;
     Kbd.IdleProc := NIL;
     Li.Init;
     Li.Add('Change Research Topic..');
     Li.Add('List Benefits of..');
     Li.Add('List Requirements for..');
     Li.Add('Buy Knowledge');
     If CivInfo [CivPointer].ScienceCity = 0 Then
       Li.Add('Appoint Centre of Learning..')
     Else
       Li.Add('Clear Centre of Learning');
     Li.Add('Suspend Research');
     i := Select('RESEARCH..', 28, Li);
     Li.Done;
     Case i Of

       4: If CivInfo [CivPointer].ResActivity <> 0 Then
            Begin;
              j := StrToInt(Request('AMOUNT TO SPEND', 3, '0123456789'));
              With CivInfo [CivPointer] Do
                If (j <= Wealth) And
                (Adv^ [ResActivity].MaxRes >= (j DIV 2) + Knowledge [ResActivity]) Then
                Begin;
                  Dec(CivInfo [CivPointer].Wealth, j);
                  m := Knowledge [ResActivity];
                  Inc(Knowledge [ResActivity], j DIV 2);
                  NewDiscoveries(m, CivPointer);
                End;
            End;
       5: If CivInfo [CivPointer].ScienceCity > 0 Then
            CivInfo [CivPointer].ScienceCity := -3
          Else
            If CivInfo [CivPointer].ScienceCity = 0 Then
              Begin;
                Li.Init;
                Ti.Init;
                j := 0;
                For i := 1 To MaxCitiesUsed Do
                  If (C [i]^.Owner = CivPointer) And (j < 30) Then
                    Begin;
                      Li.Add(CN^.ExpandStr(C [i]^.NameIdx, C [i]^.NameLen));
                      Ti.Add(NumToStr(i));
                      Inc(j);
                    End
                  Else
                    If (C [i]^.Owner = CivPointer) Then
                      j := 31;
                If j = 31 Then
                  Begin;
                    Li.Add('MORE..');
                    j := StrToInt(Ti.Get(29));
                  End;
                i := Select('APPOINT', 20, Li);
                Li.Done;
                If i = 30 Then
                  Begin;
                    Ti.Done;
                    Li.Init;
                    Ti.Init;
                    m := 0;
                    For i := j To MaxCitiesUsed Do
                      If (C [i]^.Owner = CivPointer) And (m < 30) Then
                        Begin;
                          Li.Add(CN^.ExpandStr(C [i]^.NameIdx, C [i]^.NameLen));
                          Ti.Add(NumToStr(i));
                          Inc(m);
                        End;
                    i := Select('APPOINT', 20, Li);
                    If i = 0 Then
                      Exit;
                    i := StrToInt(Ti.Get(i));
                    Li.Done;
                    Ti.Done;
                  End
                Else
                  Begin;
                    If i = 0 Then
                      Exit
                    Else
                      i := StrToInt(Ti.Get(i));
                    Ti.Done;
                  End;
                CivInfo [CivPointer].ScienceCity := i;
              End;
       6: CivInfo [CivPointer].ResActivity := 0;
       1: SelectResearch;
       2: Begin;
            Li.Init;
            For i := 1 To MaxAdvances Do
              If (i <> CivInfo [CivPointer].ResActivity) Then
                Li.Add(' ' + Adv^ [i].Name)
              Else
                Li.Add('*' + Adv^ [i].Name);
            i := Select('BENEFITS OF..', 20, Li);
            Li.Done;
            If i <> 0 Then
              Begin;
                Li.Init;
                For m := 1 To Adv^ [i].MaxRes Do
                  Begin;
                    If CivInfo [CivPointer].Knowledge [i] >= m Then
                      Ch := '*'
                    Else
                      Ch := ' ';
                    For j := 1 To MaxIBAdvReq Do
                      With ImprBuildAR [j] Do
                        If (Ad = i) And (ScoreReq = m) Then
                          Li.Add(Ch + Pad(NumToStr(ScoreReq) + ' ' + Imp [Pr].Name, ' ', 25));
                    For j := 1 To MaxUBAdvReq Do
                      With UnitBuildAR [j] Do
                        If (Ad = i) And (ScoreReq = m) Then
                          Li.Add(Ch + Pad(NumToStr(ScoreReq) + ' ' + U^ [Pr].Name, ' ', 25));
                  End;
                Select(UpStr(Adv^ [i].Name), 26, Li);
                Li.Done;
              End;
          End;
       3: Begin;
            Requirements;
            ClearPlayField;
            DrawPlayField;
          End;

     End;
   End;

 Function _Game.EnemyUnits;

   Var
      i, j   : Word;

   Begin;
     EnemyUnits := False;
     For i := x - 1 To x + 1 Do
       For j := y - 1 To y + 1 Do
         Case Map.ShadowGet(i, j) AND (shUnit OR shCity) Of

           shUnit: If (PointUnit(LocateUnit(i, j, 0))^.Owner <> o) Then
                     Begin;
                       EnemyUnits := True;
                       Exit;
                     End;
           shUnit OR shCity,
           shCity: If (C [LocateCity(i, j)]^.Owner <> o) Then
                     Begin;
                       EnemyUnits := True;
                       Exit;
                     End;

         End;
   End;

 Function _Game.CalculatePrice;

   Var
      i, j, l     : Word;

   Begin;
     l := 0;
     If Hi(ResD) <= MaxRawResources Then
       With C [ci]^ Do
         For i := x - 1 To x + 1 Do
           For j := y - 1 To y + 1 Do
             Begin;
               l := l + Map.TerGet(i, j)^.ResourceYield [Hi(ResD)];
               If (Hi(ResD) = rFood) And (Map.ShadowGet(i, j) AND shIrrigated <> 0) Then
                 l := l + Round(Map.TerGet(i, j)^.ResourceYield [Hi(ResD)] * 0.5 + 0.49);
             End;
     Case Hi(ResD) Of

            rFood: l := Round((54 - l) * 0.5);
          rTimber: l := Round((40 - l) * 1);
          rBronze: l := Round((6 - l) * 10);
            rIron: l := Round((6 - l) * 13);
           rStone: l := Round((45 - l) * 0.75);
            rSalt: l := Round((12 - l) * 8);
            rGold: l := Round((3 - l) * 50);
           rSpice: l := Round((9 - l) * 13);
      rWildHorses: l := Round((9 - l) * 10);
   rWildElephants: l := Round((4 - l) * 30);
   rTrndElephants: l := 60 * 4;
       rWarHorses: l := 40 * 9;
     rFlintDagger: l := 1 * 40;
        rFlintBow: l := Round(1.5 * 40);
      rFlintSpear: l := 2 * 40;
      rFlintSword: l := Round(2.5 * 40);
    rBronzeDagger: l := 3 * 40;
       rBronzeBow: l := Round(3.5 * 40);
     rBronzeSpear: l := 4 * 40;
     rBronzeSword: l := Round(4.5 * 40);
      rIronDagger: l := 5 * 40;
         rIronBow: l := Round(5.5 * 40);
       rIronSpear: l := 6 * 40;
       rIronSword: l := Round(6.5 * 40);
      rTrndHorses: l := 20 * 9;
           rTools: l := 100;

     End;
     l := Round(l * (Lo(ResD) / 100));
     CalculatePrice := Round(l * (1 + CivInfo [C [ci]^.Owner].CasteBonus [caMerchants] / 100));
   End;

 Function _Game.AttackPreparations;
   Begin;
     If Un [UnitPointer].Status AND stGotoing <> 0 Then
       Begin;
         AttackPreparations := False;
         Exit;
       End;
     If Request(UpStr('Are you sure?'), 1, 'YN') = 'Y' Then
       AttackPreparations := True
     Else
       AttackPreparations := False;
   End;

 Function _Game.LocateUnitDiscriminative;

   Var
      i, j        : Word;

   Begin;
     i := 0;
     j := 0;
     Repeat
      Repeat
       Inc(i);
      Until ((Un [i].x = fx) And (Un [i].y = fy)) Or (i > MaxUnitsUsed);
      If (i <= MaxUnitsUsed) And ((U^ [Un [i].UType].ActionCaps AND CarryUnits = 0) = Disc) And (j = 0) Then
        j := i;
     Until (i > MaxUnitsUsed) Or ((U^ [Un [i].UType].ActionCaps AND CarryUnits <> 0) = Disc);
     If (i > MaxUnitsUsed) And (j <> 0) Then
       LocateUnitDiscriminative := j
     Else
       LocateUnitDiscriminative := i;
   End;

 Procedure _Game.RemoveUnit;
   Begin;
     If LocateUnit(x, y, 0) > MaxUnitsUsed Then
       Map.ShadowClear(x, y, shUnit);
   End;

 Procedure _Game.KillUnit;

   Var
      b, e, f,
      bx, by,
      i, j   : Word;

      BkUp   : Array [0..15, 0..15] Of Byte;

   Begin;
     bx := Un [ui].x;
     by := Un [ui].y;
     If Show Then
       With Un [ui] Do
         Begin;
           x := (x - SX) SHL 4;
           y := (y - SY) SHL 4;
           If Random(100) < 50 Then
             Begin;
               b := 61;
               e := 66;
               f := 3;
             End
           Else
             Begin;
               b := 67;
               e := 71;
               f := 6;
             End;
           For j := b To e Do
             Begin;
               For i := y To y + 15 Do
                 Move(Screen [i, x], BkUp [i - y], 16);
               U^ [j].Display(x, y, 0, NIL);
               Delay(UnitMoveDelay * f);
               For i := y To y + 15 Do
                 Move(BkUp [i - y], Screen [i, x], 16);
             End;
         End;
       UM^.ClearUnitInfo(CivInfo [Un [ui].Owner].BlockId, ui);
       Un [ui].x := 0;
       Un [ui].y := 0;
       RemoveUnit(bx, by);
       FillChar(Un [ui], SizeOf(GameUnit), 0);
   End;

 Function _Game.LocateCity;

   Var
      i      : Word;

   Begin;
     i := 0;
     Repeat
      Inc(i);
     Until ((C [i] <> NIL) And (C [i]^.x = fx) And (C [i]^.y = fy)) Or (i > MaxCitiesUsed);
     LocateCity := i;
   End;

 Procedure _Game.InitialOrders;

   Var
      i      : Word;

   Begin;
     With C [ci]^ Do
       Begin;
         i := UM^.Locate(CivInfo [Owner].BlockId, ci OR uCityProdEvent, 0);
         If i > UM^.MaxUsed Then
           Exit;
         With UM^.Block [i] Do
           Case Data [1] Of

                    cpeSentry: Un [ui].Status := stSentried;
                   cpeFortify: Un [ui].Status := stFortified;
                      cpeGoto,
             cpeGotoAndSentry: If C [Data [2]]^.Owner = Owner Then
                                 Begin;
                                   If Data [1] = cpeGoto Then
                                     Un [ui].Status := stGotoing
                                   Else
                                     Un [ui].Status := stGotoingAndSentry;
                                   UM^.AddUnitInfo(CivInfo [Owner].BlockId,
                                                   ui, uGoTo,
                                                   C [Data [2]]^.X,
                                                   C [Data [2]]^.Y,
                                                   0);
                                 End;

           End;
       End;
   End;

 Procedure _Game.Massacre;

   Var
      Eth    : Array [1..MaxCivilizations] Of Word;

      i, j   : Word;

   Begin;
     With C [ci]^ Do
       Begin;
         For i := 1 To MaxCivilizations Do
           Eth [i] := Round(EthnicDist [i] * (Population / 100));
         If No Then
           N^.AddNotice(CivInfo [m].NoticeId,
                        nMassacred, Owner,
                        m, ci, 0);
         If Eth [m] >= 10 Then              {* VICTIMS *}
           Begin;
             Dec(Eth [m], 10);
             Dec(Population, 10);
           End
         Else
           If Eth [m] > 0 Then
             Begin;
               Dec(Population, Eth [m]);
               Eth [m] := 0;
             End
         Else
           Begin;
             i := 0;
             Repeat
              i := LocateUnit(x, y, i);
              If i <= MaxUnitsUsed Then
                AttackUnit(0, i, False, False);
             Until (i > MaxUnitsUsed);
             Exit;
           End;
         If Eth [m] >= 10 Then             {* REFUGEES *}
           Begin;
             CreateRefugees(ci, m, a);
             Dec(Population, 10);
             Dec(Eth [m], 10);
           End;
         If Eth [m] >= 10 Then             {* PARTISANS *}
           Begin;
             CreatePartisans(ci, m, a);
             Dec(Eth [m], 10);
             Dec(Population, 10);
           End;
         j := 0;
         For i := 1 To MaxCivilizations Do
           Inc(j, Eth [i]);
         For i := 1 To MaxCivilizations Do
           EthnicDist [i] := Round(Eth [i] / (j / 100));
       End;
   End;

 Function _Game.EthnicUnrest;

   Var
      Eth    : Array [1..MaxCivilizations] Of Word;

      Largest,
      Second : Byte;

      i, j   : Word;

   Begin;
     EthnicUnrest := False;
     With C [ci]^ Do
       Begin;
         Largest := 1;
         Eth [1] := EthnicDist [1];
         For i := 2 To MaxCivilizations Do
           Begin;
             If (EthnicDist [i] > EthnicDist [Largest]) Then
               Largest := i;
             Eth [i] := EthnicDist [i];
           End;
         Case Improv AND (_imShrine OR _imTemple OR _imTempleComplex OR _imMainTemple) Of

                     _imShrine: Eth [Largest] := Round(Eth [Largest] * 1.25);
                     _imShrine
                  OR _imTemple: Eth [Largest] := Round(Eth [Largest] * 1.5);
                     _imShrine
                  OR _imTemple
           OR _imTempleComplex: Eth [Largest] := Round(Eth [Largest] * 2);
                     _imShrine
                  OR _imTemple
           OR _imTempleComplex
              OR _imMainTemple: Eth [Largest] := Round(Eth [Largest] * 3);

         End;
         i := 0;
         Repeat
          i := LocateUnit(x, y, i);
          If i <= MaxUnitsUsed Then
            If U^ [Un [i].UType].ActionCaps = 0 Then
              Case Un [i].UType Of

                 5
                ..
                40: Eth [Owner] := Eth [Owner] + 50;
                42
                ..
                44,
                53: Eth [Owner] := Eth [Owner] + 20;

              End;
         Until (i > MaxUnitsUsed);
         Largest := 0;
         Second := 0;
         j := 0;
         For i := 1 To MaxCivilizations Do
           Begin;
             If (Largest = 0) Or (Eth [i] > Eth [Largest]) Then
               Begin;
                 Second := Largest;
                 Largest := i;
               End;
             Inc(j, Eth [i]);
           End;
         If (Second = 0) Then
           Begin;
             Second := Largest + 1;
             For i := Largest + 1 To MaxCivilizations Do
               If (Eth [i] > Eth [Second]) Then
                 Second := i;
           End;
         Eth [Largest] := Round((Eth [Largest] / j) * 100);
         If (Eth [Largest] >= 66) Then
           Begin;
             If Owner <> Largest Then
               Begin;
                 N^.AddNotice(CivInfo [CivPointer].NoticeId,
                              nCityReverted, Largest,
                              ci, 0, 0);
                 N^.AddNotice(CivInfo [Largest].NoticeId,
                              nCityReverted, Largest,
                              ci, 0, 0);
                 i := LocateUnit(x, y, 0);
                 If i <= MaxUnitsUsed Then
                   AttackUnit(0, i, False, KillEmAll);
                 Owner := Largest;
                 EthnicUnrest := True;
               End;
           End
         Else
           If (EthnicDist [Largest] > 0) And (EthnicDist [Second] > 0) Then
             Begin;
               N^.AddNotice(CivInfo [Owner].NoticeId,
                            nEthnicUnrest, Owner,
                            ci, Largest, Second);
               Eth [Second] := Round((Eth [Second] / j) * 100);
               i := Succ(Random(Eth [Largest] + Eth [Second]));
               If i < Eth [Largest] Then
                 Massacre(ci, Second, Largest, True)
               Else
                 Massacre(ci, Largest, Second, True);
               EthnicUnrest := True;
             End;
       End;
   End;

 Function _Game.AttackUnit;

   Var
      i, j        : Word;

   Begin;
     If atui > 0 Then
       Begin;
         i := U^ [PointUnit(atui)^.UType].Attack;
         j := Un [atui].Owner;
         With CivInfo [j] Do
           i := Round(i * (1 + (CasteBonus [caWarriors] / 100)));
       End
     Else
       i := $FF00;
     With PointUnit(dfui)^ Do
       Begin;
         j := U^ [UType].Defense;
         If Status = stFortified Then
           j := (j * 15) DIV 10;
         j := (j * Map.GetDefenseBonus(x, y)) DIV 10;
         Case Map.ShadowGet(x, y) AND (shCity OR shForted) Of

             shCity: Case C [LocateCity(x, y)]^.Improv AND
                     (impStockage OR impEarthenRamp OR impCityWalls OR impFortification) Of

                            impStockage: j := (j * 15) DIV 10;
                         impEarthenRamp: j := (j * 20) DIV 10;
                           impCityWalls: j := (j * 25) DIV 10;
                       impFortification: j := (j * 30) DIV 10;

                     End;
           shForted: j := (j * 30) DIV 10;

         End;
       End;
     If (Random(i + j) < i) Or (i = $FF00) Then
       Begin;
         AttackUnit := 1;
         If i <> $FF00 Then
           With Un [dfui] Do
             N^.AddNotice(CivInfo [Owner].NoticeId,
                          nUnitKilled,
                          Un [atui].Owner,
                          UType, X, Y);
         If kea Then
           Begin;
             i := 0;
             Repeat
              With PointUnit(dfui)^ Do
                i := LocateUnit(x, y, i);
              If (i <> dfui) And (i <= MaxUnitsUsed) Then
                KillUnit(i, False);
             Until (i > MaxUnitsUsed);
           End;
         KillUnit(dfui, Show);
       End
     Else
       Begin;
         AttackUnit := 2;
         KillUnit(atui, Show);
       End;
   End;

 Function _Game.PointUnit;
   Begin;
     PointUnit := @Un [ui];
   End;

 Function _Game.PlaceUnit;

   Var
      Jk          : String [2];

      a           : Word;

      i, j, l, m  : Integer;

   Begin;
     l := Pow [Map.TerGet(nx, ny)^.TCtype];
     If (l AND U^ [Un [ui].UType].TerrainCaps = 0) And (U^ [Un [ui].UType].ActionCaps AND CarryGoods = 0)
     And (U^ [Un [ui].UType].ActionCaps AND CarryUnits = 0) Then
       Begin;
         i := LocateUnit(nx, ny, 0);
         If (i <= MaxUnitsUsed) And (Un [i].Owner <> Un [ui].Owner) Then
           Begin;
             If (U^ [Un [ui].UType].TerrainCaps AND (tCoast OR tOcean) = 0)
             And (Pow [Pred(Map.TerGet(nx, ny)^.TCtype)] OR (tCoast OR tOcean) <> 0) And (Un [ui].Status = stTransported) Then
               Begin;
                 i := 0;
                 Repeat
                  i := LocateUnit(nx, ny, i);
                 Until (U^ [Un [i].UType].TerrainCaps AND (2 + 3) <> 0) Or (i > MaxUnitsUsed);
                 If i > MaxUnitsUsed Then
                   Begin;
                     PlaceUnit := 0;
                     Exit;
                   End
                 Else
                   Begin;
                     j := 0;
                     Repeat
                      j := LocateUnit(nx, ny, j);
                     Until (U^ [Un [j].UType].TerrainCaps AND (tCoast OR tOcean) = 0) Or (j > MaxUnitsUsed);
                     If (j <= MaxUnitsUsed) Then
                       Begin;
                         i := AttackUnit(ui, j, Show, KillOnly1);
                         PlaceUnit := i;
                         Exit;
                       End
                     Else
                       Begin;
                         N^.AddNotice(CivInfo [CivPointer].NoticeId,
                                      nShipTaken, Un [ui].Owner,
                                      Un [i].UType, Un [i].x, Un [i].y);
                         Un [i].Owner := Un [ui].Owner;
                         Un [ui].x := Un [i].x;
                         Un [ui].y := Un [i].y;
                       End;
                   End;
               End;
             Exit;
           End
         Else
           Begin;
             i := 0;
             j := 0;
             Repeat
              i := LocateUnit(nx, ny, i);
              If i <= MaxUnitsUsed Then
                With U^ [Un [i].UType] Do
                  If (ActionCaps AND CarryUnits <> 0) And (Un [i].Owner = Un [ui].Owner) Then
                    Inc(j, Capacity)
                  Else
                    If (l AND TerrainCaps = 0) Then
                      Dec(j);
             Until (i > MaxUnitsUsed);
             If j <= 0 Then
               Begin;
                 PlaceUnit := 0;
                 Exit;
               End
             Else
               With Un [ui] Do
                 Begin;
                   Status := stSentried;
                   x := nx;
                   y := ny;
                   MovesLeft := 0;
                   PlaceUnit := 0;
                   Exit;
                 End;
           End;
       End
     Else
       If (l AND U^ [Un [ui].UType].TerrainCaps = 0) And (Map.ShadowGet(nx, ny) AND shCity = 0) Then
         Begin;
           PlaceUnit := 0;
           Exit;
         End;
     If (U^ [Un [ui].UType].ActionCaps AND (CarryGoods OR Diplomacy) = 0) And (Un [ui].UType <> 2) Then
       Case Map.ShadowGet(nx, ny) AND (shUnit OR shCity) Of

         shUnit: Begin;
                   m := LocateUnitDiscriminative(nx, ny, DiscrNonCarriers);
                   If (l AND U^ [Un [ui].UType].TerrainCaps <> 0)
                       And (Un [m].Owner <> Un [ui].Owner) Then
                      Begin;
                        If AttackPreparations Then
                          Begin;
                            If (U^ [Un [m].UType].ActionCaps AND CarryGoods <> 0) Then
                              Begin;
                                j := 0;
                                Repeat
                                 j := LocateUnit(nx, ny, j);
                                Until (j <> m);
                                If j > MaxUnitsUsed Then
                                  Begin;
                                    i := UM^.Locate(CivInfo [Un [m].Owner].BlockId,
                                                    m OR uGoods, 0);
                                    With UM^.Block [i] Do
                                      UM^.AddUnitInfo(CivInfo [Un [ui].Owner].BlockId,
                                                      m, uGoods,
                                                      Data [1],
                                                      Data [2],
                                                      Data [3]);
                                    UM^.ClearUnitInfo(CivInfo [Un [m].Owner].BlockId, m);
                                    N^.AddNotice(CivInfo [Un [m].Owner].NoticeId,
                                                 nCaravanRobbed, Un [ui].Owner,
                                                 nx, ny, Un [m].UType);
                                    Un [m].Owner := Un [ui].Owner;
                                    PlaceUnit := 1;
                                    Exit;
                                  End;
                              End;
                            PlaceUnit := AttackUnit(ui, LocateUnitDiscriminative(nx, ny, DiscrNonCarriers), Show, KillEmAll);
                          End;
                        Exit;
                      End
                    Else
                      If (l AND U^ [Un [ui].UType].TerrainCaps = 0) Then
                        Begin;
                          PlaceUnit := 0;
                          Exit;
                        End;
                 End;
         shCity: If (C [LocateCity(nx, ny)]^.Owner <> Un [ui].Owner) Then
                   Begin;
                     If (l AND U^ [Un [ui].UType].TerrainCaps <> 0)
                       And (U^ [Un [ui].UType].TerrainCaps AND 1 = 1)
                       And (U^ [Un [ui].UType].ActionCaps = 0)
                       And (AttackPreparations) Then
                       Begin;
                         PlaceUnit := 3;
                         j := LocateCity(nx, ny);
                         If j = CivInfo [C [j]^.Owner].ScienceCity Then
                           With CivInfo [C [j]^.Owner] Do
                             ScienceCity := -3;
                         i := (C [j]^.Population DIV CivInfo [C [j]^.Owner].Population) * CivInfo [C [j]^.Owner].Wealth;
                         Dec(CivInfo [C [j]^.Owner].Wealth, i);
                         Inc(CivInfo [Un [ui].Owner].Wealth, i);
                         N^.AddNotice(CivInfo [C [j]^.Owner].NoticeId,
                                      nCityTaken, Un [ui].Owner,
                                      j, i, 0);
                         i := C [j]^.Owner;
                         Massacre(j, i, CivPointer, False);
                         C [j]^.Owner := Un [ui].Owner;
                         ChkEn := False;
                       End
                     Else
                       Begin;
                         PlaceUnit := 0;
                         Exit;
                       End;
                   End
                 Else
                   If (U^ [Un [ui].UType].TerrainCaps AND tOcean <> 0)
                   And (C [LocateCity(nx, ny)]^.Improv AND (_imDocks OR _imShipYard OR _imGreatShipYard) = 0) Then
                     Begin;
                       PlaceUnit := 0;
                       Exit;
                     End;
         shUnit OR
         shCity: If (C [LocateCity(nx, ny)]^.Owner <> Un [ui].Owner) And (l AND U^ [Un [ui].UType].TerrainCaps <> 0) Then
                   Begin;
                     If (AttackPreparations) Then
                       Begin;
                         PlaceUnit := AttackUnit(ui, LocateUnitDiscriminative(nx, ny, DiscrCarriers), Show, KillOnly1);
                         Exit;
                       End
                     Else
                       Begin;
                         PlaceUnit := 0;
                         Exit;
                       End;
                   End
                 Else
                   If (C [LocateCity(nx, ny)]^.Owner <> Un [ui].Owner) Then
                     Begin;
                       PlaceUnit := 0;
                       Exit;
                     End
                 Else
                   If (U^ [Un [ui].UType].TerrainCaps AND tOcean <> 0)
                   And (C [LocateCity(nx, ny)]^.Improv AND (_imDocks OR _imShipYard OR _imGreatShipYard) = 0) Then
                     Begin;
                       PlaceUnit := 0;
                       Exit;
                     End;

       End
     Else
       Case Map.ShadowGet(nx, ny) AND (shUnit OR shCity) Of

         shCity OR shUnit,
                   shCity: If U^ [Un [ui].UType].ActionCaps AND CarryGoods <> 0 Then
                             Begin;
                               m := LocateCity(nx, ny);
                               If (m <= MaxCitiesUsed) And (C [m]^.Owner <> Un [ui].Owner) Then
                                 Begin;
                                   l := UM^.Locate(CivInfo [Un [ui].Owner].BlockId, ui OR uGoods, 0);
                                   For i := 1 To U^ [Un [ui].UType].Capacity Do
                                     Begin;
                                       UM^.LoadBlock(CivInfo [Un [ui].Owner].BlockId);
                                       a := UM^.Block [l].Data [i];
                                       UM^.LoadBlock(CivInfo [C [m]^.Owner].BlockId);
                                       If a <> 0 Then
                                         Begin;
                                           j := 0;
                                           Repeat
                                            j := UM^.Locate(CivInfo [C [m]^.Owner].BlockId, ui OR uCityTrigger, j);
                                           Until (j > UM^.MaxUsed) Or (UM^.Block [j].Data [1] = a);
                                           If j <= UM^.MaxUsed Then
                                             Begin;
                                               Inc(CivInfo [Un [ui].Owner].Wealth, UM^.Block [j].Data [2]);
                                               Inc(C [m]^.Stores [Hi(a)], Lo(a));
                                               N^.AddNotice(CivInfo [C [m]^.Owner].NoticeId,
                                                            nCaravanArrived, Un [ui].Owner,
                                                            a, UM^.Block [j].Data [2], m);
                                               FillChar(UM^.Block [j], SizeOf(UM^.Block [j]), 0);
                                               UM^.LoadBlock(CivInfo [Un [ui].Owner].BlockId);
                                               UM^.Block [l].Data [i] := 0;
                                             End
                                           Else
                                             Begin;
                                               UM^.LoadBlock(CivInfo [Un [ui].Owner].BlockId);
                                               j := CalculatePrice(UM^.Block [l].Data [i], m);
                                               Jk := Request('MERCHANTS OFFER ' + NumToStr(j)
                                               + ' FOR YOUR ' + NumToStr(Lo(UM^.Block [l].Data [i]))
                                               + ' ' + UpStr(Res [Hi(UM^.Block [l].Data [i])].Name), 1, 'YN'#27);
                                               Case Jk [1] Of

                                                 'Y': Begin;
                                                        Inc(CivInfo [Un [ui].Owner].Wealth, j);
                                                        UM^.Block [l].Data [i] := 0;
                                                        Un [ui].MovesLeft := 0;
                                                      End;

                                               End;
                                             End;
                                         End;
                                     End;
                                   PlaceUnit := 0;
                                   Exit;
                                 End;
                               End
                           Else
                             If (U^ [Un [ui].UType].ActionCaps AND Diplomacy <> 0) Then
                               Begin;
                                 m := LocateCity(nx, ny);
                                 If (m <= MaxCitiesUsed) And (C [m]^.Owner <> Un [ui].Owner) Then
                                   Begin;
                                     i := UM^.Locate(CivInfo [Un [ui].Owner].BlockId,
                                                     ui OR uEmpowerment,
                                                     0);
                                     If (i > UM^.MaxUsed) Then
                                       Begin;
                                         PlaceUnit := 0;
                                         Exit;
                                       End;
                                     Case UM^.Block [i].Data [1] AND $F800 Of

                                     empBuyResources
                                                  ..
                                      empSellDefense: Begin;
                                                        Case UM^.Block [i].Data [1] AND $F800 Of

                                                           empBuyResources: j := nBuyResources;
                                                          empSellResources: Begin;
                                                                              j := nSellResources;
                                                                              UM^.Block [i].Data [1] := m;
                                                                            End;
                                                           empBuyKnowledge: j := nBuyKnowledge;
                                                          empSellKnowledge: j := nSellKnowledge;
                                                            empDemandMoney: j := nDemandMoney;
                                                              empGiveMoney: j := nGiveMoney;
                                                          empBuyRetraction: j := nBuyRetraction;
                                                         empSellRetraction: j := nSellRetraction;
                                                               empBuyPeace: j := nBuyPeace;
                                                              empSellPeace: j := nSellPeace;
                                                              empBuyBoycot: j := nBuyBoycot;
                                                             empSellBoycot: j := nSellBoycot;
                                                             empBuyEmbargo: j := nBuyEmbargo;
                                                            empSellEmbargo: j := nSellEmbargo;
                                                                 empBuyWar: j := nBuyWar;
                                                                empSellWar: j := nSellWar;
                                                             empBuyDefense: j := nBuyDefense;
                                                            empSellDefense: j := nSellDefense;

                                                        End;
                                                        N^.AddNotice(CivInfo [C [m]^.Owner].NoticeId,
                                                                     j,
                                                                     Un [ui].Owner,
                                                                     UM^.Block [i].Data [1] AND 2047,
                                                                     UM^.Block [i].Data [2],
                                                                     UM^.Block [i].Data [3]);
                                                      End;
                                          empMessage: N^.AddNotice(CivInfo [C [m]^.Owner].NoticeId,
                                                                   nMessage,
                                                                   Un [ui].Owner,
                                                                   UM^.Block [i].Data [1] AND 2047,
                                                                   UM^.Block [i].Data [2],
                                                                   m);
                                        empModThreat: N^.AddNotice(CivInfo [C [m]^.Owner].NoticeId,
                                                                   nModThreat,
                                                                   Un [ui].Owner,
                                                                   UM^.Block [i].Data [1] AND 2047,
                                                                   0,
                                                                   m);
                                        empVioThreat: N^.AddNotice(CivInfo [C [m]^.Owner].NoticeId,
                                                                   nVioThreat,
                                                                   Un [ui].Owner,
                                                                   UM^.Block [i].Data [1] AND 2047,
                                                                   0,
                                                                   m);
                                       empDeclareWar:  N^.AddNotice(CivInfo [C [m]^.Owner].NoticeId,
                                                                   nDeclareWar,
                                                                   Un [ui].Owner,
                                                                   UM^.Block [i].Data [1] AND 2047,
                                                                   0,
                                                                   m);

                                     End;
                                     FillChar(UM^.Block [i], SizeOf(UM^.Block [i]), 0);
                                     If i = UM^.MaxUsed Then
                                       Dec(UM^.MaxUsed);
                                     Un [ui].MovesLeft := 0;
                                     PlaceUnit := 0;
                                     Exit;
                                   End;
                               End
                           Else
                             Begin;
                               m := LocateCity(nx, ny);
                               If (m <= MaxCitiesUsed) Then
                                 Begin;
                                   i := UM^.Locate(CivInfo [Un [ui].Owner].BlockId,
                                                   ui OR uEthnic,
                                                   0);
                                   If (m <> UM^.Block [i].Data [1]) Then
                                     Begin;
                                       N^.AddNotice(CivInfo [C [m]^.Owner].NoticeId,
                                                    nRefugeesArrive,
                                                    Un [ui].Owner,
                                                    m,
                                                    UM^.Block [i].Data [2],
                                                    UM^.Block [i].Data [1]);
                                       C [m]^.AddEthnic(Un [ui].Owner, 10);
                                       KillUnit(ui, False);
                                       PlaceUnit := 2;
                                       Exit;
                                     End;
                                   PlaceUnit := 0;
                                   Exit;
                                 End;
                             End;
                   shUnit: Begin;
                             m := LocateUnit(nx, ny, 0);
                             If (m <= MaxUnitsUsed) And (Un [m].Owner <> Un [ui].Owner) Then
                               Begin;
                                 PlaceUnit := 0;
                                 Exit;
                               End;
                           End;

       End;
     PlaceUnit := 0;
     If (ChkEn And EnemyUnits(nx, ny, o)) And (Un [ui].Status <> stTransported)
        And (U^ [Un [ui].UType].ActionCaps AND (Diplomacy OR CarryGoods OR CarryUnits) = 0)
        And (Un [ui].UType <> 2) Then
       Exit;
     With Un [ui] Do
       Begin;
         K^.MakeKnownCircle(CivInfo [Owner].KnownId, nx, ny);
         Map.ShadowSet(nx, ny, shUnit);
         If Status = stTransported Then
           Status := stReady;
         i := 0;
         j := 0;
         If U^ [Un [ui].UType].ActionCaps AND CarryUnits <> 0 Then
           Repeat
            j := LocateUnit(x, y, j);
            If (j <= MaxUnitsUsed) And ((Un [j].Status = stSentried) Or (Un [j].Status = stTransported))
            And (U^ [Un [j].UType].ActionCaps AND CarryUnits = 0) Then
              Begin;
                Un [j].x := nx;
                Un [j].y := ny;
                Inc(i);
              End;
           Until (j > MaxUnitsUsed) Or (i = U^ [UType].Capacity);
         x := nx;
         y := ny;
       End;
   End;

 Function _Game.LocateUnit;

   Var
      i           : Word;

   Begin;
     i := ofs;
     Repeat
      Inc(i);
     Until ((Un [i].x = fx) And (Un [i].y = fy)) Or (i > MaxUnitsUsed);
     LocateUnit := i;
   End;

 Function _Game.AddUnit;

   Var
      i           : Word;

   Begin;
     i := LocateUnit(0, 0, 0);
     If i > MaxUnitsUsed Then
       MaxUnitsUsed := i;
     PointUnit(i)^.Init(nx, ny, ut, o);
     PlaceUnit(i, nx, ny, o, False, False);
     If U^ [ut].ActionCaps AND CarryGoods <> 0 Then
       UM^.AddUnitInfo(CivInfo [o].BlockId, i, uGoods, 0, 0, 0);
     AddUnit := i;
   End;

 Procedure _Game.CreateRefugees;

   Var
      i, j, l     : Integer;

   Begin;
     With C [ci]^ Do
       Begin;
         For i := x - 1 To x + 1 Do
          For j := y - 1 To y + 1 Do
            If (Map.ShadowGet(i, j) AND (shUnit OR shCity) = 0)
            And (i - x + 2 * (j - y) <> 0)
            And (Random(30) < 20) Then
              Case Pow [Map.TerGet(i, j)^.TCType] Of

                    tFlat,
                   tRiver,
                   tRough,
                tMountains: Begin;
                              AddUnit(i, j, 2, o);
                              l := LocateUnit(i, j, 0);
                              UM^.AddUnitInfo(CivInfo [o].BlockId, l, uEthnic, ci, a, 0);
                              i := x + 1;
                              j := y + 1;
                            End;

              End;
       End;
   End;

 Procedure _Game.CreatePartisans;

   Var
      S2,
      Sur    : Array [-6..6, -6..6] Of Word;

      xl, yl,
      i, j,
      l, m   : Integer;

   Begin;
     With C [ci]^ Do
       For i := -5 To 5 Do
         For j := - 5 To 5 Do
           Begin;
             Sur [i, j] := 0;
             If (Map.ShadowGet(x + i, y + j) AND (shUnit OR shCity) = 0) Then
             For l := -1 To 1 Do
               For m := -1 To 1 Do
                 Case Pow [Map.TerGet(x + i + l, y + j + m)^.TCType] Of

                       tFlat,
                       tRiver: Inc(Sur [i, j], 10);
                       tRough: Inc(Sur [i, j], 15);
                   tMountains: Inc(Sur [i, j], 30);

                 End;
             Case Pow [Map.TerGet(x + i, y + j)^.TCType] Of

               tOcean,
               tCoast: Sur [i, j] := 0;

             End;
           End;
     For i := -5 To 5 Do
       For j := - 5 To 5 Do
         Begin;
           S2 [i, j] := 0;
           For l := -1 To 1 Do
             For m := -1 To 1 Do
               Inc(S2 [i, j], Sur [i + l, j + m]);
         End;
     S2 [0, 0] := 0;
     l := -6;
     m := -6;
     S2 [l, m] := 0;
     For i := -5 To 5 Do
       For j := -5 To 5 Do
         If S2 [i, j] > S2 [l, m] Then
           Begin;
             l := i;
             m := j;
           End;
     With C [ci]^ Do
       If (l > -6) And (Map.ShadowGet(x + l, y + m) AND (shUnit OR shCity) = 0) Then
         Begin;
           AddUnit(x + l, y + m, 41, o);
           i := LocateUnit(x + l, y + m, 0);
           If i <= MaxUnitsUsed Then
             UM^.AddUnitInfo(CivInfo [o].NoticeId, i, uEthnic, ci, a, 0);
         End;
   End;

 Procedure _Game.PanPlayField;
   Begin;
     ClearPlayField;
     SX := X - (PFWidth - 2) DIV 2;
     If Integer(SX) < 1 Then
       SX := 1
     Else
       If SX + PFWidth > RightX Then
         SX := RightX - PFWidth;
     SY := Y - (PFHeight - 2) DIV 2;
     If Integer(SY) < 1 Then
       SY := 1
     Else
       If SY + PFHeight > UpperY Then
         SY := UpperY - PFHeight;
     Kbd.Clear;
   End;

 Procedure _Game.ClearPlayField;
   Begin;
     FillChar(Screen, 320*176, Black);
   End;

 Procedure _Game.DrawPlayField;

   Var
      i, j,
      l, m, o     : Word;

      s           : String;

      b, cc       : Byte;

   Begin;
     cc := 0;
     For i := SX To SX + PFWidth - 1 Do
       For j := SY To SY + PFHeight - 1 Do
         If K^.IsKnown(CivInfo [CivPointer].KnownId, i, j) Then
           Begin;
             b := Map.ShadowGet(i, j);
               If (b AND shCity <> 0) Then
                 Begin;
                   If C [LocateCity(i, j)]^.Improv AND
                      (_imStockage OR _imEarthenRamp OR _imCityWalls OR _imFortification) <> 0 Then
                     Map.Ti^ [133].Display((i - SX) * 16, (j - SY) * 16)
                   Else
                     Map.Ti^ [129].Display((i - SX) * 16, (j - SY) * 16);
                   l := LocateCity(i, j);
                   PFMatrix [Succ(i - SX) + (j - SY) * PFWidth] := l;
                   Inc(cc);
                   W.PenColour := White;
                   W.BkGColour := Black;
                   s := NumToStr(C [l]^.Population);
                   Case Length(s) Of

                     1: W.ShadowWrite((i - SX) * 16 + 6, (j - SY) * 16 + 6, s);
                     2: W.ShadowWrite((i - SX) * 16 + 4, (j - SY) * 16 + 6, s);
                     3: W.ShadowWrite((i - SX) * 16 + 1, (j - SY) * 16 + 6, s);
                     Else
                       W.ShadowWrite((i - SX) * 16 + 1, (j - SY) * 16 + 6, 'BIG');

                   End;
                   W.PenColour := C [l]^.Owner;
                   W.ShadowWrite((i - SX) * 16, (j + 1 - SY) * 16, CN^.ExpandStr(C [l]^.NameIdx, C [l]^.NameLen));
                 End
             Else
               If (b AND shUnit <> 0) Then
                 DisplayUnit(LocateUnitDiscriminative(i, j, DiscrNonCarriers))
             Else
               Map.Display(i, j, (i - SX) * 16, (j - SY) * 16);
           End;
     If cc > 0 Then
       For i := 1 To PFWidth * PFHeight Do
         Begin;
           j := PFMatrix [i];
           If j <> 0 Then
             With C [j]^ Do
               Begin;
                 W.PenColour := CivInfo [Owner].Colour;
                 W.ShadowWrite((X - SX) * 16, (Y + 1 - SY) * 16, CN^.ExpandStr(NameIdx, NameLen));
                 PFMatrix [i] := 0;
               End;
         End;
     If ShowStatus > 0 Then
       DisplayStatus;
   End;

 Procedure _Game.DisplayUnit;
   Begin;
     With Un [Ui] Do
       Begin;
         U^ [UType].Display((X - SX) * 16, (Y - SY) * 16, CivInfo [Owner].Colour, @Map.TiGet(x, y)^.BitMap);
         W.PenColour := CivInfo [Owner].Colour XOR 54;
         W.BkGColour := Black;
         W.ShadowPlot((X - SX) * 16 + 6, (Y - SY) * 16 + 10, StatusChar [Status]);
       End;
   End;

 Procedure _Game.ClearStatus;
   Begin;
     FillChar(Screen [176, 0], 1 * 320, Black);
     FillChar(Screen [177, 0], 1 * 320, White);
     FillChar(Screen [178, 0], 22 * 320, LightGray);
   End;

 Procedure _Game.DisplayStatus;

   Var
      i, j   : Word;

   Begin;
     ClearStatus;
     W.PenColour := White;
     W.BkGColour := DarkGray;
     If UnitPointer > 0 Then
       With Un [UnitPointer] Do
         If U^ [UType].ActionCaps AND CarryGoods = 0 Then
           Begin;
             W.ShadowWrite(10, 180, Pad(UpStr(U^ [UType].Name), ' ', 24) +
                           'MP: ' + Pad(NumToStr(MovesLeft), ' ', 5) +
                           'SUP: ' + Pad(NumToStr(SuppliesLeft), ' ', 4));
             W.ShadowWrite(10, 187, Pad(UpStr(Map.TerGet(X, Y)^.Name), ' ', 24) +
                           'RES: ' + Pad(NumToStr(CivInfo [CivPointer].Knowledge [CivInfo [CivPointer].ResActivity]), ' ', 4));
           End
         Else
           Begin;
             W.ShadowWrite(10, 180, Pad(UpStr(U^ [UType].Name), ' ', 24) +
                                 'MP: ' + Pad(NumToStr(MovesLeft), ' ', 5));
             W.ShadowWrite(10, 187, Pad(UpStr(Map.TerGet(X, Y)^.Name), ' ', 24) +
               'RES: ' + Pad(NumToStr(CivInfo [CivPointer].Knowledge [CivInfo [CivPointer].ResActivity]), ' ', 4));
             W.PenColour := LightCyan;
             i := UM^.Locate(CivInfo [Owner].BlockID, UnitPointer OR uGoods, 0);
             If (i > 0) And (i <= UM^.MaxUsed) Then
               For j := 1 To U^ [UType].Capacity Do
                 W.ShadowWrite(180, 180 + Pred(j) * 7, UpStr(Copy(Res [Hi(UM^.Block [i].Data [j])].Name, 1, 14)));
             W.PenColour := White;
           End
     Else
       Begin;
         W.ShadowWrite(10, 180, 'END OF TURN - PRESS ENTER TO CONTINUE');
         W.ShadowWrite(130, 187,
                       'RES: ' + Pad(NumToStr(CivInfo [CivPointer].Knowledge [CivInfo [CivPointer].ResActivity]), ' ', 4));
       End;
     W.ShadowWrite(10, 194, Pad(UpStr(CivInfo [CivPointer].Name), ' ', 24) +
                         Pad(GetGameDate, ' ', 10) +
                         'WEALTH: ' + Pad(NumToStr(CivInfo [CivPointer].Wealth), ' ', 8));
     If (ShowStatus = 2) And (UnitPointer > 0) Then
       Begin;
         i := 0;
         j := 0;
         Repeat
          With Un [UnitPointer] Do
            i := LocateUnit(x, y, i);
          If (i <> UnitPointer) And (i <= MaxUnitsUsed) Then
            With Un [i] Do
              Begin;
                U^ [UType].Display(259 + j * 20, 180, CivInfo [CivPointer].Colour, NIL);
                W.PenColour := CivInfo [Owner].Colour XOR 54;
                W.BkGColour := Black;
                W.ShadowPlot(259 + j * 20 + 6, 180 + 10, StatusChar [Status]);
                Inc(j);
              End;
         Until (i > MaxUnitsUsed) Or (j = 3);
         With Un [UnitPointer] Do
           If LocateUnit(x, y, i) <= MaxUnitsUsed Then
             Begin;
               SetColor(White);
               Line(259, 198, 315, 198);
             End;
       End;
   End;

 Procedure _Game.SubEmpower;

   Var
      Li, Ti : StringLList;

      i      : Word;

   Begin;
     Case a Of

       1: Begin;
            Li.Init;
            For i := 1 To MaxResources Do
              Li.Add(Res [i].Name);
            b := Select('SELECT RESOURCE', 20, Li) SHL 8;
            Li.Done;
            Repeat
             i := StrToInt(Request('AMOUNT (1..100)', 3, '0123456789'));
            Until (i < 101);
            b := b OR Lo(i);
            d := StrToInt(Request('PRICE', 4, '0123456789'));
          End;
       2: Begin;
            Li.Init;
            For i := 1 To MaxAdvances Do
              Li.Add(Adv^ [i].Name);
            b := Select('SELECT TOPIC', 20, Li) SHL 8;
            Li.Done;
            Repeat
             i := StrToInt(Request('POINTS (1..100)', 3, '0123456789'));
            Until (i < 101);
            b := b OR Lo(i);
            d := StrToInt(Request('PRICE', 4, '0123456789'));
          End;
       3,
       4,
       5,
       9: Begin;
            b := 0;
            d := StrToInt(Request('PRICE', 4, '0123456789'));
          End;
       6: Begin;
            Li.Init;
            Ti.Init;
            For i := 1 To MaxCivilizations Do
              If i <> CivPointer Then
                Begin;
                  Li.Add(CivInfo [i].Name);
                  Ti.Add(NumToStr(i));
                End;
            b := Select('BOYCOT..', 20, Li);
            If b <> 0 Then
              b := StrToInt(Ti.Get(b))
            Else
              b := CivPointer;
            Ti.Done;
            Li.Done;
            d := StrToInt(Request('PRICE', 4, '0123456789'));
          End;
       7: Begin;
            Li.Init;
            Ti.Init;
            For i := 1 To MaxCivilizations Do
              If i <> CivPointer Then
                Begin;
                  Li.Add(CivInfo [i].Name);
                  Ti.Add(NumToStr(i));
                End;
            b := Select('EMBARGO AGAINST..', 20, Li);
            If b <> 0 Then
              b := StrToInt(Ti.Get(b))
            Else
              b := CivPointer;
            Ti.Done;
            Li.Done;
            d := StrToInt(Request('PRICE', 4, '0123456789'));
          End;
       8: Begin;
            Li.Init;
            Ti.Init;
            For i := 1 To MaxCivilizations Do
              If i <> CivPointer Then
                Begin;
                  Li.Add(CivInfo [i].Name);
                  Ti.Add(NumToStr(i));
                End;
            b := Select('WAR AGAINST..', 20, Li);
            If b <> 0 Then
              b := StrToInt(Ti.Get(b))
            Else
              b := CivPointer;
            Ti.Done;
            Li.Done;
            d := StrToInt(Request('PRICE', 4, '0123456789'));
          End;

     End;
   End;

 Procedure _Game.Empower;

   Var
      i, j,
      ci, l, m    : Word;

      Jk          : String;

      Li          : StringLList;

   Begin;
     With Un [UnitPointer] Do
       ci := LocateCity(x, y);
     If ci > MaxCitiesUsed Then
       Exit;
     i := UM^.Locate(CivInfo [Un [UnitPointer].Owner].BlockId, UnitPointer OR uEmpowerment, 0);
     If i <= UM^.MaxUsed Then
       Begin;
         If Request(UpStr('Clear old empowerment?'), 1, 'YN'#27) <> 'Y' Then
           Exit;
         Inc(CivInfo [CivPointer].Wealth, UM^.Block [i].Data [3]);
         If (UM^.Block [i].Data [1] AND $F800 = empMessage) Then
           Msg^.Clear(UM^.Block [i].Data [1] AND 2047);
         FillChar(UM^.Block [i], SizeOf(UM^.Block [i]), 0);
         If i = UM^.MaxUsed Then
           Dec(UM^.MaxUsed);
       End;
     Li.Init;
     Li.Add('Demand/Offer to buy..');
     Li.Add('Give/Offer to sell..');
     Li.Add('Agression..');
     Li.Add('Other message');
     i := Select('EMPOWERMENT TYPE', 21, Li);
     Li.Done;
     Case i Of

       1: Begin;
            Li.Init;
            Li.Add('Resources..');
            Li.Add('Knowledge..');
            Li.Add('Money');
            Li.Add('Retraction of units');
            Li.Add('Peace');
            Li.Add('Boycot of..');
            Li.Add('Embargo against..');
            Li.Add('War against..');
            Li.Add('Mutual defense');
            l := Select('DEMAND/BUY', 19, Li);
            Case l Of

              1: j := empBuyResources;
              2: j := empBuyKnowledge;
              3: j := empDemandMoney;
              4: j := empBuyRetraction;
              5: j := empBuyPeace;
              6: j := empBuyBoycot;
              7: j := empBuyEmbargo;
              8: j := empBuyWar;
              9: j := empBuyDefense;

            End;
            With UM^.Block [i] Do
              Begin;
                SubEmpower(l, i, m);
                If (j <> empDemandMoney) And (CivInfo [CivPointer].Wealth < m) Then
                  OneLiner('YOU DON''T HAVE THAT MUCH MONEY.')
                Else
                  Begin;
                    If j <> empDemandMoney Then
                      Dec(CivInfo [CivPointer].Wealth, m);
                    UM^.AddUnitInfo(CivInfo [Un [UnitPointer].Owner].BlockId,
                                    UnitPointer, uEmpowerment,
                                    ci OR j, i, m);
                  End;
              End;
            Li.Done;
          End;
       2: Begin;
            Li.Init;
            Li.Add('Resources..');
            Li.Add('Knowledge..');
            Li.Add('Money');
            Li.Add('Retraction of units');
            Li.Add('Peace');
            Li.Add('Boycot of..');
            Li.Add('Embargo against..');
            Li.Add('War against..');
            Li.Add('Mutual defense');
            l := Select('GIVE/SELL', 19, Li);
            Case l Of

              1: j := empSellResources;
              2: j := empSellKnowledge;
              3: j := empGiveMoney;
              4: j := empSellRetraction;
              5: j := empSellPeace;
              6: j := empSellBoycot;
              7: j := empSellEmbargo;
              8: j := empSellWar;
              9: j := empSellDefense;

            End;
            With UM^.Block [i] Do
              Begin;
                SubEmpower(l, i, m);
                If (j = empGiveMoney) And (CivInfo [CivPointer].Wealth < m) Then
                  OneLiner('YOU DON''T HAVE THAT MUCH MONEY.')
                Else
                  Begin;
                    If j = empGiveMoney Then
                      Dec(CivInfo [CivPointer].Wealth, m);
                    UM^.AddUnitInfo(CivInfo [Un [UnitPointer].Owner].BlockId,
                                    UnitPointer, uEmpowerment,
                                    ci OR j, i, m);
                  End;
              End;
          End;
       3: Begin;
            Li.Add('Threaten moderately');
            Li.Add('Threaten agressively');
            Li.Add('Declare war');
            i := Select('AGRESSION', 20, Li);
            Case i Of

              1: UM^.AddUnitInfo(CivInfo [Un [UnitPointer].Owner].BlockId,
                                 UnitPointer, uEmpowerment,
                                 ci OR empModThreat, 0, 0);
              2: UM^.AddUnitInfo(CivInfo [Un [UnitPointer].Owner].BlockId,
                                 UnitPointer, uEmpowerment,
                                 ci OR empVioThreat, 0, 0);
              3: UM^.AddUnitInfo(CivInfo [Un [UnitPointer].Owner].BlockId,
                                 UnitPointer, uEmpowerment,
                                 ci OR empDeclareWar, 0, 0);

            End;
            Li.Done;
          End;
       4: Begin;
            Jk := '';
            For i := 32 To 95 Do
              Jk := Jk + Chr(Lo(i));
            Jk := Request('ENTER MESSAGE', 60, Jk);
            i := Msg^.Store(Jk);
            If i = 0 Then
              Begin;
                OneLiner('OUT OF MESSAGE STORAGE SPACE');
                Exit;
              End;
            UM^.AddUnitInfo(CivInfo [Un [UnitPointer].Owner].BlockId,
                            UnitPointer, uEmpowerment,
                            ci OR empMessage, i, 0);
          End;

     End;
   End;

 {$F+}

 Var
    bSX, bSY,
    bX, bY     : Word;

 Procedure BlinkField;
   Begin;
     SetWriteMode(XORPut);
     SetColor(128);
     Rectangle((bX - bSX) * 16, (bY - bSY) * 16, (bX - bSX) * 16 + 15, (bY - bSY) * 16 + 15);
     Kbd.IntDelay(60);
     Rectangle((bX - bSX) * 16, (bY - bSY) * 16, (bX - bSX) * 16 + 15, (bY - bSY) * 16 + 15);
     Kbd.IntDelay(60);
     SetWriteMode(CopyPut);
   End;

 {$F-}

 Function _Game.DecodeUEmp;
   Begin;
     Case empid Of

           empModThreat: DecodeUEmp := ' moderate threat';
           empVioThreat: DecodeUEmp := ' violent threat';
          empDeclareWar: DecodeUEmp := ' declaration of war';
        empBuyResources: DecodeUEmp := ' offer to buy ' + NumToStr(Lo(d2)) + ' ' + Res [Hi(d2)].Name +
                                       ' for ' + NumToStr(d3);
       empSellResources: DecodeUEmp := ' offer to sell ' + NumToStr(Lo(d2)) + ' ' + Res [Hi(d2)].Name +
                                      ' for ' + NumToStr(d3);
        empBuyKnowledge: DecodeUEmp := ' offer to buy ' + NumToStr(Lo(d2)) + ' ' + Adv^ [Hi(d2)].Name +
                                       ' for ' + NumToStr(d3);
       empSellKnowledge: DecodeUEmp := ' offer to sell ' + NumToStr(Lo(d2)) + ' ' + Adv^ [Hi(d2)].Name +
                                       ' for ' + NumToStr(d3);
         empDemandMoney: DecodeUEmp := ' demand a tribute of ' + NumToStr(d3);
           empGiveMoney: DecodeUEmp := ' offer a tribute of ' + NumToStr(d3);
       empBuyRetraction: DecodeUEmp := ' offer to pay ' + NumToStr(d3) +
                                       ' for the retraction of units';
      empSellRetraction: DecodeUEmp := ' offer to retract units for ' + NumToStr(d3);
            empBuyPeace: DecodeUEmp := ' offer to buy peace for ' + NumToStr(d3);
           empSellPeace: DecodeUEmp := ' offer peace for ' + NumToStr(d3);
           empBuyBoycot: DecodeUEmp := ' offer ' + NumToStr(d3) + ' for a boycot of the ' +
                                       CivInfo [d2].Name + ' civ.';
          empSellBoycot: DecodeUEmp := ' offer to boycot the ' + CivInfo [d2].Name + ' civ.' +
                                       ' for ' + NumToStr(d3);
           empBuyBoycot: DecodeUEmp := ' offer ' + NumToStr(d3) + ' for an embargo against the ' +
                                       CivInfo [d2].Name + ' civ.';
          empSellBoycot: DecodeUEmp := ' offer an embargo against the ' + CivInfo [d2].Name + ' civ.' +
                                       ' for ' + NumToStr(d3);
              empBuyWar: DecodeUEmp := ' offer ' + NumToStr(d3) + ' for an attack on the ' +
                                       CivInfo [d2].Name + ' civ.';
             empSellWar: DecodeUEmp := ' offer to attack the ' + CivInfo [d2].Name + ' civ.' +
                                       ' for ' + NumToStr(d3);
          empBuyDefense: DecodeUEmp := ' offer ' + NumToStr(d3) + ' for a pact of mutual defense';
         empSellDefense: DecodeUEmp := ' offer a pact of mutual defense for ' + NumToStr(d3);

     End;
   End;

 Function _Game.DecodeNEmp;
   Begin;
     Case nid Of

           nModThreat: DecodeNEmp := DecodeUEmp(empModThreat, d2, d3);
           nVioThreat: DecodeNEmp := DecodeUEmp(empVioThreat, d2, d3);
          nDeclareWar: DecodeNEmp := DecodeUEmp(empDeclareWar, d2, d3);
        nBuyResources: DecodeNEmp := DecodeUEmp(empBuyResources, d2, d3);
       nSellResources: DecodeNEmp := DecodeUEmp(empSellResources, d2, d3);
        nBuyKnowledge: DecodeNEmp := DecodeUEmp(empBuyKnowledge, d2, d3);
       nSellKnowledge: DecodeNEmp := DecodeUEmp(empSellKnowledge, d2, d3);
         nDemandMoney: DecodeNEmp := DecodeUEmp(empDemandMoney, d2, d3);
           nGiveMoney: DecodeNEmp := DecodeUEmp(empGiveMoney, d2, d3);
       nBuyRetraction: DecodeNEmp := DecodeUEmp(empBuyRetraction, d2, d3);
      nSellRetraction: DecodeNEmp := DecodeUEmp(empSellRetraction, d2, d3);
            nBuyPeace: DecodeNEmp := DecodeUEmp(empBuyPeace, d2, d3);
           nSellPeace: DecodeNEmp := DecodeUEmp(empSellPeace, d2, d3);
           nBuyBoycot: DecodeNEmp := DecodeUEmp(empBuyBoycot, d2, d3);
          nSellBoycot: DecodeNEmp := DecodeUEmp(empSellBoycot, d2, d3);
          nBuyEmbargo: DecodeNEmp := DecodeUEmp(empBuyEmbargo, d2, d3);
         nSellEmbargo: DecodeNEmp := DecodeUEmp(empSellEmbargo, d2, d3);
              nBuyWar: DecodeNEmp := DecodeUEmp(empBuyWar, d2, d3);
             nSellWar: DecodeNEmp := DecodeUEmp(empSellWar, d2, d3);
          nBuyDefense: DecodeNEmp := DecodeUEmp(empBuyDefense, d2, d3);
         nSellDefense: DecodeNEmp := DecodeUEmp(empSellDefense, d2, d3);

     End;
   End;

 Procedure _Game.PresentNotices;

   Var
      i, j   : Word;

      St     : String;

      S      : Boolean;

      src    : Text;

   Begin;
     N^.LoadN(CivInfo [CivPointer].NoticeId);
     For i := 1 To N^.MaxUsed Do
       Begin;
         S := True;
         With N^.Notice [i] Do
           Case nid Of

                  nUnitKilled: If WantNotice > 0 Then
                                 Begin;
                                   PanPlayField(Data [2], Data [3]);
                                   St := U^ [Data [1]].Name
                                               + ' defeated by '
                                               + CivInfo [CPtr].Name
                                               + ' units';
                                   bX := Data [2];
                                   bY := Data [3];
                                 End
                               Else
                                 S := False;
                nUnitProduced: If WantNotice = 2 Then
                                 Begin;
                                   With C [Data [1]]^ Do
                                     Begin;
                                       PanPlayField(X, Y);
                                       bX := X;
                                       bY := Y;
                                     End;
                                   With C [Data [1]]^ Do
                                     St := U^ [Data [2]].Name
                                           + ' produced in '
                                           + CN^.ExpandStr(NameIdx, NameLen);
                                 End
                               Else
                                 S := False;
             nResManufactured: If WantNotice = 2 Then
                                 Begin;
                                   With C [Data [1]]^ Do
                                     Begin;
                                       PanPlayField(X, Y);
                                       bX := X;
                                       bY := Y;
                                     End;
                                   With C [Data [1]]^ Do
                                     St := NumToStr(Data [3])
                                           + ' ' + Res [ResX [Data [2]].OutR].Name
                                           + ' manufactured in '
                                           + CN^.ExpandStr(NameIdx, NameLen);
                                 End
                               Else
                                 S := False;
                nImprProduced: If WantNotice = 2 Then
                                 Begin;
                                   With C [Data [1]]^ Do
                                     Begin;
                                       PanPlayField(X, Y);
                                       bX := X;
                                       bY := Y;
                                     End;
                                   With C [Data [1]]^ Do
                                     St := Imp [Data [2]].Name
                                           + ' built in '
                                           + CN^.ExpandStr(NameIdx, NameLen);
                                 End
                               Else
                                 S := False;
                 nUnitStarved: If WantNotice > 0 Then
                                 Begin;
                                   PanPlayField(Data [2], Data [3]);
                                   St := U^ [Data [1]].Name
                                         + ' ran out of supplies';
                                   bX := Data [2];
                                   bY := Data [3];
                                 End
                               Else
                                 S := False;
                 nUnitNotPaid: If WantNotice > 0 Then
                                 Begin;
                                   PanPlayField(Data [2], Data [3]);
                                   St := U^ [Data [1]].Name
                                         + ' could not be sustained';
                                   bX := Data [2];
                                   bY := Data [3];
                                 End
                               Else
                                 S := False;
                   nMassacred: If WantNotice > 0 Then
                                 Begin;
                                   With C [Data [2]]^ Do
                                     Begin;
                                       PanPlayField(X, Y);
                                       bX := X;
                                       bY := Y;
                                     End;
                                   With C [Data [2]]^ Do
                                     St := CivInfo [Data [1]].Name
                                           + ' fraction massacred in '
                                           + CN^.ExpandStr(NameIdx, NameLen);
                                 End
                               Else
                                 S := False;
                   nCityTaken: If WantNotice > 0 Then
                                 Begin;
                                   With C [Data [1]]^ Do
                                     Begin;
                                       PanPlayField(X, Y);
                                       bX := X;
                                       bY := Y;
                                     End;
                                   With C [Data [1]]^ Do
                                     St := CivInfo [CPtr].Name
                                           + ' units conquer '
                                           + CN^.ExpandStr(NameIdx, NameLen)
                                           + ': ' + NumToStr(Data [2])
                                           + ' plundered';
                                 End
                               Else
                                 S := False;
                nCityReverted: If WantNotice > 0 Then
                                 Begin;
                                   With C [Data [1]]^ Do
                                     Begin;
                                       PanPlayField(X, Y);
                                       bX := X;
                                       bY := Y;
                                     End;
                                   With C [Data [1]]^ Do
                                     St :=CivInfo [CPtr].Name
                                          + ' revolt in '
                                          + CN^.ExpandStr(NameIdx, NameLen);
                                 End
                               Else
                                 S := False;
                nEthnicUnrest: If WantNotice > 0 Then
                                 Begin;
                                   With C [Data [1]]^ Do
                                     Begin;
                                       PanPlayField(X, Y);
                                       bX := X;
                                       bY := Y;
                                     End;
                                   With C [Data [1]]^ Do
                                     St := CivInfo [Data [2]].Name
                                           + ' majority fights '
                                           + CivInfo [Data [3]].Name
                                           + ' fraction in '
                                           + CN^.ExpandStr(NameIdx, NameLen);
                                 End
                               Else
                                 S := False;
                   nShipTaken: If WantNotice > 0 Then
                                 Begin;
                                   PanPlayField(Data [2], Data [3]);
                                   St :=U^ [Data [1]].Name
                                        + ' captured by the '
                                        + CivInfo [CPtr].Name
                                        + ' fleet';
                                   bX := Data [2];
                                   bY := Data [3];
                                 End
                               Else
                                 S := False;
                  nCanProduce: If WantNotice > 0 Then
                                 Begin;
                                   If CivInfo [CPtr].ScienceCity > 0 Then
                                     With C [CivInfo [CPtr].ScienceCity]^ Do
                                       Begin;
                                         PanPlayField(X, Y);
                                         bX := X;
                                         bY := Y;
                                       End
                                   Else
                                     Begin;
                                       For j := 1 To MaxCitiesUsed Do
                                         If (C [j] <> NIL) And (C [j]^.Owner = CPtr) Then
                                           With C [j]^ Do
                                             Begin;
                                               PanPlayField(X, Y);
                                               bX := X;
                                               bY := Y;
                                             End;
                                     End;
                                   Case Data [1] Of

                                     2: St := CivInfo [CPtr].Name
                                              + ' scholars invent the '
                                              + U^ [Data [2]].Name;
                                     1: St := CivInfo [CPtr].Name
                                              + ' scholars invent the '
                                              + Imp [Data [2]].Name;

                                   End;
                                 End
                               Else
                                 S := False;
              nRefugeesArrive: If WantNotice > 0 Then
                                 Begin;
                                   With C [Data [1]]^ Do
                                     Begin;
                                       PanPlayField(X, Y);
                                       bX := X;
                                       bY := Y;
                                     End;
                                   St := CivInfo [CPtr].Name
                                         + ' refugees from the '
                                         + CivInfo [Data [2]].Name
                                         + ' massacre in '
                                         + CN^.ExpandStr(C [Data [3]]^.NameIdx, C [Data [3]]^.NameLen)
                                         + ' arrive in '
                                         + CN^.ExpandStr(C [Data [1]]^.NameIdx, C [Data [1]]^.NameLen);
                                 End
                               Else
                                 S := False;
                     nMessage: Begin;
                                 With C [Data [3]]^ Do
                                   Begin;
                                     PanPlayField(X, Y);
                                     bX := X;
                                     bY := Y;
                                   End;
                                 St := CivInfo [Cptr].Name
                                       + ' emissaries from '
                                       + CN^.ExpandStr(C [Data [1]]^.NameIdx, C [Data [1]]^.NameLen)
                                       + ' deliver this message: '
                                       + Msg^.Get(Data [2]);
                                 Msg^.Clear(Data [2]);
                               End;
               nCaravanRobbed: If WantNotice > 0 Then
                                 Begin;
                                   PanPlayField(Data [1], Data [2]);
                                   bX := Data [1];
                                   bY := Data [2];
                                   St := U^ [Data [3]].Name
                                         + ' abducted by '
                                         + CivInfo [CPtr].Name
                                         + ' units';
                                 End;
                   nModThreat: Begin;
                                 With C [Data [3]]^ Do
                                   Begin;
                                     PanPlayField(X, Y);
                                     bX := X;
                                     bY := Y;
                                   End;
                                 St := CivInfo [Cptr].Name
                                       + ' emissaries from '
                                       + CN^.ExpandStr(C [Data [1]]^.NameIdx, C [Data [1]]^.NameLen)
                                       + ' deliver a' + DecodeNEmp(nid, Data [2], Data [3]);
                               End;
                   nVioThreat: Begin;
                                 With C [Data [3]]^ Do
                                   Begin;
                                     PanPlayField(X, Y);
                                     bX := X;
                                     bY := Y;
                                   End;
                                 St := CivInfo [Cptr].Name
                                       + ' emissaries from '
                                       + CN^.ExpandStr(C [Data [1]]^.NameIdx, C [Data [1]]^.NameLen)
                                       + ' deliver a' + DecodeNEmp(nid, Data [2], Data [3]);
                               End;
                  nDeclareWar: Begin;
                                 With C [Data [3]]^ Do
                                   Begin;
                                     PanPlayField(X, Y);
                                     bX := X;
                                     bY := Y;
                                   End;
                                 St := CivInfo [Cptr].Name
                                       + ' emissaries from '
                                       + CN^.ExpandStr(C [Data [1]]^.NameIdx, C [Data [1]]^.NameLen)
                                       + ' deliver a' + DecodeNEmp(nid, Data [2], Data [3]);
                               End;
                nBuyResources
                           ..
                 nSellDefense: Begin;
                                 With CivInfo [CivPointer] Do
                                   Begin;
                                     PanPlayField(StartX, StartY);
                                     bX := StartX;
                                     bY := StartY;
                                   End;
                                 St := CivInfo [Cptr].Name
                                       + ' emissaries from '
                                       + CN^.ExpandStr(C [Data [1]]^.NameIdx, C [Data [1]]^.NameLen)
                                       + DecodeNEmp(nid, Data [2], Data [3]);
                               End;
                   nBronzeAge: Begin;
                                 With CivInfo [CivPointer] Do
                                   Begin;
                                     PanPlayField(StartX, StartY);
                                     bX := StartX;
                                     bY := StartY;
                                   End;
                                 St := 'The historical Bronze Age has begun';
                               End;
                     nIronAge: Begin;
                                 With CivInfo [CivPointer] Do
                                   Begin;
                                     PanPlayField(StartX, StartY);
                                     bX := StartX;
                                     bY := StartY;
                                   End;
                                 St := 'The historical Iron Age has begun';
                               End;
              nCaravanArrived: Begin;
                                 With C [Data [3]]^ Do
                                   Begin;
                                     PanPlayField(X, Y);
                                     bX := X;
                                     bY := Y;
                                   End;
                                 St := CivInfo [CPtr].Name + ' caravan arrives in ' +
                                       + CN^.ExpandStr(C [Data [3]]^.NameIdx, C [Data [3]]^.NameLen)
                                       + ' selling ' + NumToStr(Lo(Data [1]))
                                       + ' ' + Res [Hi(Data [1])].Name
                                       + ' for ' + NumToStr(Data [3]);
                               End;
              nTriggerExpired: Begin;
                                 With C [Data [3]]^ Do
                                   Begin;
                                     PanPlayField(X, Y);
                                     bX := X;
                                     bY := Y;
                                   End;
                                 St := CivInfo [CPtr].Name + ' merchants neglect delivery of ' +
                                       + NumToStr(Lo(Data [1]))
                                       + ' ' + Res [Hi(Data [1])].Name
                                       + ' for ' + NumToStr(Data [3])
                                       + ' in ' + CN^.ExpandStr(C [Data [3]]^.NameIdx, C [Data [3]]^.NameLen);
                               End;
              nBuyResources_Y
                           ..
               nSellDefense_Y: Begin;
                                 With C [Data [1]]^ Do
                                   Begin;
                                     PanPlayField(X, Y);
                                     bX := X;
                                     bY := Y;
                                   End;
                                 St := CivInfo [CPtr].Name
                                       + ' civ. accepts that you '
                                       + DecodeNEmp(nid - 40, Data [2], Data [3]);
                               End;
              nBuyResources_N
                           ..
               nSellDefense_N: Begin;
                                 With C [Data [1]]^ Do
                                   Begin;
                                     PanPlayField(X, Y);
                                     bX := X;
                                     bY := Y;
                                   End;
                                 St := CivInfo [CPtr].Name
                                       + ' civ. ignores that you '
                                       + DecodeNEmp(nid - 22, Data [2], Data [3]);
                               End;


           End;
         If S Then
           Begin;
             DrawPlayField;
             Kbd.ClearAreas;
             Kbd.HotArea(0, 0, 319, 176, TAB);
             bSX := SX;
             bSY := SY;
             Repeat
              Kbd.IdleProc := BlinkField;
              If Length(St) < 63 Then
                OneLiner(UpStr(St))
              Else
                SplitLiner(UpStr(St));
             Until (Kbd.Press = TAB) Or (Kbd.Press = ESC);
             With N^.Notice [i] Do
               Case nid Of

                 nBuyResources
                 ..
                  nSellDefense: Begin;
                                  St := Request('ACCEPT?', 1, 'YN');
                                  If (St = 'Y') Then
                                    Case nid Of

                                      nSellResources,
                                      nSellKnowledge,
                                      nDemandMoney,
                                      nSellRetraction,
                                      nSellPeace,
                                      nSellBoycot,
                                      nSellEmbargo,
                                      nSellWar: If (CivInfo [CivPointer].Wealth < Data [3]) Then
                                                  Begin;
                                                    OneLiner(UpStr('Your treasury cannot support that.'));
                                                    St := 'N';
                                                  End;

                                    End;
                                  Case St [1] Of

                                    'Y': Begin;
                                           Case nid Of

                                              nBuyResources: Begin;
                                                               UM^.AddUnitInfo(CivInfo [CPtr].BlockId,
                                                                               uCityTrigger, Data [1],
                                                                               Data [2], Data [3],
                                                                               (CPtr SHL 8) OR 20);
                                                             End;
                                             nSellResources: Begin;
                                                               UM^.AddUnitInfo(CivInfo [CivPointer].BlockId,
                                                                               uCityTrigger, Data [1],
                                                                               Data [2], Data [3],
                                                                               (CPtr SHL 8) OR 20);
                                                             End;
                                                 nGiveMoney: Inc(CivInfo [CivPointer].Wealth, Data [3]);
                                               nDemandMoney: Inc(CivInfo [CPtr].Wealth, Data [3]);

                                           End;
                                           N^.AddNotice(CivInfo [Cptr].NoticeId,
                                                        nid + 40, CivPointer,
                                                        Data [1], Data [2], Data [3]);
                                         End;
                                    'N': Begin;
                                           Case nid Of

                                             nBuyResources,
                                             nBuyKnowledge,
                                             nGiveMoney,
                                             nBuyRetraction,
                                             nBuyPeace,
                                             nBuyBoycot,
                                             nBuyEmbargo,
                                             nBuyWar: Inc(CivInfo [CPtr].Wealth, Data [3]);

                                           End;
                                           N^.AddNotice(CivInfo [Cptr].NoticeId,
                                                        nid + 22, CivPointer,
                                                        Data [1], Data [2], Data [3]);
                                         End;

                                  End;
                                End;

               End;
           End;
       End;
   End;

 Function _Game.CivCanBuildUnit;

   Var
      j      : Word;

   Begin;
     CivCanBuildUnit := False;
     j := 0;
     Repeat
      Inc(j);
     Until (j > MaxUBAdvReq) Or (UnitBuildAR [j].Pr = i);
     If j <= MaxUBAdvReq Then
       Repeat
        With UnitBuildAR [j] Do
          If (CivInfo [CP].Knowledge [Ad] < ScoreReq) Then
            Exit;
        Inc(j);
       Until (j > MaxUBAdvReq) Or (UnitBuildAR [j].Pr <> i);
     CivCanBuildUnit := True;
   End;

 Function _Game.CivCanBuildImpr;

   Var
      j      : Word;

   Begin;
     CivCanBuildImpr := False;
     j := 0;
     Repeat
      Inc(j);
     Until (j > MaxIBAdvReq) Or (ImprBuildAR [j].Pr = i);
     If j <= MaxIBAdvReq Then
       Repeat
        With ImprBuildAR [j] Do
          If (CivInfo [CP].Knowledge [Ad] < ScoreReq) Then
            Exit;
        Inc(j);
       Until (j > MaxIBAdvReq) Or (ImprBuildAR [j].Pr <> i);
     CivCanBuildImpr := True;
   End;

 End.