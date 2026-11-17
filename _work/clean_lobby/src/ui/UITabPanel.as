package ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class UITabPanel extends Sprite
   {
      
      public static const TAB_PANEL_CHANGE:String = "TAB_PANEL_CHANGE";
      
      private var _buttonSkin:String;
      
      private var _labels:Array;
      
      protected var _selectIndex:int = -1;
      
      protected var panelMap:Array;
      
      protected var _state:String;
      
      protected var bodyContainer:Sprite;
      
      protected var tabButton:UITabButton;
      
      public function UITabPanel()
      {
         super();
         init();
      }
      
      public function get align() : String
      {
         return tabButton.align;
      }
      
      public function set align(param1:String) : void
      {
         tabButton.align = param1;
         if(param1 == "vertical")
         {
            tabButton.y = 0;
            tabButton.x = 0;
            bodyContainer.y = tabButton.height;
            bodyContainer.x = tabButton.x;
         }
         else if(param1 == "horizon")
         {
            tabButton.x = 0;
            tabButton.y = 0;
            bodyContainer.x = tabButton.width;
            bodyContainer.y = tabButton.y;
         }
      }
      
      public function get selectIndex() : int
      {
         return _selectIndex;
      }
      
      public function set selectIndex(param1:int) : void
      {
         if(_selectIndex == param1)
         {
            return;
         }
         _selectIndex = param1;
         changeSelectPanel();
      }
      
      public function getPanel(param1:int) : DisplayObject
      {
         return panelMap[param1];
      }
      
      public function getSelectPanel() : DisplayObject
      {
         return panelMap[selectIndex];
      }
      
      public function addPanel(param1:UIButton, param2:DisplayObject, param3:int = 2, param4:int = -1, param5:* = -1) : void
      {
         tabButton.addButton(param1,param3,param4,param5);
         panelMap.push(param2);
      }
      
      public function set paddingLeft(param1:int) : void
      {
         bodyContainer.x = param1;
      }
      
      public function set paddingTop(param1:int) : void
      {
         bodyContainer.y = param1;
      }
      
      public function set paddingLeftOfButton(param1:int) : void
      {
         tabButton.x = param1;
      }
      
      public function setEnabled(param1:int, param2:Boolean) : void
      {
         tabButton.setEnabled(param1,param2);
      }
      
      protected function changeSelectPanel() : void
      {
         tabButton.selectIndex = selectIndex;
         bodyContainer.removeChildren();
         if(panelMap[selectIndex])
         {
            bodyContainer.addChild(panelMap[selectIndex]);
         }
      }
      
      protected function init() : void
      {
         tabButton = new UITabButton();
         addChild(tabButton);
         tabButton.addEventListener("TAB_BUTTON_CHANGE",onChangePanel);
         bodyContainer = new Sprite();
         addChild(bodyContainer);
         bodyContainer.y = tabButton.height;
         panelMap = [];
      }
      
      protected function onChangePanel(param1:Event) : void
      {
         selectIndex = tabButton.selectIndex;
         dispatchEvent(new Event("TAB_PANEL_CHANGE"));
      }
      
      public function clear() : void
      {
         tabButton.clear();
      }
      
      public function set buttonSkin(param1:String) : void
      {
         tabButton.buttonSkin = param1;
      }
      
      public function set buttonLabels(param1:Array) : void
      {
         tabButton.buttonLabels = param1;
      }
   }
}

