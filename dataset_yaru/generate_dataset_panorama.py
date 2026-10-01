import math
import subprocess
import shutil
from pathlib import Path
from PIL import Image
from utils import encode_lossless_h265_mp4

# 1. 实验基本参数
W_SCREEN = 2560
H_SCREEN = 720   # 修改这里：高度直接匹配图片高度
FOV_DEG = 30.0
PPD = W_SCREEN / FOV_DEG
DURATION = 5.0   # 视频时长
# FPS_LIST = list(range(145, 166, 5)) + [167]
FPS_LIST = [631]

def soft_staircase(t):
    """sec 4.1.2 (Condition f)"""
    if t == 0: return 15 # limit of sin(2πt)/(2πt) + t as t→0
    return 15.0 * (math.sin(2.0 * math.pi * t) / (2.0 * math.pi * t) + t)


def main():
    out_root = Path("dataset_exp1_f_panorama_720p")
    tmp_root = Path("tmp_frames_pano_720")
    out_root.mkdir(exist_ok=True)
    
    # 加载全景图 (3241, 720)
    pano = Image.open("tery.png").convert("RGB")
    pw, ph = pano.size
    
    print(f"Video Resolution: {W_SCREEN}x{H_SCREEN} (Matches Image Height)")

    for fps in FPS_LIST:
        frames_dir = tmp_root / f"fps_{fps:03d}"
        frames_dir.mkdir(parents=True, exist_ok=True)
        
        n_frames = int(DURATION * fps)
        
        for i in range(n_frames):
            t = i / fps
            theta = soft_staircase(t)
            
            # 计算总偏移像素
            x_offset_total = int(round(theta * PPD))
            
            # 循环滚动偏移量
            x_offset = x_offset_total % pw
            
            # 处理跨越图片边界的切割逻辑
            if x_offset + W_SCREEN > pw:
                # 截取图片末尾
                part1 = pano.crop((x_offset, 0, pw, H_SCREEN))
                # 截取图片开头补齐
                part2 = pano.crop((0, 0, W_SCREEN - (pw - x_offset), H_SCREEN))
                
                # 合并
                frame = Image.new("RGB", (W_SCREEN, H_SCREEN))
                frame.paste(part1, (0, 0))
                frame.paste(part2, (part1.width, 0))
            else:
                # 正常截取
                frame = pano.crop((x_offset, 0, x_offset + W_SCREEN, H_SCREEN))
            
            frame.save(frames_dir / f"{i+1:06d}.png")
            
        video_name = f"pano_v30_fps{fps:03d}_720p_lossless.mp4"
        out_path = out_root / video_name
        encode_lossless_h265_mp4(frames_dir, fps, out_path)
        shutil.rmtree(frames_dir)
        print(f"  - Generated: {video_name}")

    if tmp_root.exists():
        shutil.rmtree(tmp_root)
    print("\nDataset generation finished. All videos are 2560x720.")

if __name__ == "__main__":
    main()