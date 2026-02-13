# Completion Gates & Verification

Detailed gate implementation for extract-webpage-content. All gates MUST pass before marking work complete.

## Resume Logic (MANDATORY AT START)

```python
def start_workflow():
    state_file = 'extraction-state.json'
    
    if file_exists(state_file):
        state = load_state(state_file)
        print(f"Resuming: {len(state['extractedPages'])} pages done, {len(state['pendingUrls'])} remaining")
        
        if state['pendingUrls']:
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

Log after every 5-10 pages (MANDATORY):

```python
def log_progress(state):
    processed = len(state['extractedPages'])
    remaining = len(state['pendingUrls'])
    depth_breakdown = {
        d: sum(1 for p in state['extractedPages'] if p['depth'] == d)
        for d in range(3)
    }
    
    print(f"Progress: {processed} extracted, {remaining} remaining")
    print(f"Depth: D0={depth_breakdown[0]}, D1={depth_breakdown[1]}, D2={depth_breakdown[2]}")
    
    if remaining > 0:
        print(f"WARNING: {remaining} URLs pending. Work NOT complete.")
    else:
        print("Queue empty. Proceeding to completion verification.")
```

## Gate 1: State Verification

```python
def verify_gate_1(state):
    if not file_exists('extraction-state.json'):
        print("FAILED: State file missing.")
        return False
    state = load_state('extraction-state.json')
    if len(state['pendingUrls']) > 0:
        print(f"FAILED: Queue not empty: {len(state['pendingUrls'])} remaining.")
        return False
    print("PASSED: Queue is empty.")
    return True
```

**If fails:** Continue extracting queue until empty.

## Gate 2: Progress Verification

```python
def verify_gate_2(state):
    if len(state['pendingUrls']) > 0:
        print(f"FAILED: {len(state['pendingUrls'])} URLs not processed.")
        return False
    extracted = len(state['extractedPages'])
    visited = len(state['visitedUrls'])
    print(f"PASSED: All URLs processed ({extracted} pages, {visited} visited).")
    return True
```

**If fails:** Process remaining URLs.

## Gate 3: Output Verification

```python
def verify_gate_3(state, base_directory):
    for page in state['extractedPages']:
        if page['status'] == 'complete':
            expected_file = f"{base_directory}/{page['folder']}/{page['title']}_Full_Content.md"
            if not file_exists(expected_file):
                print(f"FAILED: Missing: {expected_file}")
                return False
    print("PASSED: All output files exist.")
    return True
```

**If fails:** Generate/fix missing output files.

## Running All Gates

```python
def run_completion_gates(state, base_directory):
    gates = [
        ('Gate 1: State', verify_gate_1, state),
        ('Gate 2: Progress', verify_gate_2, state),
        ('Gate 3: Output', verify_gate_3, state, base_directory)
    ]
    all_passed = True
    for gate_name, gate_func, *args in gates:
        if not gate_func(*args):
            all_passed = False
    return all_passed
```

## Completion Criteria (ALL must be true)

1. Queue empty: `pendingUrls.length === 0`
2. All links extracted: Every discovered link either extracted OR marked as error
3. State saved: State file reflects current progress
4. Output generated: All output files exist and are non-empty
5. No pending work: No URLs remaining to extract
6. Verification passed: All completion gates passed

**If ANY criterion is false, work is NOT complete. Continue extracting.**

## When Verification Fails

1. Queue not empty -> Continue extracting queue
2. Links not extracted -> Extract remaining links
3. Output missing -> Generate/fix output
4. State corrupted -> Backup (`mv extraction-state.json extraction-state.json.backup`), start fresh
5. After fixes -> Re-run all gates. Repeat until ALL pass.
