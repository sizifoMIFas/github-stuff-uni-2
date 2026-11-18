## Testavimas

- Kompiuteris: MacBook (Apple M4 Max, 36 GB RAM), macOS 27.2
- Kompiliatorius: `g++ -std=c++17 -O2`
- Failai: `studentai10000.txt`, `studentai100000.txt`, `studentai1000000.txt` (visuose testuose tie patys)
- Kiekvienas laikas yra **5 paleidimu vidurkis** (sekundemis), gautas skriptu `benchmark.zsh`:

```zsh
zsh benchmark.zsh
```

- Visi neapdoroti rezultatai yra faile `benchmark_laikai.txt`.
- Strategijos 2 ir 3 dirba tiesiogiai su pradiniu konteineriu (kopija nedaroma).
- Visu strategiju ir abieju konteineriu sukurti failai yra identiski (patikrinta kontroline suma paskutiniame lenteles stulpelyje), todel laikai palyginami.

![Testo rezultatai](nuotraukos/benchmark.png)

## Rezultatai: skirstymas i dvi grupes (s)

| Studentu | list, strat. 1 | list, strat. 2 | list, strat. 3 | vector, strat. 1 | vector, strat. 2 | vector, strat. 3 |
|---|---|---|---|---|---|---|
| 10 000 | 0.00074 | 0.00022 | 0.00035 | 0.00059 | 0.05355 | **0.00021** |
| 100 000 | 0.00790 | 0.00219 | 0.00333 | 0.00540 | 5.35180 | **0.00163** |
| 1 000 000 | 0.07409 | **0.02380** | 0.03045 | 0.05641 | 535.4 (vienas paleidimas) | **0.01656** |

Kitu zingsniu laikai su 1 000 000 studentu (s):

| Zingsnis | list | vector |
|---|---|---|
| nuskaitymas | 0.95 | 0.96 |
| rikiavimas | 0.06 | 0.01 |
| irasymas i failus | 0.28 | 0.27 |

## Atminties naudojimas

Po skirstymo programa isveda, kiek studentu objektu yra atmintyje (su 1 000 000 studentu):

| Strategija | Studentu objektu atmintyje |
|---|---|
| 1 | 2 000 000 |
| 2 | 1 000 000 |
| 3 | 1 000 000 |

![Atminties patikra](nuotraukos/atmintis.png)

Pirmoje strategijoje kiekvienas studentas egzistuoja du kartus: pradiniame konteineryje ir viename is dvieju naujuju. Strategijos 2 ir 3 studentus perkelia, todel kiekvienas yra tik viena karta. Skaiciuojami objektai, ne baitai, bet visi objektai vienodo tipo, todel atminties sanaudos studentams skiriasi apie 2 kartus.

## Isvados

- **`vector` + strategija 2 netinka dideliems duomenims.** Kiekvienas `erase` priverstina visus uz istrinto studento esancius elementus pasislinkti, todel laikas auga kvadratiskai: 10 kartu daugiau studentu reiske apie 100 kartu daugiau laiko. Su 1 000 000 studentu uztruko apie 9 minutes (matuota viena karta).
- **`vector` + strategija 3 yra greiciausia**: apie 3.4 karto greitesne uz strategija 1 ir daugiau nei 30 000 kartu greitesne uz strategija 2 (1 000 000 studentu). `stable_partition` perrikiuoja vienu praejimu, o `erase` istrina uodega vienu kvietimu, nieko neperstumdamas.
- **`list` atveju laimi strategija 2**, nes trynimas is saraso tik pakeicia rodykles tarp kaimynu. Strategija 1 yra apie 3 kartus letesne. Strategija 3 `list` atveju arti strategijos 2, bet jos nenugali.
- **Strategija 1 naudoja du kartus daugiau atminties** studentams (zr. atminties lentele).
- **Skirstymas nera pagrindine kliutis**: su 1 000 000 studentu nuskaitymas uztrunka apie 0.95 s, o skirstymas 0.02-0.07 s (isskyrus `vector` + strategija 2).
- **Rikiavimas** su `vector` yra apie 6 kartus greitesnis nei su `list` (`list` elementai atmintyje isbarstyti, `vector` - is eiles).
- Vieno paleidimo laikai svyruoja (apie 10-30 %), todel naudojami 5 paleidimu vidurkiai.

---

## v1.1: `struct` pakeistas `class`

`studentas` is `struct` pakeistas i `class` (`studentas.h`):

- visi laukai yra `private` (`vardas_`, `pavarde_`, `ndpazymiai_`, `egzrezultatas_`, `rezvidurkis_`, `rezmedian_`), pasiekiami per `getter` metodus (`vardas()`, `pavarde()`, `rezvidurkis()`, `rezmedian()`);
- konstruktorius su duomenimis (vidurki ir mediana apskaiciuoja pats), numatytasis konstruktorius (`int` ir `double` laukai pradedami nuliu);
- kopijavimo konstruktorius, kopijavimo priskyrimo operatorius (`operator=`, su `this != &copy` patikra) ir destruktorius;
- `reading.cpp`, `main.cpp`, `menu.cpp`, `rikiavimas.cpp` ir `filtering.cpp` pritaikyti: studentai kuriami konstruktoriumi, laukai skaitomi getteriais.

Programos rezultatai nepasikeite: visu atveju failu kontroline suma sutampa su v1.0 (`7214238e` su 100 000 ir `f84ad3ac` su 1 000 000 studentu).

### Testavimas: `struct` (v1.0) pries `class` (v1.1)

- Kompiuteris ir failai tie patys kaip aukstiau (MacBook, Apple M4 Max, `studentai100000.txt`, `studentai1000000.txt`).
- Konteineris: `vector`, skirstymo strategija 3 (greiciausia pagal v1.0 rezultatus).
- `struct` versija kompiliuojama is `v1.0` zymes, `class` versija is siuo metu esancio kodo, abi su `g++ -std=c++17 -DUSE_VECTOR` ir skirtingomis `-O` veliavelemis.
- Kiekvienas laikas yra **5 paleidimu vidurkis** (sekundemis), gautas skriptu `benchmark_flags.zsh`:

```zsh
zsh benchmark_flags.zsh
```

**Vykdomojo failo dydis (baitais):**

| Veliavele | `struct` | `class` |
|---|---|---|
| `-O1` | 85 656 | 86 248 |
| `-O2` | 85 656 | 86 248 |
| `-O3` | 85 320 | 85 752 |

**100 000 studentu (s):**

| Versija | Veliavele | nuskaitymas | skirstymas | rikiavimas | irasymas |
|---|---|---|---|---|---|
| `struct` | `-O1` | 0.19423 | 0.00143 | 0.00087 | 0.02721 |
| `struct` | `-O2` | 0.19994 | 0.00154 | 0.00088 | 0.02657 |
| `struct` | `-O3` | 0.19331 | 0.00150 | 0.00090 | 0.02674 |
| `class` | `-O1` | 0.19633 | 0.00248 | 0.00090 | 0.02647 |
| `class` | `-O2` | 0.19486 | 0.00241 | 0.00087 | 0.02667 |
| `class` | `-O3` | 0.19737 | 0.00233 | 0.00087 | 0.02701 |

**1 000 000 studentu (s):**

| Versija | Veliavele | nuskaitymas | skirstymas | rikiavimas | irasymas |
|---|---|---|---|---|---|
| `struct` | `-O1` | 0.95501 | 0.01679 | 0.01022 | 0.27598 |
| `struct` | `-O2` | 0.95072 | 0.01720 | 0.00972 | 0.27526 |
| `struct` | `-O3` | 0.98574 | 0.01826 | 0.01040 | 0.27856 |
| `class` | `-O1` | 0.97740 | 0.02686 | 0.00998 | 0.27192 |
| `class` | `-O2` | 0.96610 | 0.02705 | 0.01002 | 0.27325 |
| `class` | `-O3` | 0.97942 | 0.02676 | 0.01008 | 0.27901 |

Visi neapdoroti rezultatai yra faile `benchmark_flags.txt`.

### Isvados

- **Skirstymas su `class` yra apie 1.5-1.7 karto letesnis** nei su `struct` (1 000 000 studentu: ~0.027 s pries ~0.017 s). Kiti zingsniai (nuskaitymas, rikiavimas, irasymas) skiriasi tik matavimo paklaida (apie 1-3 %).
- Tikriausia priezastis: `class` turi paties parasytus kopijavimo konstruktoriu ir destruktoriu, todel kompiliatorius **nesukuria perkelimo (move) operaciju**. `stable_partition` ir `push_back` studentus perkelia, bet `class` atveju juos kopijuoja (nauji `string` ir `vector<int>` objektai). `struct` neturi sioku funkciju, todel gauna perkelima automatiskai. Tai nebuvo atskirai patikrinta (move operaciju nepridejau).
- **Vykdomojo failo dydis** beveik nesiskiria: `class` versija yra apie 0.4-0.6 KB didesne.
- **Veliaveles `-O1`, `-O2`, `-O3` beveik nieko nekeicia**: skirtumai tarp ju yra matavimo paklaidos ribose, o `-O3` nera greitesnis nei `-O2`. Visose kombinacijose kontroline suma sutampa, todel laikai palyginami.
