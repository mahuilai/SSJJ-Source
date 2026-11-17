package com.junkbyte.console.core
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.Console;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.utils.ByteArray;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   
   public class ConsoleTools extends ConsoleCore
   {
      
      public function ConsoleTools(param1:Console)
      {
         super(param1);
      }
      
      public function map(param1:DisplayObjectContainer, param2:uint = 0, param3:String = null) : void
      {
         var _loc13_:Boolean = false;
         var _loc16_:DisplayObject = null;
         var _loc14_:DisplayObjectContainer = null;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:DisplayObject = null;
         var _loc12_:String = null;
         var _loc15_:* = 0;
         var _loc5_:String = null;
         if(!param1)
         {
            report("Not a DisplayObjectContainer.",10,true,param3);
            return;
         }
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc11_:DisplayObject = null;
         var _loc6_:Array = [];
         _loc6_.push(param1);
         while(_loc4_ < _loc6_.length)
         {
            _loc16_ = _loc6_[_loc4_];
            _loc4_++;
            if(_loc16_ is DisplayObjectContainer)
            {
               _loc14_ = _loc16_ as DisplayObjectContainer;
               _loc7_ = _loc14_.numChildren;
               _loc9_ = 0;
               while(_loc9_ < _loc7_)
               {
                  _loc10_ = _loc14_.getChildAt(_loc9_);
                  _loc6_.splice(_loc4_ + _loc9_,0,_loc10_);
                  _loc9_++;
               }
            }
            if(_loc11_)
            {
               if(_loc11_ is DisplayObjectContainer && (_loc11_ as DisplayObjectContainer).contains(_loc16_))
               {
                  _loc8_++;
               }
               else
               {
                  while(_loc11_)
                  {
                     _loc11_ = _loc11_.parent;
                     if(_loc11_ is DisplayObjectContainer)
                     {
                        if(_loc8_ > 0)
                        {
                           _loc8_--;
                        }
                        if((_loc11_ as DisplayObjectContainer).contains(_loc16_))
                        {
                           _loc8_++;
                           break;
                        }
                     }
                  }
               }
            }
            _loc12_ = "";
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc12_ += _loc9_ == _loc8_ - 1 ? " ∟ " : " - ";
               _loc9_++;
            }
            if(param2 <= 0 || _loc8_ <= param2)
            {
               _loc13_ = false;
               _loc15_ = console.refs.setLogRef(_loc16_);
               _loc5_ = _loc16_.name;
               if(_loc15_)
               {
                  _loc5_ = "<a href=\'event:cl_" + _loc15_ + "\'>" + _loc5_ + "</a>";
               }
               if(_loc16_ is DisplayObjectContainer)
               {
                  _loc5_ = "<b>" + _loc5_ + "</b>";
               }
               else
               {
                  _loc5_ = "<i>" + _loc5_ + "</i>";
               }
               _loc12_ += _loc5_ + " " + console.refs.makeRefTyped(_loc16_);
               report(_loc12_,_loc16_ is DisplayObjectContainer ? 5 : 2,true,param3);
            }
            else if(!_loc13_)
            {
               _loc13_ = true;
               report(_loc12_ + "...",5,true,param3);
            }
            _loc11_ = _loc16_;
         }
         report(param1.name + ":" + console.refs.makeRefTyped(param1) + " has " + (_loc6_.length - 1) + " children/sub-children.",9,true,param3);
         if(config.commandLineAllowed)
         {
            report("Click on the child display\'s name to set scope.",-2,true,param3);
         }
      }
      
      public function explode(param1:Object, param2:int = 3, param3:int = 9) : String
      {
         var _loc8_:String = null;
         var _loc7_:XMLList = null;
         var _loc5_:String = typeof param1;
         if(param1 == null)
         {
            return "<p-2>" + param1 + "</p-2>";
         }
         if(param1 is String)
         {
            return "\"" + LogReferences.EscHTML(param1 as String) + "\"";
         }
         if(_loc5_ != "object" || param2 == 0 || param1 is ByteArray)
         {
            return console.refs.makeString(param1);
         }
         if(param3 < 0)
         {
            param3 = 0;
         }
         var _loc4_:XML = describeType(param1);
         var _loc10_:Array = [];
         _loc7_ = _loc4_["accessor"];
         for each(var _loc9_:XML in _loc7_)
         {
            _loc8_ = _loc9_.@name;
            if(_loc9_.@access != "writeonly")
            {
               try
               {
                  _loc10_.push(stepExp(param1,_loc8_,param2,param3));
               }
               catch(e:Error)
               {
               }
            }
            else
            {
               _loc10_.push(_loc8_);
            }
         }
         _loc7_ = _loc4_["variable"];
         for each(var _loc6_:XML in _loc7_)
         {
            _loc8_ = _loc6_.@name;
            _loc10_.push(stepExp(param1,_loc8_,param2,param3));
         }
         try
         {
            for(var _loc11_:String in param1)
            {
               _loc10_.push(stepExp(param1,_loc11_,param2,param3));
            }
         }
         catch(e:Error)
         {
         }
         return "<p" + param3 + ">{" + LogReferences.ShortClassName(param1) + "</p" + param3 + "> " + _loc10_.join(", ") + "<p" + param3 + ">}</p" + param3 + ">";
      }
      
      private function stepExp(param1:*, param2:String, param3:int, param4:int) : String
      {
         return param2 + ":" + explode(param1[param2],param3 - 1,param4 - 1);
      }
      
      public function getStack(param1:int, param2:int) : String
      {
         var _loc9_:int = 0;
         var _loc3_:Error = new Error();
         var _loc4_:String = _loc3_.hasOwnProperty("getStackTrace") ? _loc3_.getStackTrace() : null;
         if(!_loc4_)
         {
            return "";
         }
         var _loc8_:String = "";
         var _loc6_:Array = _loc4_.split(/\n\sat\s/);
         var _loc7_:int = int(_loc6_.length);
         var _loc5_:RegExp = new RegExp("Function|" + getQualifiedClassName(Console) + "|" + getQualifiedClassName(Cc));
         var _loc10_:Boolean = false;
         _loc9_ = 2;
         while(_loc9_ < _loc7_)
         {
            if(!_loc10_ && _loc6_[_loc9_].search(_loc5_) != 0)
            {
               _loc10_ = true;
            }
            if(_loc10_)
            {
               _loc8_ += "\n<p" + param2 + "> @ " + _loc6_[_loc9_] + "</p" + param2 + ">";
               if(param2 > 0)
               {
                  param2--;
               }
               if(--param1 <= 0)
               {
                  break;
               }
            }
            _loc9_++;
         }
         return _loc8_;
      }
   }
}

