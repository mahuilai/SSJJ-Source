package lobby.common
{
   public class PlateformName
   {
      
      public static const PLATFORM_YY:String = "dwssjj";
      
      public static const PLATFORM_4399:String = "4399";
      
      public static const PLATFORM_QQ:String = "qqltfk";
      
      public static const PLATFORM_3366:String = "3366";
      
      public static const PLATFORM_QQGAME:String = "qqgame";
      
      public static const PLATFORM_IWAN:String = "iwan";
      
      public static const PLATFORM_WEBSITE:String = "website";
      
      public static const PLATFORM_UNION:String = "union";
      
      public static const PLATFORM_XINYUE:String = "xinyue";
      
      public static const PLATFORM_FACEBOOK:String = "fb";
      
      public static const PLATFORM_WD:String = "wd";
      
      public static const PLATFORM_TGP:String = "tgp";
      
      public function PlateformName()
      {
         super();
      }
      
      public static function isTXplateform() : Boolean
      {
         if(GlobalVariable.platform == "qqltfk" || GlobalVariable.platform == "3366" || GlobalVariable.platform == "qqgame" || GlobalVariable.platform == "iwan" || GlobalVariable.platform == "website" || GlobalVariable.platform == "union" || GlobalVariable.platform == "xinyue" || GlobalVariable.platform == "tgp")
         {
            return true;
         }
         return false;
      }
   }
}

