package wdnative
{
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F___assert;
   import wdnative_nternal.L__2E_str157;
   import wdnative_nternal.L__2E_str56;
   import wdnative_nternal.__ZZ10getSceMeshPviP9WeSceMeshE8__func__;
   
   public function _wrap_getSceMesh(param1:int, param2:int, param3:int) : Boolean
   {
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc11_:int = 0;
      var _loc10_:int = 0;
      var _loc6_:int;
      _loc7_ = _loc6_ = wdnative.ESP;
      _loc5_ = param1;
      _loc11_ = param2;
      _loc10_ = param3;
      if(_loc10_ == 0)
      {
         _loc6_ -= 16;
         si32(wdnative_nternal.L__2E_str157,_loc6_ + 12);
         si32(104,_loc6_ + 8);
         si32(wdnative_nternal.L__2E_str56,_loc6_ + 4);
         si32(wdnative_nternal.__ZZ10getSceMeshPviP9WeSceMeshE8__func__,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative_nternal.F___assert();
         _loc6_ += 16;
      }
      _loc6_ -= 16;
      si32(_loc10_,_loc6_ + 8);
      si32(_loc11_,_loc6_ + 4);
      si32(_loc5_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN11WeSceParser11WeSceLoader7getMeshEiR9WeSceMesh();
      _loc6_ += 16;
      var _loc4_:Boolean;
      var _loc8_:int;
      var _loc9_:Boolean = _loc4_ = Boolean(_loc8_ = wdnative.eax);
      wdnative.ESP = _loc6_ = _loc7_;
      return _loc9_;
   }
}

