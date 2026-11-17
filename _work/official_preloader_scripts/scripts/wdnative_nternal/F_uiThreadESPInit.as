package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import flash.display.Sprite;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_uiThreadESPInit() : void
   {
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = 0;
      try
      {
         if(Sprite)
         {
            _loc1_ = int(workerClass.current.getSharedProperty("flascc.uiThread.esp_init"));
            _loc5_ = int(workerClass.current.getSharedProperty("flascc.uiThread.stackSize"));
         }
      }
      catch(e:*)
      {
      }
      _loc4_ = li32(_loc3_);
      if(_loc4_ != 0)
      {
         si32(_loc5_,_loc4_);
      }
      wdnative.eax = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

