import os

def clean_content(content):
    """Clean the content by removing excessive whitespace and empty lines."""
    # Split into lines and remove empty lines and excessive whitespace
    lines = [line.rstrip() for line in content.split('\n')]
    # Remove empty lines at the beginning and end
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    # Remove all empty lines within the content
    lines = [line for line in lines if line.strip()]
    return '\n'.join(lines)

def combine_statutes(source_dir, output_file):
    """Combine all statute files into a single file with clean formatting."""
    # Get all statute files and sort them
    statute_files = sorted([f for f in os.listdir(source_dir) if os.path.isfile(os.path.join(source_dir, f))])
    
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for i, filename in enumerate(statute_files):
            # Extract section name from filename (remove 'section' prefix)
            section_name = filename.replace('section', '').strip()
            if section_name:
                section_title = f"Section {section_name}"
            else:
                section_title = f"Section {i+1}"
            
            # Write section header
            outfile.write(f"{section_title}\n")
            outfile.write("-" * len(section_title) + "\n")
            
            # Read and clean the content
            file_path = os.path.join(source_dir, filename)
            with open(file_path, 'r', encoding='utf-8') as infile:
                content = infile.read()
                cleaned_content = clean_content(content)
                outfile.write(cleaned_content)
            
            # Add single newline between sections (except for the last one)
            if i < len(statute_files) - 1:
                outfile.write("\n\n")
            else:
                outfile.write("\n")

def main():
    source_directory = "data/sara_v3/statutes/source"
    output_file_path = "src/sara_hybrid/llm_translation/method_2_gemini_2.5pro/statutes.txt"
    
    print(f"Combining statutes from {source_directory}...")
    combine_statutes(source_directory, output_file_path)
    print(f"Statutes combined successfully into {output_file_path}")

if __name__ == "__main__":
    main()
