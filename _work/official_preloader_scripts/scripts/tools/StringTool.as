package tools
{
   import lobby.LanguageConfig;
   
   public class StringTool
   {
      
      private static var gameUnicode:Object = null;
      
      public static var checkLetterOk:Boolean = false;
      
      public static var mainUnicodeLen:int = 2;
      
      public function StringTool()
      {
         super();
      }
      
      public static function replaceParam(param1:String, ... rest) : String
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < rest.length)
         {
            param1 = param1.replace("{" + _loc3_ + "}",rest[_loc3_]);
            _loc3_++;
         }
         return param1;
      }
      
      public static function initGameUnicode(param1:Object) : void
      {
         gameUnicode = param1;
      }
      
      public static function initGameUnicodeFromText(param1:String) : void
      {
         var _loc7_:int = 0;
         var _loc2_:Array = null;
         var _loc6_:Array = param1.split("#");
         var _loc5_:int = int(_loc6_.length);
         var _loc3_:Object = {};
         var _loc4_:Object = null;
         _loc7_ = 0;
         while(_loc7_ < _loc5_)
         {
            _loc2_ = (_loc6_[_loc7_] as String).split("@");
            _loc4_ = {};
            _loc4_.id = _loc7_ + 1;
            _loc4_.name = _loc2_[0];
            _loc4_.unicodes = _loc2_[1];
            _loc4_.len = _loc2_[2];
            _loc3_[_loc4_.id] = _loc4_;
            _loc7_++;
         }
         initGameUnicode(_loc3_);
      }
      
      public static function checkStringLength(param1:String, param2:int, param3:Function, param4:Function, param5:Function = null, param6:Function = null) : void
      {
         var _loc9_:String = null;
         var _loc12_:Number = NaN;
         var _loc11_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:Boolean = false;
         checkLetterOk = true;
         var _loc8_:int = 0;
         _loc11_ = 0;
         while(_loc11_ < param1.length)
         {
            _loc9_ = param1.charAt(_loc11_);
            _loc12_ = param1.charCodeAt(_loc11_);
            if(charIsLetter(_loc12_) || charIsNumber(_loc12_))
            {
               _loc10_++;
            }
            else if(charIsLegalChar(_loc9_))
            {
               if(twoLengthLegalChars.indexOf(_loc9_) == -1)
               {
                  _loc10_++;
               }
               else
               {
                  _loc10_ += 2;
               }
               if(++_loc8_ > 2)
               {
                  checkLetterOk = false;
                  param4();
               }
               else if(checkLetterOk)
               {
                  if(null != param6)
                  {
                     param6.apply();
                  }
               }
            }
            else if(charIsMainLanguage(_loc9_))
            {
               _loc10_ += mainUnicodeLen;
            }
            else
            {
               _loc10_++;
               checkLetterOk = false;
               param3();
            }
            if(_loc10_ > param2)
            {
               param1 = param1.slice(0,_loc11_);
               if(null != param5)
               {
                  param5.apply(null,[param1]);
               }
               checkStringLength(param1,param2,param3,param4,param5,param6);
               break;
            }
            _loc11_++;
         }
      }
      
      public static function charIsNumber(param1:Number) : Boolean
      {
         var _loc2_:Boolean = false;
         return param1 >= "0".charCodeAt() && param1 <= "9".charCodeAt();
      }
      
      public static function charIsMainLanguage(param1:String) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:Object = gameUnicode;
         var _loc6_:RegExp = null;
         var _loc5_:Array = null;
         var _loc2_:int = 0;
         for each(var _loc7_:Object in _loc3_)
         {
            _loc5_ = (_loc7_.unicodes as String).split("|");
            _loc2_ = int(_loc5_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc6_ = new RegExp(_loc5_[_loc4_]);
               if(!_loc6_.test(param1))
               {
                  mainUnicodeLen = _loc7_.len;
                  return true;
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      public static function charIsLetter(param1:Number) : Boolean
      {
         var _loc2_:Boolean = false;
         _loc2_ = param1 >= "a".charCodeAt() && param1 <= "z".charCodeAt();
         return _loc2_ || param1 >= "A".charCodeAt() && param1 <= "Z".charCodeAt();
      }
      
      private static function get twoLengthLegalChars() : String
      {
         return LanguageConfig.getText("WORD_2145");
      }
      
      public static function charIsLegalChar(param1:String) : Boolean
      {
         var _loc2_:String = LanguageConfig.getText("WORD_2144");
         return _loc2_.indexOf(param1) != -1;
      }
      
      public static function decodeURIChatName(param1:String) : String
      {
         return decodeURIComponent(param1);
      }
   }
}

