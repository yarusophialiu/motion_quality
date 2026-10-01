import pandas as pd
import matplotlib.pyplot as plt
import re

def plot_marrr_figure_7(metric_csv, gt_csv, output_path, title=""):
    # 1. Load and parse the Metric Data
    df_metric = pd.read_csv(metric_csv)
    df_metric.columns = df_metric.columns.str.strip() # Clean headers
    
    def parse_filename(path):
        # Extract velocity (v15, v30, v45)
        vel = 15 if 'v15' in path else 30 if 'v30' in path else 45
        # Extract FPS (e.g., fps050 -> 50)
        match = re.search(r'fps(\d+)', path)
        fps = int(match.group(1)) if match else None
        return vel, fps

    # Apply parsing to extract columns for grouping
    df_metric[['velocity', 'fps']] = df_metric.apply(
        lambda r: pd.Series(parse_filename(str(r['test']))), axis=1
    )
    
    # Average results if multiple entries exist for the same condition
    df_metric = df_metric.groupby(['velocity', 'fps'])['cvvdp'].mean().reset_index()

    # 2. Load the Ground Truth JOD Data (from Figure 7 unified scale)
    df_gt = pd.read_csv(gt_csv, index_col=0)
    
    # 3. Plotting
    fig, ax1 = plt.subplots(figsize=(10, 6))
    ax2 = ax1.twinx() # Secondary axis for the metric scores
    
    # Paper-accurate colors: Purple (15), Blue (30), Red (45)
    colors = {15: '#9b59b6', 30: '#3498db', 45: '#e74c3c'}
    markers = {15: 'o', 30: 's', 45: '^'}
    
    # Plot Subjective Ground Truth (Solid Lines)
    for vel in [15, 30, 45]:
        row_name = f"{vel} deg/s Predictable"
        if row_name in df_gt.index:
            x_gt = df_gt.columns.astype(int)
            y_gt = df_gt.loc[row_name].values
            ax1.plot(x_gt, y_gt, color=colors[vel], linewidth=2, 
                     label=f'Subjective JND ({vel} deg/s)', alpha=0.8)

    # Plot Objective Metric Results (Dashed Lines with Markers)
    for vel in sorted(df_metric['velocity'].unique()):
        sub = df_metric[df_metric['velocity'] == vel].sort_values('fps')
        if not sub.empty:
            ax2.plot(sub['fps'], sub['cvvdp'], color=colors[vel], linestyle='--', 
                     marker=markers[vel], markersize=7, alpha=0.7, 
                     label=f'CVVDP JOD ({vel} deg/s)')

    # Formatting
    ax1.set_xlabel('Refresh Rate (Hz)', fontsize=12)
    ax1.set_ylabel('Subjective Quality (JOD, JND)', fontsize=12)
    ax2.set_ylabel('Metric Score (CVVDP)', color='gray', fontsize=12)
    
    ax1.set_title(f'Fig7 {title}: Refresh Rate vs Perceived Quality (Unified Scale)', fontsize=14)
    ax1.grid(True, linestyle=':', alpha=0.5)
    ax1.set_xlim(45, 170)
    ax1.set_ylim(-2, 6) # Standard JOD range for unified Fig 7
    
    # Combine legends from both axes
    h1, l1 = ax1.get_legend_handles_labels()
    h2, l2 = ax2.get_legend_handles_labels()
    ax1.legend(h1 + h2, l1 + l2, loc='upper left', bbox_to_anchor=(1.15, 1), frameon=False)
    
    plt.tight_layout()
    plt.savefig(output_path)
    plt.show()


def plot_cvvdp_metric_only(csv_file, output_path, title=""):
    # 1. Load the results
    df = pd.read_csv(csv_file)
    df.columns = df.columns.str.strip() # Remove any extra whitespace

    # 2. Parse Velocity and FPS from file paths
    def parse_info(path):
        # Identify velocity from folder or filename (v15, v30, v45)
        vel = 15 if 'v15' in path else 30 if 'v30' in path else 45
        # Extract FPS (e.g., fps050 -> 50)
        match = re.search(r'fps(\d+)', path)
        fps = int(match.group(1)) if match else None
        return vel, fps

    df[['velocity', 'fps']] = df.apply(
        lambda r: pd.Series(parse_info(str(r['test']))), axis=1
    )

    # 3. Aggregate scores (Mean score per condition)
    plot_data = df.groupby(['velocity', 'fps'])['cvvdp'].mean().reset_index()
    print(f'plot_data \n{plot_data}')

    # 4. Plotting
    plt.figure(figsize=(10, 6))
    
    # Established color scheme: Purple (15), Blue (30), Red (45)
    colors = {15: '#9b59b6', 30: '#3498db', 45: '#e74c3c'}
    markers = {15: 'o', 30: 's', 45: '^'}

    for vel in sorted(plot_data['velocity'].unique()):
        subset = plot_data[plot_data['velocity'] == vel].sort_values('fps')
        plt.plot(subset['fps'], subset['cvvdp'], 
                 color=colors[vel], 
                 marker=markers[vel], 
                 linestyle='--', 
                 markersize=8, 
                 linewidth=2, 
                 label=f'CVVDP ({vel} deg/s)')

    plt.xlabel('Refresh Rate (Hz)', fontsize=12)
    plt.ylabel('Metric Score (CVVDP)', fontsize=12)
    plt.title(f'{title} CVVDP Quality Scores vs Refresh Rate', fontsize=14)
    plt.grid(True, linestyle=':', alpha=0.6)
    plt.legend(title='Velocity')
    
    plt.tight_layout()
    plt.savefig(output_path)
    plt.show()



if __name__ == "__main__":
    # plot_marrr_figure_7('results_spem_old_circle.csv', 'marrr_scores_fig7_unified.csv', "fig7_spem_circle.png", title="SPEM")
    
    plot_marrr_figure_7('results_no_spem_old_circle.csv', 'marrr_scores_fig7_unified.csv', \
                        "fig7_no_spem_circle.png", title="NO SPEM")

    # Run the plotting function
    # plot_cvvdp_metric_only('results_spem_old_circle.csv', "fig7_spem_cvvdp_circle.png", title="SPEM")
    # plot_cvvdp_metric_only('results_no_spem_old.csv', "fig7_no_spem_cvvdp.png", title="NO SPEM")