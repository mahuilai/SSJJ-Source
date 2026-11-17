package wdnative
{
   public function as3_val2key(param1:*) : Object
   {
      if(param1 is Namespace)
      {
         return "Namespace:" + String(param1);
      }
      var _loc2_:String = typeof param1;
      if(_loc2_ == "object" || _loc2_ == "function")
      {
         return param1;
      }
      return _loc2_ + ":" + String(param1);
   }
}

