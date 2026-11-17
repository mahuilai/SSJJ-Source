package style
{
   import flash.filters.GlowFilter;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   
   public class StyleConfig
   {
      
      public static const FONT_SONG:String = "宋体";
      
      public static const FONT_Micro:String = "微软雅黑";
      
      public static var MOVIE_INTERVAL:int = 100;
      
      public static const DEFAULTSTYLE_UILABEL:String = "UILabel";
      
      public static const DEFAULTSTYLE_UIBUTTON:String = "UIButton";
      
      public static const DEFAULTSTYLE_UISLIDER:String = "UISlider";
      
      public static const DEFAULTSTYLE_UISCROLLBAR:String = "UIScrollBar";
      
      public static const DEFAULTSTYLE_UICOMBOBOX:String = "UICombobox";
      
      public static const DEFAULTSTYLE_UICOMBOBOXDROPLISTCELL:String = "UIComboboxDropListCell";
      
      public static const WHITE_FONT:TextFormat = new TextFormat("宋体",12,16777215);
      
      public static const COMBOBOX_TEXTFORMAT:TextFormat = new TextFormat("宋体",12,16120263);
      
      public static const COMBOBOX_DISABLED_TEXTFORMAT:TextFormat = new TextFormat("宋体",12,13948116);
      
      public static const FILTER_GLOW_SHOW_LABEL_NAME:GlowFilter = new GlowFilter(0,1,2,2,2000);
      
      public static var defaultSizeGrid:Array = [4,4,4,4];
      
      private var _styleList:Dictionary;
      
      public function StyleConfig()
      {
         super();
         _styleList = new Dictionary();
      }
      
      public function initStyle(param1:XML) : void
      {
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         var _loc2_:int = param1.style.length();
         while(_loc4_ < _loc2_)
         {
            _loc3_ = param1.style[_loc4_];
            _styleList[String(_loc3_.@name)] = JSON.parse(_loc3_.@style);
            _loc4_++;
         }
      }
      
      public function getStyle(param1:String) : Object
      {
         if(_styleList)
         {
            return _styleList[param1];
         }
         return null;
      }
   }
}

