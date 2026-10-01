"""
Generate fixation-point CSV files that track the circle center along
the cosine trajectory, for use with --fixation-points in cvvdp SPEM.

Reuses the exact trajectory math from generate_dataset_circle_cos.py.
"""

import csv, math
from pathlib import Path

W_ORIGINAL = 2560
FOV_DEG = 30.0
PPD = W_ORIGINAL / FOV_DEG
A_DEG = 15.0

CIRCLE_H = 199
H_CROP = int(CIRCLE_H * 3.5)  # 696
Y_CENTER = H_CROP // 2         # 348

conditions = {
    "condition_a_v15": 15.0,
    # "condition_b_v30": 30.0,
    # "condition_c_v45": 45.0,
}

# Common duration: match the longest condition (condition_a) so all have
# the same frame count.  Faster conditions complete more cosine cycles.
_f0_slowest = min(conditions.values()) / (2.0 * math.pi * A_DEG)
COMMON_DURATION = 0.5 / _f0_slowest

FPS_LIST = [631]

out_dir = Path("dataset_exp1_abc_cosine")

for cond_name, v_max in conditions.items():
    f0 = v_max / (2.0 * math.pi * A_DEG)

    for fps in FPS_LIST:
        n_frames = int(round(COMMON_DURATION * fps))

        csv_path = out_dir / cond_name / f"fixation_fps{fps:03d}.csv"
        csv_path.parent.mkdir(parents=True, exist_ok=True)

        with open(csv_path, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["frame", "x", "y"])
            for i in range(n_frames):
                t = i / fps
                theta = 15.0 - A_DEG * math.cos(2.0 * math.pi * f0 * t)
                x_center = int(theta * PPD)
                writer.writerow([i, x_center, Y_CENTER])

        print(f"{csv_path}  ({n_frames} frames)")

print("\nDone.")
