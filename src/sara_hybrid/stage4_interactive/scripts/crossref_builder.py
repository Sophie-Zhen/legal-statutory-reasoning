import os
import re
import json
from collections import defaultdict, deque

# --- Project root detection logic ---
def find_project_root(start_path):
    """
    Walk up from start_path until a .git directory is found, then return that directory.
    """
    cur = os.path.abspath(start_path)
    while cur != os.path.dirname(cur):
        if os.path.isdir(os.path.join(cur, '.git')):
            return cur
        cur = os.path.dirname(cur)
    raise RuntimeError('Could not find project root (.git directory)')

# 1. Load Statute Texts
def load_statute_texts(statute_dir):
    texts = {}
    for fname in os.listdir(statute_dir):
        if fname.startswith('.'):
            continue
        fpath = os.path.join(statute_dir, fname)
        if os.path.isfile(fpath):
            with open(fpath, 'r', encoding='utf-8') as f:
                texts[fname] = f.read()
    return texts

# 2. Regex Extraction
def extract_refs(text):
    # §123, § 123(a), section 152(c)(1), subsection (c)(1) of section 152
    pattern_section = re.compile(r'§\s*([0-9]+)(?:\(([a-z0-9]+)\))*')
    pattern_spelled = re.compile(r'(?:section|subsection)\s*([0-9]+)?(?:\(([a-z0-9]+)\))*', re.IGNORECASE)
    pattern_full = re.compile(r'(?:section|subsection)\s*\(([a-z0-9]+)\)(?:\(([a-z0-9]+)\))*\s*of section\s*([0-9]+)', re.IGNORECASE)
    
    refs = set()
    # § references
    for m in re.finditer(r'§\s*([0-9]+)(\([a-z0-9]+\))*', text):
        base = m.group(1)
        if m.group(2):
            # e.g. §152(c)
            sub = re.findall(r'\(([a-z0-9]+)\)', m.group(0))
            key = '_'.join([base] + sub)
        else:
            key = base
        refs.add(key)
    # spelled-out references
    for m in re.finditer(r'(?:section|subsection)\s*([0-9]+)?(?:\(([a-z0-9]+)\))*', text, re.IGNORECASE):
        if m.group(1):
            base = m.group(1)
            sub = m.group(2)
            if sub:
                key = f"{base}_{sub}"
            else:
                key = base
            refs.add(key)
    # full spelled-out e.g. subsection (c)(1) of section 152
    for m in re.finditer(r'(?:section|subsection)\s*\(([a-z0-9]+)\)(?:\(([a-z0-9]+)\))*\s*of section\s*([0-9]+)', text, re.IGNORECASE):
        base = m.group(3)
        subs = [m.group(1)]
        if m.group(2):
            subs.append(m.group(2))
        key = '_'.join([base] + subs)
        refs.add(key)
    return refs

# 3. Build Adjacency
def build_adjacency(texts):
    adjacency = defaultdict(list)
    for fname, text in texts.items():
        # Use filename (without extension) as key
        key = os.path.splitext(fname)[0]
        refs = extract_refs(text)
        adjacency[key] = sorted(refs)
    return dict(adjacency)

# 4. Compute Transitive Closure
def transitive_closure(adjacency):
    closure = {}
    for key in adjacency:
        seen = set()
        stack = list(adjacency[key])
        while stack:
            node = stack.pop()
            if node not in seen:
                seen.add(node)
                stack.extend(adjacency.get(node, []))
        closure[key] = sorted(seen)
    return closure

# 5. Export only Prolog
def export_prolog(data, out_path):
    with open(out_path, 'w', encoding='utf-8') as f:
        for k, v in data.items():
            vlist = ','.join(v)
            f.write(f"xref({k}, [{vlist}]).\n")

def main():
    # Determine project root
    project_root = os.environ.get('PROJECT_ROOT')
    if not project_root:
        project_root = find_project_root(os.path.dirname(__file__))
    # Statute source path relative to project root
    statute_dir = os.path.join(project_root, 'data/sara_v3/statutes/source')
    texts = load_statute_texts(statute_dir)
    adjacency = build_adjacency(texts)
    closure = transitive_closure(adjacency)
    out_dir = os.path.join(os.path.dirname(__file__), '../prolog_codebase')
    os.makedirs(out_dir, exist_ok=True)
    export_prolog(closure, os.path.join(out_dir, 'crossref_closure.pl'))
    print('Prolog cross-reference table exported to prolog_codebase/crossref_closure.pl')

if __name__ == '__main__':
    main() 