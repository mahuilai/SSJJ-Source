package lobby
{
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import tools.StringUtils;
   
   public class LanguageConfig
   {
      
      private static var _instance:LanguageConfig = null;
      
      private var i18nDic:Dictionary = new Dictionary();
      
      public function LanguageConfig(param1:PrivateClass)
      {
         super();
         if(null == param1)
         {
            throw new Error("param pri can\'t be null");
         }
      }
      
      public static function get instance() : LanguageConfig
      {
         if(null == _instance)
         {
            _instance = new LanguageConfig(new PrivateClass());
         }
         return _instance;
      }
      
      public static function getText(param1:String, ... rest) : String
      {
         rest.unshift(param1);
         return instance.getText.apply(null,rest);
      }
      
      public static function getErrorCode(param1:int, param2:int) : String
      {
         return instance.getText.apply(null,["ERRORCODE_" + (param1 + param2)]);
      }
      
      public function dispose() : void
      {
         i18nDic = new Dictionary();
      }
      
      public function loadFromByteI8Next(param1:ByteArray) : void
      {
         var _loc9_:int = 0;
         var _loc3_:String = param1.toString();
         var _loc4_:Array = _loc3_.split("\n");
         var _loc7_:String = null;
         var _loc2_:int = 0;
         var _loc8_:String = null;
         var _loc6_:String = null;
         var _loc5_:Dictionary = new Dictionary();
         _loc9_ = 0;
         while(_loc9_ < _loc4_.length)
         {
            _loc7_ = _loc4_[_loc9_] as String;
            _loc2_ = _loc7_.indexOf("@@=@@");
            if(_loc2_ != -1)
            {
               _loc8_ = _loc7_.substring(0,_loc2_);
               _loc6_ = _loc7_.substring(_loc2_ + 5);
               _loc6_ = _loc6_.replace(/^\s+|\s+$/g,"").replace(/\r/g,"\n").replace(/\\n/g,"\n").replace(/\\r/g,"\n");
               _loc8_ = replaceKey(_loc8_);
               if(_loc8_.indexOf("该角色拥有以下皮肤") >= 0)
               {
                  trace("aaa");
               }
               i18nDic[_loc8_] = _loc6_;
            }
            _loc9_++;
         }
      }
      
      private function replaceKey(param1:String) : String
      {
         return param1.replace(/^\s+|\s+$/g,"").replace(/\\r/g,"").replace(/\r/g,"").replace(/\\n/g,"").replace(/\n/g,"");
      }
      
      public function loadFromByteArray(param1:ByteArray) : void
      {
         loadFromProperties(param1.toString());
      }
      
      public function loadFromProperties(param1:String) : void
      {
         var _loc8_:int = 0;
         var _loc3_:Array = param1.split("\n");
         var _loc6_:String = null;
         var _loc2_:int = 0;
         var _loc7_:String = null;
         var _loc5_:String = null;
         var _loc4_:Dictionary = new Dictionary();
         _loc8_ = 0;
         while(_loc8_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc8_] as String;
            _loc2_ = _loc6_.indexOf("=");
            if(_loc2_ != -1)
            {
               _loc7_ = _loc6_.substring(0,_loc2_);
               _loc5_ = _loc6_.substring(_loc2_ + 1);
               _loc5_ = _loc5_.replace(/^\s+|\s+$/g,"").replace(/\r/g,"\n").replace(/\\n/g,"\n");
               i18nDic[_loc7_] = _loc5_;
            }
            _loc8_++;
         }
      }
      
      public function hasKey(param1:String) : Boolean
      {
         return null != i18nDic[param1];
      }
      
      private function getText(param1:String, ... rest) : String
      {
         var _loc4_:String = replaceKey(param1);
         var _loc3_:String = i18nDic[_loc4_];
         if(null == _loc3_)
         {
            return StringUtils.substitute(param1,rest);
         }
         return StringUtils.substitute(_loc3_,rest);
      }
   }
}

class PrivateClass
{
   
   public function PrivateClass()
   {
      super();
   }
}
