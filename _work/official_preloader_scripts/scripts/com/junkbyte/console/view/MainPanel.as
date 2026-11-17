package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.vos.Log;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import flash.net.FileReference;
   import flash.system.Security;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class MainPanel extends ConsolePanel
   {
      
      public static const NAME:String = "mainPanel";
      
      private static const CL_HISTORY:String = "clhistory";
      
      private static const VIEWING_CH_HISTORY:String = "viewingChannels";
      
      private static const IGNORED_CH_HISTORY:String = "ignoredChannels";
      
      private static const PRIORITY_HISTORY:String = "priority";
      
      private var _traceField:TextField;
      
      private var _cmdPrefx:TextField;
      
      private var _cmdField:TextField;
      
      private var _hintField:TextField;
      
      private var _cmdBG:Shape;
      
      private var _bottomLine:Shape;
      
      private var _mini:Boolean;
      
      private var _shift:Boolean;
      
      private var _ctrl:Boolean;
      
      private var _alt:Boolean;
      
      private var _scroll:Sprite;
      
      private var _scroller:Sprite;
      
      private var _scrolldelay:uint;
      
      private var _scrolldir:int;
      
      private var _scrolling:Boolean;
      
      private var _scrollHeight:Number;
      
      private var _selectionStart:int;
      
      private var _selectionEnd:int;
      
      private var _viewingChannels:Array;
      
      private var _ignoredChannels:Array;
      
      private var _extraMenus:Object = {};
      
      private var _cmdsInd:int = -1;
      
      private var _priority:uint;
      
      private var _filterText:String;
      
      private var _filterRegExp:RegExp;
      
      private var _clScope:String = "";
      
      private var _needUpdateMenu:Boolean;
      
      private var _needUpdateTrace:Boolean;
      
      private var _lockScrollUpdate:Boolean;
      
      private var _atBottom:Boolean = true;
      
      private var _enteringLogin:Boolean;
      
      private var _hint:String;
      
      private var _cmdsHistory:Array;
      
      public function MainPanel(param1:Console)
      {
         super(param1);
         var _loc3_:int = style.menuFontSize;
         console.cl.addCLCmd("filter",setFilterText,"Filter console logs to matching string. When done, click on the * (global channel) at top.",true);
         console.cl.addCLCmd("filterexp",setFilterRegExp,"Filter console logs to matching regular expression",true);
         console.cl.addCLCmd("clearhistory",clearCommandLineHistory,"Clear history of commands you have entered.",true);
         name = "mainPanel";
         minWidth = 50;
         minHeight = 18;
         _traceField = makeTF("traceField");
         _traceField.wordWrap = true;
         _traceField.multiline = true;
         _traceField.y = _loc3_;
         _traceField.addEventListener("scroll",onTraceScroll);
         addChild(_traceField);
         txtField = makeTF("menuField");
         txtField.wordWrap = true;
         txtField.multiline = true;
         txtField.autoSize = "right";
         txtField.height = _loc3_ + 6;
         txtField.y = -2;
         registerTFRoller(txtField,onMenuRollOver);
         addChild(txtField);
         _cmdBG = new Shape();
         _cmdBG.name = "commandBackground";
         _cmdBG.graphics.beginFill(style.commandLineColor,0.1);
         _cmdBG.graphics.drawRoundRect(0,0,100,18,_loc3_,_loc3_);
         _cmdBG.scale9Grid = new Rectangle(9,9,80,1);
         addChild(_cmdBG);
         var _loc2_:TextFormat = new TextFormat(style.menuFont,style.menuFontSize,style.highColor);
         _cmdField = new TextField();
         _cmdField.name = "commandField";
         _cmdField.type = "input";
         _cmdField.x = 40;
         _cmdField.height = _loc3_ + 6;
         _cmdField.addEventListener("keyDown",commandKeyDown);
         _cmdField.addEventListener("keyUp",commandKeyUp);
         _cmdField.addEventListener("focusIn",updateCmdHint);
         _cmdField.addEventListener("focusOut",onCmdFocusOut);
         _cmdField.defaultTextFormat = _loc2_;
         addChild(_cmdField);
         _hintField = makeTF("hintField",true);
         _hintField.mouseEnabled = false;
         _hintField.x = _cmdField.x;
         _hintField.autoSize = "left";
         addChild(_hintField);
         setHints();
         _loc2_.color = style.commandLineColor;
         _cmdPrefx = new TextField();
         _cmdPrefx.name = "commandPrefx";
         _cmdPrefx.type = "dynamic";
         _cmdPrefx.x = 2;
         _cmdPrefx.height = _loc3_ + 6;
         _cmdPrefx.selectable = false;
         _cmdPrefx.defaultTextFormat = _loc2_;
         _cmdPrefx.addEventListener("mouseDown",onCmdPrefMouseDown);
         _cmdPrefx.addEventListener("mouseMove",onCmdPrefRollOverOut);
         _cmdPrefx.addEventListener("rollOut",onCmdPrefRollOverOut);
         addChild(_cmdPrefx);
         _bottomLine = new Shape();
         _bottomLine.name = "blinkLine";
         _bottomLine.alpha = 0.2;
         addChild(_bottomLine);
         _scroll = new Sprite();
         _scroll.name = "scroller";
         _scroll.tabEnabled = false;
         _scroll.y = _loc3_ + 4;
         _scroll.buttonMode = true;
         _scroll.addEventListener("mouseDown",onScrollbarDown,false,0,true);
         _scroller = new Sprite();
         _scroller.name = "scrollbar";
         _scroller.tabEnabled = false;
         _scroller.y = style.controlSize;
         _scroller.graphics.beginFill(style.controlColor,1);
         _scroller.graphics.drawRect(-style.controlSize,0,style.controlSize,30);
         _scroller.graphics.beginFill(0,0);
         _scroller.graphics.drawRect(-style.controlSize * 2,0,style.controlSize * 2,30);
         _scroller.graphics.endFill();
         _scroller.addEventListener("mouseDown",onScrollerDown,false,0,true);
         _scroll.addChild(_scroller);
         addChild(_scroll);
         _cmdField.visible = false;
         _cmdPrefx.visible = false;
         _cmdBG.visible = false;
         updateCLScope("");
         init(640,100,true);
         registerDragger(txtField);
         if(console.so["clhistory"] is Array)
         {
            _cmdsHistory = console.so["clhistory"];
         }
         else
         {
            console.so["clhistory"] = _cmdsHistory = [];
         }
         if(config.rememberFilterSettings && console.so["viewingChannels"] is Array)
         {
            _viewingChannels = console.so["viewingChannels"];
         }
         else
         {
            console.so["viewingChannels"] = _viewingChannels = [];
         }
         if(config.rememberFilterSettings && console.so["ignoredChannels"] is Array)
         {
            _ignoredChannels = console.so["ignoredChannels"];
         }
         if(_viewingChannels.length > 0 || _ignoredChannels == null)
         {
            console.so["ignoredChannels"] = _ignoredChannels = [];
         }
         if(config.rememberFilterSettings && console.so["priority"] is uint)
         {
            _priority = console.so["priority"];
         }
         addEventListener("mouseWheel",onMouseWheel,false,0,true);
         addEventListener("link",linkHandler,false,0,true);
         addEventListener("addedToStage",stageAddedHandle,false,0,true);
         addEventListener("removedFromStage",stageRemovedHandle,false,0,true);
      }
      
      public function addMenu(param1:String, param2:Function, param3:Array, param4:String) : void
      {
         if(param1)
         {
            param1 = param1.replace(/[^\w]*/g,"");
            if(param2 == null)
            {
               delete _extraMenus[param1];
            }
            else
            {
               _extraMenus[param1] = new Array(param2,param3,param4);
            }
            _needUpdateMenu = true;
         }
         else
         {
            console.report("ERROR: Invalid add menu params.",9);
         }
      }
      
      private function stageAddedHandle(param1:Event = null) : void
      {
         stage.addEventListener("mouseDown",onStageMouseDown,true,0,true);
         stage.addEventListener("keyUp",keyUpHandler,false,0,true);
         stage.addEventListener("keyDown",keyDownHandler,false,0,true);
      }
      
      private function stageRemovedHandle(param1:Event = null) : void
      {
         stage.removeEventListener("mouseDown",onStageMouseDown,true);
         stage.removeEventListener("keyUp",keyUpHandler);
         stage.removeEventListener("keyDown",keyDownHandler);
      }
      
      private function onStageMouseDown(param1:MouseEvent) : void
      {
         _shift = param1.shiftKey;
         _ctrl = param1.ctrlKey;
         _alt = param1.altKey;
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(_shift)
         {
            _loc2_ = console.config.style.traceFontSize + (param1.delta > 0 ? 1 : -1);
            if(_loc2_ > 10 && _loc2_ < 20)
            {
               console.config.style.traceFontSize = _loc2_;
               console.config.style.updateStyleSheet();
               updateToBottom();
               param1.stopPropagation();
            }
         }
      }
      
      private function onCmdPrefRollOverOut(param1:MouseEvent) : void
      {
         console.panels.tooltip(param1.type == "mouseMove" ? "Current scope::(CommandLine)" : "",this);
      }
      
      private function onCmdPrefMouseDown(param1:MouseEvent) : void
      {
         try
         {
            stage.focus = _cmdField;
            setCLSelectionAtEnd();
         }
         catch(err:Error)
         {
         }
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 16)
         {
            _shift = true;
         }
         if(param1.keyCode == 17)
         {
            _ctrl = true;
         }
         if(param1.keyCode == 18)
         {
            _alt = true;
         }
      }
      
      private function keyUpHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 16)
         {
            _shift = false;
         }
         else if(param1.keyCode == 17)
         {
            _ctrl = false;
         }
         else if(param1.keyCode == 18)
         {
            _alt = false;
         }
         if((param1.keyCode == 9 || param1.keyCode == 13) && parent.visible && visible && _cmdField.visible)
         {
            try
            {
               stage.focus = _cmdField;
               setCLSelectionAtEnd();
            }
            catch(err:Error)
            {
            }
         }
      }
      
      public function requestLogin(param1:Boolean = true) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         if(param1)
         {
            console.commandLine = true;
            console.report("//",-2);
            console.report("// <b>Enter remoting password</b> in CommandLine below...",-2);
            updateCLScope("Password");
            _loc2_.color = style.controlColor;
            _cmdBG.transform.colorTransform = _loc2_;
            _traceField.transform.colorTransform = new ColorTransform(0.7,0.7,0.7);
         }
         else
         {
            updateCLScope("");
            _cmdBG.transform.colorTransform = _loc2_;
            _traceField.transform.colorTransform = _loc2_;
         }
         _cmdField.displayAsPassword = param1;
         _enteringLogin = param1;
      }
      
      public function update(param1:Boolean) : void
      {
         if(_bottomLine.alpha > 0)
         {
            _bottomLine.alpha -= 0.25;
         }
         if(style.showCommandLineScope)
         {
            if(_clScope != console.cl.scopeString)
            {
               _clScope = console.cl.scopeString;
               updateCLScope(_clScope);
            }
         }
         else if(_clScope != null)
         {
            _clScope = "";
            updateCLScope("");
         }
         if(param1)
         {
            _bottomLine.alpha = 1;
            _needUpdateMenu = true;
            _needUpdateTrace = true;
         }
         if(_needUpdateTrace)
         {
            _needUpdateTrace = false;
            _updateTraces(true);
         }
         if(_needUpdateMenu)
         {
            _needUpdateMenu = false;
            _updateMenu();
         }
      }
      
      public function updateToBottom() : void
      {
         _atBottom = true;
         _needUpdateTrace = true;
      }
      
      private function _updateTraces(param1:Boolean = false) : void
      {
         if(_atBottom)
         {
            updateBottom();
         }
         else if(!param1)
         {
            updateFull();
         }
         if(_selectionStart != _selectionEnd)
         {
            if(_atBottom)
            {
               _traceField.setSelection(_traceField.text.length - _selectionStart,_traceField.text.length - _selectionEnd);
            }
            else
            {
               _traceField.setSelection(_traceField.text.length - _selectionEnd,_traceField.text.length - _selectionStart);
            }
            _selectionEnd = -1;
            _selectionStart = -1;
         }
      }
      
      private function updateFull() : void
      {
         var _loc1_:String = "";
         var _loc3_:Log = console.logs.first;
         var _loc2_:Boolean = _viewingChannels.length != 1;
         var _loc4_:Boolean = _priority == 0 && _viewingChannels.length == 0;
         while(_loc3_)
         {
            if(_loc4_ || lineShouldShow(_loc3_))
            {
               _loc1_ += makeLine(_loc3_,_loc2_);
            }
            _loc3_ = _loc3_.next;
         }
         _lockScrollUpdate = true;
         _traceField.htmlText = "<logs>" + _loc1_ + "</logs>";
         _lockScrollUpdate = false;
         updateScroller();
      }
      
      public function setPaused(param1:Boolean) : void
      {
         if(param1 && _atBottom)
         {
            _atBottom = false;
            _updateTraces();
            _traceField.scrollV = _traceField.maxScrollV;
         }
         else if(!param1)
         {
            _atBottom = true;
            updateBottom();
         }
         updateMenu();
      }
      
      private function updateBottom() : void
      {
         var _loc3_:int = 0;
         var _loc1_:String = "";
         var _loc5_:int = Math.round(_traceField.height / style.traceFontSize);
         var _loc6_:int = Math.round(_traceField.width * 5 / style.traceFontSize);
         var _loc4_:Log = console.logs.last;
         var _loc2_:Boolean = _viewingChannels.length != 1;
         while(_loc4_)
         {
            if(lineShouldShow(_loc4_))
            {
               _loc3_ = Math.ceil(_loc4_.text.length / _loc6_);
               if(!(_loc4_.html || _loc5_ >= _loc3_))
               {
                  _loc4_ = _loc4_.clone();
                  _loc4_.text = _loc4_.text.substring(Math.max(0,_loc4_.text.length - _loc6_ * _loc5_));
                  _loc1_ = makeLine(_loc4_,_loc2_) + _loc1_;
                  break;
               }
               _loc1_ = makeLine(_loc4_,_loc2_) + _loc1_;
               _loc5_ -= _loc3_;
               if(_loc5_ <= 0)
               {
                  break;
               }
            }
            _loc4_ = _loc4_.prev;
         }
         _lockScrollUpdate = true;
         _traceField.htmlText = "<logs>" + _loc1_ + "</logs>";
         _traceField.scrollV = _traceField.maxScrollV;
         _lockScrollUpdate = false;
         updateScroller();
      }
      
      private function lineShouldShow(param1:Log) : Boolean
      {
         return (_priority == 0 || param1.priority >= _priority) && (chShouldShow(param1.ch) || _filterText && _viewingChannels.indexOf("~") >= 0 && param1.text.toLowerCase().indexOf(_filterText) >= 0 || _filterRegExp && _viewingChannels.indexOf("~") >= 0 && param1.text.search(_filterRegExp) >= 0);
      }
      
      private function chShouldShow(param1:String) : Boolean
      {
         return (_viewingChannels.length == 0 || _viewingChannels.indexOf(param1) >= 0) && (_ignoredChannels.length == 0 || _ignoredChannels.indexOf(param1) < 0);
      }
      
      public function get reportChannel() : String
      {
         return _viewingChannels.length == 1 ? _viewingChannels[0] : "C";
      }
      
      public function setViewingChannels(... rest) : void
      {
         var _loc3_:Array = [];
         for each(var _loc2_:Object in rest)
         {
            _loc3_.push(Console.MakeChannelName(_loc2_));
         }
         if(_viewingChannels[0] == "⌂" && (!_loc3_ || _loc3_[0] != _viewingChannels[0]))
         {
            console.refs.exitFocus();
         }
         _ignoredChannels.splice(0);
         _viewingChannels.splice(0);
         if(_loc3_.indexOf(" * ") < 0 && _loc3_.indexOf(null) < 0)
         {
            for each(var _loc4_:String in _loc3_)
            {
               if(_loc4_)
               {
                  _viewingChannels.push(_loc4_);
               }
            }
         }
         updateToBottom();
         console.panels.updateMenu();
      }
      
      public function get viewingChannels() : Array
      {
         return _viewingChannels;
      }
      
      public function setIgnoredChannels(... rest) : void
      {
         var _loc3_:Array = [];
         for each(var _loc2_:Object in rest)
         {
            _loc3_.push(Console.MakeChannelName(_loc2_));
         }
         if(_viewingChannels[0] == "⌂")
         {
            console.refs.exitFocus();
         }
         _ignoredChannels.splice(0);
         _viewingChannels.splice(0);
         if(_loc3_.indexOf(" * ") < 0 && _loc3_.indexOf(null) < 0)
         {
            for each(var _loc4_:String in _loc3_)
            {
               if(_loc4_)
               {
                  _ignoredChannels.push(_loc4_);
               }
            }
         }
         updateToBottom();
         console.panels.updateMenu();
      }
      
      public function get ignoredChannels() : Array
      {
         return _ignoredChannels;
      }
      
      private function setFilterText(param1:String = "") : void
      {
         if(param1)
         {
            _filterRegExp = null;
            _filterText = LogReferences.EscHTML(param1.toLowerCase());
            startFilter();
         }
         else
         {
            endFilter();
         }
      }
      
      private function setFilterRegExp(param1:String = "") : void
      {
         if(param1)
         {
            _filterText = null;
            _filterRegExp = new RegExp(LogReferences.EscHTML(param1),"gi");
            startFilter();
         }
         else
         {
            endFilter();
         }
      }
      
      private function startFilter() : void
      {
         console.clear("~");
         console.logs.addChannel("~");
         setViewingChannels("~");
      }
      
      private function endFilter() : void
      {
         _filterRegExp = null;
         _filterText = null;
         if(_viewingChannels.length == 1 && _viewingChannels[0] == "~")
         {
            setViewingChannels(" * ");
         }
      }
      
      private function makeLine(param1:Log, param2:Boolean) : String
      {
         var _loc4_:String = "<p>";
         if(param2)
         {
            _loc4_ += param1.chStr;
         }
         if(config.showLineNumber)
         {
            _loc4_ += param1.lineStr;
         }
         if(config.showTimestamp)
         {
            _loc4_ += param1.timeStr;
         }
         var _loc3_:String = "p" + param1.priority;
         return _loc4_ + "<" + _loc3_ + ">" + addFilterText(param1.text) + "</" + _loc3_ + "></p>";
      }
      
      private function addFilterText(param1:String) : String
      {
         var _loc2_:Object = null;
         var _loc6_:int = 0;
         var _loc4_:String = null;
         var _loc3_:String = null;
         var _loc5_:int = 0;
         if(_filterRegExp)
         {
            _filterRegExp.lastIndex = 0;
            _loc2_ = _filterRegExp.exec(param1);
            while(_loc2_ != null)
            {
               _loc6_ = int(_loc2_.index);
               _loc4_ = _loc2_[0];
               if(_loc4_.search("<|>") >= 0)
               {
                  _filterRegExp.lastIndex -= _loc4_.length - _loc4_.search("<|>");
               }
               else if(param1.lastIndexOf("<",_loc6_) <= param1.lastIndexOf(">",_loc6_))
               {
                  param1 = param1.substring(0,_loc6_) + "<u>" + param1.substring(_loc6_,_loc6_ + _loc4_.length) + "</u>" + param1.substring(_loc6_ + _loc4_.length);
                  _filterRegExp.lastIndex += 7;
               }
               _loc2_ = _filterRegExp.exec(param1);
            }
         }
         else if(_filterText)
         {
            _loc3_ = param1.toLowerCase();
            _loc5_ = _loc3_.lastIndexOf(_filterText);
            while(_loc5_ >= 0)
            {
               param1 = param1.substring(0,_loc5_) + "<u>" + param1.substring(_loc5_,_loc5_ + _filterText.length) + "</u>" + param1.substring(_loc5_ + _filterText.length);
               _loc5_ = _loc3_.lastIndexOf(_filterText,_loc5_ - 2);
            }
         }
         return param1;
      }
      
      private function onTraceScroll(param1:Event = null) : void
      {
         var _loc2_:int = 0;
         if(_lockScrollUpdate || _shift)
         {
            return;
         }
         var _loc3_:Boolean = _traceField.scrollV >= _traceField.maxScrollV;
         if(!console.paused && _atBottom != _loc3_)
         {
            _loc2_ = _traceField.maxScrollV - _traceField.scrollV;
            _selectionStart = _traceField.text.length - _traceField.selectionBeginIndex;
            _selectionEnd = _traceField.text.length - _traceField.selectionEndIndex;
            _atBottom = _loc3_;
            _updateTraces();
            _traceField.scrollV = _traceField.maxScrollV - _loc2_;
         }
         updateScroller();
      }
      
      private function updateScroller() : void
      {
         if(_traceField.maxScrollV <= 1)
         {
            _scroll.visible = false;
         }
         else
         {
            _scroll.visible = true;
            if(_atBottom)
            {
               scrollPercent = 1;
            }
            else
            {
               scrollPercent = (_traceField.scrollV - 1) / (_traceField.maxScrollV - 1);
            }
         }
      }
      
      private function onScrollbarDown(param1:MouseEvent) : void
      {
         if(_scroller.visible && _scroller.mouseY > 0 || !_scroller.visible && _scroll.mouseY > _scrollHeight / 2)
         {
            _scrolldir = 3;
         }
         else
         {
            _scrolldir = -3;
         }
         _traceField.scrollV += _scrolldir;
         _scrolldelay = 0;
         addEventListener("enterFrame",onScrollBarFrame,false,0,true);
         stage.addEventListener("mouseUp",onScrollBarUp,false,0,true);
      }
      
      private function onScrollBarFrame(param1:Event) : void
      {
         _scrolldelay = _scrolldelay + 1;
         if(_scrolldelay > 10)
         {
            _scrolldelay = 9;
            if(_scrolldir < 0 && _scroller.y > _scroll.mouseY || _scrolldir > 0 && _scroller.y + _scroller.height < _scroll.mouseY)
            {
               _traceField.scrollV += _scrolldir;
            }
         }
      }
      
      private function onScrollBarUp(param1:Event) : void
      {
         removeEventListener("enterFrame",onScrollBarFrame);
         stage.removeEventListener("mouseUp",onScrollBarUp);
      }
      
      private function get scrollPercent() : Number
      {
         return (_scroller.y - style.controlSize) / (_scrollHeight - 30 - style.controlSize * 2);
      }
      
      private function set scrollPercent(param1:Number) : void
      {
         _scroller.y = style.controlSize + (_scrollHeight - 30 - style.controlSize * 2) * param1;
      }
      
      private function onScrollerDown(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         _scrolling = true;
         if(!console.paused && _atBottom)
         {
            _atBottom = false;
            _loc2_ = scrollPercent;
            _updateTraces();
            scrollPercent = _loc2_;
         }
         _scroller.startDrag(false,new Rectangle(0,style.controlSize,0,_scrollHeight - 30 - style.controlSize * 2));
         stage.addEventListener("mouseMove",onScrollerMove,false,0,true);
         stage.addEventListener("mouseUp",onScrollerUp,false,0,true);
         param1.stopPropagation();
      }
      
      private function onScrollerMove(param1:MouseEvent) : void
      {
         _lockScrollUpdate = true;
         _traceField.scrollV = Math.round(scrollPercent * (_traceField.maxScrollV - 1) + 1);
         _lockScrollUpdate = false;
      }
      
      private function onScrollerUp(param1:MouseEvent) : void
      {
         _scroller.stopDrag();
         stage.removeEventListener("mouseMove",onScrollerMove);
         stage.removeEventListener("mouseUp",onScrollerUp);
         _scrolling = false;
         onTraceScroll();
      }
      
      override public function set width(param1:Number) : void
      {
         _lockScrollUpdate = true;
         super.width = param1;
         _traceField.width = param1 - 4;
         txtField.width = param1 - 6;
         _cmdField.width = width - 15 - _cmdField.x;
         _cmdBG.width = param1;
         _bottomLine.graphics.clear();
         _bottomLine.graphics.lineStyle(1,style.controlColor);
         _bottomLine.graphics.moveTo(10,-1);
         _bottomLine.graphics.lineTo(param1 - 10,-1);
         _scroll.x = param1;
         _atBottom = true;
         updateCLSize();
         _needUpdateMenu = true;
         _needUpdateTrace = true;
         _lockScrollUpdate = false;
      }
      
      override public function set height(param1:Number) : void
      {
         _lockScrollUpdate = true;
         var _loc4_:int = style.menuFontSize;
         var _loc5_:Number = _loc4_ + 6 + style.traceFontSize;
         if(height != param1)
         {
            _mini = param1 < (_cmdField.visible ? _loc5_ + _loc4_ + 4 : _loc5_);
         }
         super.height = param1;
         var _loc6_:Boolean = _mini || !style.topMenu;
         updateTraceFHeight();
         _traceField.y = _loc6_ ? 0 : _loc4_;
         _traceField.height = param1 - (_cmdField.visible ? _loc4_ + 4 : 0) - (_loc6_ ? 0 : _loc4_);
         var _loc2_:Number = param1 - (_loc4_ + 6);
         _cmdField.y = _loc2_;
         _cmdPrefx.y = _loc2_;
         _hintField.y = _cmdField.y - _hintField.height;
         _cmdBG.y = _loc2_;
         _bottomLine.y = _cmdField.visible ? _loc2_ : param1;
         _scroll.y = _loc6_ ? 6 : _loc4_ + 4;
         var _loc3_:uint = style.controlSize;
         _scrollHeight = _bottomLine.y - (_cmdField.visible ? 0 : _loc3_ * 2) - _scroll.y;
         _scroller.visible = _scrollHeight > 40;
         _scroll.graphics.clear();
         if(_scrollHeight >= 10)
         {
            _scroll.graphics.beginFill(style.controlColor,0.7);
            _scroll.graphics.drawRect(-_loc3_,0,_loc3_,_loc3_);
            _scroll.graphics.drawRect(-_loc3_,_scrollHeight - _loc3_,_loc3_,_loc3_);
            _scroll.graphics.beginFill(style.controlColor,0.25);
            _scroll.graphics.drawRect(-_loc3_,_loc3_,_loc3_,_scrollHeight - _loc3_ * 2);
            _scroll.graphics.beginFill(0,0);
            _scroll.graphics.drawRect(-_loc3_ * 2,_loc3_ * 2,_loc3_ * 2,_scrollHeight - _loc3_ * 2);
            _scroll.graphics.endFill();
         }
         _atBottom = true;
         _needUpdateTrace = true;
         _lockScrollUpdate = false;
      }
      
      private function updateTraceFHeight() : void
      {
         var _loc1_:Boolean = _mini || !style.topMenu;
         _traceField.y = _loc1_ ? 0 : txtField.y + txtField.height - 6;
         _traceField.height = Math.max(0,height - (_cmdField.visible ? style.menuFontSize + 4 : 0) - _traceField.y);
      }
      
      public function updateMenu(param1:Boolean = false) : void
      {
         if(param1)
         {
            _updateMenu();
         }
         else
         {
            _needUpdateMenu = true;
         }
      }
      
      private function _updateMenu() : void
      {
         var _loc2_:Boolean = false;
         var _loc1_:String = "<r><high>";
         if(_mini || !style.topMenu)
         {
            _loc1_ += "<menu><b> <a href=\"event:show\">‹</a>";
         }
         else
         {
            if(!console.panels.channelsPanel)
            {
               _loc1_ += getChannelsLink(true);
            }
            _loc1_ += "<menu> <b>";
            for(var _loc3_:String in _extraMenus)
            {
               _loc1_ += "<a href=\"event:external_" + _loc3_ + "\">" + _loc3_ + "</a> ";
               _loc2_ = true;
            }
            if(_loc2_)
            {
               _loc1_ += "¦ ";
            }
            _loc1_ += doActive("<a href=\"event:fps\">F</a>",console.fpsMonitor > 0);
            _loc1_ += doActive(" <a href=\"event:mm\">M</a>",console.memoryMonitor > 0);
            _loc1_ += doActive(" <a href=\"event:command\">CL</a>",commandLine);
            if(console.remoter.remoting != 2)
            {
               if(config.displayRollerEnabled)
               {
                  _loc1_ += doActive(" <a href=\"event:roller\">Ro</a>",console.displayRoller);
               }
               if(config.rulerToolEnabled)
               {
                  _loc1_ += doActive(" <a href=\"event:ruler\">RL</a>",console.panels.rulerActive);
               }
            }
            _loc1_ += " ¦</b>";
            _loc1_ += " <a href=\"event:copy\">Sv</a>";
            _loc1_ += " <a href=\"event:priority\">P" + _priority + "</a>";
            _loc1_ += doActive(" <a href=\"event:pause\">P</a>",console.paused);
            _loc1_ += " <a href=\"event:clear\">C</a> <a href=\"event:close\">X</a> <a href=\"event:hide\">›</a>";
         }
         _loc1_ += " </b></menu></high></r>";
         txtField.htmlText = _loc1_;
         txtField.scrollH = txtField.maxScrollH;
         updateTraceFHeight();
      }
      
      public function getChannelsLink(param1:Boolean = false) : String
      {
         var _loc8_:int = 0;
         var _loc7_:String = null;
         var _loc5_:String = null;
         var _loc2_:String = "<chs>";
         var _loc4_:Array = console.logs.getChannels();
         var _loc6_:int = int(_loc4_.length);
         if(param1 && _loc6_ > style.maxChannelsInMenu)
         {
            _loc6_ = style.maxChannelsInMenu;
         }
         var _loc3_:Boolean = _viewingChannels.length > 0 || _ignoredChannels.length > 0;
         _loc8_ = 0;
         while(_loc8_ < _loc6_)
         {
            _loc7_ = _loc4_[_loc8_];
            _loc5_ = !_loc3_ && _loc8_ == 0 || _loc3_ && _loc8_ != 0 && chShouldShow(_loc7_) ? "<ch><b>" + _loc7_ + "</b></ch>" : _loc7_;
            _loc2_ += "<a href=\"event:channel_" + _loc7_ + "\">[" + _loc5_ + "]</a> ";
            _loc8_++;
         }
         if(param1)
         {
            _loc2_ += "<ch><a href=\"event:channels\"><b>" + (_loc4_.length > _loc6_ ? "..." : "") + "</b>^^ </a></ch>";
         }
         return _loc2_ + "</chs> ";
      }
      
      private function doActive(param1:String, param2:Boolean) : String
      {
         if(param2)
         {
            return "<menuHi>" + param1 + "</menuHi>";
         }
         return param1;
      }
      
      public function onMenuRollOver(param1:TextEvent, param2:ConsolePanel = null) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         if(param2 == null)
         {
            param2 = this;
         }
         var _loc5_:String = param1.text ? param1.text.replace("event:","") : "";
         if(_loc5_ == "channel_ * ")
         {
            _loc5_ = "View all channels";
         }
         else if(_loc5_ == "channel_-")
         {
            _loc5_ = "Default channel::Logs with no channel";
         }
         else if(_loc5_ == "channel_C")
         {
            _loc5_ = "Console\'s channel::Logs generated from Console";
         }
         else if(_loc5_ == "channel_~")
         {
            _loc5_ = _filterRegExp ? String(_filterRegExp) : _filterText;
            _loc5_ = "Filtering channel::*" + _loc5_ + "*";
         }
         else if(_loc5_ == "channel_⌂")
         {
            _loc5_ = "Inspecting channel";
         }
         else if(_loc5_.indexOf("channel_") == 0)
         {
            _loc5_ = "Change channel::shift: select multiple\nctrl: ignore channel";
         }
         else if(_loc5_ == "pause")
         {
            if(console.paused)
            {
               _loc5_ = "Resume updates";
            }
            else
            {
               _loc5_ = "Pause updates";
            }
         }
         else if(_loc5_ == "close" && param2 == this)
         {
            _loc5_ = "Close::Type password to show again";
         }
         else if(_loc5_.indexOf("external_") == 0)
         {
            _loc3_ = _extraMenus[_loc5_.substring(9)];
            if(_loc3_)
            {
               _loc5_ = _loc3_[2];
            }
         }
         else
         {
            _loc4_ = {
               "fps":"Frames Per Second",
               "mm":"Memory Monitor",
               "roller":"Display Roller::Map the display list under your mouse",
               "ruler":"Screen Ruler::Measure the distance and angle between two points on screen.",
               "command":"Command Line",
               "copy":"Save to clipboard::shift: no channel name\nctrl: use viewing filters\nalt: save to file",
               "clear":"Clear log",
               "priority":"Priority filter::shift: previous priority\n(skips unused priorites)",
               "channels":"Expand channels",
               "close":"Close"
            };
            _loc5_ = _loc4_[_loc5_];
         }
         console.panels.tooltip(_loc5_,param2);
      }
      
      private function linkHandler(param1:TextEvent) : void
      {
         var _loc3_:String = null;
         var _loc5_:FileReference = null;
         var _loc4_:int = 0;
         var _loc6_:Array = null;
         txtField.setSelection(0,0);
         stopDrag();
         var _loc2_:String = param1.text;
         if(_loc2_ == "pause")
         {
            if(console.paused)
            {
               console.paused = false;
            }
            else
            {
               console.paused = true;
            }
            console.panels.tooltip(null);
         }
         else if(_loc2_ == "hide")
         {
            console.panels.tooltip();
            _mini = true;
            console.config.style.topMenu = false;
            height = height;
            updateMenu();
         }
         else if(_loc2_ == "show")
         {
            console.panels.tooltip();
            _mini = false;
            console.config.style.topMenu = true;
            height = height;
            updateMenu();
         }
         else if(_loc2_ == "close")
         {
            console.panels.tooltip();
            visible = false;
            dispatchEvent(new Event("close"));
         }
         else if(_loc2_ == "channels")
         {
            console.panels.channelsPanel = !console.panels.channelsPanel;
         }
         else if(_loc2_ == "fps")
         {
            console.fpsMonitor = !console.fpsMonitor;
         }
         else if(_loc2_ == "priority")
         {
            incPriority(_shift);
         }
         else if(_loc2_ == "mm")
         {
            console.memoryMonitor = !console.memoryMonitor;
         }
         else if(_loc2_ == "roller")
         {
            console.displayRoller = !console.displayRoller;
         }
         else if(_loc2_ == "ruler")
         {
            console.panels.tooltip();
            console.panels.startRuler();
         }
         else if(_loc2_ == "command")
         {
            commandLine = !commandLine;
         }
         else if(_loc2_ == "copy")
         {
            _loc3_ = console.logs.getLogsAsString("\r\n",!_shift,_ctrl ? lineShouldShow : null);
            if(_alt)
            {
               _loc5_ = new FileReference();
               try
               {
                  _loc5_["save"](_loc3_,"log.txt");
               }
               catch(err:Error)
               {
                  console.report("Save to file is not supported in your flash player.",8);
               }
            }
            else
            {
               System.setClipboard(_loc3_);
               console.report("Copied log to clipboard.",-1);
            }
         }
         else if(_loc2_ == "clear")
         {
            console.clear();
         }
         else if(_loc2_ == "settings")
         {
            console.report("A new window should open in browser. If not, try searching for \'Flash Player Global Security Settings panel\' online :)",-1);
            Security.showSettings("settingsManager");
         }
         else if(_loc2_ == "remote")
         {
            console.remoter.remoting = 2;
         }
         else if(_loc2_.indexOf("ref") == 0)
         {
            console.refs.handleRefEvent(_loc2_);
         }
         else if(_loc2_.indexOf("channel_") == 0)
         {
            onChannelPressed(_loc2_.substring(8));
         }
         else if(_loc2_.indexOf("cl_") == 0)
         {
            _loc4_ = _loc2_.indexOf("_",3);
            console.cl.handleScopeEvent(uint(_loc2_.substring(3,_loc4_ < 0 ? _loc2_.length : _loc4_)));
            if(_loc4_ >= 0)
            {
               _cmdField.text = _loc2_.substring(_loc4_ + 1);
            }
         }
         else if(_loc2_.indexOf("external_") == 0)
         {
            _loc6_ = _extraMenus[_loc2_.substring(9)];
            if(_loc6_)
            {
               _loc6_[0].apply(null,_loc6_[1]);
            }
         }
         txtField.setSelection(0,0);
         param1.stopPropagation();
      }
      
      public function onChannelPressed(param1:String) : void
      {
         var _loc2_:Array = null;
         if(_ctrl && param1 != " * ")
         {
            _loc2_ = toggleCHList(_ignoredChannels,param1);
            setIgnoredChannels.apply(this,_loc2_);
         }
         else if(_shift && param1 != " * " && _viewingChannels[0] != "⌂")
         {
            _loc2_ = toggleCHList(_viewingChannels,param1);
            setViewingChannels.apply(this,_loc2_);
         }
         else
         {
            console.setViewingChannels(param1);
         }
      }
      
      private function toggleCHList(param1:Array, param2:String) : Array
      {
         param1 = param1.concat();
         var _loc3_:int = param1.indexOf(param2);
         if(_loc3_ >= 0)
         {
            param1.splice(_loc3_,1);
            if(param1.length == 0)
            {
               param1.push(" * ");
            }
         }
         else
         {
            param1.push(param2);
         }
         return param1;
      }
      
      public function set priority(param1:uint) : void
      {
         _priority = param1;
         console.so["priority"] = _priority;
         updateToBottom();
         updateMenu();
      }
      
      public function get priority() : uint
      {
         return _priority;
      }
      
      private function incPriority(param1:Boolean) : void
      {
         var _loc3_:* = 0;
         var _loc6_:uint = 10;
         var _loc4_:Log = console.logs.last;
         var _loc2_:int = int(_priority);
         _priority = 0;
         var _loc5_:uint = 32000;
         while(_loc4_ && _loc5_ > 0)
         {
            _loc5_--;
            if(lineShouldShow(_loc4_))
            {
               if(_loc4_.priority > _loc2_ && _loc6_ > _loc4_.priority)
               {
                  _loc6_ = uint(_loc4_.priority);
               }
               if(_loc4_.priority < _loc2_ && _loc3_ < _loc4_.priority)
               {
                  _loc3_ = uint(_loc4_.priority);
               }
            }
            _loc4_ = _loc4_.prev;
         }
         if(param1)
         {
            if(_loc3_ == _loc2_)
            {
               _loc2_ = 10;
            }
            else
            {
               _loc2_ = _loc3_;
            }
         }
         else if(_loc6_ == _loc2_)
         {
            _loc2_ = 0;
         }
         else
         {
            _loc2_ = int(_loc6_);
         }
         priority = _loc2_;
      }
      
      private function clearCommandLineHistory(... rest) : void
      {
         _cmdsInd = -1;
         console.updateSO();
         _cmdsHistory = [];
      }
      
      private function commandKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 9)
         {
            if(_hint)
            {
               _cmdField.text = _hint;
               setCLSelectionAtEnd();
               setHints();
            }
         }
      }
      
      private function commandKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(param1.keyCode == 13)
         {
            updateToBottom();
            setHints();
            if(_enteringLogin)
            {
               console.remoter.login(_cmdField.text);
               _cmdField.text = "";
               requestLogin(false);
            }
            else
            {
               _loc2_ = _cmdField.text;
               if(_loc2_.length > 2)
               {
                  _loc3_ = _cmdsHistory.indexOf(_loc2_);
                  while(_loc3_ >= 0)
                  {
                     _cmdsHistory.splice(_loc3_,1);
                     _loc3_ = _cmdsHistory.indexOf(_loc2_);
                  }
                  _cmdsHistory.unshift(_loc2_);
                  _cmdsInd = -1;
                  if(_cmdsHistory.length > 20)
                  {
                     _cmdsHistory.splice(20);
                  }
                  console.updateSO("clhistory");
               }
               _cmdField.text = "";
               if(config.commandLineInputPassThrough != null)
               {
                  _loc2_ = config.commandLineInputPassThrough(_loc2_);
               }
               if(_loc2_)
               {
                  console.cl.run(_loc2_);
               }
            }
         }
         else if(param1.keyCode == 27)
         {
            if(stage)
            {
               stage.focus = null;
            }
         }
         else if(param1.keyCode == 38)
         {
            setHints();
            if(_cmdField.text && _cmdsInd < 0)
            {
               _cmdsHistory.unshift(_cmdField.text);
               _cmdsInd = _cmdsInd + 1;
            }
            if(_cmdsInd < _cmdsHistory.length - 1)
            {
               _cmdsInd = _cmdsInd + 1;
               _cmdField.text = _cmdsHistory[_cmdsInd];
               setCLSelectionAtEnd();
            }
            else
            {
               _cmdsInd = _cmdsHistory.length;
               _cmdField.text = "";
            }
         }
         else if(param1.keyCode == 40)
         {
            setHints();
            if(_cmdsInd > 0)
            {
               _cmdsInd = _cmdsInd - 1;
               _cmdField.text = _cmdsHistory[_cmdsInd];
               setCLSelectionAtEnd();
            }
            else
            {
               _cmdsInd = -1;
               _cmdField.text = "";
            }
         }
         else if(param1.keyCode == 9)
         {
            setCLSelectionAtEnd();
         }
         else if(!_enteringLogin)
         {
            updateCmdHint();
         }
      }
      
      private function setCLSelectionAtEnd() : void
      {
         _cmdField.setSelection(_cmdField.text.length,_cmdField.text.length);
      }
      
      private function updateCmdHint(param1:Event = null) : void
      {
         var _loc2_:String = _cmdField.text;
         if(_loc2_ && config.commandLineAutoCompleteEnabled && console.remoter.remoting != 2)
         {
            try
            {
               setHints(console.cl.getHintsFor(_loc2_,5));
               return;
            }
            catch(err:Error)
            {
            }
         }
         setHints();
      }
      
      private function onCmdFocusOut(param1:Event) : void
      {
         setHints();
      }
      
      private function setHints(param1:Array = null) : void
      {
         var _loc5_:String = null;
         var _loc2_:Boolean = false;
         var _loc7_:int = 0;
         var _loc4_:Array = null;
         var _loc3_:Rectangle = null;
         if(param1 && param1.length)
         {
            _hint = param1[0][0];
            if(param1.length > 1)
            {
               _loc5_ = param1[1][0];
               _loc2_ = false;
               _loc7_ = 0;
               while(_loc7_ < _loc5_.length)
               {
                  if(_loc5_.charAt(_loc7_) != _hint.charAt(_loc7_))
                  {
                     if(_loc2_ && _cmdField.text.length < _loc7_)
                     {
                        _hint = _hint.substring(0,_loc7_);
                     }
                     break;
                  }
                  _loc2_ = true;
                  _loc7_++;
               }
            }
            _loc4_ = [];
            for each(var _loc6_:Array in param1)
            {
               _loc4_.push("<p3>" + _loc6_[0] + "</p3> <p0>" + (_loc6_[1] ? _loc6_[1] : "") + "</p0>");
            }
            _hintField.htmlText = "<p>" + _loc4_.reverse().join("\n") + "</p>";
            _hintField.visible = true;
            _loc3_ = _cmdField.getCharBoundaries(_cmdField.text.length - 1);
            if(!_loc3_)
            {
               _loc3_ = new Rectangle();
            }
            _hintField.x = _cmdField.x + _loc3_.x + _loc3_.width + 30;
            _hintField.y = height - _hintField.height;
         }
         else
         {
            _hintField.visible = false;
            _hint = null;
         }
      }
      
      public function updateCLScope(param1:String) : void
      {
         if(_enteringLogin)
         {
            _enteringLogin = false;
            requestLogin(false);
         }
         _cmdPrefx.autoSize = "left";
         _cmdPrefx.text = param1;
         updateCLSize();
      }
      
      private function updateCLSize() : void
      {
         var _loc1_:Number = width - 48;
         if(_cmdPrefx.width > 120 || _cmdPrefx.width > _loc1_)
         {
            _cmdPrefx.autoSize = "none";
            _cmdPrefx.width = _loc1_ > 120 ? 120 : _loc1_;
            _cmdPrefx.scrollH = _cmdPrefx.maxScrollH;
         }
         _cmdField.x = _cmdPrefx.width + 2;
         _cmdField.width = width - 15 - _cmdField.x;
         _hintField.x = _cmdField.x;
      }
      
      public function set commandLine(param1:Boolean) : void
      {
         if(param1)
         {
            _cmdField.visible = true;
            _cmdPrefx.visible = true;
            _cmdBG.visible = true;
         }
         else
         {
            _cmdField.visible = false;
            _cmdPrefx.visible = false;
            _cmdBG.visible = false;
         }
         _needUpdateMenu = true;
         this.height = height;
      }
      
      public function get commandLine() : Boolean
      {
         return _cmdField.visible;
      }
   }
}

