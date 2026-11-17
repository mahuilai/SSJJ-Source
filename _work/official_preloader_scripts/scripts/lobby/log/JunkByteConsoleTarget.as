package lobby.log
{
   import com.junkbyte.console.Cc;
   import org.as3commons.logging.setup.target.IFormattingLogTarget;
   import org.as3commons.logging.util.LogMessageFormatter;
   
   public final class JunkByteConsoleTarget implements IFormattingLogTarget
   {
      
      private static const DEFAULT_FORMAT:String = "[{time}] [{shortName}]{atPerson} {message}";
      
      private static const paramPattern:RegExp = /{\d}/g;
      
      private var _formatter:LogMessageFormatter;
      
      public function JunkByteConsoleTarget(param1:String = null)
      {
         super();
         this.format = param1;
      }
      
      public function set format(param1:String) : void
      {
         _formatter = new LogMessageFormatter(param1 || "[{time}] [{shortName}]{atPerson} {message}");
      }
      
      public function log(param1:String, param2:String, param3:int, param4:Number, param5:*, param6:Array, param7:String) : void
      {
         var _loc9_:int = 0;
         var _loc8_:Object = null;
         param5 = _formatter.format(param1,param2,param3,param4,param5,null,null);
         if(param6)
         {
            param6 = param6.concat();
         }
         if(param5 is String)
         {
            _loc9_ = 0;
            _loc8_ = paramPattern.exec(param5);
            while(param6 != null && _loc8_ != null && param6.length > 0)
            {
               param5 = String(param5).replace(_loc8_[0],param6.shift());
               paramPattern.lastIndex -= 1;
               _loc8_ = paramPattern.exec(param5);
            }
         }
         if(param6 == null)
         {
            param6 = [];
         }
         param6.unshift(param5);
         if(param7)
         {
            param6.unshift(param7);
            switch(param3)
            {
               case 32:
                  Cc.debugch.apply(this,param6);
                  break;
               case 16:
                  Cc.infoch.apply(this,param6);
                  break;
               case 8:
                  Cc.infoch.apply(this,param6);
                  break;
               case 4:
                  Cc.errorch.apply(this,param6);
                  break;
               case 2:
                  Cc.fatalch.apply(this,param6);
            }
         }
         else
         {
            switch(param3)
            {
               case 32:
                  Cc.debug.apply(this,param6);
                  break;
               case 16:
                  Cc.info.apply(this,param6);
                  break;
               case 8:
                  Cc.info.apply(this,param6);
                  break;
               case 4:
                  Cc.error.apply(this,param6);
                  break;
               case 2:
                  Cc.fatal.apply(this,param6);
            }
         }
      }
   }
}

