package ui.events
{
   import flash.events.Event;
   import ui.IUICellRenderer;
   
   public class ItemEvent extends Event
   {
      
      public static const ITEM_CLICK:String = "itemClick";
      
      public static const ITEM_SELECTED:String = "itemSelected";
      
      public static const ITEM_MOUSE_DOWN:String = "itemMouseDown";
      
      public static const ITEM_ROLL_OVER:String = "itemRollOver";
      
      public static const ITEM_DOUBLE_CLICK:String = "itemDoubleClick";
      
      public var item:IUICellRenderer;
      
      public var index:int;
      
      public var data:*;
      
      public function ItemEvent(param1:String, param2:IUICellRenderer, param3:int, param4:*, param5:Boolean = false, param6:Boolean = false)
      {
         super(param1,param5,param6);
         this.item = param2;
         this.index = param3;
         this.data = param4;
      }
   }
}

