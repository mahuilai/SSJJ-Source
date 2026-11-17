package fl.controls
{
   import fl.core.UIComponent;
   import fl.events.ComponentEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class Label extends UIComponent
   {
      
      private static var defaultStyles:Object = {
         "textFormat":null,
         "embedFonts":false
      };
      
      public var textField:TextField;
      
      protected var actualWidth:Number;
      
      protected var actualHeight:Number;
      
      protected var defaultLabel:String = "Label";
      
      protected var _savedHTML:String;
      
      protected var _html:Boolean = false;
      
      public function Label()
      {
         super();
         text = defaultLabel;
         actualWidth = _width;
         actualHeight = _height;
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      public function get text() : String
      {
         return textField.text;
      }
      
      public function set text(param1:String) : void
      {
         if(param1 == text)
         {
            return;
         }
         if(componentInspectorSetting && param1 == defaultLabel)
         {
            return;
         }
         _html = false;
         textField.text = param1;
         if(textField.autoSize != "none")
         {
            invalidate("size");
         }
      }
      
      public function get htmlText() : String
      {
         return textField.htmlText;
      }
      
      public function set htmlText(param1:String) : void
      {
         if(param1 == htmlText)
         {
            return;
         }
         if(componentInspectorSetting && param1 == "")
         {
            return;
         }
         _html = true;
         _savedHTML = param1;
         textField.htmlText = param1;
         if(textField.autoSize != "none")
         {
            invalidate("size");
         }
      }
      
      public function get condenseWhite() : Boolean
      {
         return textField.condenseWhite;
      }
      
      public function set condenseWhite(param1:Boolean) : void
      {
         textField.condenseWhite = param1;
         if(textField.autoSize != "none")
         {
            invalidate("size");
         }
      }
      
      public function get selectable() : Boolean
      {
         return textField.selectable;
      }
      
      public function set selectable(param1:Boolean) : void
      {
         textField.selectable = param1;
      }
      
      public function get wordWrap() : Boolean
      {
         return textField.wordWrap;
      }
      
      public function set wordWrap(param1:Boolean) : void
      {
         textField.wordWrap = param1;
         if(textField.autoSize != "none")
         {
            invalidate("size");
         }
      }
      
      public function get autoSize() : String
      {
         return textField.autoSize;
      }
      
      public function set autoSize(param1:String) : void
      {
         textField.autoSize = param1;
         invalidate("size");
      }
      
      override public function get width() : Number
      {
         if(textField.autoSize != "none" && !wordWrap)
         {
            return _width;
         }
         return actualWidth;
      }
      
      override public function set width(param1:Number) : void
      {
         actualWidth = param1;
         super.width = param1;
      }
      
      override public function get height() : Number
      {
         if(textField.autoSize != "none" && wordWrap)
         {
            return _height;
         }
         return actualHeight;
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         actualWidth = param1;
         actualHeight = param2;
         super.setSize(param1,param2);
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         textField = new TextField();
         addChild(textField);
         textField.type = "dynamic";
         textField.selectable = false;
         textField.wordWrap = false;
      }
      
      override protected function draw() : void
      {
         var _loc1_:Object = null;
         if(isInvalid("styles","state"))
         {
            drawTextFormat();
            _loc1_ = getStyleValue("embedFonts");
            if(_loc1_ != null)
            {
               textField.embedFonts = _loc1_;
            }
            if(textField.autoSize != "none")
            {
               invalidate("size",false);
            }
         }
         if(isInvalid("size"))
         {
            drawLayout();
         }
         super.draw();
      }
      
      protected function drawTextFormat() : void
      {
         var _loc1_:Object = null;
         var _loc2_:TextFormat = getStyleValue("textFormat") as TextFormat;
         if(_loc2_ == null)
         {
            _loc1_ = UIComponent.getStyleDefinition();
            _loc2_ = enabled ? _loc1_.defaultTextFormat as TextFormat : _loc1_.defaultDisabledTextFormat as TextFormat;
         }
         textField.defaultTextFormat = _loc2_;
         textField.setTextFormat(_loc2_);
         if(_html && _savedHTML != null)
         {
            htmlText = _savedHTML;
         }
      }
      
      protected function drawLayout() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Boolean = false;
         textField.width = width;
         textField.height = height;
         if(textField.autoSize != "none")
         {
            _loc1_ = textField.width;
            _loc2_ = textField.height;
            _loc3_ = _width != _loc1_ || _height != _loc2_;
            _width = _loc1_;
            _height = _loc2_;
            switch(textField.autoSize)
            {
               case "center":
                  textField.x = actualWidth / 2 - textField.width / 2;
                  break;
               case "left":
                  textField.x = 0;
                  break;
               case "right":
                  textField.x = -(textField.width - actualWidth);
            }
         }
         else
         {
            textField.width = actualWidth;
            textField.height = actualHeight;
            textField.x = 0;
         }
         if(_loc3_)
         {
            dispatchEvent(new ComponentEvent("resize",true));
         }
      }
   }
}

