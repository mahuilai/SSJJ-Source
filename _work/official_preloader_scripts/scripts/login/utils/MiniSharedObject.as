package login.utils
{
   import flash.events.NetStatusEvent;
   import flash.net.SharedObject;
   import lobby.common.GlobalVariable;
   
   public class MiniSharedObject
   {
      
      public static const LOGIN_SERVER:String = "LOGIN_SERVER";
      
      private static var _so:SharedObject;
      
      private static var _soData:Object;
      
      private static var _soEnbale:Boolean = true;
      
      public static var flushEnbale:Boolean = false;
      
      private static var isFlushing:Boolean;
      
      public function MiniSharedObject()
      {
         super();
      }
      
      public static function getLocal() : SharedObject
      {
         try
         {
            if(!_so)
            {
               _so = SharedObject.getLocal("Lobby_" + GlobalVariable.serverId + "_" + GlobalVariable.username,"/");
            }
            _so.addEventListener("netStatus",onSONetStatus);
         }
         catch(e:Error)
         {
            return null;
         }
         return _so;
      }
      
      private static function onSONetStatus(param1:NetStatusEvent) : void
      {
         isFlushing = false;
         if(param1.info.code == "SharedObject.Flush.Failed")
         {
            _soEnbale = false;
         }
      }
      
      public static function setData(param1:String, param2:*) : void
      {
         if(getLocal())
         {
            getLocal().data[param1] = param2;
            flush();
         }
      }
      
      public static function getData(param1:String) : *
      {
         if(getLocal() == null)
         {
            return null;
         }
         if(!_soData)
         {
            _soData = getLocal().data;
         }
         return _soData[param1];
      }
      
      public static function hasData(param1:String) : Boolean
      {
         if(getLocal() == null)
         {
            return null;
         }
         return getLocal().data.hasOwnProperty(param1);
      }
      
      public static function removeData(param1:String) : void
      {
         if(getLocal() == null)
         {
            return;
         }
         delete getLocal().data[param1];
      }
      
      public static function removeAll() : void
      {
         if(getLocal() == null)
         {
            return;
         }
         getLocal().clear();
      }
      
      public static function flush() : void
      {
         if(!flushEnbale)
         {
            return;
         }
         if(!_soEnbale)
         {
            return;
         }
         if(isFlushing)
         {
            return;
         }
         isFlushing = true;
         try
         {
            getLocal().flush();
         }
         catch(e:Error)
         {
            isFlushing = false;
            _soEnbale = false;
         }
      }
   }
}

