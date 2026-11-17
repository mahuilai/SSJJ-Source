package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import flash.events.EventDispatcher;
   
   public class ConsoleCore extends EventDispatcher
   {
      
      protected var console:Console;
      
      protected var config:ConsoleConfig;
      
      public function ConsoleCore(param1:Console)
      {
         super();
         console = param1;
         config = console.config;
      }
      
      protected function get remoter() : Remoting
      {
         return console.remoter;
      }
      
      protected function report(param1:* = "", param2:int = 0, param3:Boolean = true, param4:String = null) : void
      {
         console.report(param1,param2,param3,param4);
      }
   }
}

