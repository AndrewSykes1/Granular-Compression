if mod(scanNumber,2) == 1 
    create_hdf5(cntr, imgCount, Height, Width, target_folder);
    save_to_hdf5(imgStack, cntr, target_folder);
end