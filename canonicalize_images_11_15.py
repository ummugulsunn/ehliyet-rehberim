#!/usr/bin/env python3
"""
Deneme 11-15'teki tekrar eden soruların görsellerini, Deneme 1-10 arası kaynaklara göre
kanonik hâle getirir. Eksik ana görselleri ekler ve farklı olan ana görselleri kaynak görselle değiştirir.

Ayrıca varsa seçenek görsellerini de kaynakla eşler.
"""

from __future__ import annotations
import json
import re
from typing import Dict, List, Tuple
from pathlib import Path

EXAMS_FILE = "assets/data/exams.json"
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


def load() -> List[dict]:
    with open(EXAMS_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def save(data: List[dict]) -> None:
    with open(EXAMS_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def build_source_map(data: List[dict]) -> Dict[str, Tuple[str, Dict[str, str]]]:
    source: Dict[str, Tuple[str, Dict[str, str]]] = {}
    for exam in data:
        if exam.get("examId") in TARGET_EXAMS:
            continue
        for q in exam.get("questions", []):
            qt = q.get("questionText", "")
            if not qt:
                continue
            norm = normalize_text(qt)
            img = q.get("imageUrl")
            if not img or img == "null":
                continue
            opt_imgs: Dict[str, str] = {}
            for k, v in (q.get("options", {}) or {}).items():
                if isinstance(v, dict) and v.get("imageUrl"):
                    opt_imgs[k] = v["imageUrl"]
            source[norm] = (img, opt_imgs)
    return source


def canonicalize(data: List[dict], source_map: Dict[str, Tuple[str, Dict[str, str]]]) -> dict:
    stats = {
        "exams_updated": set(),
        "questions_canonicalized": 0,
        "main_images_added": 0,
        "main_images_replaced": 0,
        "option_images_added": 0,
    }
    for exam in data:
        exam_id = exam.get("examId")
        if exam_id not in TARGET_EXAMS:
            continue
        for q in exam.get("questions", []):
            qt = q.get("questionText", "")
            norm = normalize_text(qt)
            if norm not in source_map:
                continue
            src_img, src_opt_imgs = source_map[norm]
            cur_img = q.get("imageUrl")
            changed = False
            # Ana görseli ekle/değiştir
            if not cur_img or cur_img == "null":
                q["imageUrl"] = src_img
                stats["main_images_added"] += 1
                changed = True
            elif cur_img != src_img:
                q["imageUrl"] = src_img
                stats["main_images_replaced"] += 1
                changed = True
            # Seçenek görsellerini uygula (varsa)
            if src_opt_imgs:
                opts = q.get("options", {}) or {}
                for k, rec in src_opt_imgs.items():
                    if k in opts:
                        ov = opts[k]
                        if isinstance(ov, dict):
                            if ov.get("imageUrl") != rec:
                                ov["imageUrl"] = rec
                                stats["option_images_added"] += 1
                                changed = True
                        else:
                            opts[k] = {"text": ov, "imageUrl": rec}
                            stats["option_images_added"] += 1
                            changed = True
                    else:
                        # seçenek anahtarları tutmuyorsa atla
                        pass
                q["options"] = opts
            if changed:
                stats["questions_canonicalized"] += 1
                stats["exams_updated"].add(exam_id)
    stats["exams_updated"] = sorted(list(stats["exams_updated"]))
    return stats


def main() -> int:
    if not Path(EXAMS_FILE).exists():
        print(f"❌ Bulunamadı: {EXAMS_FILE}")
        return 1
    data = load()
    source_map = build_source_map(data)
    print(f"🔍 Kaynak soru-görsel eşleşmeleri: {len(source_map)}")
    stats = canonicalize(data, source_map)
    if stats["questions_canonicalized"] > 0:
        save(data)
        print("✅ exams.json güncellendi")
    else:
        print("ℹ️ Güncelleme gerekmedi")
    print("\n📊 Özet:")
    print(f"  - Güncellenen denemeler: {', '.join(stats['exams_updated']) if stats['exams_updated'] else 'yok'}")
    print(f"  - Kanonikleştirilen soru sayısı: {stats['questions_canonicalized']}")
    print(f"  - Eklenen ana görsel: {stats['main_images_added']}")
    print(f"  - Değiştirilen ana görsel: {stats['main_images_replaced']}")
    print(f"  - Eklenen/uygulanan seçenek görselleri: {stats['option_images_added']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
