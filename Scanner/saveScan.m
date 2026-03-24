if mod(scanNumber,2) == 1 
    create_hdf5(cntr, imacount, Height, Width, target_folder);
    save_to_hdf5(image_stack, cntr, target_folder);
end