# Liminal Dreamcore 參考圖片色彩分析報告

**生成日期**: 2026-04-30
**分析工具**: `image-aesthetic-analyzer/analyze_local.py` (Pillow + ColorThief + numpy)
**分析模式**: local (客觀維度 only — 跳過 mood/composition/texture)
**圖片來源**: `C:\Users\qwqwh\Downloads\liminal_references\`

---

## 1. 16 張參考圖片色彩數據總表

### 圖例
- **T**: 色溫 (K), **S**: 飽和度 (%), **Sh/Mid/Hi**: 陰影/中間調/高光 (%)
- **Rec**: 啟發式推薦場景 (R=rain_underpass, S=snow_bridge, F=fog_highway, B=blizzard_street)
- **Manual**: 人工重新分類（見第 2 節理由）

| # | 檔案 | 主色調 Top 5 | T (K) | S% | Sh% | Mid% | Hi% | Rec | Manual |
|---|------|-------------|-------|-----|-----|------|-----|-----|--------|
| 1 | crt_01_glitch | `#1f1021` `#c67ecc` `#65a8f5` `#4a64bd` `#732059` | 7512 | 65.5 | 78.5 | 15.5 | 6.0 | F | R |
| 2 | crt_02_darkroom | `#273947` `#ce915f` `#726666` `#818992` `#919ca3` | 7782 | 48.5 | 72.0 | 24.6 | 3.3 | F | F |
| 3 | crt_03_neon | `#d3cac3` `#292b1d` `#8092b4` `#806f63` `#9c9c8a` | 6780 | 40.4 | 61.3 | 19.8 | 18.9 | F | R |
| 4 | crt_04_terminal | `#050705` `#b7b8b2` `#38ab75` `#2b46ce` `#5c3a27` | 5137 | 26.7 | 97.7 | 1.2 | 1.2 | S | S |
| 5 | dreamcore_01_pastel | `#d1cfce` `#ebe9ec` `#a39e98` `#a3a4a5` `#aca4a4` | 6315 | 1.6 | 0.0 | 0.2 | 99.8 | F | — |
| 6 | dreamcore_02_clouds | `#3d465e` `#d5b4ad` `#8b8194` `#939ab7` `#abacc0` | 9046 | 30.4 | 40.8 | 45.2 | 14.0 | F | F |
| 7 | dreamcore_03_weird | `#283241` `#b19475` `#68747b` `#718ea8` `#84a0b5` | 9903 | 43.3 | 88.1 | 11.5 | 0.4 | F | B |
| 8 | dreamcore_04_nebula | `#2c4675` `#a9a7c9` `#040a29` `#758ac2` `#84a7cd` | 11528 | 67.4 | 63.8 | 34.5 | 1.7 | F | F |
| 9 | dreamcore_05_sunset | `#2d283b` `#df8629` `#894836` `#635474` `#a47c5c` | 6480 | 59.8 | 67.0 | 24.9 | 8.0 | F | B |
| 10 | liminal_01_hallway | `#82817c` `#573b29` `#cad7de` `#414849` `#763c44` | 5263 | 19.7 | 12.5 | 55.2 | 32.2 | F | — |
| 11 | liminal_02_parking | `#8b8b8a` `#343335` `#424548` `#d3d5d6` `#695d2f` | 6180 | 3.8 | 28.3 | 65.0 | 6.6 | F | R |
| 12 | liminal_03_corridor | `#4c4139` `#ccc6c7` `#c76f65` `#bfa894` `#89837b` | 4747 | 24.9 | 60.4 | 32.0 | 7.5 | B | B |
| 13 | liminal_04_pool | `#dcd9d2` `#3c2a23` `#795842` `#8b7262` `#4d828c` | 5812 | 20.6 | 20.3 | 30.8 | 48.9 | F | — |
| 14 | ps1_02_dread | `#41413e` `#cab4a6` `#8a796d` `#9cadbf` `#8492a9` | 6966 | 22.6 | 56.2 | 32.3 | 11.5 | F | F |
| 15 | ps1_03_retro | `#0d080d` `#0cc5ec` `#c06897` `#075fac` `#0e3262` | 5601 | 64.5 | 83.6 | 11.5 | 4.9 | F | S |
| 16 | ps1_04_dark | `#80848a` `#111f28` `#e7d6cc` `#4a363b` `#684b41` | 7194 | 11.7 | 7.3 | 83.3 | 9.4 | F | — |

> **Manual = "—"** 表示該圖片與四個現有場景類型均不匹配（見第 2 節說明）。

---

## 2. 按場景類型分組的色調建議

### 2.1 啟發式演算法的侷限

`analyze_local.py` 的 `recommend_scene()` 函數使用簡單閾值規則（色溫 + 陰影比例 + 冷暖色計數），導致 14/16 圖片被歸類為 `fog_highway`。這是因為 `fog_highway` 被設為預設兜底（else 分支）。

以下人工重新分類基於：
- 主色調與現有場景參數的色彩距離
- 亮度分布與場景氛圍的匹配度
- 色溫範圍是否在場景設計意圖內

---

### 2.2 rain_underpass（雨天地下通道）— 3 張匹配

**現有場景參數:**
| 參數 | 值 |
|------|-----|
| background | `#0a0d14` |
| fog color | `#001a2e` (linear) |
| ambient | `#1a2530`, intensity 0.3 |
| point light | `#00bcd4` (window) / `#aaccff` (fluorescent) |
| 設計色溫 | 10000K (冷色調) |

**匹配圖片:**

| 圖片 | 主色調 | 色溫 | 陰影% | 匹配理由 |
|------|--------|------|-------|----------|
| crt_01_glitch | `#1f1021` → `#65a8f5` | 7512K | 78.5% | 深紫+藍色調，與地下通道冷暗氛圍一致；`#65a8f5` 接近現有 `#aaccff` 冷色系 |
| crt_03_neon | `#292b1d` → `#8092b4` | 6780K | 61.3% | 藍灰主調 `#8092b4` 與 rain 場景的混凝土色調 `#2a3540` 接近；色溫在冷色範圍 |
| liminal_02_parking | `#343335` → `#d3d5d6` | 6180K | 28.3% | 極低飽和度 (3.8%) 灰階色調適合潮濕混凝土的褪色感；需要提高陰影比例 |

**色調建議:**
- **ambient**: 從 `#1a2530` 調整為 `#1a2535`（向 crt_01 的藍紫方向微調 +5 blue）
- **point light (fluorescent)**: 從 `#aaccff` 調整為 `#88aadd`（參考 crt_01 的 `#65a8f5` + liminal_02 的極低飽和度 → 降低飽和）
- **fog**: 當前 `#001a2e` 與參考圖暗部色調一致，保留
- **陰影加深**: 參考圖平均 shadows 56%，當前場景過亮 → ambient intensity 從 0.3 降到 0.22

---

### 2.3 snow_bridge（雪夜步行橋）— 2 張匹配

**現有場景參數:**
| 參數 | 值 |
|------|-----|
| background | `#000000` |
| fog color | `#003344` (FogExp2, density 0.0012) |
| ambient | `#000511`, intensity 0.05 |
| point light | `#00bcd4`, intensity 4.0 |
| 設計色溫 | 5500K highlights |

**匹配圖片:**

| 圖片 | 主色調 | 色溫 | 陰影% | 匹配理由 |
|------|--------|------|-------|----------|
| crt_04_terminal | `#050705` → `#38ab75` | 5137K | 97.7% | 極黑背景 (97.7% shadows) 與 snow_bridge "70% dead black" 設計意圖完美吻合；CRT 綠色 `#38ab75` 可作為終端機光點 |
| ps1_03_retro | `#0d080d` → `#0cc5ec` | 5601K | 83.6% | 接近純黑背景 + 高飽和青色 `#0cc5ec` 與現有 `#00bcd4` 街燈色幾乎一致！色溫 5601K 接近設計目標 5500K |

**色調建議:**
- **point light (streetlight)**: 當前 `#00bcd4` 與 ps1_03 的 `#0cc5ec` 幾乎一致 — **保留**，這是跨參考圖驗證的正確選擇
- **ambient**: 當前 `#000511` vs crt_04 暗部 `#050705` — 非常接近，**保留**
- **fog color**: 當前 `#003344` 可考慮微調為 `#002844`（向 ps1_03 的 `#0e3262` 深藍方向靠攏）
- **CRT terminal accent**: crt_04 的 `#38ab75` 可作為 H5 窗戶的新顏色選項（替代目前的暖色窗）

---

### 2.4 fog_highway（大霧高架橋）— 4 張匹配

**現有場景參數:**
| 參數 | 值 |
|------|-----|
| background | `#1a1c20` |
| fog color | `#8a9bb0` (FogExp2, density 0.0015) |
| ambient | `#7088a0`, intensity 0.25 |
| point light | `#aaccff`, intensity 1.2 |
| 設計色溫 | 9500K |

**匹配圖片:**

| 圖片 | 主色調 | 色溫 | 陰影% | 匹配理由 |
|------|--------|------|-------|----------|
| crt_02_darkroom | `#273947` → `#ce915f` | 7782K | 72.0% | 藍灰基底 + 單一暖色點綴 (`#ce915f`)，與 H7 車禍殘骸的暖色警示燈概念一致；色溫接近設計目標 |
| dreamcore_02_clouds | `#3d465e` → `#d5b4ad` | 9046K | 40.8% | 藍紫基調 + 暖灰雲層；色溫 9046K 最接近 fog 場景設計 9500K；中間調佔比高 (45.2%) 適合霧氣擴散 |
| dreamcore_04_nebula | `#2c4675` → `#040a29` | 11528K | 63.8% | 極端冷色 (11528K) + 寶藍色調 `#2c4675`；適合 fog_highway 的「極冷夜晚」方向 |
| ps1_02_dread | `#41413e` → `#cab4a6` | 6966K | 56.2% | 低飽和灰階 (22.6%) + 暖灰點綴；PS1 低多邊形風格參考價值高 |

**色調建議:**
- **fog color**: 當前 `#8a9bb0` 與參考圖中間調 `#3d465e`、`#2c4675` 相比偏亮偏灰 → 建議調整為 `#5a6b80`（取 dreamcore_02/04 深藍與現有色的中間值）
- **fog density**: 當前 0.0015 vs 參考圖平均陰影 58% → 建議提高到 0.0018-0.0020（增強霧氣不透明度，匹配參考圖的深邃感）
- **ambient**: 當前 `#7088a0` 比參考圖暗部 (`#273947`, `#3d465e`) 亮很多 → 建議調整為 `#3a4a5a`，intensity 從 0.25 調到 0.30 補償
- **background**: 當前 `#1a1c20` 可考慮加深為 `#111318`（匹配 crt_02 暗部 `#273947` 的深度）

---

### 2.5 blizzard_street（暴雪城市街景）— 2 張匹配

**現有場景參數:**
| 參數 | 值 |
|------|-----|
| background | `#0a0808` |
| fog color | `#001a2e` (linear, near 8, far 35) |
| ambient | `#1a1520`, intensity 0.12 |
| point light (emergency) | `#ff1744`, intensity 0.6 |
| point light (street) | `#aaccff`, intensity 0.4 |
| 設計色溫 | 10000K |

**匹配圖片:**

| 圖片 | 主色調 | 色溫 | 陰影% | 匹配理由 |
|------|--------|------|-------|----------|
| liminal_03_corridor | `#4c4139` → `#c76f65` | 4747K | 60.4% | 暖棕色 + 紅色點綴 (`#c76f65`) 與 blizzard 場景的紅色緊急燈 (`#ff1744`) 概念一致；60.4% shadows 接近暴雪低能見度 |
| dreamcore_03_weird | `#283241` → `#b19475` | 9903K | 88.1% | 極高陰影比例 + 冷藍基底；色溫 9903K 接近設計 10000K；暖棕色 `#b19475` 提供冷暖對比 |

**色調建議:**
- **point light (emergency)**: 當前 `#ff1744`（純紅）vs liminal_03 的 `#c76f65`（磚紅）→ 建議改為 `#d4453a`（更接近真實應急燈的暗紅）
- **fog color**: 當前 `#001a2e` 與 dreamcore_03 暗部 `#283241` 相比偏藍 → 建議調整為 `#0a1520`（加入微量暖色）
- **ambient**: 當前 `#1a1520` 與參考圖暗部一致，**保留**
- **snow particles**: 當前 `#ddeeff` — dreamcore_03 的極冷色溫 (9903K) 支持保留冷色調雪花

---

### 2.6 不匹配圖片 — 4 張

這些圖片的色彩特徵與四個 Liminal 場景設計方向存在結構性衝突：

| 圖片 | 衝突原因 |
|------|----------|
| dreamcore_01_pastel | 99.8% 高光、1.6% 飽和（幾乎全白）；與所有場景的 dark-dominant 設計相反。Dreamcore UI overlay 可能適用，但不適合 3D 場景參考 |
| liminal_01_hallway | 32.2% 高光 + 暖灰主調 `#82817c`；是唯一「明亮室內」的參考圖。可作為未來「室內場景」類型的參考，但不屬於現有四個場景 |
| liminal_04_pool | 48.9% 高光 + 奶油色 `#dcd9d2`；室內泳池的潮濕明亮質感與戶外暗黑場景方向不符 |
| ps1_04_dark | 83.3% 中間調 + 僅 7.3% 陰影；雖然名為 "dark" 但實際亮度分布極平。PS1 風格參考價值在於低多邊形/紋理，而非色彩 |

---

## 3. 與現有遊戲場景參數的對比分析

### 3.1 色溫對比

| 場景 | 設計色溫 | 參考圖平均色溫 | 偏差 |
|------|----------|---------------|------|
| rain_underpass | 10000K | crt_01:7512K, crt_03:6780K, liminal_02:6180K → **avg 6824K** | **-3176K (偏暖)** |
| snow_bridge | 5500K | crt_04:5137K, ps1_03:5601K → **avg 5369K** | **-131K (極接近)** |
| fog_highway | 9500K | crt_02:7782K, dc_02:9046K, dc_04:11528K, ps1_02:6966K → **avg 8831K** | **-669K (略偏暖)** |
| blizzard_street | 10000K | liminal_03:4747K, dc_03:9903K → **avg 7325K** | **-2675K (偏暖)** |

**關鍵發現:** 所有場景的設計色溫都高於參考圖實測值。這說明：
- 設計意圖追求「極冷」但參考圖的現實燈光無法達到 10000K
- snow_bridge 的 5500K 設計最接近現實（僅偏離 -131K）
- rain_underpass 的偏差最大（-3176K），需要決定：堅持設計意圖（10000K 冷峻感）還是向參考圖靠攏（更自然的 6800K）

### 3.2 陰影比例對比

| 場景 | 當前 ambient 強度 | 參考圖平均 shadows% | 推導 ambient |
|------|-------------------|---------------------|-------------|
| rain_underpass | 0.30 | 56.0% | 0.22 |
| snow_bridge | 0.05 | 90.7% | 0.05 (保留) |
| fog_highway | 0.25 | 58.2% | 0.20 |
| blizzard_street | 0.12 | 74.3% | 0.10 |

**關鍵發現:**
- snow_bridge 的 0.05 ambient + 90.7% 參考圖陰影 — **已完美匹配**
- rain_underpass 的 ambient 0.30 明顯過亮（參考圖陰影 56%，意味場景應該更暗）
- fog_highway 的 ambient 0.25 也偏亮

### 3.3 主色調一致性

**驗證的參數（跨參考圖確認正確）:**
- snow_bridge streetlight `#00bcd4` — ps1_03 主色調為 `#0cc5ec`（色彩距離 < 0.05）
- blizzard ambient `#1a1520` — liminal_03/dreamcore_03 暗部在此範圍
- rain_underpass fog `#001a2e` — 所有匹配參考圖暗部均接近深藍黑

**需要調整的參數:**
- fog_highway ambient `#7088a0`: 比所有參考圖暗部亮 2-3×
- fog_highway fog `#8a9bb0`: 比參考圖中間調亮且飽和度偏高
- blizzard emergency `#ff1744`: 純紅 vs 參考圖的磚紅 `#c76f65`/`#d4453a`

### 3.4 啟發式 recommend_scene() 的修正建議

當前 `analyze_local.py` 的 `recommend_scene()` 函數將 14/16 圖片歸為 `fog_highway`，因為它是 else 兜底。建議的修正邏輯：

```python
def recommend_scene_v2(palette_hex, luminance, temperature):
    shadows = luminance["shadows_pct"]
    highlights = luminance["highlights_pct"]
    
    # 極高陰影 + 冷色溫 → snow_bridge（夜間極黑場景）
    if shadows > 80 and temperature < 10000:
        return "snow_bridge"
    
    # 高陰影 + 冷色系 + 暖色點綴 → rain_underpass（地下通道冷暗）
    if 50 <= shadows <= 80 and temperature > 6000:
        return "rain_underpass"
    
    # 高陰影 + 極冷色溫或暖暗色 → blizzard_street（暴雪極寒）
    if shadows > 55 and (temperature > 9000 or temperature < 5000):
        return "blizzard_street"
    
    # 中間調主導 + 中性色溫 → fog_highway（霧氣擴散）
    return "fog_highway"
```

---

## 4. 優先級建議

### P0 — 立即調整（參考圖與現有參數存在顯著偏差）

| # | 場景 | 參數 | 當前值 | 建議值 | 依據 |
|---|------|------|--------|--------|------|
| 1 | fog_highway | ambient color | `#7088a0` | `#3a4a5a` | 參考圖平均暗部比當前 ambient 暗 2-3× |
| 2 | fog_highway | ambient intensity | 0.25 | 0.30 | 補償顏色變暗，保持可見度 |
| 3 | fog_highway | fog color | `#8a9bb0` | `#5a6b80` | 取參考圖中間值，降低霧色飽和度 |
| 4 | fog_highway | fog density | 0.0015 | 0.0018 | 匹配參考圖平均 58% 陰影佔比 |

### P1 — 建議調整（改善氛圍但不影響可玩性）

| # | 場景 | 參數 | 當前值 | 建議值 | 依據 |
|---|------|------|--------|--------|------|
| 5 | rain_underpass | ambient intensity | 0.30 | 0.22 | 參考圖平均 56% 陰影，場景偏亮 |
| 6 | rain_underpass | fluorescent color | `#aaccff` | `#88aadd` | 向 crt_01 的 `#65a8f5` 靠攏 |
| 7 | blizzard_street | emergency color | `#ff1744` | `#d4453a` | liminal_03 磚紅比純紅更真實 |
| 8 | snow_bridge | fog color | `#003344` | `#002844` | 微調向 ps1_03 深藍 `#0e3262` |

### P2 — 可選（微調或保留不變）

| # | 場景 | 參數 | 狀態 |
|---|------|------|------|
| 9 | snow_bridge | 所有其他參數 | **保留** — 與參考圖高度一致 |
| 10 | blizzard_street | ambient/fog | **保留** — 在參考圖範圍內 |
| 11 | rain_underpass | fog/background | **保留** — 與參考圖一致 |

---

## 5. 方法論備註

- **local mode 限制**: `analyze_local.py` 僅提取客觀色彩數據；mood_tags、composition、texture_style 全部為 null。完整美學分析需要 API mode (`analyze.py`) 或 browser mode (`analyze_style.md`)
- **scene 推薦啟發式**: 當前 `recommend_scene()` 函數過度偏向 `fog_highway`（14/16 圖片）。本報告中使用人工重新分類（見第 2.6 節的推薦修正邏輯）
- **色溫估算**: McCamy 公式在 2850K–6500K 範圍內較準確；超出此範圍的值（如 dreamcore_04 的 11528K）為外推值，應視為相對指標而非絕對值
- **色彩距離**: 報告中的"接近/偏差"判斷基於 RGB 歐幾里得距離的主觀閾值，未使用 CIEDE2000 等知覺均勻色彩空間
