package tools
{
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class Singleton
   {
      
      private static var _dict:Dictionary = new Dictionary();
      
      public function Singleton()
      {
         super();
      }
      
      public static function check(param1:Object) : void
      {
         if(null == param1)
         {
            throw new Error("check 参数不能为null");
         }
         var _loc2_:Class = null;
         if(param1 is Class)
         {
            _loc2_ = param1 as Class;
         }
         else
         {
            _loc2_ = param1["constructor"] as Class;
         }
         if(null != _dict[_loc2_])
         {
            throw new Error(getQualifiedClassName(param1) + " 只允许实例化一次！");
         }
      }
      
      public static function destory(param1:Class) : void
      {
         if(null == _dict[param1])
         {
            throw new Error("该类没有实例化，不需要 销毁");
         }
         delete _dict[param1];
      }
      
      public static function getInstanceOrCreate(param1:Class) : Object
      {
         if(null == _dict[param1])
         {
            _dict[param1] = new param1();
         }
         return _dict[param1];
      }
   }
}

