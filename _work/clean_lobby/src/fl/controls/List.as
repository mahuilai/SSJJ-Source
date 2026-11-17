package fl.controls
{
   import fl.controls.listClasses.ICellRenderer;
   import fl.controls.listClasses.ListData;
   import fl.core.UIComponent;
   import fl.managers.IFocusManagerComponent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class List extends SelectableList implements IFocusManagerComponent
   {
      
      public static var createAccessibilityImplementation:Function;
      
      private static var defaultStyles:Object = {
         "focusRectSkin":null,
         "focusRectPadding":null
      };
      
      protected var _rowHeight:Number = 20;
      
      protected var _cellRenderer:Object;
      
      protected var _labelField:String = "label";
      
      protected var _labelFunction:Function;
      
      protected var _iconField:String = "icon";
      
      protected var _iconFunction:Function;
      
      public function List()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return mergeStyles(defaultStyles,SelectableList.getStyleDefinition());
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
      
      override public function get rowCount() : uint
      {
         return Math.ceil(calculateAvailableHeight() / rowHeight);
      }
      
      public function set rowCount(param1:uint) : void
      {
         var _loc2_:Number = Number(getStyleValue("contentPadding"));
         var _loc3_:Number = _horizontalScrollPolicy == "on" || _horizontalScrollPolicy == "auto" && _maxHorizontalScrollPosition > 0 ? 15 : 0;
         height = rowHeight * param1 + 2 * _loc2_ + _loc3_;
      }
      
      public function get rowHeight() : Number
      {
         return _rowHeight;
      }
      
      public function set rowHeight(param1:Number) : void
      {
         _rowHeight = param1;
         invalidate("size");
      }
      
      override public function scrollToIndex(param1:int) : void
      {
         drawNow();
         var _loc3_:uint = Math.floor((_verticalScrollPosition + availableHeight) / rowHeight) - 1;
         var _loc2_:uint = Math.ceil(_verticalScrollPosition / rowHeight);
         if(param1 < _loc2_)
         {
            verticalScrollPosition = param1 * rowHeight;
         }
         else if(param1 > _loc3_)
         {
            verticalScrollPosition = (param1 + 1) * rowHeight - availableHeight;
         }
      }
      
      override protected function configUI() : void
      {
         useFixedHorizontalScrolling = true;
         _horizontalScrollPolicy = "auto";
         _verticalScrollPolicy = "auto";
         super.configUI();
      }
      
      protected function calculateAvailableHeight() : Number
      {
         var _loc1_:Number = Number(getStyleValue("contentPadding"));
         return height - _loc1_ * 2 - (_horizontalScrollPolicy == "on" || _horizontalScrollPolicy == "auto" && _maxHorizontalScrollPosition > 0 ? 15 : 0);
      }
      
      override protected function setHorizontalScrollPosition(param1:Number, param2:Boolean = false) : void
      {
         list.x = -param1;
         super.setHorizontalScrollPosition(param1,true);
      }
      
      override protected function setVerticalScrollPosition(param1:Number, param2:Boolean = false) : void
      {
         invalidate("scroll");
         super.setVerticalScrollPosition(param1,true);
      }
      
      override protected function draw() : void
      {
         var _loc1_:Boolean = contentHeight != rowHeight * length;
         contentHeight = rowHeight * length;
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
         }
         updateChildren();
         validate();
      }
      
      override protected function drawList() : void
      {
         var _loc8_:* = 0;
         var _loc11_:Object = null;
         var _loc12_:ICellRenderer = null;
         var _loc13_:Boolean = false;
         var _loc10_:Sprite = null;
         var _loc4_:String = null;
         var _loc1_:Object = null;
         listHolder.x = listHolder.y = contentPadding;
         var _loc6_:Rectangle = listHolder.scrollRect;
         _loc6_.x = _horizontalScrollPosition;
         _loc6_.y = Math.floor(_verticalScrollPosition) % rowHeight;
         listHolder.scrollRect = _loc6_;
         listHolder.cacheAsBitmap = useBitmapScrolling;
         var _loc2_:uint = Math.floor(_verticalScrollPosition / rowHeight);
         var _loc5_:uint = Math.min(length,_loc2_ + rowCount + 1);
         var _loc7_:Dictionary = renderedItems = new Dictionary(true);
         _loc8_ = _loc2_;
         while(_loc8_ < _loc5_)
         {
            _loc7_[_dataProvider.getItemAt(_loc8_)] = true;
            _loc8_++;
         }
         var _loc9_:Dictionary = new Dictionary(true);
         while(activeCellRenderers.length > 0)
         {
            _loc12_ = activeCellRenderers.pop() as ICellRenderer;
            _loc11_ = _loc12_.data;
            if(_loc7_[_loc11_] == null || invalidItems[_loc11_] == true)
            {
               availableCellRenderers.push(_loc12_);
            }
            else
            {
               _loc9_[_loc11_] = _loc12_;
               invalidItems[_loc11_] = true;
            }
            list.removeChild(_loc12_ as DisplayObject);
         }
         invalidItems = new Dictionary(true);
         _loc8_ = _loc2_;
         while(_loc8_ < _loc5_)
         {
            _loc13_ = false;
            _loc11_ = _dataProvider.getItemAt(_loc8_);
            if(_loc9_[_loc11_] != null)
            {
               _loc13_ = true;
               _loc12_ = _loc9_[_loc11_];
               delete _loc9_[_loc11_];
            }
            else if(availableCellRenderers.length > 0)
            {
               _loc12_ = availableCellRenderers.pop() as ICellRenderer;
            }
            else
            {
               _loc12_ = getDisplayObjectInstance(getStyleValue("cellRenderer")) as ICellRenderer;
               _loc10_ = _loc12_ as Sprite;
               if(_loc10_ != null)
               {
                  _loc10_.addEventListener("click",handleCellRendererClick,false,0,true);
                  _loc10_.addEventListener("rollOver",handleCellRendererMouseEvent,false,0,true);
                  _loc10_.addEventListener("rollOut",handleCellRendererMouseEvent,false,0,true);
                  _loc10_.addEventListener("change",handleCellRendererChange,false,0,true);
                  _loc10_.doubleClickEnabled = true;
                  _loc10_.addEventListener("doubleClick",handleCellRendererDoubleClick,false,0,true);
                  if(_loc10_.hasOwnProperty("setStyle"))
                  {
                     for(var _loc3_ in rendererStyles)
                     {
                        _loc10_["setStyle"](_loc3_,rendererStyles[_loc3_]);
                     }
                  }
               }
            }
            list.addChild(_loc12_ as Sprite);
            activeCellRenderers.push(_loc12_);
            _loc12_.y = rowHeight * (_loc8_ - _loc2_);
            _loc12_.setSize(availableWidth + _maxHorizontalScrollPosition,rowHeight);
            _loc4_ = itemToLabel(_loc11_);
            _loc1_ = null;
            if(_iconFunction != null)
            {
               _loc1_ = _iconFunction(_loc11_);
            }
            else if(_iconField != null)
            {
               _loc1_ = _loc11_[_iconField];
            }
            if(!_loc13_)
            {
               _loc12_.data = _loc11_;
            }
            _loc12_.listData = new ListData(_loc4_,_loc1_,this,_loc8_,_loc8_,0);
            _loc12_.selected = _selectedIndices.indexOf(_loc8_) != -1;
            if(_loc12_ is UIComponent)
            {
               (_loc12_ as UIComponent).drawNow();
            }
            _loc8_++;
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         if(!selectable)
         {
            return;
         }
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               if(caretIndex == -1)
               {
                  caretIndex = 0;
               }
               doKeySelection(caretIndex,param1.shiftKey,param1.ctrlKey);
               scrollToSelected();
               break;
            case 1:
            case 2:
            case 3:
            case 4:
            case 6:
            case 8:
               moveSelectionVertically(param1.keyCode,param1.shiftKey && _allowMultipleSelection,param1.ctrlKey && _allowMultipleSelection);
               break;
            case 5:
            case 7:
               moveSelectionHorizontally(param1.keyCode,param1.shiftKey && _allowMultipleSelection,param1.ctrlKey && _allowMultipleSelection);
               break;
            default:
               _loc2_ = getNextIndexAtLetter(String.fromCharCode(param1.keyCode),selectedIndex);
               if(_loc2_ > -1)
               {
                  selectedIndex = _loc2_;
                  scrollToSelected();
               }
         }
         param1.stopPropagation();
      }
      
      override protected function moveSelectionHorizontally(param1:uint, param2:Boolean, param3:Boolean) : void
      {
      }
      
      override protected function moveSelectionVertically(param1:uint, param2:Boolean, param3:Boolean) : void
      {
         var _loc5_:int = Math.max(Math.floor(calculateAvailableHeight() / rowHeight),1);
         var _loc6_:int = -1;
         var _loc4_:int = 0;
         switch(int(param1) - 33)
         {
            case 0:
               if(caretIndex > 0)
               {
                  _loc6_ = Math.max(caretIndex - _loc5_,0);
               }
               break;
            case 1:
               if(caretIndex < length - 1)
               {
                  _loc6_ = Math.min(caretIndex + _loc5_,length - 1);
               }
               break;
            case 2:
               if(caretIndex < length - 1)
               {
                  _loc6_ = length - 1;
               }
               break;
            case 3:
               if(caretIndex > 0)
               {
                  _loc6_ = 0;
               }
               break;
            case 5:
               if(caretIndex > 0)
               {
                  _loc6_ = caretIndex - 1;
               }
               break;
            case 7:
               if(caretIndex < length - 1)
               {
                  _loc6_ = caretIndex + 1;
               }
         }
         if(_loc6_ >= 0)
         {
            doKeySelection(_loc6_,param2,param3);
            scrollToSelected();
         }
      }
      
      protected function doKeySelection(param1:int, param2:Boolean, param3:Boolean) : void
      {
         var _loc8_:int = 0;
         var _loc6_:Array = null;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:Boolean = false;
         if(param2)
         {
            _loc6_ = [];
            _loc4_ = lastCaretIndex;
            _loc7_ = param1;
            if(_loc4_ == -1)
            {
               _loc4_ = caretIndex != -1 ? caretIndex : param1;
            }
            if(_loc4_ > _loc7_)
            {
               _loc7_ = _loc4_;
               _loc4_ = param1;
            }
            _loc8_ = _loc4_;
            while(_loc8_ <= _loc7_)
            {
               _loc6_.push(_loc8_);
               _loc8_++;
            }
            selectedIndices = _loc6_;
            caretIndex = param1;
            _loc5_ = true;
         }
         else
         {
            selectedIndex = param1;
            caretIndex = lastCaretIndex = param1;
            _loc5_ = true;
         }
         if(_loc5_)
         {
            dispatchEvent(new Event("change"));
         }
         invalidate("data");
      }
      
      override public function itemToLabel(param1:Object) : String
      {
         if(_labelFunction != null)
         {
            return String(_labelFunction(param1));
         }
         return param1[_labelField] != null ? String(param1[_labelField]) : "";
      }
      
      override protected function initializeAccessibility() : void
      {
         if(List.createAccessibilityImplementation != null)
         {
            List.createAccessibilityImplementation(this);
         }
      }
   }
}

