package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.tcbp;
   
   public function F_thrImpersonate() : void
   {
      var _temp_2:* = this;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc11_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc6_ = _loc2_;
      _loc1_ = li32(_loc6_);
      _loc11_ = li32(_loc6_ + 4);
      _loc9_ = li32(_loc6_ + 8);
      _loc8_ = li32(_loc6_ + 12);
      _loc7_ = li32(_loc6_ + 16);
      var _loc5_:int = int(threadId);
      var _loc10_:int = tcbp;
      var _loc4_:int = wdnative_nternal._avm2_self_unlock;
      var _loc3_:int = _loc7_;
      try
      {
         threadId = _loc1_;
         tcbp = _loc11_;
         if(_loc3_)
         {
            CModule.write32(_loc3_,1);
         }
         CModule.callI(wdnative_nternal._avm2_self_lock,new Vector.<int>(0));
         _loc1_ = CModule.callI(_loc9_,new <int>[_loc8_]);
         if(_loc3_)
         {
            CModule.write32(_loc3_,0);
         }
      }
      catch(e:*)
      {
         var _temp_14:* = this;
         var _temp_15:* = e;
         if(!_loc3_)
         {
            throw e;
         }
      }
      finally
      {
         try
         {
            CModule.callI(_loc4_,new Vector.<int>(0));
         }
         catch(e:*)
         {
            var _temp_9:* = this;
            var _temp_10:* = e;
         }
         threadId = _loc5_;
         tcbp = _loc10_;
      }
      wdnative.eax = _loc1_;
      _loc2_ = _loc6_;
      wdnative.ESP = _loc2_;
   }
}

