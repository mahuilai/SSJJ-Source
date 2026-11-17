package com.junkbyte.console.core
{
   import com.junkbyte.console.vos.WeakObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getDefinitionByName;
   
   public class Executer extends EventDispatcher
   {
      
      public static const RETURNED:String = "returned";
      
      public static const CLASSES:String = "ExeValue|((com.junkbyte.console.core::)?Executer)";
      
      private static const VALKEY:String = "#";
      
      private var _values:Array;
      
      private var _running:Boolean;
      
      private var _scope:*;
      
      private var _returned:*;
      
      private var _saved:Object;
      
      private var _reserved:Array;
      
      public var autoScope:Boolean;
      
      public function Executer()
      {
         super();
      }
      
      public static function Exec(param1:Object, param2:String, param3:Object = null) : *
      {
         var _loc4_:Executer = new Executer();
         _loc4_.setStored(param3);
         return _loc4_.exec(param1,param2);
      }
      
      public function get returned() : *
      {
         return _returned;
      }
      
      public function get scope() : *
      {
         return _scope;
      }
      
      public function setStored(param1:Object) : void
      {
         _saved = param1;
      }
      
      public function setReserved(param1:Array) : void
      {
         _reserved = param1;
      }
      
      public function exec(param1:*, param2:String) : *
      {
         if(_running)
         {
            throw new Error("CommandExec.exec() is already runnnig. Does not support loop backs.");
         }
         _running = true;
         _scope = param1;
         _values = [];
         if(!_saved)
         {
            _saved = {};
         }
         if(!_reserved)
         {
            _reserved = [];
         }
         try
         {
            _exec(param2);
         }
         catch(e:Error)
         {
            reset();
            throw e;
         }
         reset();
         return _returned;
      }
      
      private function reset() : void
      {
         _saved = null;
         _reserved = null;
         _values = null;
         _running = false;
      }
      
      private function _exec(param1:String) : void
      {
         var _loc9_:String = null;
         var _loc4_:String = null;
         var _loc3_:int = 0;
         var _loc11_:int = 0;
         var _loc6_:String = null;
         var _loc10_:* = undefined;
         var _loc8_:RegExp = /''|""|('(.*?)[^\\]')|("(.*?)[^\\]")/;
         var _loc2_:Object = _loc8_.exec(param1);
         while(_loc2_ != null)
         {
            _loc9_ = _loc2_[0];
            _loc4_ = _loc9_.charAt(0);
            _loc3_ = _loc9_.indexOf(_loc4_);
            _loc11_ = _loc9_.lastIndexOf(_loc4_);
            _loc6_ = _loc9_.substring(_loc3_ + 1,_loc11_).replace(/\\(.)/g,"$1");
            param1 = tempValue(param1,new ExeValue(_loc6_),_loc2_.index + _loc3_,_loc2_.index + _loc11_ + 1);
            _loc2_ = _loc8_.exec(param1);
         }
         if(param1.search(/'|"/) >= 0)
         {
            throw new Error("Bad syntax extra quotation marks");
         }
         var _loc5_:Array = param1.split(/\s*;\s*/);
         for each(var _loc7_:String in _loc5_)
         {
            if(_loc7_.length)
            {
               _loc10_ = _saved["returned"];
               if(_loc10_ && _loc7_ == "/")
               {
                  _scope = _loc10_;
                  dispatchEvent(new Event("complete"));
               }
               else
               {
                  execNest(_loc7_);
               }
            }
         }
      }
      
      private function execNest(param1:String) : *
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:int = 0;
         var _loc9_:String = null;
         var _loc4_:Boolean = false;
         var _loc8_:int = 0;
         var _loc3_:String = null;
         var _loc5_:Array = null;
         var _loc13_:ExeValue = null;
         var _loc11_:String = null;
         param1 = ignoreWhite(param1);
         var _loc2_:int = param1.lastIndexOf("(");
         while(_loc2_ >= 0)
         {
            _loc6_ = param1.indexOf(")",_loc2_);
            if(param1.substring(_loc2_ + 1,_loc6_).search(/\w/) >= 0)
            {
               _loc7_ = _loc2_;
               _loc10_ = _loc2_ + 1;
               while(_loc7_ >= 0 && _loc7_ < _loc10_)
               {
                  _loc7_++;
                  _loc7_ = param1.indexOf("(",_loc7_);
                  _loc10_ = param1.indexOf(")",_loc10_ + 1);
               }
               _loc9_ = param1.substring(_loc2_ + 1,_loc10_);
               _loc4_ = false;
               _loc8_ = _loc2_ - 1;
               while(true)
               {
                  _loc3_ = param1.charAt(_loc8_);
                  if(_loc3_.match(/[^\s]/) || _loc8_ <= 0)
                  {
                     break;
                  }
                  _loc8_--;
               }
               if(_loc3_.match(/\w/))
               {
                  _loc4_ = true;
               }
               if(_loc4_)
               {
                  _loc5_ = _loc9_.split(",");
                  param1 = tempValue(param1,new ExeValue(_loc5_),_loc2_ + 1,_loc10_);
                  for(var _loc12_:String in _loc5_)
                  {
                     _loc5_[_loc12_] = execOperations(ignoreWhite(_loc5_[_loc12_])).value;
                  }
               }
               else
               {
                  _loc13_ = new ExeValue(_loc13_);
                  param1 = tempValue(param1,_loc13_,_loc2_,_loc10_ + 1);
                  _loc13_.setValue(execOperations(ignoreWhite(_loc9_)).value);
               }
            }
            _loc2_ = param1.lastIndexOf("(",_loc2_ - 1);
         }
         _returned = execOperations(param1).value;
         if(_returned && autoScope)
         {
            _loc11_ = typeof _returned;
            if(_loc11_ == "object" || _loc11_ == "xml")
            {
               _scope = _returned;
            }
         }
         dispatchEvent(new Event("complete"));
         return _returned;
      }
      
      private function tempValue(param1:String, param2:*, param3:int, param4:int) : String
      {
         param1 = param1.substring(0,param3) + "#" + _values.length + param1.substring(param4);
         _values.push(param2);
         return param1;
      }
      
      private function execOperations(param1:String) : ExeValue
      {
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc11_:String = null;
         var _loc9_:int = 0;
         var _loc5_:String = null;
         var _loc3_:* = undefined;
         var _loc15_:ExeValue = null;
         var _loc6_:ExeValue = null;
         var _loc12_:RegExp = /\s*(((\|\||\&\&|[+|\-|*|\/|\%|\||\&|\^]|\=\=?|\!\=|\>\>?\>?|\<\<?)\=?)|=|\~|\sis\s|typeof|delete\s)\s*/g;
         var _loc2_:Object = _loc12_.exec(param1);
         var _loc13_:Array = [];
         if(_loc2_ == null)
         {
            _loc13_.push(param1);
         }
         else
         {
            _loc8_ = 0;
            while(_loc2_ != null)
            {
               _loc4_ = int(_loc2_.index);
               _loc11_ = _loc2_[0];
               _loc2_ = _loc12_.exec(param1);
               if(_loc2_ == null)
               {
                  _loc13_.push(param1.substring(_loc8_,_loc4_));
                  _loc13_.push(ignoreWhite(_loc11_));
                  _loc13_.push(param1.substring(_loc4_ + _loc11_.length));
               }
               else
               {
                  _loc13_.push(param1.substring(_loc8_,_loc4_));
                  _loc13_.push(ignoreWhite(_loc11_));
                  _loc8_ = _loc4_ + _loc11_.length;
               }
            }
         }
         var _loc7_:int = int(_loc13_.length);
         _loc9_ = 0;
         while(_loc9_ < _loc7_)
         {
            _loc13_[_loc9_] = execSimple(_loc13_[_loc9_]);
            _loc9_ += 2;
         }
         var _loc14_:RegExp = /((\|\||\&\&|[+|\-|*|\/|\%|\||\&|\^]|\>\>\>?|\<\<)\=)|=/;
         _loc9_ = 1;
         while(_loc9_ < _loc7_)
         {
            _loc5_ = _loc13_[_loc9_];
            if(_loc5_.replace(_loc14_,"") != "")
            {
               _loc3_ = operate(_loc13_[_loc9_ - 1],_loc5_,_loc13_[_loc9_ + 1]);
               _loc15_ = ExeValue(_loc13_[_loc9_ - 1]);
               _loc15_.setValue(_loc3_);
               _loc13_.splice(_loc9_,2);
               _loc9_ -= 2;
               _loc7_ -= 2;
            }
            _loc9_ += 2;
         }
         _loc13_.reverse();
         var _loc10_:ExeValue = _loc13_[0];
         _loc9_ = 1;
         while(_loc9_ < _loc7_)
         {
            _loc5_ = _loc13_[_loc9_];
            if(_loc5_.replace(_loc14_,"") == "")
            {
               _loc10_ = _loc13_[_loc9_ - 1];
               _loc6_ = _loc13_[_loc9_ + 1];
               if(_loc5_.length > 1)
               {
                  _loc5_ = _loc5_.substring(0,_loc5_.length - 1);
               }
               _loc3_ = operate(_loc6_,_loc5_,_loc10_);
               _loc6_.setValue(_loc3_);
            }
            _loc9_ += 2;
         }
         return _loc10_;
      }
      
      private function execSimple(param1:String) : ExeValue
      {
         var _loc9_:String = null;
         var _loc15_:int = 0;
         var _loc3_:* = undefined;
         var _loc22_:String = null;
         var _loc18_:* = undefined;
         var _loc11_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:Boolean = false;
         var _loc23_:String = null;
         var _loc2_:ExeValue = null;
         var _loc12_:* = undefined;
         var _loc14_:int = 0;
         var _loc6_:String = null;
         var _loc13_:Array = null;
         var _loc21_:Array = null;
         var _loc10_:* = undefined;
         var _loc17_:ExeValue = new ExeValue(_scope);
         if(param1.indexOf("new ") == 0)
         {
            _loc9_ = param1;
            _loc15_ = param1.indexOf(")");
            if(_loc15_ >= 0)
            {
               _loc9_ = param1.substring(0,_loc15_ + 1);
            }
            _loc3_ = makeNew(_loc9_.substring(4));
            param1 = tempValue(param1,new ExeValue(_loc3_),0,_loc9_.length);
         }
         var _loc20_:RegExp = /\.|\(/g;
         var _loc4_:Object = _loc20_.exec(param1);
         if(_loc4_ == null || !isNaN(Number(param1)))
         {
            return execValue(param1,_scope);
         }
         var _loc16_:Array = String(param1.split("(")[0]).split(".");
         if(_loc16_.length > 0)
         {
            while(_loc16_.length)
            {
               _loc22_ = _loc16_.join(".");
               try
               {
                  _loc18_ = getDefinitionByName(ignoreWhite(_loc22_));
                  _loc11_ = param1.length > _loc22_.length;
                  param1 = tempValue(param1,new ExeValue(_loc18_),0,_loc22_.length);
                  if(_loc11_)
                  {
                     _loc20_.lastIndex = 0;
                     _loc4_ = _loc20_.exec(param1);
                     break;
                  }
                  return execValue(param1);
               }
               catch(e:Error)
               {
                  _loc16_.pop();
               }
            }
         }
         var _loc19_:int = 0;
         while(_loc4_ != null)
         {
            _loc7_ = int(_loc4_.index);
            _loc8_ = param1.charAt(_loc7_) == "(";
            _loc23_ = ignoreWhite(param1.substring(_loc19_,_loc7_));
            _loc2_ = _loc19_ == 0 ? execValue(_loc23_,_loc17_.value) : new ExeValue(_loc17_.value,_loc23_);
            if(_loc8_)
            {
               _loc12_ = _loc2_.value;
               _loc14_ = param1.indexOf(")",_loc7_);
               _loc6_ = param1.substring(_loc7_ + 1,_loc14_);
               _loc6_ = ignoreWhite(_loc6_);
               _loc13_ = [];
               if(_loc6_)
               {
                  _loc13_ = execValue(_loc6_).value;
               }
               if(!(_loc12_ is Function))
               {
                  try
                  {
                     _loc21_ = [AS3];
                     for each(var _loc5_:Namespace in _loc21_)
                     {
                        _loc10_ = _loc17_.obj._loc5_::[_loc23_];
                        if(_loc10_ is Function)
                        {
                           _loc12_ = _loc10_;
                           break;
                        }
                     }
                  }
                  catch(e:Error)
                  {
                  }
                  if(!(_loc12_ is Function))
                  {
                     throw new Error(_loc23_ + " is not a function.");
                  }
               }
               _loc17_.obj = (_loc12_ as Function).apply(_loc17_.value,_loc13_);
               _loc17_.prop = null;
               _loc7_ = _loc14_ + 1;
            }
            else
            {
               _loc17_ = _loc2_;
            }
            _loc19_ = _loc7_ + 1;
            _loc20_.lastIndex = _loc7_ + 1;
            _loc4_ = _loc20_.exec(param1);
            if(_loc4_ == null)
            {
               if(_loc7_ + 1 < param1.length)
               {
                  _loc20_.lastIndex = param1.length;
                  _loc4_ = {"index":param1.length};
               }
            }
         }
         return _loc17_;
      }
      
      private function execValue(param1:String, param2:* = null) : ExeValue
      {
         var _loc3_:ExeValue = null;
         var _loc5_:String = null;
         var _loc4_:ExeValue = new ExeValue();
         if(param1 == "true")
         {
            _loc4_.obj = true;
         }
         else if(param1 == "false")
         {
            _loc4_.obj = false;
         }
         else if(param1 == "this")
         {
            _loc4_.obj = _scope;
         }
         else if(param1 == "null")
         {
            _loc4_.obj = null;
         }
         else if(!isNaN(Number(param1)))
         {
            _loc4_.obj = Number(param1);
         }
         else if(param1.indexOf("#") == 0)
         {
            _loc3_ = _values[param1.substring("#".length)];
            _loc4_.obj = _loc3_.value;
         }
         else if(param1.charAt(0) == "$")
         {
            _loc5_ = param1.substring(1);
            if(_reserved.indexOf(_loc5_) < 0)
            {
               _loc4_.obj = _saved;
               _loc4_.prop = _loc5_;
            }
            else if(_saved is WeakObject)
            {
               _loc4_.obj = WeakObject(_saved).get(_loc5_);
            }
            else
            {
               _loc4_.obj = _saved[_loc5_];
            }
         }
         else
         {
            try
            {
               _loc4_.obj = getDefinitionByName(param1);
            }
            catch(e:Error)
            {
               _loc4_.obj = param2;
               _loc4_.prop = param1;
            }
         }
         return _loc4_;
      }
      
      private function operate(param1:ExeValue, param2:String, param3:ExeValue) : *
      {
         switch(param2)
         {
            case "=":
               return param3.value;
            case "+":
               return param1.value + param3.value;
            case "-":
               return param1.value - param3.value;
            case "*":
               return param1.value * param3.value;
            case "/":
               return param1.value / param3.value;
            case "%":
               return param1.value % param3.value;
            case "^":
               return param1.value ^ param3.value;
            case "&":
               return param1.value & param3.value;
            case ">>":
               return param1.value >> param3.value;
            case ">>>":
               return param1.value >>> param3.value;
            case "<<":
               return param1.value << param3.value;
            case "~":
               return ~param3.value;
            case "|":
               return param1.value | param3.value;
            case "!":
               return !param3.value;
            case ">":
               return param1.value > param3.value;
            case ">=":
               return param1.value >= param3.value;
            case "<":
               return param1.value < param3.value;
            case "<=":
               return param1.value <= param3.value;
            case "||":
               return param1.value || param3.value;
            case "&&":
               return param1.value && param3.value;
            case "is":
               return param1.value is param3.value;
            case "typeof":
               return typeof param3.value;
            case "delete":
               return delete param3.obj[param3.prop];
            case "==":
               return param1.value == param3.value;
            case "===":
               return param1.value === param3.value;
            case "!=":
               return param1.value != param3.value;
            case "!==":
               return param1.value !== param3.value;
            default:
               return;
         }
      }
      
      private function makeNew(param1:String) : *
      {
         var _loc7_:int = 0;
         var _loc2_:String = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc8_:int = param1.indexOf("(");
         var _loc4_:String = _loc8_ > 0 ? param1.substring(0,_loc8_) : param1;
         _loc4_ = ignoreWhite(_loc4_);
         var _loc3_:* = execValue(_loc4_).value;
         if(_loc8_ > 0)
         {
            _loc7_ = param1.indexOf(")",_loc8_);
            _loc2_ = param1.substring(_loc8_ + 1,_loc7_);
            _loc2_ = ignoreWhite(_loc2_);
            _loc5_ = [];
            if(_loc2_)
            {
               _loc5_ = execValue(_loc2_).value;
            }
            _loc6_ = int(_loc5_.length);
            if(_loc6_ == 0)
            {
               return new _loc3_();
            }
            if(_loc6_ == 1)
            {
               return new _loc3_(_loc5_[0]);
            }
            if(_loc6_ == 2)
            {
               return new _loc3_(_loc5_[0],_loc5_[1]);
            }
            if(_loc6_ == 3)
            {
               return new _loc3_(_loc5_[0],_loc5_[1],_loc5_[2]);
            }
            if(_loc6_ == 4)
            {
               return new _loc3_(_loc5_[0],_loc5_[1],_loc5_[2],_loc5_[3]);
            }
            if(_loc6_ == 5)
            {
               return new _loc3_(_loc5_[0],_loc5_[1],_loc5_[2],_loc5_[3],_loc5_[4]);
            }
            if(_loc6_ == 6)
            {
               return new _loc3_(_loc5_[0],_loc5_[1],_loc5_[2],_loc5_[3],_loc5_[4],_loc5_[5]);
            }
            if(_loc6_ == 7)
            {
               return new _loc3_(_loc5_[0],_loc5_[1],_loc5_[2],_loc5_[3],_loc5_[4],_loc5_[5],_loc5_[6]);
            }
            if(_loc6_ == 8)
            {
               return new _loc3_(_loc5_[0],_loc5_[1],_loc5_[2],_loc5_[3],_loc5_[4],_loc5_[5],_loc5_[6],_loc5_[7]);
            }
            if(_loc6_ == 9)
            {
               return new _loc3_(_loc5_[0],_loc5_[1],_loc5_[2],_loc5_[3],_loc5_[4],_loc5_[5],_loc5_[6],_loc5_[7],_loc5_[8]);
            }
            if(_loc6_ == 10)
            {
               return new _loc3_(_loc5_[0],_loc5_[1],_loc5_[2],_loc5_[3],_loc5_[4],_loc5_[5],_loc5_[6],_loc5_[7],_loc5_[8],_loc5_[9]);
            }
            throw new Error("CommandLine can\'t create new class instances with more than 10 arguments.");
         }
         return null;
      }
      
      private function ignoreWhite(param1:String) : String
      {
         param1 = param1.replace(/\s*(.*)/,"$1");
         var _loc2_:int = param1.length - 1;
         while(_loc2_ > 0)
         {
            if(!param1.charAt(_loc2_).match(/\s/))
            {
               break;
            }
            param1 = param1.substring(0,_loc2_);
            _loc2_--;
         }
         return param1;
      }
   }
}

class ExeValue
{
   
   public var obj:*;
   
   public var prop:String;
   
   public function ExeValue(param1:Object = null, param2:String = null)
   {
      super();
      obj = param1;
      prop = param2;
   }
   
   public function get value() : *
   {
      return prop ? obj[prop] : obj;
   }
   
   public function setValue(param1:*) : void
   {
      if(prop)
      {
         obj[prop] = param1;
      }
      else
      {
         obj = param1;
      }
   }
}
