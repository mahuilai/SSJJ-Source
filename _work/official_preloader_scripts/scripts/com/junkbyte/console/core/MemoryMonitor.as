package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import flash.system.System;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class MemoryMonitor extends ConsoleCore
   {
      
      private var _namesList:Object;
      
      private var _objectsList:Dictionary;
      
      private var _count:uint;
      
      public function MemoryMonitor(param1:Console)
      {
         super(param1);
         _namesList = {};
         _objectsList = new Dictionary(true);
         console.remoter.registerCallback("gc",gc);
      }
      
      public function watch(param1:Object, param2:String) : String
      {
         var _loc3_:String = getQualifiedClassName(param1);
         if(!param2)
         {
            param2 = _loc3_ + "@" + getTimer();
         }
         if(_objectsList[param1])
         {
            if(_namesList[_objectsList[param1]])
            {
               unwatch(_objectsList[param1]);
            }
         }
         if(_namesList[param2])
         {
            if(_objectsList[param1] == param2)
            {
               _count = _count - 1;
            }
            else
            {
               param2 = param2 + "@" + getTimer() + "_" + Math.floor(Math.random() * 100);
            }
         }
         _namesList[param2] = true;
         _count = _count + 1;
         _objectsList[param1] = param2;
         return param2;
      }
      
      public function unwatch(param1:String) : void
      {
         for(var _loc2_:Object in _objectsList)
         {
            if(_objectsList[_loc2_] == param1)
            {
               delete _objectsList[_loc2_];
            }
         }
         if(_namesList[param1])
         {
            delete _namesList[param1];
            _count = _count - 1;
         }
      }
      
      public function update() : void
      {
         if(_count == 0)
         {
            return;
         }
         var _loc1_:Array = [];
         var _loc2_:Object = {};
         for(var _loc4_:Object in _objectsList)
         {
            _loc2_[_objectsList[_loc4_]] = true;
         }
         for(var _loc3_:String in _namesList)
         {
            if(!_loc2_[_loc3_])
            {
               _loc1_.push(_loc3_);
               delete _namesList[_loc3_];
               _count = _count - 1;
            }
         }
         if(_loc1_.length)
         {
            report("<b>GARBAGE COLLECTED " + _loc1_.length + " item(s): </b>" + _loc1_.join(", "),-2);
         }
      }
      
      public function get count() : uint
      {
         return _count;
      }
      
      public function gc() : void
      {
         var _loc2_:Boolean = false;
         var _loc1_:String = null;
         if(remoter.remoting == 2)
         {
            try
            {
               remoter.send("gc");
            }
            catch(e:Error)
            {
               report(e,10);
            }
         }
         else
         {
            try
            {
               if(System["gc"] != null)
               {
                  System["gc"]();
                  _loc2_ = true;
               }
            }
            catch(e:Error)
            {
            }
            _loc1_ = "Manual garbage collection " + (_loc2_ ? "successful." : "FAILED. You need debugger version of flash player.");
            report(_loc1_,_loc2_ ? -1 : 10);
         }
      }
   }
}

