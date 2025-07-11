import os

sara_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"
case_file = os.path.join(sara_path, "data/sara_v3/cases/s1_d_iv_neg.pl")

print("=== s1_d_iv_neg.pl contents ===")
with open(case_file, 'r') as f:
    content = f.read()
    print(content[:1000])  # First 1000 chars
    
print("\n=== Looking for facts ===")
lines = content.split('\n')
for line in lines:
    if line.strip() and not line.strip().startswith('%'):
        print(line[:100])
        
# Also check a simpler case
print("\n\n=== Checking a simpler case ===")
simple_case = os.path.join(sara_path, "data/sara_v3/cases/s3306_c_5_pos.pl")
if os.path.exists(simple_case):
    with open(simple_case, 'r') as f:
        print(f.read()[:500])