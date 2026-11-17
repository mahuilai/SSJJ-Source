package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.ptr2fun;
   
   public function F__ZNK10__cxxabiv121__vmi_class_type_info11__do_upcastEPKNS_17__class_type_infoEPKvRNS1_15__upcast_resultE() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc25_:int = 0;
      var _loc10_:int = 0;
      var _loc22_:int = 0;
      var _loc23_:int = 0;
      var _loc20_:int = 0;
      var _loc19_:int = 0;
      var _loc11_:int = 0;
      var _loc18_:int = 0;
      var _loc8_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc7_:int = 0;
      var _loc24_:int = 0;
      var _loc15_:int = 0;
      var _loc16_:int = 0;
      var _loc17_:int = 0;
      var _loc14_:int = 0;
      var _loc26_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc3_:int = 0;
      var _loc21_:int = 0;
      var _loc1_:int = wdnative.ESP;
      _loc2_ = _loc1_;
      _loc1_ -= 16;
      _loc10_ = li32(_loc2_ + 4);
      _loc26_ = li32(_loc10_ + 4);
      _loc25_ = li32(_loc2_);
      _loc24_ = li32(_loc25_ + 4);
      _loc23_ = li32(_loc2_ + 12);
      _loc22_ = li32(_loc2_ + 8);
      if(_loc24_ == _loc26_)
      {
         si32(_loc22_,_loc23_);
         si32(8,_loc23_ + 12);
         si32(6,_loc23_ + 4);
         _loc21_ = 1;
      }
      else
      {
         _loc20_ = li32(_loc23_ + 8);
         _loc26_ = _loc20_ & 0x10;
         if(_loc26_ != 0)
         {
            _loc20_ = li32(_loc25_ + 8);
         }
         _loc19_ = _loc20_ & 1;
         _loc26_ = li32(_loc25_ + 12);
         _loc7_ = _loc26_ + 1;
         while(true)
         {
            if(_loc7_ == 1)
            {
               var _temp_7:* = li32(_loc23_ + 4);
               _loc3_ = 1;
               if(_temp_7 == 0)
               {
                  _loc3_ = 0;
               }
               _loc21_ = _loc3_ & 1;
               break;
            }
            si32(0,_loc2_ - 16);
            _loc15_ = _loc2_ - 16;
            _loc16_ = _loc15_ | 4;
            si32(0,_loc16_);
            si32(_loc20_,_loc2_ - 8);
            si32(0,_loc2_ - 4);
            var _temp_9:* = _loc7_ << 3;
            _loc26_ = _loc25_ + _temp_9;
            _loc17_ = li32(_loc26_ + 4);
            _loc18_ = _loc17_ & 2;
            if(_loc19_ == 0)
            {
               _loc26_ = _loc18_ >>> 1;
               if(_loc26_ == 0)
               {
                  continue;
               }
            }
            _loc11_ = _loc17_ & 1;
            _loc12_ = 0;
            if(_loc22_ != 0)
            {
               _loc13_ = _loc17_ >> 8;
               if(_loc11_ != 0)
               {
                  _loc26_ = li32(_loc22_);
                  _loc26_ = _loc26_ + _loc13_;
                  _loc13_ = li32(_loc26_);
               }
               _loc12_ = _loc22_ + _loc13_;
            }
            _loc26_ = _loc7_ << 1;
            _loc26_ = _loc26_ << 2;
            _loc14_ = _loc25_ + _loc26_;
            _loc24_ = li32(_loc14_);
            _loc26_ = li32(_loc24_);
            var _loc9_:int = li32(_loc26_ + 24);
            _loc1_ -= 16;
            si32(_loc15_,_loc1_ + 12);
            si32(_loc12_,_loc1_ + 8);
            si32(_loc10_,_loc1_ + 4);
            si32(_loc24_,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative.ptr2fun[_loc9_]();
            _loc1_ += 16;
            _loc26_ = wdnative.eax;
            if(_loc26_ != 0)
            {
               _loc8_ = li32(_loc2_ - 4);
               if(_loc8_ == 8)
               {
                  if(_loc11_ != 0)
                  {
                     _loc8_ = li32(_loc14_);
                     si32(_loc8_,_loc2_ - 4);
                  }
               }
               _loc6_ = li32(_loc16_);
               if(_loc6_ >= 4)
               {
                  if(_loc18_ == 0)
                  {
                     _loc6_ &= -3;
                     si32(_loc6_,_loc16_);
                  }
               }
               _loc4_ = li32(_loc23_ + 12);
               if(_loc4_ == 0)
               {
                  _loc26_ = li32(_loc2_ - 16);
                  si32(_loc26_,_loc23_);
                  si32(_loc6_,_loc23_ + 4);
                  _loc26_ = li32(_loc2_ - 8);
                  si32(_loc26_,_loc23_ + 8);
                  si32(_loc8_,_loc23_ + 12);
                  _loc21_ = 1;
                  if(_loc6_ < 4)
                  {
                     break;
                  }
                  _loc26_ = _loc6_ & 2;
                  if(_loc26_ != 0)
                  {
                     _loc26_ = li8(_loc25_ + 8);
                     var _temp_31:* = _loc26_ & 1;
                     _loc21_ = 1;
                     if(_temp_31 == 0)
                     {
                        break;
                     }
                  }
                  else
                  {
                     var _temp_32:* = _loc6_ & 1;
                     _loc21_ = 1;
                     if(_temp_32 == 0)
                     {
                        break;
                     }
                     _loc26_ = li8(_loc25_ + 8);
                     var _temp_34:* = _loc26_ & 2;
                     _loc21_ = 1;
                     if(_temp_34 == 0)
                     {
                        break;
                     }
                  }
               }
               else
               {
                  _loc5_ = li32(_loc23_);
                  var _temp_35:* = li32(_loc2_ - 16);
                  if(_loc5_ != _temp_35)
                  {
                     si32(0,_loc23_);
                     si32(2,_loc23_ + 4);
                     _loc21_ = 1;
                     break;
                  }
                  if(_loc5_ == 0)
                  {
                     if(_loc8_ != 8)
                     {
                        if(_loc4_ != 8)
                        {
                           var _temp_39:* = li32(_loc4_ + 4);
                           if((_loc26_ = li32(_loc8_ + 4)) == _temp_39)
                           {
                              _loc26_ = li32(_loc23_ + 4);
                              _loc26_ = _loc26_ | _loc6_;
                              si32(_loc26_,_loc23_ + 4);
                              continue;
                           }
                        }
                     }
                     si32(2,_loc23_ + 4);
                     _loc21_ = 1;
                     break;
                  }
                  _loc26_ = li32(_loc23_ + 4);
                  _loc26_ = _loc26_ | _loc6_;
                  si32(_loc26_,_loc23_ + 4);
               }
            }
            _loc7_ += -1;
         }
      }
      wdnative.eax = _loc21_;
      _loc1_ = _loc2_;
      wdnative.ESP = _loc1_;
   }
}

