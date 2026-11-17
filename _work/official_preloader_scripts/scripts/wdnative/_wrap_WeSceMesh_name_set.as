package wdnative
{
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   
   public function _wrap_WeSceMesh_name_set(param1:*, param2:int) : void
   {
      var _loc5_:int = 0;
      var _loc9_:int = 0;
      var _loc7_:int = 0;
      var _loc10_:int = 0;
      var _loc3_:int = 0;
      var _loc4_:int;
      _loc5_ = _loc4_ = wdnative.ESP;
      _loc3_ = 126;
      _loc10_ = param1;
      _loc9_ = param2;
      if(_loc9_ != 0)
      {
         do
         {
            _loc7_ = _loc3_;
            _loc3_ = _loc10_ - _loc7_;
            var _loc6_:int = _loc9_ - _loc7_;
            _loc6_ = li8(_loc6_ + 126);
            si8(_loc6_,_loc3_ + 166);
            if(_loc6_ == 0)
            {
               if(_loc7_ != 0)
               {
                  _loc4_ -= 16;
                  si32(0,_loc4_ + 4);
                  si32(_loc7_,_loc4_ + 8);
                  _loc6_ = _loc3_ + 167;
                  si32(_loc6_,_loc4_);
                  wdnative.ESP = _loc4_;
                  wdnative.Fmemset();
                  _loc4_ += 16;
               }
               break;
            }
            _loc3_ = _loc7_ + -1;
         }
         while(_loc7_ != 0);
         si8(0,_loc10_ + 167);
      }
      else
      {
         si8(0,_loc10_ + 40);
      }
      var _loc8_:* = undefined;
      wdnative.ESP = _loc4_ = _loc5_;
      return _loc8_;
   }
}

