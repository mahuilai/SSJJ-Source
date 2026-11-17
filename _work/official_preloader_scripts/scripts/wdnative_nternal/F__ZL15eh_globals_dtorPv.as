package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.ptr2fun;
   
   public function F__ZL15eh_globals_dtorPv() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      if(_loc1_ != 0)
      {
         while(true)
         {
            _loc7_ = li32(_loc1_);
            if(_loc7_ != 0)
            {
               do
               {
                  _loc6_ = li32(_loc7_ + 56);
                  _loc5_ = li32(_loc7_ + 16);
                  if(_loc6_ != 0)
                  {
                     _loc2_ -= 16;
                     si32(1,_loc2_);
                     var _loc4_:int = _loc7_ + 48;
                     si32(_loc4_,_loc2_ + 4);
                     wdnative.ESP = _loc2_;
                     wdnative.ptr2fun[_loc6_]();
                     _loc2_ += 16;
                  }
                  _loc7_ = _loc5_;
               }
               while(_loc5_ != 0);
               if(_loc1_ == 0)
               {
                  break;
               }
            }
            _loc2_ -= 16;
            si32(_loc1_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_idalloc();
            _loc2_ += 16;
            break;
         }
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

