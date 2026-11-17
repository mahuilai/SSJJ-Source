package com.junkbyte.console
{
   import com.junkbyte.console.core.CommandLine;
   import com.junkbyte.console.core.ConsoleTools;
   import com.junkbyte.console.core.Graphing;
   import com.junkbyte.console.core.KeyBinder;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.core.Logs;
   import com.junkbyte.console.core.MemoryMonitor;
   import com.junkbyte.console.core.Remoting;
   import com.junkbyte.console.view.PanelsManager;
   import com.junkbyte.console.view.RollerPanel;
   import com.junkbyte.console.vos.Log;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import flash.system.Capabilities;
   import flash.utils.getTimer;
   
   public class Console extends Sprite
   {
      
      public static const VERSION:Number = 2.6;
      
      public static const VERSION_STAGE:String = "";
      
      public static const BUILD:int = 611;
      
      public static const BUILD_DATE:String = "2012/02/22 00:11";
      
      public static const LOG:uint = 1;
      
      public static const INFO:uint = 3;
      
      public static const DEBUG:uint = 6;
      
      public static const WARN:uint = 8;
      
      public static const ERROR:uint = 9;
      
      public static const FATAL:uint = 10;
      
      public static const GLOBAL_CHANNEL:String = " * ";
      
      public static const DEFAULT_CHANNEL:String = "-";
      
      public static const CONSOLE_CHANNEL:String = "C";
      
      public static const FILTER_CHANNEL:String = "~";
      
      private var _config:ConsoleConfig;
      
      private var _panels:PanelsManager;
      
      private var _cl:CommandLine;
      
      private var _kb:KeyBinder;
      
      private var _refs:LogReferences;
      
      private var _mm:MemoryMonitor;
      
      private var _graphing:Graphing;
      
      private var _remoter:Remoting;
      
      private var _tools:ConsoleTools;
      
      private var _topTries:int = 50;
      
      private var _paused:Boolean;
      
      private var _rollerKey:KeyBind;
      
      private var _logs:Logs;
      
      private var _so:SharedObject;
      
      private var _soData:Object;
      
      public function Console(param1:String = "", param2:ConsoleConfig = null)
      {
         var password:String = param1;
         var config:ConsoleConfig = param2;
         _soData = {};
         super();
         name = "Console";
         if(config == null)
         {
            config = new ConsoleConfig();
         }
         _config = config;
         if(password)
         {
            _config.keystrokePassword = password;
         }
         _remoter = new Remoting(this);
         _logs = new Logs(this);
         _refs = new LogReferences(this);
         _cl = new CommandLine(this);
         _tools = new ConsoleTools(this);
         _graphing = new Graphing(this);
         _mm = new MemoryMonitor(this);
         _kb = new KeyBinder(this);
         cl.addCLCmd("remotingSocket",function(param1:String = ""):void
         {
            var _loc2_:Array = param1.split(/\s+|\:/);
            remotingSocket(_loc2_[0],_loc2_[1]);
         },"Connect to socket remote. /remotingSocket ip port");
         if(_config.sharedObjectName)
         {
            try
            {
               _so = SharedObject.getLocal(_config.sharedObjectName,_config.sharedObjectPath);
               _soData = _so.data;
            }
            catch(e:Error)
            {
            }
         }
         _config.style.updateStyleSheet();
         _panels = new PanelsManager(this);
         if(password)
         {
            visible = false;
         }
         report("<b>Console v2.6</b> build 611. " + Capabilities.playerType + " " + Capabilities.version + ".",-2);
         addEventListener("enterFrame",_onEnterFrame);
         addEventListener("addedToStage",stageAddedHandle);
      }
      
      public static function MakeChannelName(param1:*) : String
      {
         if(param1 is String)
         {
            return param1 as String;
         }
         if(param1)
         {
            return LogReferences.ShortClassName(param1);
         }
         return "-";
      }
      
      private function stageAddedHandle(param1:Event = null) : void
      {
         if(_cl.base == null)
         {
            _cl.base = parent;
         }
         if(loaderInfo)
         {
            listenUncaughtErrors(loaderInfo);
         }
         removeEventListener("addedToStage",stageAddedHandle);
         addEventListener("removedFromStage",stageRemovedHandle);
         stage.addEventListener("mouseLeave",onStageMouseLeave,false,0,true);
         stage.addEventListener("keyDown",_kb.keyDownHandler,false,0,true);
         stage.addEventListener("keyUp",_kb.keyUpHandler,false,0,true);
      }
      
      private function stageRemovedHandle(param1:Event = null) : void
      {
         _cl.base = null;
         removeEventListener("removedFromStage",stageRemovedHandle);
         addEventListener("addedToStage",stageAddedHandle);
         stage.removeEventListener("mouseLeave",onStageMouseLeave);
         stage.removeEventListener("keyDown",_kb.keyDownHandler);
         stage.removeEventListener("keyUp",_kb.keyUpHandler);
      }
      
      private function onStageMouseLeave(param1:Event) : void
      {
         _panels.tooltip(null);
      }
      
      public function listenUncaughtErrors(param1:LoaderInfo) : void
      {
         var _loc2_:IEventDispatcher = null;
         try
         {
            _loc2_ = param1["uncaughtErrorEvents"];
            if(_loc2_)
            {
               _loc2_.addEventListener("uncaughtError",uncaughtErrorHandle,false,0,true);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function uncaughtErrorHandle(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = param1.hasOwnProperty("error") ? param1["error"] : param1;
         if(_loc3_ is Error)
         {
            _loc2_ = _refs.makeString(_loc3_);
         }
         else if(_loc3_ is ErrorEvent)
         {
            _loc2_ = ErrorEvent(_loc3_).text;
         }
         if(!_loc2_)
         {
            _loc2_ = String(_loc3_);
         }
         report(_loc2_,10,false);
      }
      
      public function addGraph(param1:String, param2:Object, param3:String, param4:Number = -1, param5:String = null, param6:Rectangle = null, param7:Boolean = false) : void
      {
         _graphing.add(param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function fixGraphRange(param1:String, param2:Number = NaN, param3:Number = NaN) : void
      {
         _graphing.fixRange(param1,param2,param3);
      }
      
      public function removeGraph(param1:String, param2:Object = null, param3:String = null) : void
      {
         _graphing.remove(param1,param2,param3);
      }
      
      public function bindKey(param1:KeyBind, param2:Function, param3:Array = null) : void
      {
         if(param1)
         {
            _kb.bindKey(param1,param2,param3);
         }
      }
      
      public function addMenu(param1:String, param2:Function, param3:Array = null, param4:String = null) : void
      {
         panels.mainPanel.addMenu(param1,param2,param3,param4);
      }
      
      public function get displayRoller() : Boolean
      {
         return _panels.displayRoller;
      }
      
      public function set displayRoller(param1:Boolean) : void
      {
         _panels.displayRoller = param1;
      }
      
      public function setRollerCaptureKey(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false) : void
      {
         if(_rollerKey)
         {
            bindKey(_rollerKey,null);
            _rollerKey = null;
         }
         if(param1 && param1.length == 1)
         {
            _rollerKey = new KeyBind(param1,param2,param3,param4);
            bindKey(_rollerKey,onRollerCaptureKey);
         }
      }
      
      public function get rollerCaptureKey() : KeyBind
      {
         return _rollerKey;
      }
      
      private function onRollerCaptureKey() : void
      {
         if(displayRoller)
         {
            report("Display Roller Capture:<br/>" + RollerPanel(_panels.getPanel("rollerPanel")).getMapString(true),-1);
         }
      }
      
      public function get fpsMonitor() : Boolean
      {
         return _graphing.fpsMonitor;
      }
      
      public function set fpsMonitor(param1:Boolean) : void
      {
         _graphing.fpsMonitor = param1;
      }
      
      public function get memoryMonitor() : Boolean
      {
         return _graphing.memoryMonitor;
      }
      
      public function set memoryMonitor(param1:Boolean) : void
      {
         _graphing.memoryMonitor = param1;
      }
      
      public function watch(param1:Object, param2:String = null) : String
      {
         return _mm.watch(param1,param2);
      }
      
      public function unwatch(param1:String) : void
      {
         _mm.unwatch(param1);
      }
      
      public function gc() : void
      {
         _mm.gc();
      }
      
      public function store(param1:String, param2:Object, param3:Boolean = false) : void
      {
         _cl.store(param1,param2,param3);
      }
      
      public function map(param1:DisplayObjectContainer, param2:uint = 0) : void
      {
         _tools.map(param1,param2,"-");
      }
      
      public function mapch(param1:*, param2:DisplayObjectContainer, param3:uint = 0) : void
      {
         _tools.map(param2,param3,MakeChannelName(param1));
      }
      
      public function inspect(param1:Object, param2:Boolean = true) : void
      {
         _refs.inspect(param1,param2,"-");
      }
      
      public function inspectch(param1:*, param2:Object, param3:Boolean = true) : void
      {
         _refs.inspect(param2,param3,MakeChannelName(param1));
      }
      
      public function explode(param1:Object, param2:int = 3) : void
      {
         addLine(new Array(_tools.explode(param1,param2)),1,null,false,true);
      }
      
      public function explodech(param1:*, param2:Object, param3:int = 3) : void
      {
         addLine(new Array(_tools.explode(param2,param3)),1,param1,false,true);
      }
      
      public function get paused() : Boolean
      {
         return _paused;
      }
      
      public function set paused(param1:Boolean) : void
      {
         if(_paused == param1)
         {
            return;
         }
         if(param1)
         {
            report("Paused",10);
         }
         else
         {
            report("Resumed",-1);
         }
         _paused = param1;
         _panels.mainPanel.setPaused(param1);
      }
      
      override public function get width() : Number
      {
         return _panels.mainPanel.width;
      }
      
      override public function set width(param1:Number) : void
      {
         _panels.mainPanel.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         _panels.mainPanel.height = param1;
      }
      
      override public function get height() : Number
      {
         return _panels.mainPanel.height;
      }
      
      override public function get x() : Number
      {
         return _panels.mainPanel.x;
      }
      
      override public function set x(param1:Number) : void
      {
         _panels.mainPanel.x = param1;
      }
      
      override public function set y(param1:Number) : void
      {
         _panels.mainPanel.y = param1;
      }
      
      override public function get y() : Number
      {
         return _panels.mainPanel.y;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            _panels.mainPanel.visible = true;
         }
      }
      
      private function _onEnterFrame(param1:Event) : void
      {
         var _loc3_:Array = null;
         var _loc2_:int = getTimer();
         var _loc4_:Boolean = _logs.update(_loc2_);
         _refs.update(_loc2_);
         _mm.update();
         if(remoter.remoting != 2)
         {
            _loc3_ = _graphing.update(stage ? stage.frameRate : 0);
         }
         _remoter.update();
         if(visible && parent)
         {
            if(config.alwaysOnTop && parent.getChildAt(parent.numChildren - 1) != this && _topTries > 0)
            {
               _topTries = _topTries - 1;
               parent.addChild(this);
               report("Moved console on top (alwaysOnTop enabled), " + _topTries + " attempts left.",-1);
            }
            _panels.update(_paused,_loc4_);
            if(_loc3_)
            {
               _panels.updateGraphs(_loc3_);
            }
         }
      }
      
      public function get remoting() : Boolean
      {
         return _remoter.remoting == 1;
      }
      
      public function set remoting(param1:Boolean) : void
      {
         _remoter.remoting = param1 ? 1 : 0;
      }
      
      public function remotingSocket(param1:String, param2:int) : void
      {
         _remoter.remotingSocket(param1,param2);
      }
      
      public function setViewingChannels(... rest) : void
      {
         _panels.mainPanel.setViewingChannels.apply(this,rest);
      }
      
      public function setIgnoredChannels(... rest) : void
      {
         _panels.mainPanel.setIgnoredChannels.apply(this,rest);
      }
      
      public function set minimumPriority(param1:uint) : void
      {
         _panels.mainPanel.priority = param1;
      }
      
      public function report(param1:*, param2:int = 0, param3:Boolean = true, param4:String = null) : void
      {
         if(!param4)
         {
            param4 = _panels.mainPanel.reportChannel;
         }
         addLine([param1],param2,param4,false,param3,0);
      }
      
      public function addLine(param1:Array, param2:int = 0, param3:* = null, param4:Boolean = false, param5:Boolean = false, param6:int = -1) : void
      {
         var _loc9_:int = 0;
         var _loc8_:String = "";
         var _loc7_:int = int(param1.length);
         _loc9_ = 0;
         while(_loc9_ < _loc7_)
         {
            _loc8_ += (_loc9_ ? " " : "") + _refs.makeString(param1[_loc9_],null,param5);
            _loc9_++;
         }
         if(param2 >= _config.autoStackPriority && param6 < 0)
         {
            param6 = _config.defaultStackDepth;
         }
         if(!param5 && param6 > 0)
         {
            _loc8_ += _tools.getStack(param6,param2);
         }
         _logs.add(new Log(_loc8_,MakeChannelName(param3),param2,param4,param5));
      }
      
      public function set commandLine(param1:Boolean) : void
      {
         _panels.mainPanel.commandLine = param1;
      }
      
      public function get commandLine() : Boolean
      {
         return _panels.mainPanel.commandLine;
      }
      
      public function addSlashCommand(param1:String, param2:Function, param3:String = "", param4:Boolean = true, param5:String = ";") : void
      {
         _cl.addSlashCommand(param1,param2,param3,param4,param5);
      }
      
      public function add(param1:*, param2:int = 2, param3:Boolean = false) : void
      {
         addLine([param1],param2,"-",param3);
      }
      
      public function stack(param1:*, param2:int = -1, param3:int = 5) : void
      {
         addLine([param1],param3,"-",false,false,param2 >= 0 ? param2 : _config.defaultStackDepth);
      }
      
      public function stackch(param1:*, param2:*, param3:int = -1, param4:int = 5) : void
      {
         addLine([param2],param4,param1,false,false,param3 >= 0 ? param3 : _config.defaultStackDepth);
      }
      
      public function log(... rest) : void
      {
         addLine(rest,1);
      }
      
      public function info(... rest) : void
      {
         addLine(rest,3);
      }
      
      public function debug(... rest) : void
      {
         addLine(rest,6);
      }
      
      public function warn(... rest) : void
      {
         addLine(rest,8);
      }
      
      public function error(... rest) : void
      {
         addLine(rest,9);
      }
      
      public function fatal(... rest) : void
      {
         addLine(rest,10);
      }
      
      public function ch(param1:*, param2:*, param3:int = 2, param4:Boolean = false) : void
      {
         addLine([param2],param3,param1,param4);
      }
      
      public function logch(param1:*, ... rest) : void
      {
         addLine(rest,1,param1);
      }
      
      public function infoch(param1:*, ... rest) : void
      {
         addLine(rest,3,param1);
      }
      
      public function debugch(param1:*, ... rest) : void
      {
         addLine(rest,6,param1);
      }
      
      public function warnch(param1:*, ... rest) : void
      {
         addLine(rest,8,param1);
      }
      
      public function errorch(param1:*, ... rest) : void
      {
         addLine(rest,9,param1);
      }
      
      public function fatalch(param1:*, ... rest) : void
      {
         addLine(rest,10,param1);
      }
      
      public function addCh(param1:*, param2:Array, param3:int = 2, param4:Boolean = false) : void
      {
         addLine(param2,param3,param1,param4);
      }
      
      public function addHTML(... rest) : void
      {
         addLine(rest,2,"-",false,testHTML(rest));
      }
      
      public function addHTMLch(param1:*, param2:int, ... rest) : void
      {
         addLine(rest,param2,param1,false,testHTML(rest));
      }
      
      private function testHTML(param1:Array) : Boolean
      {
         try
         {
            new XML("<p>" + param1.join("") + "</p>");
         }
         catch(err:Error)
         {
            return false;
         }
         return true;
      }
      
      public function clear(param1:String = null) : void
      {
         _logs.clear(param1);
         if(!_paused)
         {
            _panels.mainPanel.updateToBottom();
         }
         _panels.updateMenu();
      }
      
      public function getAllLog(param1:String = "\r\n") : String
      {
         return _logs.getLogsAsString(param1);
      }
      
      public function get config() : ConsoleConfig
      {
         return _config;
      }
      
      public function get panels() : PanelsManager
      {
         return _panels;
      }
      
      public function get cl() : CommandLine
      {
         return _cl;
      }
      
      public function get remoter() : Remoting
      {
         return _remoter;
      }
      
      public function get graphing() : Graphing
      {
         return _graphing;
      }
      
      public function get refs() : LogReferences
      {
         return _refs;
      }
      
      public function get logs() : Logs
      {
         return _logs;
      }
      
      public function get mapper() : ConsoleTools
      {
         return _tools;
      }
      
      public function get so() : Object
      {
         return _soData;
      }
      
      public function updateSO(param1:String = null) : void
      {
         if(_so)
         {
            if(param1)
            {
               _so.setDirty(param1);
            }
            else
            {
               _so.clear();
            }
         }
      }
   }
}

