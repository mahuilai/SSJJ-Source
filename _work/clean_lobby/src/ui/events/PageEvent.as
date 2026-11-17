package ui.events
{
   import flash.events.Event;
   
   public class PageEvent extends Event
   {
      
      public static const FLIP:String = "flip";
      
      public var currentPage:int;
      
      public var totalPage:int;
      
      public function PageEvent(param1:String, param2:int = 0, param3:int = 0)
      {
         super(param1);
         this.currentPage = param2;
         this.totalPage = param3;
      }
   }
}

