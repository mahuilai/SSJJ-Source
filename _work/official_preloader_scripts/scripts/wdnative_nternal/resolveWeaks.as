package wdnative_nternal
{
   public function resolveWeaks() : Boolean
   {
      var _temp_1:* = this;
      var _loc2_:Object = {1:1};
      var _loc4_:int = 0;
      var _loc3_:Object = _loc2_;
      for each(_loc4_ in _loc3_)
      {
         if(!(_loc4_))
         {
            return false;
         }
      }
      wdnative_nternal.modWeaks = _loc2_;
      return true;
   }
}

