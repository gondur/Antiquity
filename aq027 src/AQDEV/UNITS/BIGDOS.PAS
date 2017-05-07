
 {$R-,I-,S-}

 Unit BigDos;

 Interface

 Uses
     DOS;

 Type
     Array8                 = Array [1..8] Of Char;
     Array3                 = Array [1..3] Of Char;

 Const
      pUnused               = 0;                { Constants for use with }
      pDOS12                = 1;                { partition recognition }
      pXENIX                = 2;
      pDOS16                = 4;
      pEXTEND               = 5;
      pBIGDOS               = 6;
      pHPFS                 = 7;
      pSplit                = 8;
      pDM                   = $50;
      pGB                   = $56;
      pNovell               = $64;
      pPCIX                 = $75;
      pSpeed                = $61;
      pBBT                  = $FF;
      p386ix                = $63;

      FATerror              : Boolean = False;   { Used by FATobj }

      LargeHD               : Boolean = False;

      NoDirs                = 0;                 { Used by RecurseDir }
      DirsBefore            = 1;
      DirsAfter             = 2;

      IsDriveA              = 0;                 { Used by SingleDriveStatus }
      IsDriveB              = 1;
      IsUnsure              = $FF;

      b_OEM                 = 4;                 { Used with BootSectors }
      b_BytesPerSector      = 12;
      b_SectorsPerCluster   = 14;
      b_ReservedSectors     = 15;
      b_NumberOfFATs        = 16;
      b_NumberOfRootEntries = 17;
      b_LogicalSectors      = 19;
      b_MediaDescriptor     = 21;
      b_SectorsPerFAT       = 22;
      b_SectorsPerTrack     = 24;
      b_NumberOfHeads       = 26;
      b_NumberOfHiddenSecs  = 28;

 Type
     BigArray               = Array [1..65520] Of Byte;
     DirEntry               = Record
                                Name       : Array8;
                                Ext        : Array3;
                                Attrib     : Byte;
                                Reserved   : Array [1..10] Of Byte;
                                TimeDate   : LongInt;
                                FATEntry   : Word;
                                Size       : LongInt;
                              End;
     LargeDir               = Array [1..2000] Of DirEntry;
     BootRecord             = Object
                                NearJump             : Array [1..3] Of Byte;

                                OEMSignature         : Array [1..8] Of Char;

                                BytesPerSector       : Word;
                                SectorsPerCluster    : Byte;
                                ReservedSectors      : Word;
                                NumberOfFATs         : Byte;
                                NumberOfRootEntries  : Word;
                                LogicalSectors       : Word;
                                MediaDescriptor      : Byte;
                                SectorsPerFAT        : Word;
                                SectorsPerTrack      : Word;
                                NumberOfHeads        : Word;
                                NumberOfHiddenSecs   : Word;

                                Code                 : Array [30..512] Of Byte;

                                Function Read(Drive : Char) : Boolean;
                                Function Write(Drive : Char) : Boolean;
                              End;
     FATObj                 = Object
                                Table                : ^BigArray;
                                Size                 : Word;
                                WorkDrive            : Char;
                                WorkBoot             : BootRecord;
                                FAT16                : Boolean;

                                Constructor Init(Drive : Char);
                                Function Read(No : Byte) : Boolean;
                                Function Write(No : Byte) : Boolean;
                                Function GetEntry(No : Word) : Word;
                                Procedure SetEntry(No, vl : Word);
                                Destructor Done;
                              End;
     CentralDirObj          = Object
                                List                 : ^LargeDir;

                                WorkBoot             : BootRecord;

                                WorkDrive            : Char;

                                Entries              : Word;

                                Constructor Init(Drive : Char);
                                Function GetFreeEntry(OffSet : Word) : Word;
                                Function Read : Boolean;
                                Function Write : Boolean;
                                Destructor Done;
                              End;
     SubDirObj              = Object
                                List                 : ^LargeDir;

                                WorkBoot             : BootRecord;

                                WorkDrive            : Char;

                                Entries              : Word;

                                Constructor Init(Drive : Char);
                                Function GetFreeEntry(OffSet : Word) : Word;
                                Function Read(Clst : Word) : Boolean;
                                Function Write(Clst : Word) : Boolean;
                                Destructor Done;
                              End;
     BootArray              = Array [0..511] Of Byte;
     String12               = String [12];
     String127              = String [127];
     String80               = String [80];
     HandleProc             = Procedure(Name : PathStr; IsFile : Boolean);

 Function GetPartitionInfo(No : Byte; Var Bootable : Boolean;
                                      Var ParType : Byte;
                                      Var Side : Byte;
                                      Var SecCyl : Word;
                                      Var EndSide : Byte;
                                      Var EndSecCyl : Word;
                                      Var RelSecs : LongInt;
                                      Var SecNum : LongInt) : Byte;
 Function WCMatch(Org, wc : String) : Boolean;
 Function IsFile(tst : SearchRec) : Boolean;
 Function GetInt(No : Byte) : Pointer;
 Procedure SetInt(No : Byte; vl : Pointer);
 Function ActiveDir : String;
 Function ChgDir(Ms : String) : ShortInt;
 Function Int13hError(EC : Byte) : String;
 Procedure ReCalibrate;
 Procedure SetHeadLoad(No : Byte);
 Procedure SetStepRate(No : Byte);
 Procedure SetMaxSectors(No : Byte);
 Procedure SetFormatChar(Ch : Char);
 Procedure SetMotorOff(Tim : Byte);
 Procedure SetMotorStart(No : Byte);
 Procedure SetHeadSettle(No : Byte);
 Function FindSelf(Def : NameStr) : PathStr;
 Function GetStepRate : Byte;
 Function GetMotorOff : Byte;
 Function GetFormatChar : Char;
 Function GetMaxSectors : Byte;
 Function GetMotorStart : Byte;
 Function GetHeadSettle : Byte;
 Function GetHeadLoad : Byte;
 Function PhysFlops : Byte;
 Function VerifySector(Drv, Hd, Trk, Sec : Word) : Byte;
 Function ReadSector(Drv, Hd, Trk, Sec : Word; Buf : Pointer) : Byte;
 Function WriteSector(Drv, Hd, Trk, Sec : Word; Buf : Pointer) : Byte;
 Function VerifySectors(Drv, Hd, Trk, Sec, secs : Word) : Byte;
 Function ReadSectors(Drv, Hd, Trk, Sec, secs : Word; Buf : Pointer) : Byte;
 Function WriteSectors(Drv, Hd, Trk, Sec, secs : Word; Buf : Pointer) : Byte;
 Procedure RecurseDir(Dir : DirStr; Files : String12; HandleIt : HandleProc; WhatWithDirs : Byte);
 Function SingleDriveStatus : Byte;
 Procedure SetSingleDriveStatus(Status : Byte);
 Function int25(Drive : Char; StartSec : LongInt; SecNum : Word; Var Buf) : Word;
 Function int26(Drive : Char; StartSec, SecNum : Word; Var Buf) : Word;
 Function MakeName(Name : Array8) : String;
 Function AppendExt(Ext : Array3) : String;

 Var
    Regs          : Registers;

 Implementation

 Type
     DPTRec       = Record
                      StepRate,
                      HeadLoad   : Byte;

                      MotorOff   : Byte;

                      SectorSize : Byte;

                      SecPerTrack: Byte;

                      MiscData   : Array [1..3] Of Byte;

                      FormatChar : Char;

                      HeadSettle,
                      MotorStart : Byte;
                    End;

 Var
    Jk            : String;

    DriveParmTable: ^DPTRec;

 Function GetPartitionInfo(No : Byte; Var Bootable : Boolean;
                                      Var ParType : Byte;
                                      Var Side : Byte;
                                      Var SecCyl : Word;
                                      Var EndSide : Byte;
                                      Var EndSecCyl : Word;
                                      Var RelSecs : LongInt;
                                      Var SecNum : LongInt) : Byte;

   Var
      Partition   : Record
                      Code  : Array [1..446] Of Byte;
                      PInfo : Array [1..4] Of Record
                                                Bable,
                                                SSide : Byte;
                                                SSC   : Word;
                                                ParT,
                                                ESide : Byte;
                                                ESC   : Word;
                                                RSecs : LongInt;
                                                SecNo : LongInt;
                                              End;
                    End;

   Begin;
     GetPartitionInfo := ReadSector($80, 0, 0, 1, @Partition);
     With Partition.PInfo [No] Do
       Begin;
         Bootable := Bable = $80;
         Side := SSide;
         SecCyl := SSC;
         ParType := ParT;
         EndSide := ESide;
         EndSecCyl := ESC;
         RelSecs := RSecs;
         SecNum := SecNo;
       End;
   End;

 Function FindSelf(Def : NameStr) : PathStr;

   Var
      Jk, Jk2: PathStr;

      src    : File;

   Begin;
     If Lo(DOSVersion) >= 3 Then
       Begin;
         Jk := FExpand(ParamStr(0));
         Assign(src, Jk);
         Reset(src, 1);
         If IOResult <> 0 Then
           Begin;
             Jk := GetEnv('PATH');
             Repeat
              Jk2 := Copy(Jk, 1, Pos(';', Jk) - 1);
              If Jk2 [Length(Jk2)] <> '\' Then
                Jk2 := Jk2 + '\';
              Jk2 := Jk2 + ParamStr(0);
              Assign(src, Jk2);
              Reset(src, 1);
              If IOResult = 0 Then
                Begin;
                  FindSelf := Jk2;
                  Exit;
                End;
              Delete(Jk, 1, Pos(';', Jk));
             Until (Jk = '') Or (Pos(';', Jk) = 0);
             If Jk <> '' Then
               Begin;
                 If Jk [Length(Jk)] <> '\' Then
                   Jk := Jk + '\';
                 Jk := Jk + ParamStr(0);
                 Assign(src, Jk);
                 Reset(src, 1);
                 If IOResult = 0 Then
                   Begin;
                     FindSelf := Jk;
                     Exit;
                   End;
               End;
             FindSelf := '?';
             Exit;
           End;
         FindSelf := Jk;
       End
     Else
       Begin;
         Assign(src, FExpand(Def));
         Reset(src, 1);
         If IOResult = 0 Then
           FindSelf := FExpand(Def)
         Else
           FindSelf := '?';
       End;
   End;

 Function WCMatch;

   Var
      s      : Byte;

      fOK    : Boolean;

      pt1,
      pt2    : DirStr;

      nam1,
      nam2   : NameStr;

      ext1,
      ext2   : ExtStr;

   Begin;
     FSplit(FExpand(Org), pt1, nam1, ext1);
     FSplit(FExpand(wc), pt2, nam2, ext2);
     fOK := False;
     If ext2 = '' Then
       ext2 := '*'
     Else
       Delete(ext2, 1, 1);
     If nam2 = '' Then
       nam2 := '*';
     Delete(ext1, 1, 1);
     s := 1;
     Repeat
      Case nam2 [s] Of

        '?': nam2 [s] := nam1 [s];
        '*': Begin;
               Delete(nam2, s, Succ(Length(nam2) - s));
               nam2 := nam2 + Copy(nam1, s, Succ(Length(nam1) - s));
               fOK := True;
             End;

      End;
      If (s > Length(nam1)) Or (s > Length(nam2)) Then
        fOK := True;
      Inc(s);
     Until fOK;
     fOK := False;
     s := 1;
     Repeat
      Case ext2 [s] Of

        '?': ext2 [s] := ext1 [s];
        '*': Begin;
               Delete(ext2, s, Succ(Length(ext2) - s));
               ext2 := ext2 + Copy(ext1, s, Succ(Length(ext1) - s));
               fOK := True;
             End;

      End;
      If (s > Length(ext1)) Or (s > Length(ext2)) Then
        fOK := True;
      Inc(s);
     Until fOK;
     If (nam1 = nam2) And (ext1 = ext2) Then
       WCmatch := True
     Else
       WCmatch := False;
   End;

 Function IsFile;
   Begin;
     If (tst.Attr AND VolumeID = 0) And (tst.Attr AND Directory = 0) Then
       IsFile := True
     Else
       IsFile := False;
   End;

 Function GetInt;
   Begin;
     GetInt := Pointer(Ptr($0000, No * 4)^);
   End;

 Procedure SetInt;
   Begin;
     Move(LongInt(vl), Ptr($0000, No * 4)^, 4);
   End;

 Function ActiveDir;
   Begin;
     GetDir(0, Jk);
     ActiveDir := Jk;
   End;

 Function ChgDir;
   Begin;
     ChgDir := -1;
     ChDir(Ms);
     If IOResult <> 0 Then
       Begin;
         MkDir(Ms);
         If IOResult <> 0 Then
           Exit;
         ChDir(Ms);
         If IOResult <> 0 Then
           Exit;
       End;
     ChgDir := 0;
   End;

 Function Int13hError(EC : Byte) : String;
   Begin;
     Case EC Of

       $01: Int13hError := ' Bad Command';
       $02: Int13hError := ' Address Mark Not Found';
       $03: Int13hError := ' Write Error';
       $04: Int13hError := ' Sector Not Found';
       $06: Int13hError := ' Disk Changed';
       $08: Int13hError := ' DMA Overrun';
       $09: Int13hError := ' DMA Across 64K Boundary';
       $0C: Int13hError := ' Bad Sector Detected';
       $10: Int13hError := ' Bad CRC/ECC';
       $11: Int13hError := ' Data ECC Corrected';
       $20: Int13hError := ' Controller Failure';
       $40: Int13hError := ' Seek Failed';
       $80: Int13hError := ' Drive Not Ready';
       Else Int13hError := ' Unknown or Harddisk Error';

     End;
   End;

 Procedure ReCalibrate;
   Begin;
     Regs.AH := $00;
     Intr($13, Regs);
   End;

 Function ReadSector;
   Begin;
     With Regs Do
       Begin;
         AH := $02;
         AL := $01;
         CH := Trk;
         DH := Hd;
         CL := Sec;
         DL := Drv;
         ES := Seg(Buf^);
         BX := Ofs(Buf^);
       End;
     Intr($13, Regs);
     If Regs.Flags AND 1 = 1 Then
       ReadSector := Regs.AH
     Else
       ReadSector := 0;
   End;

 Function WriteSector;
   Begin;
     With Regs Do
       Begin;
         AH := $03;
         AL := $01;
         CH := Trk;
         DH := Hd;
         CL := Sec;
         DL := Drv;
         ES := Seg(Buf^);
         BX := Ofs(Buf^);
       End;
     Intr($13, Regs);
     If Regs.Flags AND 1 = 1 Then
       WriteSector := Regs.AH
     Else
       WriteSector := 0;
   End;

 Function VerifySector;
   Begin;
     With Regs Do
       Begin;
         AH := $04;
         AL := $01;
         CH := Trk;
         DH := Hd;
         CL := Sec;
         DL := Drv;
       End;
     Intr($13, Regs);
     If Regs.Flags AND 1 = 1 Then
       VerifySector := Regs.AH
     Else
       VerifySector := 0;
   End;

 Function ReadSectors;
   Begin;
     With Regs Do
       Begin;
         AH := $02;
         AL := secs;
         CH := Trk;
         DH := Hd;
         CL := Sec;
         DL := Drv;
         ES := Seg(Buf^);
         BX := Ofs(Buf^);
       End;
     Intr($13, Regs);
     If Regs.Flags AND 1 = 1 Then
       ReadSectors := Regs.AH
     Else
       ReadSectors := 0;
   End;

 Function WriteSectors;
   Begin;
     With Regs Do
       Begin;
         AH := $03;
         AL := secs;
         CH := Trk;
         DH := Hd;
         CL := Sec;
         DL := Drv;
         ES := Seg(Buf^);
         BX := Ofs(Buf^);
       End;
     Intr($13, Regs);
     If Regs.Flags AND 1 = 1 Then
       WriteSectors := Regs.AH
     Else
       WriteSectors := 0;
   End;

 Function VerifySectors;
   Begin;
     With Regs Do
       Begin;
         AH := $04;
         AL := secs;
         CH := Trk;
         DH := Hd;
         CL := Sec;
         DL := Drv;
       End;
     Intr($13, Regs);
     If Regs.Flags AND 1 = 1 Then
       VerifySectors := Regs.AH
     Else
       VerifySectors := 0;
   End;

 Procedure SetStepRate;
   Begin;
     DriveParmTable^.StepRate := No;
   End;

 Procedure SetMaxSectors;
   Begin;
     DriveParmTable^.SecPerTrack := No;
   End;

 Procedure SetFormatChar;
   Begin;
     DriveParmTable^.FormatChar := Ch;
   End;

 Procedure SetMotorOff;
   Begin;
     DriveParmTable^.MotorOff := Tim;
   End;

 Procedure SetHeadLoad;
   Begin;
     DriveParmTable^.HeadLoad := No;
   End;

 Procedure SetMotorStart;
   Begin;
     DriveParmTable^.MotorStart := No;
   End;

 Procedure SetHeadSettle;
   Begin;
     DriveParmTable^.HeadSettle := No;
   End;

 Function GetStepRate;
   Begin;
     GetStepRate := DriveParmTable^.StepRate;
   End;

 Function GetMaxSectors;
   Begin;
     GetMaxSectors := DriveParmTable^.SecPerTrack;
   End;

 Function GetFormatChar;
   Begin;
     GetFormatChar := DriveParmTable^.FormatChar;
   End;

 Function GetMotorOff;
   Begin;
     GetMotorOff := DriveParmTable^.MotorOff;
   End;

 Function GetMotorStart;
   Begin;
     GetMotorStart := DriveParmTable^.MotorStart;
   End;

 Function GetHeadSettle;
   Begin;
     GetHeadSettle := DriveParmTable^.HeadSettle;
   End;

 Function GetHeadLoad;
   Begin;
     GetHeadLoad := DriveParmTable^.HeadLoad;
   End;

 Function PhysFlops;
   Begin;
     Intr($11, Regs);
     If Regs.AX AND 1 = 0 Then
       PhysFlops := 0
     Else
       Case Regs.AX AND 192 Of

           0: PhysFlops := 1;
         64 : PhysFlops := 2;
         128: PhysFlops := 3;
         192: PhysFlops := 4;

       End;
   End;

 {$S+,F+}

 Procedure RecurseDir(Dir : DirStr; Files : String12; HandleIt : HandleProc; WhatWithDirs : Byte);

   Var
      Path        : PathStr;

      Name        : NameStr;

      Ext         : ExtStr;

   Procedure CorrectFileName;

     Var
        Find : SearchRec;

     Begin;
       If (Pos('*', Name + Ext) = 0) And (Pos('?', Name + Ext) = 0) Then
         Begin;
           FindFirst(Path + Name + Ext, AnyFile, Find);
           If Find.Attr = VolumeID Then
             FindNext(Find);
           Case Find.Attr AND Directory Of

             Directory: Begin;
                          Path := Path + Name + Ext + '\';
                          Name := '';
                          Ext := '';
                        End;

           End;
         End;
       Case Ext [0] Of

         #0: Ext := '.*';

       End;
       Case Name [0] Of

         #0: Name := '*';

       End;
     End;

   Procedure Hunt(Pth : String127);

     Var
        Fnd    : SearchRec;

        FSpec  : String [12];

        HJk    : PathStr;

     Begin;
       If (WhatWithDirs = DirsBefore) Then
         HandleIt(Copy(Pth, 1, Pred(Length(Pth))), False);
       FSplit(FExpand(Files), Path, Name, Ext);
       CorrectFileName;
       FSpec := Name + Ext;
       If Length(Pth) > 3 Then
         ChDir(Copy(Pth, 1, Pred(Length(Pth))))
       Else
         ChDir(Pth);
       FindFirst(FSpec, AnyFile, Fnd);
       If IOResult > 0 Then ;
       If DosError = 0 Then
         Begin;
           Repeat
            If (Fnd.Attr AND Directory = Directory) Or (Fnd.Attr AND VolumeID > 0) Then
              Repeat
               FindNext(Fnd);
              Until ((Fnd.Attr AND Directory = 0) And (Fnd.Attr AND VolumeID = 0)) Or (DosError <> 0);
            If DosError = 0 Then
              Begin;
                Path := Pth;
                HandleIt(Fnd.Name, Fnd.Attr AND Directory = 0);
                FindNext(Fnd);
              End;
           Until (DosError <> 0);
         End;
       FindFirst('*.*', Directory, Fnd);
       Repeat
        FindNext(Fnd);
       Until (DosError = 18) Or ((Fnd.Name <> '..') And (Fnd.Attr AND Directory = Directory));
       If (DosError = 0) And (Fnd.Attr AND Directory = Directory) Then
         Begin;
           Repeat
            HJk := ActiveDir;
            If (Fnd.Attr AND Directory = Directory) Then
              Begin;
                If HJk [Length(HJk)] = '\' Then
                  Hunt(HJk + Fnd.Name + '\')
                Else
                  Hunt(HJk + '\' + Fnd.Name + '\');
              End;
            ChDir(HJk);
            Repeat
             FindNext(Fnd);
            Until (Fnd.Attr AND Directory = Directory) Or (DosError <> 0);
           Until (DosError <> 0);
         End;
       If (WhatWithDirs = DirsAfter) Then
         HandleIt(Copy(Pth, 1, Pred(Length(Path))), False);
     End;

   Begin;
     Hunt(Dir);
   End;

 Function SingleDriveStatus : Byte;
   Begin;
     SingleDriveStatus := Mem [$0:$504];
   End;

 Procedure SetSingleDriveStatus(Status : Byte);
   Begin;
     Mem [$0:$504] := Status;
   End;

 Function int25(Drive : Char; StartSec : LongInt; SecNum : Word; Var Buf) : Word;

   Var
      StS,
      Sg, Os : Word;

      ReqPak : Record
                 L     : LongInt;
                 W     : Word;
                 P     : Pointer;
               End;

   Begin;
     StS := StartSec;
     If LargeHD = False Then
       Begin;
         Sg := Seg(Buf);
         Os := Ofs(Buf);
         Asm
           push     ds
           push     ss
           push     bp
           mov      ax, Sg
           push     ax
           pop      ds
           mov      bx, Os
           mov      dx, StS
           mov      cx, SecNum
           mov      al, Drive
           sub      al, 65
           mov      di, sp
           int      $25
           jc      @@Error

           xor     bx, bx
           jmp     @@Finis

    @@Error:
            mov     bx, ax

    @@Finis:
           mov      sp, di
           pop      bp
           pop      ss
           pop      ds
           mov      Os, bx
         End;
         int25 := Os;
      End
    Else
      Begin;
        Sg := Seg(ReqPak);
        Os := Ofs(ReqPak);
        ReqPak.L := StartSec;
        ReqPak.W := SecNum;
        ReqPak.P := @Buf;
        Asm
          push     ds
          push     ss
          push     bp
          mov      ax, Sg
          push     ax
          pop      ds
          mov      bx, Os
          mov      dx, StS
{          mov      cx, SecNum} mov     cx, $ffff
          mov      al, Drive
          sub      al, 65
          mov      di, sp
          int      $25
          jc      @@Error

          xor     bx, bx
          jmp     @@Finis

   @@Error:
           mov     bx, ax

   @@Finis:
          mov      sp, di
          pop      bp
          pop      ss
          pop      ds
          mov      Os, bx
        End;
        int25 := Os;
      End;
     If (Os = $0207) And (LargeHD = False) Then
       Begin;
         LargeHD := True;
         int25 := int25(Drive, StartSec, SecNum, Buf);
       End;
   End;

 Function int26(Drive : Char; StartSec, SecNum : Word; Var Buf) : Word;

   Var
      StS,
      Sg, Os : Word;

      ReqPak : Record
                 L     : LongInt;
                 W     : Word;
                 P     : Pointer;
               End;

   Begin;
     StS := StartSec;
     If LargeHD = False Then
       Begin;
         Sg := Seg(Buf);
         Os := Ofs(Buf);
         Asm
           push     ds
           push     ss
           push     bp
           mov      ax, Sg
           push     ax
           pop      ds
           mov      bx, Os
           mov      dx, StS
           mov      cx, SecNum
           mov      al, Drive
           sub      al, 65
           mov      di, sp
           int      $26
           jc      @@Error

           xor     bx, bx
           jmp     @@Finis

    @@Error:
            mov     bx, ax

    @@Finis:
           mov      sp, di
           pop      bp
           pop      ss
           pop      ds
           mov      Os, bx
         End;
         int26 := Os;
      End
    Else
      Begin;
        Sg := Seg(ReqPak);
        Os := Ofs(ReqPak);
        ReqPak.L := StartSec;
        ReqPak.W := SecNum;
        ReqPak.P := @Buf;
        Asm
          push     ds
          push     ss
          push     bp
          mov      ax, Sg
          push     ax
          pop      ds
          mov      bx, Os
          mov      dx, StS
{          mov      cx, SecNum} mov     cx, $ffff
          mov      al, Drive
          sub      al, 65
          mov      di, sp
          int      $26
          jc      @@Error

          xor     bx, bx
          jmp     @@Finis

   @@Error:
           mov     bx, ax

   @@Finis:
          mov      sp, di
          pop      bp
          pop      ss
          pop      ds
          mov      Os, bx
        End;
        int26 := Os;
      End;
     If (Os = $0207) And (LargeHD = False) Then
       Begin;
         LargeHD := True;
         int26 := int26(Drive, StartSec, SecNum, Buf);
       End;
   End;

 Function BootRecord.Read(Drive : Char) : Boolean;
   Begin;
     If int25(Drive, 0, 1, NearJump) <> 0 Then
       Read := False
     Else
       Read := True;
   End;

 Function BootRecord.Write(Drive : Char) : Boolean;
   Begin;
     If int26(Drive, 0, 1, NearJump) <> 0 Then
       Write := False
     Else
       Write := True;
   End;

 Constructor FATObj.Init(Drive : Char);
   Begin;
     If WorkBoot.Read(Drive) = False Then
       Begin;
         FATerror := True;
         Fail;
       End;
     With WorkBoot Do
       Begin;
         Size := BytesPerSector * SectorsPerFAT;
         If MediaDescriptor = $F8 Then
           FAT16 := True
         Else
           FAT16 := False;
         If MaxAvail < Size Then
           Begin;
             FATerror := True;
             Fail;
           End;
         GetMem(Table, Size);
       End;
     WorkDrive := Drive;
   End;

 Function FATObj.GetEntry(No : Word) : Word;

   Var
      GEi    : Real;

   Begin;
     If FAT16 Then
       GetEntry := (Table^ [Pred(No * 2)]) OR (Table^ [No * 2] SHL 8)
     Else
       Begin;
         GEi := (No * 1.5) - 0.5;
         If Frac(GEi) <> 0 Then
           GetEntry := ((Table^ [Trunc(GEi)] AND $F0) SHR 4) OR (Table^ [Succ(Trunc(GEi))] SHL 4)
         Else
           GetEntry := Table^ [Trunc(GEi)] OR ((Table^ [Succ(Trunc(GEi))] AND $0F) SHL 8);
       End;
   End;

 Procedure FATObj.SetEntry(No, vl : Word);

   Var
      GEi    : Real;

      j      : Word;

   Begin;
     If FAT16 Then
       Begin;
         Table^ [Pred(No * 2)] := vl AND $00FF;
         Table^ [No * 2] := Hi(vl AND $FF00);
       End
     Else
       Begin;
         GEi := (No * 1.5) - 0.5;
         If Frac(GEi) <> 0 Then
           Begin;
             j := Table^ [Trunc(GEi)];
             j := (j AND $0F) OR ((vl AND $000F) SHL 4);
             Table^ [Trunc(GEi)] := j;
             Table^ [Succ(Trunc(GEi))] := (vl AND $FF0) SHR 4;
           End
         Else
           Begin;
             Table^ [Trunc(GEi)] := Lo(vl);
             j := Table^ [Succ(Trunc(GEi))];
             j := (j AND $F0) OR ((vl AND $F00) SHR 8);
             Table^ [Succ(Trunc(GEi))] := j;
           End;
       End;
   End;

 Function FATObj.Read(No : Byte) : Boolean;
   Begin;
     If int25(WorkDrive, 1 + (Pred(No) * WorkBoot.SectorsPerFAT), WorkBoot.SectorsPerFAT, Table^) <> 0 Then
       Read := False
     Else
       Read := True;
   End;

 Function FATObj.Write(No : Byte) : Boolean;
   Begin;
     If int26(WorkDrive, 1 + (Pred(No) * WorkBoot.SectorsPerFAT), WorkBoot.SectorsPerFAT, Table^) <> 0 Then
       Write := False
     Else
       Write := True;
   End;

 Destructor FATObj.Done;
   Begin;
     FreeMem(Table, Size);
   End;

 Constructor CentralDirObj.Init(Drive : Char);
   Begin;
     If WorkBoot.Read(Drive) = False Then
       Begin;
         FATerror := True;
         Fail;
       End;
     Entries := WorkBoot.NumberOfRootEntries;
     WorkDrive := Drive;
     If MaxAvail < Entries * SizeOf(DirEntry) Then
       Begin;
         FATerror := True;
         Fail;
       End;
     GetMem(List, Entries * SizeOf(DirEntry));
   End;

 Function CentralDirObj.Read : Boolean;

   Var
      Rs     : Boolean;

   Begin;
     With WorkBoot Do
       If int25(WorkDrive, Succ((SectorsPerFAT * NumberOfFATs)),
                (Entries * SizeOf(DirEntry)) DIV BytesPerSector, List^) <> 0 Then
         Rs := False
       Else
         Rs := True;
     Read := Rs;
   End;

 Function CentralDirObj.GetFreeEntry(OffSet : Word) : Word;

   Var
      GFEi   : Word;

   Begin;
     For GFEi := OffSet To Entries Do
       Case List^ [GFEi].Name [1] Of

           #0,
         #229: Begin;
                 GetFreeEntry := GFEi;
                 Exit;
               End;

       End;
     GetFreeEntry := 0;
   End;

 Function CentralDirObj.Write : Boolean;

   Var
      Rs     : Boolean;

   Begin;
     With WorkBoot Do
       If int26(WorkDrive, Succ((SectorsPerFAT * NumberOfFATs)),
                (Entries * SizeOf(DirEntry)) DIV BytesPerSector, List^) <> 0 Then
         Rs := False
       Else
         Rs := True;
     Write := Rs;
   End;

 Destructor CentralDirObj.Done;
   Begin;
     FreeMem(List, Entries * SizeOf(DirEntry));
   End;

 Constructor SubDirObj.Init(Drive : Char);
   Begin;
     If WorkBoot.Read(Drive) = False Then
       Begin;
         FATerror := True;
         Fail;
       End;
     With WorkBoot Do
       Entries := (BytesPerSector * SectorsPerCluster) DIV SizeOf(DirEntry);
     WorkDrive := Drive;
     If MaxAvail < Entries * SizeOf(DirEntry) Then
       Begin;
         FATerror := True;
         Fail;
       End;
     GetMem(List, Entries * SizeOf(DirEntry));
   End;

 Function SubDirObj.Read(Clst : Word) : Boolean;

   Var
      Rs     : Boolean;

   Begin;
     With WorkBoot Do
       If int25(WorkDrive, Succ((SectorsPerFAT * NumberOfFATs)) +
                (NumberOfRootEntries * SizeOf(DirEntry)) DIV BytesPerSector + (Pred(Pred(Clst)) * SectorsPerCluster),
                SectorsPerCluster, List^) <> 0 Then
         Rs := False
       Else
         Rs := True;
     Read := Rs;
   End;

 Function SubDirObj.GetFreeEntry(OffSet : Word) : Word;

   Var
      GFEi   : Word;

   Begin;
     For GFEi := OffSet To Entries Do
       Case List^ [GFEi].Name [1] Of

           #0,
         #229: Begin;
                 GetFreeEntry := GFEi;
                 Exit;
               End;

       End;
     GetFreeEntry := 0;
   End;

 Function SubDirObj.Write(Clst : Word) : Boolean;

   Var
      Rs     : Boolean;

   Begin;
     With WorkBoot Do
{       If int26(WorkDrive, Pred(Clst) * SectorsPerCluster, SectorsPerCluster, List^) <> 0 Then}
       If int26(WorkDrive, Succ((SectorsPerFAT * NumberOfFATs)) +
                (Entries * SizeOf(DirEntry)) DIV BytesPerSector + (Pred(Pred(Clst)) * SectorsPerCluster),
                SectorsPerCluster, List^) <> 0 Then
         Rs := False
       Else
         Rs := True;
     Write := Rs;
   End;

 Destructor SubDirObj.Done;
   Begin;
     FreeMem(List, Entries * SizeOf(DirEntry));
   End;

 Function MakeName(Name : Array8) : String;

   Var
      wkst   : String;

   Begin;
     wkst [0] := Char(Pred(Pos(' ', Name)));
     If wkst [0] = #$FF Then
       wkst [0] := #8;
     Move(Name, wkst [1], 8);
     MakeName := wkst;
   End;

 Function AppendExt(Ext : Array3) : String;

   Var
      wkst   : String;

   Begin;
     wkst [0] := Char(Pred(Pos(' ', Ext)));
     If wkst [0] = #$FF Then
       wkst [0] := #3;
     Move(Ext, wkst [1], 3);
     If wkst <> '' Then
       AppendExt := '.' + wkst
     Else
       AppendExt := '';
   End;

 Begin
   GetIntVec($1E, Pointer(DriveParmTable));
 End.