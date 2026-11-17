package wdnative
{
   import avm2.intrinsics.memory.*;
   
   public class RCVal
   {
      
      public const val:*;
      
      public const id:int;
      
      public var rc:int;
      
      public function RCVal(param1:*, param2:int)
      {
         var _temp_1:* = this;
         super();
         this.val = param1;
         this.id = param2;
      }
      
      public function acquire(param1:int = 1) : *
      {
         rc += param1;
      }
      
      public function release(param1:int = 1) : *
      {
         var _temp_1:* = this;
         var _temp_2:* = §§findproperty(rc);
         if(!(rc = rc - param1))
         {
            delete wdnative.as3_val2id[wdnative.as3_val2key(val)];
            delete wdnative.as3_id2rcv[id];
         }
      }
   }
}

