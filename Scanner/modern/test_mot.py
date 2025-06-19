import serial
import time

def test_motor_movement_full(port):
    print(f"Opening {port}...")
    s = serial.Serial(port, baudrate=9600, timeout=1)
    time.sleep(0.2)

    # STEP 1: (FOR COM2-LIKE MOTORS) Reset/homing and enable
    print("Sending initialization commands...")
    s.write(b'HR\r')   # Home Reset
    s.write(b'AR\r')   # Alarm Reset
    s.write(b'ME\r')   # Motor Enable
    time.sleep(0.5)

    # STEP 2: Set stepper mode and motion mode
    s.write(b's r0x24 31 \n')  # Stepper mode
    s.write(b's r0xc8 0 \n')   # Absolute trap
    time.sleep(0.1)

    # STEP 3: Motion parameters (try slow)
    s.write(b's r0xcb 416650 \n')   # 50 RPM
    s.write(b's r0xcc 250000 \n')   # accel
    s.write(b's r0xcd 250000 \n')   # decel
    s.write(b's r0xcf 250000 \n')   # abort decel
    time.sleep(0.1)

    # STEP 4: Move to +3000
    print("Moving to 3000...")
    s.write(b's r0xca 3000 \n')
    s.write(b't 1 \n')
    time.sleep(3)

    # STEP 5: Move back to 0
    print("Moving back to 0...")
    s.write(b's r0xca 0 \n')
    s.write(b't 1 \n')
    time.sleep(3)

    print("Done.")
    s.close()

test_motor_movement_full('COM4')  # or your working port
