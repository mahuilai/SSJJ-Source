package ui
{
   import fl.controls.CheckBox;
   import flash.net.registerClassAlias;
   import flash.text.TextFormat;
   import style.I18NConfig;
   import style.StyleConfig;
   import utils.CloneUtil;
   import utils.UIUtil;
   
   public class UICheckBox extends CheckBox
   {
      
      public static const TEXTFORMAT:String = "textFormat";
      
      public static const TEXTFORMAT_DISABLED:String = "disabledTextFormat";
      
      private var _lanId:String;
      
      private var _fontLanId:String;
      
      private var _skins:String;
      
      public function UICheckBox()
      {
         super();
         initUI();
      }
      
      protected function initUI() : void
      {
         setStyle("textFormat",new TextFormat("宋体",12,10079487));
         setStyle("disabledTextFormat",StyleConfig.COMBOBOX_DISABLED_TEXTFORMAT);
         textField.filters = [StyleConfig.FILTER_GLOW_SHOW_LABEL_NAME];
      }
      
      public function set fontSize(param1:int) : void
      {
         setTFStyleValue("textFormat","size",param1);
         setTFStyleValue("disabledTextFormat","size",param1);
      }
      
      public function get fontSize() : int
      {
         return getTFStyle("textFormat").size;
      }
      
      public function set textColor(param1:String) : void
      {
         setTFStyleValue("textFormat","color",param1);
      }
      
      public function get textColor() : String
      {
         return "0x" + getTFStyle("textFormat").color.toString(16);
      }
      
      public function set leading(param1:int) : void
      {
         setTFStyleValue("textFormat","leading",param1);
      }
      
      public function get leading() : int
      {
         return getTFStyle("textFormat").leading;
      }
      
      public function set letterSpacing(param1:int) : void
      {
         setTFStyleValue("textFormat","letterSpacing",param1);
      }
      
      public function get letterSpacing() : int
      {
         return getTFStyle("textFormat").letterSpacing;
      }
      
      public function set font(param1:String) : void
      {
         setTFStyleValue("textFormat","font",param1);
         setTFStyleValue("disabledTextFormat","font",param1);
      }
      
      public function get font() : String
      {
         return getTFStyle("textFormat").font;
      }
      
      public function set fontLanID(param1:String) : void
      {
         if(_fontLanId == param1)
         {
            return;
         }
         _fontLanId = param1;
         if(!param1 || param1.length == 0)
         {
            return;
         }
         try
         {
            font = I18NConfig.getText(param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function get fontLanID() : String
      {
         return _fontLanId;
      }
      
      public function set skins(param1:String) : void
      {
         if(_skins == param1)
         {
            return;
         }
         _skins = param1;
         setStyle("upIcon",getSkinByName(param1 + "1"));
         setStyle("overIcon",getSkinByName(param1 + "2"));
         setStyle("downIcon",getSkinByName(param1 + "3"));
         setStyle("disabledIcon",getSkinByName(param1 + "4"));
         setStyle("selectedUpIcon",getSkinByName(param1 + "5"));
         setStyle("selectedOverIcon",getSkinByName(param1 + "6") ? getSkinByName(param1 + "6") : getSkinByName(param1 + "5"));
         setStyle("selectedDownIcon",getSkinByName(param1 + "7") ? getSkinByName(param1 + "7") : getSkinByName(param1 + "5"));
         setStyle("selectedDisabledIcon",getSkinByName(param1 + "8") ? getSkinByName(param1 + "8") : getSkinByName(param1 + "5"));
      }
      
      public function get skins() : String
      {
         return _skins;
      }
      
      public function set zLanID(param1:String) : void
      {
         if(_lanId == param1)
         {
            return;
         }
         _lanId = param1;
         if(!param1 || param1.length == 0)
         {
            return;
         }
         try
         {
            label = I18NConfig.getText(param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function get zLanID() : String
      {
         return _lanId;
      }
      
      protected function getSkinByName(param1:String) : Class
      {
         try
         {
            return UIUtil.getDefinition(param1) as Class;
         }
         catch(e:Error)
         {
            trace(param1 + " have not skin");
         }
         return null;
      }
      
      private function setTFStyleValue(param1:String, param2:String, param3:*) : void
      {
         var _loc4_:Object = getTFStyle(param1);
         _loc4_[param2] = param3;
         setStyle(param1,_loc4_);
      }
      
      private function getTFStyle(param1:String) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Object = getStyle(param1);
         if(_loc3_)
         {
            return _loc3_;
         }
         registerClassAlias("flash.text.TextFormat",TextFormat);
         _loc2_ = getStyleValue(param1);
         if(!_loc2_)
         {
            _loc2_ = getStyleValue("textFormat");
         }
         if(_loc2_)
         {
            _loc2_ = CloneUtil.clone(_loc2_);
         }
         if(!_loc2_)
         {
            _loc2_ = new TextFormat();
         }
         return _loc2_;
      }
   }
}

