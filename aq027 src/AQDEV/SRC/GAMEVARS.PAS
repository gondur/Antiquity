                      CivInfo    : Array [1..MaxCivilizations] Of Civilization;
                      UnitPointer,
                      CivPointer : Word;

                      PFWidth,
                      PFHeight,
                      SX, SY     : Word;

                      PCt        : ^CityTileArray;

                      Bits       : Array [0..255] Of Byte;

                      PFMatrix   : Array [1..20*11] Of Word;

                      ImprBuildAR: Array [1..MaxIBAdvReq] Of AdvReq;

                      UnitBuildAR: Array [1..MaxUBAdvReq] Of AdvReq;

                      ImprBuildRR: Array [1..MaxIBResReq] Of ResReq;

                      UnitBuildRR: Array [1..MaxUBResReq] Of ResReq;

                      W          : Writer;

                      K          : ^KnownManager;

                      UM         : ^UnitManager;

                      N          : ^NoticeManager;

                      Msg        : ^MsgManager;

                      CN         : ^ZMachine;

                      Road       : RoadArray;

                      Adv        : PAdvanceArray;

                      Res        : Array [1..MaxResources] Of Resource;

                      ResX       : Array [1..MaxResTrans] Of ResTrans;

                      ResPic     : Array [1..MaxResources, 1..8, 1..8] Of Byte;

                      Imp        : Array [1..MaxImprovements] Of Improvement;

                      Un         : Array [1..MaxUnits] Of GameUnit;

                      C          : CityArray;

                      Map        : TileMap;

                      U          : ^UnitArray;

                      OvrVwCol   : Array [1..MaxTiles] Of Byte;

                      Year       : Integer;
