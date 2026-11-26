from bench import get_spec, build_prompt, ask_ollama, extract_verilog, run_testbench

def main():
    module = "alu"
    spec = get_spec(module)
    prompt = build_prompt(spec=spec)
    response = ask_ollama(model="qwen3.6", prompt=prompt, temp=0.2)
    print(response[0])

    code = extract_verilog(response[0])
    
    tb = run_testbench(module = module, code = code)
    print(tb)
    return tb

if __name__ == "__main__":
    main()