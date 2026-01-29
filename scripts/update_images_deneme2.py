#!/usr/bin/env python3
import json
import sys

def update_deneme2_images():
    # JSON dosyasını yükle
    with open('assets/data/exams.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Deneme 2'yi bul
    deneme2_index = None
    for i, exam in enumerate(data):
        if exam.get('examId') == 'deneme_sinavi_2':
            deneme2_index = i
            break
    
    if deneme2_index is None:
        print("Deneme 2 bulunamadı!")
        return
    
    # Güncellenmesi gereken sorular ve görsel dosyaları
    updates = {
        13: "assets/images/deneme_sinavi_2_soru_13.png",  # Kontrolsüz kavşak işareti
        17: "assets/images/deneme_sinavi_2_soru_17.png",  # Işıklı trafik işaret cihazı
        19: "assets/images/deneme_sinavi_2_soru_19.png",  # Dönel kavşak şeması
        21: "assets/images/deneme_sinavi_2_soru_21.png",  # Motosiklet takip mesafesi
        22: "assets/images/deneme_sinavi_2_soru_22.png",  # Yol yüzeri işaretleme
        28: "assets/images/deneme_sinavi_2_soru_28.png",  # Kontrolsüz kavşağa yaklaşım
        30: "assets/images/deneme_sinavi_2_soru_30.png",  # Motosiklet girebilir işareti
        32: "assets/images/deneme_sinavi_2_soru_32.png",  # Uzunluk gabari sınırı
        33: "assets/images/deneme_sinavi_2_soru_33.png",  # Yasak işareti
        34: "assets/images/deneme_sinavi_2_soru_34.png",  # Trafik görevlisi işareti
        35: "assets/images/deneme_sinavi_2_soru_35.png",  # Trafik kazası sebepleri
        39: "assets/images/deneme_sinavi_2_soru_39.png",  # Şarj sistemi ikaz ışığı
        42: "assets/images/deneme_sinavi_2_soru_42.png",  # Fren sistemi şematik
        43: "assets/images/deneme_sinavi_2_soru_43.png",  # Gösterge paneli simgesi
        48: "assets/images/deneme_sinavi_2_soru_48.png"   # Trafik adabı görseli
    }
    
    # Soruları güncelle
    questions = data[deneme2_index]['questions']
    updated_count = 0
    
    for question in questions:
        question_id = question.get('id')
        if question_id in updates:
            question['imageUrl'] = updates[question_id]
            updated_count += 1
            print(f"Soru {question_id} güncellendi: {updates[question_id]}")
    
    # JSON dosyasını kaydet
    with open('assets/data/exams.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"\nToplam {updated_count} soru güncellendi.")
    return updated_count

if __name__ == "__main__":
    update_deneme2_images()
