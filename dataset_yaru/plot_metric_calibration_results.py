import pandas as pd
import matplotlib.pyplot as plt
import re
import os

# cd dataset_yaru
# 1. Load the dataset
# Replace 'MARRR_FLIP.csv' MARRR_TOPIQ
root = r'C:\Users\15142\Projects\metric_calibration\metric_results\HPC\completed_csv_v2'
hpc_root = r'C:\Users\15142\Projects\metric_calibration\metric_results\HPC\partS'
metric_calib_dir = r'C:\Users\15142\Projects\metric_calibration'
current_dir = r'C:\Users\15142\Projects\motion_quality\dataset_yaru'
output_folder = 'Figures' # 'Figures_solid_grey'
metric_names = ['cvvdp', 'FLIP', 'TOPIQ']
metric_options = ['spem'] # 'spem', only_tcsf

fix_axis = False # True False
plot_circle = True
plot_pano = False # True False

# 2. Extract Metadata from condition_id
def extract_metadata(row): 
    cid = row['condition_id']
    # Extract scene: 'circle' or 'pano'
    scene_match = re.match(r'^([a-zA-Z]+)', cid)
    scene = scene_match.group(1) if scene_match else None
    
    # Extract velocity: e.g., '15' from 'v15'
    vel_match = re.search(r'_v(\d+)', cid)
    velocity = vel_match.group(1) if vel_match else None
    
    # Extract fps: e.g., '50' from 'fps50'
    fps_match = re.search(r'_fps(\d+)', cid)
    fps = int(fps_match.group(1)) if fps_match else None
    
    return pd.Series([scene, velocity, fps], index=['scene', 'velocity', 'fps'])

os.makedirs(f'{current_dir}/{output_folder}', exist_ok=True)

for metric_name in metric_names:
    for metric_option in metric_options:
        print(f"Processing {metric_name} with {metric_option}...")
        
        # Try different possible paths
        csv_path = f'{root}/MARRR_{metric_name}_{metric_option}.csv'
        # if not os.path.exists(csv_path):
        #     csv_path = f'{hpc_root}/MARRR_{metric_name}_{metric_option}.csv'
        
        if not os.path.exists(csv_path):
            print(f"  Warning: CSV not found for {csv_path}. Skipping...")
            continue

        df = pd.read_csv(csv_path)
        metric = f'{metric_name} ({metric_option}) reference 631FPS'
        reverse = True if metric_name.upper() == 'FLIP' else False # True False

        if fix_axis:
            out_dir = f'{current_dir}/{output_folder}/fixed_axis'
        else:
            out_dir = f'{current_dir}/{output_folder}/dynamic_axis'
        os.makedirs(out_dir, exist_ok=True)

        df[['scene', 'velocity', 'fps']] = df.apply(extract_metadata, axis=1)

        # 3. Calculate 1 - Q
        df['1-Q'] = 1 - df['Q'] if reverse else df['Q']

        # 4. Sorting for plotting
        df = df.sort_values(by=['scene', 'velocity', 'fps'])

        # --- Plot Circle Scene ---
        if plot_circle:
            plt.figure(figsize=(10, 6))
            circle_df = df[df['scene'] == 'circle']
            # Specific velocities requested: v15, v30, v45
            for v in ['15', '30', '45']:
                subset = circle_df[circle_df['velocity'] == v]
                if not subset.empty:
                    plt.plot(subset['fps'], subset['1-Q'], marker='o', label=f'v{v}')

            suffix = '1minusQ' if reverse else 'Q'
            plt.title(f'{metric} - Circle Scene')
            plt.xlabel('FPS')
            plt.ylabel('$1 - Q$ Score') if reverse else plt.ylabel('$Q$ Score') 
            plt.legend(title='Velocity')
            plt.grid(True, linestyle='--', alpha=0.7)
            if fix_axis:
                if metric_name.lower() == 'cvvdp':
                    plt.ylim(7, 10)
                elif metric_name.upper() in ['FLIP', 'TOPIQ']:
                    plt.ylim(0.5, 1)
            plt.savefig(f'{out_dir}/{metric}_circle_plot.png')
            plt.close() # Close to avoid memory issues and overlaps
            print(f"Plots saved in {out_dir}/{metric}_circle_plot.png.") # Fixed this print statement

        # --- Plot Pano Scene ---
        if plot_pano:
            plt.figure(figsize=(10, 6))
            pano_df = df[df['scene'] == 'pano']
            if pano_df.empty:
                print(f"  Warning: No pano data found for {metric_name}_{metric_option}.")
            else:
                for v in sorted(pano_df['velocity'].unique(), key=int):
                    subset = pano_df[pano_df['velocity'] == v]
                    plt.plot(subset['fps'], subset['1-Q'], marker='s', label=f'v{v}')

                plt.title(f'{metric} - Pano Scene')
                plt.xlabel('FPS')
                plt.ylabel('$1 - Q$ Score') if reverse else plt.ylabel('$Q$ Score') 
                # plt.ylabel('$Q$ Score')
                plt.legend(title='Velocity')
                plt.grid(True, linestyle='--', alpha=0.7)
                if fix_axis:
                    if metric_name.lower() in ['cvvdp', 'colorvideovdp']:
                        plt.ylim(0, 10)
                    elif metric_name.upper() in ['FLIP', 'TOPIQ']:
                        plt.ylim(0, 1)
                plt.savefig(f'{out_dir}/{metric}_pano_plot.png')
                plt.close() # Close to avoid memory issues and overlaps
                print(f"  Plots saved in {out_dir}/{metric}_pano_plot.png.")