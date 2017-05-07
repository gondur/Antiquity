
 Unit C2Str;

 Interface

 Function Pad(St : String; Dp : Char; Lt : Byte) : String;
 Function PadL(St : String; Dp : Char; Lt : Byte) : String;
 Function StrToInt(Numb : String) : LongInt;
 Function NumToStr(Src : LongInt) : String;
 Function UpStr(St : String) : String;
 Procedure UpSelf(Var St : String);
 Function Dup(ch : Char; ct : Byte) : String;
 Function NotCh(sm : Char; srch : String) : Byte;
 Function Trim(sm : Char; srch : String) : String;

 Implementation

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

 Function NumToStr(Src : LongInt) : String;

   Var
      Tmp         : String [80];

   Begin;
     Str(Src, Tmp);
     NumToStr := Tmp;
   End;

 Function StrToInt(Numb : String) : LongInt;

   Var
      Sht    : Integer;

      Dve    : LongInt;

   Begin;
     Val(Numb, Dve, Sht);
     StrToInt := Dve;
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
         Byte('ë'): Stn := Stn + 'í';
         Byte('õ'): Stn := Stn + 'ù';
         Byte('Ü'): Stn := Stn + 'è';

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
         Byte('ë'): St [Usi] := 'í';
         Byte('õ'): St [Usi] := 'ù';
         Byte('Ü'): St [Usi] := 'è';

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

 Function NotCh;

   Var
      Occ    : Word;

   Begin;
     Occ := 0;
     Repeat Inc(Occ) Until (Srch [Occ] <> Sm) or (Occ > Length(Srch));
     If Occ > Length(Srch) Then NotCh := 0
     Else NotCh := Occ;
   End;

 Function Trim;
   Begin;
     Delete(srch, 1, Pred(NotCh(sm, srch)));
     Trim := srch;
   End;

 End.