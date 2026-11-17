import json, subprocess, time, os
root=r"D:\逆向\SSJJ双塔惊魂"
dir=os.path.join(root,"_work","lobby_run")
log=os.path.join(dir,"ruffle_http4.log")
paras_path=r"D:\SSJJ\SSJJ-4399\Lobby\paras.dat"
with open(paras_path,encoding="utf-8") as f:
    paras=json.load(f)
paras.update({
    "resurl":"http://127.0.0.1:8767/",
    "globalResurl":"http://127.0.0.1:8767/",
    "resurl_back":"http://127.0.0.1:8767/",
    "testClientResurl":"http://127.0.0.1:8767/",
    "resConfigFileName":"res_config_38a3d077fefc79e447d6ea3efe8c8f66.xml",
    "loaderInfoLoaderURL":"http%3A%2F%2F127.0.0.1%3A8767%2Flobby_truely.php"
})
args=[os.path.join(root,"_tools","ruffle","ruffle.exe"),"--width","1280","--height","800","-s","show-all","--base","http://127.0.0.1:8767/","--player-runtime","air","--filesystem-access-mode","allow","--tcp-connections","allow","--storage","memory"]
for k,v in paras.items():
    if isinstance(v,(str,int,float,bool)):
        args += ["-P",f"{k}={v}"]
args += ["http://127.0.0.1:8767/Lobby_main.swf"]
with open(log,"w",encoding="utf-8") as out:
    p=subprocess.Popen(args,cwd=dir,stdout=out,stderr=subprocess.STDOUT,text=True)
print(p.pid)
time.sleep(20)
print("alive",p.poll() is None)
print(open(log,encoding="utf-8").read()[-20000:])
