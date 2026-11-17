package com.junkbyte.console.vos
{
   import com.junkbyte.console.core.Executer;
   import flash.utils.ByteArray;
   
   public class GraphInterest
   {
      
      private var _ref:WeakRef;
      
      public var _prop:String;
      
      private var useExec:Boolean;
      
      public var key:String;
      
      public var col:Number;
      
      public var v:Number;
      
      public var avg:Number;
      
      public function GraphInterest(param1:String = "", param2:Number = 0)
      {
         super();
         col = param2;
         key = param1;
      }
      
      public static function FromBytes(param1:ByteArray) : GraphInterest
      {
         var _loc2_:GraphInterest = new GraphInterest(param1.readUTF(),param1.readUnsignedInt());
         _loc2_.v = param1.readDouble();
         _loc2_.avg = param1.readDouble();
         return _loc2_;
      }
      
      public function setObject(param1:Object, param2:String) : Number
      {
         _ref = new WeakRef(param1);
         _prop = param2;
         useExec = _prop.search(/[^\w\d]/) >= 0;
         v = getCurrentValue();
         avg = v;
         return v;
      }
      
      public function get obj() : Object
      {
         return _ref != null ? _ref.reference : undefined;
      }
      
      public function get prop() : String
      {
         return _prop;
      }
      
      public function getCurrentValue() : Number
      {
         return useExec ? Executer.Exec(obj,_prop) : obj[_prop];
      }
      
      public function setValue(param1:Number, param2:uint = 0) : void
      {
         v = param1;
         if(param2 > 0)
         {
            if(isNaN(avg))
            {
               avg = v;
            }
            else
            {
               avg += (v - avg) / param2;
            }
         }
      }
      
      public function toBytes(param1:ByteArray) : void
      {
         param1.writeUTF(key);
         param1.writeUnsignedInt(col);
         param1.writeDouble(v);
         param1.writeDouble(avg);
      }
   }
}

