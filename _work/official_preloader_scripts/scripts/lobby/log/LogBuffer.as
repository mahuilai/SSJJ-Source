package lobby.log
{
   import flash.events.Event;
   import org.as3commons.logging.setup.ILogTarget;
   import org.as3commons.logging.util.LogMessageFormatter;
   
   public final class LogBuffer implements ILogTarget
   {
      
      private static const paramPattern:RegExp = /{\d}/g;
      
      private static const hallPackages:Array = ["lobby","globalRoom","loading","lobbyNet","template","tools","module","ui"];
      
      private static var _bufferList:Vector.<String> = new Vector.<String>();
      
      private const _formatter:LogMessageFormatter = new LogMessageFormatter("{logTime} {logLevel} {name} {message}");
      
      public function LogBuffer()
      {
         super();
      }
      
      public static function getLogString() : String
      {
         var _loc2_:int = 0;
         var _loc1_:String = new String();
         _loc2_ = 0;
         while(_loc2_ < _bufferList.length)
         {
            _loc1_ = _loc1_ + _bufferList[_loc2_] + "\n";
            _loc2_++;
         }
         _bufferList = new Vector.<String>();
         return _loc1_;
      }
      
      public function log(param1:String, param2:String, param3:int, param4:Number, param5:*, param6:Array, param7:String) : void
      {
         var _loc9_:Object = null;
         var _loc11_:Boolean = false;
         var _loc8_:int = 0;
         var _loc10_:String = null;
         param5 = _formatter.format(param1,param2,param3,param4,param5,null,param7);
         if(param5 is String)
         {
            _loc9_ = paramPattern.exec(param5);
            while(param6 && _loc9_ != null && param6.length > 0)
            {
               param5 = String(param5).replace(_loc9_[0],param6.shift());
               paramPattern.lastIndex -= 1;
               _loc9_ = paramPattern.exec(param5);
            }
         }
         if(param3 == 4 || param3 == 2)
         {
            _loc8_ = param1.indexOf(".");
            if(_loc8_ > -1)
            {
               _loc10_ = param1.slice(0,_loc8_);
               if(hallPackages.indexOf(_loc10_) > -1)
               {
                  _loc11_ = true;
               }
            }
            else
            {
               _loc11_ = true;
            }
            if(_loc11_)
            {
               if(param6 && param6.length > 0 && param6[0] is Error)
               {
                  PostLogUtil.postError(param6[0] as Error);
               }
               else
               {
                  PostLogUtil.postMsg(param5);
               }
            }
         }
         _bufferList.push(param5);
         if(_bufferList.length > 200)
         {
            _bufferList.shift();
         }
      }
      
      private function onSecurityError(param1:Event) : void
      {
      }
      
      private function onIOError(param1:Event) : void
      {
      }
      
      private function onSendComplete(param1:Event) : void
      {
      }
   }
}

