package lobbyNet
{
   import flash.events.Event;
   
   public class PacketEvent extends Event
   {
      
      public static const PACKET_ARRIVE:String = "PACKET_ARRIVE";
      
      public var apc:APC;
      
      public function PacketEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

