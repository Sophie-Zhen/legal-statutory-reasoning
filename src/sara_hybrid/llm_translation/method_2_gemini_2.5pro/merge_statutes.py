import os

def combine_statutes(source_dir, output_file):
    """Combine all statute files into a single file, separating by sections."""
    statute_files = sorted([f for f in os.listdir(source_dir)])
    
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for i, filename in enumerate(statute_files, 1):
            section_title = f"section {i}"
            outfile.write(f"{section_title}\n")
            outfile.write("=" * len(section_title) + "\n\n")
            
            file_path = os.path.join(source_dir, filename)
            with open(file_path, 'r', encoding='utf-8') as infile:
                content = infile.read()
                outfile.write(content)
                outfile.write("\n\n")

source_directory = "data/sara_v3/statutes/source"
output_file_path = "src/sara_hybrid/llm_translation/method_2_gemini_2.5pro/statutes.txt"
combine_statutes(source_directory, output_file_path)
