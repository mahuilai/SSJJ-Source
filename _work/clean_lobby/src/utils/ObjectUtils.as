package utils
{
   import flash.utils.Dictionary;
   
   public class ObjectUtils
   {
      
      public static var collectEnable:Boolean = false;
      
      private static var _collectedMap:Dictionary = new Dictionary();
      
      public function ObjectUtils()
      {
         super();
      }
      
      public static function get collectedMap() : Dictionary
      {
         return _collectedMap;
      }
      
      public static function resetCollectedMap() : void
      {
         _collectedMap = new Dictionary();
      }
      
      public static function collectUnloadComponent(param1:String, param2:String) : void
      {
         if(!collectEnable)
         {
            return;
         }
         param1 = param1 + "--->" + param2;
         if(null == _collectedMap[param1])
         {
            _collectedMap[param1] = 1;
         }
         else
         {
            _collectedMap[param1] = int(_collectedMap[param1]) + 1;
         }
      }
      
      public static function areObjectsEqual(param1:Object, param2:Object) : Boolean
      {
         if(param1 === param2)
         {
            return true;
         }
         if(param1 == null || param2 == null)
         {
            return false;
         }
         for(var _loc3_ in param2)
         {
            if(param2[_loc3_] != param1[_loc3_])
            {
               return false;
            }
         }
         return true;
      }
      
      public static function mergeObjects(param1:Object, param2:Object) : void
      {
         for(var _loc3_ in param2)
         {
            if(param1[_loc3_])
            {
               var _loc4_:String = _loc3_;
               var _loc5_:Number = param1[_loc4_] + int(param2[_loc3_]);
               param1[_loc4_] = _loc5_;
            }
            else
            {
               param1[_loc3_] = param2[_loc3_];
            }
         }
      }
   }
}

