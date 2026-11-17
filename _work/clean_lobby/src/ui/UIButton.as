package ui
{
   import flash.events.MouseEvent;
   import flash.net.registerClassAlias;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import style.I18NConfig;
   import style.StyleConfig;
   import ui.core.UICommon;
   import utils.CloneUtil;
   import utils.FilterUtil;
   import utils.StringUtil;
   import utils.UIUtil;
   
   public class UIButton extends UICellRenderer
   {
      
      protected static var stateMap:Object = {
         "rollOver":1,
         "rollOut":0,
         "mouseDown":2,
         "mouseUp":1,
         "selected_rollOver":4,
         "selected_rollOut":3,
         "selected_mouseDown":5,
         "selected_mouseUp":4
      };
      
      protected static var skinLenRegExp:RegExp = /len(\d)/gi;
      
      protected var _bitmap:AutoBitmap;
      
      protected var _btnLabel:UILabel;
      
      protected var _textFormats:Vector.<TextFormat>;
      
      protected var _leftMargin:Object;
      
      protected var _rightMargin:Object;
      
      protected var _topMargin:Object;
      
      protected var _bottomMargin:Object;
      
      protected var _state:int;
      
      protected var _toggle:Boolean;
      
      protected var _skin:String;
      
      protected var _tipsType:String;
      
      protected var _tipsZLanID:String;
      
      protected var _autoSize:Boolean = true;
      
      protected var _oldMode:Boolean = true;
      
      private var _imageTipsURL:String = "resource/swf/RpgAssets/Tips/{0}.swf";
      
      public var _fontLanID:String;
      
      public var _zLanID:String;
      
      public function UIButton(param1:String = null, param2:String = "")
      {
         super();
         this.skin = param1;
         this.label = param2;
         this.styleName = "UIButton";
         mouseChildren = tabEnabled = tabChildren = false;
      }
      
      public function get imageTipsURL() : String
      {
         return _imageTipsURL;
      }
      
      public function set imageTipsURL(param1:String) : void
      {
         _imageTipsURL = param1;
      }
      
      public function get tipsZLanID() : String
      {
         return _tipsZLanID;
      }
      
      public function set tipsZLanID(param1:String) : void
      {
         _tipsZLanID = param1;
      }
      
      public function get tipsType() : String
      {
         return _tipsType;
      }
      
      public function set tipsType(param1:String) : void
      {
         _tipsType = param1;
      }
      
      override protected function createChildren() : void
      {
         addChild(_bitmap = new AutoBitmap());
         addChild(_btnLabel = new UILabel());
         _textFormats = new <TextFormat>[null,null,null,null,null,null];
         _textFormats[0] = _btnLabel.format;
      }
      
      override protected function initialize() : void
      {
         _btnLabel.textAlign = "center";
         addEventListener("rollOver",onMouse);
         addEventListener("rollOut",onMouse);
         addEventListener("mouseDown",onMouse);
         addEventListener("mouseUp",onMouse);
         _bitmap.sizeGrid = StyleConfig.defaultSizeGrid;
      }
      
      protected function onMouse(param1:MouseEvent) : void
      {
         if(param1.type == "rollOver")
         {
            if(_tipsType != null && _tipsType != "none" && _tipsType !== "" && _tipsZLanID != null && _tipsZLanID != "")
            {
               if(_tipsType == "word")
               {
                  UIToolTips.instance.show(_tipsType,[I18NConfig.getText(tipsZLanID)]);
               }
               else if(_tipsType == "image")
               {
                  UIToolTips.instance.show(_tipsType,[tipsZLanID,imageTipsURL]);
               }
            }
         }
         if(param1.type == "rollOut")
         {
            UIToolTips.instance.hide();
         }
         if(_toggle == false && _selected || !_enabled)
         {
            return;
         }
         if(param1.type == "click")
         {
            if(_toggle)
            {
               selected = !_selected;
            }
            return;
         }
         state = getCurrentState(param1.type);
      }
      
      public function get label() : String
      {
         return _btnLabel.text;
      }
      
      public function set label(param1:String) : void
      {
         if(_btnLabel.text != param1)
         {
            _btnLabel.text = param1;
            callLater(changeState);
         }
      }
      
      public function get skins() : String
      {
         return this.skin;
      }
      
      public function set skins(param1:String) : void
      {
         this.skin = param1;
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
            _bitmap.clips = getClips(_skin);
            if(_autoSize)
            {
               _contentWidth = _bitmap.width;
               _contentHeight = _bitmap.height;
            }
            callLater(changeLabelSize);
         }
      }
      
      private function getClips(param1:String) : Vector.<Asset>
      {
         var _loc6_:* = undefined;
         var _loc2_:Asset = null;
         var _loc4_:int = 0;
         var _loc7_:Boolean = false;
         var _loc5_:String = null;
         var _loc3_:Object = null;
         if(UIUtil.hasDefinition(param1 + 1))
         {
            _oldMode = true;
            _loc6_ = new Vector.<Asset>();
            _loc4_ = 1;
            _loc7_ = true;
            while(_loc4_ <= 8)
            {
               if(_loc4_ == 4 || _loc4_ == 8)
               {
                  _loc4_++;
               }
               else
               {
                  if(_loc7_)
                  {
                     _loc2_ = UICommon.asset.getAsset(param1 + _loc4_);
                  }
                  if(_loc2_ == null)
                  {
                     _loc7_ = false;
                     if(_loc4_ == 2 || _loc4_ == 3)
                     {
                        _loc6_.push(_loc6_[0]);
                     }
                     if(_loc4_ == 4)
                     {
                        _loc6_.push(_loc6_[2]);
                     }
                     if(_loc4_ == 5)
                     {
                        _loc6_.push(_loc6_[2]);
                     }
                     if(_loc4_ == 6 || _loc4_ == 7 || _loc4_ == 8)
                     {
                        _loc6_.push(_loc6_[3]);
                     }
                  }
                  else
                  {
                     _loc6_.push(_loc2_);
                  }
                  _loc5_ = UICommon.asset.getBmdSizeGrid(param1 + 1);
                  if(_loc5_)
                  {
                     sizeGrid = _loc5_;
                  }
                  _loc4_++;
               }
            }
            return _loc6_;
         }
         _oldMode = false;
         skinLenRegExp.lastIndex = 0;
         _loc3_ = skinLenRegExp.exec(param1);
         if(_loc3_)
         {
            return UICommon.asset.getClips(_skin,1,_loc3_[1]);
         }
         return UICommon.asset.getClips(_skin,1,3);
      }
      
      protected function changeLabelSize() : void
      {
         _btnLabel.width = width - Number(_leftMargin) - Number(_rightMargin);
         _btnLabel.height = UIUtil.getTextField(_btnLabel.format).height;
         _btnLabel.x = Number(_leftMargin);
         _btnLabel.y = Number(_topMargin) + (height - Number(_topMargin) - Number(_bottomMargin) - _btnLabel.height) * 0.5;
      }
      
      override public function set selected(param1:Boolean) : void
      {
         if(_selected != param1)
         {
            _selected = param1;
            state = getCurrentState("rollOut");
         }
      }
      
      private function getCurrentState(param1:String) : int
      {
         var _loc2_:int = 0;
         return int(selected ? stateMap["selected_" + param1] : stateMap[param1]);
      }
      
      protected function get state() : int
      {
         return _state;
      }
      
      protected function set state(param1:int) : void
      {
         _state = param1;
         callLater(changeState);
      }
      
      protected function changeState() : void
      {
         _bitmap.index = _state;
         if(_textFormats[_state] == null)
         {
            _btnLabel.format = _textFormats[0];
         }
         else
         {
            _btnLabel.format = _textFormats[_state];
         }
         callLater(changeLabelSize);
      }
      
      public function get toggle() : Boolean
      {
         return _toggle;
      }
      
      public function set toggle(param1:Boolean) : void
      {
         _toggle = param1;
         if(!_toggle)
         {
            selected = false;
         }
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         if(_enabled != param1)
         {
            super.enabled = param1;
            state = getCurrentState("rollOut");
            FilterUtil.gray(this,!_enabled);
         }
      }
      
      public function get labelFont() : String
      {
         return _textFormats[0].font;
      }
      
      public function set labelFont(param1:String) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _textFormats.length)
         {
            if(_textFormats[_loc2_] != null)
            {
               _textFormats[_loc2_].font = param1;
            }
            _loc2_++;
         }
         callLater(changeLabelSize);
      }
      
      public function set textColor(param1:Object) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _textFormats.length)
         {
            if(_textFormats[_loc2_] != null)
            {
               _textFormats[_loc2_].color = param1;
            }
            _loc2_++;
         }
         callLater(changeLabelSize);
      }
      
      public function get textColor() : Object
      {
         return _textFormats[0].color;
      }
      
      public function set textAlign(param1:String) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _textFormats.length)
         {
            if(_textFormats[_loc2_] != null)
            {
               _textFormats[_loc2_].align = param1;
            }
            _loc2_++;
         }
         callLater(changeLabelSize);
      }
      
      public function get textAlign() : String
      {
         return _textFormats[0].align;
      }
      
      public function set textFont(param1:String) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _textFormats.length)
         {
            if(_textFormats[_loc2_] != null)
            {
               _textFormats[_loc2_].font = param1;
            }
            _loc2_++;
         }
         callLater(changeLabelSize);
      }
      
      public function get textFont() : String
      {
         return _textFormats[0].font;
      }
      
      public function set upTextColor(param1:Object) : void
      {
         _textFormats[0].color = param1;
         callLater(changeLabelSize);
      }
      
      public function get upTextColor() : Object
      {
         return _textFormats[0].color;
      }
      
      public function set overTextColor(param1:Object) : void
      {
         createTextFormat(1);
         _textFormats[1].color = param1;
         callLater(changeLabelSize);
      }
      
      public function get overTextColor() : Object
      {
         if(_textFormats[1] != null)
         {
            return _textFormats[1].color;
         }
         return _textFormats[0].color;
      }
      
      public function set downTextColor(param1:Object) : void
      {
         createTextFormat(2);
         _textFormats[2].color = param1;
         callLater(changeLabelSize);
      }
      
      public function get downTextColor() : Object
      {
         if(_textFormats[2] != null)
         {
            return _textFormats[2].color;
         }
         return _textFormats[0].color;
      }
      
      public function set selectedUpTextColor(param1:Object) : void
      {
         createTextFormat(3);
         _textFormats[3].color = param1;
         callLater(changeLabelSize);
      }
      
      public function get selectedUpTextColor() : Object
      {
         if(_textFormats[3] != null)
         {
            return _textFormats[3].color;
         }
         return _textFormats[0].color;
      }
      
      public function set selectedOverTextColor(param1:Object) : void
      {
         createTextFormat(4);
         _textFormats[4].color = param1;
         callLater(changeLabelSize);
      }
      
      public function get selectedOverTextColor() : Object
      {
         if(_textFormats[4] != null)
         {
            return _textFormats[4].color;
         }
         return _textFormats[0].color;
      }
      
      public function set selectedDownTextColor(param1:Object) : void
      {
         createTextFormat(5);
         _textFormats[5].color = param1;
         callLater(changeLabelSize);
      }
      
      public function get selectedDownTextColor() : Object
      {
         if(_textFormats[5] != null)
         {
            return _textFormats[5].color;
         }
         return _textFormats[0].color;
      }
      
      public function set upTextFormat(param1:TextFormat) : void
      {
         _textFormats[0] = param1;
      }
      
      public function get upTextFormat() : TextFormat
      {
         return _textFormats[0];
      }
      
      public function set overTextFormat(param1:TextFormat) : void
      {
         _textFormats[1] = param1;
      }
      
      public function get overTextFormat() : TextFormat
      {
         createTextFormat(1);
         return _textFormats[1];
      }
      
      public function set downTextFormat(param1:TextFormat) : void
      {
         _textFormats[2] = param1;
      }
      
      public function get downTextFormat() : TextFormat
      {
         createTextFormat(2);
         return _textFormats[2];
      }
      
      public function set selectedUpTextFormat(param1:TextFormat) : void
      {
         _textFormats[3] = param1;
      }
      
      public function get selectedUpTextFormat() : TextFormat
      {
         createTextFormat(3);
         return _textFormats[3];
      }
      
      public function set selectedOverTextFormat(param1:TextFormat) : void
      {
         _textFormats[4] = param1;
      }
      
      public function get selectedOverTextFormat() : TextFormat
      {
         createTextFormat(4);
         return _textFormats[4];
      }
      
      public function set selectedDownTextFormat(param1:TextFormat) : void
      {
         _textFormats[5] = param1;
      }
      
      public function get selectedDownTextFormat() : TextFormat
      {
         createTextFormat(5);
         return _textFormats[5];
      }
      
      private function createTextFormat(param1:int) : void
      {
         registerClassAlias("flash.text.TextFormat",TextFormat);
         if(_textFormats[param1] == null)
         {
            _textFormats[param1] = CloneUtil.clone(_textFormats[0]);
         }
         trace("createTextFormat");
      }
      
      public function set leftMargin(param1:Object) : void
      {
         _leftMargin = param1;
         callLater(changeLabelSize);
      }
      
      public function get leftMargin() : Object
      {
         return _leftMargin;
      }
      
      public function set rightMargin(param1:Object) : void
      {
         _rightMargin = param1;
         callLater(changeLabelSize);
      }
      
      public function get rightMargin() : Object
      {
         return _rightMargin;
      }
      
      public function set topMargin(param1:Object) : void
      {
         _topMargin = param1;
         callLater(changeLabelSize);
      }
      
      public function get topMargin() : Object
      {
         return _topMargin;
      }
      
      public function set bottomMargin(param1:Object) : void
      {
         _bottomMargin = param1;
         callLater(changeLabelSize);
      }
      
      public function get bottomMargin() : Object
      {
         return _bottomMargin;
      }
      
      public function get textStroke() : uint
      {
         return _btnLabel.stroke;
      }
      
      public function set textStroke(param1:uint) : void
      {
         _btnLabel.stroke = param1;
      }
      
      public function get fontSize() : Object
      {
         return _textFormats[0].size;
      }
      
      public function set fontSize(param1:Object) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _textFormats.length)
         {
            if(_textFormats[_loc2_] != null)
            {
               _textFormats[_loc2_].size = param1;
            }
            _loc2_++;
         }
         callLater(changeLabelSize);
      }
      
      public function get textBold() : Object
      {
         return _textFormats[0].bold;
      }
      
      public function set textBold(param1:Object) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _textFormats.length)
         {
            if(_textFormats[_loc2_] != null)
            {
               _textFormats[_loc2_].bold = param1;
            }
            _loc2_++;
         }
         callLater(changeLabelSize);
      }
      
      public function get letterSpacing() : Object
      {
         return _btnLabel.letterSpacing;
      }
      
      public function set letterSpacing(param1:Object) : void
      {
         _btnLabel.letterSpacing = param1;
         callLater(changeLabelSize);
      }
      
      public function get btnLabel() : UILabel
      {
         return _btnLabel;
      }
      
      public function get textField() : TextField
      {
         return _btnLabel.textField;
      }
      
      public function get sizeGrid() : String
      {
         if(_bitmap.sizeGrid)
         {
            return _bitmap.sizeGrid.join(",");
         }
         return null;
      }
      
      public function set sizeGrid(param1:String) : void
      {
         _bitmap.sizeGrid = StringUtil.fillArray(StyleConfig.defaultSizeGrid,param1);
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         if(_autoSize)
         {
            _bitmap.width = param1;
         }
         callLater(changeLabelSize);
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         if(_autoSize)
         {
            _bitmap.height = param1;
         }
         callLater(changeLabelSize);
      }
      
      override public function setStyle(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case "textFormat_up":
               upTextFormat = param2 as TextFormat;
               break;
            case "textFormat_over":
               overTextFormat = param2 as TextFormat;
               break;
            case "textFormat_down":
               downTextFormat = param2 as TextFormat;
               break;
            case "textFormat_up":
               upTextFormat = param2 as TextFormat;
               break;
            case "disabledTextFormat":
               break;
            case "textFormat_selected":
               selectedOverTextFormat = param2 as TextFormat;
               selectedUpTextFormat = param2 as TextFormat;
               selectedDownTextFormat = param2 as TextFormat;
               break;
            case "textPadding":
               leftMargin = param2;
               break;
            case "upSkin":
               createSkin(0,param2);
               break;
            case "overSkin":
               createSkin(1,param2);
               break;
            case "downSkin":
               createSkin(2,param2);
               break;
            case "selectedUpSkin":
               createSkin(3,param2);
               break;
            case "selectedOverSkin":
               createSkin(4,param2);
               break;
            case "selectedDownSkin":
               createSkin(4,param2);
               break;
            case "disabledSkin":
            case "selectedDisabledSkin":
               break;
            default:
               throw new Error("error style");
         }
      }
      
      private function createSkin(param1:int, param2:Object) : void
      {
         var _loc4_:Vector.<Asset> = _bitmap.clips;
         var _loc3_:Boolean = false;
         if(_loc4_ == null)
         {
            _loc3_ = true;
            _loc4_ = new Vector.<Asset>(0);
         }
         if(param2 is String)
         {
            _loc4_[param1] = UICommon.asset.getAsset(param2 as String);
            if(_loc3_)
            {
               _bitmap.clips = _loc4_;
            }
            return;
         }
         throw new Error("error skin value type!");
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         this.width = param1;
         this.height = param2;
      }
      
      public function set fontLanID(param1:String) : void
      {
         _fontLanID = param1;
         this.labelFont = I18NConfig.getText(param1);
      }
      
      public function get fontLanID() : String
      {
         return _fontLanID;
      }
      
      public function set font(param1:String) : void
      {
         this.labelFont = param1;
      }
      
      public function get font() : String
      {
         return labelFont;
      }
      
      public function set zLanID(param1:String) : void
      {
         _zLanID = param1;
         this.label = I18NConfig.getText(param1);
      }
      
      public function get zLanID() : String
      {
         return _zLanID;
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
   }
}

