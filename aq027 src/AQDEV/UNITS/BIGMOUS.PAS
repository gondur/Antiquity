
 Unit BigMous;

 Interface

 Const
      MousInstalled         : Byte = 0;
      LeftButt              = 1;
      RightButt             = 2;
      MiddleButt            = 4;
      MousX                 : Byte = 1;
      MousY                 : Byte = 1;
      waterpalptr           : Byte = 140;
      timertick             : Byte = 0;

 Type
     MousBox                = Record
                                X1, Y1,
                                X2, Y2: Word;
                              End;
     MousStatus             = Record
                                X, Y  : Word;
                                Butt  : Word;
                              End;

 Var
    fMous                   : MousStatus;

 Procedure MousShow;
 Procedure MousHide;
 Procedure MousInfo(Var MS : MousStatus);
 Procedure MousRatio(x, y : Byte);
 Function MousWithin(MS : MousStatus; MB : MousBox) : Boolean;
 Procedure MousGet;

 Implementation

 Uses
     DOS;

 Var
    Regs                    : Registers;

 Procedure MouseInt(no : Word);
   Begin;
     If MousInstalled <> 0 Then
       Begin;
         Regs.AX := no;
         Intr($33, Regs);
       End;
   End;

 Procedure MousShow;
   Begin;
     MouseInt(1);
   End;

 Procedure MousHide;
   Begin;
     MouseInt(2);
   End;

 Procedure MousInfo;
   Begin;
     Regs.BX := 0;
     Regs.CX := 0;
     Regs.DX := 0;
     MouseInt(3);
     With MS Do
       Begin;
         X := Regs.CX DIV MousX;
         Y := Regs.DX DIV MousY;
         Butt := Regs.BX;
       End;
   End;

 Procedure MousGet;   Assembler;
   Asm
       xor dx, dx                   { get-new-mousepos routine }
       xor bx, bx
       xor cx, cx
       mov ax, 3
       int $33
       shr cx, 1
       mov fMous.X, cx
       mov fMous.Y, dx
       mov fMous.Butt, bx
   End;

 Procedure MousRatio;
   Begin;
     MousX := x;
     MousY := y;
   End;

 Function MousWithin;
   Begin;
     With MS Do
       With MB Do
         If (X >= X1) And (X <= X2) And (Y >= Y1) And (Y <= Y2) Then
           MousWithin := True
         Else
           MousWithin := False;
   End;

 Begin
   Regs.AX := 0;
   Intr($33, Regs);
   If Integer(Regs.AX) = -1 Then
     MousInstalled := Regs.BX;
 End.