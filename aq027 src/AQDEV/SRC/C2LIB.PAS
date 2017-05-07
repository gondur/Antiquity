
 {$Define Release}

 Unit C2Lib;

 Interface

 Uses
     Keyboard;

 Type
     String4      = String [4];
     String60     = String [60];

 Const
      LeftX            : Word = 1;
      RightX           : Word = 320;
      LowerY           : Word = 1;
      UpperY           : Word = 200;

      VGA256           = 255;

      Message          = #13#10'This is messy code! :-)'#13#10;

      DiscrNonCarriers = True;
      DiscrCarriers    = False;

      KillOnly1        = False;
      KillEmAll        = True;

      CivSelection     : Byte = 2;
      HumanCivs        : Byte = 1;
      ShowCivs         : Boolean = False;
      Hide             : Boolean = False;
      EndOfTurn        : Boolean = False;
      CompMov          : Boolean = False;
      WantNotice       : Byte = 1;
      ShowStatus       : Byte = 1;

      MaxCivilizations = 30;
      MaxAdvances      = 11;
      MaxImprovements  = 30;
      MaxUnitTypes     = 71;
      MaxTiles         = 148;
      MaxTerrains      = 29;
      MaxRawResources  = 10;
      MaxResources     = 26;
      MaxResTrans      = 16;
      MaxIBAdvReq      = 40;
      MaxUBAdvReq      = 121;
      MaxUBResReq      = 79;
      MaxIBResReq      = 56;
      MaxUnits         = 3000;
      MaxCities        = 1000;
      MaxAboutLines    = 119;
      MaxControls      = 3;
      MaxRoads         = 5;
      MaxCastes        = 5;
      MaxMessages      = 200;
      MaxUnitsUsed     : Word = 0;
      MaxCitiesUsed    : Word = 0;

{$IFDEF Release}
      MapFileName      = 'DATA\EARTH.MAP';
      UnitGfxFileName  = 'DATA\UNITS0.PIC';
      TileGfxFileName  = 'DATA\STLL0.PIC';
      CivInfoFileName  = 'TEXT\CIVILIZA.TXT';
      AdvanceFileName  = 'TEXT\ADVANCE.TXT';
      TileFileName     = 'TEXT\FIELD_GR.TXT';
      TerMoveFileName  = 'TEXT\MOVEMENT.TXT';
      ResAvailFileName = 'TEXT\RESAVAIL.TXT';
      ResPicFileName   = 'DATA\RES.PIC';
      ResourceFileName = 'TEXT\RESOURCE.TXT';
      ResTransFileName = 'TEXT\RESTRANS.TXT';
      UBResReqFileName = 'TEXT\UBRR.TXT';
      IBResReqFileName = 'TEXT\IBRR.TXT';
      UBAdvReqFileName = 'TEXT\UBAR.TXT';
      IBAdvReqFileName = 'TEXT\IBAR.TXT';
      FontFileName     = 'DATA\FONT.TXT';
      TerrainFileName  = 'TEXT\RESFCAT.TXT';
      UnitFileName     = 'TEXT\UNIT_TYP.TXT';
      ImprovementFileName
                       = 'TEXT\IMPROVEM.TXT';
      DescriptFileName = 'DATA\DESCRIPT.TXT';
      ConfigFileName   = 'AQ.CFG';
      KnownMapFileName = 'KNOWNMAP.($)';
      UnitBlockFileName= 'UNITINFO.($)';
      NoticeFileName   = '_NOTICE_.($)';
      MessageFileName  = '__MSGS__.($)';
      TerCapsFileName  = 'TEXT\UNIT_MOV.TXT';
      CityGfxFileName  = 'DATA\STLL1.PIC';
      CityBackFileName = 'DATA\CITY';
      CityFileName     = 'DATA\CITYNAME.TXT';
      AboutFileName    = 'DATA\ABOUT.TXT';
{$ELSE}
      MapFileName      = '\AQ\DATA\EARTH.MAP';
      UnitGfxFileName  = '\AQ\DATA\UNITS0.PIC';
      TileGfxFileName  = '\AQ\DATA\STLL0.PIC';
      CivInfoFileName  = '\AQ\TEXT\DB\CIVILIZA.TXT';
      AdvanceFileName  = '\AQ\TEXT\DB\ADVANCE.TXT';
      TileFileName     = '\AQ\TEXT\DB\FIELD_GR.TXT';
      TerMoveFileName  = '\AQ\TEXT\DB\MOVEMENT.TXT';
      ResAvailFileName = '\AQ\TEXT\DB\RESAVAIL.TXT';
      ResPicFileName   = '\AQ\DATA\RES.PIC';
      ResourceFileName = '\AQ\TEXT\DB\RESOURCE.TXT';
      ResTransFileName = '\AQ\TEXT\DB\RESTRANS.TXT';
      UBResReqFileName = '\AQ\TEXT\DB\UBRR.TXT';
      IBResReqFileName = '\AQ\TEXT\DB\IBRR.TXT';
      UBAdvReqFileName = '\AQ\TEXT\DB\UBAR.TXT';
      IBAdvReqFileName = '\AQ\TEXT\DB\IBAR.TXT';
      FontFileName     = '\AQ\DATA\FONT.TXT';
      TerrainFileName  = '\AQ\TEXT\DB\RESFCAT.TXT';
      UnitFileName     = '\AQ\TEXT\DB\UNIT_TYP.TXT';
      ImprovementFileName
                       = '\AQ\TEXT\DB\IMPROVEM.TXT';
      DescriptFileName = '\AQ\DATA\DESCRIPT.TXT';
      ConfigFileName   = '\AQ\SRC\AQ.CFG';
      KnownMapFileName = 'KNOWNMAP.($)';
      UnitBlockFileName= 'UNITINFO.($)';
      NoticeFileName   = '_NOTICE_.($)';
      MessageFileName  = '__MSGS__.($)';
      TerCapsFileName  = '\AQ\TEXT\DB\UNIT_MOV.TXT';
      CityGfxFileName  = '\AQ\DATA\STLL1.PIC';
      CityBackFileName = '\AQ\DATA\CITY';
      CityFileName     = '\AQ\DATA\CITYNAME.TXT';
      AboutFileName    = '\AQ\DATA\ABOUT.TXT';
{$ENDIF}

      Status           : Array [0..3] Of String [25] = ('NOT ACTIVE',
                                                        'LOCAL HUMAN',
                                                        'LOCAL COMPUTER (PRIM.)',
                                                        'LOCAL COMPUTER (CIV.)');

      UnitMoveFrames   = 6;
      UnitMoveDelay    = 20;

      Diplomacy        = 32;            { Used with ActionCaps }
      CarryGoods       = 64;
      CarryUnits       = 128;

      stReady          = 0;             { Used with Status }
      stIrrigating     = 1;
      stRoading        = 2;
      stForting        = 3;
      stCitying        = 4;
      stMoving         = 10;
      stSentrying      = 11;
      stFortifying     = 12;
      stSentried       = 13;
      stFortified      = 14;
      stTransported    = 15;
      stGotoing        = 16;
      stGotoingAndSentry
                       = 17;

      tFlat            = 1;
      tRiver           = 2;
      tCoast           = 4;
      tOcean           = 8;
      tMountains       = 16;
      tRough           = 32;            { Used with TerrainCaps }

      cpeSentry        = 1;
      cpeFortify       = 2;
      cpeGoto          = 3;
      cpeGotoAndSentry = 4;

      caWarriors       = 1;
      caMerchants      = 2;
      caScholars       = 3;
      caArtisans       = 4;
      caPeasants       = 5;             { Used with Castes }

      nUnitKilled      = 1;
      nUnitProduced    = 2;
      nResManufactured = 3;
      nImprProduced    = 4;
      nUnitStarved     = 5;
      nUnitNotPaid     = 6;
      nMassacred       = 7;
      nCityTaken       = 8;
      nCityReverted    = 9;
      nEthnicUnrest    = 10;
      nShipTaken       = 11;
      nCanProduce      = 12;
      nRefugeesArrive  = 13;
      nMessage         = 14;
      nCaravanRobbed   = 15;
      nModThreat       = 16;
      nVioThreat       = 17;
      nDeclareWar      = 18;
      nBuyResources    = 19;
      nSellResources   = 20;
      nBuyKnowledge    = 21;
      nSellKnowledge   = 22;
      nDemandMoney     = 23;
      nGiveMoney       = 24;
      nBuyRetraction   = 25;
      nSellRetraction  = 26;
      nBuyPeace        = 27;
      nSellPeace       = 28;
      nBuyBoycot       = 29;
      nSellBoycot      = 30;
      nBuyEmbargo      = 31;
      nSellEmbargo     = 32;
      nBuyWar          = 33;
      nSellWar         = 34;
      nBuyDefense      = 35;
      nSellDefense     = 36;
      nBronzeAge       = 37;
      nIronAge         = 38;
      nCaravanArrived  = 39;
      nTriggerExpired  = 40;
      nBuyResources_N  = 41;
      nSellResources_N = 42;
      nBuyKnowledge_N  = 43;
      nSellKnowledge_N = 44;
      nDemandMoney_N   = 45;
      nGiveMoney_N     = 46;
      nBuyRetraction_N = 47;
      nSellRetraction_N= 48;
      nBuyPeace_N      = 49;
      nSellPeace_N     = 50;
      nBuyBoycot_N     = 51;
      nSellBoycot_N    = 52;
      nBuyEmbargo_N    = 53;
      nSellEmbargo_N   = 54;
      nBuyWar_N        = 55;
      nSellWar_N       = 56;
      nBuyDefense_N    = 57;
      nSellDefense_N   = 58;
      nBuyResources_Y  = 59;
      nSellResources_Y = 60;
      nBuyKnowledge_Y  = 61;
      nSellKnowledge_Y = 62;
      nDemandMoney_Y   = 63;
      nGiveMoney_Y     = 64;
      nBuyRetraction_Y = 65;
      nSellRetraction_Y= 66;
      nBuyPeace_Y      = 67;
      nSellPeace_Y     = 68;
      nBuyBoycot_Y     = 69;
      nSellBoycot_Y    = 70;
      nBuyEmbargo_Y    = 71;
      nSellEmbargo_Y   = 72;
      nBuyWar_Y        = 73;
      nSellWar_Y       = 74;
      nBuyDefense_Y    = 75;
      nSellDefense_Y   = 76;

      uGoods           = 4096 OR 0 OR 0 OR 0;
      uGoTo            = 0 OR 8192 OR 0 OR 0;
      uSupply          = 4096 OR 8192 OR 0 OR 0;
      uAI              = 0 OR 0 OR 16384 OR 0;
      uEthnic          = 4096 OR 0 OR 16384 OR 0;
      uEmpowerment     = 0 OR 8192 OR 16384 OR 0;
      uCityProdEvent   = 4096 OR 8192 OR 16384 OR 0;
      uCityTrigger     = 0 OR 0 OR 0 OR 32768;
      uDrainRoute      = 4096 OR 0 OR 0 OR 32768;
      uLevelRoute      = 0 OR 8192 OR 0 OR 32768;

      empMessage       = 2048 OR 0 OR 0 OR 0 OR 0;
      empBuyResources  = 0 OR 4096 OR 0 OR 0 OR 0;
      empSellResources = 2048 OR 4096 OR 0 OR 0 OR 0;
      empBuyKnowledge  = 0 OR 0 OR 8192 OR 0 OR 0;
      empSellKnowledge = 2048 OR 0 OR 8192 OR 0 OR 0;
      empDemandMoney   = 0 OR 4096 OR 8192 OR 0 OR 0;
      empGiveMoney     = 2048 OR 4096 OR 8192 OR 0 OR 0;
      empBuyRetraction = 0 OR 0 OR 0 OR 16384 OR 0;
      empSellRetraction= 2048 OR 0 OR 0 OR 16384 OR 0;
      empBuyPeace      = 0 OR 4096 OR 0 OR 16384 OR 0;
      empSellPeace     = 2048 OR 4096 OR 0 OR 16384 OR 0;
      empBuyBoycot     = 0 OR 0 OR 8192 OR 16384 OR 0;
      empSellBoycot    = 2048 OR 0 OR 8192 OR 16384 OR 0;
      empBuyEmbargo    = 0 OR 4096 OR 8192 OR 16384 OR 0;
      empSellEmbargo   = 2048 OR 4096 OR 8192 OR 16384 OR 0;
      empBuyWar        = 0 OR 0 OR 0 OR 0 OR 32768;
      empSellWar       = 2048 OR 0 OR 0 OR 0 OR 32768;
      empBuyDefense    = 0 OR 4096 OR 0 OR 0 OR 32768;
      empSellDefense   = 2048 OR 4096 OR 0 OR 0 OR 32768;
      empModThreat     = 0 OR 0 OR 8192 OR 0 OR 32768;
      empVioThreat     = 0 OR 4096 OR 8192 OR 0 OR 32768;
      empDeclareWar    = 2048 OR 0 OR 8192 OR 0 OR 32768;

      shIrrigated      = 1;             { Used with ShadowMap }
      shRoaded         = 2;
      shForted         = 4;
      shCity           = 8;
      shExploited      = 16;
      shUnit           = 128;

      rFood            = 1;
      rTimber          = 2;
      rStone           = 3;
      rBronze          = 4;
      rIron            = 5;
      rSalt            = 6;
      rGold            = 7;
      rSpice           = 8;
      rWildHorses      = 9;
      rWildElephants   = 10;
      rTrndElephants   = 11;
      rWarhorses       = 12;
      rFlintDagger     = 13;
      rFlintSpear      = 14;
      rFlintSword      = 15;
      rFlintBow        = 16;
      rBronzeDagger    = 17;
      rBronzeSpear     = 18;
      rBronzeSword     = 19;
      rBronzeBow       = 20;
      rIronDagger      = 21;
      rIronSpear       = 22;
      rIronSword       = 23;
      rIronBow         = 24;
      rTools           = 25;     { Available Resources }
      rTrndHorses      = 26;

      impShrine        = 1;
      impTemple        = 2;
      impTempleComplex = 3;
      impMainTemple    = 4;
      impShipYard      = 5;
      impGreatShipYard = 6;
      impStockage      = 7;
      impEarthenRamp   = 8;
      impCityWalls     = 9;
      impFortification = 10;
      impArchives      = 11;
      impLibrary       = 12;
      impMainLibrary   = 13;
      impTutorsResid   = 14;
      impSchool        = 15;
      impStables       = 16;
      impCarpentersWS  = 17;
      impWarehouse     = 18;            { Used with City Improvements }
      impArena         = 19;
      impCapitolium    = 20;
      impGranary       = 21;
      impBarracks      = 22;
      impFlintmakersWS = 23;
      impBronzeSmith   = 24;
      impBlackSmith    = 25;
      impSchoolOfRiding= 26;
      impDocks         = 27;
      impMilitAcademy  = 28;
      impMinorAqueduct = 29;
      impMajorAqueduct = 30;

      _imShrine        = 1;
      _imTemple        = 2;
      _imTempleComplex = 4;
      _imMainTemple    = 8;
      _imShipYard      = 16;
      _imGreatShipYard = 32;
      _imStockage      = 64;
      _imEarthenRamp   = 128;
      _imCityWalls     = 256;
      _imFortification = 512;
      _imArchives      = 1024;
      _imLibrary       = 2048;
      _imMainLibrary   = 4096;
      _imTutorsResid   = 8192;
      _imSchool        = 16384;
      _imStables       = 32768;
      _imCarpentersWS  = 65536;
      _imWarehouse     = 131072;        { Used with City Improvements }
      _imArena         = 262144;
      _imCapitolium    = 524288;
      _imGranary       = 1048576;
      _imBarracks      = 2097152;
      _imFlintmakersWS = 4194304;
      _imBronzeSmith   = 8388608;
      _imBlackSmith    = 16777216;
      _imSchoolOfRiding= 33554432;
      _imDocks         = 67108864;
      _imMilitAcademy  = 134217728;
      _imMinorAqueduct = 268435456;
      _imMajorAqueduct = 536870912;

      resEngineering   = 1;
      resReligion      = 2;
      resSeafaring     = 3;
      resLiteracy      = 4;
      resTrade         = 5;
      resStoneWorking  = 6;
      resBronzeWorking = 7;
      resIronWorking   = 8;
      resAnimalTraining= 9;
      resWeaponCrafting= 10;
      resAgriculture   = 11;            { Used with Research }

      Pow              : Array [0..30] Of LongInt = (1, 2, 4, 8,
                                                     16, 32, 64, 128,
                                                     256, 512, 1024, 2048,
                                                     4096, 8192, 16384, 32768,
                                                     65536, 131072, 262144, 524288,
                                                     1048576, 2097152, 4194304, 8388608,
                                                     16777216, 33554432, 67108864, 134217728,
                                                     268435456, 536870912, 1073741824);

      StatusChar       : Array [0..17] Of Char = (' ', 'I', 'R', 'B', 'C', ' ',
                                                  ' ', ' ', ' ', ' ', 'M', 's',
                                                  'f', 'S', 'F', 'T', 'G', 'G');

      TerrainChanges   : String4 = ('IRBC');

      TCTimeRequired   : Array [1..4] Of Byte = (3, 2, 3, 0);

 Type
     XYMapArray   = Array [1..320, 1..200] Of Byte;
     MapArray     = Array [1..64000] Of Byte;
     BitMapArray  = Array [1..16, 1..16] Of Byte;
     PBitMapArray = ^BitMapArray;
     AreaRec      = Record
                      x1, y1,
                      x2, y2     : Word;

                      B          : Array [1..64000] Of Byte;
                    End;
     Writer       = Object
                      Body       : Array [0..255, 1..4, 1..5] Of Byte;

                      PenColour  : Byte;
                      BkGColour  : Byte;

                      Constructor Init(fn : String);
                      Procedure PtShadowWrite(x, y : Word; y1, y2 : Byte; S : String);
                      Procedure PtShadowPlot(x, y : Word; y1, y2 : Byte; c : Char);
                      Procedure WkShadowWrite(x, y : Word; S: String);
                      Procedure WkShadowPlot(x, y : Word; c : Char);
                      Procedure ShadowWrite(x, y : Word; S: String);
                      Procedure ShadowPlot(x, y : Word; c : Char);
                      Procedure SoftWrite(x, y : Word; S : String);
                      Procedure SoftPlot(x, y : Word; c : Char);
                      Procedure HardWrite(x, y : Word; S : String);
                      Procedure HardPlot(x, y : Word; c : Char);
                    End;
     KnownManager = Object
                      KnownMapSizeInBytes       : Word;
                      CurrentMapId              : LongInt;

                      Width, Height             : Word;

                      kf                        : File;

                      KMap                      : Array [0..Pred(320*200 DIV 8)] Of Byte;

                      Constructor Init(W, H : Word);
                      Constructor Load(Var src : File);
                      Procedure FlushKnownMap;
                      Procedure LoadMap(id : LongInt);
                      Function AllocKnownMap : LongInt;
                      Function IsKnown(id : LongInt; x, y : Word) : Boolean;
                      Procedure ClearKnownMap(id : LongInt);
                      Procedure MakeKnown(id : LongInt; x, y : Word);
                      Procedure MakeKnownCircle(id : LongInt; x, y : Word);
                      Destructor Done;
                    End;
     ZMachine     = Object
                      Tab      : String [15];
                      Tab2     : String [15];

                      c        : Word;

                      x_p      : Pointer;

                      ChunkPtr : Word;

                      LoNibble : Boolean;

                      ZChunk   : Array [1..8192] Of Byte;

                      Constructor Init;
                      Constructor Load(Var src : File);
                      Procedure x_init(p : Pointer);
                      Procedure xmit(b : Byte);
                      Function rexv : Byte;
                      Function ExpandStr(o : Word; len : Byte) : String;
                      Function PackStr(S : String) : Word;
                    End;
     PStrElement  = ^StringElement;
     StringElement= Record
                      Prev,
                      Next     : PStrElement;

                      S        : String [40];
                    End;
     StringLList  = Object
                      Work,
                      Head,
                      Tail     : PStrElement;

                      Elements : LongInt;

                      Constructor Init;
                      Procedure Add(St : String);
                      Function Get(N : LongInt) : String;
                      Procedure SetS(N : LongInt; St : String);
                      Destructor Done;
                    End;
     UnitManager  = Object
                      Block      : Array [1..MaxUnits DIV 6] Of Record
                                                                  UnitId  : Word;
                                                                  Data    : Array [1..3] Of Word;
                                                                End;

                      MaxUsed    : Word;

                      CurrentBlId: LongInt;

                      umf        : File;

                      Constructor Init;
                      Constructor Load(Var src : File);
                      Constructor OldLoad(Var src : File);
                      Procedure FlushBlock;
                      Procedure LoadBlock(ui : LongInt);
                      Function AllocUnitBlock : LongInt;
                      Function Locate(ui : LongInt; uid : Word; o : Word) : Word;
                      Procedure ClearUnitInfo(ui : LongInt; uid : Word);
                      Function AddUnitInfo(ui : LongInt; uid : Word; ucode : Word; D1, D2, D3 : Word) : Word;
                      Destructor Done;
                    End;
     NoticeManager= Object
                      Notice     : Array [1..MaxUnits DIV 6] Of Record
                                                                  nid    : Byte;
                                                                  cptr   : Byte;
                                                                  Data   : Array [1..3] Of Word;
                                                                End;
                      MaxUsed    : Word;

                      CurrentId  : LongInt;

                      nmf        : File;

                      Constructor Init;
                      Constructor Load(Var src : File);
                      Procedure FlushN;
                      Procedure LoadN(ni : LongInt);
                      Function AllocN : LongInt;
                      Function AddNotice(ni : LongInt; id : Byte; cp : Byte; d1, d2, d3 : Word) : Word;
                      Procedure ClearN(ni : LongInt; o : Word);
                      Destructor Done;
                    End;
     MsgManager   = Object
                      AllocMap   : Array [1..MaxMessages] Of Byte;

                      ms         : String60;

                      mmf        : File;

                      Constructor Init;
                      Constructor Load(Var src : File);
                      Procedure Save(Var dst : File);
                      Function Store(St : String60) : Byte;
                      Function Get(No : Byte) : String60;
                      Procedure Clear(No : Byte);
                      Destructor Done;
                    End;
     ResTrans     = Object
                      OutR, InR       : Byte;
                      ImpReq          : Word;
                      ProdReq         : Word;
                      Ratio           : Byte;

                      Constructor Init(Var src : Text);
                    End;
     ResReq       = Object
                      Pr              : Byte;
                      Re              : Byte;
                      Amount          : Byte;

                      Constructor Init(Var src : Text);
                    End;
     AdvReq       = Object
                      Pr              : Byte;
                      Ad              : Word;
                      ScoreReq        : Word;

                      Constructor Init(Var src : Text);
                    End;
     Terrain      = Object
                      TCtype,
                      MoveCost,
                      DefenseBonus    : Byte;

                      ITR,
                      ActionCaps      : Byte;

                      { Coding of ActionCaps:
                          0-May Irrigate       <\
                          1-May build Roads    < \
                          2-May build Forts    < Settlers
                          3-May build Cities   </
                          4-Reserved
                          5-May perform acts of Diplomacy   <-  Emissaries
                          6-May carry Goods                 <-  Caravans
                          7-May carry Units                 <-  Ships
                      }

                      Name            : String [20];

                      ResourceYield   : Array [1..MaxRawResources] Of Byte;

                      Constructor Init(Var src : Text);
                    End;
     Improvement  = Object
                      Name       : String [20];
                      ProdReq    : Word;
                      ParentImp  : Byte;
                      Cost       : Word;

                      PicOffSet  : Word;
                      PicLength  : Byte;

                      Constructor Init(Var src : Text; Var picptr : Word);
                    End;
     SimpleTile   = Object
                      BitMap          : BitMapArray;

                      Constructor Init(Var gfx : File);
                      Procedure Display(sx, sy : Word);
                    End;
     CityTile     = Object(SimpleTile)
                      Procedure Display(sx, sy : Word);
                    End;
     Tile         = Object(SimpleTile)
                      TerrainType     : Byte;

                      Constructor Init(Var src : Text; Var gfx : File);
                    End;
     GameUnit     = Object
                      X, Y       : Word;
                      Owner      : Byte;
                      MovesLeft  : ShortInt;
                      UType      : Byte;
                      SuppliesLeft
                                 : ShortInt;
                      Status     : Byte;

                      Constructor Init(nx, ny : Word; ut, o : Byte);
                      Constructor Load(Var src : File);
                    End;
     UnitType     = Object
                      Cost,
                      MaxMove,
                      Attack,
                      Defense,
                      Capacity   : Byte;

                      ImpReq     : Byte;

                      Name       : String [20];

                      ActionCaps : Byte;

                      TerrainCaps: Byte;

                      BitMap     : BitMapArray;

                      Constructor Init(Var src : Text; Var gfx : File);
                      Procedure Display(sx, sy : Word; r : Byte; ABitMap : PBitMapArray);
                    End;
     TilePtr      = ^Tile;
     TileArray    = Array [1..MaxTiles] Of Tile;
     CityTileArray= Array [1..MaxTiles] Of CityTile;
     TerrainPtr   = ^Terrain;
     GameUnitPtr  = ^GameUnit;
     CityPtr      = ^City;
     CityArray    = Array [1..MaxCities] Of CityPtr;
     UnitArray    = Array [1..MaxUnitTypes] Of UnitType;
     PKnownManager= ^KnownManager;
     PUnitManager = ^UnitManager;
     PNoticeManager
                  = ^NoticeManager;
     RoadArray    = Array [1..MaxRoads] Of BitMapArray;
     TileMap      = Object
                      Width,
                      Height     : Word;

                      Shadow,
                      Body       : ^MapArray;

                      Ti         : ^TileArray;

                      Ter        : Array [1..MaxTerrains] Of Terrain;

                      Constructor Init(lx, ly, rx, uy : Word; fn : String);
                      Constructor Load(Var src : File);
                      Procedure LoadTerrain(tfn : String);
                      Procedure LoadTiles(tfn, gfn : String);
                      Procedure LoadMap(lx, ly : Word; fn : String);
                      Procedure ShadowSet(x, y : Word; btp : Byte);
                      Procedure ShadowClear(x, y : Word; btp : Byte);
                      Function ShadowGet(x, y : Word) : Byte;
                      Function TiGet(x, y : Word) : TilePtr;
                      Function TerGet(x, y : Word) : TerrainPtr;
                      Function Get(x, y : Word) : Byte;
                      Procedure Put(x, y : Word; b : Byte);
                      Procedure Display(x, y, hx, hy : Word);
                      Function GetDefenseBonus(x, y : Word) : Word;
                      Destructor Done;
                    End;
     City         = Object
                      X, Y            : Word;
                      Owner           : Word;
                      NameIdx         : Word;
                      NameLen         : Byte;
                      Stores          : Array [1..MaxResources] Of Byte;
                      Population      : Word;
                      EthnicDist      : Array [1..MaxCivilizations] Of Byte;
                      Activity        : Word;
                      Progress        : Word;
                      Goal            : Word;
                      ResExp          : Byte;
                      Improv          : LongInt;
                      Surroundings    : Byte;

                      Constructor Init(nx, ny : Word; N : String; o, s : Byte);
                      Constructor Load(Var src : File);
                      Procedure AddEthnic(people : Byte; add : Integer);
                      Function Production : Word;
                      Function ResExpFields : Word;
                      Function Taxes : Word;
                      Function FoodReq : Word;
                    End;
     Civilization = Object
                      StartX,
                      StartY     : Word;

                      Control    : Byte;
                        { 0-Not Active   1-Local Human   2-Local Computer }

                      NamedCities,
                      BuiltCities: Word;

                      ResActivity: Word;

                      Knowledge  : Array [0..MaxAdvances] Of Word;

                      Population : LongInt;

                      ScienceCity: Integer;

                      Primitive  : Boolean;

                      Colour     : Byte;

                      Name       : String [20];

                      Wealth     : LongInt;

                      BlockId,
                      KnownId,
                      NoticeId   : LongInt;

                      NLP        : ShortInt;

                      CasteBonus : Array [1..MaxCastes] Of Byte;

                      CasteRank  : Array [1..MaxCastes] Of Byte;

                      Constructor Init(Var src : Text);
                      Constructor Load(Var src : File);
                      Procedure Ready(K : PKnownManager; UM : PUnitManager; N : PNoticeManager);
                    End;
     Advance      = Object
                      Name            : String [20];

                      MaxRes          : Word;

                      ResYear         : Integer;

                      Constructor Init(var src : Text);
                    End;
     AdvanceArray = Array [1..MaxAdvances] Of Advance;
     PAdvanceArray= ^AdvanceArray;
     Resource     = Object
                      Name            : String [20];

                      Constructor Init(Var src : Text);
                    End;

 Procedure AboutGame;
 Procedure ListCommands;
 Function GetArea(x1, y1, x2, y2 : Word) : Pointer;
 Function OpenGraph(gd, gm : Integer; Pth : String) : Integer;
 Procedure RGBPal(no, red, green, blue : Byte);
 Procedure PutArea(Var T : Pointer);
 Procedure OneLiner(St : String);
 Procedure SplitLiner(St : String);
 Procedure Frame3D(x1, y1, x2, y2 : Word);
 Procedure FrameReverse3D(x1, y1, x2, y2 : Word);
 Function Request(Info : String; Len : Byte; Allowed : String) : String;
 Function Select(S : String; W : Byte; Li : StringLList) : LongInt;
 Procedure ColourFilter(Var B : BitMapArray);
 Function GetStr(Var Jk : String) : String;
 Function GetInt(Var Jk : String) : LongInt;
 Procedure BlinkWait;

 Var
    Screen        : Array [0..199, 0..319] Of Byte ABSOLUTE $A000:0000;

    PW            : ^Writer;

    R             : ^RoadArray;

    CityNames     : ^ZMachine;

    Kbd           : KbdType;

    Y, BZ, IR     : Integer;

 Implementation

 Uses
     Crt,
     C2Str,
     Graph;

 {$F+}

 Procedure BlinkWait;
   Begin;
     SetFillStyle(SolidFill, LightRed);
     PW^.HardWrite(118, 70, '                  ');
     Bar(116, 68, 300, 80);
     Kbd.IntDelay(200);
     PW^.BkGColour := Black;
     PW^.ShadowWrite(118, 70, '* PRESS ANY KEY *');
     Kbd.IntDelay(200);
   End;

 Function DetectVGA256 : Integer;
   Begin;
     DetectVGA256 := 0;
   End;

 {$F-}

 Function GetArea;

   Var
      P      : ^AreaRec;

      i,
      xp, yp : Word;

   Begin;
     GetMem(P, 8 + Succ(y2 - y1) * Succ(x2 - x1));
     P^.x1 := x1;
     P^.x2 := x2;
     P^.y1 := y1;
     P^.y2 := y2;
     i := 0;
     yp := y1;
     xp := x1;
     Repeat
      Inc(i);
      P^.B [i] := Screen [yp, xp];
      Inc(xp);
      If xp > x2 Then
        Begin;
          xp := x1;
          Inc(yp);
        End;
     Until (yp > y2);
     GetArea := P;
   End;

 Function OpenGraph;

   Var
      AutoPtr     : Pointer;

   Begin;
     If (gd = VGA) And (gm = VGA256) Then
       Begin;
         AutoPtr := @DetectVGA256;
         gd := InstallUserDriver('VGA256', AutoPtr);
         gd := Detect;
         InitGraph(gd, gm, Pth);
       End
     Else
       InitGraph(gd, gm, Pth);
     OpenGraph := GraphResult;
   End;

 Procedure RGBPal;
   Begin;
     Port [$3C8] := no;
     Port [$3C9] := red;
     Port [$3C9] := green;
     Port [$3C9] := blue;
   End;

 Procedure PutArea;

   Var
      P      : ^AreaRec;

      i,
      xp, yp : Word;

   Begin;
     P := T;
     T := NIL;
     i := 0;
     With P^ Do
       Begin;
         yp := y1;
         xp := x1;
         Repeat
          Inc(i);
          Screen [yp, xp] := B [i];
          Inc(xp);
          If xp > x2 Then
            Begin;
              xp := x1;
              Inc(yp);
            End;
         Until (yp > y2);
       End;
     FreeMem(P, 8 + Succ(P^.y2 - P^.y1) * Succ(P^.x2 - P^.x1));
   End;

 Procedure OneLiner;

   Var
      P      : Pointer;

      x1, x2 : Word;

   Begin;
     SetFillStyle(SolidFill, LightGray);
     x2 := Length(St) * 5 + 10;
     x1 := (320 - x2) DIV 2;
     x2 := x2 + x1;
     P := GetArea(x1 - 1, 49, x2 + 1, 61);
     Bar(x1, 50, x2, 60);
     FrameReverse3D(x1 - 1, 49, x2 + 1, 61);
     PW^.PenColour := White;
     PW^.BkGColour := DarkGray;
     PW^.ShadowWrite(x1 + 5, 54, St);
     Kbd.GetKey;
     PutArea(P);
   End;

 Procedure SplitLiner;

   Var
      P      : Pointer;

      J2     : String;

      sap    : Byte;

      i, j,
      x1, x2 : Word;

   Begin;
     i := 0;
     sap := 0;
     Repeat
      Repeat
       Inc(i);
      Until (St [i] = ' ') Or (i > Length(St));
      If i <= Length(St) DIV 2 Then
        sap := i;
     Until (i > Length(St) DIV 2);
     J2 := Copy(St, Succ(i), Length(St) - i);
     St [0] := Char(Lo(Pred(i)));
     SetFillStyle(SolidFill, LightGray);
     x2 := Length(St) * 5 + 10;
     x1 := (320 - x2) DIV 2;
     x2 := x2 + x1;
     P := GetArea(x1 - 1, 43, x2 + 1, 61);
     Bar(x1, 44, x2, 60);
     FrameReverse3D(x1 - 1, 43, x2 + 1, 61);
     PW^.PenColour := White;
     PW^.BkGColour := DarkGray;
     PW^.ShadowWrite(x1 + 5, 48, St);
     PW^.ShadowWrite(x1 + 5, 54, J2);
     Kbd.GetKey;
     PutArea(P);
   End;

 Procedure ListCommands;
   Begin;
     ClearDevice;
     PW^.PenColour := White;
     PW^.BkGColour := DarkGray;
     PW^.WkShadowWrite(10, 10, 'F1: HELP');
     PW^.WkShadowWrite(10, 17, 'F2: SAVE GAME');
     PW^.WkShadowWrite(10, 24, 'F3: RESTORE PALETTE*');
     PW^.WkShadowWrite(10, 31, 'F4: CASTE MENU');
     PW^.WkShadowWrite(10, 38, 'F5: SCIENCE MENU');
     PW^.WkShadowWrite(10, 45, 'F6: REVEAL MAP*');
     PW^.WkShadowWrite(10, 52, 'F7: QUIT GAME');
     PW^.WkShadowWrite(10, 59, 'F8: REQUIREMENTS MENU');
     PW^.WkShadowWrite(10, 66, 'F9: CONJURE UNIT*');
     PW^.WkShadowWrite(10, 73, 'F10: MAIN MENU');

     PW^.PenColour := LightGreen;
     PW^.WkShadowWrite(10, 87, 's-G: GOTO');
     PW^.WkShadowWrite(10, 94, '  S: SENTRY');
     PW^.WkShadowWrite(10, 101, '  F: FORTIFY');
     PW^.WkShadowWrite(10, 108, 's-U: UNLOAD');
     PW^.WkShadowWrite(10, 115, '  I: IRRIGATE');
     PW^.WkShadowWrite(10, 122, '  R: BUILD ROADS');
     PW^.WkShadowWrite(10, 129, '  C: BUILD CITY');
     PW^.WkShadowWrite(10, 136, '  W: WAIT');
     PW^.WkShadowWrite(10, 143, 'SPC: REST');
     PW^.WkShadowWrite(10, 150, 's-D: DISBAND');
     PW^.WkShadowWrite(10, 157, '  L: LAY DOWN ARMS');
     PW^.WkShadowWrite(10, 164, 's-M: MASSACRE');
     PW^.WkShadowWrite(10, 171, 's-E: EMPOWER');
     PW^.WkShadowWrite(10, 178, '  .: INSPECT CITIES (KBD)');
     PW^.WkShadowWrite(10, 185, '  R: RELEASE UNITS MODE (KBD)');

     PW^.PenColour := LightRed;
     PW^.WkShadowWrite(130, 94, ' * - DEBUGGING FEATURE');

     PW^.PenColour := LightBlue;
     PW^.WkShadowWrite(130, 10, 'IN THE CITY SCREEN, USE THE');
     PW^.WkShadowWrite(130, 17, 'F-KEYS WITH SHIFT, CTRL OR ALT');
     PW^.WkShadowWrite(130, 24, 'AS A SUBSTITUTE FOR THE MOUSE.');

     PW^.PenColour := LightRed;
     PW^.WkShadowWrite(130, 87, '(KBD) - NO MOUSE? USE THIS!');
     Kbd.GetKey;
   End;

 Procedure AboutGame;

   Type
       AboutLines = Array [1..MaxAboutLines] Of String [36];
       PAboutLines= ^AboutLines;

   Var
      src         : Text;

      i           : Word;

      AboutText   : PAboutLines;

      LinePtr,
      PixelPtr    : Word;

   Begin;
     SetFillStyle(SolidFill, LightGray);
     Bar(75, 35, 245, 165);
     Frame3D(79, 39, 241, 161);
     FrameReverse3D(74, 34, 246, 166);
     LinePtr := 1;
     PixelPtr := 1;
     GetMem(AboutText, SizeOf(AboutLines));
     Assign(src, AboutFileName);
     Reset(src);
     For i := 1 To MaxAboutLines Do
       Begin;
         ReadLn(src, AboutText^ [i]);
         If Copy(AboutText^ [i], 1, 2) = '.C' Then
           Begin;
             Delete(AboutText^ [i], 1, 2);
             AboutText^ [i] := Dup(' ', (32 - Length(AboutText^ [i])) DIV 2) + AboutText^ [i];
           End;
         AboutText^ [i] := Pad(AboutText^ [i], ' ', 32);
       End;
     Close(src);
     PW^.PenColour := White;
     PW^.BkGColour := Black;
     SetColor(LightGray);
     Repeat
      For i := 41 To 160 Do
        Move(Screen [i, 80], Screen [Pred(i), 80], 160);
      Kbd.IntDelay(120);
      If PixelPtr < 6 Then
        Begin;
          Line(80, 160, 240, 160);
          If Copy(AboutText^ [LinePtr], 1, 2) = '.!' Then
            Begin;
              PW^.PenColour := LightCyan;
              PW^.PtShadowWrite(80+1, 160+1, PixelPtr, PixelPtr, Copy(AboutText^ [LinePtr], 3, 29));
              PW^.PenColour := White;
            End
          Else
            PW^.PtShadowWrite(80+1, 160+1, PixelPtr, PixelPtr, AboutText^ [LinePtr]);
          Inc(PixelPtr);
        End
      Else
        Begin;
          Line(80, 160, 240, 160);
          PixelPtr := 1;
          Inc(LinePtr);
          If LinePtr > MaxAboutLines Then
            LinePtr := 1;
        End;
     Until (Kbd.Pressed);
     Kbd.GetKey;
     FreeMem(AboutText, SizeOf(AboutLines));
   End;

 Function Request;

   Var
      m,
      i, x, y, j  : Word;

      S           : String;

      Ch          : Char;

      P           : Pointer;

   Begin;
     If Len + 1 > Length(Info) Then
       i := Succ(Len) + 1
     Else
       i := Succ(Length(Info));
     x := (320 - i * 5) DIV 2;
     y := (200 - 15) DIV 2;
     SetFillStyle(SolidFill, LightGray);
     P := GetArea(x - 1, y - 1, x + i * 5 + 1, y + 15 + 1);
     Bar(x, y, x + i * 5, y + 15);
     FrameReverse3D(x - 1, y - 1, x + i * 5 + 1, y + 15 + 1);
     PW^.BkGColour := DarkGray;
     PW^.PenColour := White;
     PW^.WkShadowWrite(x + 2, y + 2, Info);
     SetFillStyle(SolidFill, Black);
     Bar(x + 2, y + 7, x + Succ(Len) * 5 + 2, y + 13);
     x := x + 3;
     y := y + 9;
     i := 0;
     S := '';
     PW^.PenColour := White;
     PW^.BkGColour := Black;
     Repeat
      PW^.HardWrite(x, y, S);
      Repeat
       SetColor(White);
       Line(x + i * 5, y + 4, x + i * 5 + 4, y + 4);
       Kbd.IntDelay(200);
       SetColor(Black);
       Line(x + i * 5, y + 4, x + i * 5 + 4, y + 4);
       Kbd.IntDelay(200);
      Until Keypressed;
      Ch := UpCase(Readkey);
      If (Pos(Ch, Allowed) > 0) And (i < Len) Then
        Begin;
          S := S + Ch;
          Inc(i);
        End
      Else
        If (Ch = #8) And (i > 0) Then
          Begin;
            Dec(i);
            Dec(S [0]);
            PW^.HardWrite(x, y, S + ' ');
          End;
     Until (Ch = #13) Or ((Ch = #27) And (Pos(#27, Allowed) > 0));
     If Ch = #13 Then
       Request := S
     Else
       If Ch = #27 Then
         Request := #27;
     PutArea(P);
   End;

 Function Select;

   Var
      i, x1,
      x2, y1,
      y2     : Word;

      P      : Pointer;

   Begin;
     If Li.Elements = 0 Then
       Begin;
         Select := 0;
         Exit;
       End;
     i := W * 5 + 3;
     x1 := Pred((320 - i) DIV 2);
     x2 := x1 + i;
     i := Succ(Li.Elements) * 6 + 3;
     y1 := Pred((200 - i) DIV 2);
     y2 := y1 + i;
     P := GetArea(x1, y1, x2, y2);
     SetFillStyle(SolidFill, LightBlue);
     Bar(x1, y1, x2, y2);
     FrameReverse3D(x1, y1, x2, y2);
     PW^.PenColour := LightCyan;
     PW^.BkGColour := Black;
     PW^.WkShadowWrite(x1 + 3, y1 + 3, S);
     PW^.PenColour := White;
     For i := 1 To Li.Elements Do
       Begin;
         PW^.WkShadowWrite(x1 + 3, y1 + 3 + (i * 6), UpStr(Copy(Li.Get(i), 1, W)));
         Kbd.HotArea(x1 + 1, y1 + 1 + (i * 6), x1 + 1 + (W * 5), y1 + 1 + (i * 6) + 6, i + 200);
       End;
     i := 1;
     Repeat
      PW^.BkGColour := Red;
      PW^.PenColour := White;
      PW^.HardWrite(x1 + 3, y1 + 3 + (i * 6), Pad(UpStr(Li.Get(i)), ' ', W));
      Kbd.GetKey;
      Case Kbd.Press Of

        UpKey: Begin;
                 PW^.BkGColour := LightBlue;
                 PW^.HardWrite(x1 + 3, y1 + 3 + (i * 6), Dup(' ', W));
                 PW^.BkGColour := Black;
                 PW^.WkShadowWrite(x1 + 3, y1 + 3 + (i * 6), UpStr(Li.Get(i)));
                 Dec(i);
               End;
        DnKey: Begin;
                 PW^.BkGColour := LightBlue;
                 PW^.HardWrite(x1 + 3, y1 + 3 + (i * 6), Dup(' ', W));
                 PW^.BkGColour := Black;
                 PW^.WkShadowWrite(x1 + 3, y1 + 3 + (i * 6), UpStr(Li.Get(i)));
                 Inc(i);
               End;
          201
           ..
          255: If Kbd.Press - 200 <= Li.Elements Then
                 Begin;
                   PW^.BkGColour := LightBlue;
                   PW^.HardWrite(x1 + 3, y1 + 3 + (i * 6), Dup(' ', W));
                   PW^.BkGColour := Black;
                   PW^.WkShadowWrite(x1 + 3, y1 + 3 + (i * 6), UpStr(Li.Get(i)));
                   i := Kbd.Press - 200;
                   PW^.BkGColour := Red;
                   PW^.HardWrite(x1 + 3, y1 + 3 + (i * 6), Pad(UpStr(Li.Get(i)), ' ', W));
                   Kbd.Press := Enter;
                   Delay(100);
                 End;

      End;
      If i = 0 Then
        i := Li.Elements
      Else
        If i > Li.Elements Then
          i := 1;
     Until (Kbd.Press = Enter) Or (Kbd.Press = ESC);
     If Kbd.Press <> ESC Then
       Select := i
     Else
       Select := 0;
     Kbd.Press := 0;
     PutArea(P);
   End;

 Procedure ColourFilter;

   Var
      i, j        : Word;

   Begin;
     For i := 1 To 16 Do
       For j := 1 To 16 Do
         Case B [i, j] Of

              96
              ..
           96+15: Inc(B [i, j], 144);

         End;
   End;

 Function GetStr;
   Begin;
     Delete(Jk, 1, Pos('"', Jk));
     GetStr := Copy(Jk, 1, Pred(Pos('"', Jk)));
     Delete(Jk, 1, Succ(Pos('";', Jk)));
   End;

 Function GetInt;

   Var
      w      : String;

   Begin;
     w := '';
     While (Pos(Jk [1], '-0123456789') = 0) And (Length(Jk) > 0) Do
       Delete(Jk, 1, 1);
     While (Pos(Jk [1], '-0123456789') <> 0) And (Length(Jk) > 0) Do
       Begin;
         w := w + Jk [1];
         Delete(Jk, 1, 1);
       End;
     If Jk [1] = ';' Then
       Delete(Jk, 1, 1);
     GetInt := StrToInt(w);
   End;

 Procedure Frame3D;
   Begin;
     SetColor(DarkGray);
     Rectangle(x1, y1, x2, y2);
     SetColor(White);
     Line(x1 + 1, y2, x2, y2);
     Line(x2, y2, x2, y1);
   End;

 Procedure FrameReverse3D;
   Begin;
     SetColor(White);
     Rectangle(x1, y1, x2, y2);
     SetColor(DarkGray);
     Line(x1 + 1, y2, x2, y2);
     Line(x2, y2, x2, y1);
   End;

 Constructor Writer.Init;

   Var
      i, j, k, l  : Word;

      Jk          : String;

      src         : Text;

   Begin;
     Assign(src, FontFileName);
     Reset(src);
     For i := 0 To 15 Do
       Begin;
         For j := 1 To 5 Do
           Begin;
             ReadLn(src, Jk);
             For k := 1 To 4 Do
               For l := 0 To 15 Do
                 Begin;
                   If Jk [l * 5 + k] <> ' ' Then
                     Body [i * 16 + l, k, j] := 15
                   Else
                     Body [i * 16 + l, k, j] := 0;
                 End;
           End;
         ReadLn(src);
       End;
     Close(src);
     PenColour := White;
     BkGColour := 0;
   End;

 Procedure Writer.SoftWrite;

   Var
      i           : Word;

   Begin;
     For i := 1 To Length(S) Do
       SoftPlot(x + Pred(i) * 5, y, S [i]);
   End;

 Procedure Writer.SoftPlot;

   Var
      i, j        : Word;

   Begin;
     Dec(x);
     Dec(y);
     For i := x To x + 3 Do
       For j := y To y + 4 Do
         If Body [Byte(c), Succ(i) - x, Succ(j) - y] <> 0 Then
           Screen [j, i] := PenColour;
   End;

 Procedure Writer.ShadowWrite;

   Var
      i           : Word;

   Begin;
     For i := 1 To Length(S) Do
       ShadowPlot(x + Pred(i) * 5, y, S [i]);
   End;

 Procedure Writer.ShadowPlot;

   Var
      i, j        : Word;

   Begin;
     For i := x To x + 3 Do
       For j := y To y + 4 Do
         If Body [Byte(c), Succ(i) - x, Succ(j) - y] <> 0 Then
           Screen [j, i] := BkGColour;
     Dec(x);
     Dec(y);
     For i := x To x + 3 Do
       For j := y To y + 4 Do
         If Body [Byte(c), Succ(i) - x, Succ(j) - y] <> 0 Then
           Screen [j, i] := PenColour;
   End;

 Procedure Writer.PtShadowWrite;

   Var
      i           : Word;

   Begin;
     For i := 1 To Length(S) Do
       PtShadowPlot(x + Pred(i) * 5, y, y1, y2, S [i]);
   End;

 Procedure Writer.PtShadowPlot;

   Var
      i, j        : Word;

   Begin;
     Dec(y);
     For i := x To x + 3 Do
       For j := y To y + (y2 - y1) Do
         If Body [Byte(c), Succ(i) - x, (j + y1) - y] <> 0 Then
           Screen [j, i] := BkGColour;
     Dec(x);
     For i := x To x + 3 Do
       For j := y To y + (y2 - y1) Do
         If Body [Byte(c), Succ(i) - x, (j + y1) - y] <> 0 Then
           Screen [j, i] := PenColour;
   End;

 Procedure Writer.WkShadowWrite;

   Var
      i           : Word;

   Begin;
     For i := 1 To Length(S) Do
       WkShadowPlot(x + Pred(i) * 5, y, S [i]);
   End;

 Procedure Writer.WkShadowPlot;

   Var
      i, j        : Word;

   Begin;
     Dec(y);
     For i := x To x + 3 Do
       For j := y To y + 4 Do
         If Body [Byte(c), Succ(i) - x, Succ(j) - y] <> 0 Then
           Screen [j, i] := BkGColour;
     Dec(x);
     For i := x To x + 3 Do
       For j := y To y + 4 Do
         If Body [Byte(c), Succ(i) - x, Succ(j) - y] <> 0 Then
           Screen [j, i] := PenColour;
   End;

 Procedure Writer.HardWrite;

   Var
      i, j        : Word;

   Begin;
     For i := 1 To Length(S) Do
       Begin;
         HardPlot(x + Pred(i) * 5, y, S [i]);
         For j := y - 1 To y + 3 Do
           Screen [j, x + (Pred(i) * 5) + 3] := BkGColour;
       End;
   End;

 Procedure Writer.HardPlot;

   Var
      i, j        : Word;

   Begin;
     Dec(x);
     Dec(y);
     For i := x To x + 3 Do
       For j := y To y + 4 Do
         If Body [Byte(c), Succ(i) - x, Succ(j) - y] <> 0 Then
           Screen [j, i] := PenColour
         Else
           Screen [j, i] := BkGColour;
   End;

 Constructor KnownManager.Init;
   Begin;
     Width := W;
     Height := H;
     CurrentMapId := MaxLongInt;
     KnownMapSizeInBytes := Round((W * H) / 8 + 0.5);
     Assign(kf, KnownMapFileName);
     Rewrite(kf, 1);
   End;

 Constructor KnownManager.Load;

   Var
      Buf         : Pointer;

      l           : LongInt;

   Begin;
     GetMem(Buf, 4096);
     BlockRead(src, Self, 10);
     CurrentMapId := MaxLongInt;
     Assign(kf, KnownMapFileName);
     Rewrite(kf, 1);
     BlockRead(src, l, SizeOf(l));
     Repeat
      BlockRead(src, Buf^, 4096);
      BlockWrite(kf, Buf^, 4096);
      Dec(l, 4096);
     Until (l <= 4096);
     BlockRead(src, Buf^, l);
     BlockWrite(kf, Buf^, l);
     FreeMem(Buf, 4096);
   End;

 Procedure KnownManager.FlushKnownMap;
   Begin;
     If CurrentMapId = MaxLongInt Then
       Exit;
     Seek(kf, CurrentMapId);
     BlockWrite(kf, KMap, KnownMapSizeInBytes);
     CurrentMapId := MaxLongInt;
   End;

 Function KnownManager.AllocKnownMap;
   Begin;
     FlushKnownMap;
     CurrentMapId := FileSize(kf);
     Seek(kf, CurrentMapId);
     FillChar(KMap, KnownMapSizeInBytes, 0);
     BlockWrite(kf, KMap, KnownMapSizeInBytes);
     AllocKnownMap := CurrentMapId;
   End;

 Procedure KnownManager.LoadMap;
   Begin;
     FlushKnownMap;
     Seek(kf, id);
     BlockRead(kf, KMap, KnownMapSizeInBytes);
     CurrentMapId := id;
   End;

 Function KnownManager.IsKnown;

   Var
      i           : Word;

   Begin;
     If CurrentMapId <> id Then
       LoadMap(id);
     i := (Pred(y) * Width + Pred(x));
     If (KMap [i DIV 8] AND Pow [i MOD 8] <> 0) And (x <= Width) And (y <= Height) Then
       IsKnown := True
     Else
       IsKnown := False;
   End;

 Procedure KnownManager.ClearKnownMap;
   Begin;
     If CurrentMapId <> id Then
       LoadMap(id);
     FillChar(KMap, SizeOf(KMap), 0);
     FlushKnownMap;
   End;

 Procedure KnownManager.MakeKnown;

   Var
      i           : Word;

   Begin;
     If CurrentMapId <> id Then
       LoadMap(id);
     i := (Pred(y) * Width + Pred(x));
     KMap [i DIV 8] := KMap [i DIV 8] OR Pow [i MOD 8];
   End;

 Procedure KnownManager.MakeKnownCircle;

   Var
      i, j, k     : Word;

   Begin;
     If CurrentMapId <> id Then
       LoadMap(id);
     For i := x - 1 To x + 1 Do
       For j := y - 1 To y + 1 Do
         Begin;
           k := (Pred(j) * Width + Pred(i));
           KMap [k DIV 8] := KMap [k DIV 8] OR Pow [k MOD 8];
         End;
   End;

 Destructor KnownManager.Done;
   Begin;
     FlushKnownMap;
     Close(kf);
     Erase(kf);
   End;

 Constructor ZMachine.Init;
   Begin;
     ChunkPtr := 1;
     Tab := 'ACDEFHILNORSTUY';
     Tab2 := 'BGJKMPQVWXZ -.''';
   End;

 Constructor ZMachine.Load;
   Begin;
     BlockRead(src, Self, SizeOf(ZMachine));
   End;

 Procedure ZMachine.x_init;
   Begin;
     x_p := p;
     c := 0;
     LoNibble := True;
   End;

 Procedure ZMachine.xmit;
   Begin;
     Case LoNibble Of

        True: Begin;
                Byte(x_p^) := Byte(x_p^) AND $F0;
                Byte(x_p^) := Byte(x_p^) OR b;
              End;
       False: Begin;
                Byte(x_p^) := Byte(x_p^) AND $0F;
                Byte(x_p^) := Byte(x_p^) OR b SHL 4;
                Inc(LongInt(x_p));
              End;

     End;
     Inc(c);
     LoNibble := NOT LoNibble;
   End;

 Function ZMachine.rexv;
   Begin;
     Case LoNibble Of

        True: rexv := Byte(x_p^) AND $0F;
       False: Begin;
                rexv := Byte(x_p^) SHR 4;
                Inc(LongInt(x_p));
              End;

     End;
     LoNibble := NOT LoNibble;
   End;

 Function ZMachine.PackStr;

   Var
      i      : Word;

      b      : Byte;

   Begin;
     x_init(@ZChunk [ChunkPtr]);
     For i := 1 To Length(S) Do
       Begin;
         b := Pos(S [i], Tab);
         If b > 0 Then
           xmit(Pred(b))
         Else
           Begin;
             xmit(15);
             xmit(Pred(Pos(S [i], Tab2)));
           End;
       End;
     PackStr := ChunkPtr;
     Inc(ChunkPtr, Round(c / 2 + 0.5));
   End;

 Function ZMachine.ExpandStr;
   Var
      S           : String;

      b           : Byte;

   Begin;
     S := '';
     x_init(@ZChunk [o]);
     Repeat
      b := rexv;
      If b = 15 Then
        S := S + Tab2 [Succ(rexv)]
      Else
        S := S + Tab [Succ(b)];
     Until (Length(S) >= len);
     ExpandStr := S;
   End;

 Constructor StringLList.Init;
   Begin;
     Work := NIL;
     Head := NIL;
     Tail := NIL;
     Elements := 0;
   End;

 Procedure StringLList.Add;
   Begin;
     Inc(Elements);
     GetMem(Work, SizeOf(StringElement));
     Work^.S := St;
     If Tail <> NIL Then
       Begin;
         Tail^.Next := Work;
         Work^.Next := NIL;
         Work^.Prev := Tail;
         Tail := Work;
       End
     Else
       Begin;
         Head := Work;
         Tail := Work;
         Work^.Next := NIL;
         Work^.Prev := NIL;
       End;
   End;

 Function StringLList.Get;

   Var
      i      : Word;

   Begin;
     If N > Elements DIV 2 Then
       Begin;
         i := Elements;
         Work := Tail;
         While (i > N) Do
           Begin;
             Dec(i);
             Work := Work^.Prev;
           End;
       End
     Else
       Begin;
         i := 1;
         Work := Head;
         While (i < N) Do
           Begin;
             Inc(i);
             Work := Work^.Next;
           End;
       End;
     Get := Work^.S;
   End;

 Procedure StringLList.SetS;

   Var
      i      : Word;

   Begin;
     If N > Elements DIV 2 Then
       Begin;
         i := Elements;
         Work := Tail;
         While (i > N) Do
           Begin;
             Dec(i);
             Work := Work^.Prev;
           End;
       End
     Else
       Begin;
         i := 1;
         Work := Head;
         While (i < N) Do
           Begin;
             Inc(i);
             Work := Work^.Next;
           End;
       End;
     Work^.S := St;
   End;

 Destructor StringLList.Done;

   Var
      W2     : Pointer;

   Begin;
     Work := Tail;
     While Elements > 0 Do
       Begin;
         W2 := Work^.Prev;
         FreeMem(Work, SizeOf(StringElement));
         Work := W2;
         Dec(Elements);
       End;
   End;

 Constructor UnitManager.Init;
   Begin;
     Assign(umf, UnitBlockFileName);
     Rewrite(umf, 1);
     CurrentBlId := MaxLongInt;
   End;

 Constructor UnitManager.Load;

   Var
      Buf         : Pointer;

      l           : LongInt;

   Begin;
     GetMem(Buf, 4096);
     Assign(umf, UnitBlockFileName);
     Rewrite(umf, 1);
     BlockRead(src, l, SizeOf(l));
     Repeat
      BlockRead(src, Buf^, 4096);
      BlockWrite(umf, Buf^, 4096);
      Dec(l, 4096);
     Until (l <= 4096);
     BlockRead(src, Buf^, l);
     BlockWrite(umf, Buf^, l);
     CurrentBlId := MaxLongInt;
     FreeMem(Buf, 4096);
   End;

 Constructor UnitManager.OldLoad;

   Var
      Buf         : Array [1..MaxUnits DIV 6] Of Record
                                                   id     : Word;
                                                   Data   : Array [1..2] Of Word;
                                                 End;

      i, j        : Word;

      l           : LongInt;

   Begin;
     Assign(umf, NoticeFileName);
     Rewrite(umf, 1);
     BlockRead(src, l, SizeOf(l));
     For i := 1 To l DIV (SizeOf(Buf) + 2) Do
       Begin;
         BlockRead(src, Buf, SizeOf(Buf));
         BlockRead(src, MaxUsed, SizeOf(MaxUsed));
         FillChar(Block, SizeOf(Block), 0);
         For j := 1 To MaxUsed Do
           Begin;
             Block [j].UnitId := Buf [j].id;
             Block [j].Data [1] := Buf [j].Data [1];
             Block [j].Data [2] := Buf [j].Data [2];
           End;
         BlockWrite(umf, Block, SizeOf(Block));
         BlockWrite(umf, MaxUsed, SizeOf(MaxUsed));
       End;
     CurrentBlId := MaxLongInt;
   End;

 Procedure UnitManager.FlushBlock;
   Begin;
     If CurrentBlId <> MaxLongInt Then
       Begin;
         Seek(umf, CurrentBlId);
         BlockWrite(umf, Block, SizeOf(Block));
         BlockWrite(umf, MaxUsed, 2);
       End;
   End;

 Procedure UnitManager.LoadBlock;
   Begin;
     If CurrentBlId <> ui Then
       FlushBlock;
     Seek(umf, ui);
     BlockRead(umf, Block, SizeOf(Block));
     BlockRead(umf, MaxUsed, 2);
     CurrentBlId := ui;
   End;

 Function UnitManager.AllocUnitBlock;
   Begin;
     FlushBlock;
     Seek(umf, FileSize(umf));
     FillChar(Block, SizeOf(Block), 0);
     MaxUsed := 0;
     CurrentBlId := FilePos(umf);
     FlushBlock;
     AllocUnitBlock := CurrentBlId;
   End;

 Function UnitManager.Locate;

   Var
      i      : Word;

   Begin;
     If ui <> CurrentBlId Then
       LoadBlock(ui);
     i := 0;
     For i := o + 1 To MaxUsed Do
       If (Block [i].UnitId = uid)
       Or ((Block [i].UnitId AND 4095 = uid AND 4095) And (uid AND $F000 = 0)) Then
         Begin;
           Locate := i;
           Exit;
         End;
     Locate := Succ(i);
   End;

 Procedure UnitManager.ClearUnitInfo;

   Var
      i      : Word;

   Begin;
     i := 0;
     Repeat
      i := Locate(ui, uid, i);
      FillChar(Block [i], SizeOf(Block [i]), 0);
      If i = MaxUsed Then
        Dec(MaxUsed);
     Until (i > MaxUsed);
   End;

 Function UnitManager.AddUnitInfo;

   Var
      i      : Word;

   Begin;
     If ui <> CurrentBlId Then
       LoadBlock(ui);
     i := Locate(ui, 0, 0);
     If (i > MaxUsed) Then
       Begin;
         Inc(MaxUsed);
         i := MaxUsed;
       End
     Else
       If (i = 0) Then
         Exit;
     With Block [i] Do
       Begin;
         UnitId := uid OR ucode;
         Data [1] := D1;
         Data [2] := D2;
         Data [3] := D3;
       End;
     AddUnitInfo := i;
   End;

 Destructor UnitManager.Done;
   Begin;
     FlushBlock;
     Close(umf);
     Erase(umf);
     CurrentBlId := MaxLongInt;
   End;

 Constructor NoticeManager.Init;
   Begin;
     Assign(nmf, NoticeFileName);
     Rewrite(nmf, 1);
     CurrentId := MaxLongInt;
   End;

 Constructor NoticeManager.Load;

   Var
      Buf         : Pointer;

      l           : LongInt;

   Begin;
     GetMem(Buf, 4096);
     Assign(nmf, UnitBlockFileName);
     Rewrite(nmf, 1);
     BlockRead(src, l, SizeOf(l));
     Repeat
      BlockRead(src, Buf^, 4096);
      BlockWrite(nmf, Buf^, 4096);
      Dec(l, 4096);
     Until (l <= 4096);
     BlockRead(src, Buf^, l);
     BlockWrite(nmf, Buf^, l);
     CurrentId := MaxLongInt;
     FreeMem(Buf, 4096);
   End;

 Procedure NoticeManager.FlushN;
   Begin;
     If CurrentId <> MaxLongInt Then
       Begin;
         Seek(nmf, CurrentId);
         BlockWrite(nmf, Notice, SizeOf(Notice));
         BlockWrite(nmf, MaxUsed, 2);
       End;
   End;

 Procedure NoticeManager.LoadN;
   Begin;
     If CurrentId <> ni Then
       FlushN
     Else
       Exit;
     Seek(nmf, ni);
     BlockRead(nmf, Notice, SizeOf(Notice));
     BlockRead(nmf, MaxUsed, 2);
     CurrentId := ni;
   End;

 Function NoticeManager.AllocN;
   Begin;
     FlushN;
     Seek(nmf, FileSize(nmf));
     FillChar(Notice, SizeOf(Notice), 0);
     MaxUsed := 0;
     CurrentId := FilePos(nmf);
     FlushN;
     AllocN := CurrentId;
   End;

 Function NoticeManager.AddNotice;

   Var
      i      : Word;

   Begin;
     If ni <> CurrentId Then
       LoadN(ni);
     Inc(MaxUsed);
     i := MaxUsed;
     With Notice [i] Do
       Begin;
         nid := id;
         cptr := cp;
         Data [1] := d1;
         Data [2] := d2;
         Data [3] := d3;
       End;
     AddNotice := i;
   End;

 Procedure NoticeManager.ClearN;
   Begin;
     If ni <> CurrentId Then
       LoadN(ni);
     If o >= MaxUsed Then
       MaxUsed := 0;
     FillChar(Notice, SizeOf(Notice [1]) * o, 0);
   End;

 Destructor NoticeManager.Done;
   Begin;
     FlushN;
     Close(nmf);
     Erase(nmf);
     CurrentId := MaxLongInt;
   End;

 Constructor MsgManager.Init;

   Var
      i      : Word;

   Begin;
     Assign(mmf, MessageFileName);
     Rewrite(mmf, 1);
     ms := '';
     For i := 1 To MaxMessages Do
       BlockWrite(mmf, ms, SizeOf(String60));
     FillChar(AllocMap, SizeOf(AllocMap), 0);
   End;

 Constructor MsgManager.Load;

   Var
      i      : Word;

   Begin;
     BlockRead(src, AllocMap, SizeOf(AllocMap));
     Assign(mmf, MessageFileName);
     Rewrite(mmf, 1);
     For i := 1 To MaxMessages Do
       Begin;
         BlockRead(src, ms, SizeOf(String60));
         BlockWrite(mmf, ms, SizeOf(String60));
       End;
   End;

 Procedure MsgManager.Save;

   Var
      i      : Word;

   Begin;
     BlockWrite(dst, AllocMap, SizeOf(AllocMap));
     Seek(mmf, 0);
     For i := 1 To MaxMessages Do
       Begin;
         BlockRead(mmf, ms, SizeOf(String60));
         BlockWrite(dst, ms, SizeOf(String60));
       End;
   End;

 Function MsgManager.Store(St : String60) : Byte;

   Var
      i      : Word;

   Begin;
     i := 0;
     Repeat
      Inc(i);
     Until (AllocMap [i] = 0) Or (i > MaxMessages);
     If i <= MaxMessages Then
       Begin;
         Seek(mmf, Pred(i) * SizeOf(String60));
         BlockWrite(mmf, St, SizeOf(String60));
         AllocMap [i] := 1;
         Store := i;
         Exit;
       End;
     Store := 0;
   End;

 Function MsgManager.Get;
   Begin;
     Seek(mmf, Pred(No) * SizeOf(String60));
     BlockRead(mmf, ms, SizeOf(String60));
     Get := ms;
   End;

 Procedure MsgManager.Clear(No : Byte);
   Begin;
     AllocMap [No] := 0;
   End;

 Destructor MsgManager.Done;
   Begin;
     Close(mmf);
     Erase(mmf);
   End;

 Constructor Civilization.Init;

   Var
      Jk          : String;

      i           : Word;

   Begin;
     ReadLn(src, Jk);
     Name := GetStr(Jk);
     StartX := GetInt(Jk);
     StartY := GetInt(Jk);
     Primitive := GetInt(Jk) <> 0;
     Colour := GetInt(Jk);
     NamedCities := 0;
     BuiltCities := 0;
     ResActivity := 0;
     ScienceCity := 0;
     For i := 0 To MaxAdvances Do
       Knowledge [i] := 0;
     Case Colour Of

          96
          ..
       96+15: Inc(Colour, 144);

     End;
     For i := 1 To 5 Do
       Begin;
         CasteBonus [i] := 0;
         CasteRank [i] := i;
       End;
   End;

 Constructor Civilization.Load;
   Begin;
     BlockRead(src, Self, SizeOf(Civilization));
   End;

 Procedure Civilization.Ready;
   Begin;
     If Control <> 0 Then
       Begin;
         KnownId := K^.AllocKnownMap;
         BlockId := UM^.AllocUnitBlock;
         NoticeId := N^.AllocN;
       End;
   End;

 Constructor Advance.Init;

   Var
      Jk     : String;

   Begin;
     ReadLn(src, Jk);
     Name := GetStr(Jk);
     MaxRes := GetInt(Jk);
     ResYear := GetInt(Jk);
   End;

 Constructor Resource.Init;

   Var
      Jk     : String;

   Begin;
     ReadLn(src, Jk);
     GetInt(Jk);
     Name := GetStr(Jk);
   End;

 Constructor Improvement.Init;

   Var
      Jk          : String;

   Begin;
     ReadLn(src, Jk);
     GetInt(Jk);
     Name := GetStr(Jk);
     ProdReq := GetInt(Jk) * 7;
     Cost := ProdReq;
     ParentImp := GetInt(Jk);
     PicOffset := picptr;
     PicLength := GetInt(Jk);
     Inc(picptr, PicLength);
   End;

 Constructor GameUnit.Init;
   Begin;
     X := nx;
     Y := ny;
     MovesLeft := 0;
     UType := ut;
     Owner := o;
     SuppliesLeft := 5;
     Status := stReady;
   End;

 Constructor GameUnit.Load;
   Begin;
     BlockRead(src, X, SizeOf(GameUnit));
   End;

 Constructor ResTrans.Init;

   Var
      Jk     : String;

   Begin;
     ReadLn(src, Jk);
     OutR := GetInt(Jk);
     InR := GetInt(Jk);
     ImpReq := GetInt(Jk);
     ProdReq := GetInt(Jk);
     Ratio := GetInt(Jk);
   End;

 Constructor ResReq.Init;

   Var
      Jk     : String;

   Begin;
     ReadLn(src, Jk);
     Pr := GetInt(Jk);
     Re := GetInt(Jk);
     Amount := GetInt(Jk);
   End;

 Constructor AdvReq.Init;

   Var
      Jk     : String;

   Begin;
     ReadLn(src, Jk);
     Pr := GetInt(Jk);
     Ad := GetInt(Jk);
     ScoreReq := GetInt(Jk);
   End;

 Constructor Terrain.Init;

   Var
      i, j        : Word;

      f2          : Text;

      Jk          : String;

   Begin;
     For i := 1 To MaxRawResources Do
       ResourceYield [i] := 0;
     ReadLn(src, Jk);
     j := GetInt(Jk);
     Name := GetStr(Jk);
     TCtype := GetInt(Jk);
     ITR := GetInt(Jk);
     Assign(f2, TerMoveFileName);
     Reset(f2);
     ReadLn(f2);
     Repeat
      ReadLn(f2, Jk);
     Until (GetInt(Jk) = TCtype) Or (EOF(f2));
     Dec(TCtype);
     GetStr(Jk);
     MoveCost := GetInt(Jk);
     DefenseBonus := GetInt(Jk);
     ActionCaps := GetInt(Jk);
     Close(f2);
     Assign(f2, ResAvailFileName);
     Reset(f2);
     ReadLn(f2);
     Repeat
      ReadLn(f2, Jk);
      If GetInt(Jk) = j Then
        Begin;
          i := GetInt(Jk);
          Case i Of

            rBronze: If C2Lib.Y >= BZ Then
                       ResourceYield [i] := GetInt(Jk);
              rIron: If C2Lib.Y >= IR Then
                       ResourceYield [i] := GetInt(Jk);
            Else
              ResourceYield [i] := GetInt(Jk);

          End;
        End;
     Until EOF(f2);
     Close(f2);
   End;

 Constructor TileMap.Init;
   Begin;
     Width := Succ(rx - lx);
     Height := Succ(uy - ly);
     GetMem(Body, Width * Height);
     GetMem(Shadow, Width * Height);
     FillChar(Shadow^, Width * Height, 0);
     LoadMap(lx, ly, fn);
     LoadTiles(TileFileName, TileGfxFileName);
     LoadTerrain(TerrainFileName);
   End;

 Constructor TileMap.Load;
   Begin;
     BlockRead(src, Width, SizeOf(Width));
     BlockRead(src, Height, SizeOf(Height));
     GetMem(Body, Width * Height);
     GetMem(Shadow, Width * Height);
     BlockRead(src, Shadow^, Width * Height);
     BlockRead(src, Body^, Width * Height);
     LoadTiles(TileFileName, TileGfxFileName);
     LoadTerrain(TerrainFileName);
   End;

 Procedure TileMap.LoadTerrain;

   Var
      src         : Text;

      i           : Word;

   Begin;
     Assign(src, tfn);
     Reset(src);
     ReadLn(src);
     For i := 1 To MaxTerrains Do
       Ter [i].Init(src);
     Close(src);
   End;

 Procedure TileMap.LoadTiles;

   Var
      src         : Text;

      gfx         : File;

      i           : Word;

   Begin;
     Assign(src, tfn);
     Assign(gfx, gfn);
     Reset(src);
     ReadLn(src);
     Reset(gfx, 1);
     Seek(gfx, 521);                            { Size of useless header }
     GetMem(Ti, SizeOf(TileArray));
     For i := 1 To MaxTiles Do
       Ti^ [i].Init(src, gfx);
     Close(src);
     Close(gfx);
   End;

 Procedure TileMap.LoadMap;

   Var
      src         : File;

      i, j        : Word;

   Begin;
     Assign(src, fn);
     Reset(src, 1);
     Seek(src, 673);                            { Skip the useless header }
     Seek(src, FilePos(src) + Pred(lx) * 200 + Pred(ly));
     j := 1;
     For i := 1 To Width Do
       Begin;
         BlockRead(src, Body^ [j], Height);
         Inc(j, Height);
         Seek(src, FilePos(src) + 200 - Height);
       End;
     Close(src);
   End;

 Procedure TileMap.Display;

   Procedure BitPut(hx, hy, x1, y1, x2, y2, o : Word);

     Var
        x, y : Word;

     Begin;
       Dec(hx);
       Dec(hy);
       For x := x1 To x2 Do
         For y := y1 To y2 Do
           Case R^ [o, x, y] Of

               1
              ..
             255: Screen [hy + y, hx + x] := R^ [o, x, y];

           End;
     End;

   Var
      m, l   : Word;

      i, j   : Integer;

      b      : Byte;

   Begin;
     b := ShadowGet(x, y);
     Ti^ [Get(x, y)].Display(hx, hy);
     If (b AND shIrrigated <> 0) Then
       Begin;
         For l := hx To hx + 15 Do
           For m := hy To hy + 15 Do
             Case Screen [m, l] Of

               32
               ..
               42: Inc(Screen [m, l], 5);

             End;
       End;
     SetColor(151);
     l := 0;
     If (b AND shRoaded <> 0) Then
     For j := -1 To 1 Do
       For i := -1 To 1 Do
           If (i + 2 * j <> 0) Then
             Begin;
               If (ShadowGet(x + i, y + j) AND shRoaded <> 0) Then
                 Case Pow [l] Of

                     1: BitPut(hx, hy, 1, 1, 16, 8, 2);
                     2: BitPut(hx, hy, 1, 1, 16, 8, 3);
                     4: BitPut(hx, hy, 1, 1, 16, 8, 1);
                     8: BitPut(hx, hy, 1, 1, 8, 16, 4);
                    16: BitPut(hx, hy, 9, 1, 16, 16, 4);
                    32: BitPut(hx, hy, 1, 9, 16, 16, 1);
                    64: BitPut(hx, hy, 1, 9, 16, 16, 3);
                   128: BitPut(hx, hy, 1, 9, 16, 16, 2);

                 End;
               Inc(l);
             End;
     If (b AND shForted <> 0) Then
       BitPut(hx, hy, 1, 1, 16, 16, 5);
   End;

 Function TileMap.GetDefenseBonus;
   Begin;
     GetDefenseBonus := TerGet(x, y)^.DefenseBonus;
   End;

 Procedure TileMap.ShadowSet;
   Begin;
     Shadow^ [Pred(x) * Height + y] := Shadow^ [Pred(x) * Height + y] OR btp;
   End;

 Procedure TileMap.ShadowClear;
   Begin;
     Shadow^ [Pred(x) * Height + y] := Shadow^ [Pred(x) * Height + y] AND (NOT btp);
   End;

 Function TileMap.ShadowGet;
   Begin;
     ShadowGet := Shadow^ [Pred(x) * Height + y];
   End;

 Function TileMap.TiGet;
   Begin;
     TiGet := @Ti^ [Get(x, y)];
   End;

 Function TileMap.TerGet;
   Begin;
     TerGet := @Ter [Ti^ [Get(x, y)].TerrainType];
   End;

 Function TileMap.Get;
   Begin;
     Get := Body^ [Pred(x) * Height + y];
   End;

 Procedure TileMap.Put;
   Begin;
     Body^ [Pred(x) * Height + y] := b;
   End;

 Destructor TileMap.Done;
   Begin;
     FreeMem(Body, Width * Height);
     FreeMem(Shadow, Width * Height);
     FreeMem(Ti, SizeOf(TileArray));
   End;

 Constructor SimpleTile.Init;
   Begin;
     BlockRead(gfx, BitMap, SizeOf(BitMap));
     ColourFilter(BitMap);
   End;

 Procedure SimpleTile.Display;

   Var
      j           : Word;

   Begin;
     For j := 1 To 16 Do
       Move(BitMap [j], Screen [j + Pred(sy), sx], 16);
   End;

 Procedure CityTile.Display;

   Var
      i, j        : Word;

   Begin;
     For i := 1 To 16 Do
       For j := 1 To 16 Do
         Case BitMap [j, i] Of

             1
            ..
           255: Screen [j + Pred(sy), i + Pred(sx)] := BitMap [j, i];

         End;
   End;

 Constructor Tile.Init;

   Var
      Jk          : String;

   Begin;
     ReadLn(src, Jk);
     TerrainType := GetInt(Jk);
     TerrainType := GetInt(Jk);
     SimpleTile.Init(gfx);
   End;

 Constructor UnitType.Init;

   Var
      Jk          : String;

      i, j        : Word;

      f2          : Text;

   Begin;
     ReadLn(src, Jk);
     i := GetInt(Jk);
     Name := GetStr(Jk);
     Attack := GetInt(Jk);
     Defense := GetInt(Jk);
     MaxMove := GetInt(Jk);
     Capacity := GetInt(Jk);
     ActionCaps := GetInt(Jk);
     ImpReq := GetInt(Jk);
     Cost := (Attack + Defense) DIV 10 + Capacity;
     TerrainCaps := 0;
     Assign(f2, TerCapsFileName);
     Reset(f2);
     ReadLn(f2);
     Repeat
      ReadLn(f2, Jk);
      j := GetInt(Jk);
      If j = i Then
        TerrainCaps := TerrainCaps OR Pow [Pred(GetInt(Jk))];
     Until (EOF(f2)) Or (j > i);
     Close(f2);
     BlockRead(gfx, BitMap, SizeOf(BitMap));
     ColourFilter(BitMap);
   End;

 Procedure UnitType.Display;

   Var
      i, j        : Word;

   Begin;
     For i := sx To sx + 15 Do
       For j := sy To sy + 15 Do
         Case BitMap [Succ(j - sy), Succ(i - sx)] Of

             1
            ..
             9,
            11
            ..
           255: Screen [j, i] := BitMap [Succ(j - sy), Succ(i - sx)];
            10: Screen [j, i] := r;
             0: If ABitMap <> NIL Then
                  Screen [j, i] := ABitMap^ [Succ(j - sy), Succ(i - sx)];

         End;
   End;

 Constructor City.Init;
   Begin;
     X := nx;
     Y := ny;
     Surroundings := s;
     Owner := o;
     NameLen := Length(N);
     NameIdx := CityNames^.PackStr(N);
     FillChar(Stores, SizeOf(Stores), 0);
     Population := 10;
     FillChar(EthnicDist, SizeOf(EthnicDist), 0);
     EthnicDist [Owner] := 100;
     Activity := 0;
     Progress := 0;
     Goal := 0;
     ResExp := 0;
     Improv := 0;
   End;

 Constructor City.Load;
   Begin;
     BlockRead(src, X, SizeOf(City));
   End;

 Procedure City.AddEthnic;

   Var
      Eth    : Array [1..MaxCivilizations] Of Word;

      i, j   : Word;

   Begin;
     For i := 1 To MaxCivilizations Do
       Eth [i] := Round(Population * (EthnicDist [i] / 100));
     Population := Population + add;
     Eth [people] := Eth [People] + add;
     For i := 1 To MaxCivilizations Do
       EthnicDist [i] := Round(Eth [i] / (Population / 100));
   End;

 Function City.Production;
   Begin;
     Production := Succ(Population DIV 20);
   End;

 Function City.ResExpFields;
   Begin;
     ResExpFields := Population DIV 50;
   End;

 Function City.Taxes;
   Begin;
     Taxes := Succ(Population DIV 30);
   End;

 Function City.FoodReq;
   Begin;
     FoodReq := Population DIV 20;
   End;

 End.