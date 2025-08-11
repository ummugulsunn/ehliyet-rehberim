#!/usr/bin/env python3
"""
Advanced Image Propagator for Ehliyet Rehberim
Analyzes questions in Deneme 1-6 and propagates their images to matching questions in all other exams.
"""

import json
import os
import sys
from typing import Dict, List, Tuple, Set
from collections import defaultdict

PROJECT_DIR = "/Users/ummugulsun/Ehliyet Rehberim/ehliyet_rehberim"
EXAMS_JSON = os.path.join(PROJECT_DIR, "assets/data/exams.json")
REPORT_JSON = os.path.join(PROJECT_DIR, "analysis/exams_report.json")
MISSING_CSV = os.path.join(PROJECT_DIR, "analysis/missing_images.csv")
OUTPUT_REPORT = os.path.join(PROJECT_DIR, "analysis/propagation_report.json")


def normalize(text: str) -> str:
    """Normalize question text for comparison"""
    if text is None:
        return ""
    s = text.lower().strip()
    # Remove extra spaces
    while "  " in s:
        s = s.replace("  ", " ")
    # Remove punctuation for better matching
    for char in '.,;:!?"\'':
        s = s.replace(char, "")
    return s


def load_exams() -> List[dict]:
    """Load exams data from JSON"""
    with open(EXAMS_JSON, "r", encoding="utf-8") as f:
        return json.load(f)


def save_exams(data: List[dict]) -> None:
    """Save exams data to JSON"""
    tmp_path = EXAMS_JSON + ".tmp"
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    os.replace(tmp_path, EXAMS_JSON)


def file_exists_for_image_url(image_url: str) -> bool:
    """Check if the image file actually exists"""
    if not image_url:
        return False
    abs_path = os.path.join(PROJECT_DIR, image_url)
    return os.path.exists(abs_path)


def extract_option_images(options: dict) -> Dict[str, str]:
    """Extract imageUrl from options if they have them"""
    option_images = {}
    for key, value in options.items():
        if isinstance(value, dict) and "imageUrl" in value:
            option_images[key] = value["imageUrl"]
    return option_images


def build_source_image_map(data: List[dict]) -> Dict[str, Tuple[str, Dict[str, str]]]:
    """
    Build a comprehensive map from normalized question text to (imageUrl, option_images)
    for Deneme 1-5 only.
    """
    norm_to_images = {}
    source_exam_ids = [
        "deneme_sinavi_1",
        "deneme_sinavi_2",
        "deneme_sinavi_3",
        "deneme_sinavi_4",
        "deneme_sinavi_5",
        "deneme_sinavi_6",
    ]
    
    for exam in data:
        exam_id = exam.get("examId", "")
        if exam_id not in source_exam_ids:
            continue
            
        for q in exam.get("questions", []):
            text = q.get("questionText", "")
            norm = normalize(text)
            image_url = q.get("imageUrl")
            
            # Extract option images if present
            option_images = extract_option_images(q.get("options", {}))
            
            # Only store if there's at least one image (main or option)
            if image_url or option_images:
                # Prefer entries with more images
                existing = norm_to_images.get(norm)
                if existing:
                    existing_url, existing_opt = existing
                    # Count total images
                    new_count = (1 if image_url else 0) + len(option_images)
                    existing_count = (1 if existing_url else 0) + len(existing_opt)
                    if new_count > existing_count:
                        norm_to_images[norm] = (image_url, option_images)
                else:
                    norm_to_images[norm] = (image_url, option_images)
    
    return norm_to_images


def propagate_all_images(data: List[dict], source_map: Dict[str, Tuple[str, Dict[str, str]]]) -> dict:
    """
    Propagate images to all matching questions in ALL exams (including 6-15).
    Returns detailed statistics.
    """
    stats = {
        "total_questions_updated": 0,
        "main_images_added": 0,
        "option_images_added": 0,
        "exams_affected": set(),
        "detailed_updates": []
    }
    
    for exam in data:
        exam_id = exam.get("examId", "")
        
        for q in exam.get("questions", []):
            text = q.get("questionText", "")
            norm = normalize(text)
            
            # Check if we have images for this question
            if norm in source_map:
                source_url, source_options = source_map[norm]
                updated = False
                update_details = {
                    "examId": exam_id,
                    "questionId": q.get("id"),
                    "questionText": text,
                    "updates": []
                }
                
                # Update main image if missing
                if source_url and not q.get("imageUrl"):
                    q["imageUrl"] = source_url
                    stats["main_images_added"] += 1
                    update_details["updates"].append(f"Added main image: {source_url}")
                    updated = True
                
                # Update option images
                if source_options:
                    options = q.get("options", {})
                    for opt_key, opt_value in options.items():
                        if opt_key in source_options:
                            # Check if option needs image
                            if isinstance(opt_value, str):
                                # Convert string option to dict with imageUrl
                                options[opt_key] = {
                                    "text": opt_value,
                                    "imageUrl": source_options[opt_key]
                                }
                                stats["option_images_added"] += 1
                                update_details["updates"].append(f"Added option {opt_key} image")
                                updated = True
                            elif isinstance(opt_value, dict) and not opt_value.get("imageUrl"):
                                # Add imageUrl to existing dict
                                opt_value["imageUrl"] = source_options[opt_key]
                                stats["option_images_added"] += 1
                                update_details["updates"].append(f"Added option {opt_key} image")
                                updated = True
                
                if updated:
                    stats["total_questions_updated"] += 1
                    stats["exams_affected"].add(exam_id)
                    stats["detailed_updates"].append(update_details)
    
    # Convert set to list for JSON serialization
    stats["exams_affected"] = list(stats["exams_affected"])
    return stats


def analyze_remaining_missing(data: List[dict]) -> dict:
    """Analyze what's still missing after propagation"""
    visual_keywords = [
        'şekil', 'şekle göre', 'şekildeki', 'resim', 'görsel', 'levha', 
        'işaret', 'gösterge', 'ikaz ışığı', 'yatay işaretleme', 
        'taşıt yolu üzerine çizilen', 'dönel kavşak'
    ]
    
    still_missing = []
    by_exam = defaultdict(int)
    
    for exam in data:
        exam_id = exam.get("examId", "")
        for q in exam.get("questions", []):
            text = q.get("questionText", "").lower()
            needs_visual = any(keyword in text for keyword in visual_keywords)
            
            if needs_visual and not q.get("imageUrl"):
                still_missing.append({
                    "examId": exam_id,
                    "questionId": q.get("id"),
                    "questionText": q.get("questionText"),
                    "category": q.get("category")
                })
                by_exam[exam_id] += 1
    
    return {
        "total_still_missing": len(still_missing),
        "by_exam": dict(by_exam),
        "sample_missing": still_missing[:10]  # First 10 for review
    }


def main():
    print("🚀 Advanced Image Propagator başlatılıyor...")
    
    # Load data
    data = load_exams()
    print(f"✅ {len(data)} deneme sınavı yüklendi")
    
    # Build source map from Deneme 1-6
    source_map = build_source_image_map(data)
    print(f"✅ Deneme 1-6'dan {len(source_map)} farklı soru için görsel bulundu")
    
    # Count images by type
    main_images = sum(1 for url, _ in source_map.values() if url)
    with_option_images = sum(1 for _, opts in source_map.values() if opts)
    print(f"   - Ana görsel içeren: {main_images}")
    print(f"   - Seçenek görseli içeren: {with_option_images}")
    
    # Propagate images
    print("\n🔄 Görseller tüm denemelere yayılıyor...")
    stats = propagate_all_images(data, source_map)
    
    # Save updated data
    if stats["total_questions_updated"] > 0:
        save_exams(data)
        print(f"✅ exams.json güncellendi!")
    
    # Analyze remaining
    print("\n📊 Propagasyon sonuçları:")
    print(f"   - Güncellenen toplam soru: {stats['total_questions_updated']}")
    print(f"   - Eklenen ana görsel: {stats['main_images_added']}")
    print(f"   - Eklenen seçenek görseli: {stats['option_images_added']}")
    print(f"   - Etkilenen deneme sayısı: {len(stats['exams_affected'])}")
    
    # Check what's still missing
    remaining = analyze_remaining_missing(data)
    print(f"\n📌 Hala eksik olan görsel sayısı: {remaining['total_still_missing']}")
    
    # Save detailed report
    report = {
        "propagation_stats": stats,
        "remaining_missing": remaining,
        "source_questions": len(source_map)
    }
    
    with open(OUTPUT_REPORT, "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    
    print(f"\n📄 Detaylı rapor kaydedildi: {OUTPUT_REPORT}")
    
    # Show affected exams
    if stats["exams_affected"]:
        print("\n🎯 Güncellenen denemeler:")
        for exam_id in sorted(stats["exams_affected"]):
            count = sum(1 for u in stats["detailed_updates"] if u["examId"] == exam_id)
            print(f"   - {exam_id}: {count} soru güncellendi")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
