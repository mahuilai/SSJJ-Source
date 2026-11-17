package wdnative_nternal
{
   import wdnative.CModule;
   import wdnative.ESP;
   
   public function F__fini() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc1_:int = wdnative.ESP;
      _loc2_ = _loc1_;
      wdnative.ESP = _loc1_ & -16;
      CModule.runDtors();
      _loc1_ = _loc2_;
      wdnative.ESP = _loc1_;
   }
}

