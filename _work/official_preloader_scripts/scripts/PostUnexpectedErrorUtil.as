package
{
   import errorutil.PostErrorUtil;
   import flash.events.ErrorEvent;
   import flash.events.UncaughtErrorEvent;
   
   public class PostUnexpectedErrorUtil
   {
      
      public function PostUnexpectedErrorUtil()
      {
         super();
      }
      
      public static function execute(param1:UncaughtErrorEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(param1.error is Error)
         {
            PostErrorUtil.postError(param1.error as Error);
         }
         else
         {
            _loc3_ = 0;
            if(param1.error is ErrorEvent)
            {
               _loc2_ = ErrorEvent(param1.error).text;
               _loc3_ = int(ErrorEvent(param1.error).errorID);
            }
            else
            {
               _loc2_ = param1.error.toString();
            }
            PostErrorUtil.postError(new Error(_loc2_,_loc3_));
         }
      }
      
      public static function test() : void
      {
      }
   }
}

