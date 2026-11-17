package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import com.junkbyte.console.ConsoleStyle;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   
   public class Ruler extends Sprite
   {
      
      private var _master:Console;
      
      private var _config:ConsoleConfig;
      
      private var _area:Rectangle;
      
      private var _pointer:Shape;
      
      private var _posTxt:TextField;
      
      private var _zoom:Bitmap;
      
      private var _points:Array;
      
      public function Ruler(param1:Console)
      {
         super();
         _master = param1;
         _config = param1.config;
         buttonMode = true;
         _points = [];
         _pointer = new Shape();
         addChild(_pointer);
         var _loc2_:Point = new Point();
         _loc2_ = globalToLocal(_loc2_);
         _area = new Rectangle(-param1.stage.stageWidth * 1.5 + _loc2_.x,-param1.stage.stageHeight * 1.5 + _loc2_.y,param1.stage.stageWidth * 3,param1.stage.stageHeight * 3);
         graphics.beginFill(_config.style.backgroundColor,0.2);
         graphics.drawRect(_area.x,_area.y,_area.width,_area.height);
         graphics.endFill();
         _posTxt = _master.panels.mainPanel.makeTF("positionText",true);
         _posTxt.autoSize = "left";
         addChild(_posTxt);
         _zoom = new Bitmap();
         _zoom.scaleY = _zoom.scaleX = 2;
         addChild(_zoom);
         addEventListener("click",onMouseClick,false,0,true);
         addEventListener("mouseMove",onMouseMove,false,0,true);
         onMouseMove();
         if(_config.rulerHidesMouse)
         {
            Mouse.hide();
         }
         _master.report("<b>Ruler started. Click on two locations to measure.</b>",-1);
      }
      
      private function onMouseMove(param1:MouseEvent = null) : void
      {
         var _loc4_:Matrix = null;
         _pointer.graphics.clear();
         _pointer.graphics.lineStyle(1,11193344,1);
         _pointer.graphics.moveTo(_area.x,mouseY);
         _pointer.graphics.lineTo(_area.x + _area.width,mouseY);
         _pointer.graphics.moveTo(mouseX,_area.y);
         _pointer.graphics.lineTo(mouseX,_area.y + _area.height);
         _pointer.blendMode = "invert";
         _posTxt.text = "<low>" + mouseX + "," + mouseY + "</low>";
         var _loc3_:BitmapData = new BitmapData(30,30);
         try
         {
            _loc4_ = new Matrix();
            _loc4_.tx = -stage.mouseX + 15;
            _loc4_.ty = -stage.mouseY + 15;
            _loc3_.draw(stage,_loc4_);
         }
         catch(err:Error)
         {
            _loc3_ = null;
         }
         _zoom.bitmapData = _loc3_;
         var _loc2_:int = 10;
         _posTxt.x = mouseX - _posTxt.width - _loc2_;
         _posTxt.y = mouseY - _posTxt.height - _loc2_;
         _zoom.x = _posTxt.x + _posTxt.width - _zoom.width;
         _zoom.y = _posTxt.y - _zoom.height;
         if(_posTxt.x < 16)
         {
            _posTxt.x = mouseX + _loc2_;
            _zoom.x = _posTxt.x;
         }
         if(_posTxt.y < 38)
         {
            _posTxt.y = mouseY + _loc2_;
            _zoom.y = _posTxt.y + _posTxt.height;
         }
      }
      
      private function onMouseClick(param1:MouseEvent) : void
      {
         var _loc13_:Point = null;
         var _loc4_:Point = null;
         var _loc2_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc10_:Point = null;
         var _loc12_:Point = null;
         var _loc9_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc8_:TextField = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         param1.stopPropagation();
         var _loc11_:ConsoleStyle = _config.style;
         if(_points.length == 0)
         {
            _loc13_ = new Point(param1.localX,param1.localY);
            graphics.lineStyle(1,16711680);
            graphics.drawCircle(_loc13_.x,_loc13_.y,3);
            _points.push(_loc13_);
         }
         else if(_points.length == 1)
         {
            _zoom.bitmapData = null;
            if(_config.rulerHidesMouse)
            {
               Mouse.show();
            }
            removeChild(_pointer);
            removeChild(_posTxt);
            removeEventListener("mouseMove",onMouseMove);
            _loc13_ = _points[0];
            _loc4_ = new Point(param1.localX,param1.localY);
            _points.push(_loc4_);
            graphics.clear();
            graphics.beginFill(_loc11_.backgroundColor,0.4);
            graphics.drawRect(_area.x,_area.y,_area.width,_area.height);
            graphics.endFill();
            graphics.lineStyle(1.5,16711680);
            graphics.drawCircle(_loc13_.x,_loc13_.y,4);
            graphics.lineStyle(1.5,16750848);
            graphics.drawCircle(_loc4_.x,_loc4_.y,4);
            _loc2_ = Point.interpolate(_loc13_,_loc4_,0.5);
            graphics.lineStyle(1,11184810);
            graphics.drawCircle(_loc2_.x,_loc2_.y,4);
            _loc5_ = _loc13_;
            _loc6_ = _loc4_;
            if(_loc13_.x > _loc4_.x)
            {
               _loc5_ = _loc4_;
               _loc6_ = _loc13_;
            }
            _loc10_ = _loc13_;
            _loc12_ = _loc4_;
            if(_loc13_.y > _loc4_.y)
            {
               _loc10_ = _loc4_;
               _loc12_ = _loc13_;
            }
            _loc9_ = _loc6_.x - _loc5_.x;
            _loc7_ = _loc12_.y - _loc10_.y;
            _loc3_ = Point.distance(_loc13_,_loc4_);
            _loc8_ = makeTxtField(_loc11_.highColor);
            _loc8_.text = round(_loc13_.x) + "," + round(_loc13_.y);
            _loc8_.x = _loc13_.x;
            _loc8_.y = _loc13_.y - (_loc10_ == _loc13_ ? 14 : 0);
            addChild(_loc8_);
            _loc8_ = makeTxtField(_loc11_.highColor);
            _loc8_.text = round(_loc4_.x) + "," + round(_loc4_.y);
            _loc8_.x = _loc4_.x;
            _loc8_.y = _loc4_.y - (_loc10_ == _loc4_ ? 14 : 0);
            addChild(_loc8_);
            if(_loc9_ > 40 || _loc7_ > 25)
            {
               _loc8_ = makeTxtField(_loc11_.lowColor);
               _loc8_.text = round(_loc2_.x) + "," + round(_loc2_.y);
               _loc8_.x = _loc2_.x;
               _loc8_.y = _loc2_.y;
               addChild(_loc8_);
            }
            graphics.lineStyle(1,11193344,0.5);
            graphics.moveTo(_area.x,_loc10_.y);
            graphics.lineTo(_area.x + _area.width,_loc10_.y);
            graphics.moveTo(_area.x,_loc12_.y);
            graphics.lineTo(_area.x + _area.width,_loc12_.y);
            graphics.moveTo(_loc5_.x,_area.y);
            graphics.lineTo(_loc5_.x,_area.y + _area.height);
            graphics.moveTo(_loc6_.x,_area.y);
            graphics.lineTo(_loc6_.x,_area.y + _area.height);
            _loc14_ = round(angle(_loc13_,_loc4_),100);
            _loc15_ = round(angle(_loc4_,_loc13_),100);
            graphics.lineStyle(1,11141120,0.8);
            drawCircleSegment(graphics,10,_loc13_,_loc14_,-90);
            graphics.lineStyle(1,13404160,0.8);
            drawCircleSegment(graphics,10,_loc4_,_loc15_,-90);
            graphics.lineStyle(2,65280,0.7);
            graphics.moveTo(_loc13_.x,_loc13_.y);
            graphics.lineTo(_loc4_.x,_loc4_.y);
            _master.report("Ruler results: (red) <b>[" + _loc13_.x + "," + _loc13_.y + "]</b> to (orange) <b>[" + _loc4_.x + "," + _loc4_.y + "]</b>",-2);
            _master.report("Distance: <b>" + round(_loc3_,100) + "</b>",-2);
            _master.report("Mid point: <b>[" + _loc2_.x + "," + _loc2_.y + "]</b>",-2);
            _master.report("Width:<b>" + _loc9_ + "</b>, Height: <b>" + _loc7_ + "</b>",-2);
            _master.report("Angle from first point (red): <b>" + _loc14_ + "°</b>",-2);
            _master.report("Angle from second point (orange): <b>" + _loc15_ + "°</b>",-2);
         }
         else
         {
            exit();
         }
      }
      
      public function exit() : void
      {
         _master = null;
         dispatchEvent(new Event("complete"));
      }
      
      private function makeTxtField(param1:Number, param2:Boolean = true) : TextField
      {
         var _loc3_:TextFormat = new TextFormat(_config.style.menuFont,_config.style.menuFontSize,param1,param2,true,null,null,"right");
         var _loc4_:TextField = new TextField();
         _loc4_.autoSize = "right";
         _loc4_.selectable = false;
         _loc4_.defaultTextFormat = _loc3_;
         return _loc4_;
      }
      
      private function round(param1:Number, param2:uint = 10) : Number
      {
         return Math.round(param1 * param2) / param2;
      }
      
      private function angle(param1:Point, param2:Point) : Number
      {
         var _loc3_:Number = Math.atan2(param2.y - param1.y,param2.x - param1.x) / 3.141592653589793 * 180;
         _loc3_ += 90;
         if(_loc3_ > 180)
         {
            _loc3_ -= 360;
         }
         return _loc3_;
      }
      
      private function drawCircleSegment(param1:Graphics, param2:Number, param3:Point, param4:Number = 180, param5:Number = 0) : Point
      {
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc11_:Point = null;
         var _loc13_:Boolean = false;
         if(param4 < 0)
         {
            _loc13_ = true;
            param4 = Math.abs(param4);
         }
         var _loc15_:Number = param4 * 3.141592653589793 / 180;
         var _loc6_:Number = param5 * 3.141592653589793 / 180;
         var _loc12_:Point = getPointOnCircle(param2,_loc6_);
         _loc12_.offset(param3.x,param3.y);
         param1.moveTo(_loc12_.x,_loc12_.y);
         var _loc7_:Number = 0;
         _loc9_ = 1;
         while(_loc9_ <= _loc15_ + 1)
         {
            _loc10_ = _loc9_ <= _loc15_ ? _loc9_ : _loc15_;
            _loc8_ = _loc10_ - _loc7_;
            _loc14_ = 1 + 0.12 * _loc8_ * _loc8_;
            _loc11_ = getPointOnCircle(param2 * _loc14_,(_loc10_ - _loc8_ / 2) * (_loc13_ ? -1 : 1) + _loc6_);
            _loc11_.offset(param3.x,param3.y);
            _loc12_ = getPointOnCircle(param2,_loc10_ * (_loc13_ ? -1 : 1) + _loc6_);
            _loc12_.offset(param3.x,param3.y);
            param1.curveTo(_loc11_.x,_loc11_.y,_loc12_.x,_loc12_.y);
            _loc7_ = _loc10_;
            _loc9_++;
         }
         return _loc12_;
      }
      
      private function getPointOnCircle(param1:Number, param2:Number) : Point
      {
         return new Point(param1 * Math.cos(param2),param1 * Math.sin(param2));
      }
   }
}

