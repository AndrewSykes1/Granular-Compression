import napari

def visualizer(data, points=None):
    viewer = napari.Viewer()
    viewer.add_image(data, colormap='bop blue')
    if not None: viewer.add_points(points, size=7, face_color='good_point', border_color='good_point')
    viewer.show()
