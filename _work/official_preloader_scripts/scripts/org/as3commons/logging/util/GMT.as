package org.as3commons.logging.util
{
   public const GMT:String = calculateGMT();
}

import org.as3commons.logging.util.§org.as3commons.logging.util.GMT§;

function calculateGMT():String
{
   var _loc4_:String = null;
   var _loc1_:Date = new Date();
   var _loc2_:int = _loc1_.timezoneOffset;
   var _loc3_:int = _loc2_ / 60;
   if(_loc2_ <= 0)
   {
      _loc4_ = "+";
      _loc2_ = _loc2_ * -1;
      _loc3_ = _loc3_ * -1;
   }
   else
   {
      _loc4_ = "-";
   }
   _loc3_ = Math.floor(_loc3_);
   _loc2_ = _loc2_ - _loc3_ * 60;
   return "GMT" + _loc4_ + (_loc3_ < 10 ? "0" + _loc3_ : _loc3_) + (_loc2_ < 10 ? "0" + _loc2_ : _loc2_);
}
