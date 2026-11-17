package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_catgets() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc3_:int = 0;
      var _loc13_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:int = 0;
      var _loc9_:int = 0;
      var _loc15_:int = 0;
      var _loc14_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc3_ = li32(_loc4_);
      _loc15_ = _loc3_ + -1;
      _loc14_ = li32(_loc4_ + 8);
      if(uint(_loc15_) >= 4294967294)
      {
         si32(9,wdnative_nternal._errno);
      }
      else
      {
         _loc13_ = li32(_loc4_ + 4);
         _loc3_ = li32(_loc3_);
         var _loc12_:int = li32(_loc3_ + 4);
         var _temp_6:* = _loc12_ >>> 24;
         var _loc11_:int;
         var _temp_9:* = (_loc11_ = (_loc11_ = _loc12_ >>> 8) & 0xFF00) | _temp_6;
         _loc15_ = (_loc12_ = _loc12_ << 24 | (_loc12_ <<= 8) & 0xFF0000) | _temp_9;
         _loc10_ = _loc15_ + -1;
         _loc9_ = 0;
         loop0:
         while(true)
         {
            while(true)
            {
               if(_loc9_ > _loc10_)
               {
                  break loop0;
               }
               _loc12_ = _loc10_ + _loc9_;
               var _temp_12:* = _loc12_ >>> 31;
               _loc15_ = _loc12_ + _temp_12;
               _loc8_ = _loc15_ >> 1;
               var _temp_15:* = int(_loc8_ * 12);
               _loc1_ = _loc3_ + _temp_15;
               _loc5_ = li32(_loc1_ + 20);
               if(_loc5_ == 16777216)
               {
                  break;
               }
               var _temp_19:* = _loc5_ >>> 24;
               var _temp_22:* = (_loc12_ = (_loc12_ = _loc5_ >>> 8) & 0xFF00) | _temp_19;
               var _temp_23:* = (_loc12_ = _loc5_ << 24 | (_loc11_ = _loc5_ << 8) & 0xFF0000) | _temp_22;
               _loc15_ = 1 - _temp_23;
               if(_loc15_ <= -1)
               {
                  continue;
               }
               continue loop0;
               _loc10_ = _loc8_ + -1;
            }
            _loc12_ = li32(_loc1_ + 24);
            var _temp_28:* = _loc12_ >>> 24;
            var _temp_31:* = (_loc11_ = (_loc11_ = _loc12_ >>> 8) & 0xFF00) | _temp_28;
            var _temp_40:* = (_loc12_ = _loc12_ << 24 | (_loc12_ <<= 8) & 0xFF0000) | _temp_31;
            var _temp_35:* = (_loc12_ = li32(_loc1_ + 28)) >>> 24;
            var _loc6_:int;
            var _temp_38:* = (_loc6_ = (_loc6_ = _loc12_ >>> 8) & 0xFF00) | _temp_35;
            _loc8_ = (_loc12_ = _loc12_ << 24 | (_loc12_ <<= 8) & 0xFF0000) | _temp_38;
            _loc15_ = _loc8_ + _temp_40;
            _loc7_ = _loc15_ + -1;
            _loc12_ = li32(_loc3_ + 12);
            var _temp_45:* = _loc12_ >>> 24;
            var _temp_48:* = (_loc11_ = (_loc11_ = _loc12_ >>> 8) & 0xFF00) | _temp_45;
            _loc15_ = (_loc12_ = _loc12_ << 24 | (_loc12_ <<= 8) & 0xFF0000) | _temp_48;
            _loc15_ = _loc15_ + _loc3_;
            _loc1_ = _loc15_ + 20;
            loop2:
            while(true)
            {
               while(_loc8_ <= _loc7_)
               {
                  _loc15_ = _loc7_ + _loc8_;
                  var _temp_52:* = _loc15_ >>> 31;
                  _loc15_ += _temp_52;
                  _loc10_ = _loc15_ >> 1;
                  var _temp_55:* = int(_loc10_ * 12);
                  _loc9_ = _loc1_ + _temp_55;
                  _loc15_ = li32(_loc9_);
                  var _temp_60:* = _loc15_ >>> 24;
                  var _temp_63:* = (_loc11_ = (_loc11_ = _loc15_ >>> 8) & 0xFF00) | _temp_60;
                  _loc5_ = (_loc15_ = _loc15_ << 24 | (_loc15_ <<= 8) & 0xFF0000) | _temp_63;
                  if(_loc5_ == _loc13_)
                  {
                     _loc15_ = li32(_loc9_ + 8);
                     var _temp_68:* = _loc15_ >>> 24;
                     var _temp_71:* = (_loc11_ = (_loc11_ = _loc15_ >>> 8) & 0xFF00) | _temp_68;
                     var _temp_80:* = (_loc15_ = _loc15_ << 24 | (_loc15_ <<= 8) & 0xFF0000) | _temp_71;
                     var _temp_75:* = (_loc12_ = li32(_loc3_ + 16)) >>> 24;
                     var _temp_78:* = (_loc6_ = (_loc6_ = _loc12_ >>> 8) & 0xFF00) | _temp_75;
                     _loc12_ = (_loc12_ = _loc12_ << 24 | (_loc12_ <<= 8) & 0xFF0000) | _temp_78;
                     _loc15_ = _loc12_ + _temp_80;
                     _loc15_ = _loc15_ + _loc3_;
                     _loc14_ = _loc15_ + 20;
                     break loop2;
                  }
                  _loc15_ = _loc13_ - _loc5_;
                  if(_loc15_ <= -1)
                  {
                     _loc7_ = _loc10_ + -1;
                     continue;
                  }
                  continue loop2;
               }
               break loop0;
               _loc8_ = _loc10_ + 1;
            }
            _loc9_ = _loc8_ + 1;
         }
         si32(83,wdnative_nternal._errno);
      }
      wdnative.eax = _loc14_;
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

