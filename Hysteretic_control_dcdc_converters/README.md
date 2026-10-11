# Control-and-Instrumentation-for-Systems
Find all codes related to control and instrumentation for Power converter here. 
# ESZG545 — Power Converter Control: Simulation & Design Code

Simulation models, design scripts, and worked examples accompanying **ESZG545 (Control and Instrumentation)** at BITS Pilani WILP. Covers the full modeling-to-control pipeline for DC–DC converters: switched-circuit simulation, small-signal averaged modeling, voltage-mode compensator design, and peak current-mode control.

Primary reference: R. W. Erickson and D. Maksimović, *Fundamentals of Power Electronics*, 2nd ed., Springer, 2007.

---

## Contents

| Folder | Description | Session |
|---|---|---|
| [`01-power-stage/`](#01-power-stage) | Switched buck/boost converter models (Simulink, PLECS, LTspice) | Session 1 |
| [`02-averaged-models/`](#02-averaged-models) | Small-signal averaged models (Ch. 7.2–7.5) with switched-vs-averaged validation | Session 2 |
| [`03-voltage-mode-control/`](#03-voltage-mode-control) | Gvd(s)/Gvg(s) derivation, Bode plots, PI/PID compensator design (Ch. 8–9) | Session 3 |
| [`04-current-mode-control/`](#04-current-mode-control) | Peak current-mode control model, slope compensation demo (Ch. 12) | Session 4 |
| [`assignments/`](#assignments) | Design-review assignment templates and rubrics | All |
| [`docs/`](#docs) | Derivation notes, chapter/page reference maps | All |

---

## Prerequisites

- **MATLAB** R2021b+ with **Simulink** and **Simscape Electrical** (for `.slx` models)
- **PLECS Standalone** (free trial) or **PLECS Blockset** — for fast switched-converter simulation ([plexim.com](https://www.plexim.com))
- **LTspice** (free, Analog Devices) — for student take-home circuit verification
- **Python 3.9+** with `numpy`, `scipy`, `matplotlib`, `control` — for transfer-function analysis and Bode plots outside MATLAB

```bash
pip install numpy scipy matplotlib control
```

---

## 01 — Power Stage

Switched (non-averaged) models of the basic converters, used to generate real switching-frequency waveforms and validate the averaged models in `02-averaged-models/`.

- `buck_switched.slx` — Simulink/Simscape Electrical switched buck converter with PWM generator
- `buck_switched.plecs` — PLECS equivalent (faster simulation, recommended for live demos)
- `buck_ltspice.asc` — LTspice version for student take-home labs
- `boost_switched.slx`, `buckboost_switched.slx`

**Run it:**
```matlab
open('01-power-stage/buck_switched.slx')
sim('buck_switched');
```
Use a **fixed-step solver** (`ode4`, step size ≤ 1/(20·fs)) — variable-step solvers will smooth away switching ripple.

---

## 02 — Averaged Models

Implements all three small-signal derivation paths from Ch. 7, applied to the buck-boost converter (matching the textbook's worked example, Fig. 7.7–7.17):

- `basic_averaging.m` — Section 7.2: subinterval averaging → perturbation → linearization, symbolic derivation in MATLAB Symbolic Math Toolbox
- `state_space_averaging.m` — Section 7.3: formal state-space averaging (matrix form)
- `circuit_averaging.slx` — Section 7.4: averaged switch network model in Simulink
- `canonical_model.m` — Section 7.5: extracts canonical model parameters (M(D), e(s), Ze(s)) for buck/boost/buck-boost
- `switched_vs_averaged_overlay.slx` — **Recommended in-class demo**: overlays the switched model's step response against the averaged model's prediction on one scope, showing the averaged model tracks the envelope while ignoring ripple

**Validation check:** every method in this folder should produce the same `Gvd(s)` for a given converter/operating point — `validate_methods.m` runs all three and asserts numerical agreement.

---

## 03 — Voltage-Mode Control

- `gvd_derivation.m` — derives `Gvd(s)`, `Gvg(s)` symbolically for buck/boost/buck-boost (Ch. 8)
- `bode_plots.py` — Python/`control`-library Bode plots of the open-loop plant
- `compensator_design.m` — Type II/Type III compensator design meeting a target phase margin (Ch. 9), outputs component values for the op-amp network
- `loop_gain_verification.m` — plots `T(s) = Gc(s)Gvd(s)H(s)`, reports crossover frequency and phase margin
- `closed_loop_step_response.slx` — full closed-loop simulation (Fig. 1.15 architecture) for transient verification against a design spec

**Design flow:**
```
gvd_derivation.m  →  bode_plots.py  →  compensator_design.m  →  loop_gain_verification.m  →  closed_loop_step_response.slx
```

---

## 04 — Current-Mode Control

- `peak_current_mode_model.m` — first-order and CPM small-signal models (Ch. 12.2–12.3)
- `subharmonic_oscillation_demo.slx` — demonstrates D > 0.5 instability with slope compensation disabled — **flip `slope_comp_enable` to 0 to reproduce the oscillation live**
- `slope_compensation_calc.m` — computes the minimum required compensating ramp slope for a given D, L, and switching frequency

---

## Assignments

- `design_review_template.docx` — the Session 3/4 design-review assignment (spec sheet + rubric) — see course materials for the full version
- `spec_sheet_generator.py` — randomizes key spec parameters (Vin, Vout, Iout range) per student to reduce direct copying across submissions

---

## Docs

- `chapter_page_map.md` — verified chapter/section/page references against the 2nd edition (Springer, 2007) — see repository issue tracker if your printing's pagination differs
- `derivation_notes.pdf` — hand-derivation walkthroughs matching the symbolic MATLAB scripts, for offline reference

---

## Repository Conventions

- All Simulink models use a **fixed-step solver** by default — do not switch to variable-step without updating the switching-ripple visibility notes in the model's block comments
- MATLAB scripts are self-contained and runnable via `run('scriptname.m')` with no external data files unless noted
- Python scripts assume the `control` library's state-space/transfer-function conventions (not `scipy.signal`'s) — see `docs/python_conventions.md`

---

## Contributing

Corrections to derivations, additional converter topologies, or improved PLECS models are welcome — open a pull request or flag an issue with the specific chapter/section reference for any textbook-alignment concern.

---

## License

Course materials for educational use within ESZG545, BITS Pilani WILP. Textbook content referenced under fair use for educational commentary; original code and derivations in this repository may be reused with attribution.

## Reference

R. W. Erickson and D. Maksimović, *Fundamentals of Power Electronics*, 2nd ed. New York, NY, USA: Springer, 2007.
