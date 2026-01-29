def DataViewer(data, peaks):
    import numpy as np
    import numpy as np
    import napari

    from qtpy.QtWidgets import QSlider, QVBoxLayout, QWidget, QLabel
    from qtpy.QtCore import Qt


    peaks = np.array(peaks) # [z,y,x]
    volume = data

    viewer = napari.Viewer(ndisplay=3)
    image_layer = viewer.add_image(volume, name='Volume', colormap='gray') # Plots in [z,y,x] which alligns with data format
    points_layer = viewer.add_points(peaks, # Plots in [z,y,x]
                                     size=10,
                                     face_color='red',
                                     name='Local Maxima')

    dock_widget = QWidget()
    layout = QVBoxLayout()

    label_min = QLabel("Min Z")
    slider_min = QSlider(Qt.Horizontal)
    slider_min.setMinimum(0)
    slider_min.setMaximum(volume.shape[0]-1) # Uses z coord of data -1 to find max as data is in [z,y,x]
    slider_min.setValue(0)

    label_max = QLabel("Max Z")
    slider_max = QSlider(Qt.Horizontal)
    slider_max.setMinimum(0)
    slider_max.setMaximum(volume.shape[0]-1)
    slider_max.setValue(volume.shape[0]-1)

    layout.addWidget(label_min)
    layout.addWidget(slider_min)
    layout.addWidget(label_max)
    layout.addWidget(slider_max)
    dock_widget.setLayout(layout)
    viewer.window.add_dock_widget(dock_widget, area='bottom')

    def update_view():

        zmin = slider_min.value()
        zmax = slider_max.value()

        # Clip points to slab
        filtered_points = peaks[(peaks[:, 0] >= zmin) & (peaks[:, 0] <= zmax)]
        points_layer.data = filtered_points  # z, y, x order

        # Clip volume to slab
        filtered_data = volume[zmin:zmax+1, :, :]
        image_layer.data = np.pad(filtered_data, pad_width=[[zmin, amount_of_frames-zmax-1], [0, 0], [0, 0]], mode='constant', constant_values=0)

    slider_min.valueChanged.connect(update_view)
    slider_max.valueChanged.connect(update_view)
    update_view()  # initialize

    napari.run()