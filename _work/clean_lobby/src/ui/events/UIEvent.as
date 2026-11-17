package ui.events
{
   import flash.events.Event;
   
   public class UIEvent extends Event
   {
      
      public static const FRAME_CHANGED:String = "FRAME_CHANGED";
      
      public static const FRAME_COMPLETE:String = "FRAME_COMPLETE";
      
      public static const URL_ERROR:String = "URL_ERROR";
      
      private var _data:*;
      
      public function UIEvent(param1:String, param2:*, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         _data = param2;
      }
      
      public function get data() : *
      {
         return _data;
      }
      
      public function set data(param1:*) : void
      {
         _data = param1;
      }
   }
}

