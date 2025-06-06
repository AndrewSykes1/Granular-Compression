# === Import Required Libraries ===

import numpy as np
import matplotlib.pyplot as plt
from stardist.models import StarDist2D        # Pretrained object detection model
from csbdeep.utils import normalize           # Image normalization tool
from sklearn.cluster import DBSCAN            # Clustering algorithm
import h5py                                   # For reading HDF5 files
from datetime import datetime                 # For timestamps
from skimage.transform import resize          # For image resizing
import os                                     # For directory handling
import sys                                    # For command line interaction
import plotly.graph_objects as go             # For interactive 3D plots

# === Function: Load Image Stack from HDF5 File ===

def load_hdf5_stack(path, dataset_key='RawData'):
    """
    Loads a stack of 2D images (i.e., a 3D volume) from an HDF5 file.

    Parameters:
        path (str): Path to the .hdf5 file.
        dataset_key (str): Key to the dataset within the file.

    Returns:
        np.ndarray: 3D NumPy array where each slice is a 2D image.
    """
    with h5py.File(path, 'r') as f:
        return np.array(f[dataset_key])

# === Function: Detect 2D Centers in Each Image Slice ===

def detect_centers_in_stack(image_stack, output_dir='output_figures'):
    """
    Detects 2D object centers in each image slice using the StarDist model,
    and returns them as 3D points (x, y, z).

    Parameters:
        image_stack (np.ndarray): 3D array of shape (Z, H, W).
        output_dir (str): Directory to save overlay plots.

    Returns:
        np.ndarray: Array of detected (x, y, z) coordinates.
    """
    model = StarDist2D.from_pretrained('2D_versatile_fluo')  # Load pretrained detection model
    all_centers = []

    os.makedirs(output_dir, exist_ok=True)  # Make output folder if it doesn't exist

    for z, img in enumerate(image_stack):
        # Clear previous line in terminal for clean progress updates
        CLEAR_PREVIOUS_LINE = '\033[F\033[K'
        sys.stdout.write(CLEAR_PREVIOUS_LINE)

        # Print current processing status
        now = datetime.now()
        msg = f"[{now.strftime('%Y-%m-%d %H:%M:%S')}] Processing slice {z+1}/{len(image_stack)}..."
        print(msg)

        # Preprocess image: resize and normalize
        img_resized = resize(img, (int(img.shape[0] * 0.2), int(img.shape[1] * 0.2)), preserve_range=True)
        img_norm = normalize(img_resized, 1, 99.8)

        # Use StarDist to detect object centers in the image
        labels, details = model.predict_instances(img_norm)
        centers_2d = details['points']

        # Scale detected points back to original image size
        centers_2d = centers_2d / 0.2

        # Add each (x, y) center with current z slice as (x, y, z)
        for center in centers_2d:
            all_centers.append([center[0], center[1], z])

        # Save a figure with detected centers overlaid
        plt.figure(figsize=(6, 6))
        plt.imshow(img, cmap='gray')
        plt.scatter(centers_2d[:, 1], centers_2d[:, 0], c='r', s=10)
        plt.title(f"Slice {z+1} with detected centers")
        plt.axis('off')
        plt.savefig(os.path.join(output_dir, f"slice_{z+1:03d}.png"))
        plt.close()

    return np.array(all_centers)

# === Function: Cluster 3D Points to Estimate True Particle Centers ===

def cluster_3d_points(points, eps=3.0, min_samples=1):
    """
    Groups nearby (x, y, z) points into clusters and returns the average center
    of each cluster as the final particle center.

    Parameters:
        points (np.ndarray): List of all detected (x, y, z) points.
        eps (float): Maximum distance between points to be in the same cluster.
        min_samples (int): Minimum points required to form a cluster.

    Returns:
        np.ndarray: List of 3D cluster centers.
    """
    clustering = DBSCAN(eps=eps, min_samples=min_samples).fit(points)
    labels = clustering.labels_

    centers_3d = []
    for label in np.unique(labels):
        if label == -1:
            continue  # Ignore noise points
        cluster_pts = points[labels == label]
        center = np.mean(cluster_pts, axis=0)  # Compute average of cluster
        centers_3d.append(center)

    return np.array(centers_3d)

# === MAIN EXECUTION BLOCK ===

if __name__ == '__main__':
    # Set input file and dataset path
    hdf5_path = r'C:\Users\Lab User\Desktop\experiment data\07302024\Scan_18.hdf5'
    dataset_key = 'RawData/Scan_18'

    # Step 1: Load the image stack
    print("Loading image stack from HDF5...")
    image_stack = load_hdf5_stack(hdf5_path, dataset_key)

    print(f"Image stack dtype: {image_stack.dtype}")

    # Step 2: Detect 2D object centers in each slice
    print("Detecting 2D centers in each slice...")
    all_centers = detect_centers_in_stack(image_stack)

    # Step 3: Cluster those into 3D particle centers
    print("Clustering to estimate 3D centers...")
    centers_3d = cluster_3d_points(all_centers)

    print(f"Found {len(centers_3d)} 3D particles.")

    # Step 4a: Visualize the 3D centers in 2D (colored by depth)
    plt.scatter(centers_3d[:, 1], centers_3d[:, 0], c=centers_3d[:, 2], cmap='plasma')
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.title("3D Particle Centers (Color = Z)")
    plt.colorbar(label="Z slice")
    plt.show()

    # Step 4b: Create interactive 3D scatter plot
    xs = centers_3d[:, 1]
    ys = centers_3d[:, 0]
    zs = centers_3d[:, 2]

    fig = go.Figure(data=[go.Scatter3d(
        x=xs,
        y=ys,
        z=zs,
        mode='markers',
        marker=dict(
            size=5,
            color=zs,
            colorscale='Viridis',
            opacity=0.8
        )
    )])

    fig.update_layout(
        scene=dict(
            xaxis_title='X',
            yaxis_title='Y',
            zaxis_title='Z (Slice)'
        ),
        title='3D Particle Centers',
        width=800,
        height=800
    )

    # Save interactive 3D plot as HTML
    html_file = '3d_particle_centers.html'
    fig.write_html(html_file)
    print(f"3D interactive plot saved to {html_file}")
