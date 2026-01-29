#!/usr/bin/env python3
"""
Görsel Yayma Scripti - İlk 8 Denemeden Diğerlerine
Bu script, ilk 8 denemede eklenen görselleri, diğer denemelerde tekrar eden aynı sorulara otomatik olarak yayar.
"""

import json
import re
from typing import Dict, List, Tuple, Optional
from pathlib import Path

# Dosya yolları
EXAMS_FILE = "assets/data/exams.json"
OUTPUT_REPORT = "analysis/propagation_report_first_8.json"

def normalize_text(text: str) -> str:
    """Metni normalize eder (büyük/küçük harf, noktalama, boşluk)"""
    # Küçük harfe çevir
    text = text.lower()
    # Noktalama işaretlerini kaldır
    text = re.sub(r'[^\w\s]', '', text)
    # Fazla boşlukları tek boşluğa çevir
    text = re.sub(r'\s+', ' ', text)
    # Başındaki ve sonundaki boşlukları kaldır
    text = text.strip()
    return text

def load_exams() -> List[dict]:
    """exams.json dosyasını yükler"""
    with open(EXAMS_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_exams(data: List[dict]) -> None:
    """exams.json dosyasını kaydeder"""
    with open(EXAMS_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def build_source_image_map(data: List[dict]) -> Dict[str, Tuple[str, Dict[str, str]]]:
    """
    İlk 8 denemede bulunan görselleri, soru metninden görsel yoluna eşleyen map oluşturur.
    """
    norm_to_images = {}
    source_exam_ids = ["deneme_sinavi_1", "deneme_sinavi_2", "deneme_sinavi_3",
                       "deneme_sinavi_4", "deneme_sinavi_5", "deneme_sinavi_6",
                       "deneme_sinavi_7", "deneme_sinavi_8"]
    
    print(f"🔍 İlk 8 denemede görsel aranıyor...")
    
    for exam in data:
        if exam.get("examId") not in source_exam_ids:
            continue
            
        for question in exam.get("questions", []):
            question_text = question.get("questionText", "")
            image_url = question.get("imageUrl")
            
            if not image_url or image_url == "null":
                continue
                
            # Soru metnini normalize et
            norm_text = normalize_text(question_text)
            
            if norm_text:
                # Ana görsel
                main_image = image_url
                
                # Seçenek görselleri
                option_images = {}
                options = question.get("options", {})
                for key, option in options.items():
                    if isinstance(option, dict) and option.get("imageUrl"):
                        option_images[key] = option["imageUrl"]
                
                norm_to_images[norm_text] = (main_image, option_images)
    
    print(f"✅ {len(norm_to_images)} soru metni-görsel eşleşmesi bulundu")
    return norm_to_images

def propagate_images(data: List[dict], source_map: Dict[str, Tuple[str, Dict[str, str]]]) -> Dict:
    """
    Görselleri tekrar eden sorulara yayar.
    """
    stats = {
        "total_questions_updated": 0,
        "main_images_added": 0,
        "option_images_added": 0,
        "exams_affected": set(),
        "questions_updated": []
    }
    
    target_exam_ids = ["deneme_sinavi_9", "deneme_sinavi_10", "deneme_sinavi_11", 
                       "deneme_sinavi_12", "deneme_sinavi_13", "deneme_sinavi_14", "deneme_sinavi_15"]
    
    print(f"🚀 Görsel yayma işlemi başlatılıyor...")
    print(f"🎯 Hedef denemeler: {', '.join(target_exam_ids)}")
    
    for exam in data:
        if exam.get("examId") not in target_exam_ids:
            continue
            
        exam_id = exam.get("examId")
        exam_updated = False
        
        for question in exam.get("questions", []):
            question_text = question.get("questionText", "")
            current_image_url = question.get("imageUrl")
            
            # Eğer zaten görsel varsa, atla
            if current_image_url and current_image_url != "null":
                continue
                
            # Soru metnini normalize et
            norm_text = normalize_text(question_text)
            
            if norm_text in source_map:
                main_image, option_images = source_map[norm_text]
                
                # Ana görseli ekle
                if main_image:
                    question["imageUrl"] = main_image
                    stats["main_images_added"] += 1
                    exam_updated = True
                
                # Seçenek görsellerini ekle
                if option_images:
                    options = question.get("options", {})
                    for key, option in options.items():
                        if key in option_images:
                            if isinstance(option, dict):
                                option["imageUrl"] = option_images[key]
                            else:
                                # Eğer option string ise, dict'e çevir
                                question["options"][key] = {
                                    "text": option,
                                    "imageUrl": option_images[key]
                                }
                            stats["option_images_added"] += 1
                
                stats["total_questions_updated"] += 1
                stats["exams_affected"].add(exam_id)
                stats["questions_updated"].append({
                    "examId": exam_id,
                    "questionId": question.get("id"),
                    "questionText": question_text[:100] + "...",
                    "mainImageAdded": main_image,
                    "optionImagesAdded": list(option_images.keys()) if option_images else []
                })
        
        if exam_updated:
            print(f"✅ {exam_id} güncellendi")
    
    stats["exams_affected"] = list(stats["exams_affected"])
    return stats

def main():
    print("🚀 İlk 8 Denemeden Görsel Yayma İşlemi Başlatılıyor...")
    
    # Dosyaların varlığını kontrol et
    if not Path(EXAMS_FILE).exists():
        print(f"❌ {EXAMS_FILE} bulunamadı!")
        return 1
    
    # exams.json'ı yükle
    data = load_exams()
    print(f"✅ {len(data)} deneme yüklendi")
    
    # İlk 8 denemede bulunan görselleri topla
    source_map = build_source_image_map(data)
    
    if not source_map:
        print("❌ İlk 8 denemede görsel bulunamadı!")
        return 1
    
    # Görselleri yay
    stats = propagate_images(data, source_map)
    
    if stats["total_questions_updated"] > 0:
        save_exams(data)
        print(f"✅ exams.json güncellendi!")
    else:
        print("ℹ️ Güncelleme gerekli değil")
    
    # Rapor oluştur
    report = {
        "propagation_stats": stats,
        "source_questions_count": len(source_map),
        "source_exams": ["deneme_sinavi_1", "deneme_sinavi_2", "deneme_sinavi_3",
                        "deneme_sinavi_4", "deneme_sinavi_5", "deneme_sinavi_6",
                        "deneme_sinavi_7", "deneme_sinavi_8"],
        "target_exams": ["deneme_sinavi_9", "deneme_sinavi_10", "deneme_sinavi_11", 
                        "deneme_sinavi_12", "deneme_sinavi_13", "deneme_sinavi_14", "deneme_sinavi_15"]
    }
    
    # Raporu kaydet
    Path(OUTPUT_REPORT).parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_REPORT, "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    
    print(f"📄 Rapor kaydedildi: {OUTPUT_REPORT}")
    
    # Özet
    print("\n📊 Özet:")
    print(f"  - Güncellenen sorular: {stats['total_questions_updated']}")
    print(f"  - Eklenen ana görseller: {stats['main_images_added']}")
    print(f"  - Eklenen seçenek görselleri: {stats['option_images_added']}")
    print(f"  - Etkilenen denemeler: {', '.join(stats['exams_affected']) if stats['exams_affected'] else 'yok'}")
    print(f"  - Kaynak soru sayısı: {len(source_map)}")
    
    return 0

if __name__ == "__main__":
    exit(main())
