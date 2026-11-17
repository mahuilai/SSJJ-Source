package org.SceParser
{
   import wdnative.*;
   
   public class WeSceMaterial
   {
      
      public var swigCPtr:int;
      
      public function WeSceMaterial()
      {
         super();
      }
      
      public static function create() : WeSceMaterial
      {
         var _loc1_:* = new WeSceMaterial();
         _loc1_.swigCPtr = _wrap_new_WeSceMaterial();
         return _loc1_;
      }
      
      public function set surfaceFlag(param1:int) : void
      {
         _wrap_WeSceMaterial_surfaceFlag_set(swigCPtr,param1);
      }
      
      public function get surfaceFlag() : int
      {
         return _wrap_WeSceMaterial_surfaceFlag_get(swigCPtr);
      }
      
      public function set shadowIndex(param1:int) : void
      {
         _wrap_WeSceMaterial_shadowIndex_set(swigCPtr,param1);
      }
      
      public function get shadowIndex() : int
      {
         return _wrap_WeSceMaterial_shadowIndex_get(swigCPtr);
      }
      
      public function set meshIndex(param1:int) : void
      {
         _wrap_WeSceMaterial_meshIndex_set(swigCPtr,param1);
      }
      
      public function get meshIndex() : int
      {
         return _wrap_WeSceMaterial_meshIndex_get(swigCPtr);
      }
      
      public function set name(param1:String) : void
      {
         _wrap_WeSceMaterial_name_set(swigCPtr,param1);
      }
      
      public function get name() : String
      {
         return _wrap_WeSceMaterial_name_get(swigCPtr);
      }
      
      public function set shaderName(param1:String) : void
      {
         _wrap_WeSceMaterial_shaderName_set(swigCPtr,param1);
      }
      
      public function get shaderName() : String
      {
         return _wrap_WeSceMaterial_shaderName_get(swigCPtr);
      }
      
      public function set data(param1:int) : void
      {
         _wrap_WeSceMaterial_data_set(swigCPtr,param1);
      }
      
      public function get data() : int
      {
         return _wrap_WeSceMaterial_data_get(swigCPtr);
      }
      
      public function set dataLen(param1:int) : void
      {
         _wrap_WeSceMaterial_dataLen_set(swigCPtr,param1);
      }
      
      public function get dataLen() : int
      {
         return _wrap_WeSceMaterial_dataLen_get(swigCPtr);
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeSceMaterial(swigCPtr);
      }
   }
}

