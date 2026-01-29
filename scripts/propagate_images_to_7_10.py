#!/usr/bin/env python3
"""
Propagate images to Deneme 7-10 using any previously imaged questions as sources.
Does not overwrite existing images. Also propagates option images when available.
"""

import json
import os
import sys
from typing import Dict, List, Tuple, Set
from collections import defaultdict


PROJECT_DIR = "/Users/ummugulsun/Ehliyet Rehberim/ehliyet_rehberim"
EXAMS_JSON = os.path.join(PROJECT_DIR, "assets/data/exams.json")
OUTPUT_REPORT = os.path.join(PROJECT_DIR, "analysis/propagation_report_7_10.json")


def normalize(text: str) -> str:
    if text is None:
        return ""
    s = text.lower().strip()
    while "  " in s:
        s = s.replace("  ", " ")
    for char in '.,;:!?"\'':
        s = s.replace(char, "")
    return s


def load_exams() -> List[dict]:
    with open(EXAMS_JSON, "r", encoding="utf-8") as f:
        return json.load(f)


def save_exams(data: List[dict]) -> None:
    tmp_path = EXAMS_JSON + ".tmp"
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    os.replace(tmp_path, EXAMS_JSON)


def extract_option_images(options: dict) -> Dict[str, str]:
    option_images: Dict[str, str] = {}
    for key, value in options.items():
        if isinstance(value, dict) and "imageUrl" in value and value["imageUrl"]:
            option_images[key] = value["imageUrl"]
    return option_images


def file_exists_for_image_url(image_url: str) -> bool:
    if not image_url:
        return False
    abs_path = os.path.join(PROJECT_DIR, image_url)
    return os.path.exists(abs_path)


def build_source_image_map(data: List[dict], exclude_exam_ids: Set[str]) -> Dict[str, Tuple[str, Dict[str, str]]]:
    """
    Map normalized question text -> (imageUrl, option_images) from ALL exams except excluded ones.
    Prefer entries that provide more total images (main + options).
    """
    norm_to_images: Dict[str, Tuple[str, Dict[str, str]]] = {}
    for exam in data:
        exam_id = exam.get("examId", "")
        if exam_id in exclude_exam_ids:
            continue
        for q in exam.get("questions", []):
            text = q.get("questionText", "")
            norm = normalize(text)
            image_url = q.get("imageUrl") if file_exists_for_image_url(q.get("imageUrl")) else None
            option_images = extract_option_images(q.get("options", {}))
            if not image_url and not option_images:
                continue
            existing = norm_to_images.get(norm)
            if existing:
                existing_url, existing_opts = existing
                new_count = (1 if image_url else 0) + len(option_images)
                existing_count = (1 if existing_url else 0) + len(existing_opts)
                if new_count > existing_count:
                    norm_to_images[norm] = (image_url, option_images)
            else:
                norm_to_images[norm] = (image_url, option_images)
    return norm_to_images


def propagate_to_targets(
    data: List[dict],
    source_map: Dict[str, Tuple[str, Dict[str, str]]],
    target_exam_ids: Set[str],
) -> dict:
    stats = {
        "total_questions_updated": 0,
        "main_images_added": 0,
        "option_images_added": 0,
        "exams_affected": set(),
        "detailed_updates": [],
    }

    for exam in data:
        exam_id = exam.get("examId", "")
        if exam_id not in target_exam_ids:
            continue
        for q in exam.get("questions", []):
            text = q.get("questionText", "")
            norm = normalize(text)
            source = source_map.get(norm)
            if not source:
                continue
            source_url, source_option_images = source
            updated = False
            update_details = {
                "examId": exam_id,
                "questionId": q.get("id"),
                "questionText": text,
                "updates": [],
            }

            # Main image: only if missing
            if source_url and not q.get("imageUrl"):
                q["imageUrl"] = source_url
                stats["main_images_added"] += 1
                update_details["updates"].append(f"Added main image: {source_url}")
                updated = True

            # Option images
            if source_option_images:
                options = q.get("options", {})
                for opt_key, opt_value in list(options.items()):
                    if opt_key not in source_option_images:
                        continue
                    src_opt_url = source_option_images[opt_key]
                    if isinstance(opt_value, str):
                        options[opt_key] = {"text": opt_value, "imageUrl": src_opt_url}
                        stats["option_images_added"] += 1
                        update_details["updates"].append(f"Added option {opt_key} image")
                        updated = True
                    elif isinstance(opt_value, dict) and not opt_value.get("imageUrl"):
                        opt_value["imageUrl"] = src_opt_url
                        stats["option_images_added"] += 1
                        update_details["updates"].append(f"Added option {opt_key} image")
                        updated = True

            if updated:
                stats["total_questions_updated"] += 1
                stats["exams_affected"].add(exam_id)
                stats["detailed_updates"].append(update_details)

    stats["exams_affected"] = sorted(list(stats["exams_affected"]))
    return stats


def main() -> int:
    print("🚀 Propagation to Deneme 7-10 started...")
    data = load_exams()

    target_exam_ids: Set[str] = {"deneme_sinavi_7", "deneme_sinavi_8", "deneme_sinavi_9", "deneme_sinavi_10"}
    exclude_sources = set(target_exam_ids)  # do not source from the targets themselves

    source_map = build_source_image_map(data, exclude_sources)
    print(f"✅ Source questions with images found: {len(source_map)}")

    stats = propagate_to_targets(data, source_map, target_exam_ids)

    if stats["total_questions_updated"] > 0:
        save_exams(data)
        print("✅ exams.json updated for Deneme 7-10")
    else:
        print("ℹ️ No updates were necessary for Deneme 7-10")

    # Save detailed report
    report = {
        "targets": sorted(list(target_exam_ids)),
        "propagation_stats": stats,
    }
    with open(OUTPUT_REPORT, "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    print(f"📄 Report saved: {OUTPUT_REPORT}")

    # Summary
    print("\n📊 Summary:")
    print(f"  - Questions updated: {stats['total_questions_updated']}")
    print(f"  - Main images added: {stats['main_images_added']}")
    print(f"  - Option images added: {stats['option_images_added']}")
    print(f"  - Exams affected: {', '.join(stats['exams_affected']) if stats['exams_affected'] else 'none'}")

    return 0


if __name__ == "__main__":
    sys.exit(main())


