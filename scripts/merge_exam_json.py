import json
import os

EXAMS_FILE = 'assets/data/exams.json'
IMPORTED_FILE = 'assets/data/imported_questions.json'

def merge_exams():
    if not os.path.exists(IMPORTED_FILE):
        print(f"Error: {IMPORTED_FILE} not found.")
        return

    if not os.path.exists(EXAMS_FILE):
        print(f"Error: {EXAMS_FILE} not found.")
        return

    try:
        with open(EXAMS_FILE, 'r', encoding='utf-8') as f:
            exams = json.load(f)
        
        with open(IMPORTED_FILE, 'r', encoding='utf-8') as f:
            new_questions = json.load(f)

        # Create new exam object
        new_exam = {
            "examId": "deneme_sinavi_30",
            "examName": "Ehliyet Deneme Sınavı - 30 (Ocak 2026)",
            "questions": new_questions
        }

        # Check if already exists to avoid duplicates (by ID)
        existing_ids = [e['examId'] for e in exams]
        if new_exam['examId'] in existing_ids:
            print(f"Exam {new_exam['examId']} already exists. Replacing it.")
            exams = [e for e in exams if e['examId'] != new_exam['examId']]
        
        exams.append(new_exam)

        with open(EXAMS_FILE, 'w', encoding='utf-8') as f:
            json.dump(exams, f, ensure_ascii=False, indent=2)

        print(f"Successfully added exam '{new_exam['examName']}' with {len(new_questions)} questions.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    merge_exams()
