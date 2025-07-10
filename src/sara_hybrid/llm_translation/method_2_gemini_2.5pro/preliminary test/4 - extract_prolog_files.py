#!/usr/bin/env python3
import os
import re

def extract_prolog_files(input_file_path, output_directory):
    """
    Extract Prolog code from the input file and create separate .pl files.
    
    Args:
        input_file_path: Path to the gemini_raw_answer2.1.txt file
        output_directory: Directory where to save the extracted .pl files
    """
    
    # Read the entire file
    with open(input_file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Define the file patterns to look for
    file_patterns = [
        'helpers.pl',
        'section7703.pl', 
        'section152.pl',
        'section2.pl',
        'section151.pl',
        'section68.pl',
        'section63.pl',
        'section1.pl',
        'section3301.pl',
        'section3306.pl',
        'tests.pl'
    ]
    
    # Create output directory if it doesn't exist
    os.makedirs(output_directory, exist_ok=True)
    
    extracted_files = []
    
    for i, pattern in enumerate(file_patterns):
        print(f"Processing {pattern}...")
        
        # Find the start of this file
        start_marker = f"\n{pattern}\n"
        start_pos = content.find(start_marker)
        
        if start_pos == -1:
            print(f"Warning: Could not find {pattern}")
            continue
        
        # Find the end of this file (next file marker or end of content)
        end_pos = len(content)
        for next_pattern in file_patterns[i+1:]:
            next_marker = f"\n{next_pattern}\n"
            next_pos = content.find(next_marker, start_pos)
            if next_pos != -1:
                end_pos = next_pos
                break
        
        # Extract the content for this file
        file_content = content[start_pos + len(start_marker):end_pos].strip()
        
        # Clean up the content
        file_content = clean_prolog_content(file_content)
        
        # Save to file
        output_file_path = os.path.join(output_directory, pattern)
        with open(output_file_path, 'w', encoding='utf-8') as f:
            f.write(file_content)
        
        extracted_files.append(pattern)
        print(f"Created {output_file_path}")
    
    print(f"\nExtraction complete! Created {len(extracted_files)} files:")
    for file in extracted_files:
        print(f"  - {file}")

def clean_prolog_content(content):
    """
    Clean up the Prolog content by removing unnecessary formatting and text.
    """
    # Remove content after "IGNORE_WHEN_COPYING_START"
    ignore_marker = "IGNORE_WHEN_COPYING_START"
    if ignore_marker in content:
        content = content.split(ignore_marker)[0].strip()
    
    lines = content.split('\n')
    cleaned_lines = []
    
    # Skip lines that are not part of the Prolog code
    skip_patterns = [
        'Generated prolog',
        'Here is the first set of files:',
        'Here is Part',
        'These modules',
        'I have generated',
        'I will stop here',
        'Next will be',
        'This is a good point',
        'The final part',
        'This completes',
        'All Files Generated',
        'tests.pl Details:',
        'Modularity:',
        'The code should be'
    ]
    
    for line in lines:
        # Skip lines that match skip patterns
        should_skip = False
        for pattern in skip_patterns:
            if pattern.lower() in line.lower():
                should_skip = True
                break
        
        if should_skip:
            continue
        
        # Keep the line if it's not empty or just whitespace
        if line.strip():
            cleaned_lines.append(line)
    
    return '\n'.join(cleaned_lines)

def main():
    # Get the directory of the current script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Input file path
    input_file = os.path.join(script_dir, "gemini_raw_answer2.1.txt")
    
    # Output directory (same as input file)
    output_dir = script_dir
    
    print(f"Extracting Prolog files from: {input_file}")
    print(f"Output directory: {output_dir}")
    print("-" * 50)
    
    if not os.path.exists(input_file):
        print(f"Error: Input file {input_file} not found!")
        return
    
    extract_prolog_files(input_file, output_dir)

if __name__ == "__main__":
    main() 