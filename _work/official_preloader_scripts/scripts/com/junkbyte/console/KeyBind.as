package com.junkbyte.console
{
   public class KeyBind
   {
      
      private var _code:Boolean;
      
      private var _key:String;
      
      public function KeyBind(param1:*, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false)
      {
         super();
         _key = String(param1).toUpperCase();
         if(param1 is uint)
         {
            _code = true;
         }
         else if(!param1 || _key.length != 1)
         {
            throw new Error("KeyBind: character (first char) must be a single character. You gave [" + param1 + "]");
         }
         if(_code)
         {
            _key = "keycode:" + _key;
         }
         if(param2)
         {
            _key += "+shift";
         }
         if(param3)
         {
            _key += "+ctrl";
         }
         if(param4)
         {
            _key += "+alt";
         }
         if(param5)
         {
            _key += "+up";
         }
      }
      
      public function get useKeyCode() : Boolean
      {
         return _code;
      }
      
      public function get key() : String
      {
         return _key;
      }
   }
}

