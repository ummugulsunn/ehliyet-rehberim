import json
import os

EXAMS_FILE = 'assets/data/exams.json'

def fix_explanations():
    if not os.path.exists(EXAMS_FILE):
        print("Exams file not found.")
        return

    try:
        with open(EXAMS_FILE, 'r', encoding='utf-8') as f:
            exams = json.load(f)
        
        fixed_count = 0
        for exam in exams:
            for question in exam['questions']:
                if 'explanation' not in question or question['explanation'] is None:
                    question['explanation'] = "Açıklama henüz eklenmedi."
                    fixed_count += 1
        
        if fixed_count > 0:
            with open(EXAMS_FILE, 'w', encoding='utf-8') as f:
                json.dump(exams, f, ensure_ascii=False, indent=2)
            print(f"Fixed {fixed_count} questions by adding default explanation.")
        else:
            print("No questions found missing explanations.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    fix_explanations()
