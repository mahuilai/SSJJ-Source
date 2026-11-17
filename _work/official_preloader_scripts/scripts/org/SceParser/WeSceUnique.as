package org.SceParser
{
   import wdnative.*;
   
   public class WeSceUnique
   {
      
      public var swigCPtr:int;
      
      public function WeSceUnique()
      {
         super();
      }
      
      public static function create() : WeSceUnique
      {
         var _loc1_:* = new WeSceUnique();
         _loc1_.swigCPtr = _wrap_new_WeSceUnique();
         return _loc1_;
      }
      
      public function set minsx(param1:Number) : void
      {
         _wrap_WeSceUnique_minsx_set(swigCPtr,param1);
      }
      
      public function get minsx() : Number
      {
         return _wrap_WeSceUnique_minsx_get(swigCPtr);
      }
      
      public function set minsy(param1:Number) : void
      {
         _wrap_WeSceUnique_minsy_set(swigCPtr,param1);
      }
      
      public function get minsy() : Number
      {
         return _wrap_WeSceUnique_minsy_get(swigCPtr);
      }
      
      public function set minsz(param1:Number) : void
      {
         _wrap_WeSceUnique_minsz_set(swigCPtr,param1);
      }
      
      public function get minsz() : Number
      {
         return _wrap_WeSceUnique_minsz_get(swigCPtr);
      }
      
      public function set maxsx(param1:Number) : void
      {
         _wrap_WeSceUnique_maxsx_set(swigCPtr,param1);
      }
      
      public function get maxsx() : Number
      {
         return _wrap_WeSceUnique_maxsx_get(swigCPtr);
      }
      
      public function set maxsy(param1:Number) : void
      {
         _wrap_WeSceUnique_maxsy_set(swigCPtr,param1);
      }
      
      public function get maxsy() : Number
      {
         return _wrap_WeSceUnique_maxsy_get(swigCPtr);
      }
      
      public function set maxsz(param1:Number) : void
      {
         _wrap_WeSceUnique_maxsz_set(swigCPtr,param1);
      }
      
      public function get maxsz() : Number
      {
         return _wrap_WeSceUnique_maxsz_get(swigCPtr);
      }
      
      public function set lastNormalMesh(param1:int) : void
      {
         _wrap_WeSceUnique_lastNormalMesh_set(swigCPtr,param1);
      }
      
      public function get lastNormalMesh() : int
      {
         return _wrap_WeSceUnique_lastNormalMesh_get(swigCPtr);
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeSceUnique(swigCPtr);
      }
   }
}

