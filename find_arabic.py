import os
import re

def find_arabic_strings(root_dir):
    arabic_pattern = re.compile(r'[\u0600-\u06FF]')
    string_pattern = re.compile(r'(["\'])(.*?)\1')
    comment_pattern = re.compile(r'//.*$|/\*.*?\*/', re.MULTILINE | re.DOTALL)

    results = []
    
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart') and 'l10n' not in subdir and 'app_localizations' not in file:
                file_path = os.path.join(subdir, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                        # Remove comments
                        content_no_comments = comment_pattern.sub('', content)
                        
                        # Find all strings
                        for string_match in string_pattern.finditer(content_no_comments):
                            string_literal = string_match.group(2)
                            if arabic_pattern.search(string_literal):
                                results.append(f"{file_path}: {string_literal}")
                except Exception as e:
                    pass
    
    with open('c:/Projects_Flutter/Namaa_Project_App/arabic_strings.txt', 'w', encoding='utf-8') as out:
        for r in set(results):
            out.write(r + '\n')

find_arabic_strings('c:/Projects_Flutter/Namaa_Project_App/lib')

