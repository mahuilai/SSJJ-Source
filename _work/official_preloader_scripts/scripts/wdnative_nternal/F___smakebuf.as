package wdnative_nternal
{
   import avm2.intrinsics.memory.li16;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si16;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.sxi16;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.eax;
   
   public function F___smakebuf() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 144;
      _loc1_ = li32(_loc3_);
      var _loc10_:int = li8(_loc1_ + 12);
      _loc10_ = _loc10_ & 2;
      if(_loc10_ != 0)
      {
         _loc10_ = _loc1_ + 67;
         si32(_loc10_,_loc1_);
         si32(_loc10_,_loc1_ + 16);
         si32(1,_loc1_ + 20);
      }
      else
      {
         _loc9_ = si16(li16(_loc1_ + 14));
         _loc8_ = 2048;
         _loc7_ = 1024;
         _loc6_ = 0;
         if(_loc9_ >= 0)
         {
            _loc2_ -= 16;
            _loc10_ = _loc3_ - 144;
            si32(_loc10_,_loc2_ + 4);
            si32(_loc9_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F___sys_fstat();
            _loc8_ = 2048;
            _loc7_ = 1024;
            _loc6_ = 0;
            _loc2_ += 16;
            _loc10_ = wdnative.eax;
            if(_loc10_ >= 0)
            {
               _loc10_ = li16(_loc3_ - 136);
               _loc9_ = _loc10_ & 0xF000;
               _loc6_ = 1;
               if(_loc9_ != 8192)
               {
                  _loc6_ = 0;
               }
               _loc6_ &= 1;
               _loc8_ = 2048;
               _loc7_ = 1024;
               _loc5_ = li32(_loc3_ - 80);
               if(_loc5_ != 0)
               {
                  si32(_loc5_,_loc1_ + 76);
                  while(true)
                  {
                     if(_loc9_ == 32768)
                     {
                        var _temp_10:* = li32(_loc1_ + 40);
                        _loc8_ = 1024;
                        _loc7_ = _loc5_;
                        if(_temp_10 == wdnative_nternal.___sseek)
                        {
                           break;
                        }
                     }
                     _loc8_ = 2048;
                     _loc7_ = _loc5_;
                     break;
                  }
               }
            }
         }
         _loc2_ -= 16;
         si32(_loc7_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative.F_malloc();
         _loc2_ += 16;
         _loc9_ = wdnative.eax;
         if(_loc9_ == 0)
         {
            _loc10_ = li16(_loc1_ + 12);
            _loc10_ = _loc10_ | 2;
            si16(_loc10_,_loc1_ + 12);
            _loc10_ = _loc1_ + 67;
            si32(_loc10_,_loc1_);
            si32(_loc10_,_loc1_ + 16);
            si32(1,_loc1_ + 20);
         }
         else
         {
            si32(wdnative_nternal.__cleanup,wdnative_nternal.___cleanup);
            si32(_loc9_,_loc1_);
            si32(_loc9_,_loc1_ + 16);
            si32(_loc7_,_loc1_ + 20);
            _loc7_ = _loc8_ | 0x80;
            if(_loc6_ != 0)
            {
               var _temp_17:* = si16(li16(_loc1_ + 14));
               _loc2_ -= 16;
               _loc10_ = _loc3_ - 48;
               si32(_loc10_,_loc2_ + 8);
               si32(1076655123,_loc2_ + 4);
               si32(_temp_17,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F___sys_ioctl();
               _loc2_ += 16;
               _loc10_ = wdnative.eax;
               if(_loc10_ != -1)
               {
                  _loc7_ = _loc8_ | 0x81;
               }
            }
            _loc10_ = li16(_loc1_ + 12);
            _loc10_ = _loc10_ | _loc7_;
            si16(_loc10_,_loc1_ + 12);
         }
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

