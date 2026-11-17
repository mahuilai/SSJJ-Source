package ui
{
   import fl.data.DataProvider;
   import fl.events.DataChangeEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import ui.events.ItemEvent;
   import ui.events.PageEvent;
   import utils.InstanceUtil;
   
   public class UIList extends UIGroup implements IUIList
   {
      
      private var _data:DataProvider = null;
      
      private var _columnCount:int = 1;
      
      private var _rowCount:int = 0;
      
      private var _columnWidth:int;
      
      private var _rowHeight:int;
      
      private var _itemRendererClass:Class = null;
      
      private var _cellRendererName:String;
      
      private var _itemPool:Array = [];
      
      private var _page:IUIPage;
      
      private var _scrollPane:UIScrollPane;
      
      private var _currentSelectedIndex:int = -1;
      
      private var _defaultSetData:Boolean;
      
      public var defaultSelected:Boolean = false;
      
      public var resetWhenReturn:Boolean = false;
      
      public function UIList()
      {
         super();
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         _scrollPane = new UIScrollPane();
         _scrollPane.doubleClickEnabled = true;
         _content.doubleClickEnabled = true;
         this.addChild(_scrollPane);
         _scrollPane.content = _content;
         _scrollPane.horizontalScrollPolicy = "off";
      }
      
      public function set dataProvider(param1:DataProvider) : void
      {
         var _loc2_:int = 0;
         if(dataProvider == param1)
         {
            return;
         }
         if(_data != null)
         {
            _data.removeEventListener("dataChange",handleDataChange);
         }
         _data = param1;
         if(param1 != null)
         {
            _data.addEventListener("dataChange",handleDataChange,false,0,true);
            if(_page != null)
            {
               _loc2_ = _page.currentPage;
               _page.totalPage = Math.ceil(param1.length / pageSize);
               if(_page.currentPage != _loc2_)
               {
                  _currentSelectedIndex = -1;
               }
            }
            _defaultSetData = true;
            refresh();
         }
         else
         {
            clear();
         }
      }
      
      public function get dataProvider() : DataProvider
      {
         return _data;
      }
      
      protected function refresh() : void
      {
         var _loc1_:IUICellRenderer = null;
         var _loc3_:int = 0;
         if(_data == null || _itemRendererClass == null || _columnCount <= 0)
         {
            clear();
            return;
         }
         var _loc2_:int = int(_data.length);
         if(_page != null)
         {
            if(_page.currentPage * pageSize > _data.length)
            {
               _loc2_ = _data.length - (_page.currentPage - 1) * pageSize;
            }
            else
            {
               _loc2_ = Math.min(pageSize,_data.length);
            }
         }
         if(_loc2_ <= 0)
         {
            clear();
            return;
         }
         if(_currentItem != null && _defaultSetData)
         {
            clear();
         }
         recoverItemToPool();
         var _loc4_:int = _page != null ? (_page.currentPage - 1) * pageSize : 0;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = getItemFormPool();
            addCell(_loc1_);
            _loc1_.data = _data.getItemAt(_loc3_ + _loc4_);
            _loc3_++;
         }
         if(_defaultSetData && _currentSelectedIndex == -1)
         {
            if(defaultSelected && mouseDownSelect)
            {
               selectedIndex = 0;
            }
            _defaultSetData = false;
         }
         else if(_currentSelectedIndex > -1)
         {
            selectedIndex = _currentSelectedIndex;
         }
         layout();
      }
      
      override protected function layout() : void
      {
         var _loc1_:IUICellRenderer = null;
         var _loc4_:IUICellRenderer = null;
         var _loc3_:int = 0;
         var _loc2_:int = length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = getCellByIndex(_loc3_);
            if(_loc4_ != null)
            {
               if(_loc3_ % _columnCount == 0)
               {
                  _loc1_.x = 0;
                  if(rowHeight > 0)
                  {
                     _loc1_.y = _loc4_.y + rowHeight + _verticalGap;
                  }
                  else
                  {
                     _loc1_.y = _loc4_.y + _loc4_.height + _verticalGap;
                  }
               }
               else
               {
                  if(columnWidth > 0)
                  {
                     _loc1_.x = _loc4_.x + columnWidth + _horizontalGap;
                  }
                  else
                  {
                     _loc1_.x = _loc4_.x + _loc4_.width + _horizontalGap;
                  }
                  _loc1_.y = _loc4_.y;
               }
            }
            else
            {
               _loc1_.x = _loc1_.y = 0;
            }
            _loc4_ = _loc1_;
            _loc3_++;
         }
         scrollPane.update();
      }
      
      private function isOutOfPage(param1:*) : Boolean
      {
         if(page && (param1 < (page.currentPage - 1) * pageSize || param1 >= page.currentPage * pageSize))
         {
            return true;
         }
         return false;
      }
      
      protected function handleDataChange(param1:DataChangeEvent) : void
      {
         var _loc6_:int = 0;
         var _loc4_:IUICellRenderer = null;
         var _loc3_:int = int(param1.startIndex);
         var _loc5_:int = int(param1.endIndex);
         var _loc2_:String = param1.changeType;
         if(_loc2_ == "invalidateAll")
         {
            callLater(refresh);
         }
         else if(_loc2_ == "invalidate")
         {
            if(isOutOfPage(_loc3_))
            {
               return;
            }
            getCellByIndex(_loc3_ % pageSize).data = dataProvider.getItemAt(_loc3_);
         }
         else if(_loc2_ == "add")
         {
            if(isOutOfPage(_loc3_))
            {
               return;
            }
            addNewCellAt(dataProvider.getItemAt(_loc3_),_loc3_);
         }
         else if(_loc2_ == "remove")
         {
            if(isOutOfPage(_loc3_))
            {
               return;
            }
            _loc4_ = _itemList[_loc3_];
            removeCell(_loc4_);
         }
         else if(_loc2_ == "removeAll")
         {
            clear();
         }
         else if(_loc2_ != "replace")
         {
         }
      }
      
      public function addItem(param1:Object) : void
      {
         addItemAt(param1,dataProvider == null ? 0 : dataProvider.length);
      }
      
      public function addItemAt(param1:Object, param2:int) : void
      {
         if(dataProvider == null)
         {
            dataProvider = new DataProvider();
         }
         dataProvider.addItemAt(param1,param2);
      }
      
      private function addNewCellAt(param1:Object, param2:int) : void
      {
         var _loc3_:IUICellRenderer = getItemFormPool();
         _loc3_.data = param1;
         addCellAt(_loc3_,param2);
      }
      
      public function removeItem(param1:Object) : void
      {
         dataProvider.removeItem(param1);
      }
      
      public function removeItemAt(param1:int) : void
      {
         dataProvider.removeItemAt(param1);
      }
      
      override public function addCellAt(param1:IUICellRenderer, param2:int) : void
      {
         super.addCellAt(param1,param2);
         if(rowHeight > 0)
         {
            param1.height = rowHeight;
         }
         if(columnWidth > 0)
         {
            param1.width = columnWidth;
         }
      }
      
      public function set selectedItem(param1:Object) : void
      {
         if(!dataProvider)
         {
            return;
         }
         var _loc2_:int = dataProvider.getItemIndex(param1);
         selectedIndex = _loc2_;
      }
      
      public function get selectedItem() : Object
      {
         if(_currentItem == null)
         {
            return null;
         }
         return _currentItem.data;
      }
      
      override public function set selectedCell(param1:IUICellRenderer) : void
      {
         super.selectedCell = param1;
      }
      
      override protected function sendChangeEvent(param1:IUICellRenderer) : void
      {
         if(_currentItem != null)
         {
            _currentSelectedIndex = _currentItem.index;
         }
         else
         {
            _currentSelectedIndex = -1;
         }
         dispatchEvent(new Event("change"));
         dispatchEvent(new ItemEvent("itemSelected",param1,param1 != null ? param1.index : -1,param1 != null ? param1.data : null));
      }
      
      override public function set selectedIndex(param1:int) : void
      {
         if(!_data)
         {
            return;
         }
         if(param1 >= _data.length)
         {
            param1 = _data.length - 1;
         }
         if(param1 < 0)
         {
            param1 = -1;
         }
         if(_page != null)
         {
            _page.currentPage = Math.ceil((param1 + 1) / pageSize);
            _currentSelectedIndex = param1 % pageSize;
            callLater(refresh);
         }
         else if(param1 <= pageSize)
         {
            _currentSelectedIndex = param1;
            super.selectedIndex = param1;
         }
      }
      
      override public function get selectedIndex() : int
      {
         return _currentSelectedIndex;
      }
      
      private function pageFlipHandler(param1:PageEvent) : void
      {
         _currentSelectedIndex = -1;
         callLater(refresh);
      }
      
      private function recoverItemToPool() : void
      {
         var _loc1_:IUICellRenderer = null;
         while(_itemList.length > 0)
         {
            _loc1_ = _itemList.shift();
            if(!resetWhenReturn)
            {
               disposeItem(_loc1_);
            }
            else
            {
               resetItem(_loc1_);
            }
         }
         _currentItem = null;
      }
      
      private function getItemFormPool() : IUICellRenderer
      {
         if(_itemPool.length > 0)
         {
            return _itemPool.pop();
         }
         if(_itemRendererClass != null)
         {
            return new _itemRendererClass();
         }
         return null;
      }
      
      override protected function disposeItem(param1:IUICellRenderer) : void
      {
         super.disposeItem(param1);
         _itemPool.push(param1);
      }
      
      override protected function resetItem(param1:IUICellRenderer) : void
      {
         super.resetItem(param1);
         _itemPool.push(param1);
      }
      
      public function preCreateItems(param1:int) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1)
         {
            _itemPool.push(new _itemRendererClass());
            _loc2_++;
         }
      }
      
      public function clearItemPool() : void
      {
         var _loc1_:IUICellRenderer = null;
         while(_itemPool.length > 0)
         {
            _loc1_ = _itemPool.shift() as IUICellRenderer;
            _loc1_.dispose();
         }
      }
      
      override public function clear() : void
      {
         var _loc1_:IUICellRenderer = null;
         selectedIndices = [];
         _selectedIndex = -1;
         while(_itemList.length > 0)
         {
            _loc1_ = _itemList.pop();
            if(!resetWhenReturn)
            {
               disposeItem(_loc1_);
            }
            else
            {
               resetItem(_loc1_);
            }
         }
         _currentItem = null;
         _currentSelectedIndex = -1;
      }
      
      override public function removeCell(param1:IUICellRenderer) : IUICellRenderer
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
            if(!resetWhenReturn)
            {
               disposeItem(param1);
            }
            else
            {
               resetItem(param1);
            }
         }
         return param1;
      }
      
      override protected function changeSize() : void
      {
         scrollPane.update();
         super.changeSize();
      }
      
      public function set columnCount(param1:int) : void
      {
         if(_columnCount == param1)
         {
            return;
         }
         _columnCount = param1;
         callLater(refresh);
      }
      
      public function get columnCount() : int
      {
         return _columnCount;
      }
      
      public function set rowCount(param1:int) : void
      {
         if(_rowCount == param1)
         {
            return;
         }
         _rowCount = param1;
         if(_rowCount > 0 && _rowHeight > 0)
         {
            height = _rowCount * _rowHeight;
         }
         callLater(refresh);
      }
      
      public function get rowCount() : int
      {
         return _rowCount;
      }
      
      public function set rowHeight(param1:int) : void
      {
         if(_rowHeight == param1)
         {
            return;
         }
         _rowHeight = param1;
         if(_rowCount > 0 && _rowHeight > 0)
         {
            height = _rowCount * _rowHeight;
         }
         callLater(refresh);
      }
      
      public function get rowHeight() : int
      {
         return _rowHeight;
      }
      
      public function set columnWidth(param1:int) : void
      {
         if(_columnWidth == param1)
         {
            return;
         }
         _columnWidth = param1;
         callLater(refresh);
      }
      
      public function get columnWidth() : int
      {
         return _columnWidth;
      }
      
      public function set cellRenderer(param1:Class) : void
      {
         if(_itemRendererClass == param1)
         {
            return;
         }
         clearItemPool();
         _itemRendererClass = param1;
         callLater(refresh);
      }
      
      public function get cellRenderer() : Class
      {
         return _itemRendererClass;
      }
      
      public function set cellRendererName(param1:String) : void
      {
         if(_cellRendererName == param1)
         {
            return;
         }
         _cellRendererName = param1;
         cellRenderer = InstanceUtil.getClassByName(param1);
      }
      
      public function get cellRendererName() : String
      {
         return _cellRendererName;
      }
      
      public function get pageSize() : int
      {
         if(page == null)
         {
            return 2147483647;
         }
         return _rowCount * _columnCount;
      }
      
      public function getDataIndex(param1:int) : int
      {
         if(_page != null)
         {
            return (_page.currentPage - 1) * pageSize + param1;
         }
         return param1;
      }
      
      override protected function onCellMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:IUICellRenderer = param1.currentTarget as IUICellRenderer;
         if(mouseDownSelect)
         {
            selectedCell = _loc2_;
         }
         super.onCellMouseDownHandler(param1);
      }
      
      override protected function onCellClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:IUICellRenderer = param1.currentTarget as IUICellRenderer;
         this.dispatchEvent(new ItemEvent("itemClick",_loc2_,_loc2_.index,_loc2_.data));
      }
      
      public function set page(param1:IUIPage) : void
      {
         if(_page == param1)
         {
            return;
         }
         if(_page)
         {
            _page.removeEventListener("flip",pageFlipHandler);
         }
         _page = param1;
         if(_page)
         {
            _page.addEventListener("flip",pageFlipHandler);
         }
         refresh();
      }
      
      public function get page() : IUIPage
      {
         return _page;
      }
      
      public function get scrollPane() : UIScrollPane
      {
         return _scrollPane;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         scrollPane.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         scrollPane.height = param1;
      }
      
      public function set horizontalScrollPolicy(param1:String) : void
      {
         scrollPane.horizontalScrollPolicy = param1;
      }
      
      public function get horizontalScrollPolicy() : String
      {
         return scrollPane.horizontalScrollPolicy;
      }
      
      public function set verticalScrollPolicy(param1:String) : void
      {
         scrollPane.verticalScrollPolicy = param1;
      }
      
      public function get verticalScrollPolicy() : String
      {
         return scrollPane.verticalScrollPolicy;
      }
      
      public function set scrollBarSkins(param1:String) : void
      {
         scrollPane.verticalScrollBar.skin = param1;
      }
      
      public function get scrollBarSkins() : String
      {
         return scrollPane.verticalScrollBar.skin;
      }
      
      public function set verticalScrollBarSkins(param1:String) : void
      {
         scrollPane.verticalScrollBar.skin = param1;
      }
      
      public function get verticalScrollBarSkins() : String
      {
         return scrollPane.verticalScrollBar.skin;
      }
      
      public function set horizontalScrollBarSkins(param1:String) : void
      {
         scrollPane.horizontalScrollBar.skin = param1;
      }
      
      public function get horizontalScrollBarSkins() : String
      {
         return scrollPane.horizontalScrollBar.skin;
      }
      
      override public function dispose() : void
      {
         if(_data != null)
         {
            _data.removeEventListener("dataChange",handleDataChange);
         }
         _data = null;
         clear();
         clearItemPool();
         _page = null;
      }
      
      public function setStyle(param1:String, param2:Object) : void
      {
         if(param1 == "cellRenderer")
         {
            cellRenderer = param2 as Class;
            return;
         }
         throw new Error("list Error style");
      }
      
      public function invalidateList() : void
      {
      }
      
      public function invalidateItemAt(param1:int) : void
      {
         dataProvider.invalidateItemAt(param1);
      }
      
      public function removeAll() : void
      {
         if(dataProvider)
         {
            dataProvider.removeAll();
         }
      }
   }
}

