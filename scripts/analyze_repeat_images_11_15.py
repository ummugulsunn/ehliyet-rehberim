#!/usr/bin/env python3
"""
Deneme 11-15 için tekrar eden soruların, önceki denemelerde (1-10) zaten eklenmiş görsellerle
hangi ölçüde eşleştiğini analiz eder. Hiçbir değişiklik yapmaz, sadece rapor üretir.

Çıktılar:
- analysis/repeat_image_analysis_11_15.json (ayrıntılı JSON)
- analysis/repeat_image_analysis_11_15.csv (özet CSV)
"""

from __future__ import annotations
import json
import re
import csv
from typing import Dict, List, Tuple
from pathlib import Path

EXAMS_FILE = "assets/data/exams.json"
OUTPUT_JSON = "analysis/repeat_image_analysis_11_15.json"
OUTPUT_CSV = "analysis/repeat_image_analysis_11_15.csv"

TARGET_EXAMS = [
    "deneme_sinavi_11",
    "deneme_sinavi_12",
    "deneme_sinavi_13",
    "deneme_sinavi_14",
    "deneme_sinavi_15",
]


def normalize_text(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^\w\s]", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def load_exams() -> List[dict]:
    with open(EXAMS_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def build_source_map(exams: List[dict]) -> Dict[str, Tuple[str, Dict[str, str]]]:
    """Kaynak soru metni -> (ana_gorsel, seçenek_gorselleri) map'i (Deneme 1-10)."""
    source_map: Dict[str, Tuple[str, Dict[str, str]]] = {}
    for exam in exams:
        if exam.get("examId") in TARGET_EXAMS:
            continue
        for q in exam.get("questions", []):
            qtext = q.get("questionText", "")
            if not qtext:
                continue
            norm = normalize_text(qtext)
            img = q.get("imageUrl")
            if not img or img == "null":
                continue
            option_images: Dict[str, str] = {}
            options = q.get("options", {})
            for key, val in options.items():
                if isinstance(val, dict) and val.get("imageUrl"):
                    option_images[key] = val["imageUrl"]
            source_map[norm] = (img, option_images)
    return source_map


def analyze_targets(exams: List[dict], source_map: Dict[str, Tuple[str, Dict[str, str]]]) -> dict:
    report = {
        "summary": {
            "targets": TARGET_EXAMS,
            "source_exam_range": "deneme_sinavi_1..deneme_sinavi_10",
            "total_target_exams": 0,
            "total_questions": 0,
            "repeated_questions": 0,
            "can_add_main_images": 0,
            "already_has_main_images": 0,
            "conflicting_main_images": 0,
            "option_images_candidates": 0,
        },
        "exams": {},
    }

    for exam in exams:
        exam_id = exam.get("examId")
        if exam_id not in TARGET_EXAMS:
            continue
        exam_block = {
            "total_questions": 0,
            "repeated_questions": 0,
            "can_add_main_images": 0,
            "already_has_main_images": 0,
            "conflicting_main_images": 0,
            "option_images_candidates": 0,
            "details": [],
        }
        for q in exam.get("questions", []):
            exam_block["total_questions"] += 1
            report["summary"]["total_questions"] += 1
            qtext = q.get("questionText", "")
            norm = normalize_text(qtext)
            if not norm:
                continue
            if norm in source_map:
                exam_block["repeated_questions"] += 1
                report["summary"]["repeated_questions"] += 1
                src_img, src_option_imgs = source_map[norm]
                cur_img = q.get("imageUrl")
                status = ""
                if not cur_img or cur_img == "null":
                    status = "needs_main_image"
                    exam_block["can_add_main_images"] += 1
                    report["summary"]["can_add_main_images"] += 1
                else:
                    if cur_img == src_img:
                        status = "has_same_main_image"
                        exam_block["already_has_main_images"] += 1
                        report["summary"]["already_has_main_images"] += 1
                    else:
                        status = "has_different_main_image"
                        exam_block["conflicting_main_images"] += 1
                        report["summary"]["conflicting_main_images"] += 1
                option_candidate_count = len(src_option_imgs or {})
                if option_candidate_count:
                    exam_block["option_images_candidates"] += option_candidate_count
                    report["summary"]["option_images_candidates"] += option_candidate_count
                exam_block["details"].append({
                    "questionId": q.get("id"),
                    "questionText": qtext,
                    "status": status,
                    "currentImage": cur_img,
                    "recommendedImage": src_img,
                    "optionImages": src_option_imgs,
                })
        report["exams"][exam_id] = exam_block
        report["summary"]["total_target_exams"] += 1
    return report


def write_reports(report: dict) -> None:
    Path(OUTPUT_JSON).parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)

    # CSV: sadece eklenebilecek ana görsel adaylarını listeler
    rows: List[List[str]] = [[
        "examId", "questionId", "status", "currentImage", "recommendedImage", "questionText"
    ]]
    for exam_id, block in report.get("exams", {}).items():
        for d in block.get("details", []):
            if d.get("status") == "needs_main_image":
                rows.append([
                    exam_id,
                    str(d.get("questionId")),
                    d.get("status", ""),
                    d.get("currentImage") or "",
                    d.get("recommendedImage") or "",
                    (d.get("questionText") or "").replace("\n", " ")[:200]
                ])
    with open(OUTPUT_CSV, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerows(rows)


def main() -> int:
    if not Path(EXAMS_FILE).exists():
        print(f"❌ Bulunamadı: {EXAMS_FILE}")
        return 1
    exams = load_exams()
    source_map = build_source_map(exams)
    print(f"🔍 Kaynak görsel eşleşmeleri: {len(source_map)}")
    report = analyze_targets(exams, source_map)
    write_reports(report)
    s = report["summary"]
    print("\n📊 Özet:")
    print(f"  - Hedef denemeler: {', '.join(TARGET_EXAMS)}")
    print(f"  - Toplam hedef deneme: {s['total_target_exams']}")
    print(f"  - Toplam soru: {s['total_questions']}")
    print(f"  - Tekrarlayan soru: {s['repeated_questions']}")
    print(f"  - Ana görsel eklenebilir (kaynakta var, hedefte yok): {s['can_add_main_images']}")
    print(f"  - Hedefte zaten aynı ana görsel var: {s['already_has_main_images']}")
    print(f"  - Hedefte farklı ana görsel var (çakışma): {s['conflicting_main_images']}")
    print(f"  - Seçenek görseli adayları (toplam): {s['option_images_candidates']}")
    print(f"\n📄 JSON: {OUTPUT_JSON}")
    print(f"📄 CSV : {OUTPUT_CSV}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
