package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F___assert;
   import wdnative_nternal.L__2E_str345;
   import wdnative_nternal.L__2E_str42;
   import wdnative_nternal.L__2E_str446;
   import wdnative_nternal.L__2E_str56;
   import wdnative_nternal.L__2E_str864;
   import wdnative_nternal.__ZZ14getSceMaterialPviP13WeSceMaterialE8__func__;
   import wdnative_nternal.__ZZN11WeSceParser11WeSceLoader11getMaterialEiR13WeSceMaterialE8__func__;
   
   public function _wrap_getSceMaterial(param1:int, param2:int, param3:int) : Boolean
   {
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc12_:int = 0;
      var _loc11_:int = 0;
      var _loc6_:int;
      _loc7_ = _loc6_ = wdnative.ESP;
      _loc5_ = param1;
      _loc12_ = param2;
      _loc11_ = param3;
      if(_loc11_ == 0)
      {
         _loc6_ -= 16;
         si32(wdnative_nternal.L__2E_str864,_loc6_ + 12);
         si32(53,_loc6_ + 8);
         si32(wdnative_nternal.L__2E_str56,_loc6_ + 4);
         si32(wdnative_nternal.__ZZ14getSceMaterialPviP13WeSceMaterialE8__func__,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative_nternal.F___assert();
         _loc6_ += 16;
      }
      var _loc9_:int = li32(_loc5_ + 124);
      if(_loc9_ <= _loc12_)
      {
         _loc6_ -= 16;
         si32(wdnative_nternal.L__2E_str345,_loc6_ + 12);
         si32(396,_loc6_ + 8);
         si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
         si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader11getMaterialEiR13WeSceMaterialE8__func__,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative_nternal.F___assert();
         _loc6_ += 16;
      }
      _loc5_ = li32(_loc5_ + 560);
      if(_loc5_ == 0)
      {
         _loc6_ -= 16;
         si32(wdnative_nternal.L__2E_str446,_loc6_ + 12);
         si32(397,_loc6_ + 8);
         si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
         si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader11getMaterialEiR13WeSceMaterialE8__func__,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative_nternal.F___assert();
         _loc6_ += 16;
      }
      _loc9_ = _loc12_ * 28;
      _loc9_ = _loc5_ + _loc9_;
      var _loc8_:int = li32(_loc9_);
      si32(_loc8_,_loc11_);
      _loc8_ = li32(_loc9_ + 4);
      si32(_loc8_,_loc11_ + 4);
      _loc8_ = li32(_loc9_ + 8);
      si32(_loc8_,_loc11_ + 8);
      _loc8_ = li32(_loc9_ + 12);
      si32(_loc8_,_loc11_ + 12);
      _loc8_ = li32(_loc9_ + 16);
      si32(_loc8_,_loc11_ + 16);
      _loc8_ = li32(_loc9_ + 20);
      si32(_loc8_,_loc11_ + 20);
      _loc9_ = li32(_loc9_ + 24);
      si32(_loc9_,_loc11_ + 24);
      var _loc4_:Boolean;
      var _loc10_:Boolean = _loc4_ = Boolean(1);
      wdnative.ESP = _loc6_ = _loc7_;
      return _loc10_;
   }
}

