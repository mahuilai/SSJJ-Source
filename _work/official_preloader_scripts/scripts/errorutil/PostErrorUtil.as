package errorutil
{
   import lobby.log.IRemoteLog;
   
   public class PostErrorUtil
   {
      
      private static var proxy:IRemoteLog;
      
      public function PostErrorUtil()
      {
         super();
      }
      
      public static function set postProxy(param1:IRemoteLog) : void
      {
         PostErrorUtil.proxy = param1;
      }
      
      public static function set reportURL(param1:String) : void
      {
         if(!proxy)
         {
            return;
         }
         proxy.reportURL = param1;
      }
      
      public static function postError(param1:Error, param2:String = "from player", param3:String = "addHallLog", ... rest) : void
      {
         if(!proxy)
         {
            return;
         }
         if(rest == null)
         {
            rest = [];
         }
         rest.unshift(param3);
         rest.unshift(param2);
         rest.unshift(param1);
         proxy.postError.apply(null,rest);
      }
      
      public static function postMsg(param1:String, param2:* = 0, ... rest) : void
      {
         if(!proxy)
         {
            return;
         }
         if(rest == null)
         {
            rest = [];
         }
         rest.unshift(param2);
         rest.unshift(param1);
         proxy.postMsg.apply(null,rest);
      }
   }
}

