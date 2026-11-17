package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.WeakObject;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class LogReferences extends ConsoleCore
   {
      
      public static const INSPECTING_CHANNEL:String = "⌂";
      
      private var _refMap:WeakObject = new WeakObject();
      
      private var _refRev:Dictionary = new Dictionary(true);
      
      private var _refIndex:uint = 1;
      
      private var _dofull:Boolean;
      
      private var _current:*;
      
      private var _history:Array;
      
      private var _hisIndex:uint;
      
      private var _prevBank:Array = [];
      
      private var _currentBank:Array = [];
      
      private var _lastWithdraw:uint;
      
      public function LogReferences(param1:Console)
      {
         var console:Console = param1;
         super(console);
         remoter.registerCallback("ref",function(param1:ByteArray):void
         {
            handleString(param1.readUTF());
         });
         remoter.registerCallback("focus",handleFocused);
      }
      
      public static function EscHTML(param1:String) : String
      {
         return param1.replace(/</g,"&lt;").replace(/\>/g,"&gt;").replace(/\x00/g,"");
      }
      
      public static function ShortClassName(param1:Object, param2:Boolean = true) : String
      {
         var _loc3_:String = getQualifiedClassName(param1);
         var _loc4_:int = _loc3_.indexOf("::");
         var _loc5_:String = param1 is Class ? "*" : "";
         _loc3_ = _loc5_ + _loc3_.substring(_loc4_ >= 0 ? _loc4_ + 2 : 0) + _loc5_;
         if(param2)
         {
            return EscHTML(_loc3_);
         }
         return _loc3_;
      }
      
      public function update(param1:uint) : void
      {
         if(_currentBank.length || _prevBank.length)
         {
            if(param1 > _lastWithdraw + config.objectHardReferenceTimer * 1000)
            {
               _prevBank = _currentBank;
               _currentBank = [];
               _lastWithdraw = param1;
            }
         }
      }
      
      public function setLogRef(param1:*) : uint
      {
         var _loc3_:int = 0;
         if(!config.useObjectLinking)
         {
            return 0;
         }
         var _loc2_:uint = uint(_refRev[param1]);
         if(!_loc2_)
         {
            _loc2_ = _refIndex;
            _refMap[_loc2_] = param1;
            _refRev[param1] = _loc2_;
            if(config.objectHardReferenceTimer)
            {
               _currentBank.push(param1);
            }
            _refIndex = _refIndex + 1;
            _loc3_ = _loc2_ - 50;
            while(_loc3_ >= 0)
            {
               if(_refMap[_loc3_] === null)
               {
                  delete _refMap[_loc3_];
               }
               _loc3_ -= 50;
            }
         }
         return _loc2_;
      }
      
      public function getRefId(param1:*) : uint
      {
         return _refRev[param1];
      }
      
      public function getRefById(param1:uint) : *
      {
         return _refMap[param1];
      }
      
      public function makeString(param1:*, param2:* = null, param3:Boolean = false, param4:int = -1) : String
      {
         var _loc10_:String = null;
         var _loc12_:* = undefined;
         var _loc14_:Error = null;
         var _loc6_:String = null;
         var _loc13_:String = null;
         var _loc7_:int = 0;
         var _loc9_:Boolean = false;
         var _loc11_:int = 0;
         var _loc5_:String = null;
         var _loc8_:String = null;
         try
         {
            _loc12_ = param2 ? param1[param2] : param1;
         }
         catch(err:Error)
         {
            return "<p0><i>" + err.toString() + "</i></p0>";
         }
         if(_loc12_ is Error)
         {
            _loc14_ = _loc12_ as Error;
            _loc6_ = _loc14_.hasOwnProperty("getStackTrace") ? _loc14_.getStackTrace() : _loc14_.toString();
            if(_loc6_)
            {
               return _loc6_;
            }
            return _loc14_.toString();
         }
         if(_loc12_ is XML || _loc12_ is XMLList)
         {
            return shortenString(EscHTML(_loc12_.toXMLString()),param4,param1,param2);
         }
         if(_loc12_ is QName)
         {
            return String(_loc12_);
         }
         if(_loc12_ is Array || getQualifiedClassName(_loc12_).indexOf("__AS3__.vec::Vector.") == 0)
         {
            _loc13_ = "[";
            _loc7_ = int(_loc12_.length);
            _loc9_ = param4 >= 0;
            _loc11_ = 0;
            while(_loc11_ < _loc7_)
            {
               _loc5_ = makeString(_loc12_[_loc11_],null,false,param4);
               _loc13_ += (_loc11_ ? ", " : "") + _loc5_;
               param4 -= _loc5_.length;
               if(_loc9_ && param4 <= 0 && _loc11_ < _loc7_ - 1)
               {
                  _loc13_ += ", " + genLinkString(param1,param2,"...");
                  break;
               }
               _loc11_++;
            }
            return _loc13_ + "]";
         }
         if(config.useObjectLinking && _loc12_ && typeof _loc12_ == "object")
         {
            _loc8_ = "";
            if(_loc12_ is ByteArray)
            {
               _loc8_ = " position:" + _loc12_.position + " length:" + _loc12_.length;
            }
            else if(_loc12_ is Date || _loc12_ is Rectangle || _loc12_ is Point || _loc12_ is Matrix || _loc12_ is Event)
            {
               _loc8_ = " " + String(_loc12_);
            }
            else if(_loc12_ is DisplayObject && _loc12_.name)
            {
               _loc8_ = " " + _loc12_.name;
            }
            _loc10_ = "{" + genLinkString(param1,param2,ShortClassName(_loc12_)) + EscHTML(_loc8_) + "}";
         }
         else
         {
            if(_loc12_ is ByteArray)
            {
               _loc10_ = "[ByteArray position:" + ByteArray(_loc12_).position + " length:" + ByteArray(_loc12_).length + "]";
            }
            else
            {
               _loc10_ = String(_loc12_);
            }
            if(!param3)
            {
               return shortenString(EscHTML(_loc10_),param4,param1,param2);
            }
         }
         return _loc10_;
      }
      
      public function makeRefTyped(param1:*) : String
      {
         if(param1 && typeof param1 == "object" && !(param1 is QName))
         {
            return "{" + genLinkString(param1,null,ShortClassName(param1)) + "}";
         }
         return ShortClassName(param1);
      }
      
      private function genLinkString(param1:*, param2:*, param3:String) : String
      {
         if(param2 && !(param2 is String))
         {
            param1 = param1[param2];
            param2 = null;
         }
         var _loc4_:uint = setLogRef(param1);
         if(_loc4_)
         {
            return "<menu><a href=\'event:ref_" + _loc4_ + (param2 ? "_" + param2 : "") + "\'>" + param3 + "</a></menu>";
         }
         return param3;
      }
      
      private function shortenString(param1:String, param2:int, param3:*, param4:* = null) : String
      {
         if(param2 >= 0 && param1.length > param2)
         {
            param1 = param1.substring(0,param2);
            return param1 + genLinkString(param3,param4," ...");
         }
         return param1;
      }
      
      private function historyInc(param1:int) : void
      {
         _hisIndex += param1;
         var _loc2_:* = _history[_hisIndex];
         if(_loc2_)
         {
            focus(_loc2_,_dofull);
         }
      }
      
      public function handleRefEvent(param1:String) : void
      {
         var _loc2_:ByteArray = null;
         if(remoter.remoting == 2)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(param1);
            remoter.send("ref",_loc2_);
         }
         else
         {
            handleString(param1);
         }
      }
      
      private function handleString(param1:String) : void
      {
         var _loc6_:int = 0;
         var _loc2_:* = 0;
         var _loc3_:String = null;
         var _loc5_:int = 0;
         var _loc4_:Object = null;
         if(param1 == "refexit")
         {
            exitFocus();
            console.setViewingChannels();
         }
         else if(param1 == "refprev")
         {
            historyInc(-2);
         }
         else if(param1 == "reffwd")
         {
            historyInc(0);
         }
         else if(param1 == "refi")
         {
            focus(_current,!_dofull);
         }
         else
         {
            _loc6_ = param1.indexOf("_") + 1;
            if(_loc6_ > 0)
            {
               _loc3_ = "";
               _loc5_ = param1.indexOf("_",_loc6_);
               if(_loc5_ > 0)
               {
                  _loc2_ = uint(param1.substring(_loc6_,_loc5_));
                  _loc3_ = param1.substring(_loc5_ + 1);
               }
               else
               {
                  _loc2_ = uint(param1.substring(_loc6_));
               }
               _loc4_ = getRefById(_loc2_);
               if(_loc3_)
               {
                  _loc4_ = _loc4_[_loc3_];
               }
               if(_loc4_)
               {
                  if(param1.indexOf("refe_") == 0)
                  {
                     console.explodech(console.panels.mainPanel.reportChannel,_loc4_);
                  }
                  else
                  {
                     focus(_loc4_,_dofull);
                  }
                  return;
               }
            }
            report("Reference no longer exist (garbage collected).",-2);
         }
      }
      
      public function focus(param1:*, param2:Boolean = false) : void
      {
         remoter.send("focus");
         console.clear("⌂");
         console.setViewingChannels("⌂");
         if(!_history)
         {
            _history = [];
         }
         if(_current != param1)
         {
            _current = param1;
            if(_history.length <= _hisIndex)
            {
               _history.push(param1);
            }
            else
            {
               _history[_hisIndex] = param1;
            }
            _hisIndex = _hisIndex + 1;
         }
         _dofull = param2;
         inspect(param1,_dofull);
      }
      
      private function handleFocused() : void
      {
         console.clear("⌂");
         console.setViewingChannels("⌂");
      }
      
      public function exitFocus() : void
      {
         var _loc1_:ByteArray = null;
         _current = null;
         _dofull = false;
         _history = null;
         _hisIndex = 0;
         if(remoter.remoting == 1)
         {
            _loc1_ = new ByteArray();
            _loc1_.writeUTF("refexit");
            remoter.send("ref",_loc1_);
         }
         console.clear("⌂");
      }
      
      public function inspect(param1:*, param2:Boolean = true, param3:String = null) : void
      {
         var _loc6_:String = null;
         var _loc30_:* = null;
         var _loc18_:* = null;
         var _loc34_:String = null;
         var _loc37_:String = null;
         var _loc35_:DisplayObject = null;
         var _loc29_:DisplayObjectContainer = null;
         var _loc41_:DisplayObjectContainer = null;
         var _loc36_:String = null;
         var _loc15_:DisplayObjectContainer = null;
         var _loc33_:int = 0;
         var _loc31_:int = 0;
         var _loc10_:DisplayObject = null;
         var _loc8_:Boolean = false;
         var _loc39_:Boolean = false;
         var _loc23_:Array = null;
         var _loc32_:XMLList = null;
         var _loc26_:String = null;
         if(!param1)
         {
            report(param1,-2,true,param3);
            return;
         }
         var _loc25_:uint = setLogRef(param1);
         var _loc13_:String = "";
         if(!param2)
         {
            _loc13_ = " [<a href=\'event:refi\'>show inherited</a>]";
         }
         if(_history)
         {
            _loc6_ = "<b>[<a href=\'event:refexit\'>exit</a>]";
            if(_hisIndex > 1)
            {
               _loc6_ += " [<a href=\'event:refprev\'>previous</a>]";
            }
            if(_history && _hisIndex < _history.length)
            {
               _loc6_ += " [<a href=\'event:reffwd\'>forward</a>]";
            }
            _loc6_ += "</b> || [<a href=\'event:ref_" + _loc25_ + "\'>refresh</a>]";
            _loc6_ = _loc6_ + ("</b> [<a href=\'event:refe_" + _loc25_ + "\'>explode</a>]");
            if(config.commandLineAllowed)
            {
               _loc6_ += " [<a href=\'event:cl_" + _loc25_ + "\'>scope</a>]";
            }
            if(param2)
            {
               _loc6_ += " [<a href=\'event:refi\'>hide inherited</a>]";
            }
            else
            {
               _loc6_ += _loc13_;
            }
            report(_loc6_,-1,true,param3);
            report("",1,true,param3);
         }
         var _loc11_:XML = describeType(param1);
         var _loc20_:Object = param1 is Class ? param1 : param1.constructor;
         var _loc19_:XML = describeType(_loc20_);
         var _loc7_:String = _loc11_.@name;
         var _loc4_:Boolean = param1 is Class;
         var _loc14_:String = _loc4_ ? "*" : "";
         var _loc28_:String = "<b>{" + _loc14_ + genLinkString(param1,null,EscHTML(_loc7_)) + _loc14_ + "}</b>";
         var _loc40_:Array = [];
         if(_loc11_.@isStatic == "true")
         {
            _loc40_.push("<b>static</b>");
         }
         if(_loc11_.@isDynamic == "true")
         {
            _loc40_.push("dynamic");
         }
         if(_loc11_.@isFinal == "true")
         {
            _loc40_.push("final");
         }
         if(_loc40_.length > 0)
         {
            _loc28_ += " <p-1>" + _loc40_.join(" | ") + "</p-1>";
         }
         report(_loc28_,-2,true,param3);
         _loc30_ = _loc11_.extendsClass;
         if(_loc30_.length())
         {
            _loc40_ = [];
            for each(var _loc9_:XML in _loc30_)
            {
               _loc14_ = _loc9_.@type.toString();
               _loc40_.push(_loc14_.indexOf("*") < 0 ? makeValue(getDefinitionByName(_loc14_)) : EscHTML(_loc14_));
               if(!param2)
               {
                  break;
               }
            }
            report("<p10>Extends:</p10> " + _loc40_.join(" &gt; "),1,true,param3);
         }
         _loc30_ = _loc11_.implementsInterface;
         if(_loc30_.length())
         {
            _loc40_ = [];
            for each(var _loc17_:XML in _loc30_)
            {
               _loc40_.push(makeValue(getDefinitionByName(_loc17_.@type.toString())));
            }
            report("<p10>Implements:</p10> " + _loc40_.join(", "),1,true,param3);
         }
         report("",1,true,param3);
         _loc40_ = [];
         _loc30_ = _loc11_.metadata.(@name == "Event");
         if(_loc30_.length())
         {
            for each(var _loc27_:XML in _loc30_)
            {
               _loc34_ = _loc18_ = _loc27_.arg.(@key == "name").@value;
               _loc37_ = _loc18_.(@key == "type").@value;
               if(_loc25_)
               {
                  _loc40_.push("<a href=\'event:cl_" + _loc25_ + "_dispatchEvent(new " + _loc37_ + "(\"" + _loc34_ + "\"))\'>" + _loc34_ + "</a><p0>(" + _loc37_ + ")</p0>");
               }
               else
               {
                  _loc40_.push(_loc34_ + "<p0>(" + _loc37_ + ")</p0>");
               }
            }
            report("<p10>Events:</p10> " + _loc40_.join("<p-1>; </p-1>"),1,true,param3);
            report("",1,true,param3);
         }
         if(param1 is DisplayObject)
         {
            _loc35_ = param1 as DisplayObject;
            _loc29_ = _loc35_.parent;
            if(_loc29_)
            {
               _loc40_ = new Array("@" + _loc29_.getChildIndex(_loc35_));
               while(_loc29_)
               {
                  _loc41_ = _loc29_;
                  _loc29_ = _loc29_.parent;
                  _loc36_ = _loc29_ ? "@" + _loc29_.getChildIndex(_loc41_) : "";
                  _loc40_.push("<b>" + _loc41_.name + "</b>" + _loc36_ + makeValue(_loc41_));
               }
               report("<p10>Parents:</p10> " + _loc40_.join("<p-1> -> </p-1>") + "<br/>",1,true,param3);
            }
         }
         if(param1 is DisplayObjectContainer)
         {
            _loc40_ = [];
            _loc15_ = param1 as DisplayObjectContainer;
            _loc33_ = _loc15_.numChildren;
            _loc31_ = 0;
            while(_loc31_ < _loc33_)
            {
               _loc10_ = _loc15_.getChildAt(_loc31_);
               _loc40_.push("<b>" + _loc10_.name + "</b>@" + _loc31_ + makeValue(_loc10_));
               _loc31_++;
            }
            if(_loc33_)
            {
               report("<p10>Children:</p10> " + _loc40_.join("<p-1>; </p-1>") + "<br/>",1,true,param3);
            }
         }
         _loc40_ = [];
         _loc30_ = _loc19_..constant;
         for each(var _loc12_:XML in _loc30_)
         {
            report(" const <p3>" + _loc12_.@name + "</p3>:" + _loc12_.@type + " = " + makeValue(_loc20_,_loc12_.@name.toString()) + "</p0>",1,true,param3);
         }
         if(_loc30_.length())
         {
            report("",1,true,param3);
         }
         var _loc24_:uint = 0;
         _loc40_ = [];
         _loc30_ = _loc19_..method;
         for each(var _loc21_:XML in _loc30_)
         {
            if(param2 || _loc7_ == _loc21_.@declaredBy)
            {
               _loc8_ = true;
               _loc39_ = _loc21_.parent().name() != "factory";
               _loc28_ = " " + (_loc39_ ? "static " : "") + "function ";
               _loc23_ = [];
               _loc32_ = _loc21_.parameter;
               for each(var _loc38_:XML in _loc32_)
               {
                  _loc23_.push(_loc38_.@optional == "true" ? "<i>" + _loc38_.@type + "</i>" : _loc38_.@type);
               }
               if(_loc25_ && (_loc39_ || !_loc4_))
               {
                  _loc28_ += "<a href=\'event:cl_" + _loc25_ + "_" + _loc21_.@name + "()\'><p3>" + _loc21_.@name + "</p3></a>";
               }
               else
               {
                  _loc28_ += "<p3>" + _loc21_.@name + "</p3>";
               }
               _loc28_ += "(" + _loc23_.join(", ") + "):" + _loc21_.@returnType;
               report(_loc28_,1,true,param3);
            }
            else
            {
               _loc24_++;
            }
         }
         if(_loc24_)
         {
            report("   \t + " + _loc24_ + " inherited methods." + _loc13_,1,true,param3);
         }
         else if(_loc8_)
         {
            report("",1,true,param3);
         }
         _loc8_ = false;
         _loc24_ = 0;
         _loc40_ = [];
         _loc30_ = _loc19_..accessor;
         for each(var _loc22_:XML in _loc30_)
         {
            if(param2 || _loc7_ == _loc22_.@declaredBy)
            {
               _loc8_ = true;
               _loc39_ = _loc22_.parent().name() != "factory";
               _loc28_ = " ";
               if(_loc39_)
               {
                  _loc28_ += "static ";
               }
               _loc26_ = _loc22_.@access;
               if(_loc26_ == "readonly")
               {
                  _loc28_ += "get";
               }
               else if(_loc26_ == "writeonly")
               {
                  _loc28_ += "set";
               }
               else
               {
                  _loc28_ += "assign";
               }
               if(_loc25_ && (_loc39_ || !_loc4_))
               {
                  _loc28_ += " <a href=\'event:cl_" + _loc25_ + "_" + _loc22_.@name + "\'><p3>" + _loc22_.@name + "</p3></a>:" + _loc22_.@type;
               }
               else
               {
                  _loc28_ += " <p3>" + _loc22_.@name + "</p3>:" + _loc22_.@type;
               }
               if(_loc26_ != "writeonly" && (_loc39_ || !_loc4_))
               {
                  _loc28_ += " = " + makeValue(_loc39_ ? _loc20_ : param1,_loc22_.@name.toString());
               }
               report(_loc28_,1,true,param3);
            }
            else
            {
               _loc24_++;
            }
         }
         if(_loc24_)
         {
            report("   \t + " + _loc24_ + " inherited accessors." + _loc13_,1,true,param3);
         }
         else if(_loc8_)
         {
            report("",1,true,param3);
         }
         _loc30_ = _loc19_..variable;
         for each(var _loc5_:XML in _loc30_)
         {
            _loc39_ = _loc5_.parent().name() != "factory";
            _loc28_ = _loc39_ ? " static" : "";
            if(_loc25_)
            {
               _loc28_ += " var <p3><a href=\'event:cl_" + _loc25_ + "_" + _loc5_.@name + " = \'>" + _loc5_.@name + "</a>";
            }
            else
            {
               _loc28_ += " var <p3>" + _loc5_.@name;
            }
            _loc28_ += "</p3>:" + _loc5_.@type + " = " + makeValue(_loc39_ ? _loc20_ : param1,_loc5_.@name.toString());
            report(_loc28_,1,true,param3);
         }
         try
         {
            _loc40_ = [];
            for(var _loc16_ in param1)
            {
               if(_loc16_ is String)
               {
                  if(_loc25_)
                  {
                     _loc28_ = "<a href=\'event:cl_" + _loc25_ + "_" + _loc16_ + " = \'>" + _loc16_ + "</a>";
                  }
                  else
                  {
                     _loc28_ = _loc16_;
                  }
                  report(" dynamic var <p3>" + _loc28_ + "</p3> = " + makeValue(param1,_loc16_),1,true,param3);
               }
               else
               {
                  report(" dictionary <p3>" + makeValue(_loc16_) + "</p3> = " + makeValue(param1,_loc16_),1,true,param3);
               }
            }
         }
         catch(e:Error)
         {
            report("Could not get dynamic values. " + e.message,9,false,param3);
         }
         if(param1 is String)
         {
            report("",1,true,param3);
            report("String",10,true,param3);
            report(EscHTML(param1),1,true,param3);
         }
         else if(param1 is XML || param1 is XMLList)
         {
            report("",1,true,param3);
            report("XMLString",10,true,param3);
            report(EscHTML(param1.toXMLString()),1,true,param3);
         }
         if(_loc6_)
         {
            report("",1,true,param3);
            report(_loc6_,-1,true,param3);
         }
      }
      
      public function getPossibleCalls(param1:*) : Array
      {
         var _loc9_:Array = null;
         var _loc6_:XMLList = null;
         var _loc8_:Array = [];
         var _loc2_:XML = describeType(param1);
         var _loc4_:XMLList = _loc2_.method;
         for each(var _loc5_:XML in _loc4_)
         {
            _loc9_ = [];
            _loc6_ = _loc5_.parameter;
            for each(var _loc10_:XML in _loc6_)
            {
               _loc9_.push(_loc10_.@optional == "true" ? "<i>" + _loc10_.@type + "</i>" : _loc10_.@type);
            }
            _loc8_.push([_loc5_.@name + "(",_loc9_.join(", ") + " ):" + _loc5_.@returnType]);
         }
         _loc4_ = _loc2_.accessor;
         for each(var _loc7_:XML in _loc4_)
         {
            _loc8_.push([String(_loc7_.@name),String(_loc7_.@type)]);
         }
         _loc4_ = _loc2_.variable;
         for each(var _loc3_:XML in _loc4_)
         {
            _loc8_.push([String(_loc3_.@name),String(_loc3_.@type)]);
         }
         return _loc8_;
      }
      
      private function makeValue(param1:*, param2:* = null) : String
      {
         return makeString(param1,param2,false,config.useObjectLinking ? 100 : -1);
      }
   }
}

