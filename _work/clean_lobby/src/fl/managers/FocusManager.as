package fl.managers
{
   import fl.controls.Button;
   import fl.core.UIComponent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.SimpleButton;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.*;
   
   public class FocusManager implements IFocusManager
   {
      
      private var _form:DisplayObjectContainer;
      
      private var focusableObjects:Dictionary;
      
      private var focusableCandidates:Array;
      
      private var activated:Boolean = false;
      
      private var calculateCandidates:Boolean = true;
      
      private var lastFocus:InteractiveObject;
      
      private var _showFocusIndicator:Boolean = true;
      
      private var lastAction:String;
      
      private var defButton:Button;
      
      private var _defaultButton:Button;
      
      private var _defaultButtonEnabled:Boolean = true;
      
      public function FocusManager(param1:DisplayObjectContainer)
      {
         super();
         focusableObjects = new Dictionary(true);
         if(param1 != null)
         {
            _form = param1;
            activate();
         }
      }
      
      private function addedHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         if(_loc2_.stage)
         {
            addFocusables(DisplayObject(param1.target));
         }
      }
      
      private function removedHandler(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc3_:InteractiveObject = null;
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         if(_loc2_ is IFocusManagerComponent && focusableObjects[_loc2_] == true)
         {
            if(_loc2_ == lastFocus)
            {
               IFocusManagerComponent(lastFocus).drawFocus(false);
               lastFocus = null;
            }
            _loc2_.removeEventListener("tabEnabledChange",tabEnabledChangeHandler,false);
            delete focusableObjects[_loc2_];
            calculateCandidates = true;
         }
         else if(_loc2_ is InteractiveObject && focusableObjects[_loc2_] == true)
         {
            _loc3_ = _loc2_ as InteractiveObject;
            if(_loc3_)
            {
               if(_loc3_ == lastFocus)
               {
                  lastFocus = null;
               }
               delete focusableObjects[_loc3_];
               calculateCandidates = true;
            }
            _loc2_.addEventListener("tabEnabledChange",tabEnabledChangeHandler,false,0,true);
         }
         removeFocusables(_loc2_);
      }
      
      private function addFocusables(param1:DisplayObject, param2:Boolean = false) : void
      {
         var _loc5_:IFocusManagerComponent = null;
         var _loc7_:InteractiveObject = null;
         var _loc6_:DisplayObjectContainer = null;
         var _loc4_:DisplayObjectContainer = null;
         var _loc8_:int = 0;
         var _loc3_:DisplayObject = null;
         if(!param2)
         {
            if(param1 is IFocusManagerComponent)
            {
               _loc5_ = IFocusManagerComponent(param1);
               if(_loc5_.focusEnabled)
               {
                  if(_loc5_.tabEnabled && isTabVisible(param1))
                  {
                     focusableObjects[param1] = true;
                     calculateCandidates = true;
                  }
                  param1.addEventListener("tabEnabledChange",tabEnabledChangeHandler,false,0,true);
                  param1.addEventListener("tabIndexChange",tabIndexChangeHandler,false,0,true);
               }
            }
            else if(param1 is InteractiveObject)
            {
               _loc7_ = param1 as InteractiveObject;
               if(_loc7_ && _loc7_.tabEnabled && findFocusManagerComponent(_loc7_) == _loc7_)
               {
                  focusableObjects[_loc7_] = true;
                  calculateCandidates = true;
               }
               _loc7_.addEventListener("tabEnabledChange",tabEnabledChangeHandler,false,0,true);
               _loc7_.addEventListener("tabIndexChange",tabIndexChangeHandler,false,0,true);
            }
         }
         if(param1 is DisplayObjectContainer)
         {
            _loc6_ = DisplayObjectContainer(param1);
            param1.addEventListener("tabChildrenChange",tabChildrenChangeHandler,false,0,true);
            _loc4_ = null;
            try
            {
               _loc4_ = _loc6_.parent;
            }
            catch(se:SecurityError)
            {
               _loc4_ = null;
            }
            if(_loc6_ is Stage || _loc4_ is Stage || _loc6_.tabChildren)
            {
               _loc8_ = 0;
               while(_loc8_ < _loc6_.numChildren)
               {
                  try
                  {
                     _loc3_ = _loc6_.getChildAt(_loc8_);
                     if(_loc3_ != null)
                     {
                        addFocusables(_loc6_.getChildAt(_loc8_));
                     }
                  }
                  catch(error:SecurityError)
                  {
                  }
                  _loc8_++;
               }
            }
         }
      }
      
      private function removeFocusables(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObject = null;
         if(param1 is DisplayObjectContainer)
         {
            param1.removeEventListener("tabChildrenChange",tabChildrenChangeHandler,false);
            param1.removeEventListener("tabIndexChange",tabIndexChangeHandler,false);
            for(var _loc3_ in focusableObjects)
            {
               _loc2_ = DisplayObject(_loc3_);
               if(DisplayObjectContainer(param1).contains(_loc2_))
               {
                  if(_loc2_ == lastFocus)
                  {
                     lastFocus = null;
                  }
                  _loc2_.removeEventListener("tabEnabledChange",tabEnabledChangeHandler,false);
                  delete focusableObjects[_loc3_];
                  calculateCandidates = true;
               }
            }
         }
      }
      
      private function isTabVisible(param1:DisplayObject) : Boolean
      {
         var _loc2_:DisplayObjectContainer = null;
         try
         {
            _loc2_ = param1.parent;
            while(_loc2_ && !(_loc2_ is Stage) && !(_loc2_.parent && _loc2_.parent is Stage))
            {
               if(!_loc2_.tabChildren)
               {
                  return false;
               }
               _loc2_ = _loc2_.parent;
            }
         }
         catch(se:SecurityError)
         {
         }
         return true;
      }
      
      private function isValidFocusCandidate(param1:DisplayObject, param2:String) : Boolean
      {
         var _loc3_:IFocusManagerGroup = null;
         if(!isEnabledAndVisible(param1))
         {
            return false;
         }
         if(param1 is IFocusManagerGroup)
         {
            _loc3_ = IFocusManagerGroup(param1);
            if(param2 == _loc3_.groupName)
            {
               return false;
            }
         }
         return true;
      }
      
      private function isEnabledAndVisible(param1:DisplayObject) : Boolean
      {
         var _loc2_:DisplayObjectContainer = null;
         var _loc4_:TextField = null;
         var _loc3_:SimpleButton = null;
         try
         {
            _loc2_ = DisplayObject(form).parent;
            while(param1 != _loc2_)
            {
               if(param1 is UIComponent)
               {
                  if(!UIComponent(param1).enabled)
                  {
                     return false;
                  }
               }
               else if(param1 is TextField)
               {
                  _loc4_ = TextField(param1);
                  if(_loc4_.type == "dynamic" || !_loc4_.selectable)
                  {
                     return false;
                  }
               }
               else if(param1 is SimpleButton)
               {
                  _loc3_ = SimpleButton(param1);
                  if(!_loc3_.enabled)
                  {
                     return false;
                  }
               }
               if(!param1.visible)
               {
                  return false;
               }
               param1 = param1.parent;
            }
         }
         catch(se:SecurityError)
         {
         }
         return true;
      }
      
      private function tabEnabledChangeHandler(param1:Event) : void
      {
         calculateCandidates = true;
         var _loc2_:InteractiveObject = InteractiveObject(param1.target);
         var _loc3_:Boolean = focusableObjects[_loc2_] == true;
         if(_loc2_.tabEnabled)
         {
            if(!_loc3_ && isTabVisible(_loc2_))
            {
               if(!(_loc2_ is IFocusManagerComponent))
               {
                  _loc2_.focusRect = false;
               }
               focusableObjects[_loc2_] = true;
            }
         }
         else if(_loc3_)
         {
            delete focusableObjects[_loc2_];
         }
      }
      
      private function tabIndexChangeHandler(param1:Event) : void
      {
         calculateCandidates = true;
      }
      
      private function tabChildrenChangeHandler(param1:Event) : void
      {
         if(param1.target != param1.currentTarget)
         {
            return;
         }
         calculateCandidates = true;
         var _loc2_:DisplayObjectContainer = DisplayObjectContainer(param1.target);
         if(_loc2_.tabChildren)
         {
            addFocusables(_loc2_,true);
         }
         else
         {
            removeFocusables(_loc2_);
         }
      }
      
      public function activate() : void
      {
         if(activated)
         {
            return;
         }
         addFocusables(form);
         form.addEventListener("added",addedHandler,false,0,true);
         form.addEventListener("removed",removedHandler,false,0,true);
         try
         {
            form.stage.addEventListener("mouseFocusChange",mouseFocusChangeHandler,false,0,true);
            form.stage.addEventListener("keyFocusChange",keyFocusChangeHandler,false,0,true);
            form.stage.addEventListener("activate",activateHandler,false,0,true);
            form.stage.addEventListener("deactivate",deactivateHandler,false,0,true);
         }
         catch(se:SecurityError)
         {
            form.addEventListener("mouseFocusChange",mouseFocusChangeHandler,false,0,true);
            form.addEventListener("keyFocusChange",keyFocusChangeHandler,false,0,true);
            form.addEventListener("activate",activateHandler,false,0,true);
            form.addEventListener("deactivate",deactivateHandler,false,0,true);
         }
         form.addEventListener("focusIn",focusInHandler,true,0,true);
         form.addEventListener("focusOut",focusOutHandler,true,0,true);
         form.addEventListener("mouseDown",mouseDownHandler,false,0,true);
         form.addEventListener("keyDown",keyDownHandler,true,0,true);
         activated = true;
         if(lastFocus)
         {
            setFocus(lastFocus);
         }
      }
      
      public function deactivate() : void
      {
         if(!activated)
         {
            return;
         }
         focusableObjects = new Dictionary(true);
         focusableCandidates = null;
         lastFocus = null;
         defButton = null;
         form.removeEventListener("added",addedHandler,false);
         form.removeEventListener("removed",removedHandler,false);
         try
         {
            form.stage.removeEventListener("mouseFocusChange",mouseFocusChangeHandler,false);
            form.stage.removeEventListener("keyFocusChange",keyFocusChangeHandler,false);
            form.stage.removeEventListener("activate",activateHandler,false);
            form.stage.removeEventListener("deactivate",deactivateHandler,false);
         }
         catch(se:SecurityError)
         {
         }
         form.removeEventListener("mouseFocusChange",mouseFocusChangeHandler,false);
         form.removeEventListener("keyFocusChange",keyFocusChangeHandler,false);
         form.removeEventListener("activate",activateHandler,false);
         form.removeEventListener("deactivate",deactivateHandler,false);
         form.removeEventListener("focusIn",focusInHandler,true);
         form.removeEventListener("focusOut",focusOutHandler,true);
         form.removeEventListener("mouseDown",mouseDownHandler,false);
         form.removeEventListener("keyDown",keyDownHandler,true);
         activated = false;
      }
      
      private function focusInHandler(param1:FocusEvent) : void
      {
         var _loc3_:Button = null;
         if(!activated)
         {
            return;
         }
         var _loc2_:InteractiveObject = InteractiveObject(param1.target);
         if(form.contains(_loc2_))
         {
            lastFocus = findFocusManagerComponent(InteractiveObject(_loc2_));
            if(lastFocus is Button)
            {
               _loc3_ = Button(lastFocus);
               if(defButton)
               {
                  defButton.emphasized = false;
                  defButton = _loc3_;
                  _loc3_.emphasized = true;
               }
            }
            else if(defButton && defButton != _defaultButton)
            {
               defButton.emphasized = false;
               defButton = _defaultButton;
               _defaultButton.emphasized = true;
            }
         }
      }
      
      private function focusOutHandler(param1:FocusEvent) : void
      {
         if(!activated)
         {
            return;
         }
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
      }
      
      private function activateHandler(param1:Event) : void
      {
         if(!activated)
         {
            return;
         }
         var _loc2_:InteractiveObject = InteractiveObject(param1.target);
         if(lastFocus)
         {
            if(lastFocus is IFocusManagerComponent)
            {
               IFocusManagerComponent(lastFocus).setFocus();
            }
            else
            {
               form.stage.focus = lastFocus;
            }
         }
         lastAction = "ACTIVATE";
      }
      
      private function deactivateHandler(param1:Event) : void
      {
         if(!activated)
         {
            return;
         }
         var _loc2_:InteractiveObject = InteractiveObject(param1.target);
      }
      
      private function mouseFocusChangeHandler(param1:FocusEvent) : void
      {
         if(!activated)
         {
            return;
         }
         if(param1.relatedObject is TextField)
         {
            return;
         }
         param1.preventDefault();
      }
      
      private function keyFocusChangeHandler(param1:FocusEvent) : void
      {
         if(!activated)
         {
            return;
         }
         showFocusIndicator = true;
         if((param1.keyCode == 9 || param1.keyCode == 0) && !param1.isDefaultPrevented())
         {
            setFocusToNextObject(param1);
            param1.preventDefault();
         }
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(!activated)
         {
            return;
         }
         if(param1.keyCode == 9)
         {
            lastAction = "KEY";
            if(calculateCandidates)
            {
               sortFocusableObjects();
               calculateCandidates = false;
            }
         }
         if(defaultButtonEnabled && param1.keyCode == 13 && defaultButton && defButton.enabled)
         {
            sendDefaultButtonEvent();
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         if(!activated)
         {
            return;
         }
         if(param1.isDefaultPrevented())
         {
            return;
         }
         var _loc2_:InteractiveObject = getTopLevelFocusTarget(InteractiveObject(param1.target));
         if(!_loc2_)
         {
            return;
         }
         showFocusIndicator = false;
         if((_loc2_ != lastFocus || lastAction == "ACTIVATE") && !(_loc2_ is TextField))
         {
            setFocus(_loc2_);
         }
         lastAction = "MOUSEDOWN";
      }
      
      public function get defaultButton() : Button
      {
         return _defaultButton;
      }
      
      public function set defaultButton(param1:Button) : void
      {
         var _loc2_:Button = param1 ? Button(param1) : null;
         if(_loc2_ != _defaultButton)
         {
            if(_defaultButton)
            {
               _defaultButton.emphasized = false;
            }
            if(defButton)
            {
               defButton.emphasized = false;
            }
            _defaultButton = _loc2_;
            defButton = _loc2_;
            if(_loc2_)
            {
               _loc2_.emphasized = true;
            }
         }
      }
      
      public function sendDefaultButtonEvent() : void
      {
         defButton.dispatchEvent(new MouseEvent("click"));
      }
      
      private function setFocusToNextObject(param1:FocusEvent) : void
      {
         if(!hasFocusableObjects())
         {
            return;
         }
         var _loc2_:InteractiveObject = getNextFocusManagerComponent(param1.shiftKey);
         if(_loc2_)
         {
            setFocus(_loc2_);
         }
      }
      
      private function hasFocusableObjects() : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Dictionary = focusableObjects;
         for(var _loc1_ in _loc2_)
         {
            return true;
         }
         return false;
      }
      
      public function getNextFocusManagerComponent(param1:Boolean = false) : InteractiveObject
      {
         var _loc5_:IFocusManagerGroup = null;
         if(!hasFocusableObjects())
         {
            return null;
         }
         if(calculateCandidates)
         {
            sortFocusableObjects();
            calculateCandidates = false;
         }
         var _loc6_:DisplayObject = form.stage.focus;
         _loc6_ = DisplayObject(findFocusManagerComponent(InteractiveObject(_loc6_)));
         var _loc2_:String = "";
         if(_loc6_ is IFocusManagerGroup)
         {
            _loc5_ = IFocusManagerGroup(_loc6_);
            _loc2_ = _loc5_.groupName;
         }
         var _loc8_:int = getIndexOfFocusedObject(_loc6_);
         var _loc4_:Boolean = false;
         var _loc3_:int = _loc8_;
         if(_loc8_ == -1)
         {
            if(param1)
            {
               _loc8_ = int(focusableCandidates.length);
            }
            _loc4_ = true;
         }
         var _loc7_:int = getIndexOfNextObject(_loc8_,param1,_loc4_,_loc2_);
         return findFocusManagerComponent(focusableCandidates[_loc7_]);
      }
      
      private function getIndexOfFocusedObject(param1:DisplayObject) : int
      {
         var _loc2_:int = int(focusableCandidates.length);
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(focusableCandidates[_loc3_] == param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      private function getIndexOfNextObject(param1:int, param2:Boolean, param3:Boolean, param4:String) : int
      {
         var _loc9_:DisplayObject = null;
         var _loc5_:IFocusManagerGroup = null;
         var _loc11_:int = 0;
         var _loc10_:DisplayObject = null;
         var _loc6_:IFocusManagerGroup = null;
         var _loc8_:int = int(focusableCandidates.length);
         var _loc7_:int = param1;
         while(true)
         {
            if(param2)
            {
               param1--;
            }
            else
            {
               param1++;
            }
            if(param3)
            {
               if(param2 && param1 < 0)
               {
                  break;
               }
               if(!param2 && param1 == _loc8_)
               {
                  break;
               }
            }
            else
            {
               param1 = int((param1 + _loc8_) % _loc8_);
               if(_loc7_ == param1)
               {
                  break;
               }
            }
            if(isValidFocusCandidate(focusableCandidates[param1],param4))
            {
               _loc9_ = DisplayObject(findFocusManagerComponent(focusableCandidates[param1]));
               if(_loc9_ is IFocusManagerGroup)
               {
                  _loc5_ = IFocusManagerGroup(_loc9_);
                  _loc11_ = 0;
                  while(_loc11_ < focusableCandidates.length)
                  {
                     _loc10_ = focusableCandidates[_loc11_];
                     if(_loc10_ is IFocusManagerGroup)
                     {
                        _loc6_ = IFocusManagerGroup(_loc10_);
                        if(_loc6_.groupName == _loc5_.groupName && _loc6_.selected)
                        {
                           param1 = _loc11_;
                           break;
                        }
                     }
                     _loc11_++;
                  }
               }
               return param1;
            }
         }
         return param1;
      }
      
      private function sortFocusableObjects() : void
      {
         var _loc1_:InteractiveObject = null;
         focusableCandidates = [];
         for(var _loc2_ in focusableObjects)
         {
            _loc1_ = InteractiveObject(_loc2_);
            if(_loc1_.tabIndex && !isNaN(_loc1_.tabIndex) && _loc1_.tabIndex > 0)
            {
               sortFocusableObjectsTabIndex();
               return;
            }
            focusableCandidates.push(_loc1_);
         }
         focusableCandidates.sort(sortByDepth);
      }
      
      private function sortFocusableObjectsTabIndex() : void
      {
         var _loc1_:InteractiveObject = null;
         focusableCandidates = [];
         for(var _loc2_ in focusableObjects)
         {
            _loc1_ = InteractiveObject(_loc2_);
            if(_loc1_.tabIndex && !isNaN(_loc1_.tabIndex))
            {
               focusableCandidates.push(_loc1_);
            }
         }
         focusableCandidates.sort(sortByTabIndex);
      }
      
      private function sortByDepth(param1:InteractiveObject, param2:InteractiveObject) : Number
      {
         var _loc4_:int = 0;
         var _loc8_:String = null;
         var _loc3_:String = null;
         var _loc9_:String = "";
         var _loc10_:String = "";
         var _loc6_:String = "0000";
         var _loc7_:DisplayObject = DisplayObject(param1);
         var _loc5_:DisplayObject = DisplayObject(param2);
         try
         {
            while(_loc7_ != DisplayObject(form) && _loc7_.parent)
            {
               _loc4_ = getChildIndex(_loc7_.parent,_loc7_);
               _loc8_ = _loc4_.toString(16);
               if(_loc8_.length < 4)
               {
                  _loc3_ = _loc6_.substring(0,4 - _loc8_.length) + _loc8_;
               }
               _loc9_ = _loc3_ + _loc9_;
               _loc7_ = _loc7_.parent;
            }
         }
         catch(se1:SecurityError)
         {
         }
         try
         {
            while(_loc5_ != DisplayObject(form) && _loc5_.parent)
            {
               _loc4_ = getChildIndex(_loc5_.parent,_loc5_);
               _loc8_ = _loc4_.toString(16);
               if(_loc8_.length < 4)
               {
                  _loc3_ = _loc6_.substring(0,4 - _loc8_.length) + _loc8_;
               }
               _loc10_ = _loc3_ + _loc10_;
               _loc5_ = _loc5_.parent;
            }
         }
         catch(se2:SecurityError)
         {
         }
         return _loc9_ > _loc10_ ? 1 : (_loc9_ < _loc10_ ? -1 : 0);
      }
      
      private function getChildIndex(param1:DisplayObjectContainer, param2:DisplayObject) : int
      {
         return param1.getChildIndex(param2);
      }
      
      private function sortByTabIndex(param1:InteractiveObject, param2:InteractiveObject) : int
      {
         return param1.tabIndex > param2.tabIndex ? 1 : (param1.tabIndex < param2.tabIndex ? -1 : sortByDepth(param1,param2));
      }
      
      public function get defaultButtonEnabled() : Boolean
      {
         return _defaultButtonEnabled;
      }
      
      public function set defaultButtonEnabled(param1:Boolean) : void
      {
         _defaultButtonEnabled = param1;
      }
      
      public function get nextTabIndex() : int
      {
         return 0;
      }
      
      public function get showFocusIndicator() : Boolean
      {
         return _showFocusIndicator;
      }
      
      public function set showFocusIndicator(param1:Boolean) : void
      {
         _showFocusIndicator = param1;
      }
      
      public function get form() : DisplayObjectContainer
      {
         return _form;
      }
      
      public function set form(param1:DisplayObjectContainer) : void
      {
         _form = param1;
      }
      
      public function getFocus() : InteractiveObject
      {
         var _loc1_:InteractiveObject = form.stage.focus;
         return findFocusManagerComponent(_loc1_);
      }
      
      public function setFocus(param1:InteractiveObject) : void
      {
         if(param1 is IFocusManagerComponent)
         {
            IFocusManagerComponent(param1).setFocus();
         }
         else
         {
            form.stage.focus = param1;
         }
      }
      
      public function showFocus() : void
      {
      }
      
      public function hideFocus() : void
      {
      }
      
      public function findFocusManagerComponent(param1:InteractiveObject) : InteractiveObject
      {
         var _loc2_:InteractiveObject = param1;
         try
         {
            while(param1)
            {
               if(param1 is IFocusManagerComponent && Boolean(IFocusManagerComponent(param1).focusEnabled))
               {
                  return param1;
               }
               param1 = param1.parent;
            }
         }
         catch(se:SecurityError)
         {
         }
         return _loc2_;
      }
      
      private function getTopLevelFocusTarget(param1:InteractiveObject) : InteractiveObject
      {
         try
         {
            while(param1 != InteractiveObject(form))
            {
               if(param1 is IFocusManagerComponent && Boolean(IFocusManagerComponent(param1).focusEnabled) && Boolean(IFocusManagerComponent(param1).mouseFocusEnabled) && Boolean(UIComponent(param1).enabled))
               {
                  return param1;
               }
               param1 = param1.parent;
               if(param1 == null)
               {
                  break;
               }
            }
         }
         catch(se:SecurityError)
         {
         }
         return null;
      }
   }
}

