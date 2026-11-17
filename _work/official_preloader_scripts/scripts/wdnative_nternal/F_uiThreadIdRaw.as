package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import flash.display.Sprite;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_uiThreadIdRaw() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:* = undefined;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = -1;
      try
      {
         if(Sprite)
         {
            _loc4_ = workerClass.current.getSharedProperty("flascc.uiThread.threadId");
            _loc1_ = int(typeof _loc4_ == "undefined" ? -1 : _loc4_);
         }
      }
      catch(e:*)
      {
         var _temp_3:* = this;
         var _temp_4:* = e;
      }
      wdnative.eax = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

