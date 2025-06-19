import serial
import time

def setup_motor(s):
    s.write(b's r0x24 31 \n')   # Stepper mode
    s.write(b's r0xc8 0 \n')    # Absolute trap mode
    time.sleep(0.1)

def motorparam(s, rpm, acl, dcl, abrt):
    """Set speed/accel parameters."""
    rpm_count = int(8333 * rpm)
    acl_count = int(5000 * acl)
    dcl_count = int(5000 * dcl)
    abrt_count = int(5000 * abrt)

    s.write(f's r0xcb {rpm_count} \n'.encode())   # Speed
    s.write(f's r0xcc {acl_count} \n'.encode())   # Accel
    s.write(f's r0xcd {dcl_count} \n'.encode())   # Decel
    s.write(f's r0xcf {abrt_count} \n'.encode())  # Abort
    time.sleep(0.1)

def moveto(s, usteps):
    """Move to microstep position and trigger motion."""
    s.write(f's r0xca {usteps} \n'.encode())  # Set target pos
    s.write(b't 1 \n')                        # Start motion
    time.sleep(0.1)

def test_motor(port):
    try:
        s = serial.Serial(port, baudrate=9600, timeout=1)
        time.sleep(0.5)
    except Exception as e:
        print(f"Could not open {port}: {e}")
        return
    
    """Test motor for response"""
    s.write(b's r0x24 31 \r\n')  # ask for RPM register value
    time.sleep(0.1)
    response = s.read_all().decode(errors='ignore').strip()
    print(f"Response: '{response}'")

    s.write(b'HR\r')  # Home Reset
    s.write(b'AR\r')  # Alarm Reset
    s.write(b'ME\r')  # Enable

    print(f"[{port}] Initializing...")

    # Step 1: Set control modes
    s.write(b's r0x24 31 \r\n')  # Stepper mode
    s.write(b's r0xc8 0 \r\n')   # Absolute trap mode
    time.sleep(0.1)


    setup_motor(s)
    motorparam(s, rpm=100, acl=50, dcl=50, abrt=100)  # Try lower RPM for reliability

    print(f"[{port}] Moving to +3000...")
    moveto(s, -1500)
    time.sleep(2)

    print(f"[{port}] Moving back to 0...")
    moveto(s, 0)
    time.sleep(2)

    print(f"[{port}] Closing port.")
    s.close()

def main():
    test_motor('COM4') 

if __name__ == "__main__":
    main()
