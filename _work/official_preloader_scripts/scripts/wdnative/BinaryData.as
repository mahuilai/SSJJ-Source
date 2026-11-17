package wdnative
{
   import flash.system.System;
   import flash.utils.ByteArray;
   
   public class BinaryData extends ByteArray
   {
      
      public function BinaryData()
      {
         var _loc3_:* = null;
         var _loc5_:String = null;
         var _loc8_:* = 0;
         var _loc10_:* = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:int = 0;
         super();
         if(length)
         {
            return;
         }
         var _loc11_:* = (_loc7_ = CModule.describeType(this))..metadata.(@name == "HexData");
         for each(var _loc9_:XML in _loc11_)
         {
            _loc3_ = _loc9_..arg.(@key == "");
            for each(var _loc2_:XML in _loc3_)
            {
               _loc5_ = _loc2_.@value;
               _loc8_ = uint(_loc5_.length);
               _loc10_ = 0;
               while(_loc10_ < _loc8_)
               {
                  _loc4_ = _loc5_.charCodeAt(_loc10_);
                  _loc6_ = _loc5_.charCodeAt(_loc10_ + 1);
                  _loc1_ = 0;
                  if(_loc4_ < 58)
                  {
                     _loc1_ = _loc4_ - 48;
                  }
                  else if(_loc4_ < 71)
                  {
                     _loc1_ = 10 + (_loc4_ - 65);
                  }
                  else if(_loc4_ < 103)
                  {
                     _loc1_ = 10 + (_loc4_ - 97);
                  }
                  _loc1_ *= 16;
                  if(_loc6_ < 58)
                  {
                     _loc1_ += _loc6_ - 48;
                  }
                  else if(_loc6_ < 71)
                  {
                     _loc1_ += 10 + (_loc6_ - 65);
                  }
                  else if(_loc6_ < 103)
                  {
                     _loc1_ += 10 + (_loc6_ - 97);
                  }
                  writeByte(_loc1_);
                  _loc10_ += 2;
               }
            }
         }
         position = 0;
         try
         {
            System.disposeXML(_loc7_);
         }
         catch(error:*)
         {
         }
         var _loc7_:XML = null;
      }
   }
}

const §7§:*;

§__force_ordering_ns_89674f80-1ed2-4d3e-b5a4-2c3091889351§;

