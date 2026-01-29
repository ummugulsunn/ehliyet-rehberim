#!/usr/bin/env python3
import json

# JSON dosyasını yükle
with open('assets/data/exams.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Deneme 2'yi bul
deneme2 = None
for exam in data:
    if exam.get('examId') == 'deneme_sinavi_2':
        deneme2 = exam
        break

if deneme2:
    print("🎯 Deneme 2 Güncellemeleri:")
    print("=" * 40)
    
    for question in deneme2['questions']:
        if question['id'] == 13:
            print(f"✅ Soru 13: {question['questionText'][:50]}...")
            print(f"   Ana Görsel: {question['imageUrl']}")
            if isinstance(question['options']['A'], dict):
                print("   📸 Şık Görselleri:")
                for key in ['A', 'B', 'C', 'D']:
                    print(f"     {key}: {question['options'][key]['imageUrl']}")
            else:
                print("   ❌ Şık görselleri henüz eklenmedi")
        
        elif question['id'] == 17:
            print(f"✅ Soru 17: {question['questionText'][:50]}...")
            print(f"   Görsel: {question['imageUrl']}")
    
else:
    print("❌ Deneme 2 bulunamadı!")

