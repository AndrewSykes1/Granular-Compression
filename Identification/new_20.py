import numpy as np
import matplotlib.pyplot as plt
from stardist.models import StarDist2D
from csbdeep.utils import normalize
from sklearn.cluster import DBSCAN
import h5py
from datetime import datetime
from skimage.transform import resize
import os
from mpl_toolkits.mplot3d import Axes3D
import plotly.graph_objects as go
import sys

def load_hdf5_stack(path, dataset_key='RawData'):
    with h5py.File(path, 'r') as f:
        # Adjust to nested dataset key if needed, e.g., 'RawData/Scan_18'
        return np.array(f[dataset_key])

def detect_centers_in_stack(image_stack, output_dir='output_figures'):
    model = StarDist2D.from_pretrained('2D_versatile_fluo')
    all_centers = []

    os.makedirs(output_dir, exist_ok=True)

    for z, img in enumerate(image_stack):
        CLEAR_PREVIOUS_LINE = '\033[F\033[K'  # \033[F = move cursor up, \033[K = clear line
        sys.stdout.write(CLEAR_PREVIOUS_LINE)  # Remove previous "Processing slice..." line
        now = datetime.now()
        msg = f"[{now.strftime('%Y-%m-%d %H:%M:%S')}] Processing slice {z+1}/{len(image_stack)}..."
        print(msg)

        # Resize to 20% of original size
        img_resized = resize(img, (int(img.shape[0]*0.2), int(img.shape[1]*0.2)), preserve_range=True)
        img_norm = normalize(img_resized, 1, 99.8)

        labels, details = model.predict_instances(img_norm)
        centers_2d = details['points']

        # Rescale centers back to original image size
        centers_2d = centers_2d / 0.2  # Because resized down by 0.2, so scale centers up by 1/0.2 = 5

        for center in centers_2d:
            all_centers.append([center[0], center[1], z])

        # Plot the original image and overlay predicted centers
        plt.figure(figsize=(6,6))
        plt.imshow(img, cmap='gray')
        plt.scatter(centers_2d[:, 1], centers_2d[:, 0], c='r', s=10)
        plt.title(f"Slice {z+1} with detected centers")
        plt.axis('off')

        # Save the figure to disk instead of showing it
        plt.savefig(os.path.join(output_dir, f"slice_{z+1:03d}.png"))
        plt.close()

    return np.array(all_centers)

def cluster_3d_points(points, eps=3.0, min_samples=1):
    clustering = DBSCAN(eps=eps, min_samples=min_samples).fit(points)
    labels = clustering.labels_

    centers_3d = []
    for label in np.unique(labels):
        if label == -1:
            continue
        cluster_pts = points[labels == label]
        center = np.mean(cluster_pts, axis=0)
        centers_3d.append(center)

    return np.array(centers_3d)

# === MAIN ===
if __name__ == '__main__':
    hdf5_path = r'C:\Users\Lab User\Desktop\experiment data\07302024\Scan_18.hdf5'
    dataset_key = 'RawData/Scan_18'  # Adjust as needed

    print("Loading image stack from HDF5...")
    image_stack = load_hdf5_stack(hdf5_path, dataset_key)

    print(f"Image stack dtype: {image_stack.dtype}")
    print("Detecting 2D centers in each slice...")
    all_centers = detect_centers_in_stack(image_stack)

    print("Clustering to estimate 3D centers...")
    centers_3d = cluster_3d_points(all_centers)

    print(f"Found {len(centers_3d)} 3D particles.")

    # Plot clustered 3D centers
    plt.scatter(centers_3d[:, 1], centers_3d[:, 0], c=centers_3d[:, 2], cmap='plasma')
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.title("3D Particle Centers (Color = Z)")
    plt.colorbar(label="Z slice")
    plt.show()

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
            color=zs,                # color by Z slice
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

    # Save to HTML file
    html_file = '3d_particle_centers.html'
    fig.write_html(html_file)
    print(f"3D interactive plot saved to {html_file}")