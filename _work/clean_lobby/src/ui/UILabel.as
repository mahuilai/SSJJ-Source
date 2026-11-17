package ui
{
   import flash.display.DisplayObject;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import style.I18NConfig;
   import style.StyleConfig;
   import ui.core.UICommon;
   import utils.FilterUtil;
   import utils.StringUtil;
   import utils.UIUtil;
   
   public class UILabel extends UIBase
   {
      
      protected var _textField:TextField;
      
      protected var _format:TextFormat;
      
      protected var _text:String;
      
      protected var _htmlText:String;
      
      protected var _stroke:uint;
      
      protected var _skin:String;
      
      protected var _bitmap:AutoBitmap;
      
      protected var _leftMargin:Object;
      
      protected var _rightMargin:Object;
      
      protected var _topMargin:Object;
      
      protected var _bottomMargin:Object;
      
      protected var _fontLanId:String;
      
      protected var _lanId:String;
      
      protected var _htmlLanID:String;
      
      public function UILabel(param1:String = "", param2:String = null)
      {
         this.removeChildren();
         super();
         this.text = param1;
         this.skin = param2;
         styleName = "UILabel";
      }
      
      override protected function preinitialize() : void
      {
         mouseEnabled = false;
         mouseChildren = true;
      }
      
      override protected function createChildren() : void
      {
         addChild(_bitmap = new AutoBitmap());
         addChild(_textField = new TextField());
      }
      
      override protected function initialize() : void
      {
         _format = _textField.defaultTextFormat;
         _format.font = "宋体";
         _format.size = 12;
         _format.color = 16777215;
         _textField.selectable = false;
         _textField.autoSize = "left";
         _bitmap.sizeGrid = [2,2,2,2];
      }
      
      public function get text() : String
      {
         if(_text == null)
         {
            return "";
         }
         return _text;
      }
      
      public function set text(param1:String) : void
      {
         _htmlText = null;
         if(_text != param1)
         {
            _text = param1;
            changeText();
            sendEvent("change");
         }
      }
      
      public function get htmlText() : String
      {
         if(_htmlText == null)
         {
            return "";
         }
         return _htmlText;
      }
      
      public function set htmlText(param1:String) : void
      {
         _text = null;
         if(_htmlText != param1)
         {
            _htmlText = param1;
            changeText();
            sendEvent("change");
         }
      }
      
      public function set zLanID(param1:String) : void
      {
         if(_lanId == param1)
         {
            return;
         }
         _htmlLanID = null;
         _lanId = param1;
         if(!param1 || param1.length == 0)
         {
            text = null;
            return;
         }
         try
         {
            text = I18NConfig.getText(param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function get zLanID() : String
      {
         return _lanId;
      }
      
      public function set htmlTextLanID(param1:String) : void
      {
         if(_htmlLanID == param1)
         {
            return;
         }
         _lanId = null;
         _htmlLanID = param1;
         if(!param1 || param1.length == 0)
         {
            htmlText = null;
            return;
         }
         try
         {
            htmlText = I18NConfig.getText(param1);
         }
         catch(e:Error)
         {
         }
      }
      
      public function get htmlTextLanID() : String
      {
         return _htmlLanID;
      }
      
      protected function changeText() : void
      {
         _textField.defaultTextFormat = _format;
         if(_text)
         {
            _textField.text = _text;
         }
         else if(_htmlText)
         {
            _textField.htmlText = _htmlText;
         }
         else
         {
            _textField.text = "";
         }
      }
      
      override protected function changeSize() : void
      {
         if(!isNaN(_width))
         {
            _textField.autoSize = "none";
            _textField.width = _width - int(_leftMargin) - int(_rightMargin);
            if(isNaN(_height) && wordWrap)
            {
               _textField.autoSize = "left";
            }
            else
            {
               if(_height <= 0)
               {
                  _height = UIUtil.getTextField(format).textHeight;
               }
               _textField.height = _height - int(_topMargin) - int(_bottomMargin);
            }
         }
         else
         {
            _width = _height = NaN;
            _textField.autoSize = "left";
         }
         super.changeSize();
      }
      
      public function get stroke() : uint
      {
         return _stroke;
      }
      
      public function set stroke(param1:uint) : void
      {
         if(_stroke != param1)
         {
            _stroke = param1;
            FilterUtil.clearFilter(_textField,GlowFilter);
            if(param1 > 0)
            {
               FilterUtil.addFilter(_textField,FilterUtil.getStrokeFilter(_stroke,1,2,2,2000));
            }
         }
      }
      
      public function set filtersColor(param1:String) : void
      {
         if(param1 == null || param1.length == 0)
         {
            stroke = 0;
            return;
         }
         stroke = uint(param1);
         this.textField.filters = [new GlowFilter(uint(param1),1,2,2,2000)];
      }
      
      public function get filtersColor() : String
      {
         return _stroke.toString(16);
      }
      
      public function get multiline() : Boolean
      {
         return _textField.multiline;
      }
      
      public function set multiline(param1:Boolean) : void
      {
         _textField.wordWrap = param1;
         _textField.multiline = param1;
      }
      
      public function get displayAsPassword() : Boolean
      {
         return _textField.displayAsPassword;
      }
      
      public function set displayAsPassword(param1:Boolean) : void
      {
         _textField.displayAsPassword = param1;
      }
      
      public function get autoSize() : String
      {
         return _textField.autoSize;
      }
      
      public function set autoSize(param1:String) : void
      {
         if(param1 != "none")
         {
            height = width = NaN;
         }
         _textField.autoSize = param1;
      }
      
      public function get wordWrap() : Boolean
      {
         return _textField.wordWrap;
      }
      
      public function set wordWrap(param1:Boolean) : void
      {
         _textField.wordWrap = param1;
      }
      
      public function get selectable() : Boolean
      {
         return _textField.selectable;
      }
      
      public function set selectable(param1:Boolean) : void
      {
         _textField.selectable = param1;
         mouseEnabled = param1;
      }
      
      public function get background() : Boolean
      {
         return _textField.background;
      }
      
      public function set background(param1:Boolean) : void
      {
         _textField.background = param1;
      }
      
      public function get backgroundColor() : uint
      {
         return _textField.backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         _textField.backgroundColor = param1;
      }
      
      public function get textColor() : Object
      {
         return _format.color;
      }
      
      public function set textColor(param1:Object) : void
      {
         _format.color = param1;
         callLater(changeText);
      }
      
      public function get font() : String
      {
         return _format.font;
      }
      
      public function set font(param1:String) : void
      {
         _format.font = param1;
         callLater(changeText);
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
      
      public function get textAlign() : String
      {
         return _format.align;
      }
      
      public function set textAlign(param1:String) : void
      {
         _format.align = param1;
         callLater(changeText);
      }
      
      public function get textBold() : Object
      {
         return _format.bold;
      }
      
      public function set textBold(param1:Object) : void
      {
         _format.bold = param1;
         callLater(changeText);
      }
      
      public function get leading() : Object
      {
         return _format.leading;
      }
      
      public function set leading(param1:Object) : void
      {
         _format.leading = param1;
         callLater(changeText);
      }
      
      public function get indent() : Object
      {
         return _format.indent;
      }
      
      public function set indent(param1:Object) : void
      {
         _format.indent = param1;
         callLater(changeText);
      }
      
      public function get fontSize() : Object
      {
         return _format.size;
      }
      
      public function set fontSize(param1:Object) : void
      {
         _format.size = param1;
         callLater(changeText);
      }
      
      public function get underline() : Object
      {
         return _format.underline;
      }
      
      public function set underline(param1:Object) : void
      {
         _format.underline = param1;
         callLater(changeText);
      }
      
      public function get letterSpacing() : Object
      {
         return _format.letterSpacing;
      }
      
      public function set letterSpacing(param1:Object) : void
      {
         _format.letterSpacing = param1;
         callLater(changeText);
      }
      
      public function set leftMargin(param1:Object) : void
      {
         _leftMargin = param1;
         _textField.x = int(_leftMargin);
         callLater(changeSize);
      }
      
      public function get leftMargin() : Object
      {
         return _leftMargin;
      }
      
      public function set rightMargin(param1:Object) : void
      {
         _rightMargin = param1;
         callLater(changeSize);
      }
      
      public function get rightMargin() : Object
      {
         return _rightMargin;
      }
      
      public function set topMargin(param1:Object) : void
      {
         _topMargin = param1;
         _textField.y = int(_topMargin);
         callLater(changeSize);
      }
      
      public function get topMargin() : Object
      {
         return _topMargin;
      }
      
      public function set bottomMargin(param1:Object) : void
      {
         _bottomMargin = param1;
         callLater(changeSize);
      }
      
      public function get bottomMargin() : Object
      {
         return _bottomMargin;
      }
      
      public function get embedFonts() : Boolean
      {
         return _textField.embedFonts;
      }
      
      public function set embedFonts(param1:Boolean) : void
      {
         _textField.embedFonts = param1;
      }
      
      public function get format() : TextFormat
      {
         return _format;
      }
      
      public function set format(param1:TextFormat) : void
      {
         _format = param1;
         callLater(changeText);
      }
      
      public function get textField() : TextField
      {
         return _textField;
      }
      
      public function appendText(param1:String) : void
      {
         text += param1;
      }
      
      public function get skin() : String
      {
         return _skin;
      }
      
      public function set skin(param1:String) : void
      {
         if(_skin != param1)
         {
            _skin = param1;
            if(_skin == null)
            {
               _bitmap.asset = null;
               return;
            }
            _bitmap.asset = UICommon.asset.getAsset(_skin);
            _contentWidth = _bitmap.width;
            _contentHeight = _bitmap.height;
         }
      }
      
      public function get sizeGrid() : String
      {
         return _bitmap.sizeGrid.join(",");
      }
      
      public function set sizeGrid(param1:String) : void
      {
         _bitmap.sizeGrid = StringUtil.fillArray(StyleConfig.defaultSizeGrid,param1);
      }
      
      override public function commitMeasure() : void
      {
         exeCallLater(changeText);
         exeCallLater(changeSize);
      }
      
      override public function get width() : Number
      {
         if(!isNaN(_width) || Boolean(_skin) || Boolean(_text))
         {
            commitMeasure();
            return super.width;
         }
         return 0;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         _bitmap.width = param1;
      }
      
      override public function get height() : Number
      {
         if(!isNaN(_height) || Boolean(_skin) || Boolean(_text))
         {
            commitMeasure();
            return super.height;
         }
         return 0;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         _bitmap.height = param1;
      }
      
      public function setStyle(param1:String, param2:Object) : void
      {
         if(param1 == "textFormat")
         {
            format = param2 as TextFormat;
            return;
         }
         throw new Error("error style name!!");
      }
      
      public function getStyle(param1:String) : Object
      {
         if(param1 == "textFormat")
         {
            return format;
         }
         throw new Error("error style name!!");
      }
      
      public function set condenseWhite(param1:Boolean) : void
      {
      }
      
      public function get condenseWhite() : Boolean
      {
         return false;
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         return super.addChild(param1);
      }
   }
}

