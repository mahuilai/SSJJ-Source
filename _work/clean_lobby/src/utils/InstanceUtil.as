package utils
{
   import fl.core.UIComponent;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class InstanceUtil
   {
      
      public function InstanceUtil()
      {
         super();
      }
      
      public static function getClassByName(param1:String) : Class
      {
         try
         {
            return getDefinitionByName(param1) as Class;
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public static function getNewInstaceByInstance(param1:Object) : Object
      {
         var _loc2_:Class = getClassDef(param1);
         if(_loc2_)
         {
            return new _loc2_();
         }
         return null;
      }
      
      public static function getClassDef(param1:Object) : Class
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
   }
}

