import json
import os
import urllib.request
import hashlib
from urllib.parse import urlparse

def download_assets():
    print("Starting Asset Migration (Urllib Mode)...")
    
    exams_path = 'assets/data/exams.json'
    base_download_dir = 'assets/images/downloaded'
    
    if not os.path.exists(base_download_dir):
        os.makedirs(base_download_dir)
        
    try:
        with open(exams_path, 'r', encoding='utf-8') as f:
            exams = json.load(f)
            
        total_downloaded = 0
        
        # Helper to process a URL
        def process_url(url, exam_id):
            if not url or not url.lower().startswith('http'):
                return url
                
            # Keep extension
            parsed = urlparse(url)
            path = parsed.path
            ext = os.path.splitext(path)[1]
            if not ext: ext = '.jpg'
            
            # Sanitized exam folder
            exam_dir = os.path.join(base_download_dir, exam_id)
            if not os.path.exists(exam_dir):
                os.makedirs(exam_dir)
                
            # Hash URL for uniqueness
            md5 = hashlib.md5(url.encode('utf-8')).hexdigest()
            filename = f"{md5}{ext}"
            local_path = os.path.join(exam_dir, filename)
            project_path = local_path # relative path for JSON
            
            if os.path.exists(local_path):
                # Already downloaded
                return project_path
                
            try:
                print(f"Downloading {url}...")
                req = urllib.request.Request(
                    url, 
                    headers={'User-Agent': 'Mozilla/5.0'}
                )
                with urllib.request.urlopen(req, timeout=10) as response, open(local_path, 'wb') as out_file:
                    out_file.write(response.read())
                return project_path
            except Exception as e:
                print(f"Error downloading {url}: {e}")
                return url
                
        # Iterate exams
        for exam in exams:
            exam_id = exam['examId']
            # print(f"Processing Exam: {exam_id}")
            
            for q in exam['questions']:
                # Question Image
                if q.get('imageUrl') and q['imageUrl'].lower().startswith('http'):
                    new_path = process_url(q['imageUrl'], exam_id)
                    if new_path != q['imageUrl']:
                        q['imageUrl'] = new_path
                        total_downloaded += 1
                        
                # Option Images
                for key, opt in q['options'].items():
                    if isinstance(opt, dict) and opt.get('imageUrl') and opt['imageUrl'].lower().startswith('http'):
                        new_path = process_url(opt['imageUrl'], exam_id)
                        if new_path != opt['imageUrl']:
                            opt['imageUrl'] = new_path
                            total_downloaded += 1

        # Save updated JSON
        with open(exams_path, 'w', encoding='utf-8') as f:
            json.dump(exams, f, ensure_ascii=False, indent=2)
            
        print(f"\nMigration Complete. Downloaded/Updated: {total_downloaded}")
        
    except Exception as e:
        print(f"Critical Error: {e}")

if __name__ == "__main__":
    download_assets()
