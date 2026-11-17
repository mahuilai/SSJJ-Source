package ui
{
   import flash.events.IEventDispatcher;
   
   public interface IUIGroup extends IEventDispatcher
   {
      
      function addCell(param1:IUICellRenderer) : void;
      
      function addCellAt(param1:IUICellRenderer, param2:int) : void;
      
      function removeCell(param1:IUICellRenderer) : IUICellRenderer;
      
      function set selectedCell(param1:IUICellRenderer) : void;
      
      function get selectedCell() : IUICellRenderer;
      
      function set allowMultipleSelection(param1:Boolean) : void;
      
      function get allowMultipleSelection() : Boolean;
      
      function set selectedIndex(param1:int) : void;
      
      function get selectedIndex() : int;
      
      function set selectedIndices(param1:Array) : void;
      
      function get selectedIndices() : Array;
      
      function getCellByIndex(param1:int) : IUICellRenderer;
      
      function get length() : int;
      
      function set enabled(param1:Boolean) : void;
      
      function get enabled() : Boolean;
      
      function set horizontalGap(param1:int) : void;
      
      function get horizontalGap() : int;
      
      function set verticalGap(param1:int) : void;
      
      function get verticalGap() : int;
      
      function set direction(param1:String) : void;
      
      function get direction() : String;
      
      function clear() : void;
   }
}

