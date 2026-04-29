# PRPD-Simulator
MATLAB-based simulator for real-time Phase-Resolved Partial Discharge (PRPD) pattern visualisation
1. Title 
The functions listed in this README are the functions used to: receive the excel files/folders, process the various signals and update the PRPD plot to simulate a real time system. 

2. Introduction 
This software simulates a real-time Phase-Resolved Partial Discharge (PRPD) pattern on an inverter-fed three phase system. It processes streaming data files, applies adaptive filtering to isolate fundamental frequency components, determines phase relationships between channels, and generates PRPD heatmaps for partial discharge detection and visualisations. 

The system is designed as a proof of concept to show that this could be used for partial discharge (PD) detection in electric vehicles (EVs), where monitoring insulation condition and detecting partial discharge in high-voltage equipment is critical. It processes pre-recorded data and produces PRPD visualisation showing discharge activity across all three phases. 

3. Contextual Overview 
The software is structured as a pipeline of processing stages, all controlled by a controller, each implemented as separate MATLAB functions. Data flows from raw CSV files through frequency identification, filtering and phase correction before being mapped onto a PRPD heatmap. 

<img width="621" height="535" alt="image" src="https://github.com/user-attachments/assets/d9d6ba84-6c1c-4a07-b906-a4cdb67698ac" />

Note: Phase A is used as the reference phase throughout all detection and phase relationship calculations 

4. Installation Instructions 
**Required Software**
MATLAB R2019a or later (tested on R2024a) 
Signal Processing Toolbox

Dependencies 
No additional third-part libraries required 

5. Technical Details
**Design Assumptions**
All phase detection and discharge classification is performed relative to Phase A, which serves as the reference phase throughout the system.

**Algorithms**
| Stage | Function | Method |
|---|---|---|
| Frequency detection | `Discrete_FFT.m` | FFT to identify fundamental frequency |
