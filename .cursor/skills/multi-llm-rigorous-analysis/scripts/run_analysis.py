#!/usr/bin/env python3
"""
Multi-LLM Rigorous Analysis Runner

Runs 4 LLMs (Sonnet, Opus, GPT, Gemini) to produce independent critiques of a write-up.
Each model produces its own markdown file. Use --sequential for one-at-a-time execution.

Usage:
  python run_analysis.py /path/to/source.md [--sequential] [--output-dir /path]

Requires: pip install litellm
Env: ANTHROPIC_API_KEY, OPENAI_API_KEY, GOOGLE_API_KEY (or GEMINI_API_KEY)
"""

import argparse
import json
import os
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

try:
    import litellm
except ImportError:
    print("Error: litellm required. Run: pip install litellm")
    sys.exit(1)

SCRIPT_DIR = Path(__file__).resolve().parent
SKILL_DIR = SCRIPT_DIR.parent


def load_config():
    config_path = SCRIPT_DIR / "config.json"
    with open(config_path, encoding="utf-8") as f:
        return json.load(f)


def load_prompt_template():
    path = SKILL_DIR / "references" / "ANALYSIS_PROMPT.md"
    with open(path, encoding="utf-8") as f:
        return f.read()


def load_thought_leaders():
    path = SKILL_DIR / "references" / "THOUGHT_LEADERS.md"
    with open(path, encoding="utf-8") as f:
        return f.read()


def run_single_model(model_id: str, prompt: str, config: dict) -> str:
    """Call one model and return response."""
    try:
        response = litellm.completion(
            model=model_id,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=config.get("max_tokens", 16000),
            temperature=config.get("temperature", 0.4),
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"Error: {e}\n\nModel: {model_id}"


def main():
    parser = argparse.ArgumentParser(
        description="Run 4 LLMs to produce rigorous critiques of a write-up"
    )
    parser.add_argument(
        "source",
        type=Path,
        help="Path to source markdown file",
    )
    parser.add_argument(
        "--sequential",
        action="store_true",
        help="Run models sequentially instead of parallel",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="Output directory (default: source_dir/analyses/)",
    )
    args = parser.parse_args()

    source_path = args.source.resolve()
    if not source_path.exists():
        print(f"Error: Source file not found: {source_path}")
        sys.exit(1)

    with open(source_path, encoding="utf-8") as f:
        source_content = f.read()

    config = load_config()
    prompt_template = load_prompt_template()
    thought_leaders = load_thought_leaders()

    prompt = prompt_template.replace("{SOURCE_CONTENT}", source_content)
    prompt = prompt.replace("{THOUGHT_LEADERS}", thought_leaders)

    output_dir = args.output_dir or (source_path.parent / "analyses")
    output_dir.mkdir(parents=True, exist_ok=True)

    basename = source_path.stem
    models = config["models"]
    models_fallback = config.get("fallback_models", {})

    outputs = {
        "sonnet": (output_dir / f"{basename}_analysis_sonnet.md", models["sonnet"]),
        "opus": (output_dir / f"{basename}_analysis_opus.md", models["opus"]),
        "gpt": (output_dir / f"{basename}_analysis_gpt.md", models["gpt"]),
        "gemini": (output_dir / f"{basename}_analysis_gemini.md", models["gemini"]),
    }

    def run_one(name: str, out_path: Path, model_id: str) -> tuple[str, Path, str]:
        print(f"Running {name} ({model_id})...")
        try:
            result = run_single_model(model_id, prompt, config)
        except Exception as e:
            fallback = models_fallback.get(name)
            if fallback:
                print(f"  Fallback to {fallback}")
                result = run_single_model(fallback, prompt, config)
            else:
                result = f"Error: {e}"
        return (name, out_path, result)

    if args.sequential:
        for name, (out_path, model_id) in outputs.items():
            _, path, result = run_one(name, out_path, model_id)
            with open(path, "w", encoding="utf-8") as f:
                f.write(result)
            print(f"  Wrote {path}")
    else:
        with ThreadPoolExecutor(max_workers=4) as executor:
            futures = {
                executor.submit(run_one, name, out_path, model_id): (
                    name,
                    out_path,
                    model_id,
                )
                for name, (out_path, model_id) in outputs.items()
            }
            for future in as_completed(futures):
                name, path, result = future.result()
                with open(path, "w", encoding="utf-8") as f:
                    f.write(result)
                print(f"  Wrote {path} ({name})")

    print(f"\nDone. Outputs in: {output_dir}")


if __name__ == "__main__":
    main()
