package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative_nternal.F__Znaj;
   import wdnative_nternal.F_idalloc;
   
   public function _wrap_WeSceMaterial_name_set(param1:*, param2:String) : void
   {
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc18_:int = 0;
      var _loc17_:int = 0;
      var _loc14_:int = 0;
      var _loc12_:int = 0;
      var _loc3_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc19_:int = 0;
      var _loc13_:int = 0;
      var _loc10_:int = 0;
      var _loc11_:int = 0;
      var _loc5_:int;
      _loc7_ = _loc5_ = wdnative.ESP;
      _loc6_ = param1;
      wdnative.ESP = _loc5_ & -16;
      _loc19_ = CModule.mallocString(param2);
      _loc18_ = li32(_loc6_ + 12);
      if(_loc18_ != 0)
      {
         _loc5_ -= 16;
         si32(_loc18_,_loc5_);
         wdnative.ESP = _loc5_;
         wdnative_nternal.F_idalloc();
         _loc5_ += 16;
      }
      if(_loc19_ != 0)
      {
         _loc17_ = _loc19_ & -4;
         var _loc16_:int = li32(_loc17_);
         var _temp_9:* = int(_loc16_ + -16843009);
         var _loc15_:int = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_9;
         if(_loc15_ != 0)
         {
            _loc14_ = _loc17_ + 4;
            _loc13_ = 0;
            while(true)
            {
               _loc12_ = _loc19_ + _loc13_;
               if((uint(_loc12_)) < uint(_loc14_))
               {
                  _loc15_ = li8(_loc12_);
                  if(_loc15_ == 0)
                  {
                     break;
                  }
                  _loc13_ += 1;
                  continue;
               }
            }
            §§goto(addr01bb);
         }
         _loc3_ = _loc17_ + 4;
         while(true)
         {
            _loc8_ = li32(_loc3_);
            _loc15_ = _loc8_ + -16843009;
            _loc16_ = _loc8_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc15_ = _loc16_ & _loc15_;
            if(_loc15_ != 0)
            {
               _loc15_ = _loc8_ & 0xFF;
               if(_loc15_ == 0)
               {
                  _loc13_ = _loc3_ - _loc19_;
                  break;
               }
               _loc15_ = li8(_loc3_ + 1);
               if(_loc15_ == 0)
               {
                  _loc15_ = 1 - _loc19_;
                  _loc13_ = _loc15_ + _loc3_;
                  break;
               }
               _loc15_ = li8(_loc3_ + 2);
               if(_loc15_ == 0)
               {
                  _loc15_ = 2 - _loc19_;
                  _loc13_ = _loc15_ + _loc3_;
                  break;
               }
               _loc15_ = li8(_loc3_ + 3);
               if(_loc15_ == 0)
               {
                  _loc15_ = 3 - _loc19_;
                  _loc13_ = _loc15_ + _loc3_;
                  break;
               }
            }
            _loc3_ += 4;
         }
         addr01bb:
         _loc5_ -= 16;
         _loc15_ = _loc13_ + 1;
         si32(_loc15_,_loc5_);
         wdnative.ESP = _loc5_;
         wdnative_nternal.F__Znaj();
         _loc5_ += 16;
         _loc9_ = wdnative.eax;
         si32(_loc9_,_loc6_ + 12);
         _loc15_ = li8(_loc19_);
         si8(_loc15_,_loc9_);
         if(_loc15_ != 0)
         {
            _loc10_ = _loc9_ + 1;
            _loc11_ = _loc19_ + 1;
            do
            {
               _loc15_ = li8(_loc11_);
               si8(_loc15_,_loc10_);
               _loc10_ += 1;
               _loc11_ += 1;
            }
            while(_loc15_ != 0);
         }
         if(_loc19_ != 0)
         {
            _loc5_ -= 16;
            si32(_loc19_,_loc5_);
            wdnative.ESP = _loc5_;
            wdnative_nternal.F_idalloc();
            _loc5_ += 16;
         }
         §§goto(addr0279);
      }
      else
      {
         si32(0,_loc6_ + 12);
      }
      addr0279:
      var _loc4_:* = undefined;
      wdnative.ESP = _loc5_ = _loc7_;
      return _loc4_;
   }
}

