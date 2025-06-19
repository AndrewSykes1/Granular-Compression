import serial

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
            s.write(b's r0xc8 0 \n;')   # Trapaziodal movement mode

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