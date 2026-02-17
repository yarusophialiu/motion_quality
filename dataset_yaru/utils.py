import os, math, shutil, subprocess
from pathlib import Path

def encode_lossless_ffv1(frames_dir: Path, fps: int, out_path: Path):
    """
    Encodes frames as FFV1 (lossless) into MKV.
    """
    out_path.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "ffmpeg", "-y",
        "-framerate", str(fps),
        "-i", str(frames_dir / "%06d.png"),
        "-c:v", "ffv1",
        "-level", "3",
        "-pix_fmt", "rgb24",
        str(out_path)
    ]
    subprocess.run(cmd, check=True)


def encode_lossless_h264_mp4(frames_dir: Path, fps: int, out_path: Path):
    """
    使用 x264 将帧无损编码为 MP4 格式。
    """
    out_path.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "ffmpeg", "-y",
        "-framerate", str(fps),
        "-i", str(frames_dir / "%06d.png"),
        "-c:v", "libx264",
        "-preset", "veryslow",
        "-crf", "0",            
        "-pix_fmt", "yuv444p",  
        str(out_path)
    ]
    subprocess.run(cmd, check=True)
    

def encode_lossless_h265_mp4(frames_dir: Path, fps: int, out_path: Path):
    """
    使用 x265 将帧无损编码为 MP4 格式。
    """
    out_path.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "ffmpeg", "-y",
        "-framerate", str(fps),
        "-i", str(frames_dir / "%06d.png"),
        "-c:v", "libx265",
        "-preset", "veryslow",   # 最佳压缩效率
        "-x265-params", "lossless=1",  # 开启 H.265 硬件级无损模式
        "-pix_fmt", "yuv444p",   # 确保颜色采样不被压缩，保持纹理清晰
        str(out_path)
    ]
    subprocess.run(cmd, check=True)

