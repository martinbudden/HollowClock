<a name="TOP"></a>
# HollowClock
# Hollow Clock Assembly Instructions


![Main Assembly](assemblies/main_assembled.png)



<span></span>

---

## Table of Contents

1. [Parts list](#Parts_list)

1. [Clock Face Assembly](#Clock_Face_assembly)
1. [Gears Assembly](#Gears_assembly)
1. [Base Stage 1 Assembly](#Base_Stage_1_assembly)
1. [Base Assembly](#Base_assembly)
1. [Main Assembly](#main_assembly)

<span></span>
[Top](#TOP)

---
<a name="Parts_list"></a>

## Parts list


| <span style="writing-mode: vertical-rl; text-orientation: mixed;">Clock Face</span> | <span style="writing-mode: vertical-rl; text-orientation: mixed;">Gears</span> | <span style="writing-mode: vertical-rl; text-orientation: mixed;">Base</span> | <span style="writing-mode: vertical-rl; text-orientation: mixed;">Main</span> | <span style="writing-mode: vertical-rl; text-orientation: mixed;">TOTALS</span> |  |
|---:|---:|---:|---:|---:|:---|
|  |  |  |  | | **Vitamins** |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;4&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;4&nbsp; | &nbsp;&nbsp; Bolt M2 caphead x  6mm |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;2&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;2&nbsp; | &nbsp;&nbsp; Bolt M3 buttonhead x  6mm |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;3&nbsp; | &nbsp;&nbsp;2&nbsp; |  &nbsp;&nbsp;5&nbsp; | &nbsp;&nbsp; Bolt M3 buttonhead x  8mm |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp; Bolt M3 caphead x 16mm |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp; Geared stepper - 28BYJ-48 5V |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp; Raspberry Pi Pico |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp; ZC-A0591 ULN2003 driver PCB |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;12&nbsp; | &nbsp;&nbsp;2&nbsp; | &nbsp;&nbsp;15&nbsp; | &nbsp;&nbsp;Total vitamins count |
|  |  |  |  | | **3D printed parts** |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;Base.stl |
| &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;Clock_Face.stl |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;Cover.stl |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;Drive_Gear.stl |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;Hour_Gear.stl |
| &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;Hour_Hand.stl |
| &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;Minute_Hand.stl |
| &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;.&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;.&nbsp; |  &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;Reduction_Gear.stl |
| &nbsp;&nbsp;3&nbsp; | &nbsp;&nbsp;2&nbsp; | &nbsp;&nbsp;2&nbsp; | &nbsp;&nbsp;1&nbsp; | &nbsp;&nbsp;8&nbsp; | &nbsp;&nbsp;Total 3D printed parts count |

<span></span>
[Top](#TOP)

---
<a name="Clock_Face_assembly"></a>

## Clock Face Assembly

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

## Gears Assembly

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

## Base Stage 1 Assembly

### Vitamins

|Qty|Description|
|---:|:----------|
|4| Bolt M2 caphead x  6mm|
|3| Bolt M3 buttonhead x  8mm|
|1| Bolt M3 caphead x 16mm|
|1| Raspberry Pi Pico|
|1| ZC-A0591 ULN2003 driver PCB|


### 3D Printed parts

| 1 x Base.stl | 1 x Reduction_Gear.stl |
|---|---|
| ![Base.stl](stls/Base.png) | ![Reduction_Gear.stl](stls/Reduction_Gear.png) 



### Assembly instructions

![Base_Stage_1_assembly](assemblies/Base_Stage_1_assembly.png)

Wiring is easier if the stepper driver pcb is mounted "upside down" and attached with just 3 screws.

![Base_Stage_1_assembled](assemblies/Base_Stage_1_assembled.png)

<span></span>
[Top](#TOP)

---
<a name="Base_assembly"></a>

## Base Assembly

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

## Main Assembly

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
