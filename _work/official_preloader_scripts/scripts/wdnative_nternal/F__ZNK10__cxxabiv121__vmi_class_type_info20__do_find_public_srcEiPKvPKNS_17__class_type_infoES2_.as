package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.ptr2fun;
   
   public function F__ZNK10__cxxabiv121__vmi_class_type_info20__do_find_public_srcEiPKvPKNS_17__class_type_infoES2_() : void
   {
      var _temp_1:* = this;
      var _loc8_:int = 0;
      var _loc18_:int = 0;
      var _loc14_:int = 0;
      var _loc19_:int = 0;
      var _loc20_:int = 0;
      var _loc4_:int = 0;
      var _loc13_:int = 0;
      var _loc10_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = 0;
      var _loc12_:int = 0;
      var _loc15_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc8_ = _loc3_;
      _loc4_ = li32(_loc8_ + 16);
      _loc20_ = li32(_loc8_ + 12);
      _loc19_ = li32(_loc8_ + 8);
      _loc18_ = li32(_loc8_);
      loop2:
      while(true)
      {
         if(_loc19_ == _loc4_)
         {
            var _temp_4:* = li32(_loc20_ + 4);
            var _temp_3:* = li32(_loc18_ + 4);
            _loc15_ = 6;
            if(_temp_3 == _temp_4)
            {
               break;
            }
         }
         _loc14_ = li32(_loc8_ + 4);
         _loc13_ = li32(_loc18_ + 12);
         if(_loc14_ != -3)
         {
            _loc1_ = _loc13_ + 1;
            while(true)
            {
               _loc15_ = 1;
               if(_loc1_ == 1)
               {
                  break loop2;
               }
               var _temp_5:* = _loc1_ << 3;
               var _loc16_:int = _loc18_ + _temp_5;
               _loc5_ = li32(_loc16_ + 4);
               _loc16_ = _loc5_ & 2;
               if(_loc16_ == 0)
               {
                  continue;
               }
               _loc12_ = _loc5_ & 1;
               _loc6_ = _loc5_ >> 8;
               if(_loc12_ != 0)
               {
                  _loc16_ = li32(_loc19_);
                  _loc16_ = _loc16_ + _loc6_;
                  _loc6_ = li32(_loc16_);
               }
               _loc16_ = _loc1_ << 1;
               _loc16_ = _loc16_ << 2;
               _loc16_ = _loc18_ + _loc16_;
               _loc16_ = li32(_loc16_);
               var _loc17_:int = li32(_loc16_);
               var _loc7_:int = li32(_loc17_ + 32);
               _loc3_ -= 32;
               si32(_loc4_,_loc3_ + 16);
               si32(_loc20_,_loc3_ + 12);
               _loc17_ = _loc19_ + _loc6_;
               si32(_loc17_,_loc3_ + 8);
               si32(_loc14_,_loc3_ + 4);
               si32(_loc16_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.ptr2fun[_loc7_]();
               _loc3_ += 32;
               _loc2_ = wdnative.eax;
               if(_loc2_ < 4)
               {
                  continue;
               }
               _loc1_ += -1;
            }
            break;
         }
         _loc9_ = _loc13_ + 1;
         while(true)
         {
            _loc15_ = 1;
            if(_loc9_ == 1)
            {
               break loop2;
            }
            var _temp_18:* = _loc9_ << 3;
            _loc16_ = _loc18_ + _temp_18;
            _loc10_ = li32(_loc16_ + 4);
            _loc16_ = _loc10_ & 2;
            if(_loc16_ == 0)
            {
               continue;
            }
            _loc16_ = _loc10_ & 1;
            if(_loc16_ != 0)
            {
               continue;
            }
            _loc16_ = _loc9_ << 1;
            var _temp_24:* = _loc16_ << 2;
            _loc16_ = _loc18_ + _temp_24;
            _loc16_ = li32(_loc16_);
            _loc17_ = li32(_loc16_);
            var _loc11_:int = li32(_loc17_ + 32);
            _loc3_ -= 32;
            si32(_loc4_,_loc3_ + 16);
            si32(_loc20_,_loc3_ + 12);
            var _temp_28:* = _loc10_ >> 8;
            _loc17_ = _loc19_ + _temp_28;
            si32(_loc17_,_loc3_ + 8);
            si32(_loc14_,_loc3_ + 4);
            si32(_loc16_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.ptr2fun[_loc11_]();
            _loc12_ = 0;
            _loc3_ += 32;
            _loc2_ = wdnative.eax;
            if(_loc2_ <= 3)
            {
               continue;
            }
            _loc9_ += -1;
         }
         break;
         _loc15_ = _loc2_ | _loc12_;
         break;
      }
      wdnative.eax = _loc15_;
      _loc3_ = _loc8_;
      wdnative.ESP = _loc3_;
   }
}

