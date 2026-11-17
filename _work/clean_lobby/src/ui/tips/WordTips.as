package ui.tips
{
   import flash.display.Sprite;
   
   public class WordTips extends Sprite implements IToolTips
   {
      
      private var tipsText:TipWordTextField;
      
      private var MAX_WID:uint = 280;
      
      private var preParams:Array;
      
      public function WordTips()
      {
         super();
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      public function dispose() : void
      {
      }
      
      public function show(param1:Array) : void
      {
         if(preParams && preParams[0] == param1[0])
         {
            return;
         }
         if(tipsText == null)
         {
            tipsText = new TipWordTextField();
            tipsText.wordWrap = true;
         }
         if(param1.length >= 2)
         {
            tipsText.width = int(param1[1]);
         }
         else
         {
            tipsText.width = MAX_WID;
         }
         tipsText.htmlText = param1[0];
         var _loc2_:uint = tipsText.textWidth + 10;
         if(_loc2_ < MAX_WID)
         {
            tipsText.width = _loc2_;
         }
         tipsText.height = tipsText.textHeight + 18;
         tipsText.x = 13;
         tipsText.y = 5;
         if(!contains(tipsText))
         {
            addChild(tipsText);
         }
         drawBg();
      }
      
      private function drawBg() : void
      {
         graphics.clear();
         graphics.lineStyle(1,6710886,0.5);
         graphics.beginFill(0,0.8);
         graphics.drawRoundRect(0,0,tipsText.width + 20,tipsText.height - 3,10,10);
         graphics.endFill();
      }
      
      public function hide() : void
      {
         visible = false;
      }
      
      public function getWidth() : int
      {
         return width;
      }
      
      public function getHeight() : int
      {
         return height;
      }
   }
}

import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFormat;

class TipWordTextField extends TextField
{
   
   private static var _TIP_FONT:TextFormat = null;
   
   public function TipWordTextField(param1:String = "")
   {
      super();
      this.selectable = false;
      this.defaultTextFormat = TIP_FONT;
      var _loc2_:GlowFilter = new GlowFilter(0,1,2,2,2000);
      filters = [_loc2_];
      this.text = param1;
   }
   
   public static function get TIP_FONT() : TextFormat
   {
      if(null == _TIP_FONT)
      {
         _TIP_FONT = new TextFormat("宋体",12,16777215,null,null,null,null,null,null,null,null,null,8);
      }
      return _TIP_FONT;
   }
}
