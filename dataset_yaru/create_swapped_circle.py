import numpy as np
from PIL import Image

def swap_colors():
    # Load the image
    img = Image.open('circle1.png').convert('RGB')
    arr = np.array(img)
    
    # Create empty array
    new_arr = np.empty_like(arr)
    
    # Create masks
    mask_grey = np.all(arr == [128, 128, 128], axis=-1)
    mask_white = np.all(arr == [255, 255, 255], axis=-1)
    
    # Swap colors: background grey -> white, foreground white -> grey
    new_arr[mask_grey] = [255, 255, 255]
    new_arr[mask_white] = [128, 128, 128]
    
    # Handle any theoretical other pixels
    mask_other = ~(mask_grey | mask_white)
    new_arr[mask_other] = arr[mask_other]
    
    # Save the new image
    Image.fromarray(new_arr).save('circle1_grey_on_white.png')
    print("Successfully created 'circle1_grey_on_white.png'")

if __name__ == '__main__':
    swap_colors()
