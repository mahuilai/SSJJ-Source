package org.SceParser
{
   import wdnative.*;
   
   public class WeSceSelfilluminDiffuse
   {
      
      public var swigCPtr:int;
      
      public function WeSceSelfilluminDiffuse()
      {
         super();
      }
      
      public static function create() : WeSceSelfilluminDiffuse
      {
         var _loc1_:* = new WeSceSelfilluminDiffuse();
         _loc1_.swigCPtr = _wrap_new_WeSceSelfilluminDiffuse();
         return _loc1_;
      }
      
      public function set color(param1:int) : void
      {
         _wrap_WeSceSelfilluminDiffuse_color_set(swigCPtr,param1);
      }
      
      public function get color() : int
      {
         return _wrap_WeSceSelfilluminDiffuse_color_get(swigCPtr);
      }
      
      public function set baseIndex(param1:int) : void
      {
         _wrap_WeSceSelfilluminDiffuse_baseIndex_set(swigCPtr,param1);
      }
      
      public function get baseIndex() : int
      {
         return _wrap_WeSceSelfilluminDiffuse_baseIndex_get(swigCPtr);
      }
      
      public function set baseTilingX(param1:Number) : void
      {
         _wrap_WeSceSelfilluminDiffuse_baseTilingX_set(swigCPtr,param1);
      }
      
      public function get baseTilingX() : Number
      {
         return _wrap_WeSceSelfilluminDiffuse_baseTilingX_get(swigCPtr);
      }
      
      public function set baseTilingY(param1:Number) : void
      {
         _wrap_WeSceSelfilluminDiffuse_baseTilingY_set(swigCPtr,param1);
      }
      
      public function get baseTilingY() : Number
      {
         return _wrap_WeSceSelfilluminDiffuse_baseTilingY_get(swigCPtr);
      }
      
      public function set baseOffsetX(param1:Number) : void
      {
         _wrap_WeSceSelfilluminDiffuse_baseOffsetX_set(swigCPtr,param1);
      }
      
      public function get baseOffsetX() : Number
      {
         return _wrap_WeSceSelfilluminDiffuse_baseOffsetX_get(swigCPtr);
      }
      
      public function set baseOffsetY(param1:Number) : void
      {
         _wrap_WeSceSelfilluminDiffuse_baseOffsetY_set(swigCPtr,param1);
      }
      
      public function get baseOffsetY() : Number
      {
         return _wrap_WeSceSelfilluminDiffuse_baseOffsetY_get(swigCPtr);
      }
      
      public function set illuminIndex(param1:int) : void
      {
         _wrap_WeSceSelfilluminDiffuse_illuminIndex_set(swigCPtr,param1);
      }
      
      public function get illuminIndex() : int
      {
         return _wrap_WeSceSelfilluminDiffuse_illuminIndex_get(swigCPtr);
      }
      
      public function set illuminTilingX(param1:Number) : void
      {
         _wrap_WeSceSelfilluminDiffuse_illuminTilingX_set(swigCPtr,param1);
      }
      
      public function get illuminTilingX() : Number
      {
         return _wrap_WeSceSelfilluminDiffuse_illuminTilingX_get(swigCPtr);
      }
      
      public function set illuminTilingY(param1:Number) : void
      {
         _wrap_WeSceSelfilluminDiffuse_illuminTilingY_set(swigCPtr,param1);
      }
      
      public function get illuminTilingY() : Number
      {
         return _wrap_WeSceSelfilluminDiffuse_illuminTilingY_get(swigCPtr);
      }
      
      public function set illuminOffsetX(param1:Number) : void
      {
         _wrap_WeSceSelfilluminDiffuse_illuminOffsetX_set(swigCPtr,param1);
      }
      
      public function get illuminOffsetX() : Number
      {
         return _wrap_WeSceSelfilluminDiffuse_illuminOffsetX_get(swigCPtr);
      }
      
      public function set illuminOffsetY(param1:Number) : void
      {
         _wrap_WeSceSelfilluminDiffuse_illuminOffsetY_set(swigCPtr,param1);
      }
      
      public function get illuminOffsetY() : Number
      {
         return _wrap_WeSceSelfilluminDiffuse_illuminOffsetY_get(swigCPtr);
      }
      
      public function set emission(param1:Number) : void
      {
         _wrap_WeSceSelfilluminDiffuse_emission_set(swigCPtr,param1);
      }
      
      public function get emission() : Number
      {
         return _wrap_WeSceSelfilluminDiffuse_emission_get(swigCPtr);
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeSceSelfilluminDiffuse(swigCPtr);
      }
   }
}

import flash.utils.Dictionary;

const §11§:*;
