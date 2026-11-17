package wdnative
{
   import avm2.intrinsics.memory.lf32;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.sf32;
   import avm2.intrinsics.memory.si32;
   
   public function F__ZN11WeSceParser11WeSceLoader9getVertexEiR11WeVertexExt() : void
   {
      var _temp_1:* = this;
      var _loc7_:int = 0;
      var _loc17_:int = 0;
      var _loc32_:int = 0;
      var _loc31_:int = 0;
      var _loc30_:int = 0;
      var _loc29_:int = 0;
      var _loc28_:int = 0;
      var _loc27_:int = 0;
      var _loc14_:int = 0;
      var _loc22_:int = 0;
      var _loc24_:int = 0;
      var _loc11_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc25_:int = 0;
      var _loc34_:int = 0;
      var _loc13_:Number = NaN;
      var _loc18_:int = 0;
      var _loc19_:int = 0;
      var _loc20_:int = 0;
      var _loc21_:int = 0;
      var _loc16_:int = 0;
      var _loc15_:int = 0;
      var _loc12_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = 0;
      var _loc1_:int = 0;
      var _loc26_:int = 0;
      var _loc33_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc7_ = _loc3_;
      _loc3_ -= 32;
      _loc17_ = li32(_loc7_);
      _loc34_ = li32(_loc17_ + 96);
      _loc34_ = _loc34_ + -104;
      _loc33_ = li32(_loc7_ + 8);
      _loc32_ = li32(_loc7_ + 4);
      if(uint(_loc34_) <= 1)
      {
         _loc31_ = li32(_loc17_ + 288);
         _loc30_ = li32(_loc17_ + 292);
         _loc34_ = int(int(int(int(int(_loc30_ + _loc31_) + (_loc29_ = li32(_loc17_ + 296))) + (_loc28_ = li32(_loc17_ + 300))) + (_loc27_ = li32(_loc17_ + 304))) + (_loc14_ = li32(_loc17_ + 308))) + (_loc22_ = li32(_loc17_ + 312));
         _loc34_ = int(_loc34_ * _loc32_) + li32(_loc17_ + 144);
         si32(_loc34_,_loc17_ + 88);
         var _temp_12:* = li32(_loc17_ + 84);
         if(_loc34_ >= _temp_12)
         {
            si32(1,_loc17_ + 44);
            si32(1,_loc17_ + 48);
         }
         _loc24_ = _loc17_ + 40;
         si32(_loc32_,_loc33_);
         if(_loc31_ == 4)
         {
            _loc3_ -= 16;
            si32(_loc24_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc3_ += 16;
            _loc34_ = wdnative.eax;
            si32(_loc34_,_loc7_ - 4);
            _loc13_ = lf32(_loc7_ - 4);
         }
         else
         {
            _loc34_ = li32(_loc17_ + 88);
            _loc34_ = _loc34_ + _loc31_;
            si32(_loc34_,_loc17_ + 88);
            _loc13_ = 0;
            var _temp_17:* = li32(_loc17_ + 84);
            if(_loc34_ >= _temp_17)
            {
               si32(1,_loc17_ + 44);
               si32(1,_loc17_ + 48);
               _loc13_ = 0;
            }
         }
         sf32(_loc13_,_loc33_ + 4);
         if(_loc30_ == 4)
         {
            _loc3_ -= 16;
            si32(_loc24_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc3_ += 16;
            _loc34_ = wdnative.eax;
            si32(_loc34_,_loc7_ - 8);
            _loc13_ = lf32(_loc7_ - 8);
         }
         else
         {
            _loc34_ = li32(_loc17_ + 88);
            _loc34_ = _loc34_ + _loc30_;
            si32(_loc34_,_loc17_ + 88);
            _loc13_ = 0;
            var _temp_22:* = li32(_loc17_ + 84);
            if(_loc34_ >= _temp_22)
            {
               si32(1,_loc17_ + 44);
               si32(1,_loc17_ + 48);
               _loc13_ = 0;
            }
         }
         sf32(_loc13_,_loc33_ + 8);
         if(_loc29_ == 4)
         {
            _loc3_ -= 16;
            si32(_loc24_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc3_ += 16;
            _loc34_ = wdnative.eax;
            si32(_loc34_,_loc7_ - 12);
            _loc13_ = lf32(_loc7_ - 12);
         }
         else
         {
            _loc34_ = li32(_loc17_ + 88);
            var _loc23_:int = _loc34_ + _loc29_;
            si32(_loc23_,_loc17_ + 88);
            _loc13_ = 0;
            var _temp_27:* = li32(_loc17_ + 84);
            if(_loc23_ >= _temp_27)
            {
               si32(1,_loc17_ + 44);
               si32(1,_loc17_ + 48);
               _loc13_ = 0;
            }
         }
         sf32(_loc13_,_loc33_ + 12);
         _loc34_ = li8(_loc17_ + 36);
         _loc34_ = _loc34_ & 2;
         if(_loc34_ != 0)
         {
            if(_loc28_ == 4)
            {
               _loc3_ -= 16;
               si32(_loc24_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc7_ - 16);
               _loc13_ = lf32(_loc7_ - 16);
            }
            else
            {
               _loc34_ = li32(_loc17_ + 88);
               _loc23_ = _loc34_ + _loc28_;
               si32(_loc23_,_loc17_ + 88);
               _loc13_ = 0;
               var _temp_34:* = li32(_loc17_ + 84);
               if(_loc23_ >= _temp_34)
               {
                  si32(1,_loc17_ + 44);
                  si32(1,_loc17_ + 48);
                  _loc13_ = 0;
               }
            }
            sf32(_loc13_,_loc33_ + 16);
            if(_loc27_ == 4)
            {
               _loc3_ -= 16;
               si32(_loc24_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc7_ - 20);
               _loc13_ = lf32(_loc7_ - 20);
            }
            else
            {
               _loc34_ = li32(_loc17_ + 88);
               _loc23_ = _loc34_ + _loc27_;
               si32(_loc23_,_loc17_ + 88);
               _loc13_ = 0;
               var _temp_39:* = li32(_loc17_ + 84);
               if(_loc23_ >= _temp_39)
               {
                  si32(1,_loc17_ + 44);
                  si32(1,_loc17_ + 48);
                  _loc13_ = 0;
               }
            }
            sf32(_loc13_,_loc33_ + 20);
            if(_loc14_ == 4)
            {
               _loc3_ -= 16;
               si32(_loc24_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc7_ - 24);
               _loc13_ = lf32(_loc7_ - 24);
            }
            else
            {
               _loc34_ = li32(_loc17_ + 88);
               _loc34_ = _loc34_ + _loc14_;
               si32(_loc34_,_loc17_ + 88);
               _loc13_ = 0;
               var _temp_44:* = li32(_loc17_ + 84);
               if(_loc34_ >= _temp_44)
               {
                  si32(1,_loc17_ + 44);
                  si32(1,_loc17_ + 48);
                  _loc13_ = 0;
               }
            }
            sf32(_loc13_,_loc33_ + 24);
            if(_loc22_ == 4)
            {
               _loc3_ -= 16;
               si32(_loc24_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc7_ - 28);
               _loc13_ = lf32(_loc7_ - 28);
            }
            else
            {
               _loc34_ = li32(_loc17_ + 88);
               _loc34_ = _loc34_ + _loc22_;
               si32(_loc34_,_loc17_ + 88);
               _loc13_ = 0;
               var _temp_49:* = li32(_loc17_ + 84);
               if(_loc34_ >= _temp_49)
               {
                  si32(1,_loc17_ + 44);
                  si32(1,_loc17_ + 48);
                  _loc13_ = 0;
               }
            }
            sf32(_loc13_,_loc33_ + 28);
         }
      }
      else
      {
         _loc31_ = li32(_loc17_ + 356);
         _loc18_ = _loc26_ = 0;
         if(_loc31_ != _loc26_)
         {
            _loc18_ = 4;
         }
         _loc30_ = li32(_loc17_ + 360);
         _loc19_ = _loc26_;
         if(_loc30_ != _loc26_)
         {
            _loc19_ = 4;
         }
         _loc29_ = li32(_loc17_ + 364);
         _loc20_ = _loc26_;
         if(_loc29_ != _loc26_)
         {
            _loc20_ = 4;
         }
         _loc28_ = li32(_loc17_ + 368);
         _loc21_ = _loc26_;
         if(_loc28_ != _loc26_)
         {
            _loc21_ = 4;
         }
         _loc27_ = li32(_loc17_ + 372);
         _loc16_ = _loc26_;
         if(_loc27_ != _loc26_)
         {
            _loc16_ = 4;
         }
         _loc14_ = li32(_loc17_ + 376);
         _loc15_ = _loc26_;
         if(_loc14_ != _loc26_)
         {
            _loc15_ = 4;
         }
         _loc24_ = li32(_loc17_ + 380);
         _loc12_ = _loc26_;
         if(_loc24_ != _loc26_)
         {
            _loc12_ = 4;
         }
         _loc22_ = li32(_loc17_ + 384);
         _loc10_ = _loc26_;
         if(_loc22_ != _loc26_)
         {
            _loc10_ = 4;
         }
         _loc11_ = li32(_loc17_ + 388);
         _loc8_ = _loc26_;
         if(_loc11_ != _loc26_)
         {
            _loc8_ = 4;
         }
         _loc9_ = li32(_loc17_ + 392);
         _loc5_ = _loc26_;
         if(_loc9_ != _loc26_)
         {
            _loc5_ = 4;
         }
         _loc6_ = li32(_loc17_ + 396);
         _loc2_ = _loc26_;
         if(_loc6_ != _loc26_)
         {
            _loc2_ = 4;
         }
         _loc4_ = li32(_loc17_ + 400);
         _loc1_ = _loc26_;
         if(_loc4_ != _loc26_)
         {
            _loc1_ = 4;
         }
         _loc25_ = li32(_loc17_ + 404);
         if(_loc25_ != _loc26_)
         {
            _loc26_ = 4;
         }
         _loc34_ = _loc19_ + _loc18_;
         _loc34_ = _loc34_ + _loc20_;
         _loc34_ = _loc34_ + _loc21_;
         _loc34_ = _loc34_ + _loc16_;
         _loc34_ = _loc34_ + _loc15_;
         _loc34_ = _loc34_ + _loc12_;
         _loc34_ = _loc34_ + _loc10_;
         _loc34_ = _loc34_ + _loc8_;
         _loc34_ = _loc34_ + _loc5_;
         _loc34_ = _loc34_ + _loc2_;
         _loc34_ = _loc34_ + _loc1_;
         _loc34_ = _loc34_ + _loc26_;
         _loc34_ = _loc34_ * _loc32_;
         _loc23_ = li32(_loc17_ + 144);
         _loc23_ = _loc34_ + _loc23_;
         si32(_loc23_,_loc17_ + 88);
         _loc34_ = li32(_loc17_ + 84);
         if(_loc23_ >= _loc34_)
         {
            si32(1,_loc17_ + 44);
            si32(1,_loc17_ + 48);
         }
         _loc18_ = _loc17_ + 40;
         si32(_loc32_,_loc33_);
         if(_loc31_ != 0)
         {
            _loc3_ -= 16;
            si32(_loc18_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc3_ += 16;
            _loc34_ = wdnative.eax;
            si32(_loc34_,_loc33_ + 4);
         }
         if(_loc30_ != 0)
         {
            _loc3_ -= 16;
            si32(_loc18_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc3_ += 16;
            _loc34_ = wdnative.eax;
            si32(_loc34_,_loc33_ + 8);
         }
         if(_loc29_ != 0)
         {
            _loc3_ -= 16;
            si32(_loc18_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc3_ += 16;
            _loc34_ = wdnative.eax;
            si32(_loc34_,_loc33_ + 12);
         }
         _loc34_ = li8(_loc17_ + 36);
         _loc34_ = _loc34_ & 2;
         if(_loc34_ != 0)
         {
            if(_loc28_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 16);
            }
            if(_loc27_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 20);
            }
            if(_loc14_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 24);
            }
            if(_loc24_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 28);
            }
            if(_loc22_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 32);
            }
            if(_loc11_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 36);
            }
            if(_loc9_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 40);
            }
            if(_loc6_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 44);
            }
            if(_loc4_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 48);
            }
            if(_loc25_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc34_ = wdnative.eax;
               si32(_loc34_,_loc33_ + 52);
            }
         }
      }
      _loc34_ = li32(_loc17_ + 44);
      _loc33_ = 1;
      if(_loc34_ == _loc33_)
      {
         _loc33_ = 0;
      }
      wdnative.eax = _loc34_ = _loc33_ & 1;
      _loc3_ = _loc7_;
      wdnative.ESP = _loc3_;
   }
}

