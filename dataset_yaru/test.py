import scipy.io
import pandas as pd

# Load the mat file
path = '../experiment_fps_jod/analysis/scaled_results.mat'
data = scipy.io.loadmat(path)
res = data['res'][0, 0]

# Extract variables
refresh_rates = res['refresh_rates'].flatten()
jods = res['JODs']    # Matrix for Figure 8
jods3 = res['JODs3']  # Matrix for Figure 7

# Stimuli labels based on experimental conditions
stimuli_labels = [
    "Circle 15 deg/s Predictable",
    "Circle 30 deg/s Predictable",
    "Circle 45 deg/s Predictable",
    "Circle 23 deg/s Unpredictable",
    "ET Target 15 deg/s Predictable",
    "Panorama 30 deg/s Predictable",
    "Stimulus 7"
]

velocity_labels = [
    "15 deg/s Predictable",
    "30 deg/s Predictable",
    "45 deg/s Predictable"
]

# Save Figure 8 data
df_fig8 = pd.DataFrame(jods, columns=refresh_rates, index=stimuli_labels[:jods.shape[0]])
df_fig8.to_csv('marrr_scores_fig8_independent.csv')

# Save Figure 7 data
df_fig7 = pd.DataFrame(jods3, columns=refresh_rates, index=velocity_labels[:jods3.shape[0]])
df_fig7.to_csv('marrr_scores_fig7_unified.csv')
