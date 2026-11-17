package ui.managers
{
   import flash.events.Event;
   import flash.utils.Dictionary;
   import ui.core.UICommon;
   
   public class EnterFrameManager
   {
      
      private static var _instance:EnterFrameManager;
      
      private var _handlers:Dictionary = new Dictionary();
      
      public function EnterFrameManager()
      {
         super();
         UICommon.stage.addEventListener("enterFrame",onEnterFrame);
      }
      
      public static function getInstance() : EnterFrameManager
      {
         if(null == _instance)
         {
            _instance = new EnterFrameManager();
         }
         return _instance;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Object = null;
         for(var _loc3_ in this._handlers)
         {
            _loc2_ = this._handlers[_loc3_];
            _loc3_.apply(null,_loc2_);
            delete this._handlers[_loc3_];
         }
      }
      
      public function frameCall(param1:Function, param2:Array) : void
      {
         if(null == this._handlers[param1])
         {
            this._handlers[param1] = param2;
         }
      }
   }
}

