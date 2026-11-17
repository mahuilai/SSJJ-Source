package lobby.log
{
   public interface IRemoteLog
   {
      
      function postError(param1:Error, param2:String = "from player", param3:String = "addHallLog", ... rest) : void;
      
      function postMsg(param1:String, param2:* = 0, ... rest) : void;
      
      function set reportURL(param1:String) : void;
   }
}

