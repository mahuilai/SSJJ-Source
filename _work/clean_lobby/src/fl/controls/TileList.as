package fl.controls
{
   import fl.controls.listClasses.ICellRenderer;
   import fl.controls.listClasses.ImageCell;
   import fl.controls.listClasses.ListData;
   import fl.controls.listClasses.TileListData;
   import fl.core.UIComponent;
   import fl.data.DataProvider;
   import fl.data.TileListCollectionItem;
   import fl.managers.IFocusManagerComponent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.utils.Dictionary;
   
   public class TileList extends SelectableList implements IFocusManagerComponent
   {
      
      public static var createAccessibilityImplementation:Function;
      
      private static var defaultStyles:Object = {
         "cellRenderer":ImageCell,
         "focusRectSkin":null,
         "focusRectPadding":null,
         "skin":"TileList_skin"
      };
      
      protected var _rowHeight:Number = 50;
      
      protected var _columnWidth:Number = 50;
      
      protected var _scrollDirection:String = "horizontal";
      
      protected var _scrollPolicy:String = "auto";
      
      protected var _cellRenderer:Object;
      
      protected var oldLength:uint = 0;
      
      protected var _labelField:String = "label";
      
      protected var _labelFunction:Function;
      
      protected var _iconField:String = "icon";
      
      protected var _iconFunction:Function;
      
      protected var _sourceField:String = "source";
      
      protected var _sourceFunction:Function;
      
      protected var __rowCount:uint = 0;
      
      protected var __columnCount:uint = 0;
      
      private var collectionItemImport:TileListCollectionItem;
      
      public function TileList()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return mergeStyles(defaultStyles,SelectableList.getStyleDefinition(),ScrollBar.getStyleDefinition());
      }
      
      override public function get dataProvider() : DataProvider
      {
         return super.dataProvider;
      }
      
      override public function set dataProvider(param1:DataProvider) : void
      {
         super.dataProvider = param1;
      }
      
      public function get labelField() : String
      {
         return _labelField;
      }
      
      public function set labelField(param1:String) : void
      {
         if(param1 == _labelField)
         {
            return;
         }
         _labelField = param1;
         invalidate("data");
      }
      
      public function get labelFunction() : Function
      {
         return _labelFunction;
      }
      
      public function set labelFunction(param1:Function) : void
      {
         if(_labelFunction == param1)
         {
            return;
         }
         _labelFunction = param1;
         invalidate("data");
      }
      
      public function get iconField() : String
      {
         return _iconField;
      }
      
      public function set iconField(param1:String) : void
      {
         if(param1 == _iconField)
         {
            return;
         }
         _iconField = param1;
         invalidate("data");
      }
      
      public function get iconFunction() : Function
      {
         return _iconFunction;
      }
      
      public function set iconFunction(param1:Function) : void
      {
         if(_iconFunction == param1)
         {
            return;
         }
         _iconFunction = param1;
         invalidate("data");
      }
      
      public function get sourceField() : String
      {
         return _sourceField;
      }
      
      public function set sourceField(param1:String) : void
      {
         _sourceField = param1;
         invalidate("data");
      }
      
      public function get sourceFunction() : Function
      {
         return _sourceFunction;
      }
      
      public function set sourceFunction(param1:Function) : void
      {
         _sourceFunction = param1;
         invalidate("data");
      }
      
      override public function get rowCount() : uint
      {
         var _loc1_:Number = Number(getStyleValue("contentPadding"));
         var _loc2_:uint = Math.max(1,(_width - 2 * _loc1_) / _columnWidth << 0);
         var _loc3_:uint = Math.max(1,(_height - 2 * _loc1_) / _rowHeight << 0);
         if(_scrollDirection == "horizontal")
         {
            if(_scrollPolicy == "on" || _scrollPolicy == "auto" && length > _loc2_ * _loc3_)
            {
               _loc3_ = Math.max(1,(_height - 2 * _loc1_ - 15) / _rowHeight << 0);
            }
         }
         else
         {
            _loc3_ = Math.max(1,Math.ceil((_height - 2 * _loc1_) / _rowHeight));
         }
         return _loc3_;
      }
      
      public function set rowCount(param1:uint) : void
      {
         if(param1 == 0)
         {
            return;
         }
         if(componentInspectorSetting)
         {
            __rowCount = param1;
            return;
         }
         __rowCount = 0;
         var _loc2_:Number = Number(getStyleValue("contentPadding"));
         var _loc3_:Boolean = Math.ceil(length / param1) > width / columnWidth >> 0 && _scrollPolicy == "auto" || _scrollPolicy == "on";
         height = rowHeight * param1 + 2 * _loc2_ + (_scrollDirection == "horizontal" && _loc3_ ? 15 : 0);
      }
      
      public function get rowHeight() : Number
      {
         return _rowHeight;
      }
      
      public function set rowHeight(param1:Number) : void
      {
         if(_rowHeight == param1)
         {
            return;
         }
         _rowHeight = param1;
         invalidate("size");
      }
      
      public function get columnCount() : uint
      {
         var _loc1_:Number = Number(getStyleValue("contentPadding"));
         var _loc2_:uint = Math.max(1,(_width - 2 * _loc1_) / _columnWidth << 0);
         var _loc3_:uint = Math.max(1,(_height - 2 * _loc1_) / _rowHeight << 0);
         if(_scrollDirection != "horizontal")
         {
            if(_scrollPolicy == "on" || _scrollPolicy == "auto" && length > _loc2_ * _loc3_)
            {
               _loc2_ = Math.max(1,(_width - 2 * _loc1_ - 15) / _columnWidth << 0);
            }
         }
         else
         {
            _loc2_ = Math.max(1,Math.ceil((_width - 2 * _loc1_) / _columnWidth));
         }
         return _loc2_;
      }
      
      public function set columnCount(param1:uint) : void
      {
         if(param1 == 0)
         {
            return;
         }
         if(componentInspectorSetting)
         {
            __columnCount = param1;
            return;
         }
         __columnCount = 0;
         var _loc2_:Number = Number(getStyleValue("contentPadding"));
         var _loc3_:Boolean = Math.ceil(length / param1) > height / rowHeight >> 0 && _scrollPolicy == "auto" || _scrollPolicy == "on";
         width = columnWidth * param1 + 2 * _loc2_ + (_scrollDirection == "vertical" && _loc3_ ? 15 : 0);
      }
      
      public function get columnWidth() : Number
      {
         return _columnWidth;
      }
      
      public function set columnWidth(param1:Number) : void
      {
         if(_columnWidth == param1)
         {
            return;
         }
         _columnWidth = param1;
         invalidate("size");
      }
      
      public function get innerWidth() : Number
      {
         drawNow();
         var _loc1_:Number = getStyleValue("contentPadding") as Number;
         return width - _loc1_ * 2 - (_verticalScrollBar.visible ? _verticalScrollBar.width : 0);
      }
      
      public function get innerHeight() : Number
      {
         drawNow();
         var _loc1_:Number = getStyleValue("contentPadding") as Number;
         return height - _loc1_ * 2 - (_horizontalScrollBar.visible ? _horizontalScrollBar.height : 0);
      }
      
      public function get direction() : String
      {
         return _scrollDirection;
      }
      
      public function set direction(param1:String) : void
      {
         if(_scrollDirection == param1)
         {
            return;
         }
         _scrollDirection = param1;
         invalidate("size");
      }
      
      public function get scrollPolicy() : String
      {
         return _scrollPolicy;
      }
      
      public function set scrollPolicy(param1:String) : void
      {
         if(!componentInspectorSetting && _scrollPolicy == param1)
         {
            return;
         }
         _scrollPolicy = param1;
         if(direction == "horizontal")
         {
            _horizontalScrollPolicy = param1;
            _verticalScrollPolicy = "off";
         }
         else
         {
            _verticalScrollPolicy = param1;
            _horizontalScrollPolicy = "off";
         }
         invalidate("size");
      }
      
      override public function scrollToIndex(param1:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         drawNow();
         var _loc2_:uint = Math.max(1,contentWidth / _columnWidth << 0);
         if(_scrollDirection == "vertical")
         {
            if(rowHeight > availableHeight)
            {
               return;
            }
            _loc3_ = (param1 / _loc2_ >> 0) * rowHeight;
            if(_loc3_ < verticalScrollPosition)
            {
               verticalScrollPosition = _loc3_;
            }
            else if(_loc3_ > verticalScrollPosition + availableHeight - rowHeight)
            {
               verticalScrollPosition = _loc3_ + rowHeight - availableHeight;
            }
         }
         else
         {
            if(columnWidth > availableWidth)
            {
               return;
            }
            _loc4_ = param1 % _loc2_ * columnWidth;
            if(_loc4_ < horizontalScrollPosition)
            {
               horizontalScrollPosition = _loc4_;
            }
            else if(_loc4_ > horizontalScrollPosition + availableWidth - columnWidth)
            {
               horizontalScrollPosition = _loc4_ + columnWidth - availableWidth;
            }
         }
      }
      
      override public function itemToLabel(param1:Object) : String
      {
         if(_labelFunction != null)
         {
            return String(_labelFunction(param1));
         }
         if(param1[_labelField] == null)
         {
            return "";
         }
         return String(param1[_labelField]);
      }
      
      override public function get verticalScrollPolicy() : String
      {
         return null;
      }
      
      override public function set verticalScrollPolicy(param1:String) : void
      {
      }
      
      override public function get horizontalScrollPolicy() : String
      {
         return null;
      }
      
      override public function set horizontalScrollPolicy(param1:String) : void
      {
      }
      
      override public function get maxHorizontalScrollPosition() : Number
      {
         drawNow();
         return _maxHorizontalScrollPosition;
      }
      
      override public function set maxHorizontalScrollPosition(param1:Number) : void
      {
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         _horizontalScrollPolicy = scrollPolicy;
         _verticalScrollPolicy = "off";
      }
      
      override protected function setHorizontalScrollPosition(param1:Number, param2:Boolean = false) : void
      {
         invalidate("scroll");
         super.setHorizontalScrollPosition(param1,true);
      }
      
      override protected function setVerticalScrollPosition(param1:Number, param2:Boolean = false) : void
      {
         invalidate("scroll");
         super.setVerticalScrollPosition(param1,true);
      }
      
      override protected function draw() : void
      {
         if(direction == "vertical")
         {
            if(__rowCount > 0)
            {
               rowCount = __rowCount;
            }
            if(__columnCount > 0)
            {
               columnCount = __columnCount;
            }
         }
         else
         {
            if(__columnCount > 0)
            {
               columnCount = __columnCount;
            }
            if(__rowCount > 0)
            {
               rowCount = __rowCount;
            }
         }
         var _loc1_:Boolean = oldLength != length;
         oldLength = length;
         if(isInvalid("styles"))
         {
            setStyles();
            drawBackground();
            if(contentPadding != getStyleValue("contentPadding"))
            {
               invalidate("size",false);
            }
            if(_cellRenderer != getStyleValue("cellRenderer"))
            {
               _invalidateList();
               _cellRenderer = getStyleValue("cellRenderer");
            }
         }
         if(isInvalid("size","state") || _loc1_)
         {
            drawLayout();
         }
         if(isInvalid("rendererStyles"))
         {
            updateRendererStyles();
         }
         if(isInvalid("styles","size","data","scroll","selected"))
         {
            drawList();
            _maxHorizontalScrollPosition = Math.max(0,contentWidth - availableWidth);
         }
         updateChildren();
         validate();
      }
      
      override protected function drawLayout() : void
      {
         var _loc2_:* = 0;
         var _loc1_:* = 0;
         _horizontalScrollPolicy = _scrollDirection == "horizontal" ? _scrollPolicy : "off";
         _verticalScrollPolicy = _scrollDirection != "horizontal" ? _scrollPolicy : "off";
         if(_scrollDirection == "horizontal")
         {
            _loc2_ = rowCount;
            contentHeight = _loc2_ * _rowHeight;
            contentWidth = _columnWidth * Math.ceil(length / _loc2_);
         }
         else
         {
            _loc1_ = columnCount;
            contentWidth = _loc1_ * _columnWidth;
            contentHeight = _rowHeight * Math.ceil(length / _loc1_);
         }
         super.drawLayout();
      }
      
      override protected function drawList() : void
      {
         var _loc18_:* = 0;
         var _loc19_:* = 0;
         var _loc24_:Object = null;
         var _loc6_:ICellRenderer = null;
         var _loc1_:* = 0;
         var _loc15_:* = 0;
         var _loc26_:* = 0;
         var _loc9_:* = 0;
         var _loc11_:* = 0;
         var _loc3_:* = 0;
         var _loc8_:Boolean = false;
         var _loc20_:Sprite = null;
         var _loc14_:String = null;
         var _loc10_:Object = null;
         var _loc21_:Object = null;
         var _loc5_:UIComponent = null;
         var _loc17_:uint = rowCount;
         var _loc2_:uint = columnCount;
         var _loc12_:Number = columnWidth;
         var _loc7_:Number = rowHeight;
         var _loc23_:Number = 0;
         var _loc25_:Number = 0;
         listHolder.x = listHolder.y = contentPadding;
         contentScrollRect = listHolder.scrollRect;
         contentScrollRect.x = Math.floor(_horizontalScrollPosition) % _loc12_;
         contentScrollRect.y = Math.floor(_verticalScrollPosition) % _loc7_;
         listHolder.scrollRect = contentScrollRect;
         listHolder.cacheAsBitmap = useBitmapScrolling;
         var _loc22_:Array = [];
         if(_scrollDirection == "horizontal")
         {
            _loc26_ = uint(availableWidth / _loc12_ << 0);
            _loc9_ = uint(Math.max(_loc26_,Math.ceil(length / _loc17_)));
            _loc23_ = _horizontalScrollPosition / _loc12_ << 0;
            _loc2_ = Math.max(_loc26_,Math.min(_loc9_ - _loc23_,_loc2_ + 1));
            _loc15_ = 0;
            while(_loc15_ < _loc17_)
            {
               _loc1_ = 0;
               while(_loc1_ < _loc2_)
               {
                  _loc19_ = uint(_loc15_ * _loc9_ + _loc23_ + _loc1_);
                  if(_loc19_ >= length)
                  {
                     break;
                  }
                  _loc22_.push(_loc19_);
                  _loc1_++;
               }
               _loc15_++;
            }
         }
         else
         {
            _loc17_++;
            _loc25_ = _verticalScrollPosition / _loc7_ << 0;
            _loc11_ = uint(Math.floor(_loc25_ * _loc2_));
            _loc3_ = uint(Math.min(length,_loc11_ + _loc17_ * _loc2_));
            _loc18_ = _loc11_;
            while(_loc18_ < _loc3_)
            {
               _loc22_.push(_loc18_);
               _loc18_++;
            }
         }
         var _loc16_:Dictionary = renderedItems = new Dictionary(true);
         for each(_loc19_ in _loc22_)
         {
            _loc16_[_dataProvider.getItemAt(_loc19_)] = true;
         }
         var _loc4_:Dictionary = new Dictionary(true);
         while(activeCellRenderers.length > 0)
         {
            _loc6_ = activeCellRenderers.pop();
            _loc24_ = _loc6_.data;
            if(_loc16_[_loc24_] == null || invalidItems[_loc24_] == true)
            {
               availableCellRenderers.push(_loc6_);
            }
            else
            {
               _loc4_[_loc24_] = _loc6_;
               invalidItems[_loc24_] = true;
            }
            list.removeChild(_loc6_ as DisplayObject);
         }
         invalidItems = new Dictionary(true);
         _loc18_ = 0;
         for each(_loc19_ in _loc22_)
         {
            _loc1_ = uint(_loc18_ % _loc2_);
            _loc15_ = uint(_loc18_ / _loc2_ << 0);
            _loc8_ = false;
            _loc24_ = _dataProvider.getItemAt(_loc19_);
            if(_loc4_[_loc24_] != null)
            {
               _loc8_ = true;
               _loc6_ = _loc4_[_loc24_];
               delete _loc4_[_loc24_];
            }
            else if(availableCellRenderers.length > 0)
            {
               _loc6_ = availableCellRenderers.pop() as ICellRenderer;
            }
            else
            {
               _loc6_ = getDisplayObjectInstance(getStyleValue("cellRenderer")) as ICellRenderer;
               _loc20_ = _loc6_ as Sprite;
               if(_loc20_ != null)
               {
                  _loc20_.addEventListener("click",handleCellRendererClick,false,0,true);
                  _loc20_.addEventListener("rollOver",handleCellRendererMouseEvent,false,0,true);
                  _loc20_.addEventListener("rollOut",handleCellRendererMouseEvent,false,0,true);
                  _loc20_.addEventListener("change",handleCellRendererChange,false,0,true);
                  _loc20_.doubleClickEnabled = true;
                  _loc20_.addEventListener("doubleClick",handleCellRendererDoubleClick,false,0,true);
                  if(_loc20_["setStyle"] != null)
                  {
                     for(var _loc13_ in rendererStyles)
                     {
                        _loc20_["setStyle"](_loc13_,rendererStyles[_loc13_]);
                     }
                  }
               }
            }
            list.addChild(_loc6_ as Sprite);
            activeCellRenderers.push(_loc6_);
            _loc6_.y = _loc7_ * _loc15_;
            _loc6_.x = _loc12_ * _loc1_;
            _loc6_.setSize(columnWidth,rowHeight);
            _loc14_ = itemToLabel(_loc24_);
            _loc10_ = null;
            if(_iconFunction != null)
            {
               _loc10_ = _iconFunction(_loc24_);
            }
            else if(_iconField != null)
            {
               _loc10_ = _loc24_[_iconField];
            }
            _loc21_ = null;
            if(_sourceFunction != null)
            {
               _loc21_ = _sourceFunction(_loc24_);
            }
            else if(_sourceField != null)
            {
               _loc21_ = _loc24_[_sourceField];
            }
            if(!_loc8_)
            {
               _loc6_.data = _loc24_;
            }
            _loc6_.listData = new TileListData(_loc14_,_loc10_,_loc21_,this,_loc19_,_loc25_ + _loc15_,_loc23_ + _loc1_) as ListData;
            _loc6_.selected = _selectedIndices.indexOf(_loc19_) != -1;
            if(_loc6_ is UIComponent)
            {
               _loc5_ = _loc6_ as UIComponent;
               _loc5_.drawNow();
            }
            _loc18_++;
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(!selectable)
         {
            return;
         }
         switch(int(param1.keyCode) - 33)
         {
            case 0:
            case 1:
            case 2:
            case 3:
               if(_scrollDirection == "horizontal")
               {
                  moveSelectionHorizontally(param1.keyCode,param1.shiftKey && _allowMultipleSelection,param1.ctrlKey && _allowMultipleSelection);
               }
               else
               {
                  moveSelectionVertically(param1.keyCode,param1.shiftKey && _allowMultipleSelection,param1.ctrlKey && _allowMultipleSelection);
               }
               break;
            case 4:
            case 6:
               moveSelectionHorizontally(param1.keyCode,param1.shiftKey && _allowMultipleSelection,param1.ctrlKey && _allowMultipleSelection);
               break;
            case 5:
            case 7:
               moveSelectionVertically(param1.keyCode,param1.shiftKey && _allowMultipleSelection,param1.ctrlKey && _allowMultipleSelection);
               break;
            default:
               _loc2_ = getNextIndexAtLetter(String.fromCharCode(param1.keyCode),selectedIndex);
               if(_loc2_ > -1)
               {
                  selectedIndex = _loc2_;
                  scrollToSelected();
               }
         }
      }
      
      protected function calculateAvailableHeight() : Number
      {
         var _loc1_:Number = Number(getStyleValue("contentPadding"));
         return height - _loc1_ * 2 - (_horizontalScrollPolicy == "on" || _horizontalScrollPolicy == "auto" && _maxHorizontalScrollPosition > 0 ? 15 : 0);
      }
      
      override protected function moveSelectionVertically(param1:uint, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:uint = Math.max(1,Math.max(contentHeight,availableHeight) / _rowHeight << 0);
         var _loc6_:uint = Math.ceil(Math.max(columnCount * rowCount,length) / _loc5_);
         var _loc7_:uint = Math.ceil(length / _loc6_);
         switch(int(param1) - 33)
         {
            case 0:
               _loc8_ = selectedIndex - _loc6_ * (_loc7_ - 1);
               if(_loc8_ < 0)
               {
                  _loc8_ += _loc6_;
               }
               _loc4_ = Math.max(0,_loc8_);
               break;
            case 1:
               _loc8_ = selectedIndex + _loc6_ * (_loc7_ - 1);
               if(_loc8_ >= length)
               {
                  _loc8_ -= _loc6_;
               }
               _loc4_ = Math.min(length - 1,_loc8_);
               break;
            case 2:
               _loc4_ = length - 1;
               break;
            case 3:
               _loc4_ = 0;
               break;
            case 5:
               _loc4_ = selectedIndex - _loc6_;
               break;
            case 7:
               _loc4_ = selectedIndex + _loc6_;
         }
         doKeySelection(_loc4_,param2,param3);
         scrollToSelected();
      }
      
      override protected function moveSelectionHorizontally(param1:uint, param2:Boolean, param3:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:* = undefined;
         var _loc5_:uint = Math.ceil(Math.max(rowCount * columnCount,length) / rowCount);
         switch(int(param1) - 33)
         {
            case 0:
               _loc7_ = selectedIndex - selectedIndex % _loc5_;
               _loc6_ = Math.max(0,Math.max(_loc7_,selectedIndex - columnCount));
               break;
            case 1:
               _loc4_ = selectedIndex - selectedIndex % _loc5_ + _loc5_ - 1;
               _loc6_ = Math.min(length - 1,Math.min(_loc4_,selectedIndex + _loc5_));
               break;
            case 2:
               _loc6_ = length - 1;
               break;
            case 3:
               _loc6_ = 0;
               break;
            case 4:
               _loc6_ = Math.max(0,selectedIndex - 1);
               break;
            case 6:
               _loc6_ = Math.min(length - 1,selectedIndex + 1);
         }
         doKeySelection(_loc6_,param2,param3);
         scrollToSelected();
      }
      
      protected function doKeySelection(param1:uint, param2:Boolean, param3:Boolean) : void
      {
         var _loc6_:* = 0;
         var _loc7_:int = 0;
         var _loc5_:Array = selectedIndices;
         var _loc4_:Boolean = false;
         if(!(param1 < 0 || param1 > length - 1))
         {
            if(param2 && _loc5_.length > 0 && param1 != _loc5_[0])
            {
               _loc6_ = uint(_loc5_[0]);
               _loc5_ = [];
               if(param1 < _loc6_)
               {
                  _loc7_ = _loc6_;
                  while(_loc7_ >= param1)
                  {
                     _loc5_.push(_loc7_);
                     _loc7_--;
                  }
               }
               else
               {
                  _loc7_ = _loc6_;
                  while(_loc7_ <= param1)
                  {
                     _loc5_.push(_loc7_);
                     _loc7_++;
                  }
               }
               _loc4_ = true;
            }
            else
            {
               _loc5_ = [param1];
               caretIndex = param1;
               _loc4_ = true;
            }
         }
         selectedIndices = _loc5_;
         if(_loc4_)
         {
            dispatchEvent(new Event("change"));
         }
         invalidate("data");
      }
      
      override protected function initializeAccessibility() : void
      {
         if(TileList.createAccessibilityImplementation != null)
         {
            TileList.createAccessibilityImplementation(this);
         }
      }
   }
}

