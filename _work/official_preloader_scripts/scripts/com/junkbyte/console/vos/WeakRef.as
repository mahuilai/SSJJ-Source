package com.junkbyte.console.vos
{
   import flash.utils.Dictionary;
   
   public class WeakRef
   {
      
      private var _val:*;
      
      private var _strong:Boolean;
      
      public function WeakRef(param1:*, param2:Boolean = false)
      {
         super();
         _strong = param2;
         reference = param1;
      }
      
      public function get reference() : *
      {
         if(_strong)
         {
            return _val;
         }
         var _loc3_:int = 0;
         var _loc2_:* = _val;
         for(var _loc1_ in _loc2_)
         {
            return _loc1_;
         }
         return null;
      }
      
      public function set reference(param1:*) : void
      {
         if(_strong)
         {
            _val = param1;
         }
         else
         {
            _val = new Dictionary(true);
            _val[param1] = null;
         }
      }
      
      public function get strong() : Boolean
      {
         return _strong;
      }
   }
}

