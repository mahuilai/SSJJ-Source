package org.SceParser
{
   import wdnative.*;
   
   public class WeSceLoadFlag
   {
      
      public var swigCPtr:int;
      
      public function WeSceLoadFlag()
      {
         super();
      }
      
      public static function get LOAD_MESH_EXT() : int
      {
         return _wrap_LOAD_MESH_EXT();
      }
      
      public static function get LOAD_VERT_EXT() : int
      {
         return _wrap_LOAD_VERT_EXT();
      }
      
      public static function get LOAD_MATERIAL() : int
      {
         return _wrap_LOAD_MATERIAL();
      }
      
      public static function get LOAD_MAT_EXT() : int
      {
         return _wrap_LOAD_MAT_EXT();
      }
      
      public static function get LOAD_TEXTURE() : int
      {
         return _wrap_LOAD_TEXTURE();
      }
      
      public static function get LOAD_UNIQUE() : int
      {
         return _wrap_LOAD_UNIQUE();
      }
      
      public static function get LOAD_LIGHTPROBE() : int
      {
         return _wrap_LOAD_LIGHTPROBE();
      }
      
      public static function get LOAD_PVS() : int
      {
         return _wrap_LOAD_PVS();
      }
      
      public static function get LOAD_PHYSICS() : int
      {
         return _wrap_LOAD_PHYSICS();
      }
      
      public static function get LOAD_SERVER() : int
      {
         return _wrap_LOAD_SERVER();
      }
      
      public static function get LOAD_LOGIC() : int
      {
         return _wrap_LOAD_LOGIC();
      }
      
      public static function get LOAD_RENDER() : int
      {
         return _wrap_LOAD_RENDER();
      }
      
      public static function create() : WeSceLoadFlag
      {
         var _loc1_:* = new WeSceLoadFlag();
         _loc1_.swigCPtr = _wrap_new_WeSceLoadFlag();
         return _loc1_;
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeSceLoadFlag(swigCPtr);
      }
   }
}

