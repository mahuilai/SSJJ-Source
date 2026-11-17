package org.SceParser
{
   import wdnative.*;
   
   public class WeVertexExt
   {
      
      public var swigCPtr:int;
      
      public function WeVertexExt()
      {
         super();
      }
      
      public static function create() : WeVertexExt
      {
         var _loc1_:* = new WeVertexExt();
         _loc1_.swigCPtr = _wrap_new_WeVertexExt();
         return _loc1_;
      }
      
      public function set index(param1:int) : void
      {
         _wrap_WeVertexExt_index_set(swigCPtr,param1);
      }
      
      public function get index() : int
      {
         return _wrap_WeVertexExt_index_get(swigCPtr);
      }
      
      public function set vx(param1:Number) : void
      {
         _wrap_WeVertexExt_vx_set(swigCPtr,param1);
      }
      
      public function get vx() : Number
      {
         return _wrap_WeVertexExt_vx_get(swigCPtr);
      }
      
      public function set vy(param1:Number) : void
      {
         _wrap_WeVertexExt_vy_set(swigCPtr,param1);
      }
      
      public function get vy() : Number
      {
         return _wrap_WeVertexExt_vy_get(swigCPtr);
      }
      
      public function set vz(param1:Number) : void
      {
         _wrap_WeVertexExt_vz_set(swigCPtr,param1);
      }
      
      public function get vz() : Number
      {
         return _wrap_WeVertexExt_vz_get(swigCPtr);
      }
      
      public function set u1(param1:Number) : void
      {
         _wrap_WeVertexExt_u1_set(swigCPtr,param1);
      }
      
      public function get u1() : Number
      {
         return _wrap_WeVertexExt_u1_get(swigCPtr);
      }
      
      public function set v1(param1:Number) : void
      {
         _wrap_WeVertexExt_v1_set(swigCPtr,param1);
      }
      
      public function get v1() : Number
      {
         return _wrap_WeVertexExt_v1_get(swigCPtr);
      }
      
      public function set u2(param1:Number) : void
      {
         _wrap_WeVertexExt_u2_set(swigCPtr,param1);
      }
      
      public function get u2() : Number
      {
         return _wrap_WeVertexExt_u2_get(swigCPtr);
      }
      
      public function set v2(param1:Number) : void
      {
         _wrap_WeVertexExt_v2_set(swigCPtr,param1);
      }
      
      public function get v2() : Number
      {
         return _wrap_WeVertexExt_v2_get(swigCPtr);
      }
      
      public function set normalx(param1:Number) : void
      {
         _wrap_WeVertexExt_normalx_set(swigCPtr,param1);
      }
      
      public function get normalx() : Number
      {
         return _wrap_WeVertexExt_normalx_get(swigCPtr);
      }
      
      public function set normaly(param1:Number) : void
      {
         _wrap_WeVertexExt_normaly_set(swigCPtr,param1);
      }
      
      public function get normaly() : Number
      {
         return _wrap_WeVertexExt_normaly_get(swigCPtr);
      }
      
      public function set normalz(param1:Number) : void
      {
         _wrap_WeVertexExt_normalz_set(swigCPtr,param1);
      }
      
      public function get normalz() : Number
      {
         return _wrap_WeVertexExt_normalz_get(swigCPtr);
      }
      
      public function set tangentx(param1:Number) : void
      {
         _wrap_WeVertexExt_tangentx_set(swigCPtr,param1);
      }
      
      public function get tangentx() : Number
      {
         return _wrap_WeVertexExt_tangentx_get(swigCPtr);
      }
      
      public function set tangenty(param1:Number) : void
      {
         _wrap_WeVertexExt_tangenty_set(swigCPtr,param1);
      }
      
      public function get tangenty() : Number
      {
         return _wrap_WeVertexExt_tangenty_get(swigCPtr);
      }
      
      public function set tangentz(param1:Number) : void
      {
         _wrap_WeVertexExt_tangentz_set(swigCPtr,param1);
      }
      
      public function get tangentz() : Number
      {
         return _wrap_WeVertexExt_tangentz_get(swigCPtr);
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeVertexExt(swigCPtr);
      }
   }
}

