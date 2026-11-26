import ollama as ol
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).parent

def get_spec(module):
    return (ROOT / "specs" / f"{module}.txt").read_text()


def build_prompt(spec):
    return ("Using exactly the following description, write exactly one Verilog module in plain "
            "Verilog-2001. Use exactly the module name and ports given. Do not include a testbench "
            "or any explanation, just the code in one code block.\n\n" + spec)

def ask_ollama(model, temp, prompt):
    response = ol.chat (
        model=model,
        messages = [
            {
                'role' :'system',
                'content':'You are a Verilog expert who writes  in Verilog-2001',
            },
            {
                'role' :'user',
                'content':prompt,
            },
        ],
        options = {
            'temperature':temp,
        }
    )

    return response.message.content, response.prompt_eval_count + response.eval_count, response.total_duration / 1e9


def extract_verilog(reply):
    match = re.search(r"\bmodule\b.*?\bendmodule\b", reply, re.DOTALL)
    return match.group(0) if match else None


def run_testbench(module, code):
    if code is None:
        return 'NO_CODE'
    with tempfile.TemporaryDirectory() as tmp:
        design = Path(tmp) / f"{module}.v"
        sim = Path(tmp) / "sim"
        design.write_text(code)
        built = subprocess.run(
            ["iverilog", "-o", str(sim), str(ROOT / "tb" / f"tb_{module}.v"), str(design)],
            capture_output=True, text=True,
        )
        if built.returncode != 0:
            return "COMPILE_ERROR", built.stderr
        try:
            run = subprocess.run(["vvp", str(sim)], capture_output=True, text=True, timeout=10)
        except subprocess.TimeoutExpired:
            return "TIMEOUT", ""
        if "PASS" in run.stdout.splitlines():
            return "PASS", run.stdout
        return "FAIL", run.stdout


