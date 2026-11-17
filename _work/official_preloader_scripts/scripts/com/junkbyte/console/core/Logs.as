package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.Log;
   import flash.events.Event;
   import flash.utils.ByteArray;
   
   public class Logs extends ConsoleCore
   {
      
      private var _channels:Object;
      
      private var _repeating:uint;
      
      private var _lastRepeat:Log;
      
      private var _newRepeat:Log;
      
      private var _hasNewLog:Boolean;
      
      private var _timer:uint;
      
      public var first:Log;
      
      public var last:Log;
      
      private var _length:uint;
      
      private var _lines:uint;
      
      public function Logs(param1:Console)
      {
         var console:Console = param1;
         super(console);
         _channels = {};
         remoter.addEventListener("connect",onRemoteConnection);
         remoter.registerCallback("log",function(param1:ByteArray):void
         {
            registerLog(Log.FromBytes(param1));
         });
      }
      
      private function onRemoteConnection(param1:Event) : void
      {
         var _loc2_:Log = first;
         while(_loc2_)
         {
            send2Remote(_loc2_);
            _loc2_ = _loc2_.next;
         }
      }
      
      private function send2Remote(param1:Log) : void
      {
         var _loc2_:ByteArray = null;
         if(remoter.canSend)
         {
            _loc2_ = new ByteArray();
            param1.toBytes(_loc2_);
            remoter.send("log",_loc2_);
         }
      }
      
      public function update(param1:uint) : Boolean
      {
         _timer = param1;
         if(_repeating > 0)
         {
            _repeating = _repeating - 1;
         }
         if(_newRepeat)
         {
            if(_lastRepeat)
            {
               remove(_lastRepeat);
            }
            _lastRepeat = _newRepeat;
            _newRepeat = null;
            push(_lastRepeat);
         }
         var _loc2_:Boolean = _hasNewLog;
         _hasNewLog = false;
         return _loc2_;
      }
      
      public function add(param1:Log) : void
      {
         _lines = _lines + 1;
         param1.line = _lines;
         param1.time = _timer;
         registerLog(param1);
      }
      
      private function registerLog(param1:Log) : void
      {
         _hasNewLog = true;
         addChannel(param1.ch);
         param1.lineStr = param1.line + " ";
         param1.chStr = "[<a href=\"event:channel_" + param1.ch + "\">" + param1.ch + "</a>] ";
         param1.timeStr = config.timeStampFormatter(param1.time) + " ";
         send2Remote(param1);
         if(param1.repeat)
         {
            if(_repeating > 0 && _lastRepeat)
            {
               param1.line = _lastRepeat.line;
               _newRepeat = param1;
               return;
            }
            _repeating = config.maxRepeats;
            _lastRepeat = param1;
         }
         push(param1);
         while(_length > config.maxLines && config.maxLines > 0)
         {
            remove(first);
         }
         if(config.tracing && config.traceCall != null)
         {
            config.traceCall(param1.ch,param1.plainText(),param1.priority);
         }
      }
      
      public function clear(param1:String = null) : void
      {
         var _loc2_:Log = null;
         if(param1)
         {
            _loc2_ = first;
            while(_loc2_)
            {
               if(_loc2_.ch == param1)
               {
                  remove(_loc2_);
               }
               _loc2_ = _loc2_.next;
            }
            delete _channels[param1];
         }
         else
         {
            first = null;
            last = null;
            _length = 0;
            _channels = {};
         }
      }
      
      public function getLogsAsString(param1:String, param2:Boolean = true, param3:Function = null) : String
      {
         var _loc4_:String = "";
         var _loc5_:Log = first;
         while(_loc5_)
         {
            if(param3 == null || param3(_loc5_))
            {
               if(first != _loc5_)
               {
                  _loc4_ += param1;
               }
               _loc4_ += param2 ? _loc5_.toString() : _loc5_.plainText();
            }
            _loc5_ = _loc5_.next;
         }
         return _loc4_;
      }
      
      public function getChannels() : Array
      {
         var _loc2_:Array = new Array(" * ");
         addIfexist("-",_loc2_);
         addIfexist("~",_loc2_);
         addIfexist("⌂",_loc2_);
         addIfexist("C",_loc2_);
         var _loc1_:Array = [];
         for(var _loc3_:String in _channels)
         {
            if(_loc2_.indexOf(_loc3_) < 0)
            {
               _loc1_.push(_loc3_);
            }
         }
         return _loc2_.concat(_loc1_.sort(1));
      }
      
      private function addIfexist(param1:String, param2:Array) : void
      {
         if(_channels.hasOwnProperty(param1))
         {
            param2.push(param1);
         }
      }
      
      public function cleanChannels() : void
      {
         _channels = {};
         var _loc1_:Log = first;
         while(_loc1_)
         {
            addChannel(_loc1_.ch);
            _loc1_ = _loc1_.next;
         }
      }
      
      public function addChannel(param1:String) : void
      {
         _channels[param1] = null;
      }
      
      private function push(param1:Log) : void
      {
         if(last == null)
         {
            first = param1;
         }
         else
         {
            last.next = param1;
            param1.prev = last;
         }
         last = param1;
         _length = _length + 1;
      }
      
      private function remove(param1:Log) : void
      {
         if(first == param1)
         {
            first = param1.next;
         }
         if(last == param1)
         {
            last = param1.prev;
         }
         if(param1 == _lastRepeat)
         {
            _lastRepeat = null;
         }
         if(param1 == _newRepeat)
         {
            _newRepeat = null;
         }
         if(param1.next != null)
         {
            param1.next.prev = param1.prev;
         }
         if(param1.prev != null)
         {
            param1.prev.next = param1.next;
         }
         _length = _length - 1;
      }
   }
}

