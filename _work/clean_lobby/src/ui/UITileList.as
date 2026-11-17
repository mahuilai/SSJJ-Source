package ui
{
   import fl.controls.TileList;
   import flash.display.Sprite;
   import style.StyleConfig;
   import utils.InstanceUtil;
   import utils.UIUtil;
   
   public class UITileList extends TileList
   {
      
      private var _cellRendererName:String;
      
      private var _scrollBarSkins:String;
      
      public function UITileList()
      {
         super();
         init();
      }
      
      private function init() : void
      {
         setStyle("skin",Sprite);
         iconField = null;
         sourceField = null;
         horizontalScrollPolicy = "off";
         direction = "vertical";
         setRendererStyle("textFormat",StyleConfig.WHITE_FONT);
      }
      
      override public function set rowCount(param1:uint) : void
      {
         super.rowCount = param1;
      }
      
      override public function set columnCount(param1:uint) : void
      {
         super.columnCount = param1;
      }
      
      override public function set rowHeight(param1:Number) : void
      {
         super.rowHeight = param1;
      }
      
      override public function set columnWidth(param1:Number) : void
      {
         super.columnWidth = param1;
      }
      
      public function set cellRenderer(param1:Class) : void
      {
         setStyle("cellRenderer",param1);
      }
      
      public function set cellRendererName(param1:String) : void
      {
         if(_cellRendererName == param1)
         {
            return;
         }
         _cellRendererName = param1;
         setStyle("cellRenderer",InstanceUtil.getClassByName(param1));
      }
      
      public function get cellRendererName() : String
      {
         return _cellRendererName;
      }
      
      public function set scrollBarSkins(param1:String) : void
      {
         if(_scrollBarSkins == param1)
         {
            return;
         }
         _scrollBarSkins = param1;
         setStyle("upArrowUpSkin",getDefByName(param1 + "_up1"));
         setStyle("upArrowOverSkin",getDefByName(param1 + "_up2"));
         setStyle("upArrowDownSkin",getDefByName(param1 + "_up3"));
         setStyle("upArrowDisabledSkin",getDefByName(param1 + "_up4"));
         setStyle("downArrowUpSkin",getDefByName(param1 + "_down1"));
         setStyle("downArrowOverSkin",getDefByName(param1 + "_down2"));
         setStyle("downArrowDownSkin",getDefByName(param1 + "_down3"));
         setStyle("downArrowDisabledSkin",getDefByName(param1 + "_down4"));
         setStyle("thumbUpSkin",getDefByName(param1 + "_bar_thumb1"));
         setStyle("thumbOverSkin",getDefByName(param1 + "_bar_thumb2"));
         setStyle("thumbDownSkin",getDefByName(param1 + "_bar_thumb3"));
         setStyle("thumbDisabledSkin",getDefByName(param1 + "_bar_thumb4"));
         setStyle("trackUpSkin",getDefByName(param1 + "_track"));
         setStyle("trackOverSkin",getDefByName(param1 + "_track"));
         setStyle("trackDownSkin",getDefByName(param1 + "_track"));
         setStyle("trackDisabledSkin",getDefByName(param1 + "_track"));
      }
      
      public function get scrollBarSkins() : String
      {
         return _scrollBarSkins;
      }
      
      protected function getDefByName(param1:String) : Class
      {
         return UIUtil.getDefinition(param1);
      }
   }
}

