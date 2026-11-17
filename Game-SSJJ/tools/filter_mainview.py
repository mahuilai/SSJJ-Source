# -*- coding: utf-8 -*-
"""从 mainView 里裁出「大厅常驻骨架」：去掉各种弹窗与条件面板。

原版 mainView 是 120 个顶层节点堆在一起，靠 AS 代码逐个 setVisible 控制。
静态复现时按节点名做白名单，只保留大厅常态可见的部分。
"""
import re, sys, os

SRC = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_ui\view_dec\mainView.dec.xml"
DST = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_ui\view_dec\mainView_lobby.xml"

# 大厅常驻：背景 / 角色位 / 顶栏按钮组 / 底栏 / 货币 / 进游戏按钮 / VIP
KEEP = {
    "bg", "iconBg", "modelBottomBgImage", "playerProtrait", "titleLB",
    "nationalFlag", "topButtonPanel", "NewPlayerProtrait", "NewSwitchRoleList",
    "NewBottomBar", "CurrencyBar", "btnArea", "vipIcon", "btnVip", "setBtn",
}
# 明确排除（弹窗 / 活动 / 条件提示）
DROP = {
    "tenBtn", "selectRoleBtn", "automaticEquipBtn", "questionnaireInvBtn",
    "questionnaireInvBtn1", "fulibtn", "banGameTipLabel", "videoListBtn",
    "videoSystemBtn", "btnExceptional", "btnBreak", "recommendStuffView",
    "propBtn", "trailerItem", "antiRewardMc", "customerServiceBtn",
    "btnFeedback", "facebookInviteBtn", "maskSp", "newPlayerSp",
    "_popContainer", "imgNew", "inviteContainer", "fashCacheTips",
    "iconMicroDisable", "iconMicroEnable", "microClientTips", "btnAnti",
    "bgAntiTips", "labelAntiTips", "secondLevelPasswordBtn", "backBtn",
    "btnBlock", "redPoint", "setRedImage", "setTipsNumLaebel", "vipRedPoint",
    "qianUI", "matchInfo", "rigthButton", "_viewContainer",
    "fastTimeTxt", "idCardTips", "fcmTips",
}


def split_top(text):
    """把 config 的直接子节点切成块。"""
    lines = text.splitlines(True)
    head, blocks = [], []
    cur = None
    for ln in lines:
        if re.match(r"^  <[A-Za-z_]", ln):
            if cur:
                blocks.append(cur)
            cur = [ln]
        elif cur is not None:
            cur.append(ln)
        else:
            head.append(ln)
    if cur:
        blocks.append(cur)
    return head, blocks


def main():
    text = open(SRC, encoding="utf-8", errors="replace").read()
    head, blocks = split_top(text)
    kept, dropped = [], 0
    seen = set()
    for b in blocks:
        first = b[0]
        m = re.match(r'^  <([A-Za-z_]\w*)([^>]*?)(/?)>', first)
        name = None
        if m:
            nm = re.search(r'name="([^"]*)"', m.group(2))
            name = nm.group(1) if nm else ""
        tag = m.group(1) if m else ""
        # 同名节点只留第一次出现（新版组件优先，旧版 sbag/bottomBar 之类会重复）
        key = (tag, name)
        if name in DROP:
            dropped += 1
            continue
        # 无名装饰节点同样要过白名单：大厅里那些「确定」大按钮就是无名 MovieClip
        if name not in KEEP:
            dropped += 1
            continue
        kept.append("".join(b))

    out = "".join(head) + "".join(kept)
    if "</config>" not in out:
        out += "</config>\n"
    open(DST, "w", encoding="utf-8").write(out)
    print(f"blocks={len(blocks)} kept={len(kept)} dropped={dropped}")
    print("->", DST)


if __name__ == "__main__":
    main()
