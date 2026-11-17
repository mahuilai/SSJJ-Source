package errorutil
{
   import com.wooduan.bytes.utils.ByteUtils;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.system.ApplicationDomain;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.utils.Dictionary;
   import lobby.common.GlobalVariable;
   import lobby.log.IRemoteLog;
   import tools.js.JsManager;
   
   public class RemoteLogPost implements IRemoteLog
   {
      
      public static var _reportURL:String;
      
      public static var errorSequence:int = 1;
      
      private static var errorList:Dictionary = new Dictionary();
      
      public function RemoteLogPost()
      {
         super();
      }
      
      public function set reportURL(param1:String) : void
      {
         _reportURL = param1;
      }
      
      public function isErrorPosted(param1:String) : Boolean
      {
         var _loc2_:String = ByteUtils.hash(param1);
         if(errorList[_loc2_] == null)
         {
            errorList[_loc2_] = true;
            return false;
         }
         return true;
      }
      
      public function postError(param1:Error, param2:String = "from player", param3:String = "addHallLog", ... rest) : void
      {
         var _loc6_:int = 0;
         if(isErrorPosted(param1.getStackTrace()))
         {
            return;
         }
         var _loc5_:Object = createBaseParam();
         _loc5_.message = param1.message;
         _loc5_.errorID = param1.errorID;
         _loc5_.stack = param1.getStackTrace();
         _loc5_.log = getAllConsloeLog();
         _loc5_.method = param3;
         if(param1.hasOwnProperty("stackTrace"))
         {
            _loc5_.stackTrace = param1.stackTrace;
         }
         _loc6_ = 0;
         while(_loc6_ < rest.length)
         {
            _loc5_["param" + (_loc6_ + 1)] = rest[_loc6_];
            _loc6_++;
         }
         post(_loc5_);
      }
      
      private function createBaseParam() : Object
      {
         var _loc1_:Object = {};
         _loc1_.username = GlobalVariable.username;
         _loc1_.serverID = GlobalVariable.serverId;
         _loc1_.serverName = getServerName();
         _loc1_.cpu = Capabilities.cpuArchitecture;
         _loc1_.supports64 = Capabilities.supports64BitProcesses;
         _loc1_.os = Capabilities.os;
         _loc1_.lang = Capabilities.language;
         _loc1_.memory = "System.freeMemory:" + System.freeMemory.toString() + " System.privateMemory:" + System.privateMemory.toString() + " System.totalMemory:" + System.totalMemory.toString() + " System.totalMemoryNumber:" + System.totalMemoryNumber.toString() + " System.domainMemory:" + ApplicationDomain.currentDomain.domainMemory.length;
         _loc1_.browser = browserAgent;
         _loc1_.flashPlayer = Capabilities.version;
         _loc1_.gameVersion = GlobalVariable.gameVersion;
         _loc1_.errorSequence = errorSequence++;
         _loc1_.platform = GlobalVariable.platform;
         _loc1_.time = new Date().toString();
         if(GlobalVariable.cdnIp)
         {
            _loc1_.cdnIp = GlobalVariable.cdnIp;
         }
         if(GlobalVariable.cdnId)
         {
            _loc1_.cdnId = GlobalVariable.cdnId;
         }
         if(GlobalVariable.isp)
         {
            _loc1_.isp = GlobalVariable.isp;
         }
         return _loc1_;
      }
      
      private function get browserAgent() : String
      {
         return JsManager.browserAgent;
      }
      
      private function post(param1:Object) : void
      {
         if(!_reportURL || !param1)
         {
            return;
         }
         var _loc2_:URLRequest = new URLRequest(_reportURL);
         var _loc3_:URLLoader = new URLLoader();
         _loc2_.method = "POST";
         _loc3_.dataFormat = "text";
         _loc3_.addEventListener("complete",onSendComplete);
         _loc3_.addEventListener("ioError",onIOError);
         _loc3_.addEventListener("securityError",onSecurityError);
         var _loc5_:URLVariables = new URLVariables();
         for(var _loc4_ in param1)
         {
            _loc5_[_loc4_] = param1[_loc4_];
         }
         _loc2_.data = _loc5_;
         _loc3_.load(_loc2_);
      }
      
      private function onSendComplete(param1:Event) : void
      {
         if(String(param1.target.data) == "API_RETURN_SUCCEED")
         {
            trace("post error success");
         }
         else
         {
            trace("post error fail");
         }
         dispose(param1.currentTarget as URLLoader);
      }
      
      private function onSecurityError(param1:SecurityErrorEvent) : void
      {
         trace(param1.text);
         dispose(param1.currentTarget as URLLoader);
      }
      
      private function onIOError(param1:IOErrorEvent) : void
      {
         if(String(param1.target.data) == "API_RETURN_SUCCEED")
         {
            trace("post error success");
         }
         else
         {
            trace("post error fail");
         }
         dispose(param1.currentTarget as URLLoader);
      }
      
      private function dispose(param1:URLLoader) : void
      {
         if(!param1)
         {
            return;
         }
         param1.removeEventListener("complete",onSendComplete);
         param1.removeEventListener("ioError",onIOError);
         param1.removeEventListener("securityError",onSecurityError);
      }
      
      private function getAllConsloeLog() : String
      {
         var _loc1_:Object = null;
         try
         {
            _loc1_ = ApplicationDomain.currentDomain.getDefinition("lobby.log.Logger");
            return _loc1_.getAllLog(100);
         }
         catch(e:Error)
         {
            var _loc4_:String = "";
         }
         return _loc4_;
      }
      
      private function getServerName() : String
      {
         var _loc1_:Object = null;
         try
         {
            _loc1_ = ApplicationDomain.currentDomain.getDefinition("tools.PostErrorUtil");
            return _loc1_.getServerName();
         }
         catch(e:Error)
         {
            var _loc4_:String = "";
         }
         return _loc4_;
      }
      
      public function postMsg(param1:String, param2:* = 0, ... rest) : void
      {
         try
         {
            throw new Error(param1,param2);
         }
         catch(error:Error)
         {
            postError(error,"from player","addHallLog",[error,""].concat(rest));
         }
      }
   }
}

