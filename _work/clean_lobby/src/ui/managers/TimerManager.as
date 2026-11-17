package ui.managers
{
   import flash.display.Shape;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class TimerManager
   {
      
      private var _shape:Shape = new Shape();
      
      private var _pool:Vector.<TimerHandler> = new Vector.<TimerHandler>();
      
      private var _handlers:Dictionary = new Dictionary();
      
      private var _currTimer:int = getTimer();
      
      private var _currFrame:int = 0;
      
      private var _count:int = 0;
      
      private var _index:uint = 0;
      
      public function TimerManager()
      {
         super();
         _shape.addEventListener("enterFrame",onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc6_:TimerHandler = null;
         var _loc2_:int = 0;
         var _loc4_:Function = null;
         var _loc3_:Array = null;
         _currFrame = _currFrame + 1;
         _currTimer = getTimer();
         for(var _loc5_ in _handlers)
         {
            _loc6_ = _handlers[_loc5_];
            _loc2_ = _loc6_.userFrame ? _currFrame : _currTimer;
            if(_loc2_ >= _loc6_.exeTime)
            {
               _loc4_ = _loc6_.method;
               _loc3_ = _loc6_.args;
               if(_loc6_.repeat)
               {
                  while(_loc2_ >= _loc6_.exeTime && _loc5_ in _handlers)
                  {
                     _loc6_.exeTime += _loc6_.delay;
                     _loc4_.apply(null,_loc3_);
                  }
               }
               else
               {
                  clearTimer(_loc5_);
                  _loc4_.apply(null,_loc3_);
               }
            }
         }
      }
      
      private function create(param1:Boolean, param2:Boolean, param3:int, param4:Function, param5:Array = null, param6:Boolean = true) : Object
      {
         var _loc7_:Object = null;
         if(param6)
         {
            clearTimer(param4);
            _loc7_ = param4;
         }
         else
         {
            _loc7_ = _index++;
         }
         if(param3 < 1)
         {
            param4.apply(null,param5);
            return -1;
         }
         var _loc8_:TimerHandler = _pool.length > 0 ? _pool.pop() : new TimerHandler();
         _loc8_.userFrame = param1;
         _loc8_.repeat = param2;
         _loc8_.delay = param3;
         _loc8_.method = param4;
         _loc8_.args = param5;
         _loc8_.exeTime = param3 + (param1 ? _currFrame : _currTimer);
         _handlers[_loc7_] = _loc8_;
         _count = _count + 1;
         return _loc7_;
      }
      
      public function doOnce(param1:int, param2:Function, param3:Array = null, param4:Boolean = true) : Object
      {
         return create(false,false,param1,param2,param3,param4);
      }
      
      public function doLoop(param1:int, param2:Function, param3:Array = null, param4:Boolean = true) : Object
      {
         return create(false,true,param1,param2,param3,param4);
      }
      
      public function doFrameOnce(param1:int, param2:Function, param3:Array = null, param4:Boolean = true) : Object
      {
         return create(true,false,param1,param2,param3,param4);
      }
      
      public function doFrameLoop(param1:int, param2:Function, param3:Array = null, param4:Boolean = true) : Object
      {
         return create(true,true,param1,param2,param3,param4);
      }
      
      public function get count() : int
      {
         return _count;
      }
      
      public function clearTimer(param1:Object) : void
      {
         var _loc2_:TimerHandler = _handlers[param1];
         if(_loc2_ != null)
         {
            delete _handlers[param1];
            _loc2_.clear();
            _pool.push(_loc2_);
            _count = _count - 1;
         }
      }
   }
}

class TimerHandler
{
   
   public var delay:int;
   
   public var repeat:Boolean;
   
   public var userFrame:Boolean;
   
   public var exeTime:int;
   
   public var method:Function;
   
   public var args:Array;
   
   public function TimerHandler()
   {
      super();
   }
   
   public function clear() : void
   {
      method = null;
      args = null;
   }
}
