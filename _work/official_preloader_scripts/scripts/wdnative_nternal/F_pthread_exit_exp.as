package wdnative_nternal
{
   import wdnative.ESP;
   
   public function F_pthread_exit_exp() : void
   {
      var _temp_1:* = this;
      var _loc1_:int = wdnative.ESP;
      var _loc2_:int = _loc1_;
      wdnative.ESP = _loc1_;
      wdnative_nternal.F_stub_exit();
   }
}

