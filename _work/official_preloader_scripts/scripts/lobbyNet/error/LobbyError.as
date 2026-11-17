package lobbyNet.error
{
   public class LobbyError extends Error
   {
      
      public static const ID_LOGIN_CONNECT_TIMEROUT:int = 6100;
      
      public static const ID_LOGIN_CONNECT_ONRECONNECT:int = 6101;
      
      public static const ID_LOGIN_CONNECT_SUCCESS:int = 6102;
      
      public static const ID_LOGIN_CONNECT_SECERROR:int = 6103;
      
      public static const ID_LOGIN_CONNECT_IOERROR:int = 6104;
      
      public static const ID_CHANNEL_CONNECT_TIMEROUT:int = 6200;
      
      public static const ID_CHANNEL_CONNECT_ONRECONNECT:int = 6201;
      
      public static const ID_CHANNEL_CONNECT_SUCCESS:int = 6202;
      
      public static const ID_CHANNEL_CONNECT_SECERROR:int = 6203;
      
      public static const ID_CHANNEL_CONNECT_IOERROR:int = 6204;
      
      public function LobbyError(param1:* = "", param2:* = 0)
      {
         super(param1,param2);
      }
   }
}

