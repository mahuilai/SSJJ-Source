package wdnative
{
   import avm2.intrinsics.memory.*;
   
   function as3_valRegSpecial(param1:*) : void
   {
      var _temp_1:* = this;
      var _loc2_:int = int(this.as3_nextId);
      this.as3_nextId++;
      this.as3_id2rcv[_loc2_] = new RCValSpecial(param1);
      this.as3_val2id[wdnative.as3_val2key(param1)] = _loc2_;
   }
}

