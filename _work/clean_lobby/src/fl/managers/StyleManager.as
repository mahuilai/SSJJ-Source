package fl.managers
{
   import fl.core.UIComponent;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   
   public class StyleManager
   {
      
      private static var _instance:StyleManager;
      
      private var styleToClassesHash:Object;
      
      private var classToInstancesDict:Dictionary;
      
      private var classToStylesDict:Dictionary;
      
      private var classToDefaultStylesDict:Dictionary;
      
      private var globalStyles:Object;
      
      public function StyleManager()
      {
         super();
         styleToClassesHash = {};
         classToInstancesDict = new Dictionary(true);
         classToStylesDict = new Dictionary(true);
         classToDefaultStylesDict = new Dictionary(true);
         globalStyles = UIComponent.getStyleDefinition();
      }
      
      private static function getInstance() : *
      {
         if(_instance == null)
         {
            _instance = new StyleManager();
         }
         return _instance;
      }
      
      public static function registerInstance(param1:UIComponent) : void
      {
         var _loc4_:Class = null;
         var _loc6_:Object = null;
         var _loc5_:Object = null;
         var _loc7_:StyleManager = getInstance();
         var _loc2_:Class = getClassDef(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc7_.classToInstancesDict[_loc2_] == null)
         {
            _loc7_.classToInstancesDict[_loc2_] = new Dictionary(true);
            _loc4_ = _loc2_;
            while(_loc6_ == null)
            {
               if(_loc4_["getStyleDefinition"] != null)
               {
                  _loc6_ = _loc4_["getStyleDefinition"]();
                  break;
               }
               try
               {
                  _loc4_ = param1.loaderInfo.applicationDomain.getDefinition(getQualifiedSuperclassName(_loc4_)) as Class;
               }
               catch(err:Error)
               {
                  try
                  {
                     _loc4_ = getDefinitionByName(getQualifiedSuperclassName(_loc4_)) as Class;
                  }
                  catch(e:Error)
                  {
                     _loc6_ = UIComponent.getStyleDefinition();
                     break;
                  }
               }
            }
            _loc5_ = _loc7_.styleToClassesHash;
            for(var _loc3_ in _loc6_)
            {
               if(_loc5_[_loc3_] == null)
               {
                  _loc5_[_loc3_] = new Dictionary(true);
               }
               _loc5_[_loc3_][_loc2_] = true;
            }
            _loc7_.classToDefaultStylesDict[_loc2_] = _loc6_;
            if(_loc7_.classToStylesDict[_loc2_] == null)
            {
               _loc7_.classToStylesDict[_loc2_] = {};
            }
         }
         _loc7_.classToInstancesDict[_loc2_][param1] = true;
         setSharedStyles(param1);
      }
      
      private static function setSharedStyles(param1:UIComponent) : void
      {
         var _loc5_:StyleManager = getInstance();
         var _loc2_:Class = getClassDef(param1);
         var _loc4_:Object = _loc5_.classToDefaultStylesDict[_loc2_];
         for(var _loc3_ in _loc4_)
         {
            param1.setSharedStyle(_loc3_,getSharedStyle(param1,_loc3_));
         }
      }
      
      private static function getSharedStyle(param1:UIComponent, param2:String) : Object
      {
         var _loc4_:Class = getClassDef(param1);
         var _loc5_:StyleManager = getInstance();
         var _loc3_:Object = _loc5_.classToStylesDict[_loc4_][param2];
         if(_loc3_ != null)
         {
            return _loc3_;
         }
         _loc3_ = _loc5_.globalStyles[param2];
         if(_loc3_ != null)
         {
            return _loc3_;
         }
         return _loc5_.classToDefaultStylesDict[_loc4_][param2];
      }
      
      public static function getComponentStyle(param1:Object, param2:String) : Object
      {
         var _loc3_:Class = getClassDef(param1);
         var _loc4_:Object = getInstance().classToStylesDict[_loc3_];
         return _loc4_ == null ? null : _loc4_[param2];
      }
      
      public static function clearComponentStyle(param1:Object, param2:String) : void
      {
         var _loc3_:Class = getClassDef(param1);
         var _loc4_:Object = getInstance().classToStylesDict[_loc3_];
         if(_loc4_ != null && _loc4_[param2] != null)
         {
            delete _loc4_[param2];
            invalidateComponentStyle(_loc3_,param2);
         }
      }
      
      public static function setComponentStyle(param1:Object, param2:String, param3:Object) : void
      {
         var _loc4_:Class = getClassDef(param1);
         var _loc5_:Object = getInstance().classToStylesDict[_loc4_];
         if(_loc5_ == null)
         {
            _loc5_ = getInstance().classToStylesDict[_loc4_] = {};
         }
         if(_loc5_ == param3)
         {
            return;
         }
         _loc5_[param2] = param3;
         invalidateComponentStyle(_loc4_,param2);
      }
      
      private static function getClassDef(param1:Object) : Class
      {
         if(param1 is Class)
         {
            return param1 as Class;
         }
         try
         {
            return getDefinitionByName(getQualifiedClassName(param1)) as Class;
         }
         catch(e:Error)
         {
            if(param1 is UIComponent)
            {
               try
               {
                  return param1.loaderInfo.applicationDomain.getDefinition(getQualifiedClassName(param1)) as Class;
               }
               catch(e:Error)
               {
               }
            }
         }
         return null;
      }
      
      private static function invalidateStyle(param1:String) : void
      {
         var _loc2_:Dictionary = getInstance().styleToClassesHash[param1];
         if(_loc2_ == null)
         {
            return;
         }
         for(var _loc3_ in _loc2_)
         {
            invalidateComponentStyle(Class(_loc3_),param1);
         }
      }
      
      private static function invalidateComponentStyle(param1:Class, param2:String) : void
      {
         var _loc4_:UIComponent = null;
         var _loc5_:Dictionary = getInstance().classToInstancesDict[param1];
         if(_loc5_ == null)
         {
            return;
         }
         for(var _loc3_ in _loc5_)
         {
            _loc4_ = _loc3_ as UIComponent;
            if(_loc4_ != null)
            {
               _loc4_.setSharedStyle(param2,getSharedStyle(_loc4_,param2));
            }
         }
      }
      
      public static function setStyle(param1:String, param2:Object) : void
      {
         var _loc3_:Object = getInstance().globalStyles;
         if(_loc3_[param1] === param2 && !(param2 is TextFormat))
         {
            return;
         }
         _loc3_[param1] = param2;
         invalidateStyle(param1);
      }
      
      public static function clearStyle(param1:String) : void
      {
         setStyle(param1,null);
      }
      
      public static function clear() : void
      {
         getInstance().styleToClassesHash = {};
         getInstance().classToInstancesDict = new Dictionary(true);
         getInstance().classToStylesDict = new Dictionary(true);
         getInstance().classToDefaultStylesDict = new Dictionary(true);
      }
      
      public static function getStyle(param1:String) : Object
      {
         return getInstance().globalStyles[param1];
      }
   }
}

