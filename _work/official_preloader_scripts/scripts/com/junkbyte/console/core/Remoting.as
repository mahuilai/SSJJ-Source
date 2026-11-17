package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import flash.events.AsyncErrorEvent;
   import flash.events.Event;
   import flash.events.SecurityErrorEvent;
   import flash.events.StatusEvent;
   import flash.net.LocalConnection;
   import flash.net.Socket;
   import flash.system.Security;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class Remoting extends ConsoleCore
   {
      
      public static const NONE:uint = 0;
      
      public static const SENDER:uint = 1;
      
      public static const RECIEVER:uint = 2;
      
      private var _callbacks:Object = {};
      
      private var _mode:uint;
      
      private var _local:LocalConnection;
      
      private var _socket:Socket;
      
      private var _sendBuffer:ByteArray = new ByteArray();
      
      private var _recBuffers:Object = {};
      
      private var _senders:Dictionary = new Dictionary();
      
      private var _lastLogin:String = "";
      
      private var _loggedIn:Boolean;
      
      private var _sendID:String;
      
      private var _lastReciever:String;
      
      public function Remoting(param1:Console)
      {
         var m:Console = param1;
         super(m);
         registerCallback("login",function(param1:ByteArray):void
         {
            login(param1.readUTF());
         });
         registerCallback("requestLogin",requestLogin);
         registerCallback("loginFail",loginFail);
         registerCallback("loginSuccess",loginSuccess);
      }
      
      public function update() : void
      {
         var _loc4_:ByteArray = null;
         var _loc3_:ByteArray = null;
         var _loc2_:String = null;
         if(_sendBuffer.length)
         {
            if(_socket && _socket.connected)
            {
               _socket.writeBytes(_sendBuffer);
               _sendBuffer = new ByteArray();
            }
            else if(_local)
            {
               _sendBuffer.position = 0;
               if(_sendBuffer.bytesAvailable < 38000)
               {
                  _loc4_ = _sendBuffer;
                  _sendBuffer = new ByteArray();
               }
               else
               {
                  _loc4_ = new ByteArray();
                  _sendBuffer.readBytes(_loc4_,0,Math.min(38000,_sendBuffer.bytesAvailable));
                  _loc3_ = new ByteArray();
                  _sendBuffer.readBytes(_loc3_);
                  _sendBuffer = _loc3_;
               }
               _loc2_ = config.remotingConnectionName + (remoting == 2 ? 1 : 2);
               _local.send(_loc2_,"synchronize",_sendID,_loc4_);
            }
            else
            {
               _sendBuffer = new ByteArray();
            }
         }
         for(var _loc1_:String in _recBuffers)
         {
            processRecBuffer(_loc1_);
         }
      }
      
      private function processRecBuffer(param1:String) : void
      {
         var _loc7_:* = 0;
         var _loc4_:String = null;
         var _loc3_:ByteArray = null;
         var _loc5_:* = 0;
         var _loc8_:Object = null;
         var _loc6_:ByteArray = null;
         if(!_senders[param1])
         {
            _senders[param1] = true;
            if(_lastReciever)
            {
               report("Remote switched to new sender [" + param1 + "] as primary.",-2);
            }
            _lastReciever = param1;
         }
         var _loc2_:ByteArray = _recBuffers[param1];
         try
         {
            _loc7_ = _loc2_.position = 0;
            while(_loc2_.bytesAvailable)
            {
               _loc4_ = _loc2_.readUTF();
               _loc3_ = null;
               if(_loc2_.bytesAvailable == 0)
               {
                  break;
               }
               if(_loc2_.readBoolean())
               {
                  if(_loc2_.bytesAvailable == 0)
                  {
                     break;
                  }
                  _loc5_ = _loc2_.readUnsignedInt();
                  if(_loc2_.bytesAvailable < _loc5_)
                  {
                     break;
                  }
                  _loc3_ = new ByteArray();
                  _loc2_.readBytes(_loc3_,0,_loc5_);
               }
               _loc8_ = _callbacks[_loc4_];
               if(!_loc8_.latest || param1 == _lastReciever)
               {
                  if(_loc3_)
                  {
                     _loc8_.fun(_loc3_);
                  }
                  else
                  {
                     _loc8_.fun();
                  }
               }
               _loc7_ = _loc2_.position;
            }
            if(_loc7_ < _loc2_.length)
            {
               _loc6_ = new ByteArray();
               _loc6_.writeBytes(_loc2_,_loc7_);
               _recBuffers[param1] = _loc2_ = _loc6_;
            }
            else
            {
               delete _recBuffers[param1];
            }
         }
         catch(err:Error)
         {
            report("Remoting sync error: " + err,9);
         }
      }
      
      private function synchronize(param1:String, param2:Object) : void
      {
         if(!(param2 is ByteArray))
         {
            report("Remoting sync error. Recieved non-ByteArray:" + param2,9);
            return;
         }
         var _loc4_:ByteArray = param2 as ByteArray;
         var _loc3_:ByteArray = _recBuffers[param1];
         if(_loc3_)
         {
            _loc3_.position = _loc3_.length;
            _loc3_.writeBytes(_loc4_);
         }
         else
         {
            _recBuffers[param1] = _loc4_;
         }
      }
      
      public function send(param1:String, param2:ByteArray = null) : Boolean
      {
         if(_mode == 0)
         {
            return false;
         }
         _sendBuffer.position = _sendBuffer.length;
         _sendBuffer.writeUTF(param1);
         if(param2)
         {
            _sendBuffer.writeBoolean(true);
            _sendBuffer.writeUnsignedInt(param2.length);
            _sendBuffer.writeBytes(param2);
         }
         else
         {
            _sendBuffer.writeBoolean(false);
         }
         return true;
      }
      
      public function get remoting() : uint
      {
         return _mode;
      }
      
      public function get canSend() : Boolean
      {
         return _mode == 1 && _loggedIn;
      }
      
      public function set remoting(param1:uint) : void
      {
         var _loc2_:String = null;
         if(param1 == _mode)
         {
            return;
         }
         _sendID = generateId();
         if(param1 == 1)
         {
            if(!startSharedConnection(1))
            {
               report("Could not create remoting client service. You will not be able to control this console with remote.",10);
            }
            _sendBuffer = new ByteArray();
            _local.addEventListener("status",onSenderStatus,false,0,true);
            report("<b>Remoting started.</b> " + getInfo(),-1);
            _loggedIn = checkLogin("");
            if(_loggedIn)
            {
               sendLoginSuccess();
            }
            else
            {
               send("requestLogin");
            }
         }
         else if(param1 == 2)
         {
            if(startSharedConnection(2))
            {
               _sendBuffer = new ByteArray();
               _local.addEventListener("asyncError",onRemoteAsyncError,false,0,true);
               _local.addEventListener("status",onRecieverStatus,false,0,true);
               report("<b>Remote started.</b> " + getInfo(),-1);
               _loc2_ = Security.sandboxType;
               if(_loc2_ == "localWithFile" || _loc2_ == "localWithNetwork")
               {
                  report("Untrusted local sandbox. You may not be able to listen for logs properly.",10);
                  printHowToGlobalSetting();
               }
               login(_lastLogin);
            }
            else
            {
               report("Could not create remote service. You might have a console remote already running.",10);
            }
         }
         else
         {
            close();
         }
         console.panels.updateMenu();
      }
      
      public function remotingSocket(param1:String, param2:int = 0) : void
      {
         if(_socket && _socket.connected)
         {
            _socket.close();
            _socket = null;
         }
         if(param1 && param2)
         {
            remoting = 1;
            report("Connecting to socket " + param1 + ":" + param2);
            _socket = new Socket();
            _socket.addEventListener("close",socketCloseHandler);
            _socket.addEventListener("connect",socketConnectHandler);
            _socket.addEventListener("ioError",socketIOErrorHandler);
            _socket.addEventListener("securityError",socketSecurityErrorHandler);
            _socket.addEventListener("socketData",socketDataHandler);
            _socket.connect(param1,param2);
         }
      }
      
      private function socketCloseHandler(param1:Event) : void
      {
         if(param1.currentTarget == _socket)
         {
            _socket = null;
         }
      }
      
      private function socketConnectHandler(param1:Event) : void
      {
         report("Remoting socket connected.",-1);
         _sendBuffer = new ByteArray();
         if(_loggedIn || checkLogin(""))
         {
            sendLoginSuccess();
         }
         else
         {
            send("requestLogin");
         }
      }
      
      private function socketIOErrorHandler(param1:Event) : void
      {
         report("Remoting socket error." + param1,9);
         remotingSocket(null);
      }
      
      private function socketSecurityErrorHandler(param1:Event) : void
      {
         report("Remoting security error." + param1,9);
         remotingSocket(null);
      }
      
      private function socketDataHandler(param1:Event) : void
      {
         handleSocket(param1.currentTarget as Socket);
      }
      
      public function handleSocket(param1:Socket) : void
      {
         if(!_senders[param1])
         {
            _senders[param1] = generateId();
            _socket = param1;
         }
         var _loc2_:ByteArray = new ByteArray();
         param1.readBytes(_loc2_);
         synchronize(_senders[param1],_loc2_);
      }
      
      private function onSenderStatus(param1:StatusEvent) : void
      {
         if(param1.level == "error" && !(_socket && _socket.connected))
         {
            _loggedIn = false;
         }
      }
      
      private function onRecieverStatus(param1:StatusEvent) : void
      {
         if(remoting == 2 && param1.level == "error")
         {
            report("Problem communicating to client.",10);
         }
      }
      
      private function onRemotingSecurityError(param1:SecurityErrorEvent) : void
      {
         report("Remoting security error.",9);
         printHowToGlobalSetting();
      }
      
      private function onRemoteAsyncError(param1:AsyncErrorEvent) : void
      {
         report("Problem with remote sync. [<a href=\'event:remote\'>Click here</a>] to restart.",10);
         remoting = 0;
      }
      
      private function getInfo() : String
      {
         return "<p4>channel:" + config.remotingConnectionName + " (" + Security.sandboxType + ")</p4>";
      }
      
      private function printHowToGlobalSetting() : void
      {
         report("Make sure your flash file is \'trusted\' in Global Security Settings.",-2);
         report("Go to Settings Manager [<a href=\'event:settings\'>click here</a>] &gt; \'Global Security Settings Panel\' (on left) &gt; add the location of the local flash (swf) file.",-2);
      }
      
      private function generateId() : String
      {
         return new Date().time + "." + Math.floor(Math.random() * 100000);
      }
      
      private function startSharedConnection(param1:uint) : Boolean
      {
         close();
         _mode = param1;
         _local = new LocalConnection();
         _local.client = {"synchronize":synchronize};
         if(config.allowedRemoteDomain)
         {
            _local.allowDomain(config.allowedRemoteDomain);
            _local.allowInsecureDomain(config.allowedRemoteDomain);
         }
         _local.addEventListener("securityError",onRemotingSecurityError,false,0,true);
         try
         {
            _local.connect(config.remotingConnectionName + _mode);
         }
         catch(err:Error)
         {
            return false;
         }
         return true;
      }
      
      public function registerCallback(param1:String, param2:Function, param3:Boolean = false) : void
      {
         _callbacks[param1] = {
            "fun":param2,
            "latest":param3
         };
      }
      
      private function loginFail() : void
      {
         if(remoting != 2)
         {
            return;
         }
         report("Login Failed",10);
         console.panels.mainPanel.requestLogin();
      }
      
      private function sendLoginSuccess() : void
      {
         _loggedIn = true;
         send("loginSuccess");
         dispatchEvent(new Event("connect"));
      }
      
      private function loginSuccess() : void
      {
         console.setViewingChannels();
         report("Login Successful",-1);
      }
      
      private function requestLogin() : void
      {
         if(remoting != 2)
         {
            return;
         }
         _sendBuffer = new ByteArray();
         if(_lastLogin)
         {
            login(_lastLogin);
         }
         else
         {
            console.panels.mainPanel.requestLogin();
         }
      }
      
      public function login(param1:String = "") : void
      {
         var _loc2_:ByteArray = null;
         if(remoting == 2)
         {
            _lastLogin = param1;
            report("Attempting to login...",-1);
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(param1);
            send("login",_loc2_);
         }
         else if(_loggedIn || checkLogin(param1))
         {
            sendLoginSuccess();
         }
         else
         {
            send("loginFail");
         }
      }
      
      private function checkLogin(param1:String) : Boolean
      {
         return config.remotingPassword === null && config.keystrokePassword == param1 || config.remotingPassword === "" || config.remotingPassword == param1;
      }
      
      public function close() : void
      {
         if(_local)
         {
            try
            {
               _local.close();
            }
            catch(error:Error)
            {
               report("Remote.close: " + error,10);
            }
         }
         _mode = 0;
         _sendBuffer = new ByteArray();
         _local = null;
      }
   }
}

