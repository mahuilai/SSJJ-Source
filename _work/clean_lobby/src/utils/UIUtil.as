package utils
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import ui.UIAsset;
   import ui.UIAssetsLoader;
   import ui.UIBase;
   import ui.UIButton;
   import ui.UICheckBox;
   import ui.UIClip;
   import ui.UICombobox;
   import ui.UIContainer;
   import ui.UIDataGrid;
   import ui.UIGroup;
   import ui.UIImage;
   import ui.UIImageNumber;
   import ui.UILabel;
   import ui.UIList;
   import ui.UIPage;
   import ui.UIProgressBar;
   import ui.UIRadioButton;
   import ui.UIScrollBar;
   import ui.UIScrollPane;
   import ui.UISlider;
   import ui.UITabButton;
   import ui.UITabPanel;
   import ui.UITextInput;
   import ui.UITileList;
   import ui.core.UICommon;
   import ui.core.UIComponent;
   
   public class UIUtil
   {
      
      private static var userInstace:Dictionary = new Dictionary();
      
      public static var assetClassDic:Dictionary = new Dictionary(true);
      
      private static const excludePreperties:Vector.<String> = Vector.<String>(["skins","skin","autoSize","height","columnWidth","rowHeight","columnCount","rowCount"]);
      
      private static var _tf:TextField = new TextField();
      
      public function UIUtil()
      {
         super();
      }
      
      public static function initUI(param1:DisplayObjectContainer, param2:XML, rootXml:XML = null) : void
      {
         if(rootXml == null) { rootXml = param2; }
         var _loc7_:XML = null;
         var _loc3_:DisplayObject = null;
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc5_:String = null;
         var _loc8_:String = null;
         initJsonString(param1,param2.@properties);
         for each(_loc7_ in param2.*)
         {
            _loc3_ = null;
            _loc4_ = _loc7_.@name;
            _loc6_ = _loc7_.@target;
            if(_loc4_ != "" && (_loc4_ in param1)) { try { _loc3_ = param1[_loc4_]; } catch(e:Error) {} }
            switch(_loc7_.name().toString())
            {
               case "UIImage":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIImage();
                  }
                  break;
               case "UIImageNumber":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIImageNumber();
                  }
                  break;
               case "UILabel":
                  if(!_loc3_)
                  {
                     _loc3_ = new UILabel();
                  }
                  break;
               case "UITextInput":
                  if(!_loc3_)
                  {
                     _loc3_ = new UITextInput();
                  }
                  break;
               case "UIButton":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIButton();
                  }
                  break;
               case "UIClip":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIClip();
                  }
                  break;
               case "MovieClip":
                  if(!_loc3_)
                  {
                     if(String(_loc7_.@definition) != "")
                     {
                        _loc3_ = getInstance(_loc7_.@definition);
                     }
                     else
                     {
                        _loc3_ = new MovieClip();
                     }
                  }
                  break;
               case "Sprite":
                  if(!_loc3_)
                  {
                     if(String(_loc7_.@definition) != "")
                     {
                        _loc3_ = getInstance(_loc7_.@definition);
                     }
                     else
                     {
                        _loc3_ = new Sprite();
                     }
                  }
                  break;
               case "UIContainer":
                  if(_loc4_ != "" && (_loc4_ in param1)) { try { _loc3_ = param1[_loc4_]; } catch(e:Error) {} }
                  if(_loc3_ == null)
                  {
                     _loc3_ = new UIContainer();
                  }
                  (_loc3_ as UIContainer).initUI(_loc7_);
                  break;
               case "UIComponent":
                  if(_loc4_ != "" && (_loc4_ in param1))
                  {
                     try { _loc3_ = param1[_loc4_]; } catch(e:Error) {}
                  }
                  if(!_loc3_)
                  {
                     var _clsName:String = String(_loc7_.@className);
                     if(_clsName != "" && rootXml != null && rootXml[_clsName].length() > 0)
                     {
                        var _subComp:UIContainer = new UIContainer();
                        initUI(_subComp, rootXml[_clsName][0], rootXml);
                        _loc3_ = _subComp;
                     }
                     else if(String(_loc7_.@definition) != "")
                     {
                        _loc3_ = getInstance(_loc7_.@definition);
                     }
                     if(!_loc3_)
                     {
                        _loc3_ = new UIContainer();
                     }
                  }
                  break;
               case "DisplayObject":
                  if(String(_loc7_.@definition) != "")
                  {
                     _loc3_ = getInstance(_loc7_.@definition);
                  }
                  break;
               case "UIProgressBar":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIProgressBar();
                  }
                  break;
               case "UISlider":
                  if(!_loc3_)
                  {
                     _loc3_ = new UISlider();
                  }
                  break;
               case "UIGroup":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIGroup();
                  }
                  break;
               case "UIPage":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIPage();
                  }
                  break;
               case "UIScrollBar":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIScrollBar();
                  }
                  break;
               case "ExtComponent":
                  if(!_loc3_)
                  {
                     if(String(_loc7_.@definition) != "")
                     {
                        _loc3_ = getInstance(_loc7_.@definition);
                     }
                     if(!_loc3_)
                     {
                        _loc3_ = new UIContainer();
                     }
                  }
                  break;
               case "UIAsset":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIAsset();
                  }
                  break;
               case "UICheckBox":
                  if(!_loc3_)
                  {
                     _loc3_ = new UICheckBox();
                  }
                  break;
               case "UICombobox":
                  if(!_loc3_)
                  {
                     _loc3_ = new UICombobox();
                  }
                  break;
               case "UIDataGrid":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIDataGrid();
                  }
                  break;
               case "UIList":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIList();
                  }
                  break;
               case "UITileList":
                  if(!_loc3_)
                  {
                     _loc3_ = new UITileList();
                  }
                  break;
               case "UIRadioButton":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIRadioButton();
                  }
                  break;
               case "UIScrollPane":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIScrollPane();
                  }
                  if(_loc6_ != "")
                  {
                     (_loc3_ as UIScrollPane).content = param1[_loc6_];
                  }
                  break;
               case "UITabButton":
                  if(!_loc3_)
                  {
                     _loc3_ = new UITabButton();
                  }
                  break;
               case "UITabPanel":
                  if(!_loc3_)
                  {
                     _loc3_ = new UITabPanel();
                  }
                  break;
               case "TextField":
                  if(!_loc3_)
                  {
                     _loc3_ = new TextField();
                  }
                  break;
               case "UIAssetsLoader":
                  if(!_loc3_)
                  {
                     _loc3_ = new UIAssetsLoader();
                  }
                  break;
               default:
                  _loc3_ = null;
            }
            if(_loc3_ != null)
            {
               if(_loc3_ is UIComponent || _loc3_ is UIBase || _loc3_ is UIContainer == false)
               {
                  initJsonString(_loc3_,_loc7_.@properties);
               }
               if(_loc4_ != "") { try { param1[_loc4_] = _loc3_; } catch(e:Error) {} _loc3_.name = _loc4_; }
               _loc5_ = _loc7_.@parent;
               if(_loc5_ != "")
               {
                  if(_loc5_ != "null")
                  {
                     if(param1.hasOwnProperty(_loc5_) && param1[_loc5_] != null) {
                        param1[_loc5_].addChild(_loc3_);
                     } else {
                        param1.addChild(_loc3_);
                     }
                  }
               }
               else
               {
                  param1.addChild(_loc3_);
               }
            }
         }
      }
      
      public static function autoUI(param1:DisplayObject, param2:DisplayObjectContainer = null, param3:Object = null, param4:String = null) : *
      {
         if(param2)
         {
            param2.addChild(param1);
         }
         if(param3)
         {
            initObject(param1,param3);
         }
         if(param4)
         {
            initJsonString(param1,param4);
         }
         return param1;
      }
      
      public static function initJsonString(param1:Object, param2:String) : void
      {
         if(param2.length > 0)
         {
            param2 = param2.replace(/'/g,"\"");
            initObject(param1,JSON.parse(param2));
         }
      }
      
      public static function registerUserInstance(param1:String, param2:*) : void
      {
         userInstace[param1] = param2;
      }
      
      public static function removeUserInstance(param1:String) : void
      {
         delete userInstace[param1];
      }
      
      public static function clearUserIntance() : void
      {
         userInstace = new Dictionary();
      }
      
      public static function getInstance(param1:String) : *
      {
         var _loc2_:Class = null;
         if(userInstace.hasOwnProperty(param1))
         {
            return userInstace[param1];
         }
         try
         {
            _loc2_ = getDefinition(param1) as Class;
            return new _loc2_();
         }
         catch(error:Error)
         {
            trace("========get Instance By Name error! name:" + param1);
            trace(error.message + "," + error.getStackTrace());
            var _loc5_:* = null;
         }
         return _loc5_;
      }
      
      public static function hasDefinition(param1:String) : Boolean
      {
         if(UICommon.localAsset)
         {
            return UICommon.localAsset.hasDefinition(param1);
         }
         return getDefinition(param1) != null;
      }
      
      public static function getDefinition(param1:String) : *
      {
         var _loc2_:Class = null;
         try
         {
            _loc2_ = getGameDefinitionByName(param1) as Class;
            if(_loc2_ == null)
            {
               _loc2_ = getDefinitionByAssetClass(param1);
            }
            return _loc2_;
         }
         catch(error:Error)
         {
            var _loc5_:* = null;
         }
         return _loc5_;
      }
      
      private static function getGameDefinitionByName(param1:String) : Object
      {
         var _loc2_:Class = null;
         try
         {
            _loc2_ = getDefinitionByName(param1) as Class;
         }
         catch(e:Error)
         {
            trace("getGameDefinitionByName " + param1 + " not exist");
            try
            {
            }
            catch(e:Error)
            {
            }
         }
         return _loc2_;
      }
      
      public static function getDefinitionByAssetClass(param1:String) : *
      {
         var _loc3_:* = null;
         var _loc4_:Class = null;
         var _loc2_:String = null;
         try
         {
            if(assetClassDic[param1])
            {
               _loc4_ = assetClassDic[param1];
            }
            if(!_loc4_)
            {
               _loc4_ = getDefinitionByName("assets." + param1.split(".")[0]) as Class;
               assetClassDic[param1] = _loc4_;
            }
            if(_loc4_)
            {
               _loc2_ = param1.split(".")[1];
               return _loc4_[_loc2_.toLocaleUpperCase()];
            }
         }
         catch(error:Error)
         {
            trace("========get Assets By Name error! name:" + param1);
            return null;
         }
      }
      
      public static function initObject(param1:Object, param2:Object) : *
      {
         if(param2.skins != null)
         {
            param1.skins = param2.skins;
         }
         if(param2.skin != null)
         {
            param1.skin = param2.skin;
         }
         if(param2.autoSize)
         {
            param1.autoSize = param2.autoSize;
         }
         if(param2.height)
         {
            param1.height = param2.height;
         }
         if(param2.columnWidth)
         {
            param1.columnWidth = param2.columnWidth;
         }
         if(param2.rowHeight)
         {
            param1.rowHeight = param2.rowHeight;
         }
         if(param2.columnCount)
         {
            param1.columnCount = param2.columnCount;
         }
         if(param2.rowCount)
         {
            param1.rowCount = param2.rowCount;
         }
         for(var _loc3_ in param2)
         {
            if(excludePreperties.indexOf(_loc3_) <= -1)
            {
               if(!(_loc3_ == "autoSize" && param1 is UILabel && (_loc3_ == "width" || _loc3_ == "height")))
               {
                  try
                  {
                     if(isSampleType(param2[_loc3_]) == false && param1[_loc3_] != null)
                     {
                        initObject(param1[_loc3_],param2[_loc3_]);
                     }
                     else
                     {
                        param1[_loc3_] = param2[_loc3_];
                     }
                  }
                  catch(error:Error)
                  {
                     trace("\n");
                     trace("-=-=-=-=-=-=-=-=-= initObject Error -=-=-=-=-=-=-=-=-=-");
                     trace("    target:",param1);
                     trace("properties:",_loc3_);
                     trace("     value:",param2[_loc3_]);
                     trace("     error:",error.message);
                     trace("-=-=-=-=-=-=-=-=-=-=-=-= END =-=-=-=-=-=-=-=-=-=-=-=-=-");
                     trace("\n");
                     continue;
                  }
               }
            }
         }
         return param1;
      }
      
      public static function isSampleType(param1:Object) : Boolean
      {
         if(param1 is int || param1 is String || param1 is Boolean || param1 is Number || param1 is uint || param1 is Array)
         {
            return true;
         }
         return false;
      }
      
      public static function getTextField(param1:TextFormat, param2:String = "Test") : TextField
      {
         _tf.autoSize = "left";
         _tf.defaultTextFormat = param1;
         _tf.text = param2;
         return _tf;
      }
   }
}

