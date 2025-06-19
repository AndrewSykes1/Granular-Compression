import os
import time
import numpy as np
import h5py
import serial

# ---------------------------------------
# Serial-based motor control functions
# ---------------------------------------

def setup_motors_and_wall(CompressionSpeed):
    def safe_open(port):
        try:
            return serial.Serial(port, timeout=1)
        except:
            print(f"{port} unavailable")
            return None

    s1 = safe_open('COM3')  # Near Laser
    s2 = safe_open('COM4')  # Camera
    s3 = safe_open('COM5')  # Far Laser

    for s in [s1, s2, s3]:
        if s:
            s.write(b's r0x24 31 \n;')  # Stepper mode
            s.write(b's r0xc8 0 \n;')   # Absolute trap mode

    try:
        s4 = serial.Serial('COM2', baudrate=9600, bytesize=8, parity='N', stopbits=1, timeout=1)
        s4.write(b'HR\r')
        s4.write(b'AR\r')
        s4.write(b'ME\r')
        rev_velocity = CompressionSpeed * 10 / 25.4
        acdc = int(rev_velocity * 10)
        s4.write(f'VE{rev_velocity:.5f}\r'.encode())
        s4.write(f'AC{acdc}\r'.encode())
        s4.write(f'DE{acdc}\r'.encode())
        s4.write(b'EG51200\r')
    except:
        print("COM2 unavailable (s4)")
        s4 = None

    return s1, s2, s3, s4

def motorparam(mtr, rpm, acl, dcl, abrt):
    if mtr is None: return
    mtr.write(f's r0xcb {int(8333 * rpm)} \n'.encode())
    mtr.write(f's r0xcc {int(5000 * acl)} \n'.encode())
    mtr.write(f's r0xcd {int(5000 * dcl)} \n'.encode())
    mtr.write(f's r0xcf {int(5000 * abrt)} \n'.encode())

def moveto(mtr, usteps):
    if mtr is None: return
    mtr.write(f's r0xca {int(usteps)} \n'.encode())
    mtr.write(b't 1 \n')

def moveWall(steps, driver):
    if driver:
        command = f'FL{int(steps)}\r' if steps < 0 else f'FR{int(steps)}\r'
        driver.write(command.encode())

# ---------------------------------------
# HDF5 saving
# ---------------------------------------

def create_hdf5(scan_number, num_images, xres, yres, path):
    filename = os.path.join(path, f"Scan_{scan_number}.hdf5")
    dataset = f"/RawData/Scan_{scan_number}"
    h5create = h5py.File(filename, "w")
    h5create.create_dataset(
        dataset,
        shape=(xres, yres, num_images),
        dtype='uint16',
        chunks=(xres, yres, 1),
        compression="gzip",
        compression_opts=4,
        shuffle=True,
        fletcher32=True
    )
    h5create.close()

def save_to_hdf5(image_stack, scan_number, path):
    filename = os.path.join(path, f"Scan_{scan_number}.hdf5")
    dataset = f"/RawData/Scan_{scan_number}"
    with h5py.File(filename, "a") as f:
        f[dataset][:] = image_stack

# ---------------------------------------
# Mock image capture (replace with real)
# ---------------------------------------

def capture_image(h, w):
    return np.random.randint(0, 65535, (h, w), dtype=np.uint16)

# ---------------------------------------
# Main scan execution
# ---------------------------------------

def make_scan(imacount, s1, s2, s3, laser_targets, camera_targets, image_stack, Width, Height):
    for i in range(imacount):
        image_stack[:, :, i] = capture_image(Height, Width)
        moveto(s1, -laser_targets[i])
        moveto(s3, laser_targets[i])
        moveto(s2, camera_targets[i])
        time.sleep(0.05)  # simulate camera frame interval

# ---------------------------------------
# Main function
# ---------------------------------------

def main():
    Width, Height = 1224, 1024
    scan_distance = 90  # mm
    volume_length = 15.3 / 2.54
    pixel_width = volume_length * 25.4 / Width
    refraction_index = 1.49
    exposure_time = 50
    CompressionSpeed = 0.05
    NumberOfCycles = 100

    CompressionDistance = volume_length * 0.01
    CompressionSteps = int(CompressionDistance * 10 * 51200)
    motionSeries = -CompressionSteps * np.array([1, -1] * 10)
    numberOfScans = len(motionSeries)
    imacount = int(scan_distance / pixel_width)

    laser_targets = np.floor(np.linspace(1, imacount, imacount) * scan_distance / (85 * imacount) * 50000).astype(int)
    camera_targets = np.floor(laser_targets / refraction_index).astype(int)

    folder = r'C:\Users\Lab User\Desktop\experiment data\07312027\\'
    os.makedirs(folder, exist_ok=True)

    s1, s2, s3, s4 = setup_motors_and_wall(CompressionSpeed)

    motorparam(s1, 20, 10, 10, 50)
    motorparam(s3, 20, 10, 10, 50)
    motorparam(s2, 20, 10, 10, 50)
    moveto(s1, 0)
    moveto(s3, 3000)
    moveto(s2, 0)

    for cycleNum in range(98, NumberOfCycles):
        cntr = cycleNum * 2 + 1
        for scanNumber in range(numberOfScans):
            print(f"Cycle {cycleNum} | Scan {scanNumber+1}/{numberOfScans}")

            motorparam(s1, 200, 40, 40, 50)
            motorparam(s3, 200, 40, 40, 50)
            motorparam(s2, int((1/refraction_index)*200), 40, 40, 50)

            image_stack = np.zeros((Height, Width, imacount), dtype=np.uint16)

            make_scan(imacount, s1, s2, s3, laser_targets, camera_targets, image_stack, Width, Height)

            motorparam(s1, 20, 10, 10, 50)
            motorparam(s3, 20, 10, 10, 50)
            motorparam(s2, 20, 10, 10, 50)

            moveto(s1, 0)
            moveto(s3, 3000)
            moveto(s2, 0)

            print(f"Wall move {motionSeries[scanNumber]}")
            moveWall(motionSeries[scanNumber], s4)

            create_hdf5(cntr, imacount, Height, Width, folder)
            save_to_hdf5(image_stack, cntr, folder)

            time.sleep(1)
            cntr += 1

    print("Scan Complete.")

if __name__ == "__main__":
    main()
