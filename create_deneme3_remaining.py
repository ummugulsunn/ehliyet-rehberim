#!/usr/bin/env python3
import os

# Deneme 3 için kalan görseller
svgs = {
    "first_aid_pressure.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="150" viewBox="0 0 200 150" xmlns="http://www.w3.org/2000/svg">
  <!-- İnsan vücut şeması -->
  <ellipse cx="100" cy="30" rx="20" ry="15" fill="#ffdbac" stroke="#333333" stroke-width="2"/>
  <rect x="85" y="40" width="30" height="50" fill="#87ceeb" stroke="#333333" stroke-width="2"/>
  <rect x="70" y="50" width="15" height="30" fill="#ffdbac" stroke="#333333" stroke-width="2"/>
  <rect x="115" y="50" width="15" height="30" fill="#ffdbac" stroke="#333333" stroke-width="2"/>
  
  <!-- Kanama noktası -->
  <circle cx="125" cy="65" r="8" fill="#ff0000"/>
  
  <!-- Basınç uygulama noktası -->
  <circle cx="140" cy="60" r="6" fill="#00ff00" stroke="#333333" stroke-width="2"/>
  <text x="140" y="105" text-anchor="middle" fill="green" font-size="10">Basınç Noktası</text>
  
  <!-- Ok işareti -->
  <path d="M 135 65 L 130 60 L 130 70 Z" fill="green"/>
</svg>''',

    "emergency_vehicle.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="100" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Ambulans -->
  <rect x="50" y="40" width="60" height="30" fill="#ffffff" stroke="#ff0000" stroke-width="3"/>
  <rect x="110" y="45" width="20" height="20" fill="#ffffff" stroke="#ff0000" stroke-width="2"/>
  
  <!-- Kırmızı çarpı -->
  <rect x="70" y="50" width="20" height="4" fill="#ff0000"/>
  <rect x="78" y="42" width="4" height="20" fill="#ff0000"/>
  
  <!-- Tekerlekler -->
  <circle cx="65" cy="75" r="8" fill="#333333"/>
  <circle cx="95" cy="75" r="8" fill="#333333"/>
  
  <!-- Işık çubuğu -->
  <rect x="70" y="35" width="20" height="5" fill="#ff0000"/>
  <text x="100" y="25" text-anchor="middle" fill="red" font-size="12">ACİL DURUM</text>
</svg>''',

    "traffic_violation.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="150" viewBox="0 0 200 150" xmlns="http://www.w3.org/2000/svg">
  <!-- Kavşak -->
  <rect x="90" y="0" width="20" height="150" fill="#333333"/>
  <rect x="0" y="65" width="200" height="20" fill="#333333"/>
  
  <!-- Araç 1 (kusurlu) -->
  <rect x="40" y="50" width="25" height="15" fill="#ff0000" stroke="#333333" stroke-width="1"/>
  <text x="52" y="40" text-anchor="middle" fill="red" font-size="12" font-weight="bold">1</text>
  
  <!-- Diğer araç -->
  <rect x="110" y="30" width="25" height="15" fill="#0000ff" stroke="#333333" stroke-width="1"/>
  
  <!-- Çarpışma -->
  <polygon points="90,60 100,70 80,70" fill="#ffff00" stroke="#ff0000" stroke-width="2"/>
  
  <!-- Uyarı -->
  <text x="100" y="110" text-anchor="middle" fill="red" font-size="10">ASLİ KUSUR</text>
</svg>''',

    "right_turn_scheme.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="150" viewBox="0 0 200 150" xmlns="http://www.w3.org/2000/svg">
  <!-- Kavşak yolları -->
  <rect x="90" y="0" width="20" height="150" fill="#333333"/>
  <rect x="0" y="65" width="200" height="20" fill="#333333"/>
  
  <!-- Araç (sağa dönecek) -->
  <rect x="80" y="100" width="20" height="15" fill="#0000ff" stroke="#333333" stroke-width="1"/>
  
  <!-- Dönüş yolu -->
  <path d="M 100 110 Q 120 110 120 90" stroke="blue" stroke-width="3" fill="none"/>
  <path d="M 115 85 L 120 90 L 125 85" fill="blue"/>
  
  <!-- Yaya geçidi -->
  <rect x="95" y="55" width="10" height="3" fill="white"/>
  <rect x="95" y="50" width="10" height="3" fill="white"/>
  <text x="130" y="70" fill="black" font-size="10">Yaya Geçidi</text>
</svg>''',

    "dashboard_icons.svg": '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="300" height="100" viewBox="0 0 300 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Motor ikonu -->
  <rect x="20" y="30" width="40" height="25" fill="#333333" stroke="#ffffff" stroke-width="2"/>
  <text x="40" y="70" text-anchor="middle" fill="black" font-size="10">Motor</text>
  
  <!-- Yağ ikonu -->
  <ellipse cx="120" rx="20" ry="15" fill="#000000"/>
  <rect x="115" y="35" width="10" height="20" fill="#000000"/>
  <text x="120" y="70" text-anchor="middle" fill="black" font-size="10">Yağ</text>
  
  <!-- Glow plug ikonu -->
  <path d="M 200 30 Q 210 25 220 30 Q 210 35 200 30" fill="#ff6600"/>
  <rect x="205" y="30" width="10" height="15" fill="#ff6600"/>
  <text x="210" y="70" text-anchor="middle" fill="black" font-size="10">Glow Plug</text>
</svg>'''
}

# SVG'leri oluştur ve PNG'ye çevir
file_mappings = {
    "first_aid_pressure.svg": "deneme_sinavi_3_soru_12.png",
    "emergency_vehicle.svg": "deneme_sinavi_3_soru_15.png", 
    "traffic_violation.svg": "deneme_sinavi_3_soru_17.png",
    "right_turn_scheme.svg": "deneme_sinavi_3_soru_28.png",
    "dashboard_icons.svg": "deneme_sinavi_3_soru_38.png"
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

print("Deneme 3 için 5 ek görsel oluşturuldu!")

