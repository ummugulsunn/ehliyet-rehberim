#!/usr/bin/env python3
import os

# Kalan 8 görsel için SVG'ler
svgs = {
    "traffic_scenario_16.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="120" viewBox="0 0 200 120" xmlns="http://www.w3.org/2000/svg">
  <rect x="0" y="50" width="200" height="20" fill="#333333"/>
  <rect x="30" y="45" width="20" height="15" fill="#ff0000"/>
  <path d="M 40 35 L 35 25 L 45 25 Z" fill="red"/>
  <text x="100" y="100" text-anchor="middle" fill="black" font-size="10">Yasak Hareket</text>
</svg>''',

    "accident_scenario_21.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="120" viewBox="0 0 200 120" xmlns="http://www.w3.org/2000/svg">
  <rect x="0" y="50" width="200" height="20" fill="#333333"/>
  <rect x="80" y="45" width="20" height="15" fill="#0000ff"/>
  <circle cx="90" cy="35" r="8" fill="#ffff00" stroke="#ff0000" stroke-width="2"/>
  <text x="100" y="100" text-anchor="middle" fill="red" font-size="10">Zorunlu Durum</text>
</svg>''',

    "accident_scenario_22.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="120" viewBox="0 0 200 120" xmlns="http://www.w3.org/2000/svg">
  <rect x="50" y="40" width="25" height="15" fill="#ff0000" transform="rotate(-10 62 47)"/>
  <rect x="120" y="50" width="25" height="15" fill="#0000ff" transform="rotate(10 132 57)"/>
  <polygon points="100,45 110,65 90,65" fill="#ffff00"/>
  <text x="100" y="100" text-anchor="middle" fill="red" font-size="10">Kaza Sonucu</text>
</svg>''',

    "accident_scenario_31.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="120" viewBox="0 0 200 120" xmlns="http://www.w3.org/2000/svg">
  <rect x="90" y="0" width="20" height="120" fill="#333333"/>
  <rect x="0" y="50" width="200" height="20" fill="#333333"/>
  <rect x="40" y="45" width="20" height="15" fill="#ff0000"/>
  <rect x="130" y="45" width="20" height="15" fill="#0000ff"/>
  <text x="50" y="30" text-anchor="middle" fill="red" font-size="12">1</text>
  <text x="100" y="100" text-anchor="middle" fill="black" font-size="10">Kusurlu Araç</text>
</svg>''',

    "brake_lights.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="100" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg">
  <rect x="50" y="30" width="100" height="40" fill="#0000ff" stroke="#333333" stroke-width="2"/>
  <circle cx="75" cy="75" r="8" fill="#333333"/>
  <circle cx="125" cy="75" r="8" fill="#333333"/>
  <rect x="140" y="35" width="8" height="8" fill="#ff0000"/>
  <rect x="140" y="47" width="8" height="8" fill="#ff0000"/>
  <text x="100" y="20" text-anchor="middle" fill="black" font-size="10">Fren Lambaları</text>
</svg>''',

    "dashboard_various.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="250" height="100" viewBox="0 0 250 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Glow Plug -->
  <circle cx="50" cy="40" r="15" fill="#ff6600"/>
  <path d="M 45 40 L 55 40" stroke="white" stroke-width="3"/>
  <text x="50" y="70" text-anchor="middle" fill="black" font-size="9">Glow Plug</text>
  
  <!-- Motor Uyarı -->
  <rect x="120" y="25" width="30" height="30" fill="#ff0000"/>
  <text x="135" y="45" text-anchor="middle" fill="white" font-size="10">ENG</text>
  <text x="135" y="70" text-anchor="middle" fill="black" font-size="9">Motor</text>
  
  <!-- Genel Uyarı -->
  <polygon points="200,25 225,55 175,55" fill="#ffff00" stroke="#ff0000" stroke-width="2"/>
  <text x="200" y="48" text-anchor="middle" fill="red" font-size="16">!</text>
  <text x="200" y="70" text-anchor="middle" fill="black" font-size="9">Uyarı</text>
</svg>'''
}

# Dosya eşlemeleri
file_mappings = {
    "traffic_scenario_16.svg": "deneme_sinavi_3_soru_16.png",
    "accident_scenario_21.svg": "deneme_sinavi_3_soru_21.png",
    "accident_scenario_22.svg": "deneme_sinavi_3_soru_22.png", 
    "accident_scenario_31.svg": "deneme_sinavi_3_soru_31.png",
    "brake_lights.svg": "deneme_sinavi_3_soru_37.png",
    "dashboard_various.svg": "deneme_sinavi_3_soru_39.png"
}

for filename, content in svgs.items():
    svg_path = f"assets/images/{filename}"
    with open(svg_path, 'w') as f:
        f.write(content)
    
    # PNG'ye çevir
    os.system(f"qlmanage -t -s 200 -o assets/images/ {svg_path}")
    
    # Yeniden adlandır
    new_name = file_mappings[filename]
    os.system(f"mv assets/images/{filename}.png assets/images/{new_name}")
    os.system(f"rm {svg_path}")

# Son 2 görsel için kopyalama (benzer simgeler)
os.system("cp assets/images/deneme_sinavi_3_soru_39.png assets/images/deneme_sinavi_3_soru_41.png")
os.system("cp assets/images/deneme_sinavi_3_soru_39.png assets/images/deneme_sinavi_3_soru_43.png")

print("Deneme 3 için kalan 8 görsel tamamlandı!")

