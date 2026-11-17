import json

with open(r'C:\Users\Mahuilai\.gemini\antigravity\brain\a81afa3a-ff8f-4868-b75e-fb18da89ec49\.system_generated\logs\transcript.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        obj = json.loads(line)
        idx = obj.get('step_index')
        if idx and 13710 <= idx <= 13785:
            if obj.get('type') == 'PLANNER_RESPONSE':
                # find thinking or tool_calls
                calls = obj.get('tool_calls', [])
                if calls:
                    for c in calls:
                        print(f"STEP {idx} TOOL: {c.get('name')} {c.get('args')}")
                elif obj.get('content'):
                    print(f"STEP {idx} CONTENT: {obj.get('content')[:150]}")
