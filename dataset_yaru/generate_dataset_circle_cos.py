import math
import subprocess, time
from pathlib import Path
from PIL import Image
from utils import encode_lossless_h265_mp4
import shutil



# cos curve,  starts from min location to max location
# only half period
# so it works with temp-padding symmetric
W_ORIGINAL = 2560
H_ORIGINAL = 1440
FOV_DEG = 30.0
PPD = W_ORIGINAL / FOV_DEG  # approxm 85.33

# 0.5 cycles
conditions = {
    "condition_a_v15": 15.0,
    # "condition_b_v30": 30.0,
    # "condition_c_v45": 45.0, # peak velocity 45 deg/s
}

cycles_conditions = {
    "condition_a_v15": 0.5,
    # "condition_b_v30": 0.5,
    # "condition_c_v45": 0.5,  # half cycle
}

# fps_list = list(range(30, 500, 20)) + [] # 166
fps_list = [30] # 166

# Background color: 'grey' or 'white'
BG_COLOR = "white" # "grey"

# 0-30 deg
A_DEG = 15.0  # circle in 30 deg

def main():
    out_root = Path("dataset_exp1_abc_cosine")
    tmp_root = Path("tmp_frames_cosine")
    circle_png = "circle1_solid_grey.png"

    if BG_COLOR == "grey":
        bg_rgb = (128, 128, 128)
    elif BG_COLOR == "white":
        bg_rgb = (255, 255, 255)
    else:
        raise ValueError("BG_COLOR must be 'grey' or 'white'")
        
    circle = Image.open(circle_png).convert("RGBA")
    cw, ch = circle.size
    h_crop = int(ch * 3.5)  
    y_center = h_crop // 2

    print(f"Starting dataset generation. Crop height: {h_crop}px")
    
    for cond_name, v_max in conditions.items():
        start_total = time.time()

        cond_dir = out_root / cond_name
        cond_dir.mkdir(parents=True, exist_ok=True)
        
        # A_DEG: Amplitude (half of the total movement range)
        # f0: temporal frequency Hz (cycles/sec)
        # how many full oscillation cycles the object would complete in one second
        f0 = v_max / (2.0 * math.pi * A_DEG)
        n_cycles = cycles_conditions[cond_name] 
        duration = n_cycles / f0  # 

        print(f'\ncycles is {n_cycles}, duration is {duration} s')
        print(f"\nProcessing {cond_name} (v_max={v_max} deg/s, f0={f0:.4f} Hz)")

        
        for fps in fps_list:
            frames_dir = tmp_root / cond_name / f"fps_{fps:03d}"
            frames_dir.mkdir(parents=True, exist_ok=True)
            
            n_frames = int(round(duration * fps))
            
            for i in range(n_frames):
                t = i / fps
                
                # edited to minus cosine：
                # theta: angular position, at time t, which position should circle appear in FOV 
                # represents the horizontal location of the object at t in visual degrees.
                # t=0, cos(0)=1, theta = 15 - 15 cos(...) = 0 (min point)
                # t=duration, cos(pi)=-1, theta = 15 - (-15) = 30 (max point)
                # theta from 0 to 30, i.e. left most of screen to right most of screen
                theta = 15.0 - A_DEG * math.cos(2.0 * math.pi * f0 * t)
                
                # map theta (0-30) to pixels, i.e. screen coordinates(0 - W_ORIGINAL)
                # 0 to 30, i.e. left most of screen to right most of screen
                # x_center: pixel on the screen where the center of the object should be located
                x_center = int(theta * PPD)
                
                frame = Image.new("RGB", (W_ORIGINAL, h_crop), bg_rgb)
                # images are typically "pasted" using their top-left corner
                # so x0, y0 are position of top-left corner of the circle
                x0 = x_center - cw // 2 
                y0 = y_center - ch // 2
                frame.paste(circle, (x0, y0), circle)
                
                frame.save(frames_dir / f"{i+1:06d}.png")
            
            video_name = f"circle_{cond_name}_fps{fps:03d}_lossless.mp4"
            out_path = cond_dir / video_name
            encode_lossless_h265_mp4(frames_dir, fps, out_path)
            
            shutil.rmtree(frames_dir)
            print(f"  - Generated: {video_name}")

        end_total = time.time()
        total_seconds = end_total - start_total

        minutes, seconds = divmod(total_seconds, 60)
        print(f"\nTotal execution time for {cond_name}: {int(minutes)}m {seconds:.2f}s")

    if tmp_root.exists():
        shutil.rmtree(tmp_root)
    print("\nAll conditions and FPS variants generated successfully.")

if __name__ == "__main__":
    main()