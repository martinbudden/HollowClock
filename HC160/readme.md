<a name="TOP"></a>

# Hollow Clock Assembly Instructions


![Main Assembly](assemblies/main_assembled.png)



<span></span>

---

## Table of Contents

1. [Parts list](#Parts_list)

1. [Clock_Face assembly](#Clock_Face_assembly)
1. [Gears assembly](#Gears_assembly)
1. [Base_Stage_1 assembly](#Base_Stage_1_assembly)
1. [Base assembly](#Base_assembly)
1. [Main assembly](#main_assembly)

<span></span>
[Top](#TOP)

---
<a name="Parts_list"></a>

## Parts list


| <span style="writing-mode: vertical-rl; text-orientation: mixed;">Clock Face</span> | <span style="writing-mode: vertical-rl; text-orientation: mixed;">Gears</span> | <span style="writing-mode: vertical-rl; text-orientation: mixed;">Base</span> | <span style="writing-mode: vertical-rl; text-orientation: mixed;">Main</span> | <span style="writing-mode: vertical-rl; text-orientation: mixed;">TOTALS</span> |  |
|-----:|-----:|-----:|-----:|------:|:---|
|      |      |      |      |       | **Vitamins** |
|   .  |   .  |   4  |   .  |    4  |  Bolt M2 caphead x  6mm |
|   .  |   .  |   2  |   .  |    2  |  Bolt M3 buttonhead x  6mm |
|   .  |   .  |   4  |   2  |    6  |  Bolt M3 buttonhead x  8mm |
|   .  |   .  |   1  |   .  |    1  |  Bolt M3 caphead x 16mm |
|   .  |   1  |   .  |   .  |    1  |  Geared stepper - 28BYJ-48 5V |
|   .  |   .  |   1  |   .  |    1  |  Raspberry Pi Pico |
|   .  |   .  |   1  |   .  |    1  |  ZC-A0591 ULN2003 driver PCB |
|   .  |   1  |  13  |   2  |   16  | Total vitamins count |
|      |      |      |      |       | **3D printed parts** |
|   .  |   .  |   1  |   .  |    1  | Base.stl |
|   1  |   .  |   .  |   .  |    1  | Clock_Face.stl |
|   .  |   .  |   .  |   1  |    1  | Cover.stl |
|   .  |   1  |   .  |   .  |    1  | Drive_Gear.stl |
|   .  |   1  |   .  |   .  |    1  | Hour_Gear.stl |
|   1  |   .  |   .  |   .  |    1  | Hour_Hand.stl |
|   1  |   .  |   .  |   .  |    1  | Minute_Hand.stl |
|   .  |   .  |   1  |   .  |    1  | Reduction_Gear.stl |
|   3  |   2  |   2  |   1  |    8  | Total 3D printed parts count |

<span></span>
[Top](#TOP)

---
<a name="Clock_Face_assembly"></a>

## Clock_Face assembly

### 3D Printed parts

| 1 x Clock_Face.stl | 1 x Hour_Hand.stl | 1 x Minute_Hand.stl |
|---|---|---|
| ![Clock_Face.stl](stls/Clock_Face.png) | ![Hour_Hand.stl](stls/Hour_Hand.png) | ![Minute_Hand.stl](stls/Minute_Hand.png) 



### Assembly instructions

![Clock_Face_assembly](assemblies/Clock_Face_assembly.png)

![Clock_Face_assembled](assemblies/Clock_Face_assembled.png)

<span></span>
[Top](#TOP)

---
<a name="Gears_assembly"></a>

## Gears assembly

### Vitamins

|Qty|Description|
|---:|:----------|
|1| Geared stepper - 28BYJ-48 5V|


### 3D Printed parts

| 1 x Drive_Gear.stl | 1 x Hour_Gear.stl |
|---|---|
| ![Drive_Gear.stl](stls/Drive_Gear.png) | ![Hour_Gear.stl](stls/Hour_Gear.png) 



### Assembly instructions

![Gears_assembly](assemblies/Gears_assembly_tn.png)

![Gears_assembled](assemblies/Gears_assembled_tn.png)

<span></span>
[Top](#TOP)

---
<a name="Base_Stage_1_assembly"></a>

## Base_Stage_1 assembly

### Vitamins

|Qty|Description|
|---:|:----------|
|4| Bolt M2 caphead x  6mm|
|4| Bolt M3 buttonhead x  8mm|
|1| Bolt M3 caphead x 16mm|
|1| Raspberry Pi Pico|
|1| ZC-A0591 ULN2003 driver PCB|


### 3D Printed parts

| 1 x Base.stl | 1 x Reduction_Gear.stl |
|---|---|
| ![Base.stl](stls/Base.png) | ![Reduction_Gear.stl](stls/Reduction_Gear.png) 



### Assembly instructions

![Base_Stage_1_assembly](assemblies/Base_Stage_1_assembly.png)

![Base_Stage_1_assembled](assemblies/Base_Stage_1_assembled.png)

<span></span>
[Top](#TOP)

---
<a name="Base_assembly"></a>

## Base assembly

### Vitamins

|Qty|Description|
|---:|:----------|
|2| Bolt M3 buttonhead x  6mm|


### Sub-assemblies

| 1 x Base_Stage_1_assembly | 1 x Gears_assembly |
|---|---|
| ![Base_Stage_1_assembled](assemblies/Base_Stage_1_assembled_tn.png) | ![Gears_assembled](assemblies/Gears_assembled_tn.png) 



### Assembly instructions

![Base_assembly](assemblies/Base_assembly.png)

![Base_assembled](assemblies/Base_assembled.png)

<span></span>
[Top](#TOP)

---
<a name="main_assembly"></a>

## main assembly

### Vitamins

|Qty|Description|
|---:|:----------|
|2| Bolt M3 buttonhead x  8mm|


### 3D Printed parts

| 1 x Cover.stl |
|---|
| ![Cover.stl](stls/Cover.png) 



### Sub-assemblies

| 1 x Base_assembly | 1 x Clock_Face_assembly |
|---|---|
| ![Base_assembled](assemblies/Base_assembled_tn.png) | ![Clock_Face_assembled](assemblies/Clock_Face_assembled_tn.png) 



### Assembly instructions

![main_assembly](assemblies/main_assembly.png)

![main_assembled](assemblies/main_assembled.png)

<span></span>
[Top](#TOP)
