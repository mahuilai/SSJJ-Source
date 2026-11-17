package com.junkbyte.console.addons.htmlexport
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.vos.Log;
   import flash.utils.describeType;
   
   public class ConsoleHTMLRefsGen
   {
      
      private static const refSearchExpression:RegExp = /<a(\s+)href=\'event:ref_(\d+)\'>/g;
      
      private var console:Console;
      
      private var referencesDepth:uint;
      
      private var referencesMap:Object;
      
      public function ConsoleHTMLRefsGen(param1:Console, param2:uint)
      {
         super();
         this.console = param1;
         this.referencesDepth = param2;
      }
      
      public function fillData(param1:Object) : void
      {
         referencesMap = {};
         param1.references = referencesMap;
         var _loc2_:Log = console.logs.last;
         while(_loc2_)
         {
            processRefIdsFromLine(_loc2_.text);
            _loc2_ = _loc2_.prev;
         }
      }
      
      private function processRefIdsFromLine(param1:String, param2:uint = 0) : void
      {
         var _loc3_:* = 0;
         refSearchExpression.lastIndex = 0;
         var _loc4_:Object = refSearchExpression.exec(param1);
         while(_loc4_ != null)
         {
            _loc3_ = uint(_loc4_[2]);
            processRefId(_loc3_,param2);
            _loc4_ = refSearchExpression.exec(param1);
         }
      }
      
      private function processRefId(param1:uint, param2:uint) : void
      {
         var _loc3_:* = console.refs.getRefById(param1);
         if(_loc3_ != null && referencesMap[param1] == null)
         {
            referencesMap[param1] = processRef(_loc3_,param2);
         }
      }
      
      private function processRef(param1:Object, param2:uint) : Object
      {
         var _loc19_:Boolean = false;
         var _loc16_:Object = null;
         var _loc14_:XML = describeType(param1);
         var _loc6_:Object = param1 is Class ? param1 : param1.constructor;
         var _loc3_:XML = describeType(_loc6_);
         var _loc7_:Boolean = param1 is Class;
         var _loc4_:Object = {};
         _loc4_.name = LogReferences.EscHTML(_loc14_.@name);
         var _loc9_:Object = {};
         _loc4_.constants = _loc9_;
         for each(var _loc15_:XML in _loc3_..constant)
         {
            _loc9_[_loc15_.@name.toString()] = makeValue(_loc6_,_loc15_.@name.toString(),param2);
         }
         var _loc12_:Object = {};
         _loc4_.accessors = _loc12_;
         var _loc5_:Object = {};
         _loc4_.staticAccessors = _loc5_;
         for each(var _loc11_:XML in _loc3_..accessor)
         {
            _loc19_ = _loc11_.parent().name() != "factory";
            _loc16_ = _loc19_ ? _loc5_ : _loc12_;
            if(_loc11_.@access.toString() != "writeonly" && (_loc19_ || !_loc7_))
            {
               _loc16_[_loc11_.@name] = makeValue(_loc19_ ? _loc6_ : param1,_loc11_.@name.toString(),param2);
            }
         }
         var _loc13_:Object = {};
         _loc4_.variables = _loc13_;
         var _loc10_:Object = {};
         _loc4_.staticVariables = _loc10_;
         for each(var _loc8_:XML in _loc3_..variable)
         {
            _loc19_ = _loc8_.parent().name() != "factory";
            _loc16_ = _loc19_ ? _loc10_ : _loc13_;
            _loc16_[_loc8_.@name] = makeValue(_loc19_ ? _loc6_ : param1,_loc8_.@name.toString(),param2);
         }
         var _loc18_:Object = {};
         _loc4_.dynamicVariables = _loc18_;
         try
         {
            for(var _loc17_ in param1)
            {
               _loc18_[_loc17_] = makeValue(param1,_loc17_,param2);
            }
         }
         catch(e:Error)
         {
            _loc4_.dynamicVariables = e.message;
         }
         return _loc4_;
      }
      
      private function makeValue(param1:*, param2:*, param3:uint) : String
      {
         var _loc4_:* = undefined;
         try
         {
            _loc4_ = param1[param2];
         }
         catch(err:Error)
         {
            return "<p0><i>" + err.toString() + "</i></p0>";
         }
         var _loc5_:String = console.refs.makeString(_loc4_,null,true);
         if(param3 < referencesDepth)
         {
            param3++;
            processRefIdsFromLine(_loc5_,param3);
         }
         return _loc5_;
      }
   }
}

