
 {$R-,I-,S-}

 Program AQ;

 Uses
     C2G;

 Begin
   C2Game.Init;
   If (InitStatus <> ExitGame) Then
     Begin;
       C2Game.Play;
       C2Game.Done;
     End;
 End.