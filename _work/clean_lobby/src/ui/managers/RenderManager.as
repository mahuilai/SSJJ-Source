package ui.managers
{
   import flash.events.Event;
   import flash.utils.Dictionary;
   import ui.core.UICommon;
   
   public class RenderManager
   {
      
      private var _methods:Dictionary = new Dictionary();
      
      public function RenderManager()
      {
         super();
      }
      
      private function invalidate() : void
      {
         if(UICommon.stage != null) {
            UICommon.stage.addEventListener("render",onValidate);
            UICommon.stage.addEventListener("enterFrame",onValidate);
            UICommon.stage.invalidate();
         } else {
            renderAll();
            return;
         }

      }
      
      private function onValidate(param1:Event) : void
      {
         if(UICommon.stage != null) {
            UICommon.stage.removeEventListener("render",onValidate);
            UICommon.stage.removeEventListener("enterFrame",onValidate);
         }
         
         renderAll();
      }
      
      public function renderAll() : void
      {
         for(var _loc1_ in _methods)
         {
            exeCallLater(_loc1_ as Function);
         }
      }
      
      public function callLater(param1:Function, param2:Array = null) : void
      {
         if(_methods[param1] == null)
         {
            _methods[param1] = param2 || [];
            invalidate();
         }
      }
      
      public function exeCallLater(param1:Function) : void
      {
         var _loc2_:Array = null;
         if(_methods[param1] != null)
         {
            _loc2_ = _methods[param1];
            delete _methods[param1];
            param1.apply(null,_loc2_);
         }
      }
   }
}

