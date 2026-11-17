import json, sys

with open(r'C:\Users\Mahuilai\.gemini\antigravity\brain\a81afa3a-ff8f-4868-b75e-fb18da89ec49\.system_generated\logs\transcript.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        obj = json.loads(line)
        idx = obj.get('step_index')
        if obj.get('type') == 'USER_INPUT' and idx and idx >= 11900:
            c = obj.get('content')
            sys.stdout.buffer.write(f"=== STEP {idx} ===\n{c}\n".encode('utf-8'))
