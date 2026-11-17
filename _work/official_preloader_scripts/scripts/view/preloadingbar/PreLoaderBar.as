package view.preloadingbar
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.ProgressEvent;
   import flash.text.TextField;
   import res.preloader_bg;
   import res.rpg2_preloader_bg;
   
   public class PreLoaderBar extends Sprite
   {
      
      private var back:Sprite = null;
      
      private var mc_bar:MovieClip = null;
      
      private var label_progress:TextField = null;
      
      private var label_desc:TextField = null;
      
      private var totalFrame:int = 0;
      
      private var frameHelper:int = 0;
      
      public function PreLoaderBar(param1:Boolean)
      {
         super();
         rpg2_preloader_bg;
         preloader_bg;
         if(param1)
         {
            this.back = new rpg2_preloader_bg();
         }
         else
         {
            this.back = new preloader_bg();
         }
         this.mc_bar = this.back["mc_bar"] as MovieClip;
         this.label_progress = this.back["label_progress"] as TextField;
         this.label_desc = this.back["label_desc"] as TextField;
         this.addChild(this.back);
         this.label_progress.filters = null;
         this.label_desc.filters = null;
         this.totalFrame = this.mc_bar.totalFrames;
         this.label_progress.text = "";
         this.mc_bar.gotoAndStop(1);
      }
      
      public function setDesc(param1:String) : void
      {
         this.label_desc.text = param1;
      }
      
      public function setProgress(param1:ProgressEvent) : void
      {
         this.label_progress.text = (param1.bytesLoaded / param1.bytesTotal * 100).toFixed(2) + "%";
         this.frameHelper = param1.bytesLoaded / param1.bytesTotal * this.totalFrame;
         this.frameHelper = this.frameHelper <= 0 ? 1 : this.frameHelper;
         this.mc_bar.gotoAndStop(this.frameHelper);
      }
      
      public function initRate(param1:Number) : void
      {
         this.mc_bar.gotoAndStop(param1);
      }
   }
}

