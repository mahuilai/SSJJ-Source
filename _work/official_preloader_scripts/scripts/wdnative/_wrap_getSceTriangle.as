package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F___assert;
   import wdnative_nternal.L__2E_str258;
   import wdnative_nternal.L__2E_str56;
   import wdnative_nternal.__ZZ14getSceTrianglePviP10WeTriangleE8__func__;
   
   public function _wrap_getSceTriangle(param1:int, param2:int, param3:int) : Boolean
   {
      var _loc9_:int = 0;
      var _loc17_:int = 0;
      var _loc15_:int = 0;
      var _loc14_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc18_:int = 0;
      var _loc8_:int = 0;
      var _loc4_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:int;
      _loc9_ = _loc7_ = wdnative.ESP;
      _loc8_ = param1;
      _loc18_ = param2;
      _loc17_ = param3;
      if(_loc17_ == 0)
      {
         _loc7_ -= 16;
         si32(wdnative_nternal.L__2E_str258,_loc7_ + 12);
         si32(98,_loc7_ + 8);
         si32(wdnative_nternal.L__2E_str56,_loc7_ + 4);
         si32(wdnative_nternal.__ZZ14getSceTrianglePviP10WeTriangleE8__func__,_loc7_);
         wdnative.ESP = _loc7_;
         wdnative_nternal.F___assert();
         _loc7_ += 16;
      }
      var _loc16_:int = li32(_loc8_ + 96);
      _loc16_ = _loc16_ + -104;
      if((uint(_loc16_)) <= 1)
      {
         _loc15_ = li32(_loc8_ + 356);
         _loc14_ = li32(_loc8_ + 360);
         _loc16_ = int(int(_loc14_ + _loc15_) + (_loc13_ = li32(_loc8_ + 364))) + (_loc12_ = li32(_loc8_ + 368));
         var _loc11_:int = int(_loc16_ * _loc18_) + li32(_loc8_ + 156);
         si32(_loc11_,_loc8_ + 88);
         var _temp_11:* = li32(_loc8_ + 84);
         if(_loc11_ >= _temp_11)
         {
            si32(1,_loc8_ + 44);
            si32(1,_loc8_ + 48);
         }
         _loc16_ = _loc8_ + 40;
         _loc7_ -= 16;
         si32(_loc15_,_loc7_ + 4);
         si32(_loc16_,_loc7_);
         wdnative.ESP = _loc7_;
         wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
         _loc7_ += 16;
         _loc11_ = wdnative.eax;
         si32(_loc11_,_loc17_);
         _loc7_ -= 16;
         si32(_loc14_,_loc7_ + 4);
         si32(_loc16_,_loc7_);
         wdnative.ESP = _loc7_;
         wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
         _loc7_ += 16;
         _loc11_ = wdnative.eax;
         si32(_loc11_,_loc17_ + 4);
         _loc7_ -= 16;
         si32(_loc13_,_loc7_ + 4);
         si32(_loc16_,_loc7_);
         wdnative.ESP = _loc7_;
         wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
         _loc7_ += 16;
         _loc11_ = wdnative.eax;
         si32(_loc11_,_loc17_ + 8);
         _loc7_ -= 16;
         si32(_loc12_,_loc7_ + 4);
         si32(_loc16_,_loc7_);
         wdnative.ESP = _loc7_;
         wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
         _loc7_ += 16;
         _loc16_ = wdnative.eax;
         si32(_loc16_,_loc17_ + 12);
      }
      else
      {
         _loc13_ = li32(_loc8_ + 424);
         _loc14_ = _loc15_ = 0;
         if(_loc13_ != _loc15_)
         {
            _loc14_ = 4;
         }
         _loc12_ = li32(_loc8_ + 428);
         _loc4_ = _loc15_;
         if(_loc12_ != _loc15_)
         {
            _loc4_ = 4;
         }
         _loc16_ = li32(_loc8_ + 432);
         _loc10_ = _loc15_;
         if(_loc16_ != _loc15_)
         {
            _loc10_ = 4;
         }
         _loc16_ = li32(_loc8_ + 436);
         if(_loc16_ != _loc15_)
         {
            _loc15_ = 4;
         }
         _loc16_ = _loc4_ + _loc14_;
         _loc16_ = _loc16_ + _loc10_;
         _loc16_ = _loc16_ + _loc15_;
         _loc11_ = _loc16_ * _loc18_;
         _loc16_ = li32(_loc8_ + 156);
         _loc11_ += _loc16_;
         si32(_loc11_,_loc8_ + 88);
         _loc16_ = li32(_loc8_ + 84);
         if(_loc11_ >= _loc16_)
         {
            si32(1,_loc8_ + 44);
            si32(1,_loc8_ + 48);
         }
         _loc18_ = _loc8_ + 40;
         if(_loc13_ != 0)
         {
            _loc7_ -= 16;
            si32(_loc18_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc7_ += 16;
            _loc16_ = wdnative.eax;
            si32(_loc16_,_loc17_);
            _loc12_ = li32(_loc8_ + 428);
         }
         if(_loc12_ != 0)
         {
            _loc7_ -= 16;
            si32(_loc18_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc7_ += 16;
            _loc16_ = wdnative.eax;
            si32(_loc16_,_loc17_ + 4);
         }
         _loc16_ = li32(_loc8_ + 432);
         if(_loc16_ != 0)
         {
            _loc7_ -= 16;
            si32(_loc18_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc7_ += 16;
            _loc16_ = wdnative.eax;
            si32(_loc16_,_loc17_ + 8);
         }
         _loc16_ = li32(_loc8_ + 436);
         if(_loc16_ != 0)
         {
            _loc7_ -= 16;
            si32(_loc18_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative.F__ZN20WeLittleEndianReader7readIntEv();
            _loc7_ += 16;
            _loc16_ = wdnative.eax;
            si32(_loc16_,_loc17_ + 12);
         }
      }
      _loc16_ = li32(_loc8_ + 44);
      _loc17_ = 1;
      if(_loc16_ == _loc17_)
      {
         _loc17_ = 0;
      }
      var _loc6_:Boolean;
      var _loc5_:Boolean = _loc6_ = Boolean(_loc16_ = _loc17_ & 1);
      wdnative.ESP = _loc7_ = _loc9_;
      return _loc5_;
   }
}

