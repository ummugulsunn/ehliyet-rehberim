import json
import os

EXAMS_FILE = 'assets/data/exams.json'

def remove_exam(exam_id_to_remove):
    if not os.path.exists(EXAMS_FILE):
        return

    try:
        with open(EXAMS_FILE, 'r', encoding='utf-8') as f:
            exams = json.load(f)
        
        initial_count = len(exams)
        exams = [e for e in exams if e['examId'] != exam_id_to_remove]
        final_count = len(exams)

        if initial_count != final_count:
            with open(EXAMS_FILE, 'w', encoding='utf-8') as f:
                json.dump(exams, f, ensure_ascii=False, indent=2)
            print(f"Removed exam '{exam_id_to_remove}'.")
        else:
            print(f"Exam '{exam_id_to_remove}' not found.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    remove_exam("deneme_sinavi_3")
