package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.Fmemcpy;
   import wdnative.eax;
   import wdnative.edx;
   
   public function F___multadd_D2A() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc14_:int = 0;
      var _loc13_:int = 0;
      var _loc15_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc12_:int = 0;
      var _loc11_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc3_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc3_ = li32(_loc4_ + 4);
      _loc15_ = _loc3_ >> 31;
      _loc14_ = li32(_loc4_);
      _loc13_ = li32(_loc14_ + 16);
      _loc12_ = 0;
      _loc11_ = 0;
      _loc10_ = 0;
      do
      {
         _loc2_ -= 16;
         si32(_loc3_,_loc2_ + 8);
         si32(0,_loc2_ + 4);
         si32(_loc15_,_loc2_ + 12);
         var _loc9_:int = _loc12_ << 2;
         _loc9_ = _loc14_ + _loc9_;
         var _loc8_:int = li32(_loc9_ + 20);
         si32(_loc8_,_loc2_);
         wdnative.ESP = _loc2_;
         F___muldi3();
         _loc2_ += 16;
         _loc8_ = wdnative.eax;
         _loc1_ = wdnative.edx;
         _loc5_ = _loc8_ + _loc11_;
         si32(_loc5_,_loc9_ + 20);
         _loc7_ = _loc6_ = 1;
         if(uint(_loc5_) >= uint(_loc8_))
         {
            _loc7_ = 0;
         }
         if(uint(_loc5_) >= uint(_loc11_))
         {
            _loc6_ = _loc7_;
         }
         _loc9_ = _loc1_ + _loc10_;
         _loc11_ = _loc9_ + _loc6_;
         _loc12_ += 1;
         _loc10_ = 0;
      }
      while(_loc12_ < _loc13_);
      var _temp_9:* = _loc11_ | 0;
      _loc3_ = _loc14_;
      if(_temp_9 != 0)
      {
         var _temp_10:* = li32(_loc14_ + 8);
         _loc3_ = _loc14_;
         if(_temp_10 <= _loc13_)
         {
            _loc3_ = li32(_loc14_ + 4);
            while(true)
            {
               _loc15_ = _loc3_ + 1;
               if(_loc15_ >= 10)
               {
                  _loc10_ = 1 << _loc15_;
                  _loc9_ = _loc10_ << 2;
                  _loc7_ = _loc9_ + 27;
               }
               else
               {
                  var _temp_14:* = _loc3_ << 2;
                  _loc12_ = wdnative_nternal._freelist + _temp_14;
                  _loc3_ = li32(_loc12_ + 4);
                  if(_loc3_ != 0)
                  {
                     _loc9_ = li32(_loc3_);
                     si32(_loc9_,_loc12_ + 4);
                     §§goto(addr020a);
                  }
                  _loc3_ = li32(wdnative_nternal._pmem_next);
                  _loc9_ = _loc3_ - wdnative_nternal._private_mem;
                  _loc9_ = (_loc9_ >> 3) + (_loc12_ = (_loc7_ = (_loc9_ = (_loc10_ = 1 << _loc15_) << 2) + 27) >>> 3);
                  if((uint(_loc9_)) <= 288)
                  {
                     var _temp_36:* = _loc12_ << 3;
                     _loc9_ = _loc3_ + _temp_36;
                     si32(_loc9_,wdnative_nternal._pmem_next);
                     break;
                  }
               }
               _loc2_ -= 16;
               _loc9_ = _loc7_ & -8;
               si32(_loc9_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.F_malloc();
               _loc2_ += 16;
               _loc3_ = wdnative.eax;
               break;
            }
            si32(_loc15_,_loc3_ + 4);
            si32(_loc10_,_loc3_ + 8);
            addr020a:
            si32(0,_loc3_ + 16);
            si32(0,_loc3_ + 12);
            _loc9_ = li32(_loc14_ + 16);
            _loc2_ -= 16;
            _loc8_ = _loc14_ + 12;
            si32(_loc8_,_loc2_ + 4);
            _loc8_ = _loc3_ + 12;
            si32(_loc8_,_loc2_);
            _loc9_ <<= 2;
            _loc9_ = _loc9_ + 8;
            si32(_loc9_,_loc2_ + 8);
            wdnative.ESP = _loc2_;
            wdnative.Fmemcpy();
            _loc2_ += 16;
            if(_loc14_ != 0)
            {
               _loc15_ = li32(_loc14_ + 4);
               if(_loc15_ >= 10)
               {
                  _loc2_ -= 16;
                  si32(_loc14_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_idalloc();
                  _loc2_ += 16;
               }
               else
               {
                  var _temp_24:* = _loc15_ << 2;
                  _loc9_ = wdnative_nternal._freelist + _temp_24;
                  _loc8_ = li32(_loc9_);
                  si32(_loc8_,_loc14_);
                  si32(_loc14_,_loc9_);
               }
            }
            §§goto(addr02bf);
         }
         addr02bf:
         _loc9_ = _loc13_ << 2;
         _loc9_ = _loc3_ + _loc9_;
         si32(_loc11_,_loc9_ + 20);
         _loc9_ = _loc13_ + 1;
         si32(_loc9_,_loc3_ + 16);
         §§goto(addr02e4);
      }
      addr02e4:
      wdnative.eax = _loc3_;
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

