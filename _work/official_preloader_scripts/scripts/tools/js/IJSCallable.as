package tools.js
{
   public interface IJSCallable
   {
      
      function call(param1:String, param2:String) : void;
      
      function addCallback(param1:String, param2:Function) : void;
      
      function removeCallback(param1:Array) : void;
   }
}

