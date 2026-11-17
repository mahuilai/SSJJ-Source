package tools.js
{
   import flash.external.ExternalInterface;
   import flash.system.Capabilities;
   import tools.Singleton;
   
   public class JsManager
   {
      
      private var _callable:IJSCallable = null;
      
      public function JsManager()
      {
         super();
         Singleton.check(this);
      }
      
      public static function get instance() : JsManager
      {
         return Singleton.getInstanceOrCreate(JsManager) as JsManager;
      }
      
      public static function get browserAgent() : String
      {
         if("Desktop" == Capabilities.playerType)
         {
            return "air";
         }
         if(ExternalInterface.available)
         {
            return ExternalInterface.call("function getBrowser(){return navigator.userAgent;}");
         }
         return "other_" + Capabilities.playerType;
      }
      
      public static function get getFlashPlugins() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call("getFlashPlugins");
         }
         return "";
      }
      
      public function setJsCallable(param1:IJSCallable) : void
      {
         _callable = param1;
      }
      
      public function call(param1:String, param2:String) : void
      {
         if(null == _callable)
         {
            if("airHeartBeat" != param1)
            {
               trace("null==_callable js call:" + param1 + "(" + param2 + ")");
            }
            return;
         }
         _callable.call(param1,param2);
      }
      
      public function addCallback(param1:String, param2:Function) : void
      {
         if(null == _callable)
         {
            trace("null==_callable js addCallback:" + param1 + "(" + param2 + ")");
            return;
         }
         _callable.addCallback(param1,param2);
      }
      
      public function removeCallback(param1:Array) : void
      {
         if(null == _callable)
         {
            trace("null==_callable js removeCallback");
            return;
         }
         _callable.removeCallback(param1);
      }
   }
}

