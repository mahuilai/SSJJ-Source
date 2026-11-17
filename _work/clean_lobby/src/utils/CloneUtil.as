package utils
{
   import flash.utils.ByteArray;
   
   public class CloneUtil
   {
      
      public function CloneUtil()
      {
         super();
      }
      
      public static function clone(param1:Object) : *
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         param1 = _loc2_.readObject();
         _loc2_.clear();
         return param1;
      }
      
      public static function cloneObject(param1:Object) : Object
      {
         var _loc2_:Object = {};
         for(var _loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         return _loc2_;
      }
   }
}

