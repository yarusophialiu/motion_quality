import math
import subprocess
from pathlib import Path
from PIL import Image
from utils import encode_lossless_h265_mp4


import math
import subprocess
import shutil
from pathlib import Path
from PIL import Image

# 1. 实验基本参数 (基于 ASUS PG279Q)
W_ORIGINAL = 2560
H_ORIGINAL = 1440
FOV_DEG = 30.0
PPD = W_ORIGINAL / FOV_DEG  # 约 85.33

# 2. 运动条件与刷新率列表
conditions = {
    "condition_a_v15": 15.0,
    "condition_b_v30": 30.0,
    "condition_c_v45": 45.0,
}
# fps_list = list(range(50, 76, 5)) # 166
fps_list = [167] # reference

# 3. 安全振幅：确保圆圈完全留在 30度 视场内 (-15度 到 +15度)
A_DEG = 12.0 

def main():
    out_root = Path("dataset_exp1_abc")
    tmp_root = Path("tmp_frames")
    circle_png = "circle1.png"
    
    # 预加载圆圈并计算裁剪高度
    circle = Image.open(circle_png).convert("RGBA")
    cw, ch = circle.size
    h_crop = int(ch * 3.5)  # 裁剪优化：3.5倍圆圈高度
    y_center = h_crop // 2
    
    print(f"Starting dataset generation. Crop height: {h_crop}px")

    for cond_name, v_max in conditions.items():
        cond_dir = out_root / cond_name
        cond_dir.mkdir(parents=True, exist_ok=True)
        
        # 计算该速度下的频率: f0 = v_max / (2 * pi * A)
        f0 = v_max / (2.0 * math.pi * A_DEG)
        duration = 1.0 / f0  # 正好 1 个周期
        
        print(f"\nProcessing {cond_name} (v_max={v_max} deg/s, f0={f0:.4f} Hz)")

        for fps in fps_list:
            frames_dir = tmp_root / cond_name / f"fps_{fps:03d}"
            frames_dir.mkdir(parents=True, exist_ok=True)
            
            n_frames = int(round(duration * fps))
            
            for i in range(n_frames):
                t = i / fps
                # 标准正弦波：从屏幕中心开始 (theta=0)
                theta = A_DEG * math.sin(2.0 * math.pi * f0 * t)
                
                x_center = int(W_ORIGINAL / 2 + theta * PPD)
                
                frame = Image.new("RGB", (W_ORIGINAL, h_crop), (128, 128, 128))
                x0 = x_center - cw // 2
                y0 = y_center - ch // 2
                frame.paste(circle, (x0, y0), circle)
                
                frame.save(frames_dir / f"{i+1:06d}.png")
            
            video_name = f"circle_{cond_name}_fps{fps:03d}_lossless.mp4"
            out_path = cond_dir / video_name
            encode_lossless_h265_mp4(frames_dir, fps, out_path)
            
            shutil.rmtree(frames_dir)
            print(f"  - Generated: {video_name}")

    # 最终清理
    if tmp_root.exists():
        shutil.rmtree(tmp_root)
    print("\nAll conditions and FPS variants generated successfully.")

if __name__ == "__main__":
    main()