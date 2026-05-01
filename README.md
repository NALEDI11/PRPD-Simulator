# PRPD Simulator – Detection and Visualisation of Partial Discharge in Inverter-Fed Electrical Machines

**Author:** Naledi Majake | **Student ID:** 11138055 | **Date:** 29 April 2026

---

## 1. Introduction

This software simulates a real-time Phase-Resolved Partial Discharge (PRPD) pattern on an inverter-fed three-phase system. It processes streaming data files, applies adaptive filtering to isolate fundamental frequency components, determines phase relationships between channels, and generates PRPD heatmaps for partial discharge detection and visualisation.

The system is designed as a proof of concept to demonstrate the viability of on-line partial discharge (PD) detection in electric vehicles (EVs), where monitoring insulation condition in high-voltage equipment is safety-critical. It processes pre-recorded CSV data and produces PRPD visualisations showing discharge activity across all three phases.

---

## 2. Contextual Overview

The software is structured as a pipeline of processing stages, each implemented as a separate MATLAB function. Data flows from raw CSV files through frequency identification, filtering, and phase correction before being mapped onto a PRPD heatmap.

<img width="564" height="1054" alt="image" src="https://github.com/user-attachments/assets/46d447e5-d453-4a49-a19a-7654f49e8241" />

> **Note:** Phase A is used as the reference phase throughout all detection and phase-relationship calculations.

---

## 3. Installation Instructions

### Required Software

| Software | Version |
|---|---|
| MATLAB | R2019a or later (tested on R2024a) |
| Signal Processing Toolbox | Included with MATLAB |

### Dependencies

No additional third-party libraries are required.

### Environment Setup

1. Clone or download all `.m` files into a single folder:
   - RunMe.m
   - Realtime_Controller.m
   - Discrete_FFT.m
   - Phase_Relationship.m
   - Filtering.m
   - Phase_Corrected.m
   - Update_histogram.m
   - Save_PRPD_Figures.m


2. Add the folder to the MATLAB path
  matlab
  addpath('C:\your\folder\path')
  savepath

---

## 4. How to Run the Software

The entry point is `RunMe.m`. Open this file in MATLAB and set the following user-configurable parameters before running:

| Parameter | Description |
|---|---|
| MATLAB folder path | Path to the directory containing the `.m` files |
| Data folder path | Path to the folder containing the CSV data files |
| Reference data file path | Path to the reference CSV file |
| Reference channel number | Channel index used as the phase reference |
| PRPD noise threshold | Maximum magnitude considered noise (used for PD detection) |

Once all parameters are set, press **Run** (or call `RunMe` from the MATLAB command window) to start the simulator.

### CSV Input Format

**Data files** (5 columns):

| Column | Description | Units |
|---|---|---|
| 1 | Timestamp | Seconds |
| 2 | Phase A PD signal | Volts |
| 3 | Phase B PD signal | Volts |
| 4 | Phase C PD signal | Volts |
| 5 | Reference voltage signal (Phase A) | Volts |

**Reference data file** (4 columns):

| Column | Description | Units |
|---|---|---|
| 1 | Timestamp | Seconds |
| 2 | Phase A | Volts |
| 3 | Phase B | Volts |
| 4 | Phase C | Volts |

### Expected Output

- A live MATLAB figure window showing **three PRPD heatmaps**, updating after each data file is processed.
- Console output with processing progress and summary statistics.
- Two saved image files in the working directory:
  - `PRPD_Initial_Heatmap.png`
  - `PRPD_Final_Heatmap.png`

---

## 5. Technical Details

### Design Assumption

All phase detection and discharge classification is performed relative to **Phase A**, which serves as the reference phase throughout the system.

### Algorithms

| Stage | Function | Method |
|---|---|---|
| Frequency detection | `Discrete_FFT.m` | Fast Fourier Transform (FFT) to identify the dominant fundamental frequency in the signal |
| Phase calibration | `Phase_Relationship.m` | Cross-correlation or peak-alignment against the reference file to compute per-channel phase offsets |
| Filtering | `Filtering.m` | Adaptive low-pass filter with cutoff derived from the detected fundamental frequency |
| Peak detection | `Realtime_Controller.m` | Threshold-based detection; events exceeding the user-defined noise maximum are classified as PD candidates |
| Histogram binning | `Update_histogram.m` | Detected events are binned into a 2D phase–magnitude histogram to build the PRPD pattern |
| Visualisation & export | `Save_PRPD_Figures.m` | Heatmap rendered from accumulated histogram; exported at initial and final processing stages |

### PRPD Heatmap

The PRPD (Phase-Resolved Partial Discharge) pattern maps discharge magnitude against the instantaneous phase angle of the supply voltage at the time of each event. Repeated discharge events cluster into characteristic patterns that can be used to identify the nature and location of insulation degradation.

---

## 6. Known Issues and Future Improvements

### Known Issues

- **Hard-coded folder structure:** Although `RunMe.m` exposes key parameters to the user, some internal paths and folder configurations remain hard-coded. Users must ensure their data is organised in the expected directory structure for the software to run without modification.

- **Saturating heatmap colour scale:** The PRPD heatmap count has a fixed maximum. When a large number of data points are processed, high-frequency bins (typically noise) saturate quickly. Because PD events naturally occur less frequently than noise, they can become visually indistinguishable on a saturated scale — potentially giving a false impression that no PD is present.

- **Fixed y-axis scale:** The heatmap y-axis (magnitude) is fixed to allow consistent visual comparison across runs. While this aids relative comparison, it may clip signals if discharge magnitudes fall outside the expected range.

### Future Improvements

- Replace hard-coded paths with fully parameterised inputs in `RunMe.m`.
- Implement a dual-scale or normalised heatmap view that separately renders noise and PD clusters to prevent saturation masking low-count PD events.
- Add automatic y-axis scaling with an optional lock mode for controlled comparisons.
- Extend the system to accept live streaming data (e.g., from a serial or network interface) to support genuine real-time monitoring rather than simulation from pre-recorded files.
- Validate the system on hardware from EV high-voltage systems to confirm suitability for on-vehicle deployment.

---

*This software was developed as part of a final-year project on inverter-fed machine condition monitoring.*
