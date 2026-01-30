#!/usr/bin/env python3
"""
Script to categorize questions based on their content.
Categories:
- Trafik ve Çevre Bilgisi
- Trafik İşaretleri  
- İlk Yardım
- Motor ve Araç Tekniği
- Trafik Adabı
"""

import json
import os

def categorize_question(question_text, options_text=""):
    """Determine the category based on question content."""
    text = (question_text + " " + options_text).lower()
    
    # İlk Yardım keywords
    ilk_yardim_keywords = [
        "ilk yardım", "kazazede", "yaralı", "kanama", "kırık", "yanık",
        "şok", "bilinç", "solunum", "nabız", "kalp", "turnike", "sargı",
        "112", "ambulans", "hastane", "tedavi", "hayat kurtarma", "boğulma",
        "zehirlenme", "sara", "epilepsi", "bayılma", "suni solunum", "kalp masajı",
        "abc", "yaşam zinciri", "travma", "omurga", "boyun", "koma",
        "göğüs ağrısı", "nefes darlığı", "alerjik", "anafilaksi"
    ]
    
    # Motor ve Araç Tekniği keywords
    motor_keywords = [
        "motor", "fren", "lastik", "akü", "yağ", "yakıt", "benzin", "dizel",
        "debriyaj", "vites", "şanzıman", "süspansiyon", "amortisör", "direksiyon",
        "far", "lambası", "sinyal", "silecek", "ayna", "kaporta", "şasi",
        "egzoz", "katalitik", "turbo", "radyatör", "soğutma", "hararet",
        "marş", "şarj", "alternatör", "bujiler", "enjektör", "hidrolik",
        "abs", "esp", "airbag", "hava yastığı", "emniyet kemeri", "emniyet",
        "conta", "piston", "silindir", "subap", "krank", "kam mili",
        "diferansiyel", "şaft", "aks", "bijon", "jant", "teker",
        "cc", "beygir", "güç", "tork", "hız", "devir"
    ]
    
    # Trafik İşaretleri keywords
    isaret_keywords = [
        "işaret", "levha", "şekil", "tabela", "ışık", "sinyal",
        "kırmızı", "yeşil", "sarı", "yanıp", "dur", "dikkat", "uyarı",
        "yasak", "mecburi", "bilgi", "yön", "ok", "şerit", "geçiş",
        "yaya", "okul", "hastane", "kavşak", "dönüş", "viraj",
        "eğim", "tümsek", "çukur", "kaygan", "buzlanma", "taş düşebilir"
    ]
    
    # Trafik Adabı keywords
    adab_keywords = [
        "saygı", "hoşgörü", "sabır", "nezaket", "adab", "davranış",
        "stres", "öfke", "agresif", "sakin", "dikkatli", "dikkatsiz",
        "alkol", "uyuşturucu", "ilaç", "yorgunluk", "uyku", "uykusuzluk",
        "dikkat dağınıklığı", "telefon", "cep telefonu", "mesaj",
        "empati", "anlayış", "paylaşım", "yol verme", "geçiş hakkı",
        "öncelik", "makas", "korna", "kornaya", "selektör"
    ]
    
    # Check categories in order of specificity
    for keyword in ilk_yardim_keywords:
        if keyword in text:
            return "İlk Yardım"
    
    for keyword in motor_keywords:
        if keyword in text:
            return "Motor ve Araç Tekniği"
    
    for keyword in isaret_keywords:
        if keyword in text:
            return "Trafik İşaretleri"
    
    for keyword in adab_keywords:
        if keyword in text:
            return "Trafik Adabı"
    
    # Default category
    return "Trafik ve Çevre Bilgisi"


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    imported_path = os.path.join(project_root, "assets", "data", "imported_questions.json")
    
    with open(imported_path, "r", encoding="utf-8") as f:
        questions = json.load(f)
    
    categorized_count = {
        "Trafik ve Çevre Bilgisi": 0,
        "Trafik İşaretleri": 0,
        "İlk Yardım": 0,
        "Motor ve Araç Tekniği": 0,
        "Trafik Adabı": 0
    }
    
    for question in questions:
        # Combine question text and options for better categorization
        options_text = ""
        if "options" in question:
            for key, value in question["options"].items():
                if isinstance(value, str):
                    options_text += " " + value
                elif isinstance(value, dict) and "text" in value:
                    options_text += " " + value["text"]
        
        category = categorize_question(question.get("questionText", ""), options_text)
        question["category"] = category
        categorized_count[category] += 1
    
    # Save updated questions
    with open(imported_path, "w", encoding="utf-8") as f:
        json.dump(questions, f, ensure_ascii=False, indent=4)
    
    print("Kategorilendirme tamamlandı!")
    print("\nKategori dağılımı:")
    for cat, count in categorized_count.items():
        print(f"  - {cat}: {count} soru")
    
    print(f"\nToplam: {len(questions)} soru güncellendi.")


if __name__ == "__main__":
    main()
