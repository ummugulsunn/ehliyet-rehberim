#!/usr/bin/env python3
import json
import sys

def update_deneme3_images():
    # JSON dosyasını yükle
    with open('assets/data/exams.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Deneme 3'ü bul
    deneme3_index = None
    for i, exam in enumerate(data):
        if exam.get('examId') == 'deneme_sinavi_3':
            deneme3_index = i
            break
    
    if deneme3_index is None:
        print("Deneme 3 bulunamadı!")
        return
    
    # Güncellenmesi gereken sorular ve görsel dosyaları
    # Deneme 3'teki 18 eksik görselin TAMAMI
    updates = {
        12: "assets/images/deneme_sinavi_3_soru_12.png",  # İlk yardım basınç noktası
        13: "assets/images/deneme_sinavi_3_soru_13.png",  # Yatay işaretleme
        15: "assets/images/deneme_sinavi_3_soru_15.png",  # Acil durum aracı
        16: "assets/images/deneme_sinavi_3_soru_16.png",  # Trafik senaryosu
        17: "assets/images/deneme_sinavi_3_soru_17.png",  # Trafik ihlali şeması
        21: "assets/images/deneme_sinavi_3_soru_21.png",  # Kaza senaryosu
        22: "assets/images/deneme_sinavi_3_soru_22.png",  # Kaza senaryosu
        25: "assets/images/deneme_sinavi_3_soru_25.png",  # İşaret levhasına yaklaşım
        26: "assets/images/deneme_sinavi_3_soru_26.png",  # Trafik işareti  
        28: "assets/images/deneme_sinavi_3_soru_28.png",  # Sağa dönüş şeması
        30: "assets/images/deneme_sinavi_3_soru_30.png",  # Kasisli yol işareti
        31: "assets/images/deneme_sinavi_3_soru_31.png",  # Kaza senaryosu
        33: "assets/images/deneme_sinavi_3_soru_33.png",  # Trafik işareti
        37: "assets/images/deneme_sinavi_3_soru_37.png",  # Fren lambaları
        38: "assets/images/deneme_sinavi_3_soru_38.png",  # Gösterge paneli simgesi
        39: "assets/images/deneme_sinavi_3_soru_39.png",  # Gösterge paneli ikaz ışığı
        41: "assets/images/deneme_sinavi_3_soru_41.png",  # Gösterge paneli simgesi
        43: "assets/images/deneme_sinavi_3_soru_43.png",  # Gösterge paneli ikaz ışığı
    }
    
    # Soruları güncelle
    questions = data[deneme3_index]['questions']
    updated_count = 0
    
    for question in questions:
        question_id = question.get('id')
        if question_id in updates:
            question['imageUrl'] = updates[question_id]
            updated_count += 1
            print(f"Deneme 3 - Soru {question_id} güncellendi: {updates[question_id]}")
    
    # JSON dosyasını kaydet
    with open('assets/data/exams.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"\nDeneme 3'te toplam {updated_count} soru güncellendi.")
    print(f"Kalan {18-updated_count} görsel için devam edilecek...")
    return updated_count

if __name__ == "__main__":
    update_deneme3_images()
