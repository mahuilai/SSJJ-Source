package ui
{
   import flash.display.DisplayObjectContainer;
   import flash.events.IEventDispatcher;
   
   public interface IUICellRenderer extends IEventDispatcher
   {
      
      function set group(param1:IUIGroup) : void;
      
      function get group() : IUIGroup;
      
      function set selected(param1:Boolean) : void;
      
      function get selected() : Boolean;
      
      function set deselected(param1:Boolean) : void;
      
      function get deselected() : Boolean;
      
      function set enabled(param1:Boolean) : void;
      
      function get enabled() : Boolean;
      
      function set doubleClickEnabled(param1:Boolean) : void;
      
      function get doubleClickEnabled() : Boolean;
      
      function set index(param1:int) : void;
      
      function get index() : int;
      
      function set width(param1:Number) : void;
      
      function get width() : Number;
      
      function set height(param1:Number) : void;
      
      function get height() : Number;
      
      function set data(param1:Object) : void;
      
      function get data() : Object;
      
      function get parent() : DisplayObjectContainer;
      
      function set visible(param1:Boolean) : void;
      
      function get visible() : Boolean;
      
      function set x(param1:Number) : void;
      
      function get x() : Number;
      
      function set y(param1:Number) : void;
      
      function get y() : Number;
      
      function reset() : void;
      
      function dispose() : void;
   }
}

