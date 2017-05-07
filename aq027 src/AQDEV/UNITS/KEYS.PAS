
 {$R-,I-,S-}

 Unit Keys;

 Interface

 Const
      DKSTR  = 'abcdefghijklmnopqrstuvwxyz.,ABCDEFGHIJKLMNOPQRSTUVWXYZëõÜíùè1234567890!"#$%''&*()_+-=/?;:[]{}<>\|@^ ';
      USSTR  = 'abcdefghijklmnopqrstuvwxyz.,ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!"#$%''&*()_+-=/?;:[]{}<>\|@^ ';
      DKTXT  = 'abcdefghijklmnopqrstuvwxyzëõÜABCDEFGHIJKLMNOPQRSTUVWXYZíùè ';
      USTXT  = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ';
      PATHS  = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\*.?:';
      ONEWRD = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
      NUM    = '0123456789';
      DECI   = '0123456789.';
      MATH   = '0123456789./*-+=<> ';

 Function IntDelay(No : Word) : Boolean;
 Procedure ClearKbdBuf;
 Procedure FakeKeys(St : String);

 Implementation

 Uses
     Crt;

 Var
    x    : Word;

 Function IntDelay;
   Begin;
     x := 0;
     Repeat
      Inc(x);
      Delay(1);
     Until (Keypressed) or (x - 1 = No);
     If (Keypressed) And ((x - 1) < No) Then
       IntDelay := False
     Else
       IntDelay := True;
   End;

 Procedure ClearKbdBuf;
   Begin;
     Mem [$0:$41C] := Mem [$0:$41A];
   End;

 Procedure FakeKeys(St : String);

   Var
      kTail  : Word ABSOLUTE $0:$41C;
      kHead  : Word ABSOLUTE $0:$41A;
      kBufEnd: Word ABSOLUTE $0:$482;
      kBufOfs: Word ABSOLUTE $0:$480;

   Begin;
     kTail := kHead;
     For x := 1 To Length(St) Do
       Begin;
         Move(St [x], Ptr(0, kTail + $400)^, 1);
         FillChar(Ptr(0, Succ(kTail + $400))^, 1, 0);
         Inc(kTail, 2);
         If kTail = kBufEnd Then
           kTail := kBufOfs;
         If kTail = kHead Then
           x := Length(St);
       End;
   End;

  End.