def read_file(file_path):
    """Read the content of a file and return it as a string."""
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()

def extract_cases(cases_content):
    """Extract only the essential case information (Case ID, Text, Question) from the cases content."""
    cases = []
    lines = cases_content.splitlines()
    current_case = {}
    
    for line in lines:
        line = line.strip()
        
        # Skip empty lines, separators, headers, and case numbers
        if (not line or 
            line.startswith('-') or 
            line.startswith('=') or 
            line.startswith('S CASES:') or 
            line.startswith('TAX CASES:') or 
            line.startswith('Case ') and ':' in line and not line.startswith('Case ID:')):
            continue
            
        # Extract Case ID
        if line.startswith('Case ID:'):
            if current_case:  # Save previous case if exists
                cases.append(current_case)
            current_case = {'case_id': line.replace('Case ID:', '').strip()}
            
        # Extract Text
        elif line.startswith('Text:'):
            current_case['text'] = line.replace('Text:', '').strip()
            
        # Extract Question
        elif line.startswith('Question:'):
            current_case['question'] = line.replace('Question:', '').strip()
    
    # Add the last case
    if current_case:
        cases.append(current_case)
    
    # Format cases as clean strings
    formatted_cases = []
    for case in cases:
        if 'case_id' in case and 'text' in case and 'question' in case:
            formatted_case = f"Case ID: {case['case_id']}\nText: {case['text']}\nQuestion: {case['question']}"
            formatted_cases.append(formatted_case)
    
    return formatted_cases

def create_prompt(prompt_file, statutes_file, cases_file, output_file):
    """Create a prompt by merging the contents of the prompt, statutes, and cases files."""
    # Read the contents of each file
    prompt_content = read_file(prompt_file)
    statutes_content = read_file(statutes_file)
    cases_content = read_file(cases_file)
    
    # Extract case IDs, texts, and questions
    extracted_cases = extract_cases(cases_content)
    
    # Format the merged content
    merged_content = (
        f"{prompt_content}\n\n"
        f"Here are the statutes files:\n[{statutes_content}]\n\n"
        f"Selected Cases:\n[" + "\n\n".join(extracted_cases) + "]"
    )
    
    # Write the merged content to the output file
    with open(output_file, 'w', encoding='utf-8') as file:
        file.write(merged_content)

def main():
    prompt_file_path = "promt3.0.txt"
    statutes_file_path = "statutes.txt"
    cases_file_path = "selected_cases.txt"
    output_file_path = "merged_prompt3.0.txt"
    
    print("Creating merged prompt...")
    create_prompt(prompt_file_path, statutes_file_path, cases_file_path, output_file_path)
    print(f"Merged prompt created successfully at {output_file_path}")

if __name__ == "__main__":
    main()






