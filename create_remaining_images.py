#!/usr/bin/env python3
import os

# Kalan görseller için basit SVG'ler oluştur
svgs = {
    "motorcycle_distance.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="300" height="100" viewBox="0 0 300 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Yol -->
  <rect x="0" y="40" width="300" height="20" fill="#333333"/>
  
  <!-- Motosiklet -->
  <rect x="50" y="45" width="15" height="10" fill="#ff0000"/>
  <text x="57" y="75" text-anchor="middle" fill="black" font-size="10">Motosiklet</text>
  
  <!-- Araç -->
  <rect x="150" y="45" width="20" height="10" fill="#0000ff"/>
  <text x="160" y="75" text-anchor="middle" fill="black" font-size="10">Araç</text>
  
  <!-- Mesafe çizgisi -->
  <line x1="65" y1="30" x2="150" y2="30" stroke="red" stroke-width="2"/>
  <text x="107" y="25" text-anchor="middle" fill="red" font-size="12">30m</text>
</svg>''',
    
    "traffic_accident.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="150" viewBox="0 0 200 150" xmlns="http://www.w3.org/2000/svg">
  <!-- Çarpışan araçlar -->
  <rect x="50" y="60" width="25" height="15" fill="#ff0000" transform="rotate(-20 62 67)"/>
  <rect x="120" y="70" width="25" height="15" fill="#0000ff" transform="rotate(15 132 77)"/>
  
  <!-- Patlama işareti -->
  <polygon points="100,50 110,70 90,70" fill="#ffff00" stroke="#ff0000" stroke-width="2"/>
  
  <!-- Uyarı işareti -->
  <text x="100" y="120" text-anchor="middle" fill="red" font-size="14" font-weight="bold">KAZA!</text>
</svg>''',

    "brake_system.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="150" viewBox="0 0 200 150" xmlns="http://www.w3.org/2000/svg">
  <!-- Fren balata -->
  <rect x="50" y="50" width="30" height="20" fill="#666666"/>
  <rect x="120" y="50" width="30" height="20" fill="#666666"/>
  
  <!-- Fren diski -->
  <circle cx="100" cy="75" r="35" fill="#444444" stroke="#333333" stroke-width="3"/>
  <circle cx="100" cy="75" r="15" fill="#222222"/>
  
  <!-- Fren çizgileri -->
  <line x1="80" y1="60" x2="65" y2="60" stroke="red" stroke-width="3"/>
  <line x1="120" y1="60" x2="135" y2="60" stroke="red" stroke-width="3"/>
  
  <text x="100" y="130" text-anchor="middle" fill="black" font-size="12">Fren Sistemi</text>
</svg>''',

    "traffic_courtesy.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="150" viewBox="0 0 200 150" xmlns="http://www.w3.org/2000/svg">
  <!-- Polis memuru -->
  <rect x="85" y="50" width="30" height="40" fill="#0000ff"/>
  <circle cx="100" cy="40" r="15" fill="#ffdbac"/>
  <rect x="95" y="35" width="10" height="8" fill="#333333"/>
  
  <!-- Sürücü -->
  <rect x="140" y="70" width="25" height="15" fill="#ff0000"/>
  <circle cx="150" cy="60" r="8" fill="#ffdbac"/>
  
  <!-- Saygı işareti -->
  <text x="100" y="110" text-anchor="middle" fill="green" font-size="12" font-weight="bold">Saygı</text>
  <path d="M 130 80 Q 135 75 140 80" stroke="green" stroke-width="2" fill="none"/>
</svg>'''
}

# SVG'leri oluştur ve PNG'ye çevir
for filename, content in svgs.items():
    svg_path = f"assets/images/{filename}"
    with open(svg_path, 'w') as f:
        f.write(content)
    
    # PNG'ye çevir
    os.system(f"qlmanage -t -s 200 -o assets/images/ {svg_path}")
    
    # Yeniden adlandır
    base_name = filename.replace('.svg', '')
    if base_name == "motorcycle_distance":
        new_name = "deneme_sinavi_2_soru_21.png"
    elif base_name == "traffic_accident":
        new_name = "deneme_sinavi_2_soru_35.png"
    elif base_name == "brake_system":
        new_name = "deneme_sinavi_2_soru_42.png"
    elif base_name == "traffic_courtesy":
        new_name = "deneme_sinavi_2_soru_48.png"
    
    os.system(f"mv assets/images/{filename}.png assets/images/{new_name}")
    os.system(f"rm {svg_path}")

print("Kalan 4 görsel oluşturuldu!")

