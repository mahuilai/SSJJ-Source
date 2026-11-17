package
{
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import org.as3commons.logging.api.ILogger;
   import org.as3commons.logging.api.getLogger;
   
   public class MultiApplicationUtil
   {
      
      private static const appName:String = "AirLobbyPreloader";
      
      private static var curAppId:int = 0;
      
      private static const _logger:ILogger = getLogger(MultiApplicationUtil);
      
      public function MultiApplicationUtil()
      {
         super();
      }
      
      private static function getClosedFile() : File
      {
         return new File(File.applicationDirectory.nativePath + "/air.dat");
      }
      
      private static function getOpenNumFile() : File
      {
         return new File(File.applicationDirectory.nativePath + "/air_open.dat");
      }
      
      private static function getApplicationXmlFile() : File
      {
         return new File(File.applicationDirectory.nativePath + "/META-INF/AIR/" + "application.xml");
      }
      
      private static function getNumFromFile(param1:File) : int
      {
         var _loc2_:int = 0;
         if(param1.exists)
         {
            _loc2_ = int(readTextFromFile(param1));
         }
         return _loc2_;
      }
      
      private static function getClosedNum() : int
      {
         return getNumFromFile(getClosedFile());
      }
      
      private static function getOpenNum() : int
      {
         return getNumFromFile(getOpenNumFile());
      }
      
      public static function appOpen() : void
      {
         var _loc7_:File = getApplicationXmlFile();
         var _loc6_:String = readTextFromFile(_loc7_);
         var _loc1_:String = "<id>";
         var _loc4_:String = "</id>";
         var _loc3_:int = _loc6_.search(_loc1_);
         var _loc2_:int = _loc6_.search(_loc4_);
         var _loc5_:String = _loc6_.slice(_loc3_ + _loc1_.length,_loc2_);
         curAppId = int(_loc5_.substring("AirLobbyPreloader".length,_loc5_.length));
         addId(curAppId);
         updateApplicationFile();
      }
      
      public static function updateApplicationFile() : void
      {
         var _loc8_:String = getNextSuffix();
         var _loc7_:File = getApplicationXmlFile();
         var _loc6_:String = readTextFromFile(_loc7_);
         var _loc1_:String = "<id>";
         var _loc4_:String = "</id>";
         var _loc3_:int = _loc6_.search(_loc1_);
         var _loc2_:int = _loc6_.search(_loc4_);
         var _loc5_:String = _loc6_.slice(_loc3_ + _loc1_.length,_loc2_);
         _loc6_ = _loc6_.replace(_loc5_,"AirLobbyPreloader" + _loc8_);
         writeTextFile(_loc7_,_loc6_);
      }
      
      public static function appClosed() : void
      {
         removeId(curAppId);
         updateApplicationFile();
      }
      
      private static function addFileNum(param1:File) : void
      {
         var _loc2_:int = getNumFromFile(param1);
         _loc2_++;
         writeTextFile(param1,"" + _loc2_);
      }
      
      private static function readTextFromFile(param1:File) : String
      {
         var _loc3_:FileStream = new FileStream();
         _loc3_.open(param1,"read");
         var _loc2_:String = _loc3_.readUTFBytes(_loc3_.bytesAvailable);
         _loc3_.close();
         return _loc2_;
      }
      
      private static function writeTextFile(param1:File, param2:String) : void
      {
         var _loc3_:FileStream = null;
         try
         {
            _loc3_ = new FileStream();
            _loc3_.open(param1,"write");
            _loc3_.writeUTFBytes(param2);
            _loc3_.close();
         }
         catch(e:Error)
         {
            _logger.error("write file error path:" + param1.nativePath);
            _logger.error("write file erro:" + e.getStackTrace());
         }
      }
      
      private static function getAirIdMapFile() : File
      {
         return new File(File.applicationDirectory.nativePath + "/air.dat");
      }
      
      public static function getNextSuffix() : String
      {
         var _loc1_:int = getCurValidIdByIdMap(getIdMap());
         if(0 == _loc1_)
         {
            return "";
         }
         return "" + _loc1_;
      }
      
      private static function getIdMap() : Object
      {
         var _loc1_:File = getAirIdMapFile();
         var _loc2_:Object = null;
         if(_loc1_.exists)
         {
            try
            {
               _loc2_ = JSON.parse(readTextFromFile(_loc1_));
            }
            catch(e:Error)
            {
               _loc2_ = {};
            }
         }
         else
         {
            _loc2_ = {};
         }
         return _loc2_;
      }
      
      private static function getCurValidIdByIdMap(param1:Object) : int
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < 2147483647)
         {
            if(!param1.hasOwnProperty(_loc2_))
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public static function addId(param1:int) : void
      {
         updateIdMapFile(param1,false);
      }
      
      public static function removeId(param1:int) : void
      {
         updateIdMapFile(param1,true);
      }
      
      private static function updateIdMapFile(param1:int, param2:Boolean) : void
      {
         var _loc3_:Object = getIdMap();
         if(param2)
         {
            delete _loc3_[param1];
         }
         else
         {
            _loc3_[param1] = param1;
         }
         writeTextFile(getAirIdMapFile(),JSON.stringify(_loc3_));
      }
   }
}

