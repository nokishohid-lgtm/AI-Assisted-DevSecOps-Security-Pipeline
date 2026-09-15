#!/usr/bin/env python3
"""
AI-assisted triage of CodeQL SARIF findings using Groq (Llama 3.3).
Reads SARIF, sends each finding + surrounding code to the LLM,
posts a summary comment on the PR.
"""
import json
import os
import sys
import subprocess
from pathlib import Path
from openai import OpenAI

MODEL = "llama-3.3-70b-versatile"
MAX_FINDINGS = 10
CONTEXT_LINES = 15


def load_sarif(path: str) -> list[dict]:
    with open(path, "r", encoding="utf-8") as f:
        sarif = json.load(f)

    findings = []
    for run in sarif.get("runs", []):
        rules = {r["id"]: r for r in run.get("tool", {}).get("driver", {}).get("rules", [])}
        for result in run.get("results", []):
            loc = result.get("locations", [{}])[0]
            phys = loc.get("physicalLocation", {})
            artifact = phys.get("artifactLocation", {})
            region = phys.get("region", {})
            rule_id = result.get("ruleId", "unknown")
            rule = rules.get(rule_id, {})
            findings.append({
                "rule_id": rule_id,
                "message": result.get("message", {}).get("text", ""),
                "file": artifact.get("uri", ""),
                "line": region.get("startLine", 0),
                "help": rule.get("help", {}).get("text", "")[:400],
            })
    return findings[:MAX_FINDINGS]


def read_context(file_path: str, line: int, window: int = CONTEXT_LINES) -> str:
    p = Path(file_path)
    if not p.exists():
        return "(file not found in checkout)"
    lines = p.read_text(encoding="utf-8", errors="replace").splitlines()
    start = max(0, line - window - 1)
    end = min(len(lines), line + window)
    numbered = [f"{i+1:4d} | {lines[i]}" for i in range(start, end)]
    return "\n".join(numbered)


def triage(client: OpenAI, finding: dict, context: str) -> dict:
    prompt = f"""You are a security engineer triaging a SAST finding.

Finding: {finding['rule_id']}
Message: {finding['message']}
File: {finding['file']}:{finding['line']}

Rule help:
{finding['help']}

Code context:
{context}

Is this exploitable by an attacker? Consider:
- Is the vulnerable code reachable from user input?
- Is there sanitization the SAST tool might have missed?
- What prevents exploitation?

Respond ONLY with JSON in this exact shape:
{{"decision": "true_positive" or "false_positive" or "needs_review",
  "reasoning": "one or two sentences",
  "fix_suggestion": "one sentence or empty string"}}
"""
    resp = client.chat.completions.create(
        model=MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.1,
        max_tokens=500,
    )
    raw = resp.choices[0].message.content.strip()
    if raw.startswith("```"):
        raw = raw.split("```")[1]
        if raw.startswith("json"):
            raw = raw[4:]
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {"decision": "needs_review", "reasoning": f"unparseable: {raw[:150]}", "fix_suggestion": ""}


def post_pr_comment(body: str) -> None:
    pr_number = os.environ.get("PR_NUMBER")
    if not pr_number:
        print("No PR number; printing to stdout:\n")
        print(body)
        return
    subprocess.run(["gh", "pr", "comment", pr_number, "--body", body], check=True)


def main():
    if len(sys.argv) < 2:
        print("usage: triage.py <sarif-file>", file=sys.stderr)
        sys.exit(2)

    api_key = os.environ.get("GROQ_API_KEY")
    if not api_key:
        print("GROQ_API_KEY not set", file=sys.stderr)
        sys.exit(2)

    findings = load_sarif(sys.argv[1])
    if not findings:
        print("No findings to triage.")
        return

    client = OpenAI(api_key=api_key, base_url="https://api.groq.com/openai/v1")
    results = []
    for f in findings:
        ctx = read_context(f["file"], f["line"])
        verdict = triage(client, f, ctx)
        results.append((f, verdict))
        print(f"[{verdict['decision']}] {f['rule_id']} @ {f['file']}:{f['line']}")

    tp = sum(1 for _, v in results if v["decision"] == "true_positive")
    fp = sum(1 for _, v in results if v["decision"] == "false_positive")
    nr = sum(1 for _, v in results if v["decision"] == "needs_review")

    lines = [
        "## 🤖 AI Triage Summary",
        "",
        f"Triaged **{len(results)}** findings: "
        f"**{tp}** true positive · **{fp}** false positive · **{nr}** needs review",
        "",
        "| Finding | Location | Decision | Reasoning |",
        "|---|---|---|---|",
    ]
    for f, v in results:
        lines.append(
            f"| `{f['rule_id']}` | `{f['file']}:{f['line']}` | "
            f"**{v['decision']}** | {v['reasoning'][:180]} |"
        )
    lines.append("")
    lines.append("_AI triage is advisory. Deterministic security gates still block merges._")
    post_pr_comment("\n".join(lines))


if __name__ == "__main__":
    main()