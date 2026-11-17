package org.SceParser
{
   import wdnative.*;
   
   public class WeSceTexture
   {
      
      public var swigCPtr:int;
      
      public function WeSceTexture()
      {
         super();
      }
      
      public static function create() : WeSceTexture
      {
         var _loc1_:* = new WeSceTexture();
         _loc1_.swigCPtr = _wrap_new_WeSceTexture();
         return _loc1_;
      }
      
      public function set name(param1:String) : void
      {
         _wrap_WeSceTexture_name_set(swigCPtr,param1);
      }
      
      public function get name() : String
      {
         return _wrap_WeSceTexture_name_get(swigCPtr);
      }
      
      public function set wrap(param1:int) : void
      {
         _wrap_WeSceTexture_wrap_set(swigCPtr,param1);
      }
      
      public function get wrap() : int
      {
         return _wrap_WeSceTexture_wrap_get(swigCPtr);
      }
      
      public function set filter(param1:int) : void
      {
         _wrap_WeSceTexture_filter_set(swigCPtr,param1);
      }
      
      public function get filter() : int
      {
         return _wrap_WeSceTexture_filter_get(swigCPtr);
      }
      
      public function destroy() : void
      {
         _wrap_delete_WeSceTexture(swigCPtr);
      }
   }
}

