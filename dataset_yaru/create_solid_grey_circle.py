import numpy as np
from PIL import Image, ImageDraw

def create_solid_circle():
    # Desired colors
    bg_color = (255, 255, 255)  # White background
    fg_color = (128, 128, 128)  # Solid grey circle

    # Dimensions based on circle1.png analysis
    width, height = 199, 199
    
    # Bounding box of the original circle pattern
    x_min, x_max = 21, 178
    y_min, y_max = 18, 175
    
    # We will draw at 4x resolution and downscale for anti-aliasing
    scale = 4
    large_size = (width * scale, height * scale)
    
    # Create the large image (with white background)
    large_img = Image.new('RGB', large_size, bg_color)
    draw = ImageDraw.Draw(large_img)
    
    # Draw the solid circle using scaled bounding box
    bbox = [x_min * scale, y_min * scale, x_max * scale, y_max * scale]
    draw.ellipse(bbox, fill=fg_color)
    
    # Downscale using LANCZOS back to original size for smooth edges
    final_img = large_img.resize((width, height), Image.Resampling.LANCZOS)
    
    # Save the new file
    output_path = 'C:/Users/15142/Projects/motion_quality/dataset_yaru/circle1_solid_grey.png'
    final_img.save(output_path)
    print(f"Successfully created solid grey circle at: {output_path}")

if __name__ == '__main__':
    create_solid_circle()
