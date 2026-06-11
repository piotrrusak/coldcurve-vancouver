# Coldcurve Vancouver — Dokumentacja gry

## 1. Opis gry

**Coldcurve Vancouver** to top-down 2D gra akcji z elementami skradanki, w której gracz przemierza kolejne plansze i eliminuje wszystkich wrogów, zanim sam zostanie trafiony. Rozgrywka opiera się na klasycznym zestawieniu: zwrotny gracz z bronią białą kontra uzbrojeni wrogowie ze sztuczną inteligencją opartą na polu widzenia.

Koncepcja nawiązuje do arcade'owych twin-stick shooterów (Robotron, Smash TV) i gier skradankowych z widokiem z góry (seria Hotline Miami pod kątem bezpośredniości walki, seria Metal Gear w kwestii mechaniki zasięgu wzroku u wrogów). Charakterystycznym elementem odróżniającym grę od prostych shoot'em-upów jest **stożek widzenia** każdego wroga: patrole zachowują się jak realistyczni strażnicy — aktywnie przeszukują teren, reagują na utratę kontaktu wzrokowego i komunikują stan percepcji kolorem stożka.

Wersja prezentowana obejmuje 8 poziomów o rosnącej liczbie wrogów i złożoności mapy, a także system progresji z ekranami przejść między poziomami.

---

## 2. Użyte narzędzia

| | |
|---|---|
| **Silnik** | Godot 4.6 (tryb Forward Plus) |
| **Język skryptowy** | GDScript |
| **Platforma** | PC (Windows / macOS / Linux) |
| **Rozdzielczość** | Okno 480 × 720 px, canvas wewnętrzny 1280 × 720 px (portrait, skalowanie canvas_items) |
| **Fizyka 2D** | Wbudowana w Godot (CharacterBody2D, RigidBody2D) |
| **Nawigacja** | NavigationAgent2D + NavigationServer2D (Godot NavMesh) |

---

## 3. Mechaniki gry

### 3.1 Świat i kamera

Gra rozgrywa się w środowiskach 2D z widokiem z góry (top-down). Mapy są ograniczone — każdy z 8 poziomów to zamknięta plansza zbudowana z kafelków (TileMap), z wyraźnie zaznaczonymi ścianami i korytarzami. Kamera podąża za graczem. Przy dużych planszach (poziomy 5–8, rozmiar dochodzi do ~7500 × 9500 jednostek) widoczna jest tylko część mapy jednocześnie.

### 3.2 Gracz

Postać gracza to `CharacterBody2D`. Sterowanie:

- **WASD / strzałki / HJKL** — ruch w 8 kierunkach (ukośny możliwy)
- **Mysz** — kierunek ostrza broni

Prędkość bazowa: 400 j/s (modyfikowalna w opcjach). Broń (Weapon) to ostrze obracające się wokół postaci w kierunku kursora myszy. Kolizja ostrza z wrogiem natychmiast go eliminuje i daje punkt. Gracz **nie ma punktów życia** — jedno trafienie (kontakt z wrogiem lub pocisk) oznacza game over i reset poziomu.

### 3.3 Wrogowie i system AI

Każdy wróg to `CharacterBody2D` z modułową maszyną stanów złożoną z pięciu serwisów. Kolor stożka wizualizuje aktualny stan:

| Stan | Kolor stożka | Zachowanie |
|---|---|---|
| **SEARCH** | Żółty | Patrolujesz teren algorytmem ping-pong między waypoints; co kilka sekund zatrzymuje się i skanuje otoczenie, obracając się w miejscu |
| **INVESTIGATE** | Pomarańczowy | Po utracie LOS biegnie z 2× prędkością do ostatniej znane pozycji gracza; skanuje po dotarciu, następnie wraca do SEARCH |
| **ENGAGE** | Czerwony | Widzi gracza — strafuje prostopadle, utrzymując zasięg strzału; co 0,5 s oddaje strzał |

Parametry bazowe wroga:

| Parametr | Wartość |
|---|---|
| Prędkość ruchu | 180 j/s (strafe: 270 j/s) |
| Kąt pola widzenia | 60° |
| Zasięg wzroku | 500 j |
| Czas łaski po utracie LOS | 5 s |
| Prędkość obrotu | 240°/s |
| Interwał strzału | 0,5 s |

### 3.4 Pociski

Pociski to `RigidBody2D` (trójkąty) lecące w linii prostej z lekką losową wariancją prędkości (100–125% prędkości bazowej ~500 j/s). Usuwają się po wyjściu poza ekran lub trafieniu w gracza/ścianę.

### 3.5 Progresja poziomów

Wyeliminowanie wszystkich wrogów kończy poziom. Przy stracie życia gracz restartuje bieżący poziom (wynik cofa się do stanu z początku poziomu). Po ukończeniu poziomu 8 wyświetla się ekran końcowy.

| Poziom | Liczba wrogów |
|---|---|
| 1 | 7 |
| 2 | 12 |
| 3 | 34 |
| 4 | 39 |
| 5 | 79 |
| 6 | 100 |
| 7 | ~155 |
| 8 | ~200 |

### 3.6 Interfejs użytkownika

- **Licznik punktów** — góra ekranu; każdy zabity wróg = 1 pkt.
- **Strzałki kierunkowe** — pojawiają się gdy zostało mniej niż 10% wrogów poza ekranem; wskazują ich kierunek.
- **Menu główne** — Start, Wybór poziomu, Opcje, Wyjście.
- **Pauza** — Escape w trakcie gry; po wznowieniu odliczanie 3…2…1.
- **Opcje** — mnożniki prędkości (kula / gracz / wróg), tryb nieśmiertelności.

### 3.7 Taktyka

- Podchodź do wrogów od tyłu lub z boku stożka widzenia.
- Czerwony stożek = wróg cię widzi i zaraz strzeli — atakuj lub uciekaj natychmiast.
- Przy małej liczbie pozostałych wrogów strzałki UI pomagają ich namierzyć.
- W opcjach można dostosować prędkości, jeśli poziom trudności jest zbyt wysoki.

---

## 4. Użyte assety

| Asset | Źródło | Sposób użycia |
|---|---|---|
| Sprite sheet postaci / wrogów | „Neo Zero" — darmowy sci-fi pixel-art tileset (itch.io) | Zaimportowany bez modyfikacji; animacje walk_side / walk_down / walk_up / idle |
| Kafelki mapy | floor.png, wall.png | Własnoręcznie przygotowane proste tekstury kafelkowe |
| Ikony broni | „32 Free Weapon Icons" — darmowy pack graficzny | Zaimportowane, dołączone jako zasób do dalszego rozwoju |
| Ostrze gracza | — | Rysowane proceduralnie (GDScript `draw_circle`, wektory) |
| Pocisk wroga | — | Rysowany proceduralnie (`draw_colored_polygon`, czerwony trójkąt) |
| Stożek widzenia (SightCone) | — | `Polygon2D` generowany z 60 raycastów per klatka |
| Strzałki UI (EnemyArrows) | — | Rysowane proceduralnie (`draw_colored_polygon`) |

Dźwięk / muzyka: brak w prezentowanej wersji.

---

## 5. Wykorzystanie AI

**Zachowanie postaci** — ręcznie zaprogramowana maszyna stanów (FSM): wrogowie działają na 3-stanowej FSM zaimplementowanej w GDScript. Pathfinding oparty na NavMesh Godota. Nie użyto żadnego systemu uczącego (ML/RL).

**AI w procesie tworzenia**: Claude Code (Anthropic) był używany jako asystent programistyczny przy implementacji mechanik (logika serwisów AI wroga, system poziomów, HUD, algorytm ping-pong pathfindingu). AI nie generowało grafiki, muzyki ani treści — służyło wyłącznie jako narzędzie do pisania i debugowania kodu GDScript.

---

## 6. Uruchomienie gry

**Wymagania:** Godot 4.6

**Z edytora:**
1. Otwórz projekt w Godot 4.6 (`File → Open Project`, wskaż folder z `project.godot`).
2. Naciśnij **F5** lub kliknij „Run Project".

**Z linii poleceń:**
```
godot --path /ścieżka/do/folderu/gry
```

**Moduł wykonywalny:** Eksport przez `Project → Export` w edytorze (wymaga zainstalowanych szablonów eksportu Godota).

---

## 7. Screenshots

<!-- Wstaw screenshoty tutaj -->

Sugerowane ujęcia:
- Ekran menu głównego
- Gameplay z widocznym stożkami widzenia (żółty / czerwony)
- Duża plansza (poziom 5–8)
- Ekran ukończenia poziomu / ekran końcowy

---

## 8. Bibliografia

**Algorytm ping-pong pathfinding** (SearchService):
Własna implementacja „bouncing waypoints" — cel po osiągnięciu jest odbijany za poprzedni punkt kotwiczny, tworząc naturalną, nieregularną trasę patrolową. Komentarz z diagramem ASCII zawarty w kodzie: `scripts/enemies/base_enemy_services/search_service.gd`, linia 77.

**Godot Navigation System:**
Dokumentacja: https://docs.godotengine.org/en/stable/tutorials/navigation/
Użyte API: `NavigationAgent2D`, `NavigationServer2D.map_get_closest_point()`, `NavigationServer2D.region_get_random_point()`
