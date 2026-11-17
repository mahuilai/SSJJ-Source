package org.SceParser
{
   import wdnative.*;
   
   public class WeSceMesh
   {
      
      public var swigCPtr:int;
      
      public function WeSceMesh()
      {
         super();
      }
      
      public static function create() : WeSceMesh
      {
         var _loc1_:* = new WeSceMesh();
         _loc1_.swigCPtr = _wrap_new_WeSceMesh();
         return _loc1_;
      }
      
      public function set firstIndex(param1:int) : void
      {
         _wrap_WeSceMesh_firstIndex_set(swigCPtr,param1);
      }
      
      public function get firstIndex() : int
      {
         return _wrap_WeSceMesh_firstIndex_get(swigCPtr);
      }
      
      public function set nTriangle(param1:int) : void
      {
         _wrap_WeSceMesh_nTriangle_set(swigCPtr,param1);
      }
      
      public function get nTriangle() : int
      {
         return _wrap_WeSceMesh_nTriangle_get(swigCPtr);
      }
      
      public function set minsx(param1:Number) : void
      {
         _wrap_WeSceMesh_minsx_set(swigCPtr,param1);
      }
      
      public function get minsx() : Number
      {
         return _wrap_WeSceMesh_minsx_get(swigCPtr);
      }
      
      public function set minsy(param1:Number) : void
      {
         _wrap_WeSceMesh_minsy_set(swigCPtr,param1);
      }
      
      public function get minsy() : Number
      {
         return _wrap_WeSceMesh_minsy_get(swigCPtr);
      }
      
      public function set minsz(param1:Number) : void
      {
         _wrap_WeSceMesh_minsz_set(swigCPtr,param1);
      }
      
      public function get minsz() : Number
      {
         return _wrap_WeSceMesh_minsz_get(swigCPtr);
      }
      
      public function set maxsx(param1:Number) : void
      {
         _wrap_WeSceMesh_maxsx_set(swigCPtr,param1);
      }
      
      public function get maxsx() : Number
      {
         return _wrap_WeSceMesh_maxsx_get(swigCPtr);
      }
      
      public function set maxsy(param1:Number) : void
      {
         _wrap_WeSceMesh_maxsy_set(swigCPtr,param1);
      }
      
      public function get maxsy() : Number
      {
         return _wrap_WeSceMesh_maxsy_get(swigCPtr);
      }
      
      public function set maxsz(param1:Number) : void
      {
         _wrap_WeSceMesh_maxsz_set(swigCPtr,param1);
      }
      
      public function get maxsz() : Number
      {
         return _wrap_WeSceMesh_maxsz_get(swigCPtr);
      }
      
      public function set contents(param1:int) : void
      {
         _wrap_WeSceMesh_contents_set(swigCPtr,param1);
      }
      
      public function get contents() : int
      {
         return _wrap_WeSceMesh_contents_get(swigCPtr);
      }
      
      public function set sceneFlag(param1:int) : void
      {
         _wrap_WeSceMesh_sceneFlag_set(swigCPtr,param1);
      }
      
      public function get sceneFlag() : int
      {
         return _wrap_WeSceMesh_sceneFlag_get(swigCPtr);
      }
      
      public function set name(param1:int) : void
      {
         _wrap_WeSceMesh_name_set(swigCPtr,param1);
      }
      
      public function get name() : int
      {
         return _wrap_WeSceMesh_name_get(swigCPtr);
      }
      
      public function getName() : String
      {
         return _wrap_WeSceMesh_getName(swigCPtr);
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeSceMesh(swigCPtr);
      }
   }
}

