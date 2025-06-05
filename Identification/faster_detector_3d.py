import h5py
import numpy as np
from detect_particles import detect_particles
from scipy.spatial import cKDTree
import matplotlib.pyplot as plt

def load_images_from_hdf5(file_path):
    with h5py.File(file_path, 'r') as f:
        return np.array(f['RawData/Scan_18'])  # adjust key if needed

def collect_particle_data(images):
    particle_dict = {}  # particle_id: list of (z, x, y, r)
    centers_by_layer = []

    for z, image in enumerate(images):
        particles = detect_particles(image, show=True)
        print(image.shape)
        print(particles.shape)

        print(image.shape)

        print(particles.shape)
        print(particles)
        exit()
        centers_by_layer.append([(x, y, r, z) for x, y, r in particles])

    return centers_by_layer

def group_particles(centers_by_layer, threshold=5.0):
    particles = []
    visited = set()

    for z, layer in enumerate(centers_by_layer):
        for i, (x, y, r, z) in enumerate(layer):
            if (z, i) in visited:
                continue

            cluster = [(x, y, r, z)]
            visited.add((z, i))

            for dz in [1, -1]:
                z2 = z + dz
                if z2 < 0 or z2 >= len(centers_by_layer):
                    continue

                tree = cKDTree([(cx, cy) for cx, cy, _, _ in centers_by_layer[z2]])
                dists, idxs = tree.query([x, y], distance_upper_bound=threshold)

                for dist, idx in zip(dists, idxs):
                    if idx < len(centers_by_layer[z2]):
                        x2, y2, r2, _ = centers_by_layer[z2][idx]
                        cluster.append((x2, y2, r2, z2))
                        visited.add((z2, idx))

            particles.append(cluster)

    return particles

def get_largest_cross_section_center(particle_group):
    return max(particle_group, key=lambda tup: tup[2])  # max by radius

def plot_centers(centers):
    xs, ys, zs = zip(*centers)
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.scatter(xs, ys, zs, c='r', marker='o')
    plt.show()

def main():
    file = r'C:\Users\Lab User\Desktop\experiment data\07302024\Scan_18.hdf5'
    #with h5py.File(file, 'r') as f:
    #    print(list(f.keys()))


    images = load_images_from_hdf5(file) # Shape is (852,1224,1024)
    centers_by_layer = collect_particle_data(images)
    grouped_particles = group_particles(centers_by_layer)
    final_centers = [(x, y, z) for x, y, r, z in map(get_largest_cross_section_center, grouped_particles)]
    plot_centers(final_centers)

if __name__ == '__main__':
    main()
