package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.WeakObject;
   import com.junkbyte.console.vos.WeakRef;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public class CommandLine extends ConsoleCore
   {
      
      private static const DISABLED:String = "<b>Advanced CommandLine is disabled.</b>\nEnable by setting `Cc.config.commandLineAllowed = true;´\nType <b>/commands</b> for permitted commands.";
      
      private static const RESERVED:Array = ["returned","base","C"];
      
      private var _saved:WeakObject;
      
      private var _scope:*;
      
      private var _prevScope:WeakRef;
      
      private var _scopeStr:String = "";
      
      private var _slashCmds:Object;
      
      public var localCommands:Array = new Array("filter","filterexp");
      
      public function CommandLine(param1:Console)
      {
         var m:Console = param1;
         super(m);
         _saved = new WeakObject();
         _scope = m;
         _slashCmds = {};
         _prevScope = new WeakRef(m);
         _saved.set("C",m);
         remoter.registerCallback("cmd",function(param1:ByteArray):void
         {
            run(param1.readUTF());
         });
         remoter.registerCallback("scope",function(param1:ByteArray):void
         {
            handleScopeEvent(param1.readUnsignedInt());
         });
         remoter.registerCallback("cls",handleScopeString);
         remoter.addEventListener("connect",sendCmdScope2Remote);
         addCLCmd("help",printHelp,"How to use command line");
         addCLCmd("save|store",saveCmd,"Save current scope as weak reference. (same as Cc.store(...))");
         addCLCmd("savestrong|storestrong",saveStrongCmd,"Save current scope as strong reference");
         addCLCmd("saved|stored",savedCmd,"Show a list of all saved references");
         addCLCmd("string",stringCmd,"Create String, useful to paste complex strings without worrying about \" or \'",false,null);
         addCLCmd("commands",cmdsCmd,"Show a list of all slash commands",true);
         addCLCmd("inspect",inspectCmd,"Inspect current scope");
         addCLCmd("explode",explodeCmd,"Explode current scope to its properties and values (similar to JSON)");
         addCLCmd("map",mapCmd,"Get display list map starting from current scope");
         addCLCmd("function",funCmd,"Create function. param is the commandline string to create as function. (experimental)");
         addCLCmd("autoscope",autoscopeCmd,"Toggle autoscoping.");
         addCLCmd("base",baseCmd,"Return to base scope");
         addCLCmd("/",prevCmd,"Return to previous scope");
      }
      
      public function set base(param1:Object) : void
      {
         if(base)
         {
            report("Set new commandLine base from " + base + " to " + param1,10);
         }
         else
         {
            _prevScope.reference = _scope;
            _scope = param1;
            _scopeStr = LogReferences.ShortClassName(param1,false);
         }
         _saved.set("base",param1);
      }
      
      public function get base() : Object
      {
         return _saved.get("base");
      }
      
      public function handleScopeString(param1:ByteArray) : void
      {
         _scopeStr = param1.readUTF();
      }
      
      public function handleScopeEvent(param1:uint) : void
      {
         var _loc3_:ByteArray = null;
         var _loc2_:* = undefined;
         if(remoter.remoting == 2)
         {
            _loc3_ = new ByteArray();
            _loc3_.writeUnsignedInt(param1);
            remoter.send("scope",_loc3_);
         }
         else
         {
            _loc2_ = console.refs.getRefById(param1);
            if(_loc2_)
            {
               console.cl.setReturned(_loc2_,true,false);
            }
            else
            {
               console.report("Reference no longer exist.",-2);
            }
         }
      }
      
      public function store(param1:String, param2:Object, param3:Boolean = false) : void
      {
         if(!param1)
         {
            report("ERROR: Give a name to save.",10);
            return;
         }
         if(param2 is Function)
         {
            param3 = true;
         }
         param1 = param1.replace(/[^\w]*/g,"");
         if(RESERVED.indexOf(param1) >= 0)
         {
            report("ERROR: The name [" + param1 + "] is reserved",10);
            return;
         }
         _saved.set(param1,param2,param3);
      }
      
      public function getHintsFor(param1:String, param2:uint) : Array
      {
         var X:String;
         var cmd:Object;
         var Y:String;
         var hints:Array;
         var canadate:Array;
         var str:String = param1;
         var max:uint = param2;
         var all:Array = [];
         for(X in _slashCmds)
         {
            cmd = _slashCmds[X];
            if(config.commandLineAllowed || cmd.allow)
            {
               all.push(["/" + X + " ",cmd.d ? cmd.d : null]);
            }
         }
         if(config.commandLineAllowed)
         {
            for(Y in _saved)
            {
               all.push(["$" + Y,LogReferences.ShortClassName(_saved.get(Y))]);
            }
            if(_scope)
            {
               all.push(["this",LogReferences.ShortClassName(_scope)]);
               all = all.concat(console.refs.getPossibleCalls(_scope));
            }
         }
         str = str.toLowerCase();
         hints = [];
         for each(canadate in all)
         {
            if(canadate[0].toLowerCase().indexOf(str) == 0)
            {
               hints.push(canadate);
            }
         }
         hints = hints.sort(function(param1:Array, param2:Array):int
         {
            if(param1[0].length < param2[0].length)
            {
               return -1;
            }
            if(param1[0].length > param2[0].length)
            {
               return 1;
            }
            return 0;
         });
         if(max > 0 && hints.length > max)
         {
            hints.splice(max);
            hints.push(["..."]);
         }
         return hints;
      }
      
      public function get scopeString() : String
      {
         return config.commandLineAllowed ? _scopeStr : "";
      }
      
      public function addCLCmd(param1:String, param2:Function, param3:String, param4:Boolean = false, param5:String = ";") : void
      {
         var _loc7_:int = 0;
         var _loc6_:Array = param1.split("|");
         _loc7_ = 0;
         while(_loc7_ < _loc6_.length)
         {
            param1 = _loc6_[_loc7_];
            _slashCmds[param1] = new SlashCommand(param1,param2,param3,false,param4,param5);
            if(_loc7_ > 0)
            {
               _slashCmds.setPropertyIsEnumerable(param1,false);
            }
            _loc7_++;
         }
      }
      
      public function addSlashCommand(param1:String, param2:Function, param3:String = "", param4:Boolean = true, param5:String = ";") : void
      {
         var _loc6_:SlashCommand = null;
         param1 = param1.replace(/[^\w]*/g,"");
         if(_slashCmds[param1] != null)
         {
            _loc6_ = _slashCmds[param1];
            if(!_loc6_.user)
            {
               throw new Error("Can not alter build-in slash command [" + param1 + "]");
            }
         }
         if(param2 == null)
         {
            delete _slashCmds[param1];
         }
         else
         {
            _slashCmds[param1] = new SlashCommand(param1,param2,LogReferences.EscHTML(param3),true,param4,param5);
         }
      }
      
      public function run(param1:String, param2:Object = null) : *
      {
         var _loc4_:ByteArray = null;
         var _loc6_:Executer = null;
         if(!param1)
         {
            return;
         }
         param1 = param1.replace(/\s*/,"");
         if(remoter.remoting == 2)
         {
            if(param1.charAt(0) == "~")
            {
               param1 = param1.substring(1);
            }
            else if(param1.search(new RegExp("/" + localCommands.join("|/"))) != 0)
            {
               report("Run command at remote: " + param1,-2);
               _loc4_ = new ByteArray();
               _loc4_.writeUTF(param1);
               if(!console.remoter.send("cmd",_loc4_))
               {
                  report("Command could not be sent to client.",10);
               }
               return null;
            }
         }
         report("&gt; " + param1,4,false);
         var _loc3_:* = null;
         try
         {
            if(param1.charAt(0) == "/")
            {
               execCommand(param1.substring(1));
            }
            else
            {
               if(!config.commandLineAllowed)
               {
                  report("<b>Advanced CommandLine is disabled.</b>\nEnable by setting `Cc.config.commandLineAllowed = true;´\nType <b>/commands</b> for permitted commands.",9);
                  return null;
               }
               _loc6_ = new Executer();
               _loc6_.addEventListener("complete",onExecLineComplete,false,0,true);
               if(param2)
               {
                  for(var _loc5_:String in _saved)
                  {
                     if(!param2[_loc5_])
                     {
                        param2[_loc5_] = _saved[_loc5_];
                     }
                  }
               }
               else
               {
                  param2 = _saved;
               }
               _loc6_.setStored(param2);
               _loc6_.setReserved(RESERVED);
               _loc6_.autoScope = config.commandLineAutoScope;
               _loc3_ = _loc6_.exec(_scope,param1);
            }
         }
         catch(e:Error)
         {
            reportError(e);
         }
         return _loc3_;
      }
      
      private function onExecLineComplete(param1:Event) : void
      {
         var _loc2_:Executer = param1.currentTarget as Executer;
         if(_scope == _loc2_.scope)
         {
            setReturned(_loc2_.returned);
         }
         else if(_loc2_.scope == _loc2_.returned)
         {
            setReturned(_loc2_.scope,true);
         }
         else
         {
            setReturned(_loc2_.returned);
            setReturned(_loc2_.scope,true);
         }
      }
      
      private function execCommand(param1:String) : void
      {
         var _loc6_:SlashCommand = null;
         var _loc7_:String = null;
         var _loc4_:int = 0;
         var _loc2_:int = param1.search(/[^\w]/);
         var _loc3_:String = param1.substring(0,_loc2_ > 0 ? _loc2_ : param1.length);
         if(_loc3_ == "")
         {
            setReturned(_saved.get("returned"),true);
            return;
         }
         var _loc5_:String = _loc2_ > 0 ? param1.substring(_loc2_ + 1) : "";
         if(_slashCmds[_loc3_] != null)
         {
            try
            {
               _loc6_ = _slashCmds[_loc3_];
               if(!config.commandLineAllowed && !_loc6_.allow)
               {
                  report("<b>Advanced CommandLine is disabled.</b>\nEnable by setting `Cc.config.commandLineAllowed = true;´\nType <b>/commands</b> for permitted commands.",9);
                  return;
               }
               if(_loc6_.endMarker)
               {
                  _loc4_ = _loc5_.indexOf(_loc6_.endMarker);
                  if(_loc4_ >= 0)
                  {
                     _loc7_ = _loc5_.substring(_loc4_ + _loc6_.endMarker.length);
                     _loc5_ = _loc5_.substring(0,_loc4_);
                  }
               }
               if(_loc5_.length == 0)
               {
                  _loc6_.f();
               }
               else
               {
                  _loc6_.f(_loc5_);
               }
               if(_loc7_)
               {
                  run(_loc7_);
               }
            }
            catch(err:Error)
            {
               reportError(err);
            }
         }
         else
         {
            report("Undefined command <b>/commands</b> for list of all commands.",10);
         }
      }
      
      public function setReturned(param1:*, param2:Boolean = false, param3:Boolean = true) : void
      {
         if(!config.commandLineAllowed)
         {
            report("<b>Advanced CommandLine is disabled.</b>\nEnable by setting `Cc.config.commandLineAllowed = true;´\nType <b>/commands</b> for permitted commands.",9);
            return;
         }
         if(param1 !== undefined)
         {
            _saved.set("returned",param1,true);
            if(param2 && param1 !== _scope)
            {
               _prevScope.reference = _scope;
               _scope = param1;
               if(remoter.remoting != 2)
               {
                  _scopeStr = LogReferences.ShortClassName(_scope,false);
                  sendCmdScope2Remote();
               }
               report("Changed to " + console.refs.makeRefTyped(param1),-1);
            }
            else if(param3)
            {
               report("Returned " + console.refs.makeString(param1),-1);
            }
         }
         else if(param3)
         {
            report("Exec successful, undefined return.",-1);
         }
      }
      
      public function sendCmdScope2Remote(param1:Event = null) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTF(_scopeStr);
         console.remoter.send("cls",_loc2_);
      }
      
      private function reportError(param1:Error) : void
      {
         var _loc10_:int = 0;
         var _loc6_:String = null;
         var _loc2_:String = console.refs.makeString(param1);
         var _loc8_:Array = _loc2_.split(/\n\s*/);
         var _loc5_:int = 10;
         var _loc3_:int = 0;
         var _loc9_:int = int(_loc8_.length);
         var _loc7_:Array = [];
         var _loc4_:RegExp = new RegExp("\\s*at\\s+(ExeValue|((com.junkbyte.console.core::)?Executer)|" + getQualifiedClassName(this) + ")");
         _loc10_ = 0;
         while(_loc10_ < _loc9_)
         {
            _loc6_ = _loc8_[_loc10_];
            if(_loc6_.search(_loc4_) == 0)
            {
               if(_loc3_ > 0 && _loc10_ > 0)
               {
                  break;
               }
               _loc3_++;
            }
            _loc7_.push("<p" + _loc5_ + "> " + _loc6_ + "</p" + _loc5_ + ">");
            if(_loc5_ > 6)
            {
               _loc5_--;
            }
            _loc10_++;
         }
         report(_loc7_.join("\n"),9);
      }
      
      private function saveCmd(param1:String = null) : void
      {
         store(param1,_scope,false);
      }
      
      private function saveStrongCmd(param1:String = null) : void
      {
         store(param1,_scope,true);
      }
      
      private function savedCmd(... rest) : void
      {
         var _loc2_:WeakRef = null;
         report("Saved vars: ",-1);
         var _loc5_:uint = 0;
         var _loc3_:uint = 0;
         for(var _loc4_:String in _saved)
         {
            _loc2_ = _saved.getWeakRef(_loc4_);
            _loc5_++;
            if(_loc2_.reference == null)
            {
               _loc3_++;
            }
            report((_loc2_.strong ? "strong" : "weak") + " <b>$" + _loc4_ + "</b> = " + console.refs.makeString(_loc2_.reference),-2);
         }
         report("Found " + _loc5_ + " item(s), " + _loc3_ + " empty.",-1);
      }
      
      private function stringCmd(param1:String) : void
      {
         report("String with " + param1.length + " chars entered. Use /save <i>(name)</i> to save.",-2);
         setReturned(param1,true);
      }
      
      private function cmdsCmd(... rest) : void
      {
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         for each(var _loc2_:SlashCommand in _slashCmds)
         {
            if(config.commandLineAllowed || _loc2_.allow)
            {
               if(_loc2_.user)
               {
                  _loc4_.push(_loc2_);
               }
               else
               {
                  _loc3_.push(_loc2_);
               }
            }
         }
         _loc3_ = _loc3_.sortOn("n");
         report("Built-in commands:" + (!config.commandLineAllowed ? " (limited permission)" : ""),4);
         for each(_loc2_ in _loc3_)
         {
            report("<b>/" + _loc2_.n + "</b> <p-1>" + _loc2_.d + "</p-1>",-2);
         }
         if(_loc4_.length)
         {
            _loc4_ = _loc4_.sortOn("n");
            report("User commands:",4);
            for each(_loc2_ in _loc4_)
            {
               report("<b>/" + _loc2_.n + "</b> <p-1>" + _loc2_.d + "</p-1>",-2);
            }
         }
      }
      
      private function inspectCmd(... rest) : void
      {
         console.refs.focus(_scope);
      }
      
      private function explodeCmd(param1:String = "0") : void
      {
         var _loc2_:int = int(param1);
         console.explodech(console.panels.mainPanel.reportChannel,_scope,_loc2_ <= 0 ? 3 : _loc2_);
      }
      
      private function mapCmd(param1:String = "0") : void
      {
         console.mapch(console.panels.mainPanel.reportChannel,_scope as DisplayObjectContainer,int(param1));
      }
      
      private function funCmd(param1:String = "") : void
      {
         var _loc2_:FakeFunction = new FakeFunction(run,param1);
         report("Function created. Use /savestrong <i>(name)</i> to save.",-2);
         setReturned(_loc2_.exec,true);
      }
      
      private function autoscopeCmd(... rest) : void
      {
         config.commandLineAutoScope = !config.commandLineAutoScope;
         report("Auto-scoping <b>" + (config.commandLineAutoScope ? "enabled" : "disabled") + "</b>.",10);
      }
      
      private function baseCmd(... rest) : void
      {
         setReturned(base,true);
      }
      
      private function prevCmd(... rest) : void
      {
         setReturned(_prevScope.reference,true);
      }
      
      private function printHelp(... rest) : void
      {
         report("____Command Line Help___",10);
         report("/filter (text) = filter/search logs for matching text",5);
         report("/commands to see all slash commands",5);
         report("Press up/down arrow keys to recall previous line",2);
         report("__Examples:",10);
         report("<b>stage.stageWidth</b>",5);
         report("<b>stage.scaleMode = flash.display.StageScaleMode.NO_SCALE</b>",5);
         report("<b>stage.frameRate = 12</b>",5);
         report("__________",10);
      }
   }
}

class FakeFunction
{
   
   private var line:String;
   
   private var run:Function;
   
   public function FakeFunction(param1:Function, param2:String)
   {
      super();
      run = param1;
      line = param2;
   }
   
   public function exec(... rest) : *
   {
      return run(line,rest);
   }
}

class SlashCommand
{
   
   public var n:String;
   
   public var f:Function;
   
   public var d:String;
   
   public var user:Boolean;
   
   public var allow:Boolean;
   
   public var endMarker:String;
   
   public function SlashCommand(param1:String, param2:Function, param3:String, param4:Boolean, param5:Boolean, param6:String)
   {
      super();
      n = param1;
      f = param2;
      d = param3 ? param3 : "";
      user = param4;
      allow = param5;
      endMarker = param6;
   }
}
