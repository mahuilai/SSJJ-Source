package org.SceParser
{
   import wdnative.*;
   
   public class WeSceHeader
   {
      
      public var swigCPtr:int;
      
      public function WeSceHeader()
      {
         super();
      }
      
      public static function create() : WeSceHeader
      {
         var _loc1_:* = new WeSceHeader();
         _loc1_.swigCPtr = _wrap_new_WeSceHeader();
         return _loc1_;
      }
      
      public function set version1(param1:int) : void
      {
         _wrap_WeSceHeader_version1_set(swigCPtr,param1);
      }
      
      public function get version1() : int
      {
         return _wrap_WeSceHeader_version1_get(swigCPtr);
      }
      
      public function set version2(param1:int) : void
      {
         _wrap_WeSceHeader_version2_set(swigCPtr,param1);
      }
      
      public function get version2() : int
      {
         return _wrap_WeSceHeader_version2_get(swigCPtr);
      }
      
      public function set maxVersion(param1:int) : void
      {
         _wrap_WeSceHeader_maxVersion_set(swigCPtr,param1);
      }
      
      public function get maxVersion() : int
      {
         return _wrap_WeSceHeader_maxVersion_get(swigCPtr);
      }
      
      public function set unityVersion(param1:int) : void
      {
         _wrap_WeSceHeader_unityVersion_set(swigCPtr,param1);
      }
      
      public function get unityVersion() : int
      {
         return _wrap_WeSceHeader_unityVersion_get(swigCPtr);
      }
      
      public function set flagIDFOffset(param1:int) : void
      {
         _wrap_WeSceHeader_flagIDFOffset_set(swigCPtr,param1);
      }
      
      public function get flagIDFOffset() : int
      {
         return _wrap_WeSceHeader_flagIDFOffset_get(swigCPtr);
      }
      
      public function set flagIDFCount(param1:int) : void
      {
         _wrap_WeSceHeader_flagIDFCount_set(swigCPtr,param1);
      }
      
      public function get flagIDFCount() : int
      {
         return _wrap_WeSceHeader_flagIDFCount_get(swigCPtr);
      }
      
      public function set flagIDFLen(param1:int) : void
      {
         _wrap_WeSceHeader_flagIDFLen_set(swigCPtr,param1);
      }
      
      public function get flagIDFLen() : int
      {
         return _wrap_WeSceHeader_flagIDFLen_get(swigCPtr);
      }
      
      public function set materialOffset(param1:int) : void
      {
         _wrap_WeSceHeader_materialOffset_set(swigCPtr,param1);
      }
      
      public function get materialOffset() : int
      {
         return _wrap_WeSceHeader_materialOffset_get(swigCPtr);
      }
      
      public function set materialCount(param1:int) : void
      {
         _wrap_WeSceHeader_materialCount_set(swigCPtr,param1);
      }
      
      public function get materialCount() : int
      {
         return _wrap_WeSceHeader_materialCount_get(swigCPtr);
      }
      
      public function set materialLen(param1:int) : void
      {
         _wrap_WeSceHeader_materialLen_set(swigCPtr,param1);
      }
      
      public function get materialLen() : int
      {
         return _wrap_WeSceHeader_materialLen_get(swigCPtr);
      }
      
      public function set textureOffset(param1:int) : void
      {
         _wrap_WeSceHeader_textureOffset_set(swigCPtr,param1);
      }
      
      public function get textureOffset() : int
      {
         return _wrap_WeSceHeader_textureOffset_get(swigCPtr);
      }
      
      public function set textureCount(param1:int) : void
      {
         _wrap_WeSceHeader_textureCount_set(swigCPtr,param1);
      }
      
      public function get textureCount() : int
      {
         return _wrap_WeSceHeader_textureCount_get(swigCPtr);
      }
      
      public function set textureLen(param1:int) : void
      {
         _wrap_WeSceHeader_textureLen_set(swigCPtr,param1);
      }
      
      public function get textureLen() : int
      {
         return _wrap_WeSceHeader_textureLen_get(swigCPtr);
      }
      
      public function set vertexOffset(param1:int) : void
      {
         _wrap_WeSceHeader_vertexOffset_set(swigCPtr,param1);
      }
      
      public function get vertexOffset() : int
      {
         return _wrap_WeSceHeader_vertexOffset_get(swigCPtr);
      }
      
      public function set vertexCount(param1:int) : void
      {
         _wrap_WeSceHeader_vertexCount_set(swigCPtr,param1);
      }
      
      public function get vertexCount() : int
      {
         return _wrap_WeSceHeader_vertexCount_get(swigCPtr);
      }
      
      public function set vertexLen(param1:int) : void
      {
         _wrap_WeSceHeader_vertexLen_set(swigCPtr,param1);
      }
      
      public function get vertexLen() : int
      {
         return _wrap_WeSceHeader_vertexLen_get(swigCPtr);
      }
      
      public function set polygonOffset(param1:int) : void
      {
         _wrap_WeSceHeader_polygonOffset_set(swigCPtr,param1);
      }
      
      public function get polygonOffset() : int
      {
         return _wrap_WeSceHeader_polygonOffset_get(swigCPtr);
      }
      
      public function set polyCount(param1:int) : void
      {
         _wrap_WeSceHeader_polyCount_set(swigCPtr,param1);
      }
      
      public function get polyCount() : int
      {
         return _wrap_WeSceHeader_polyCount_get(swigCPtr);
      }
      
      public function set polygonLen(param1:int) : void
      {
         _wrap_WeSceHeader_polygonLen_set(swigCPtr,param1);
      }
      
      public function get polygonLen() : int
      {
         return _wrap_WeSceHeader_polygonLen_get(swigCPtr);
      }
      
      public function set meshOffset(param1:int) : void
      {
         _wrap_WeSceHeader_meshOffset_set(swigCPtr,param1);
      }
      
      public function get meshOffset() : int
      {
         return _wrap_WeSceHeader_meshOffset_get(swigCPtr);
      }
      
      public function set meshCount(param1:int) : void
      {
         _wrap_WeSceHeader_meshCount_set(swigCPtr,param1);
      }
      
      public function get meshCount() : int
      {
         return _wrap_WeSceHeader_meshCount_get(swigCPtr);
      }
      
      public function set meshLen(param1:int) : void
      {
         _wrap_WeSceHeader_meshLen_set(swigCPtr,param1);
      }
      
      public function get meshLen() : int
      {
         return _wrap_WeSceHeader_meshLen_get(swigCPtr);
      }
      
      public function set uniqueOffset(param1:int) : void
      {
         _wrap_WeSceHeader_uniqueOffset_set(swigCPtr,param1);
      }
      
      public function get uniqueOffset() : int
      {
         return _wrap_WeSceHeader_uniqueOffset_get(swigCPtr);
      }
      
      public function set uniqueCount(param1:int) : void
      {
         _wrap_WeSceHeader_uniqueCount_set(swigCPtr,param1);
      }
      
      public function get uniqueCount() : int
      {
         return _wrap_WeSceHeader_uniqueCount_get(swigCPtr);
      }
      
      public function set uniqueLen(param1:int) : void
      {
         _wrap_WeSceHeader_uniqueLen_set(swigCPtr,param1);
      }
      
      public function get uniqueLen() : int
      {
         return _wrap_WeSceHeader_uniqueLen_get(swigCPtr);
      }
      
      public function set lightProbeOffset(param1:int) : void
      {
         _wrap_WeSceHeader_lightProbeOffset_set(swigCPtr,param1);
      }
      
      public function get lightProbeOffset() : int
      {
         return _wrap_WeSceHeader_lightProbeOffset_get(swigCPtr);
      }
      
      public function set lightProbeCount(param1:int) : void
      {
         _wrap_WeSceHeader_lightProbeCount_set(swigCPtr,param1);
      }
      
      public function get lightProbeCount() : int
      {
         return _wrap_WeSceHeader_lightProbeCount_get(swigCPtr);
      }
      
      public function set lightProbeLen(param1:int) : void
      {
         _wrap_WeSceHeader_lightProbeLen_set(swigCPtr,param1);
      }
      
      public function get lightProbeLen() : int
      {
         return _wrap_WeSceHeader_lightProbeLen_get(swigCPtr);
      }
      
      public function set pvsOffset(param1:int) : void
      {
         _wrap_WeSceHeader_pvsOffset_set(swigCPtr,param1);
      }
      
      public function get pvsOffset() : int
      {
         return _wrap_WeSceHeader_pvsOffset_get(swigCPtr);
      }
      
      public function set pvsCount(param1:int) : void
      {
         _wrap_WeSceHeader_pvsCount_set(swigCPtr,param1);
      }
      
      public function get pvsCount() : int
      {
         return _wrap_WeSceHeader_pvsCount_get(swigCPtr);
      }
      
      public function set pvsLen(param1:int) : void
      {
         _wrap_WeSceHeader_pvsLen_set(swigCPtr,param1);
      }
      
      public function get pvsLen() : int
      {
         return _wrap_WeSceHeader_pvsLen_get(swigCPtr);
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeSceHeader(swigCPtr);
      }
   }
}

