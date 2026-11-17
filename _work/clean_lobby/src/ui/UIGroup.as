package ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import ui.events.ItemEvent;
   
   public class UIGroup extends UIContainer implements IUIGroup
   {
      
      public static const DIRECTION_HORIZONTAL:String = "horizontal";
      
      public static const DIRECTION_VERTICAL:String = "vertical";
      
      public static const DIRECTION_ABSOLUTE:String = "absolute";
      
      public var mouseDownSelect:Boolean = true;
      
      private var _allowMultipleSelection:Boolean = false;
      
      private var _selectedIndices:Array;
      
      protected var _itemList:Vector.<IUICellRenderer>;
      
      protected var _direction:String;
      
      protected var _horizontalGap:int;
      
      protected var _verticalGap:int;
      
      protected var _currentItem:IUICellRenderer;
      
      protected var _selectedIndex:int = -1;
      
      protected var _content:Sprite;
      
      public function UIGroup()
      {
         super();
         _itemList = new Vector.<IUICellRenderer>();
         _direction = "absolute";
         _selectedIndices = [];
      }
      
      override protected function createChildren() : void
      {
         _content = new Sprite();
         this.addChild(_content);
      }
      
      protected function layout() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IUICellRenderer = null;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(_direction == "absolute" || _itemList.length == 0)
         {
            return;
         }
         _loc4_ = 0;
         _loc3_ = int(_itemList.length);
         while(_loc4_ < _loc3_)
         {
            _loc2_ = _itemList[_loc4_];
            if(_loc2_.parent == this && _loc2_.visible)
            {
               switch(_direction)
               {
                  case "horizontal":
                     _loc2_.x = _loc1_;
                     _loc1_ = _loc2_.x + _loc2_.width + _horizontalGap;
                     _loc2_.y = 0;
                     break;
                  case "vertical":
                     _loc2_.y = _loc1_;
                     _loc1_ = _loc2_.y + _loc2_.height + _verticalGap;
                     _loc2_.x = 0;
               }
            }
            _loc4_++;
         }
      }
      
      public function addCell(param1:IUICellRenderer) : void
      {
         addCellAt(param1,length);
      }
      
      public function addCellAt(param1:IUICellRenderer, param2:int) : void
      {
         var _loc3_:int = 0;
         if(_itemList.indexOf(param1) > -1)
         {
            return;
         }
         param1.index = param2;
         _loc3_ = length - 1;
         while(_loc3_ >= param2)
         {
            _itemList[_loc3_ + 1] = _itemList[_loc3_];
            _itemList[_loc3_ + 1].index++;
            _loc3_--;
         }
         _itemList[param2] = param1;
         param1.group = this;
         param1.enabled = _enabled;
         param1.doubleClickEnabled = true;
         param1.addEventListener("click",onCellClickHandler,false,0,true);
         param1.addEventListener("doubleClick",onCellDoubleClickHandler,false,0,true);
         param1.addEventListener("mouseDown",onCellMouseDownHandler,false,0,true);
         _content.addChild(param1 as DisplayObject);
         callLater(layout);
      }
      
      public function removeCell(param1:IUICellRenderer) : IUICellRenderer
      {
         var _loc3_:IUICellRenderer = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = _itemList.indexOf(param1);
         if(_loc2_ == -1)
         {
            return param1;
         }
         _loc5_ = _loc2_ + 1;
         _loc4_ = int(_itemList.length);
         while(_loc5_ < _loc4_)
         {
            _loc3_ = _itemList[_loc5_] as IUICellRenderer;
            _loc3_.index--;
            _loc5_++;
         }
         if(_loc2_ != -1)
         {
            _itemList.splice(_loc2_,1);
            if(param1 == _currentItem)
            {
               _currentItem = null;
            }
         }
         callLater(layout);
         if(param1)
         {
            disposeItem(param1);
         }
         return param1;
      }
      
      public function set selectedCell(param1:IUICellRenderer) : void
      {
         if(param1 && param1.group != this)
         {
            return;
         }
         if(param1 && param1.enabled == false)
         {
            return;
         }
         if(param1)
         {
            if(param1.deselected)
            {
               param1.selected = !param1.selected;
            }
            else
            {
               param1.selected = true;
            }
         }
         _selectedIndex = -1;
         while(!allowMultipleSelection && _selectedIndices.length > 0)
         {
            _selectedIndices.pop();
         }
         if(_currentItem)
         {
            if(_currentItem == param1)
            {
               if(_currentItem.deselected)
               {
                  _selectedIndices.splice(_selectedIndices.indexOf(_currentItem.index),1);
                  _currentItem = null;
                  if(_selectedIndices.length > 0)
                  {
                     _selectedIndex = _selectedIndices[_selectedIndices.length - 1];
                     _currentItem = getCellByIndex(_selectedIndex);
                  }
               }
               sendChangeEvent(_currentItem);
               return;
            }
            if(!allowMultipleSelection)
            {
               _currentItem.selected = false;
               _selectedIndices.splice(_selectedIndices.indexOf(_currentItem.index),1);
               _currentItem = null;
            }
         }
         if(param1 && param1.selected)
         {
            _currentItem = param1;
            if(_currentItem)
            {
               _selectedIndex = _currentItem.index;
               if(_selectedIndices.indexOf(_selectedIndex) == -1)
               {
                  _selectedIndices.push(_selectedIndex);
               }
            }
         }
         else
         {
            if(param1)
            {
               if(_selectedIndices.indexOf(param1.index) > -1)
               {
                  _selectedIndices.splice(_selectedIndices.indexOf(param1.index),1);
               }
            }
            if(_selectedIndices.length > 0)
            {
               _selectedIndex = _selectedIndices[_selectedIndices.length - 1];
               _currentItem = getCellByIndex(_selectedIndex);
            }
         }
         sendChangeEvent(_currentItem);
      }
      
      protected function sendChangeEvent(param1:IUICellRenderer) : void
      {
         dispatchEvent(new Event("change"));
         dispatchEvent(new ItemEvent("itemSelected",param1,param1 != null ? param1.index : -1,param1 != null ? param1.data : null));
      }
      
      public function get selectedCell() : IUICellRenderer
      {
         return _currentItem;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = -1;
         }
         if(param1 >= _itemList.length)
         {
            param1 = _itemList.length - 1;
         }
         _selectedIndex = param1;
         if(param1 > -1 && param1 < _itemList.length)
         {
            selectedCell = _itemList[param1];
         }
         else
         {
            selectedCell = null;
         }
      }
      
      public function get selectedIndex() : int
      {
         return _selectedIndex;
      }
      
      public function set selectedIndices(param1:Array) : void
      {
         for each(var _loc2_ in param1)
         {
            selectedIndex = _loc2_;
         }
      }
      
      public function get selectedIndices() : Array
      {
         return _selectedIndices.concat();
      }
      
      public function set allowMultipleSelection(param1:Boolean) : void
      {
         _allowMultipleSelection = param1;
      }
      
      public function get allowMultipleSelection() : Boolean
      {
         return _allowMultipleSelection;
      }
      
      public function getCellByIndex(param1:int) : IUICellRenderer
      {
         return _itemList[param1];
      }
      
      protected function onCellClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:IUICellRenderer = param1.currentTarget as IUICellRenderer;
         if(mouseDownSelect)
         {
            selectedCell = _loc2_;
         }
         this.dispatchEvent(new ItemEvent("itemClick",_loc2_,_loc2_.index,_loc2_.data));
      }
      
      protected function onCellDoubleClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:IUICellRenderer = param1.currentTarget as IUICellRenderer;
         this.dispatchEvent(new ItemEvent("itemDoubleClick",_loc2_,_loc2_.index,_loc2_.data));
      }
      
      protected function onCellMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:IUICellRenderer = param1.currentTarget as IUICellRenderer;
         this.dispatchEvent(new ItemEvent("itemMouseDown",_loc2_,_loc2_ ? _loc2_.index : -1,_loc2_ ? _loc2_.data : null));
      }
      
      public function get length() : int
      {
         return _itemList.length;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(_enabled == param1)
         {
            return;
         }
         super.enabled = param1;
         _loc2_ = 0;
         while(_loc2_ < _itemList.length)
         {
            _itemList[_loc2_].enabled = param1;
            _loc2_++;
         }
      }
      
      public function set horizontalGap(param1:int) : void
      {
         _horizontalGap = param1;
         callLater(layout);
      }
      
      public function get horizontalGap() : int
      {
         return _horizontalGap;
      }
      
      public function set verticalGap(param1:int) : void
      {
         _verticalGap = param1;
         callLater(layout);
      }
      
      public function get verticalGap() : int
      {
         return _verticalGap;
      }
      
      public function set direction(param1:String) : void
      {
         _direction = param1;
         callLater(layout);
      }
      
      public function get direction() : String
      {
         return _direction;
      }
      
      public function get content() : Sprite
      {
         return _content;
      }
      
      public function clear() : void
      {
         var _loc1_:IUICellRenderer = null;
         _selectedIndices = [];
         _selectedIndex = -1;
         while(_itemList.length > 0)
         {
            _loc1_ = _itemList.pop();
            disposeItem(_loc1_);
         }
         _currentItem = null;
      }
      
      protected function disposeItem(param1:IUICellRenderer) : void
      {
         param1.removeEventListener("click",onCellClickHandler);
         param1.removeEventListener("doubleClick",onCellDoubleClickHandler);
         param1.removeEventListener("mouseDown",onCellMouseDownHandler);
         param1.group = null;
         param1.index = 0;
         param1.selected = false;
         if(param1.parent == content)
         {
            content.removeChild(param1 as DisplayObject);
         }
         param1.dispose();
      }
      
      protected function resetItem(param1:IUICellRenderer) : void
      {
         param1.removeEventListener("click",onCellClickHandler);
         param1.removeEventListener("doubleClick",onCellDoubleClickHandler);
         param1.removeEventListener("mouseDown",onCellMouseDownHandler);
         param1.group = null;
         param1.index = 0;
         param1.selected = false;
         if(param1.parent == content)
         {
            content.removeChild(param1 as DisplayObject);
         }
         param1.reset();
      }
   }
}

