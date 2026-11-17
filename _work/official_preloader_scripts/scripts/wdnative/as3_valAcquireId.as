package wdnative
{
   import avm2.intrinsics.memory.*;
   
   public function as3_valAcquireId(param1:*) : int
   {
      var _loc3_:Object = wdnative.as3_val2key(param1);
      var _loc2_:int = int(this.as3_val2id[_loc3_]);
      if(!_loc2_)
      {
         _loc2_ = int(this.as3_nextId);
         while(this.as3_id2rcv[_loc2_])
         {
            _loc2_++;
         }
         this.as3_nextId = _loc2_ + 1;
         this.as3_id2rcv[_loc2_] = new RCVal(param1,_loc2_);
         this.as3_val2id[_loc3_] = _loc2_;
      }
      this.as3_id2rcv[_loc2_].acquire();
      return _loc2_;
   }
}

