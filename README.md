# motion_quality

This repo has two parts:

- **`dataset_yaru/`**: scripts that regenerate the moving-circle (and panorama) stimuli from Experiment 1 of the paper below, as lossless videos. The videos are used to test how well video quality metrics (ColorVideoVDP / `cvvdp`, FLIP, TOPIQ) predict the measured motion quality.
- **Everything else**: the original code and data from Denes, Jindal, Mikhailiuk & Mantiuk, *"A perceptual model of motion quality for rendering with adaptive refresh-rate and resolution"*, SIGGRAPH 2020 (referred to as **MARRR** in the scripts). The experiment code, the subjective results and the model are all included.

Most people will only need `dataset_yaru/`, which is described in section 1.

---

## 1. Moving-circle stimuli (`dataset_yaru/`)

### The stimulus

A textured circle moves horizontally across a band of the screen. Each frame is the circle image pasted onto a plain background at the position for that time. The videos are encoded losslessly, and each motion condition is rendered at many frame rates.

The setup matches the MARRR display (see `experiment_fps_jod/a_setupinfo.txt`):

| | |
|---|---|
| Display | ASUS ROG Swift PG279Q, 2560 × 1440 |
| Viewing distance | ~108–110 cm |
| Horizontal field of view | 30° |
| Pixels per degree | 2560 / 30 ≈ 85.3 |
| Frame size | 2560 × 696. The height is cropped to 3.5 × the circle height to keep files small. |

### Circle images

| File | What it is |
|---|---|
| `circle1.png` | 199 × 199 px. A black and white checkerboard circle on a grey (128) background. This is the original MARRR stimulus. |
| `circle1_grey_on_white.png` | Same as above with the colours swapped. Made by `create_swapped_circle.py`. |
| `circle1_solid_grey.png` | A plain grey circle on white, with no texture. Made by `create_solid_grey_circle.py`. |
| `tery.png` | The panorama image (3241 × 720) for the panorama condition. |

### Motion conditions

The conditions are named by peak velocity:

- `condition_a_v15` = 15 °/s
- `condition_b_v30` = 30 °/s
- `condition_c_v45` = 45 °/s

There are two trajectory scripts.

**`generate_dataset_circle_cos.py`: left to right, half a cycle.** This is the current version.

```
θ(t) = 15 − 15·cos(2π f0 t),   f0 = v_max / (2π · 15)
```

- The circle starts at the left edge (θ = 0°), speeds up, and slows down to stop at the right edge (θ = 30°).
- Duration is half a period, `0.5 / f0`. That is ≈ 3.14 s for v15, 1.57 s for v30 and 1.05 s for v45.
- Starting and ending at rest makes the clip work with symmetric temporal padding.
- The circle centre starts at x = 0, so half of the circle is off-screen in the first and last frames.
- Output: `dataset_exp1_abc_cosine/<condition>/circle_<condition>_fpsNNN_lossless.mp4`

**`generate_dataest_circle_sin.py`: centred oscillation.** This is the original MARRR Exp. 1 motion.

```
θ(t) = 12 · sin(2π f0 t),   f0 = v_max / (2π · 12)
```

- The circle starts at the screen centre and swings ±12° several times. The number of cycles for each condition is set in `cycles_conditions`.
- The background is grey and the image is `circle1.png`.
- Output: `dataset_exp1_abc/<condition>/circle_<condition>_fpsNNN_lossless.mp4`

**`generate_dataset_panorama.py`: panorama condition (f).** The panorama scrolls with the "soft staircase" motion from Sec. 4.1.2 of the paper. Output: `dataset_exp1_f_panorama_720p/pano_v30_fpsNNN_720p_lossless.mp4`

### How to generate

Requirements: Python 3, `pillow`, and `ffmpeg` on the PATH (built with `libx265`).

```bash
cd dataset_yaru              # the scripts use relative paths; run them from here
python generate_dataset_circle_cos.py
```

Every run is controlled by the constants at the top of the script. **Check them before running**, because some are commented out and others are set to quick-test values:

| Constant | Meaning | Value currently in the cos script |
|---|---|---|
| `conditions` | which velocities to render | only `condition_a_v15` |
| `cycles_conditions` | how many cycles per condition | 0.5 |
| `fps_list` | frame rates to render | `[30]` |
| `BG_COLOR` | `"grey"` or `"white"` | `"white"` |
| `circle_png` | which circle image to use | `circle1_solid_grey.png` |

To get the full MARRR set, enable all three conditions and use `fps_list = list(range(50, 166, 5))` (50–165 Hz in steps of 5). Also render a high-fps reference, e.g. 167 or 631.

How a run works:

- Frames are written to a temporary folder (`tmp_frames*/`), encoded, and the folder is then deleted.
- Encoding uses `utils.encode_lossless_h265_mp4`: x265 `lossless=1`, `yuv444p`, preset `veryslow`.
- `utils.py` also has lossless H.264 and FFV1 encoders.

### Fixation points for cvvdp (SPEM)

`generate_fixation_csvs_circle.py` and `generate_fixation_csvs_panorama.py` write `fixation_fpsNNN.csv` files with columns `frame, x, y`. The circle script tracks the circle centre along the cosine trajectory. Pass the file to cvvdp to model smooth-pursuit eye movement, for example:

```bash
cvvdp --test circle_condition_a_v15_fps050_lossless.mp4 \
      --ref  circle_condition_a_v15_fps631_lossless.mp4 \
      --display asus_pg279q --temp-resample 631 --spem \
      --fixation-points fixation_fps631.csv
```

### Comparing metrics with the subjective data

- `test.py` reads `experiment_fps_jod/analysis/scaled_results.mat`, which holds the paper's JOD scores. It exports `marrr_scores_fig7_unified.csv` and `marrr_scores_fig8_independent.csv`.
- `plot_paper_fig.py` plots the metric predictions against the Fig. 7 JODs.
- `plot_metric_calibration_results.py` plots cvvdp, FLIP and TOPIQ results from the `metric_calibration` project. Its input paths are hard-coded to a local machine, so edit them before running.
- `metrics*.html` are saved interactive plots of these results.

---

## 2. Original MARRR code (Denes et al. 2020)

| Folder | Contents |
|---|---|
| `experiment_fps_jod/` | The main refresh-rate experiment (MATLAB): stimuli, sampling, `run_*_experiment*.m`, and analysis. `analysis/scaled_results.mat` holds the scaled JODs. |
| `experiment_blurvsjudder/` | Blur-vs-judder experiment: raw JSON results and scaling scripts. |
| `experiment_eyetracker/` | Eye-tracking experiment and analysis (EyeLink EDF converter in `deps/`). |
| `experiment_unity/` | Look-up-table scripts only. The Unity project itself is not in this repo. |
| `model/` | The motion quality model: `optimise_model*.m`, `model_predict_Q*.m`, visualisations. |
| `papers/` | LaTeX sources for the SIGGRAPH 2020 paper and supplementary material. |
| `denes20_comp.pdf` | The paper. |
| `readme_0213.txt` | Notes on how the Exp. 1 stimuli are defined. |

If you use this code or data, please cite:

> G. Denes, A. Jindal, A. Mikhailiuk, R. K. Mantiuk. *A perceptual model of motion quality for rendering with adaptive refresh-rate and resolution.* ACM Transactions on Graphics (SIGGRAPH), 2020.

---

## Notes

- **Videos are not in git.** `.gitignore` excludes `*.mp4` and `*.png`. Generate the videos locally, or ask for the pre-rendered set (`dataset_yaru/iridium/`).
- **Known inconsistency.** `generate_fixation_csvs_circle.py` uses one common duration (that of the slowest condition) for every condition. `generate_dataset_circle_cos.py` uses half a period per condition. For v30 and v45, the CSV therefore has more frames than the video. Fix one of the two scripts before using SPEM on those conditions.
- The file name `generate_dataest_circle_sin.py` has a typo ("dataest").
