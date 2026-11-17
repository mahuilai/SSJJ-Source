# -*- coding: utf-8 -*-
import json

p = r'C:\Users\Mahuilai\.gemini\antigravity\brain\a81afa3a-ff8f-4868-b75e-fb18da89ec49\.system_generated\logs\transcript_full.jsonl'
with open(p, 'r', encoding='utf-8') as f:
    for i, line in enumerate(f):
        if i == 131:
            obj = json.loads(line)
            content = obj.get('content', '')
            print("Step 117 content:")
            print(content[:1500])
            break
