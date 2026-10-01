"""
Generate fixation-point CSV files for the panorama scrolling dataset.

The eye tracks a world-fixed point on the panorama. As the panorama
scrolls right by dx pixels per frame, the tracked point moves left by dx
on screen. The fixation trajectory captures this apparent motion.

Reuses the exact soft_staircase trajectory from generate_dataset_panorama.py.
"""

import csv, math
from pathlib import Path

W_SCREEN = 2560
H_SCREEN = 720
FOV_DEG = 30.0
PPD = W_SCREEN / FOV_DEG
DURATION = 5.0
FPS_LIST = [30, 50, 170]

Y_CENTER = H_SCREEN // 2  # 360

def soft_staircase(t):
    if t == 0:
        return 15.0  # limit of sin(2πt)/(2πt) + t as t→0
    return 15.0 * (math.sin(2.0 * math.pi * t) / (2.0 * math.pi * t) + t)

out_dir = Path("dataset_exp1_f_panorama_720p")
out_dir.mkdir(parents=True, exist_ok=True)

for fps in FPS_LIST:
    n_frames = int(DURATION * fps)

    csv_path = out_dir / f"fixation_fps{fps:03d}.csv"

    with open(csv_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["frame", "x", "y"])
        for i in range(n_frames):
            t = i / fps
            theta = soft_staircase(t)
            x_offset_total = int(round(theta * PPD))
            # Eye tracks a world-fixed point starting at screen center.
            # As the panorama scrolls right, the tracked point moves left.
            x_fixation = W_SCREEN / 2.0 - x_offset_total
            writer.writerow([i, f"{x_fixation:.1f}", Y_CENTER])

    print(f"{csv_path}  ({n_frames} frames)")

print("\nDone.")
