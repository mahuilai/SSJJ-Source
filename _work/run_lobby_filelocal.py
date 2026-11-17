import json,subprocess,time,os
root=r"D:\逆向\SSJJ双塔惊魂"; d=os.path.join(root,"_work","lobby_run")
paras=json.load(open(r"D:\SSJJ\SSJJ-4399\Lobby\paras.dat",encoding="utf-8"))
local="file:///D:/逆向/SSJJ双塔惊魂/_work/lobby_run/"
paras.update({"resurl":local,"globalResurl":local,"resurl_back":local,"testClientResurl":local,"resConfigFileName":"res_config_38a3d077fefc79e447d6ea3efe8c8f66.xml","loaderInfoLoaderURL":"file:///D:/逆向/SSJJ双塔惊魂/_work/lobby_run/lobby_truely.php"})
args=[os.path.join(root,"_tools","ruffle","ruffle.exe"),"--width","1280","--height","800","-s","show-all","--player-runtime","air","--filesystem-access-mode","allow","--tcp-connections","allow","--storage","memory"]
for k,v in paras.items():
 if isinstance(v,(str,int,float,bool)): args += ["-P",f"{k}={v}"]
args += ["Lobby_main.swf"]
log=os.path.join(d,"ruffle_filelocal.log")
with open(log,"w",encoding="utf-8") as out:p=subprocess.Popen(args,cwd=d,stdout=out,stderr=subprocess.STDOUT,text=True)
time.sleep(20)
print("pid",p.pid,"alive",p.poll() is None)
print(open(log,encoding="utf-8").read()[-20000:])
