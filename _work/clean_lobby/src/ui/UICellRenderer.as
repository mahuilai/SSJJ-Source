package ui
{
   import fl.controls.listClasses.ICellRenderer;
   import fl.controls.listClasses.ListData;
   
   public class UICellRenderer extends UIContainer implements IUICellRenderer, ICellRenderer
   {
      
      protected var _data:Object;
      
      protected var _selected:Boolean;
      
      protected var _deselected:Boolean;
      
      protected var _group:IUIGroup;
      
      protected var _index:int;
      
      protected var mouseState:String;
      
      protected var _listData:ListData;
      
      public function UICellRenderer()
      {
         super();
      }
      
      public function reset() : void
      {
      }
      
      public function set data(param1:Object) : void
      {
         _data = param1;
      }
      
      public function get data() : Object
      {
         return _data;
      }
      
      public function get selected() : Boolean
      {
         return _selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         _selected = param1;
      }
      
      public function set group(param1:IUIGroup) : void
      {
         _group = param1;
      }
      
      public function get group() : IUIGroup
      {
         return _group;
      }
      
      public function set deselected(param1:Boolean) : void
      {
         _deselected = param1;
      }
      
      public function get deselected() : Boolean
      {
         return _deselected;
      }
      
      public function set index(param1:int) : void
      {
         _index = param1;
      }
      
      public function get index() : int
      {
         return _index;
      }
      
      public function setMouseState(param1:String) : void
      {
         if(mouseState == param1)
         {
            return;
         }
         mouseState = param1;
      }
      
      public function get listData() : ListData
      {
         return _listData;
      }
      
      public function set listData(param1:ListData) : void
      {
         _listData = param1;
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
      }
      
      public function setStyle(param1:String, param2:Object) : void
      {
      }
   }
}

