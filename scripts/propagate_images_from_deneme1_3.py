#!/usr/bin/env python3
import json
import os
import sys
from typing import Dict, List, Tuple


PROJECT_DIR = "/Users/ummugulsun/Ehliyet Rehberim/ehliyet_rehberim"
EXAMS_JSON = os.path.join(PROJECT_DIR, "assets/data/exams.json")


def normalize(text: str) -> str:
    if text is None:
        return ""
    s = text.lower().strip()
    # collapse whitespace
    while "  " in s:
        s = s.replace("  ", " ")
    # remove quotes similar to Dart validate_exams.dart
    s = s.replace('"', '').replace("'", "")
    return s


def load_exams() -> List[dict]:
    with open(EXAMS_JSON, "r", encoding="utf-8") as f:
        return json.load(f)


def save_exams(data: List[dict]) -> None:
    tmp_path = EXAMS_JSON + ".tmp"
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    os.replace(tmp_path, EXAMS_JSON)


def file_exists_for_image_url(image_url: str) -> bool:
    if not image_url:
        return False
    # imageUrl stored like assets/images/xyz.png relative to project dir
    abs_path = os.path.join(PROJECT_DIR, image_url)
    return os.path.exists(abs_path)


def collect_source_images(data: List[dict], source_exam_ids: Tuple[str, ...]) -> Dict[str, str]:
    """
    Build a map: normalized(questionText) -> first existing imageUrl found in source exams.
    Preference order: jpg > png > gif > webp > svg, but we simply pick the first that exists.
    """
    norm_to_image: Dict[str, str] = {}

    def rank(image_url: str) -> int:
        if not image_url:
            return 999
        ext = os.path.splitext(image_url)[1].lower()
        order = [".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg"]
        try:
            return order.index(ext)
        except ValueError:
            return 500

    for exam in data:
        exam_id = exam.get("examId", "")
        if exam_id not in source_exam_ids:
            continue
        for q in exam.get("questions", []):
            text = q.get("questionText", "")
            norm = normalize(text)
            image_url = q.get("imageUrl")
            if not image_url:
                continue
            if not file_exists_for_image_url(image_url):
                continue
            prev = norm_to_image.get(norm)
            if prev is None or rank(image_url) < rank(prev):
                norm_to_image[norm] = image_url
    return norm_to_image


def propagate_images(data: List[dict], norm_to_image: Dict[str, str], target_exam_ids: Tuple[str, ...]) -> int:
    """
    For each question in target exams, if its normalized text matches and its imageUrl is null/empty,
    set imageUrl to the mapped one.
    Returns number of questions updated.
    """
    updates = 0
    for exam in data:
        exam_id = exam.get("examId", "")
        if target_exam_ids and exam_id not in target_exam_ids:
            continue
        for q in exam.get("questions", []):
            if q.get("imageUrl"):
                continue  # do not overwrite existing
            text = q.get("questionText", "")
            norm = normalize(text)
            new_url = norm_to_image.get(norm)
            if new_url:
                q["imageUrl"] = new_url
                updates += 1
    return updates


def main() -> int:
    data = load_exams()

    # sources: deneme 1-3; targets: all others except 1-3
    source_ids = ("deneme_sinavi_1", "deneme_sinavi_2", "deneme_sinavi_3")

    all_exam_ids = [e.get("examId", "") for e in data]
    target_ids = tuple([eid for eid in all_exam_ids if eid not in source_ids])

    source_map = collect_source_images(data, source_ids)

    updated = propagate_images(data, source_map, target_ids)
    if updated:
        save_exams(data)

    print(f"Propagate complete. Mapped images: {len(source_map)}. Questions updated: {updated}.")
    if updated:
        print("Saved exams.json with propagated imageUrls.")
    else:
        print("No updates needed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())


