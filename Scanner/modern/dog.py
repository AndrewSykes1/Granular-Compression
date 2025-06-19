import serial
import time

def motorparam(s, rpm, acl, dcl, abrt):
    
    # Convert numbers to motors internal units
    rpm_count = int(8333 * rpm)
    acl_count = int(5000 * acl)
    dcl_count = int(5000 * dcl)
    abrt_count = int(5000 * abrt)

    s.write(f's r0xcb {rpm_count} \n'.encode())   # 0xCB represents RPM
    s.write(f's r0xcc {acl_count} \n'.encode())   # 0xCC represents acceleration rate
    s.write(f's r0xcd {dcl_count} \n'.encode())   # 0xCD represents deceleration rate
    s.write(f's r0xcf {abrt_count} \n'.encode())  # 0xCF represents EMERGENCY deceleration

def moveto(s, usteps):
    s.write(f's r0xca {usteps} \n'.encode())
    s.write(b't 1 \n')

def test_motor(port):
    
    print(f"Opening {port}...")

    try:
        s = serial.Serial(port, baudrate=9600, timeout=1)  # Adjust baudrate if needed
    except Exception as e:
        print(f"Failed to open {port}: {e}")
        return

    print(f"Setting motor parameters on {port}...")
    s.write(b's r0x24 31 \n')  # Set stepper mode
    s.write(b's r0xc8 0 \n')   # Set absolute trap mode
    time.sleep(0.1)  # slight delay between commands
    motorparam(s, rpm=500, acl=200, dcl=200, abrt=500) # rev/s^2
    
    moveto(s, 3000)
    time.sleep(3)
    moveto(s, 0)
    time.sleep(3)
    
    s.close()
    print(f"{port} done.\n")

def main():
    port = 'COM5'
    test_motor(port)

if __name__ == "__main__":
    main()
