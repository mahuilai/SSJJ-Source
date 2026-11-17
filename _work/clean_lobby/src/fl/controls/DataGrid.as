package fl.controls
{
   import fl.controls.dataGridClasses.DataGridColumn;
   import fl.controls.dataGridClasses.HeaderRenderer;
   import fl.controls.listClasses.ICellRenderer;
   import fl.controls.listClasses.ListData;
   import fl.core.UIComponent;
   import fl.data.DataProvider;
   import fl.events.DataChangeEvent;
   import fl.events.DataGridEvent;
   import fl.managers.IFocusManager;
   import fl.managers.IFocusManagerComponent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.Mouse;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   
   public class DataGrid extends SelectableList implements IFocusManagerComponent
   {
      
      public static var createAccessibilityImplementation:Function;
      
      private static var defaultStyles:Object = {
         "headerUpSkin":"HeaderRenderer_upSkin",
         "headerDownSkin":"HeaderRenderer_downSkin",
         "headerOverSkin":"HeaderRenderer_overSkin",
         "headerDisabledSkin":"HeaderRenderer_disabledSkin",
         "headerSortArrowDescSkin":"HeaderSortArrow_descIcon",
         "headerSortArrowAscSkin":"HeaderSortArrow_ascIcon",
         "columnStretchCursorSkin":"ColumnStretch_cursor",
         "columnDividerSkin":null,
         "headerTextFormat":null,
         "headerDisabledTextFormat":null,
         "headerTextPadding":5,
         "headerRenderer":HeaderRenderer,
         "focusRectSkin":null,
         "focusRectPadding":null,
         "skin":"DataGrid_skin"
      };
      
      protected static const HEADER_STYLES:Object = {
         "disabledSkin":"headerDisabledSkin",
         "downSkin":"headerDownSkin",
         "overSkin":"headerOverSkin",
         "upSkin":"headerUpSkin",
         "textFormat":"headerTextFormat",
         "disabledTextFormat":"headerDisabledTextFormat",
         "textPadding":"headerTextPadding"
      };
      
      protected var _rowHeight:Number = 20;
      
      protected var _headerHeight:Number = 25;
      
      protected var _showHeaders:Boolean = true;
      
      protected var _columns:Array;
      
      protected var _minColumnWidth:Number;
      
      protected var header:Sprite;
      
      protected var headerMask:Sprite;
      
      protected var headerSortArrow:Sprite;
      
      protected var _cellRenderer:Object;
      
      protected var _headerRenderer:Object;
      
      protected var _labelFunction:Function;
      
      protected var visibleColumns:Array;
      
      protected var displayableColumns:Array;
      
      protected var columnsInvalid:Boolean = true;
      
      protected var minColumnWidthInvalid:Boolean = false;
      
      protected var activeCellRenderersMap:Dictionary;
      
      protected var availableCellRenderersMap:Dictionary;
      
      protected var dragHandlesMap:Dictionary;
      
      protected var columnStretchIndex:Number = -1;
      
      protected var columnStretchStartX:Number;
      
      protected var columnStretchStartWidth:Number;
      
      protected var columnStretchCursor:Sprite;
      
      protected var _sortIndex:int = -1;
      
      protected var lastSortIndex:int = -1;
      
      protected var _sortDescending:Boolean = false;
      
      protected var _editedItemPosition:Object;
      
      protected var editedItemPositionChanged:Boolean = false;
      
      protected var proposedEditedItemPosition:*;
      
      protected var actualRowIndex:int;
      
      protected var actualColIndex:int;
      
      protected var isPressed:Boolean = false;
      
      protected var losingFocus:Boolean = false;
      
      protected var maxHeaderHeight:Number = 25;
      
      protected var currentHoveredRow:int = -1;
      
      public var editable:Boolean = false;
      
      public var resizableColumns:Boolean = true;
      
      public var sortableColumns:Boolean = true;
      
      public var itemEditorInstance:Object;
      
      public function DataGrid()
      {
         super();
         if(_columns == null)
         {
            _columns = [];
         }
         _horizontalScrollPolicy = "off";
         activeCellRenderersMap = new Dictionary(true);
         availableCellRenderersMap = new Dictionary(true);
         addEventListener("itemEditBeginning",itemEditorItemEditBeginningHandler,false,-50);
         addEventListener("itemEditBegin",itemEditorItemEditBeginHandler,false,-50);
         addEventListener("itemEditEnd",itemEditorItemEditEndHandler,false,-50);
         addEventListener("mouseDown",mouseDownHandler);
         addEventListener("mouseUp",mouseUpHandler);
      }
      
      public static function getStyleDefinition() : Object
      {
         return mergeStyles(defaultStyles,SelectableList.getStyleDefinition(),ScrollBar.getStyleDefinition());
      }
      
      override public function set dataProvider(param1:DataProvider) : void
      {
         super.dataProvider = param1;
         if(_columns == null)
         {
            _columns = [];
         }
         if(_columns.length == 0)
         {
            createColumnsFromDataProvider();
         }
         removeCellRenderers();
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         header.mouseChildren = _enabled;
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         super.setSize(param1,param2);
         columnsInvalid = true;
      }
      
      override public function get horizontalScrollPolicy() : String
      {
         return _horizontalScrollPolicy;
      }
      
      override public function set horizontalScrollPolicy(param1:String) : void
      {
         super.horizontalScrollPolicy = param1;
         columnsInvalid = true;
      }
      
      public function get columns() : Array
      {
         return _columns.slice(0);
      }
      
      public function set columns(param1:Array) : void
      {
         var _loc2_:* = 0;
         removeCellRenderers();
         _columns = [];
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            addColumn(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      public function get minColumnWidth() : Number
      {
         return _minColumnWidth;
      }
      
      public function set minColumnWidth(param1:Number) : void
      {
         _minColumnWidth = param1;
         columnsInvalid = true;
         minColumnWidthInvalid = true;
         invalidate("size");
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
      
      override public function get rowCount() : uint
      {
         return Math.ceil(calculateAvailableHeight() / rowHeight);
      }
      
      public function set rowCount(param1:uint) : void
      {
         var _loc2_:Number = Number(getStyleValue("contentPadding"));
         var _loc3_:Number = _horizontalScrollPolicy == "on" || _horizontalScrollPolicy == "auto" && hScrollBar ? 15 : 0;
         height = rowHeight * param1 + 2 * _loc2_ + _loc3_ + (showHeaders ? headerHeight : 0);
      }
      
      public function get rowHeight() : Number
      {
         return _rowHeight;
      }
      
      public function set rowHeight(param1:Number) : void
      {
         _rowHeight = Math.max(0,param1);
         invalidate("size");
      }
      
      public function get headerHeight() : Number
      {
         return _headerHeight;
      }
      
      public function set headerHeight(param1:Number) : void
      {
         maxHeaderHeight = param1;
         _headerHeight = Math.max(0,param1);
         invalidate("size");
      }
      
      public function get showHeaders() : Boolean
      {
         return _showHeaders;
      }
      
      public function set showHeaders(param1:Boolean) : void
      {
         _showHeaders = param1;
         invalidate("size");
      }
      
      public function get sortIndex() : int
      {
         return _sortIndex;
      }
      
      public function get sortDescending() : Boolean
      {
         return _sortDescending;
      }
      
      public function get imeMode() : String
      {
         return _imeMode;
      }
      
      public function set imeMode(param1:String) : void
      {
         _imeMode = param1;
      }
      
      public function get editedItemRenderer() : ICellRenderer
      {
         if(!itemEditorInstance)
         {
            return null;
         }
         return getCellRendererAt(actualRowIndex,actualColIndex);
      }
      
      public function get editedItemPosition() : Object
      {
         if(_editedItemPosition)
         {
            return {
               "rowIndex":_editedItemPosition.rowIndex,
               "columnIndex":_editedItemPosition.columnIndex
            };
         }
         return _editedItemPosition;
      }
      
      public function set editedItemPosition(param1:Object) : void
      {
         var _loc2_:Object = {
            "rowIndex":param1.rowIndex,
            "columnIndex":param1.columnIndex
         };
         setEditedItemPosition(_loc2_);
      }
      
      protected function calculateAvailableHeight() : Number
      {
         var _loc1_:Number = Number(getStyleValue("contentPadding"));
         var _loc2_:Number = _horizontalScrollPolicy == "on" || _horizontalScrollPolicy == "auto" && _maxHorizontalScrollPosition > 0 ? 15 : 0;
         return height - _loc1_ * 2 - _loc2_ - (showHeaders ? headerHeight : 0);
      }
      
      public function addColumn(param1:*) : DataGridColumn
      {
         return addColumnAt(param1,_columns.length);
      }
      
      public function addColumnAt(param1:*, param2:uint) : DataGridColumn
      {
         var _loc4_:DataGridColumn = null;
         var _loc5_:* = 0;
         if(param2 < _columns.length)
         {
            _columns.splice(param2,0,"");
            _loc5_ = uint(param2 + 1);
            while(_loc5_ < _columns.length)
            {
               _loc4_ = _columns[_loc5_] as DataGridColumn;
               _loc4_.colNum = _loc5_;
               _loc5_++;
            }
         }
         var _loc3_:* = param1;
         if(!(_loc3_ is DataGridColumn))
         {
            if(_loc3_ is String)
            {
               _loc3_ = new DataGridColumn(_loc3_);
            }
            else
            {
               _loc3_ = new DataGridColumn();
            }
         }
         _loc4_ = _loc3_ as DataGridColumn;
         _loc4_.owner = this;
         _loc4_.colNum = param2;
         _columns[param2] = _loc4_;
         invalidate("size");
         columnsInvalid = true;
         return _loc4_;
      }
      
      public function removeColumnAt(param1:uint) : DataGridColumn
      {
         var _loc3_:* = 0;
         var _loc2_:DataGridColumn = _columns[param1] as DataGridColumn;
         if(_loc2_ != null)
         {
            removeCellRenderersByColumn(_loc2_);
            _columns.splice(param1,1);
            _loc3_ = param1;
            while(_loc3_ < _columns.length)
            {
               _loc2_ = _columns[_loc3_] as DataGridColumn;
               if(_loc2_)
               {
                  _loc2_.colNum = _loc3_;
               }
               _loc3_++;
            }
            invalidate("size");
            columnsInvalid = true;
         }
         return _loc2_;
      }
      
      public function removeAllColumns() : void
      {
         if(_columns.length > 0)
         {
            removeCellRenderers();
            _columns = [];
            invalidate("size");
            columnsInvalid = true;
         }
      }
      
      public function getColumnAt(param1:uint) : DataGridColumn
      {
         return _columns[param1] as DataGridColumn;
      }
      
      public function getColumnIndex(param1:String) : int
      {
         var _loc3_:* = 0;
         var _loc2_:DataGridColumn = null;
         _loc3_ = 0;
         while(_loc3_ < _columns.length)
         {
            _loc2_ = _columns[_loc3_] as DataGridColumn;
            if(_loc2_.dataField == param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public function getColumnCount() : uint
      {
         return _columns.length;
      }
      
      public function spaceColumnsEqually() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc1_:DataGridColumn = null;
         drawNow();
         if(displayableColumns.length > 0)
         {
            _loc2_ = availableWidth / displayableColumns.length;
            _loc3_ = 0;
            while(_loc3_ < displayableColumns.length)
            {
               _loc1_ = displayableColumns[_loc3_] as DataGridColumn;
               _loc1_.width = _loc2_;
               _loc3_++;
            }
            invalidate("size");
            columnsInvalid = true;
         }
      }
      
      public function editField(param1:uint, param2:String, param3:Object) : void
      {
         var _loc4_:Object = getItemAt(param1);
         _loc4_[param2] = param3;
         replaceItemAt(_loc4_,param1);
      }
      
      override public function itemToCellRenderer(param1:Object) : ICellRenderer
      {
         return null;
      }
      
      override protected function configUI() : void
      {
         useFixedHorizontalScrolling = false;
         super.configUI();
         headerMask = new Sprite();
         var _loc1_:Graphics = headerMask.graphics;
         _loc1_.beginFill(0,0.3);
         _loc1_.drawRect(0,0,100,100);
         _loc1_.endFill();
         headerMask.visible = false;
         addChild(headerMask);
         header = new Sprite();
         addChild(header);
         header.mask = headerMask;
         _horizontalScrollPolicy = "off";
         _verticalScrollPolicy = "auto";
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
            if(_cellRenderer != getStyleValue("cellRenderer") || _headerRenderer != getStyleValue("headerRenderer"))
            {
               _invalidateList();
               _cellRenderer = getStyleValue("cellRenderer");
               _headerRenderer = getStyleValue("headerRenderer");
            }
         }
         if(isInvalid("size"))
         {
            columnsInvalid = true;
         }
         if(isInvalid("size","state") || _loc1_)
         {
            drawLayout();
            drawDisabledOverlay();
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
      
      override protected function drawLayout() : void
      {
         vOffset = showHeaders ? headerHeight : 0;
         super.drawLayout();
         contentScrollRect = listHolder.scrollRect;
         if(showHeaders)
         {
            headerHeight = maxHeaderHeight;
            if(Math.floor(availableHeight - headerHeight) <= 0)
            {
               _headerHeight = availableHeight;
            }
            list.y = headerHeight;
            contentScrollRect = listHolder.scrollRect;
            contentScrollRect.y = contentPadding + headerHeight;
            contentScrollRect.height = availableHeight - headerHeight;
            listHolder.y = contentPadding + headerHeight;
            headerMask.x = contentPadding;
            headerMask.y = contentPadding;
            headerMask.width = availableWidth;
            headerMask.height = headerHeight;
         }
         else
         {
            contentScrollRect.y = contentPadding;
            listHolder.y = 0;
         }
         listHolder.scrollRect = contentScrollRect;
      }
      
      override protected function drawList() : void
      {
         var _loc19_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc22_:* = 0;
         var _loc25_:Object = null;
         var _loc14_:ICellRenderer = null;
         var _loc13_:Array = null;
         var _loc2_:DataGridColumn = null;
         var _loc24_:DataGridColumn = null;
         var _loc23_:Sprite = null;
         var _loc11_:UIComponent = null;
         var _loc26_:* = 0;
         var _loc8_:Object = null;
         var _loc7_:HeaderRenderer = null;
         var _loc1_:Sprite = null;
         var _loc16_:Graphics = null;
         var _loc5_:Object = null;
         var _loc12_:Array = null;
         var _loc10_:Dictionary = null;
         var _loc15_:Boolean = false;
         if(showHeaders)
         {
            header.visible = true;
            header.x = contentPadding - _horizontalScrollPosition;
            header.y = contentPadding;
            listHolder.y = contentPadding + headerHeight;
            _loc19_ = Math.floor(availableHeight - headerHeight);
            _verticalScrollBar.setScrollProperties(_loc19_,0,contentHeight - _loc19_,_verticalScrollBar.pageScrollSize);
         }
         else
         {
            header.visible = false;
            listHolder.y = contentPadding;
         }
         listHolder.x = contentPadding;
         contentScrollRect = listHolder.scrollRect;
         contentScrollRect.x = _horizontalScrollPosition;
         contentScrollRect.y = vOffset + Math.floor(_verticalScrollPosition) % rowHeight;
         listHolder.scrollRect = contentScrollRect;
         listHolder.cacheAsBitmap = useBitmapScrolling;
         var _loc18_:uint = Math.min(Math.max(length - 1,0),Math.floor(_verticalScrollPosition / rowHeight));
         var _loc9_:uint = Math.min(Math.max(length - 1,0),_loc18_ + rowCount + 1);
         var _loc27_:Boolean = list.hitTestPoint(stage.mouseX,stage.mouseY);
         calculateColumnSizes();
         var _loc21_:Dictionary = renderedItems = new Dictionary(true);
         if(length > 0)
         {
            _loc22_ = _loc18_;
            while(_loc22_ <= _loc9_)
            {
               _loc21_[_dataProvider.getItemAt(_loc22_)] = true;
               _loc22_++;
            }
         }
         _loc28_ = 0;
         var _loc6_:DataGridColumn = visibleColumns[0] as DataGridColumn;
         _loc22_ = 0;
         while(_loc22_ < displayableColumns.length)
         {
            _loc24_ = displayableColumns[_loc22_] as DataGridColumn;
            if(_loc24_ == _loc6_)
            {
               break;
            }
            _loc28_ += _loc24_.width;
            _loc22_++;
         }
         while(header.numChildren > 0)
         {
            header.removeChildAt(0);
         }
         dragHandlesMap = new Dictionary(true);
         var _loc20_:Array = [];
         var _loc4_:uint = visibleColumns.length;
         _loc26_ = 0;
         while(_loc26_ < _loc4_)
         {
            _loc2_ = visibleColumns[_loc26_] as DataGridColumn;
            _loc20_.push(_loc2_.colNum);
            if(showHeaders)
            {
               _loc8_ = _loc2_.headerRenderer != null ? _loc2_.headerRenderer : _headerRenderer;
               _loc7_ = getDisplayObjectInstance(_loc8_) as HeaderRenderer;
               if(_loc7_ != null)
               {
                  _loc7_.addEventListener("click",handleHeaderRendererClick,false,0,true);
                  _loc7_.x = _loc28_;
                  _loc7_.y = 0;
                  _loc7_.setSize(_loc2_.width,headerHeight);
                  _loc7_.column = _loc2_.colNum;
                  _loc7_.label = _loc2_.headerText;
                  header.addChildAt(_loc7_,_loc26_);
                  copyStylesToChild(_loc7_,HEADER_STYLES);
                  if(sortIndex == -1 && lastSortIndex == -1 || _loc2_.colNum != sortIndex)
                  {
                     _loc7_.setStyle("icon",null);
                  }
                  else
                  {
                     _loc7_.setStyle("icon",sortDescending ? getStyleValue("headerSortArrowAscSkin") : getStyleValue("headerSortArrowDescSkin"));
                  }
                  if(_loc26_ < _loc4_ - 1 && resizableColumns && _loc2_.resizable)
                  {
                     _loc1_ = new Sprite();
                     _loc16_ = _loc1_.graphics;
                     _loc16_.beginFill(0,0);
                     _loc16_.drawRect(0,0,3,headerHeight);
                     _loc16_.endFill();
                     _loc1_.x = _loc28_ + _loc2_.width - 2;
                     _loc1_.y = 0;
                     _loc1_.alpha = 0;
                     _loc1_.addEventListener("mouseOver",handleHeaderResizeOver,false,0,true);
                     _loc1_.addEventListener("mouseOut",handleHeaderResizeOut,false,0,true);
                     _loc1_.addEventListener("mouseDown",handleHeaderResizeDown,false,0,true);
                     header.addChild(_loc1_);
                     dragHandlesMap[_loc1_] = _loc2_.colNum;
                  }
                  if(_loc26_ == _loc4_ - 1 && _horizontalScrollPosition == 0 && availableWidth > _loc28_ + _loc2_.width)
                  {
                     _loc3_ = Math.floor(availableWidth - _loc28_);
                     _loc7_.setSize(_loc3_,headerHeight);
                  }
                  else
                  {
                     _loc3_ = _loc2_.width;
                  }
                  _loc7_.drawNow();
               }
            }
            _loc5_ = _loc2_.cellRenderer != null ? _loc2_.cellRenderer : _cellRenderer;
            _loc12_ = availableCellRenderersMap[_loc2_];
            _loc13_ = activeCellRenderersMap[_loc2_];
            if(_loc13_ == null)
            {
               activeCellRenderersMap[_loc2_] = _loc13_ = [];
            }
            if(_loc12_ == null)
            {
               availableCellRenderersMap[_loc2_] = _loc12_ = [];
            }
            _loc10_ = new Dictionary(true);
            while(_loc13_.length > 0)
            {
               _loc14_ = _loc13_.pop();
               _loc25_ = _loc14_.data;
               if(_loc21_[_loc25_] == null || invalidItems[_loc25_] == true)
               {
                  _loc12_.push(_loc14_);
               }
               else
               {
                  _loc10_[_loc25_] = _loc14_;
                  invalidItems[_loc25_] = true;
               }
               list.removeChild(_loc14_ as DisplayObject);
            }
            if(length > 0)
            {
               _loc22_ = _loc18_;
               while(_loc22_ <= _loc9_)
               {
                  _loc15_ = false;
                  _loc25_ = _dataProvider.getItemAt(_loc22_);
                  if(_loc10_[_loc25_] != null)
                  {
                     _loc15_ = true;
                     _loc14_ = _loc10_[_loc25_];
                     delete _loc10_[_loc25_];
                  }
                  else if(_loc12_.length > 0)
                  {
                     _loc14_ = _loc12_.pop() as ICellRenderer;
                  }
                  else
                  {
                     _loc14_ = getDisplayObjectInstance(_loc5_) as ICellRenderer;
                     _loc23_ = _loc14_ as Sprite;
                     if(_loc23_ != null)
                     {
                        _loc23_.addEventListener("click",handleCellRendererClick,false,0,true);
                        _loc23_.addEventListener("rollOver",handleCellRendererMouseEvent,false,0,true);
                        _loc23_.addEventListener("rollOut",handleCellRendererMouseEvent,false,0,true);
                        _loc23_.addEventListener("change",handleCellRendererChange,false,0,true);
                        _loc23_.doubleClickEnabled = true;
                        _loc23_.addEventListener("doubleClick",handleCellRendererDoubleClick,false,0,true);
                        if(_loc23_["setStyle"] != null)
                        {
                           for(var _loc17_ in rendererStyles)
                           {
                              _loc23_["setStyle"](_loc17_,rendererStyles[_loc17_]);
                           }
                        }
                     }
                  }
                  list.addChild(_loc14_ as Sprite);
                  _loc13_.push(_loc14_);
                  _loc14_.x = _loc28_;
                  _loc14_.y = rowHeight * (_loc22_ - _loc18_);
                  _loc14_.setSize(_loc26_ == _loc4_ - 1 ? _loc3_ : _loc2_.width,rowHeight);
                  if(!_loc15_)
                  {
                     _loc14_.data = _loc25_;
                  }
                  _loc14_.listData = new ListData(columnItemToLabel(_loc2_.colNum,_loc25_),null,this,_loc22_,_loc22_,_loc2_.colNum);
                  if(_loc27_ && isHovered(_loc14_))
                  {
                     _loc14_.setMouseState("over");
                     currentHoveredRow = _loc22_;
                  }
                  else
                  {
                     _loc14_.setMouseState("up");
                  }
                  _loc14_.selected = _selectedIndices.indexOf(_loc22_) != -1;
                  if(_loc14_ is UIComponent)
                  {
                     _loc11_ = _loc14_ as UIComponent;
                     _loc11_.drawNow();
                  }
                  _loc22_++;
               }
            }
            _loc28_ += _loc2_.width;
            _loc26_++;
         }
         _loc22_ = 0;
         while(_loc22_ < _columns.length)
         {
            if(_loc20_.indexOf(_loc22_) == -1)
            {
               removeCellRenderersByColumn(_columns[_loc22_] as DataGridColumn);
            }
            _loc22_++;
         }
         if(editedItemPositionChanged)
         {
            editedItemPositionChanged = false;
            commitEditedItemPosition(proposedEditedItemPosition);
            proposedEditedItemPosition = undefined;
         }
         invalidItems = new Dictionary(true);
      }
      
      override protected function updateRendererStyles() : void
      {
         var _loc5_:* = 0;
         var _loc1_:Array = [];
         for(var _loc2_ in availableCellRenderersMap)
         {
            _loc1_ = _loc1_.concat(availableCellRenderersMap[_loc2_]);
         }
         for(_loc2_ in activeCellRenderersMap)
         {
            _loc1_ = _loc1_.concat(activeCellRenderersMap[_loc2_]);
         }
         var _loc3_:uint = _loc1_.length;
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            if(_loc1_[_loc5_]["setStyle"] != null)
            {
               for(var _loc4_ in updatedRendererStyles)
               {
                  _loc1_[_loc5_].setStyle(_loc4_,updatedRendererStyles[_loc4_]);
               }
               _loc1_[_loc5_].drawNow();
            }
            _loc5_++;
         }
         updatedRendererStyles = {};
      }
      
      protected function removeCellRenderers() : void
      {
         var _loc1_:* = 0;
         _loc1_ = 0;
         while(_loc1_ < _columns.length)
         {
            removeCellRenderersByColumn(_columns[_loc1_] as DataGridColumn);
            _loc1_++;
         }
      }
      
      protected function removeCellRenderersByColumn(param1:DataGridColumn) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Array = activeCellRenderersMap[param1];
         if(_loc2_ != null)
         {
            while(_loc2_.length > 0)
            {
               list.removeChild(_loc2_.pop() as DisplayObject);
            }
         }
      }
      
      override protected function handleCellRendererMouseEvent(param1:MouseEvent) : void
      {
         var _loc6_:int = 0;
         var _loc5_:String = null;
         var _loc7_:* = 0;
         var _loc2_:DataGridColumn = null;
         var _loc3_:ICellRenderer = null;
         var _loc4_:ICellRenderer = param1.target as ICellRenderer;
         if(_loc4_)
         {
            _loc6_ = int(_loc4_.listData.row);
            if(param1.type == "rollOver")
            {
               _loc5_ = "over";
            }
            else if(param1.type == "rollOut")
            {
               _loc5_ = "up";
            }
            if(_loc5_)
            {
               _loc7_ = 0;
               while(_loc7_ < visibleColumns.length)
               {
                  _loc2_ = visibleColumns[_loc7_] as DataGridColumn;
                  _loc3_ = getCellRendererAt(_loc6_,_loc2_.colNum);
                  if(_loc3_)
                  {
                     _loc3_.setMouseState(_loc5_);
                  }
                  if(_loc6_ != currentHoveredRow)
                  {
                     _loc3_ = getCellRendererAt(currentHoveredRow,_loc2_.colNum);
                     if(_loc3_)
                     {
                        _loc3_.setMouseState("up");
                     }
                  }
                  _loc7_++;
               }
            }
         }
         super.handleCellRendererMouseEvent(param1);
      }
      
      protected function isHovered(param1:ICellRenderer) : Boolean
      {
         var _loc4_:uint = Math.min(Math.max(length - 1,0),Math.floor(_verticalScrollPosition / rowHeight));
         var _loc2_:Number = (param1.listData.row - _loc4_) * rowHeight;
         var _loc3_:Point = list.globalToLocal(new Point(0,stage.mouseY));
         return _loc3_.y > _loc2_ && _loc3_.y < _loc2_ + rowHeight;
      }
      
      override protected function setHorizontalScrollPosition(param1:Number, param2:Boolean = false) : void
      {
         if(param1 == _horizontalScrollPosition)
         {
            return;
         }
         contentScrollRect = listHolder.scrollRect;
         contentScrollRect.x = param1;
         listHolder.scrollRect = contentScrollRect;
         list.x = 0;
         header.x = -param1;
         super.setHorizontalScrollPosition(param1,true);
         invalidate("scroll");
         columnsInvalid = true;
      }
      
      override protected function setVerticalScrollPosition(param1:Number, param2:Boolean = false) : void
      {
         if(itemEditorInstance)
         {
            endEdit("other");
         }
         invalidate("scroll");
         super.setVerticalScrollPosition(param1,true);
      }
      
      public function columnItemToLabel(param1:uint, param2:Object) : String
      {
         var _loc3_:DataGridColumn = _columns[param1] as DataGridColumn;
         if(_loc3_ != null)
         {
            return _loc3_.itemToLabel(param2);
         }
         return " ";
      }
      
      protected function calculateColumnSizes() : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:DataGridColumn = null;
         var _loc8_:int = 0;
         var _loc13_:Number = NaN;
         var _loc7_:DataGridColumn = null;
         var _loc10_:Number = NaN;
         var _loc1_:int = 0;
         var _loc6_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc11_:Number = 0;
         if(_columns.length == 0)
         {
            visibleColumns = [];
            displayableColumns = [];
            return;
         }
         if(columnsInvalid)
         {
            columnsInvalid = false;
            visibleColumns = [];
            if(minColumnWidthInvalid)
            {
               _loc5_ = int(_columns.length);
               _loc9_ = 0;
               while(_loc9_ < _loc5_)
               {
                  _columns[_loc9_].minWidth = minColumnWidth;
                  _loc9_++;
               }
               minColumnWidthInvalid = false;
            }
            displayableColumns = null;
            _loc5_ = int(_columns.length);
            _loc9_ = 0;
            while(_loc9_ < _loc5_)
            {
               if(displayableColumns && _columns[_loc9_].visible)
               {
                  displayableColumns.push(_columns[_loc9_]);
               }
               else if(!displayableColumns && !_columns[_loc9_].visible)
               {
                  displayableColumns = new Array(_loc9_);
                  _loc8_ = 0;
                  while(_loc8_ < _loc9_)
                  {
                     displayableColumns[_loc8_] = _columns[_loc8_];
                     _loc8_++;
                  }
               }
               _loc9_++;
            }
            if(!displayableColumns)
            {
               displayableColumns = _columns;
            }
            if(horizontalScrollPolicy == "off")
            {
               _loc5_ = int(displayableColumns.length);
               _loc9_ = 0;
               while(_loc9_ < _loc5_)
               {
                  visibleColumns.push(displayableColumns[_loc9_]);
                  _loc9_++;
               }
            }
            else
            {
               _loc5_ = int(displayableColumns.length);
               _loc13_ = 0;
               _loc9_ = 0;
               while(_loc9_ < _loc5_)
               {
                  _loc2_ = displayableColumns[_loc9_] as DataGridColumn;
                  if(_loc13_ + _loc2_.width > _horizontalScrollPosition && _loc13_ < _horizontalScrollPosition + availableWidth)
                  {
                     visibleColumns.push(_loc2_);
                  }
                  _loc13_ += _loc2_.width;
                  _loc9_++;
               }
            }
         }
         if(horizontalScrollPolicy == "off")
         {
            _loc1_ = 0;
            _loc6_ = 0;
            _loc5_ = int(visibleColumns.length);
            _loc9_ = 0;
            while(_loc9_ < _loc5_)
            {
               _loc2_ = visibleColumns[_loc9_] as DataGridColumn;
               if(_loc2_.resizable)
               {
                  if(!isNaN(_loc2_.explicitWidth))
                  {
                     _loc6_ += _loc2_.width;
                  }
                  else
                  {
                     _loc1_++;
                     _loc6_ += _loc2_.minWidth;
                  }
               }
               else
               {
                  _loc6_ += _loc2_.width;
               }
               _loc11_ += _loc2_.width;
               _loc9_++;
            }
            _loc14_ = availableWidth;
            if(availableWidth > _loc6_ && _loc1_)
            {
               _loc5_ = int(visibleColumns.length);
               _loc9_ = 0;
               while(_loc9_ < _loc5_)
               {
                  _loc2_ = visibleColumns[_loc9_] as DataGridColumn;
                  if(_loc2_.resizable && isNaN(_loc2_.explicitWidth))
                  {
                     _loc7_ = _loc2_;
                     if(_loc11_ > availableWidth)
                     {
                        _loc12_ = (_loc7_.width - _loc7_.minWidth) / (_loc11_ - _loc6_);
                     }
                     else
                     {
                        _loc12_ = _loc7_.width / _loc11_;
                     }
                     _loc10_ = _loc7_.width - (_loc11_ - availableWidth) * _loc12_;
                     _loc3_ = _loc2_.minWidth;
                     _loc2_.setWidth(Math.max(_loc10_,_loc3_));
                  }
                  _loc14_ -= _loc2_.width;
                  _loc9_++;
               }
               if(_loc14_ && _loc7_)
               {
                  _loc7_.setWidth(_loc7_.width + _loc14_);
               }
            }
            else
            {
               _loc5_ = int(visibleColumns.length);
               _loc9_ = 0;
               while(_loc9_ < _loc5_)
               {
                  _loc7_ = visibleColumns[_loc9_] as DataGridColumn;
                  _loc12_ = _loc7_.width / _loc11_;
                  _loc10_ = availableWidth * _loc12_;
                  _loc7_.setWidth(_loc10_);
                  _loc7_.explicitWidth = NaN;
                  _loc14_ -= _loc10_;
                  _loc9_++;
               }
               if(_loc14_ && _loc7_)
               {
                  _loc7_.setWidth(_loc7_.width + _loc14_);
               }
            }
         }
      }
      
      override protected function calculateContentWidth() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:DataGridColumn = null;
         if(_columns.length == 0)
         {
            contentWidth = 0;
            return;
         }
         if(minColumnWidthInvalid)
         {
            _loc2_ = int(_columns.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc1_ = _columns[_loc3_] as DataGridColumn;
               _loc1_.minWidth = minColumnWidth;
               _loc3_++;
            }
            minColumnWidthInvalid = false;
         }
         if(horizontalScrollPolicy == "off")
         {
            contentWidth = availableWidth;
         }
         else
         {
            contentWidth = 0;
            _loc2_ = int(_columns.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc1_ = _columns[_loc3_] as DataGridColumn;
               if(_loc1_.visible)
               {
                  contentWidth += _loc1_.width;
               }
               _loc3_++;
            }
            if(!isNaN(_horizontalScrollPosition) && _horizontalScrollPosition + availableWidth > contentWidth)
            {
               setHorizontalScrollPosition(contentWidth - availableWidth);
            }
         }
      }
      
      protected function handleHeaderRendererClick(param1:MouseEvent) : void
      {
         var _loc2_:* = 0;
         var _loc6_:DataGridEvent = null;
         if(!_enabled)
         {
            return;
         }
         var _loc4_:HeaderRenderer = param1.currentTarget as HeaderRenderer;
         var _loc5_:uint = _loc4_.column;
         var _loc3_:DataGridColumn = _columns[_loc5_] as DataGridColumn;
         if(sortableColumns && _loc3_.sortable)
         {
            _loc2_ = uint(_sortIndex);
            _sortIndex = _loc5_;
            _loc6_ = new DataGridEvent("headerRelease",false,true,_loc5_,-1,_loc4_,_loc3_ ? _loc3_.dataField : null);
            if(!dispatchEvent(_loc6_) || !_selectable)
            {
               _sortIndex = lastSortIndex;
               return;
            }
            lastSortIndex = _loc2_;
            sortByColumn(_loc5_);
            invalidate("data");
         }
      }
      
      public function resizeColumn(param1:int, param2:Number) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Number = NaN;
         var _loc7_:int = 0;
         var _loc10_:DataGridColumn = null;
         var _loc9_:DataGridColumn = null;
         var _loc12_:int = 0;
         var _loc6_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc11_:Number = NaN;
         if(_columns.length == 0)
         {
            return;
         }
         var _loc8_:DataGridColumn = _columns[param1] as DataGridColumn;
         if(!_loc8_)
         {
            return;
         }
         if(!visibleColumns || visibleColumns.length == 0)
         {
            _loc8_.setWidth(param2);
            return;
         }
         if(param2 < _loc8_.minWidth)
         {
            param2 = _loc8_.minWidth;
         }
         if(_horizontalScrollPolicy == "on" || _horizontalScrollPolicy == "auto")
         {
            _loc8_.setWidth(param2);
            _loc8_.explicitWidth = param2;
         }
         else
         {
            _loc5_ = getVisibleColumnIndex(_loc8_);
            if(_loc5_ != -1)
            {
               _loc4_ = 0;
               _loc7_ = int(visibleColumns.length);
               _loc12_ = _loc5_ + 1;
               while(_loc12_ < _loc7_)
               {
                  _loc10_ = visibleColumns[_loc12_] as DataGridColumn;
                  if(_loc10_ && _loc10_.resizable)
                  {
                     _loc4_ += _loc10_.width;
                  }
                  _loc12_++;
               }
               _loc3_ = _loc8_.width - param2 + _loc4_;
               if(_loc4_)
               {
                  _loc8_.setWidth(param2);
                  _loc8_.explicitWidth = param2;
               }
               _loc11_ = 0;
               _loc12_ = _loc5_ + 1;
               while(_loc12_ < _loc7_)
               {
                  _loc10_ = visibleColumns[_loc12_] as DataGridColumn;
                  if(_loc10_.resizable)
                  {
                     _loc6_ = _loc10_.width * _loc3_ / _loc4_;
                     if(_loc6_ < _loc10_.minWidth)
                     {
                        _loc6_ = _loc10_.minWidth;
                     }
                     _loc10_.setWidth(_loc6_);
                     _loc11_ += _loc10_.width;
                     _loc9_ = _loc10_;
                  }
                  _loc12_++;
               }
               if(_loc11_ > _loc3_)
               {
                  _loc6_ = _loc8_.width - _loc11_ + _loc3_;
                  if(_loc6_ < _loc8_.minWidth)
                  {
                     _loc6_ = _loc8_.minWidth;
                  }
                  _loc8_.setWidth(_loc6_);
               }
               else if(_loc9_)
               {
                  _loc9_.setWidth(_loc9_.width - _loc11_ + _loc3_);
               }
            }
            else
            {
               _loc8_.setWidth(param2);
               _loc8_.explicitWidth = param2;
            }
         }
         columnsInvalid = true;
         invalidate("size");
      }
      
      protected function sortByColumn(param1:int) : void
      {
         var _loc2_:DataGridColumn = columns[param1] as DataGridColumn;
         if(!enabled || !_loc2_ || !_loc2_.sortable)
         {
            return;
         }
         var _loc3_:Boolean = _loc2_.sortDescending;
         var _loc4_:uint = _loc2_.sortOptions;
         if(_loc3_)
         {
            _loc4_ |= 2;
         }
         else
         {
            _loc4_ &= ~2;
         }
         if(_loc2_.sortCompareFunction != null)
         {
            sortItems(_loc2_.sortCompareFunction,_loc4_);
         }
         else
         {
            sortItemsOn(_loc2_.dataField,_loc4_);
         }
         _sortDescending = _loc2_.sortDescending = !_loc3_;
         if(lastSortIndex >= 0 && lastSortIndex != sortIndex)
         {
            _loc2_ = columns[lastSortIndex] as DataGridColumn;
            if(_loc2_ != null)
            {
               _loc2_.sortDescending = false;
            }
         }
      }
      
      protected function createColumnsFromDataProvider() : void
      {
         var _loc1_:Object = null;
         _columns = [];
         if(length > 0)
         {
            _loc1_ = _dataProvider.getItemAt(0);
            for(var _loc2_ in _loc1_)
            {
               addColumn(_loc2_);
            }
         }
      }
      
      protected function getVisibleColumnIndex(param1:DataGridColumn) : int
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < visibleColumns.length)
         {
            if(param1 == visibleColumns[_loc2_])
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      protected function handleHeaderResizeOver(param1:MouseEvent) : void
      {
         if(columnStretchIndex == -1)
         {
            showColumnStretchCursor();
         }
      }
      
      protected function handleHeaderResizeOut(param1:MouseEvent) : void
      {
         if(columnStretchIndex == -1)
         {
            showColumnStretchCursor(false);
         }
      }
      
      protected function handleHeaderResizeDown(param1:MouseEvent) : void
      {
         var _loc2_:Sprite = param1.currentTarget as Sprite;
         var _loc5_:Number = Number(dragHandlesMap[_loc2_]);
         var _loc4_:DataGridColumn = getColumnAt(_loc5_);
         columnStretchIndex = _loc5_;
         columnStretchStartX = param1.stageX;
         columnStretchStartWidth = _loc4_.width;
         var _loc3_:DisplayObjectContainer = focusManager.form;
         _loc3_.addEventListener("mouseMove",handleHeaderResizeMove,false,0,true);
         _loc3_.addEventListener("mouseUp",handleHeaderResizeUp,false,0,true);
      }
      
      protected function handleHeaderResizeMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = param1.stageX - columnStretchStartX;
         var _loc3_:Number = columnStretchStartWidth + _loc2_;
         resizeColumn(columnStretchIndex,_loc3_);
      }
      
      protected function handleHeaderResizeUp(param1:MouseEvent) : void
      {
         var _loc4_:HeaderRenderer = null;
         var _loc7_:* = 0;
         var _loc2_:Sprite = param1.currentTarget as Sprite;
         var _loc5_:DataGridColumn = _columns[columnStretchIndex] as DataGridColumn;
         _loc7_ = 0;
         while(_loc7_ < header.numChildren)
         {
            _loc4_ = header.getChildAt(_loc7_) as HeaderRenderer;
            if(_loc4_ && _loc4_.column == columnStretchIndex)
            {
               break;
            }
            _loc7_++;
         }
         var _loc6_:DataGridEvent = new DataGridEvent("columnStretch",false,true,columnStretchIndex,-1,_loc4_,_loc5_ ? _loc5_.dataField : null);
         dispatchEvent(_loc6_);
         columnStretchIndex = -1;
         showColumnStretchCursor(false);
         var _loc3_:DisplayObjectContainer = focusManager.form;
         _loc3_.removeEventListener("mouseMove",handleHeaderResizeMove,false);
         _loc3_.removeEventListener("mouseUp",handleHeaderResizeUp,false);
      }
      
      protected function showColumnStretchCursor(param1:Boolean = true) : void
      {
         var _loc3_:Point = null;
         if(columnStretchCursor == null)
         {
            columnStretchCursor = getDisplayObjectInstance(getStyleValue("columnStretchCursorSkin")) as Sprite;
            columnStretchCursor.mouseEnabled = false;
         }
         var _loc2_:DisplayObjectContainer = focusManager.form;
         if(param1)
         {
            Mouse.hide();
            _loc2_.addChild(columnStretchCursor);
            _loc2_.addEventListener("mouseMove",positionColumnStretchCursor,false,0,true);
            _loc3_ = _loc2_.globalToLocal(new Point(stage.mouseX,stage.mouseY));
            columnStretchCursor.x = _loc3_.x;
            columnStretchCursor.y = _loc3_.y;
         }
         else
         {
            _loc2_.removeEventListener("mouseMove",positionColumnStretchCursor,false);
            if(_loc2_.contains(columnStretchCursor))
            {
               _loc2_.removeChild(columnStretchCursor);
            }
            Mouse.show();
         }
      }
      
      protected function positionColumnStretchCursor(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObjectContainer = focusManager.form;
         var _loc3_:Point = _loc2_.globalToLocal(new Point(param1.stageX,param1.stageY));
         columnStretchCursor.x = _loc3_.x;
         columnStretchCursor.y = _loc3_.y;
      }
      
      protected function setEditedItemPosition(param1:Object) : void
      {
         editedItemPositionChanged = true;
         proposedEditedItemPosition = param1;
         if(param1 && param1.rowIndex != selectedIndex)
         {
            selectedIndex = param1.rowIndex;
         }
         invalidate("data");
      }
      
      protected function commitEditedItemPosition(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc5_:int = 0;
         if(!enabled || !editable)
         {
            return;
         }
         if(itemEditorInstance && param1 && itemEditorInstance is IFocusManagerComponent && _editedItemPosition.rowIndex == param1.rowIndex && _editedItemPosition.columnIndex == param1.columnIndex)
         {
            IFocusManagerComponent(itemEditorInstance).setFocus();
            return;
         }
         if(itemEditorInstance)
         {
            if(!param1)
            {
               _loc2_ = "other";
            }
            else if(!editedItemPosition || param1.rowIndex == editedItemPosition.rowIndex)
            {
               _loc2_ = "newColumn";
            }
            else
            {
               _loc2_ = "newRow";
            }
            if(!endEdit(_loc2_) && _loc2_ != "other")
            {
               return;
            }
         }
         _editedItemPosition = param1;
         if(!param1)
         {
            return;
         }
         actualRowIndex = param1.rowIndex;
         actualColIndex = param1.columnIndex;
         if(displayableColumns.length != _columns.length)
         {
            _loc5_ = 0;
            while(_loc5_ < displayableColumns.length)
            {
               if(displayableColumns[_loc5_].colNum >= actualColIndex)
               {
                  actualColIndex = displayableColumns[_loc5_].colNum;
                  break;
               }
               _loc5_++;
            }
            if(_loc5_ == displayableColumns.length)
            {
               actualColIndex = 0;
            }
         }
         scrollToPosition(actualRowIndex,actualColIndex);
         var _loc4_:ICellRenderer = getCellRendererAt(actualRowIndex,actualColIndex);
         var _loc3_:DataGridEvent = new DataGridEvent("itemEditBegin",false,true,actualColIndex,actualRowIndex,_loc4_);
         dispatchEvent(_loc3_);
         if(editedItemPositionChanged)
         {
            editedItemPositionChanged = false;
            commitEditedItemPosition(proposedEditedItemPosition);
            proposedEditedItemPosition = undefined;
         }
         if(!itemEditorInstance)
         {
            commitEditedItemPosition(null);
         }
      }
      
      protected function itemEditorItemEditBeginningHandler(param1:DataGridEvent) : void
      {
         if(!param1.isDefaultPrevented())
         {
            setEditedItemPosition({
               "columnIndex":param1.columnIndex,
               "rowIndex":uint(param1.rowIndex)
            });
         }
         else if(!itemEditorInstance)
         {
            _editedItemPosition = null;
            editable = false;
            setFocus();
            editable = true;
         }
      }
      
      protected function itemEditorItemEditBeginHandler(param1:DataGridEvent) : void
      {
         var _loc2_:IFocusManager = null;
         addEventListener("deactivate",deactivateHandler,false,0,true);
         if(!param1.isDefaultPrevented())
         {
            createItemEditor(param1.columnIndex,uint(param1.rowIndex));
            ICellRenderer(itemEditorInstance).listData = ICellRenderer(editedItemRenderer).listData;
            ICellRenderer(itemEditorInstance).data = editedItemRenderer.data;
            itemEditorInstance.imeMode = columns[param1.columnIndex].imeMode == null ? _imeMode : columns[param1.columnIndex].imeMode;
            _loc2_ = focusManager;
            if(itemEditorInstance is IFocusManagerComponent)
            {
               _loc2_.setFocus(InteractiveObject(itemEditorInstance));
            }
            _loc2_.defaultButtonEnabled = false;
            param1 = new DataGridEvent("itemFocusIn",false,false,_editedItemPosition.columnIndex,_editedItemPosition.rowIndex,itemEditorInstance);
            dispatchEvent(param1);
         }
      }
      
      protected function itemEditorItemEditEndHandler(param1:DataGridEvent) : void
      {
         var _loc5_:Boolean = false;
         var _loc2_:Object = null;
         var _loc7_:String = null;
         var _loc6_:Object = null;
         var _loc4_:String = null;
         var _loc3_:IFocusManager = null;
         if(!param1.isDefaultPrevented())
         {
            _loc5_ = false;
            if(itemEditorInstance && param1.reason != "cancelled")
            {
               _loc2_ = itemEditorInstance[_columns[param1.columnIndex].editorDataField];
               _loc7_ = _columns[param1.columnIndex].dataField;
               _loc6_ = param1.itemRenderer.data;
               _loc4_ = "";
               for each(var _loc8_ in describeType(_loc6_).variable)
               {
                  if(_loc7_ == _loc8_.@name.toString())
                  {
                     _loc4_ = _loc8_.@type.toString();
                     break;
                  }
               }
               switch(_loc4_)
               {
                  case "String":
                     if(!(_loc2_ is String))
                     {
                        _loc2_ = _loc2_.toString();
                     }
                     break;
                  case "uint":
                     if(!(_loc2_ is uint))
                     {
                        _loc2_ = uint(_loc2_);
                     }
                     break;
                  case "int":
                     if(!(_loc2_ is int))
                     {
                        _loc2_ = int(_loc2_);
                     }
                     break;
                  case "Number":
                     if(!(_loc2_ is Number))
                     {
                        _loc2_ = Number(_loc2_);
                     }
               }
               if(_loc6_[_loc7_] != _loc2_)
               {
                  _loc5_ = true;
                  _loc6_[_loc7_] = _loc2_;
               }
               param1.itemRenderer.data = _loc6_;
            }
         }
         else if(param1.reason != "other")
         {
            if(itemEditorInstance && _editedItemPosition)
            {
               if(selectedIndex != _editedItemPosition.rowIndex)
               {
                  selectedIndex = _editedItemPosition.rowIndex;
               }
               _loc3_ = focusManager;
               if(itemEditorInstance is IFocusManagerComponent)
               {
                  _loc3_.setFocus(InteractiveObject(itemEditorInstance));
               }
            }
         }
         if(param1.reason == "other" || !param1.isDefaultPrevented())
         {
            destroyItemEditor();
         }
      }
      
      override protected function focusInHandler(param1:FocusEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc2_:DataGridColumn = null;
         if(param1.target != this)
         {
            return;
         }
         if(losingFocus)
         {
            losingFocus = false;
            return;
         }
         setIMEMode(true);
         super.focusInHandler(param1);
         if(editable && !isPressed)
         {
            _loc3_ = editedItemPosition != null;
            if(!_editedItemPosition)
            {
               _editedItemPosition = {
                  "rowIndex":0,
                  "columnIndex":0
               };
               while(_editedItemPosition.columnIndex < _columns.length)
               {
                  _loc2_ = _columns[_editedItemPosition.columnIndex] as DataGridColumn;
                  if(_loc2_.editable && _loc2_.visible)
                  {
                     _loc3_ = true;
                     break;
                  }
                  _editedItemPosition.columnIndex++;
               }
            }
            if(_loc3_)
            {
               setEditedItemPosition(_editedItemPosition);
            }
         }
         if(editable)
         {
            addEventListener("keyFocusChange",keyFocusChangeHandler);
            addEventListener("mouseDown",mouseFocusChangeHandler);
         }
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         setIMEMode(false);
         if(param1.target == this)
         {
            super.focusOutHandler(param1);
         }
         if(param1.relatedObject == this && itemRendererContains(itemEditorInstance,DisplayObject(param1.target)))
         {
            return;
         }
         if(param1.relatedObject == null && itemRendererContains(editedItemRenderer,DisplayObject(param1.target)))
         {
            return;
         }
         if(param1.relatedObject == null && itemRendererContains(itemEditorInstance,DisplayObject(param1.target)))
         {
            return;
         }
         if(itemEditorInstance && (!param1.relatedObject || !itemRendererContains(itemEditorInstance,param1.relatedObject)))
         {
            endEdit("other");
            removeEventListener("keyFocusChange",keyFocusChangeHandler);
            removeEventListener("mouseDown",mouseFocusChangeHandler);
         }
      }
      
      protected function editorMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:ICellRenderer = null;
         var _loc3_:* = 0;
         if(!itemRendererContains(itemEditorInstance,DisplayObject(param1.target)))
         {
            if(param1.target is ICellRenderer && contains(DisplayObject(param1.target)))
            {
               _loc2_ = param1.target as ICellRenderer;
               _loc3_ = _loc2_.listData.row;
               if(_editedItemPosition.rowIndex == _loc3_)
               {
                  endEdit("newColumn");
               }
               else
               {
                  endEdit("newRow");
               }
            }
            else
            {
               endEdit("other");
            }
         }
      }
      
      protected function editorKeyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 27)
         {
            endEdit("cancelled");
         }
         else if(param1.ctrlKey && param1.charCode == 46)
         {
            endEdit("cancelled");
         }
         else if(param1.charCode == 13 && param1.keyCode != 229)
         {
            if(endEdit("newRow"))
            {
               findNextEnterItemRenderer(param1);
            }
         }
      }
      
      protected function findNextItemRenderer(param1:Boolean) : Boolean
      {
         var _loc2_:String = null;
         var _loc7_:DataGridEvent = null;
         if(!_editedItemPosition)
         {
            return false;
         }
         if(proposedEditedItemPosition !== undefined)
         {
            return false;
         }
         var _loc4_:int = int(_editedItemPosition.rowIndex);
         var _loc3_:int = int(_editedItemPosition.columnIndex);
         var _loc8_:Boolean = false;
         var _loc6_:int = param1 ? -1 : 1;
         var _loc5_:int = length - 1;
         while(!_loc8_)
         {
            _loc3_ += _loc6_;
            if(_loc3_ < 0 || _loc3_ >= _columns.length)
            {
               _loc3_ = _loc3_ < 0 ? _columns.length - 1 : 0;
               _loc4_ += _loc6_;
               if(_loc4_ < 0 || _loc4_ > _loc5_)
               {
                  setEditedItemPosition(null);
                  losingFocus = true;
                  setFocus();
                  return false;
               }
            }
            if(_columns[_loc3_].editable && _columns[_loc3_].visible)
            {
               _loc8_ = true;
               if(_loc4_ == _editedItemPosition.rowIndex)
               {
                  _loc2_ = "newColumn";
               }
               else
               {
                  _loc2_ = "newRow";
               }
               if(!itemEditorInstance || endEdit(_loc2_))
               {
                  _loc7_ = new DataGridEvent("itemEditBeginning",false,true,_loc3_,_loc4_);
                  _loc7_.dataField = _columns[_loc3_].dataField;
                  dispatchEvent(_loc7_);
               }
            }
         }
         return _loc8_;
      }
      
      protected function findNextEnterItemRenderer(param1:KeyboardEvent) : void
      {
         if(proposedEditedItemPosition !== undefined)
         {
            return;
         }
         var _loc3_:int = int(_editedItemPosition.rowIndex);
         var _loc2_:int = int(_editedItemPosition.columnIndex);
         var _loc5_:int = _editedItemPosition.rowIndex + (param1.shiftKey ? -1 : 1);
         if(_loc5_ >= 0 && _loc5_ < length)
         {
            _loc3_ = _loc5_;
         }
         var _loc4_:DataGridEvent = new DataGridEvent("itemEditBeginning",false,true,_loc2_,_loc3_);
         _loc4_.dataField = _columns[_loc2_].dataField;
         dispatchEvent(_loc4_);
      }
      
      protected function mouseFocusChangeHandler(param1:MouseEvent) : void
      {
         if(itemEditorInstance && !param1.isDefaultPrevented() && itemRendererContains(itemEditorInstance,DisplayObject(param1.target)))
         {
            param1.preventDefault();
         }
      }
      
      protected function keyFocusChangeHandler(param1:FocusEvent) : void
      {
         if(param1.keyCode == 9 && !param1.isDefaultPrevented() && findNextItemRenderer(param1.shiftKey))
         {
            param1.preventDefault();
         }
      }
      
      private function itemEditorFocusOutHandler(param1:FocusEvent) : void
      {
         if(param1.relatedObject && contains(param1.relatedObject))
         {
            return;
         }
         if(!param1.relatedObject)
         {
            return;
         }
         if(itemEditorInstance)
         {
            endEdit("other");
         }
      }
      
      protected function deactivateHandler(param1:Event) : void
      {
         if(itemEditorInstance)
         {
            endEdit("other");
            losingFocus = true;
            setFocus();
         }
      }
      
      protected function mouseDownHandler(param1:MouseEvent) : void
      {
         if(!enabled || !selectable)
         {
            return;
         }
         isPressed = true;
      }
      
      protected function mouseUpHandler(param1:MouseEvent) : void
      {
         if(!enabled || !selectable)
         {
            return;
         }
         isPressed = false;
      }
      
      override protected function handleCellRendererClick(param1:MouseEvent) : void
      {
         var _loc2_:DataGridColumn = null;
         var _loc3_:DataGridEvent = null;
         super.handleCellRendererClick(param1);
         var _loc4_:ICellRenderer = param1.currentTarget as ICellRenderer;
         if(_loc4_ && _loc4_.data && _loc4_ != itemEditorInstance)
         {
            _loc2_ = _columns[_loc4_.listData.column] as DataGridColumn;
            if(editable && _loc2_ && _loc2_.editable)
            {
               _loc3_ = new DataGridEvent("itemEditBeginning",false,true,_loc4_.listData.column,_loc4_.listData.row,_loc4_,_loc2_.dataField);
               dispatchEvent(_loc3_);
            }
         }
      }
      
      public function createItemEditor(param1:uint, param2:uint) : void
      {
         var _loc6_:int = 0;
         if(displayableColumns.length != _columns.length)
         {
            _loc6_ = 0;
            while(_loc6_ < displayableColumns.length)
            {
               if(displayableColumns[_loc6_].colNum >= param1)
               {
                  param1 = uint(displayableColumns[_loc6_].colNum);
                  break;
               }
               _loc6_++;
            }
            if(_loc6_ == displayableColumns.length)
            {
               param1 = 0;
            }
         }
         var _loc3_:DataGridColumn = _columns[param1] as DataGridColumn;
         var _loc5_:ICellRenderer = getCellRendererAt(param2,param1);
         if(!itemEditorInstance)
         {
            itemEditorInstance = getDisplayObjectInstance(_loc3_.itemEditor);
            itemEditorInstance.tabEnabled = false;
            list.addChild(DisplayObject(itemEditorInstance));
         }
         list.setChildIndex(DisplayObject(itemEditorInstance),list.numChildren - 1);
         var _loc4_:Sprite = _loc5_ as Sprite;
         itemEditorInstance.visible = true;
         itemEditorInstance.move(_loc4_.x,_loc4_.y);
         itemEditorInstance.setSize(_loc3_.width,rowHeight);
         itemEditorInstance.drawNow();
         DisplayObject(itemEditorInstance).addEventListener("focusOut",itemEditorFocusOutHandler);
         _loc4_.visible = false;
         DisplayObject(itemEditorInstance).addEventListener("keyDown",editorKeyDownHandler);
         focusManager.form.addEventListener("mouseDown",editorMouseDownHandler,true,0,true);
      }
      
      public function destroyItemEditor() : void
      {
         var _loc1_:DataGridEvent = null;
         if(itemEditorInstance)
         {
            DisplayObject(itemEditorInstance).removeEventListener("keyDown",editorKeyDownHandler);
            focusManager.form.removeEventListener("mouseDown",editorMouseDownHandler,true);
            _loc1_ = new DataGridEvent("itemFocusOut",false,false,_editedItemPosition.columnIndex,_editedItemPosition.rowIndex,itemEditorInstance);
            dispatchEvent(_loc1_);
            if(itemEditorInstance && itemEditorInstance is UIComponent)
            {
               UIComponent(itemEditorInstance).drawFocus(false);
            }
            list.removeChild(DisplayObject(itemEditorInstance));
            DisplayObject(editedItemRenderer).visible = true;
            itemEditorInstance = null;
         }
      }
      
      protected function endEdit(param1:String) : Boolean
      {
         if(!editedItemRenderer)
         {
            return true;
         }
         var _loc2_:DataGridEvent = new DataGridEvent("itemEditEnd",false,true,editedItemPosition.columnIndex,editedItemPosition.rowIndex,editedItemRenderer,_columns[editedItemPosition.columnIndex].dataField,param1);
         dispatchEvent(_loc2_);
         return !_loc2_.isDefaultPrevented();
      }
      
      public function getCellRendererAt(param1:uint, param2:uint) : ICellRenderer
      {
         var _loc4_:Array = null;
         var _loc6_:* = 0;
         var _loc5_:ICellRenderer = null;
         var _loc3_:DataGridColumn = _columns[param2] as DataGridColumn;
         if(_loc3_ != null)
         {
            _loc4_ = activeCellRenderersMap[_loc3_] as Array;
            if(_loc4_ != null)
            {
               _loc6_ = 0;
               while(_loc6_ < _loc4_.length)
               {
                  _loc5_ = _loc4_[_loc6_] as ICellRenderer;
                  if(_loc5_.listData.row == param1)
                  {
                     return _loc5_;
                  }
                  _loc6_++;
               }
            }
         }
         return null;
      }
      
      protected function itemRendererContains(param1:Object, param2:DisplayObject) : Boolean
      {
         if(!param2 || !param1 || !(param1 is DisplayObjectContainer))
         {
            return false;
         }
         return DisplayObjectContainer(param1).contains(param2);
      }
      
      override protected function handleDataChange(param1:DataChangeEvent) : void
      {
         super.handleDataChange(param1);
         if(_columns == null)
         {
            _columns = [];
         }
         if(_columns.length == 0)
         {
            createColumnsFromDataProvider();
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(!selectable || itemEditorInstance)
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
               scrollToIndex(caretIndex);
               doKeySelection(caretIndex,param1.shiftKey,param1.ctrlKey);
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
      
      override public function scrollToIndex(param1:int) : void
      {
         var _loc2_:Number = NaN;
         drawNow();
         var _loc4_:int = Math.floor((_verticalScrollPosition + availableHeight) / rowHeight) - 1;
         var _loc3_:int = Math.ceil(_verticalScrollPosition / rowHeight);
         if(param1 < _loc3_)
         {
            verticalScrollPosition = param1 * rowHeight;
         }
         else if(param1 >= _loc4_)
         {
            _loc2_ = _horizontalScrollPolicy == "on" || _horizontalScrollPolicy == "auto" && hScrollBar ? 15 : 0;
            verticalScrollPosition = (param1 + 1) * rowHeight - availableHeight + _loc2_ + (showHeaders ? headerHeight : 0);
         }
      }
      
      protected function scrollToPosition(param1:int, param2:int) : void
      {
         var _loc8_:* = 0;
         var _loc5_:DataGridColumn = null;
         var _loc6_:Number = verticalScrollPosition;
         var _loc4_:Number = horizontalScrollPosition;
         scrollToIndex(param1);
         var _loc7_:Number = 0;
         var _loc3_:DataGridColumn = _columns[param2] as DataGridColumn;
         _loc8_ = 0;
         while(_loc8_ < displayableColumns.length)
         {
            _loc5_ = displayableColumns[_loc8_] as DataGridColumn;
            if(_loc5_ == _loc3_)
            {
               break;
            }
            _loc7_ += _loc5_.width;
            _loc8_++;
         }
         if(horizontalScrollPosition > _loc7_)
         {
            horizontalScrollPosition = _loc7_;
         }
         else if(horizontalScrollPosition + availableWidth < _loc7_ + _loc3_.width)
         {
            horizontalScrollPosition = -(availableWidth - (_loc7_ + _loc3_.width));
         }
         if(_loc6_ != verticalScrollPosition || _loc4_ != horizontalScrollPosition)
         {
            drawNow();
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
         else if(param3)
         {
            caretIndex = param1;
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
      
      override protected function initializeAccessibility() : void
      {
         if(DataGrid.createAccessibilityImplementation != null)
         {
            DataGrid.createAccessibilityImplementation(this);
         }
      }
   }
}

