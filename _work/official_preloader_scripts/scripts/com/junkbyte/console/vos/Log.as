package com.junkbyte.console.vos
{
   import flash.utils.ByteArray;
   
   public class Log
   {
      
      public var line:uint;
      
      public var text:String;
      
      public var ch:String;
      
      public var priority:int;
      
      public var repeat:Boolean;
      
      public var html:Boolean;
      
      public var time:uint;
      
      public var timeStr:String;
      
      public var lineStr:String;
      
      public var chStr:String;
      
      public var next:Log;
      
      public var prev:Log;
      
      public function Log(param1:String, param2:String, param3:int, param4:Boolean = false, param5:Boolean = false)
      {
         super();
         text = param1;
         ch = param2;
         priority = param3;
         repeat = param4;
         html = param5;
      }
      
      public static function FromBytes(param1:ByteArray) : Log
      {
         var _loc2_:String = param1.readUTFBytes(param1.readUnsignedInt());
         var _loc4_:String = param1.readUTF();
         var _loc5_:int = param1.readInt();
         var _loc3_:Boolean = param1.readBoolean();
         return new Log(_loc2_,_loc4_,_loc5_,_loc3_,true);
      }
      
      public function toBytes(param1:ByteArray) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(text);
         param1.writeUnsignedInt(_loc2_.length);
         param1.writeBytes(_loc2_);
         param1.writeUTF(ch);
         param1.writeInt(priority);
         param1.writeBoolean(repeat);
      }
      
      public function plainText() : String
      {
         return text.replace(/<.*?>/g,"").replace(/&lt;/g,"<").replace(/&gt;/g,">");
      }
      
      public function toString() : String
      {
         return "[" + ch + "] " + plainText();
      }
      
      public function clone() : Log
      {
         var _loc1_:Log = new Log(text,ch,priority,repeat,html);
         _loc1_.line = line;
         _loc1_.time = time;
         return _loc1_;
      }
   }
}

