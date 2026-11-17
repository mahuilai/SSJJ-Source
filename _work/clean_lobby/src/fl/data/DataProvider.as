package fl.data
{
   import fl.events.DataChangeEvent;
   import flash.events.EventDispatcher;
   
   public class DataProvider extends EventDispatcher
   {
      
      protected var data:Array;
      
      public function DataProvider(param1:Object = null)
      {
         super();
         if(param1 == null)
         {
            data = [];
         }
         else
         {
            data = getDataFromObject(param1);
         }
      }
      
      public function get length() : uint
      {
         return data.length;
      }
      
      public function invalidateItemAt(param1:int) : void
      {
         checkIndex(param1,data.length - 1);
         dispatchChangeEvent("invalidate",[data[param1]],param1,param1);
      }
      
      public function invalidateItem(param1:Object) : void
      {
         var _loc2_:uint = uint(getItemIndex(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         invalidateItemAt(_loc2_);
      }
      
      public function invalidate() : void
      {
         dispatchEvent(new DataChangeEvent("dataChange","invalidateAll",data.concat(),0,data.length));
      }
      
      public function addItemAt(param1:Object, param2:uint) : void
      {
         checkIndex(param2,data.length);
         dispatchPreChangeEvent("add",[param1],param2,param2);
         data.splice(param2,0,param1);
         dispatchChangeEvent("add",[param1],param2,param2);
      }
      
      public function addItem(param1:Object) : void
      {
         dispatchPreChangeEvent("add",[param1],data.length - 1,data.length - 1);
         data.push(param1);
         dispatchChangeEvent("add",[param1],data.length - 1,data.length - 1);
      }
      
      public function addItemsAt(param1:Object, param2:uint) : void
      {
         checkIndex(param2,data.length);
         var _loc3_:Array = getDataFromObject(param1);
         dispatchPreChangeEvent("add",_loc3_,param2,param2 + _loc3_.length - 1);
         data.splice.apply(data,[param2,0].concat(_loc3_));
         dispatchChangeEvent("add",_loc3_,param2,param2 + _loc3_.length - 1);
      }
      
      public function addItems(param1:Object) : void
      {
         addItemsAt(param1,data.length);
      }
      
      public function concat(param1:Object) : void
      {
         addItems(param1);
      }
      
      public function merge(param1:Object) : void
      {
         var _loc6_:* = 0;
         var _loc4_:Object = null;
         var _loc3_:Array = getDataFromObject(param1);
         var _loc5_:uint = _loc3_.length;
         var _loc2_:uint = data.length;
         dispatchPreChangeEvent("add",data.slice(_loc2_,data.length),_loc2_,this.data.length - 1);
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            _loc4_ = _loc3_[_loc6_];
            if(getItemIndex(_loc4_) == -1)
            {
               data.push(_loc4_);
            }
            _loc6_++;
         }
         if(data.length > _loc2_)
         {
            dispatchChangeEvent("add",data.slice(_loc2_,data.length),_loc2_,this.data.length - 1);
         }
         else
         {
            dispatchChangeEvent("add",[],-1,-1);
         }
      }
      
      public function getItemAt(param1:uint) : Object
      {
         checkIndex(param1,data.length - 1);
         return data[param1];
      }
      
      public function getItemIndex(param1:Object) : int
      {
         return data.indexOf(param1);
      }
      
      public function removeItemAt(param1:uint) : Object
      {
         checkIndex(param1,data.length - 1);
         dispatchPreChangeEvent("remove",data.slice(param1,param1 + 1),param1,param1);
         var _loc2_:Array = data.splice(param1,1);
         dispatchChangeEvent("remove",_loc2_,param1,param1);
         return _loc2_[0];
      }
      
      public function removeItem(param1:Object) : Object
      {
         var _loc2_:int = getItemIndex(param1);
         if(_loc2_ != -1)
         {
            return removeItemAt(_loc2_);
         }
         return null;
      }
      
      public function removeAll() : void
      {
         var _loc1_:Array = data.concat();
         dispatchPreChangeEvent("removeAll",_loc1_,0,_loc1_.length);
         data = [];
         dispatchChangeEvent("removeAll",_loc1_,0,_loc1_.length);
      }
      
      public function replaceItem(param1:Object, param2:Object) : Object
      {
         var _loc3_:int = getItemIndex(param2);
         if(_loc3_ != -1)
         {
            return replaceItemAt(param1,_loc3_);
         }
         return null;
      }
      
      public function replaceItemAt(param1:Object, param2:uint) : Object
      {
         checkIndex(param2,data.length - 1);
         var _loc3_:Array = [data[param2]];
         dispatchPreChangeEvent("replace",_loc3_,param2,param2);
         data[param2] = param1;
         dispatchChangeEvent("replace",_loc3_,param2,param2);
         return _loc3_[0];
      }
      
      public function sort(... rest) : *
      {
         dispatchPreChangeEvent("sort",data.concat(),0,data.length - 1);
         var _loc2_:Array = data.sort.apply(data,rest);
         dispatchChangeEvent("sort",data.concat(),0,data.length - 1);
         return _loc2_;
      }
      
      public function sortOn(param1:Object, param2:Object = null) : *
      {
         dispatchPreChangeEvent("sort",data.concat(),0,data.length - 1);
         var _loc3_:Array = data.sortOn(param1,param2);
         dispatchChangeEvent("sort",data.concat(),0,data.length - 1);
         return _loc3_;
      }
      
      public function clone() : DataProvider
      {
         return new DataProvider(data);
      }
      
      public function toArray() : Array
      {
         return data.concat();
      }
      
      override public function toString() : String
      {
         return "DataProvider [" + data.join(" , ") + "]";
      }
      
      protected function getDataFromObject(param1:Object) : Array
      {
         var _loc3_:Array = null;
         var _loc5_:Array = null;
         var _loc12_:* = 0;
         var _loc9_:Object = null;
         var _loc11_:XML = null;
         var _loc7_:XMLList = null;
         var _loc6_:XMLList = null;
         var _loc8_:XMLList = null;
         if(param1 is Array)
         {
            _loc5_ = param1 as Array;
            if(_loc5_.length > 0)
            {
               if(_loc5_[0] is String || _loc5_[0] is Number)
               {
                  _loc3_ = [];
                  _loc12_ = 0;
                  while(_loc12_ < _loc5_.length)
                  {
                     _loc9_ = {
                        "label":String(_loc5_[_loc12_]),
                        "data":_loc5_[_loc12_]
                     };
                     _loc3_.push(_loc9_);
                     _loc12_++;
                  }
                  return _loc3_;
               }
            }
            return param1.concat();
         }
         if(param1 is DataProvider)
         {
            return param1.toArray();
         }
         if(param1 is XML)
         {
            _loc11_ = param1 as XML;
            _loc3_ = [];
            _loc7_ = _loc11_.*;
            for each(var _loc2_ in _loc7_)
            {
               param1 = {};
               _loc6_ = _loc2_.attributes();
               for each(var _loc10_ in _loc6_)
               {
                  param1[_loc10_.localName()] = _loc10_.toString();
               }
               _loc8_ = _loc2_.*;
               for each(var _loc4_ in _loc8_)
               {
                  if(_loc4_.hasSimpleContent())
                  {
                     param1[_loc4_.localName()] = _loc4_.toString();
                  }
               }
               _loc3_.push(param1);
            }
            return _loc3_;
         }
         throw new TypeError("Error: Type Coercion failed: cannot convert " + param1 + " to Array or DataProvider.");
      }
      
      protected function checkIndex(param1:int, param2:int) : void
      {
         if(param1 > param2 || param1 < 0)
         {
            throw new RangeError("DataProvider index (" + param1 + ") is not in acceptable range (0 - " + param2 + ")");
         }
      }
      
      protected function dispatchChangeEvent(param1:String, param2:Array, param3:int, param4:int) : void
      {
         dispatchEvent(new DataChangeEvent("dataChange",param1,param2,param3,param4));
      }
      
      protected function dispatchPreChangeEvent(param1:String, param2:Array, param3:int, param4:int) : void
      {
         dispatchEvent(new DataChangeEvent("preDataChange",param1,param2,param3,param4));
      }
   }
}

