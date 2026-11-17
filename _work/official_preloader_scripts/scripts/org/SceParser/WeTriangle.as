package org.SceParser
{
   import wdnative.*;
   
   public class WeTriangle
   {
      
      public var swigCPtr:int;
      
      public function WeTriangle()
      {
         super();
      }
      
      public static function create() : WeTriangle
      {
         var _loc1_:* = new WeTriangle();
         _loc1_.swigCPtr = _wrap_new_WeTriangle();
         return _loc1_;
      }
      
      public function set firstIndex(param1:int) : void
      {
         _wrap_WeTriangle_firstIndex_set(swigCPtr,param1);
      }
      
      public function get firstIndex() : int
      {
         return _wrap_WeTriangle_firstIndex_get(swigCPtr);
      }
      
      public function set secondIndex(param1:int) : void
      {
         _wrap_WeTriangle_secondIndex_set(swigCPtr,param1);
      }
      
      public function get secondIndex() : int
      {
         return _wrap_WeTriangle_secondIndex_get(swigCPtr);
      }
      
      public function set thirdIndex(param1:int) : void
      {
         _wrap_WeTriangle_thirdIndex_set(swigCPtr,param1);
      }
      
      public function get thirdIndex() : int
      {
         return _wrap_WeTriangle_thirdIndex_get(swigCPtr);
      }
      
      public function set shaderIndex(param1:int) : void
      {
         _wrap_WeTriangle_shaderIndex_set(swigCPtr,param1);
      }
      
      public function get shaderIndex() : int
      {
         return _wrap_WeTriangle_shaderIndex_get(swigCPtr);
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeTriangle(swigCPtr);
      }
   }
}

