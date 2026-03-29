# Completion Gates & Verification

Detailed gate implementation for extract-sitemap. All gates MUST pass before generating the final sitemap.

## Resume Logic (MANDATORY AT START)

```python
def start_workflow():
    state_file = 'sitemap-state.json'
    
    if file_exists(state_file):
        state = load_state(state_file)
        print(f"Resuming: {len(state['pages'])} processed, {len(state['queue'])} remaining")
        
        if state['queue']:
            return state  # Resume from queue
        else:
            if verify_completion(state):
                delete_state_file(state_file)
                return None  # Start fresh
            else:
                return state  # Resume incomplete run
    
    return None  # Start fresh
```

## Progress Tracking

Log after every 10-20 pages (MANDATORY):

```python
def log_progress(state):
    processed = len(state['pages'])
    remaining = len(state['queue'])
    depth_breakdown = {
        d: sum(1 for p in state['pages'] if p['depth'] == d)
        for d in range(3)
    }
    status_breakdown = {
        'accessible': sum(1 for p in state['pages'] if 'Accessible' in p['status']),
        'dead': sum(1 for p in state['pages'] if 'Dead' in p['status']),
        'forbidden': sum(1 for p in state['pages'] if 'Forbidden' in p['status'])
    }
    
    print(f"Progress: {processed} processed, {remaining} remaining")
    print(f"Depth: D0={depth_breakdown[0]}, D1={depth_breakdown[1]}, D2={depth_breakdown[2]}")
    print(f"Status: OK={status_breakdown['accessible']}, Dead={status_breakdown['dead']}, Forbidden={status_breakdown['forbidden']}")
    
    if remaining > 0:
        print(f"WARNING: {remaining} URLs pending. Work NOT complete.")
    else:
        print("Queue empty. Proceeding to completion verification.")
```

## Gate 1: State Verification

```python
def verify_gate_1(state):
    if not file_exists('sitemap-state.json'):
        print("FAILED: State file missing.")
        return False
    state = load_state('sitemap-state.json')
    if len(state['queue']) > 0:
        print(f"FAILED: Queue not empty: {len(state['queue'])} remaining.")
        return False
    print("PASSED: Queue is empty.")
    return True
```

**If fails:** Continue processing queue until empty.

## Gate 2: Progress Verification

```python
def verify_gate_2(state):
    processed = len(state['pages'])
    total_discovered = sum(p['linksFound'] for p in state['pages'])
    total_processed = len(state['visitedUrls'])
    dead_count = sum(1 for p in state['pages'] if any(s in p['status'] for s in ['Dead', 'Forbidden', 'Error', 'Timeout']))
    
    if total_processed + dead_count < total_discovered:
        print(f"FAILED: Discovered {total_discovered}, processed {total_processed}, dead {dead_count}.")
        return False
    print(f"PASSED: All links processed ({total_discovered} discovered, {total_processed} processed).")
    return True
```

**If fails:** Process remaining links.

## Gate 3: Output Verification

```python
def verify_gate_3(state, output_file):
    if not file_exists(output_file):
        print(f"FAILED: Output file missing: {output_file}")
        return False
    if file_size(output_file) == 0:
        print(f"FAILED: Output file empty: {output_file}")
        return False
    print("PASSED: Output file exists and is non-empty.")
    return True
```

**If fails:** Generate/fix output file.

## Running All Gates

```python
def run_completion_gates(state, output_file):
    gates = [
        ('Gate 1: State', verify_gate_1, state),
        ('Gate 2: Progress', verify_gate_2, state),
        ('Gate 3: Output', verify_gate_3, state, output_file)
    ]
    all_passed = True
    for gate_name, gate_func, *args in gates:
        if not gate_func(*args):
            all_passed = False
    return all_passed
```

## Completion Criteria (ALL must be true)

1. Queue empty: `queue.length === 0`
2. All links processed: Every discovered link either processed OR marked as dead/forbidden
3. State saved: State file reflects current progress
4. Output generated: Sitemap file exists, is non-empty, contains all processed pages
5. No pending work: No URLs remaining to process
6. Verification passed: All completion gates passed

**If ANY criterion is false, work is NOT complete. Continue processing.**

## When Verification Fails

1. Queue not empty -> Continue processing queue
2. Links not processed -> Process remaining links
3. Output missing -> Generate/fix sitemap output
4. State corrupted -> Backup (`mv sitemap-state.json sitemap-state.json.backup`), start fresh
5. After fixes -> Re-run all gates. Repeat until ALL pass.
