package ui
{
   import fl.data.DataProvider;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import ui.core.UICommon;
   import ui.events.ItemEvent;
   
   public class UICombobox extends UIBase
   {
      
      public static const UP:String = "up";
      
      public static const DOWN:String = "down";
      
      protected var labelBtn:UIButton;
      
      protected var list:UIList;
      
      protected var _prompt:String;
      
      protected var _selectedItemData:Object;
      
      protected var _selectedIndex:int = -1;
      
      protected var _defaultSelected:Boolean = true;
      
      protected var _openDirection:String = "down";
      
      public function UICombobox(param1:String = null)
      {
         super();
         labelBtn = new UIButton();
         list = new UIList();
         this.addChild(labelBtn);
         dropdown.cellRenderer = UIComboboxCellRenderer;
         this.addEventListener("click",dropHandler);
         dropdown.addEventListener("itemSelected",itemSelectedHandler);
         this.skin = param1;
         styleName = "UICombobox";
         dropdown.columnCount = 1;
         close();
      }
      
      public function get textField() : TextField
      {
         return labelBtn.textField;
      }
      
      public function get dropdown() : UIList
      {
         return list;
      }
      
      public function get labelButton() : UIButton
      {
         return labelBtn;
      }
      
      public function set skin(param1:String) : void
      {
         labelBtn.skin = param1;
         callLater(onSizeChange);
      }
      
      public function get skin() : String
      {
         return labelBtn.skin;
      }
      
      public function set skins(param1:String) : void
      {
         skin = param1;
      }
      
      public function get skins() : String
      {
         return labelBtn.skin;
      }
      
      private function onSizeChange() : void
      {
         this.width = labelBtn.width;
         this.height = labelBtn.height;
      }
      
      public function set prompt(param1:String) : void
      {
         _prompt = param1;
         if(selectedIndex < 0)
         {
            labelBtn.label = _prompt;
         }
      }
      
      public function get prompt() : String
      {
         return _prompt;
      }
      
      public function set text(param1:String) : void
      {
         labelBtn.label = param1;
      }
      
      public function get text() : String
      {
         return labelBtn.label;
      }
      
      public function set defaultSelected(param1:Boolean) : void
      {
         _defaultSelected = param1;
      }
      
      public function get defaultSelected() : Boolean
      {
         return _defaultSelected;
      }
      
      public function set dataProvider(param1:DataProvider) : void
      {
         if(dropdown.dataProvider === param1)
         {
            return;
         }
         dropdown.dataProvider = param1;
         _selectedItemData = dropdown.selectedItem;
         if(_selectedItemData)
         {
            text = _selectedItemData.label;
         }
         if(_defaultSelected && _prompt == null && param1 && param1.length > 0 && _selectedIndex === -1)
         {
            selectedIndex = 0;
         }
         else
         {
            _selectedIndex = dropdown.selectedIndex;
         }
      }
      
      public function get dataProvider() : DataProvider
      {
         return dropdown.dataProvider;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(_selectedIndex == param1)
         {
            return;
         }
         if(dropdown == null || dropdown.length == 0)
         {
            return;
         }
         _selectedIndex = param1;
         if(_selectedIndex < -1)
         {
            _selectedIndex = -1;
         }
         if(_selectedIndex >= dropdown.length)
         {
            _selectedIndex = dropdown.length - 1;
         }
         dropdown.selectedIndex = _selectedIndex;
         if(selectedIndex < 0)
         {
            labelBtn.label = _prompt;
         }
      }
      
      public function get selectedIndex() : int
      {
         return _selectedIndex;
      }
      
      private function itemSelectedHandler(param1:ItemEvent) : void
      {
         if(_selectedItemData === param1.data && _selectedIndex === param1.index)
         {
            return;
         }
         _selectedItemData = param1.data;
         _selectedIndex = param1.index;
         if(_selectedItemData && _selectedItemData.hasOwnProperty("label"))
         {
            text = _selectedItemData.label;
         }
         param1.stopPropagation();
         dispatchEvent(new ItemEvent("itemSelected",param1.item,param1.index,param1.data));
         dispatchEvent(new Event("change"));
         close();
      }
      
      public function get openDirection() : String
      {
         return _openDirection;
      }
      
      public function set openDirection(param1:String) : void
      {
         _openDirection = param1;
      }
      
      private function dropHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(dropdown.parent)
         {
            close();
         }
         else
         {
            open();
         }
      }
      
      public function open() : void
      {
         var _loc4_:Rectangle = null;
         if(this.stage == null)
         {
            return;
         }
         UICommon.stageAgent2.addChild(dropdown);
         UICommon.stage.addEventListener("click",onStageClick);
         var _loc3_:Point = this.localToGlobal(new Point(0,0));
         var _loc2_:Number = _loc3_.x / UICommon.scale;
         var _loc1_:Number = _loc3_.y / UICommon.scale;
         dropdown.x = _loc2_;
         if(_openDirection === "up")
         {
            _loc4_ = dropdown.getRect(dropdown);
            if(_loc4_.height > dropdown.height)
            {
               dropdown.y = -dropdown.height + _loc1_;
            }
            else
            {
               dropdown.y = -_loc4_.height + _loc1_;
            }
         }
         else
         {
            dropdown.y = labelBtn.height + _loc1_;
         }
      }
      
      private function onStageClick(param1:MouseEvent) : void
      {
         if(param1.target != this && param1.target != dropdown && dropdown.contains(param1.target as DisplayObject) == false)
         {
            close();
            UICommon.stage.removeEventListener("click",onStageClick);
         }
      }
      
      public function close() : void
      {
         if(dropdown.parent)
         {
            dropdown.parent.removeChild(dropdown);
         }
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         labelBtn.enabled = param1;
      }
      
      public function set rowCount(param1:int) : void
      {
         dropdown.rowCount = param1;
      }
      
      public function get rowCount() : int
      {
         return dropdown.rowCount;
      }
      
      public function set dropdownHeight(param1:Number) : void
      {
         dropdown.height = param1;
      }
      
      public function get dropdownHeight() : Number
      {
         return dropdown.height;
      }
      
      public function set dropdownRowHeight(param1:int) : void
      {
         dropdown.rowHeight = param1;
      }
      
      public function get dropdownRowHeight() : int
      {
         return dropdown.rowHeight;
      }
      
      public function get selectedItem() : Object
      {
         return _selectedItemData;
      }
      
      public function get length() : int
      {
         return dropdown.length;
      }
      
      public function set dropItemRendererClass(param1:Class) : void
      {
         dropdown.cellRenderer = param1;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         labelBtn.width = param1;
         dropdown.width = param1;
         dropdown.columnWidth = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         labelBtn.height = param1;
      }
      
      public function set selected(param1:Boolean) : void
      {
         labelBtn.selected = param1;
      }
      
      public function get selected() : Boolean
      {
         return labelBtn.selected;
      }
      
      public function set fontSize(param1:Object) : void
      {
         labelButton.fontSize = param1;
      }
      
      public function get fontSize() : Object
      {
         return labelButton.fontSize;
      }
      
      public function set font(param1:String) : void
      {
         labelButton.font = param1;
      }
      
      public function get font() : String
      {
         return labelButton.font;
      }
      
      public function set textColor(param1:Object) : void
      {
         labelBtn.textColor = param1;
      }
      
      public function get textColor() : Object
      {
         return labelBtn.textColor;
      }
      
      public function set upTextColor(param1:Object) : void
      {
         labelBtn.upTextColor = param1;
      }
      
      public function get upTextColor() : Object
      {
         return labelBtn.upTextColor;
      }
      
      public function set overTextColor(param1:Object) : void
      {
         labelBtn.overTextColor = param1;
      }
      
      public function get overTextColor() : Object
      {
         return labelBtn.overTextColor;
      }
      
      public function set downTextColor(param1:Object) : void
      {
         labelBtn.downTextColor = param1;
      }
      
      public function get downTextColor() : Object
      {
         return labelBtn.downTextColor;
      }
      
      public function set selectedUpTextColor(param1:Object) : void
      {
         labelBtn.selectedUpTextColor = param1;
      }
      
      public function get selectedUpTextColor() : Object
      {
         return labelBtn.selectedUpTextColor;
      }
      
      public function set selectedOverTextColor(param1:Object) : void
      {
         labelBtn.selectedOverTextColor = param1;
      }
      
      public function get selectedOverTextColor() : Object
      {
         return labelBtn.selectedOverTextColor;
      }
      
      public function set selectedDownTextColor(param1:Object) : void
      {
         labelBtn.selectedDownTextColor = param1;
      }
      
      public function get selectedDownTextColor() : Object
      {
         return labelBtn.selectedDownTextColor;
      }
      
      public function set zLanID(param1:String) : void
      {
         labelBtn.zLanID = param1;
      }
      
      public function get zLanID() : String
      {
         return labelBtn.zLanID;
      }
      
      public function set fontLanID(param1:String) : void
      {
         labelBtn.fontLanID = param1;
      }
      
      public function get fontLanID() : String
      {
         return labelBtn.fontLanID;
      }
      
      override public function dispose() : void
      {
         labelBtn.removeEventListener("click",dropHandler);
         dropdown.removeEventListener("itemSelected",itemSelectedHandler);
      }
   }
}

