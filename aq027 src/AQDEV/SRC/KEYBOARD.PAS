
 Unit Keyboard;

 Interface

 Uses
     BigMous;

 Const
      TAB         = 9;
      ESC         = 27;
      SPACE       = 32;
      Enter       = 13;
      HmKey       = 1071;
      UpKey       = 1072;
      PUKey       = 1073;
      PDKey       = 1081;
      DnKey       = 1080;
      EnKey       = 1079;
      LfKey       = 1075;
      RtKey       = 1077;
      F1          = 1059;
      F2          = 1060;
      F3          = 1061;
      F4          = 1062;
      F5          = 1063;
      F6          = 1064;
      F7          = 1065;
      F8          = 1066;
      F9          = 1067;
      F10         = 1068;
      sF1         = 1084;
      sF2         = 1085;
      sF3         = 1086;
      sF4         = 1087;
      sF5         = 1088;
      sF6         = 1089;
      sF7         = 1090;
      sF8         = 1091;
      sF9         = 1092;
      sF10        = 1093;
      cF1         = 1094;
      cF2         = 1095;
      cF3         = 1096;
      cF4         = 1097;
      cF5         = 1098;
      cF6         = 1099;
      cF7         = 1100;
      cF8         = 1101;
      cF9         = 1102;
      cF10        = 1103;
      aF1         = 1104;
      aF2         = 1105;
      aF3         = 1106;
      aF4         = 1107;
      aF5         = 1108;
      aF6         = 1109;
      aF7         = 1110;
      aF8         = 1111;
      aF9         = 1112;
      aF10        = 1113;

      PauseMouse  : Boolean = True;

      DeadManButton
                  : Word = 0;

 Type
     KbdType      = Object
                      Press           : Word;
                      PressCh         : String [2];

                      GK              : Boolean;

                      IdleProc        : Procedure;

                      AreaPtr         : Byte;

                      NextKey         : Word;

                      Area            : Array [1..100] Of Record
                                                            MB : MousBox;

                                                            KC : Word;
                                                          End;

                      Constructor Init;
                      Procedure Clear;
                      Procedure ClearAreas;
                      Procedure HotArea(aX1, aY1, aX2, aY2, aKC : Word);
                      Function Pressed : Boolean;
                      Function IntDelay(No : Word) : Boolean;
                      Procedure GetKey;
                      Destructor Done;
                    End;

 Implementation

 Uses
     Crt;

 Constructor KbdType.Init;
   Begin;
     PressCh := '';
     Press := 0;
     IdleProc := NIL;
     GK := False;
     NextKey := 0;
     ClearAreas;
   End;

 Procedure KbdType.Clear;
   Begin;
     Mem [$0:$41C] := Mem [$0:$41A];
   End;

 Function KbdType.Pressed;
   Begin;
     MousGet;
     If (Keypressed) Or (fMous.Butt <> 0) Or (NextKey <> 0) Then
       Pressed := True
     Else
       Pressed := False;
     DeadManButton := 0;
   End;

 Function KbdType.IntDelay;

   Var
      x      : Word;

   Begin;
     If GK Then
       MousShow;
     x := 0;
     Repeat
      Inc(x);
      Delay(1);
      MousGet;
     Until (Pressed) Or (x - 1 = No);
     If (Pressed) And ((x - 1) < No) Then
       IntDelay := False
     Else
       IntDelay := True;
     If GK Then
       MousHide;
   End;

 Procedure KbdType.HotArea;
   Begin;
     Inc(AreaPtr);
     With Area [AreaPtr] Do
       Begin;
         MB.X1 := ax1;
         MB.X2 := ax2;
         MB.Y1 := ay1;
         MB.Y2 := ay2;
         KC := aKC;
       End;
   End;

 Procedure KbdType.ClearAreas;
   Begin;
     AreaPtr := 0;
   End;

 Procedure KbdType.GetKey;

   Var
      i      : Word;

   Begin;
     If NextKey <> 0 Then
       Begin;
         Press := NextKey;
         PressCh := Chr(Lo(Press));
         NextKey := 0;
         IdleProc := NIL;
         Exit;
       End;
     GK := True;
     MousShow;
     Repeat
      DeadManButton := 0;
      If Pointer(@IdleProc) <> NIL Then
        Begin;
          MousHide;
          IdleProc;
          MousShow;
        End;
      MousGet;
     Until (Keypressed) Or (fMous.Butt <> 0);
     If fMous.Butt AND LeftButt <> 0 Then
       Begin;
         Press := 0;
         PressCh := '';
         For i := 1 To AreaPtr Do
           If MousWithIn(fMous, Area [i].MB) Then
             Begin;
               Press := Area [i].KC;
               PressCh := Chr(Lo(Press));
             End;
         If PauseMouse Then
           Repeat
            MousGet;
           Until (fMous.Butt = 0);
       End
     Else
       If fMous.Butt AND RightButt <> 0 Then
         Begin;
           Press := ESC;
           PressCh := #27;
           If PauseMouse Then
             Repeat
              MousGet;
             Until (fMous.Butt = 0);
         End
     Else
       If fMous.Butt AND MiddleButt <> 0 Then
         Begin;
           Press := Enter;
           PressCh := #13;
           If PauseMouse Then
             Repeat
              MousGet;
             Until (fMous.Butt = 0);
         End
     Else
       Begin;
         PressCh := Readkey;
         If (PressCh = #0) And (Keypressed) Then
           Begin;
             PressCh := PressCh + Readkey;
             Press := 1000 + Ord(PressCh [2]);
           End
         Else
           Press := Ord(PressCh [1]);
       End;
     MousHide;
     GK := False;
     IdleProc := NIL;
   End;

 Destructor KbdType.Done;
   Begin;
   End;

 End.