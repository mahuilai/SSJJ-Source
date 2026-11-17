package ui
{
   import flash.events.IEventDispatcher;
   
   public interface IUIPage extends IEventDispatcher
   {
      
      function get totalPage() : int;
      
      function set totalPage(param1:int) : void;
      
      function get currentPage() : int;
      
      function set currentPage(param1:int) : void;
   }
}

