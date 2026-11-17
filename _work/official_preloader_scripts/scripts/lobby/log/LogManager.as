package lobby.log
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.addons.htmlexport.ConsoleHtmlExportAddon;
   import flash.display.DisplayObjectContainer;
   import org.as3commons.logging.api.ILogSetup;
   import org.as3commons.logging.api.LOGGER_FACTORY;
   import org.as3commons.logging.setup.log4j.Log4JStyleSetup;
   
   public class LogManager
   {
      
      public static var logSetup:ILogSetup;
      
      public function LogManager()
      {
         super();
      }
      
      public static function start(param1:DisplayObjectContainer, param2:String = null, param3:int = 1000, param4:Boolean = true) : void
      {
         var _loc5_:Log4JStyleSetup = null;
         if(Cc.instance == null)
         {
            Cc.config.style.backgroundAlpha = 1;
            Cc.start(param1,param2);
            Cc.visible = false;
            Cc.config.commandLineAllowed = param4;
            Cc.config.tracing = true;
            Cc.remoting = false;
            Cc.config.maxLines = param3;
            Cc.commandLine = param4;
            Cc.height = 220;
            ConsoleHtmlExportAddon.addToMenu();
         }
         if(logSetup == null)
         {
            _loc5_ = new Log4JStyleSetup();
            _loc5_.rootLogger = "INFO, CONSOLE, REMOTE";
            _loc5_.appender.CONSOLE = new JunkByteConsoleTarget();
            _loc5_.appender.REMOTE = new LogBuffer();
            _loc5_.logger.com.wooduan.resource = "ERROR";
            _loc5_.logger.com.wooduan.resource.pub.Cache = "DEBUG";
            _loc5_.logger.com.wooduan.material = "ERROR";
            logSetup = _loc5_.compile();
         }
         if(LOGGER_FACTORY.setup != logSetup)
         {
            LOGGER_FACTORY.setup = logSetup;
         }
      }
      
      public static function getLogString() : String
      {
         return LogBuffer.getLogString();
      }
   }
}

