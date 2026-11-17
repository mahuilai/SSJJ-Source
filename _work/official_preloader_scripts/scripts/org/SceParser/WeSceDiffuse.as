package org.SceParser
{
   import wdnative.*;
   
   public class WeSceDiffuse
   {
      
      public var swigCPtr:int;
      
      public function WeSceDiffuse()
      {
         super();
      }
      
      public static function create() : WeSceDiffuse
      {
         var _loc1_:* = new WeSceDiffuse();
         _loc1_.swigCPtr = _wrap_new_WeSceDiffuse();
         return _loc1_;
      }
      
      public function set color(param1:int) : void
      {
         _wrap_WeSceDiffuse_color_set(swigCPtr,param1);
      }
      
      public function get color() : int
      {
         return _wrap_WeSceDiffuse_color_get(swigCPtr);
      }
      
      public function set baseIndex(param1:int) : void
      {
         _wrap_WeSceDiffuse_baseIndex_set(swigCPtr,param1);
      }
      
      public function get baseIndex() : int
      {
         return _wrap_WeSceDiffuse_baseIndex_get(swigCPtr);
      }
      
      public function set baseTilingX(param1:Number) : void
      {
         _wrap_WeSceDiffuse_baseTilingX_set(swigCPtr,param1);
      }
      
      public function get baseTilingX() : Number
      {
         return _wrap_WeSceDiffuse_baseTilingX_get(swigCPtr);
      }
      
      public function set baseTilingY(param1:Number) : void
      {
         _wrap_WeSceDiffuse_baseTilingY_set(swigCPtr,param1);
      }
      
      public function get baseTilingY() : Number
      {
         return _wrap_WeSceDiffuse_baseTilingY_get(swigCPtr);
      }
      
      public function set baseOffsetX(param1:Number) : void
      {
         _wrap_WeSceDiffuse_baseOffsetX_set(swigCPtr,param1);
      }
      
      public function get baseOffsetX() : Number
      {
         return _wrap_WeSceDiffuse_baseOffsetX_get(swigCPtr);
      }
      
      public function set baseOffsetY(param1:Number) : void
      {
         _wrap_WeSceDiffuse_baseOffsetY_set(swigCPtr,param1);
      }
      
      public function get baseOffsetY() : Number
      {
         return _wrap_WeSceDiffuse_baseOffsetY_get(swigCPtr);
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeSceDiffuse(swigCPtr);
      }
   }
}

