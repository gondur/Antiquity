
 Unit Strings;

 Interface

 Type
     String80 = String [80];

 Function Subst(St : String; fi, sb : Char) : String;
 Function Word2Chars(vl : Word) : String;
 Function Pad(St : String; Dp : Char; Lt : Byte) : String;
 Function PadL(St : String; Dp : Char; Lt : Byte) : String;
 Procedure Replace(Post : Byte; Var Dst : String; Inp : String);
 Function CutStr(Var Src : String; Indx, Cnt : Integer) : String;
 Function StrToInt(Numb : String) : LongInt;
 Function StrToReal(Numb : String) : Real;
 Function NumToStr(Src : LongInt) : String;
 Function RealToStr(Src : Real) : String;
 Function UpStr(St : String) : String;
 Function UpChar(Ch : Char) : Char;
 Procedure UpSelf(Var St : String);
 Function Dup(ch : Char; ct : Byte) : String;
 Function LengthJustify(Ts : String; Lt, Ct : Byte; Sm : Char) : String;
 Procedure Kill(Var Src : String; Sml : String);
 Procedure FDel(Var Setr : String; Sml : Char);
 Function LPos(sm : Char; srch : String) : Byte;
 Function NotCh(sm : Char; srch : String) : Byte;
 Function LNotCh(sm : Char; srch : String) : Byte;
 Function LCh(sm : Char; srch : String) : Byte;
 Function Trim(sm : Char; srch : String) : String;
 Function TrimL(sm : Char; srch : String) : String;
 Function GetWordQk(St : String; No : Word) : String;
 Function GetWord(St : String; No : Word) : String;
 Function Words(St : String) : Word;

 Const
      LinBar      : String [80] = 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ';
      BigBar      : String [80] = 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ';
      NiceBar     : String [80] = 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ';

 Implementation

 Var
    y,
    x      : Integer;

    Letter : Array [0..255] of Char;

    Tmp,
    BufStr,
    BufStr2: String;

    BufWC  : Word;

    Occ    : Byte;

 Function Subst;
   Begin;
     For x := 1 To Length(St) Do
       If St [x] = fi Then
         St [x] := sb;
     Subst := St;
   End;

 Function Pad;
   Begin;
     If Length(St) > Lt Then
       Pad := Copy(St, 1, Lt)
     Else
       Pad := St + Dup(Dp, Lt - Length(St));
   End;

 Function PadL;
   Begin;
     If Length(St) > Lt Then
       PadL := Copy(St, 1 + (Lt - Length(St)), Lt)
     Else
       PadL := Dup(Dp, Lt - Length(St)) + St;
   End;

 Procedure Replace(Post : Byte; Var Dst : String; Inp : String);
   Begin;
     Delete(Dst, Post, 1);
     Insert(Inp, Dst, Post);
   End;

 Function NumToStr(Src : LongInt) : String;
   Begin;
     Str(Src,Tmp);
     NumToStr := Tmp;
   End;

 Function RealToStr(Src : Real) : String;
   Begin;
     Str(Src:1:1,Tmp);
     RealToStr := Tmp;
   End;

 Function CutStr(Var Src : String; Indx, Cnt : Integer) : String;
   Begin;
     CutStr := Copy(Src,Indx,Cnt);
     Delete(Src,Indx,Cnt);
   End;

 Function StrToInt(Numb : String) : LongInt;

   Var
      Sht    : Integer;

      Dve    : LongInt;

   Begin;
     Val(Numb, Dve, Sht);
     StrToInt := Dve;
   End;

 Function StrToReal(Numb : String) : Real;

   Var
      Sht    : Integer;

      Dve    : Real;

   Begin;
     Val(Numb, Dve, Sht);
     StrToReal := Dve;
   End;

 Function UpStr;

   Var
      USi    : Byte;

      Stn    : String;

   Begin;
     Stn := '';
     For USi := 1 To Length(St) Do
       Case Byte(St [USi]) Of

         0..133,
         135..144,
         146..154,
         156..255 : Stn := Stn + UpCase(St [USi]);
         Byte('‘'): Stn := Stn + '’';
         Byte('›'): Stn := Stn + '';
         Byte('†'): Stn := Stn + '';

       End;
     UpStr := Stn;
   End;

 Procedure UpSelf;

   Var
      USi    : Byte;

   Begin;
     For USi := 1 To Length(St) Do
       Case Byte(St [USi]) Of

         0..133,
         135..144,
         146..154,
         156..255 : St [Usi] := UpCase(St [USi]);
         Byte('‘'): St [Usi] := '’';
         Byte('›'): St [Usi] := '';
         Byte('†'): St [Usi] := '';

       End;
   End;

 Function UpChar;
   Begin;
     Case Byte(Ch) Of

       0..133,
       135..144,
       146..154,
       156..255 : UpChar := UpCase(Ch);
       Byte('‘'): UpChar := '’';
       Byte('›'): UpChar := '';
       Byte('†'): UpChar := '';

     End;
   End;

 Function Dup;

   Var
      wk     : String;

   Begin;
     FillChar(wk [1], ct, ch);
     wk [0] := Chr(ct);
     Dup := wk;
   End;

 Function LengthJustify;
   Begin;
     If Length(Ts) > Lt Then
       LengthJustify := Dup(Sm, Ct) + Copy(Ts, Succ((Length(Ts) - Lt) +  Ct), Lt - Ct)
     Else
       LengthJustify := Ts;
   End;

 Procedure Kill(Var Src : String; Sml : String);
   Begin;
     Delete(Src, Pos(Sml, Src), Succ(Length(Src) - Pos(Sml, Src)));
   End;

 Procedure FDel(Var Setr : String; Sml : Char);   {3.39}
   Begin;
     For y := 1 To Length(Setr) Do
       Letter [y] := Setr [y];
     If Length(Setr) = 0 Then
       y := 0;
     Setr := '';
     For x := 1 To y Do
       If Letter [x] <> Sml Then
         Setr := Setr + Letter [x];
   End;

 Function LPos(sm : char; srch : String) : Byte;

   Var
      sx : Byte;

   Begin;
     LPos := 0;
     For sx := Length(srch) DownTo 1 Do
       If srch [sx] = sm Then
         Begin;
           LPos := sx;
           sx := 1;
         End;
   End;

 Function NotCh;
   Begin;
     Occ := 0;
     Repeat Inc(Occ) Until (Srch [Occ] <> Sm) or (Occ > Length(Srch));
     If Occ > Length(Srch) Then NotCh := 0
     Else NotCh := Occ;
   End;

 Function LNotCh;
   Begin;
     Occ := Length(Srch) + 1;
     Repeat Dec(Occ) Until (Srch [Occ] <> Sm) or (Occ = 0);
     LNotCh := Occ;
   End;

 Function LCh;
   Begin;
     Occ := Length(Srch) + 1;
     Repeat Dec(Occ) Until (Srch [Occ] = Sm) or (Occ = 0);
     LCh := Occ;
   End;

 Function Trim;
   Begin;
     Delete(srch, 1, Pred(NotCh(sm, srch)));
     Trim := srch;
   End;

 Function TrimL;

   Var
      ti          : Byte;

   Begin;
     ti := LNotCh(sm, srch);
     Delete(srch, Succ(ti), Length(srch) - ti);
     TrimL := srch;
   End;

 Function Word2Chars;
   Begin;
     Word2Chars := Chr(Lo(vl)) + Chr(Hi(vl));
   End;

 Function GetWordQk(St : String; No : Word) : String;

   Var
      WCount      : Word;

      W           : String;

   Begin;
     If (St = BufStr) And (No > BufWC) Then
       Begin;
         St := BufStr2;
         WCount := BufWC;
       End
     Else
       Begin;
         BufStr := St;
         BufWC := 0;
         WCount := 0;
       End;
     Repeat
      If Pos(St [1], 'abcdefghijklmnopqrstuvwxyz‘›†ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 0 Then
        Repeat
         Delete(St, 1, 1);
        Until (Pos(St [1], 'abcdefghijklmnopqrstuvwxyz‘›†ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0) Or (St = '');
      W := '';
      If St <> '' Then
        Begin;
          Repeat
           W := W + St [1];
           Delete(St, 1, 1);
          Until (Pos(St [1], 'abcdefghijklmnopqrstuvwxyz‘›†ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 0) Or (St = '');
          Inc(WCount);
        End;
     Until (WCount = No) Or (St = '');
     If WCount = No Then
       GetWordQk := W
     Else
       GetWordQk := '';
     BufStr2 := St;
     BufWC := WCount;
   End;

 Function GetWord(St : String; No : Word) : String;

   Var
      WCount      : Word;

      W           : String;

   Begin;
     WCount := 0;
     Repeat
      If Pos(St [1], 'abcdefghijklmnopqrstuvwxyz‘›†ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 0 Then
        Repeat
         Delete(St, 1, 1);
        Until (Pos(St [1], 'abcdefghijklmnopqrstuvwxyz‘›†ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0) Or (St = '');
      W := '';
      If St <> '' Then
        Begin;
          Repeat
           W := W + St [1];
           Delete(St, 1, 1);
          Until (Pos(St [1], 'abcdefghijklmnopqrstuvwxyz‘›†ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 0) Or (St = '');
          Inc(WCount);
        End;
     Until (WCount = No) Or (St = '');
     If (WCount = No) Then
       GetWord := W
     Else
       GetWord := '';
   End;

 Function Words(St : String) : Word;

   Var
      WCount      : Word;

      W           : String;

   Begin;
     WCount := 0;
     Repeat
      If Pos(St [1], 'abcdefghijklmnopqrstuvwxyz‘›†ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 0 Then
        Repeat
         Delete(St, 1, 1);
        Until (Pos(St [1], 'abcdefghijklmnopqrstuvwxyz‘›†ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') > 0) Or (St = '');
      W := '';
      If St <> '' Then
        Begin;
          Repeat
           W := W + St [1];
           Delete(St, 1, 1);
          Until (Pos(St [1], 'abcdefghijklmnopqrstuvwxyz‘›†ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') = 0) Or (St = '');
          Inc(WCount);
        End;
     Until (St = '');
     Words := WCount;
   End;

 Begin
   FillChar(NiceBar [25], 30, 'Ä');
   BufStr := '';
   BufStr2 := '';
   BufWC := 0;
 End.