package com.wooduan.bytes.utils
{
   import com.adobe.crypto.MD5;
   import flash.utils.ByteArray;
   import wdnative.CModule;
   import wdnative.lobby_decoder.swfDecode;
   import wdnative.md5.getCTXsize;
   import wdnative.md5.md5Final;
   import wdnative.md5.md5FirstUpdate;
   import wdnative.md5.md5Init;
   import wdnative.md5.md5UpdateEnd;
   import wdnative.md5.md5UpdateLoop;
   
   public class ByteUtils
   {
      
      private static var cmoduleError:Boolean = false;
      
      private static var blockSize:int = 1024;
      
      private static var bufferPtr:int = 0;
      
      private static var md5Ptr:int = 0;
      
      public function ByteUtils()
      {
         super();
      }
      
      public static function decodeByte(param1:ByteArray) : ByteArray
      {
         var _loc3_:int = CModule.malloc(param1.length);
         param1.position = 0;
         CModule.writeBytes(_loc3_,param1.length,param1);
         swfDecode(_loc3_,param1.length);
         var _loc2_:ByteArray = new ByteArray();
         CModule.readBytes(_loc3_,param1.length,_loc2_);
         CModule.free(_loc3_);
         return _loc2_;
      }
      
      public static function encodeByte(param1:ByteArray) : ByteArray
      {
         var _loc3_:int = CModule.malloc(param1.length);
         param1.position = 0;
         CModule.writeBytes(_loc3_,param1.length,param1);
         swfDecode(_loc3_,param1.length);
         var _loc2_:ByteArray = new ByteArray();
         CModule.readBytes(_loc3_,param1.length,_loc2_);
         CModule.free(_loc3_);
         return _loc2_;
      }
      
      public static function hash(param1:String) : String
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         return hashBinary(_loc2_);
      }
      
      public static function hashBytes(param1:ByteArray) : String
      {
         return hashBinary(param1);
      }
      
      public static function hashBinary(param1:ByteArray) : String
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:String = null;
         if(!cmoduleError)
         {
            try
            {
               if(md5Ptr == 0)
               {
                  _loc3_ = getCTXsize();
                  md5Ptr = CModule.malloc(_loc3_ + blockSize);
                  if(md5Ptr == 0)
                  {
                     throw new Error("CModule.malloc error");
                  }
                  bufferPtr = md5Ptr + _loc3_;
               }
               param1.position = 0;
               _loc5_ = 0;
               md5Init(md5Ptr);
               while(param1.bytesAvailable > 0)
               {
                  _loc5_ = int(param1.position);
                  _loc4_ = int(param1.bytesAvailable);
                  if(_loc4_ > blockSize)
                  {
                     _loc4_ = blockSize;
                  }
                  CModule.writeBytes(bufferPtr,_loc4_,param1);
                  if(_loc5_ == 0)
                  {
                     md5FirstUpdate(md5Ptr,bufferPtr,param1.length);
                  }
                  md5UpdateLoop(md5Ptr,_loc5_,bufferPtr,_loc4_);
               }
               md5UpdateEnd(md5Ptr,_loc5_,bufferPtr,_loc4_);
               _loc2_ = md5Final(md5Ptr);
               param1.position = 0;
               return _loc2_;
            }
            catch(e:Error)
            {
               cmoduleError = true;
            }
         }
         if(cmoduleError)
         {
            return MD5.hashBinary(param1);
         }
         return "";
      }
   }
}

