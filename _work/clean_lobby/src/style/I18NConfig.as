package style
{
   public class I18NConfig
   {
      public static var dic:Object = {
         "WORD_19": "宋体",
         "WORD_20": "微软雅黑",
         "WORD_258": "点券",
         "WORD_280": "主武器",
         "WORD_283": "修理",
         "WORD_284": "卸下",
         "WORD_604": "购物车",
         "WORD_605": "激活码",
         "WORD_606": "礼券",
         "WORD_609": "武器",
         "WORD_610": "角色",
         "WORD_611": "道具",
         "WORD_612": "礼包",
         "WORD_735": "GP",
         "WORD_999": "个人仓库",
         "WORD_1630": "前往商城",
         "WORD_8477": "皮肤"
      };

      public function I18NConfig()
      {
         super();
      }

      public static function loadProperties(raw:String) : void
      {
         if(!raw) return;
         var lines:Array = raw.split("\n");
         for(var i:int = 0; i < lines.length; i++)
         {
            var line:String = lines[i];
            var eq:int = line.indexOf("=");
            if(eq > 0)
            {
               var k:String = line.substring(0, eq).replace(/^\s+|\s+$/g, "");
               if(k.charCodeAt(0) == 0xFEFF) k = k.substring(1);
               var v:String = line.substring(eq + 1).replace(/\r/g, "");
               dic[k] = v;
            }
         }
      }

      public static function getText(param1:String) : String
      {
         if(param1 == null) return "";
         if(dic[param1] != null) return String(dic[param1]);
         return param1;
      }
   }
}
