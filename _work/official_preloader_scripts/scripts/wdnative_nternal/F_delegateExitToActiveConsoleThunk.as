package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_delegateExitToActiveConsoleThunk() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      try
      {
         _loc1_ = int(CModule.activeConsole.exit(_loc1_));
      }
      catch(e:*)
      {
         var _temp_2:* = this;
         var _temp_3:* = e;
         _loc1_ = 0;
      }
      wdnative.eax = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

