import serial
import time

def motorparam(ser, rpm, acl, dcl, abrt):
    rpm_count = int(8333 * rpm)
    acl_count = int(5000 * acl)
    dcl_count = int(5000 * dcl)
    abrt_count = int(5000 * abrt)

    ser.write(f's r0xcb {rpm_count} \n'.encode())
    ser.write(f's r0xcc {acl_count} \n'.encode())
    ser.write(f's r0xcd {dcl_count} \n'.encode())
    ser.write(f's r0xcf {abrt_count} \n'.encode())

def moveto(ser, usteps):
    ser.write(f's r0xca {usteps} \n'.encode())
    ser.write(b't 1 \n')

def test_motor(port):
    try:
        ser = serial.Serial(port, baudrate=9600, timeout=1)
        print(f"Opened {port}")
    except Exception as e:
        print(f"Failed to open {port}: {e}")
        return

    # Set motor parameters: rpm=50, acceleration=10, deceleration=10, emergency deceleration=50
    motorparam(ser, rpm=50, acl=10, dcl=10, abrt=50)
    time.sleep(0.1)

    # Move forward 1000 microsteps
    print("Moving forward 1000 microsteps")
    moveto(ser, 1000)
    time.sleep(5)  # wait for motor to move

    # Move back to zero
    print("Moving back to zero")
    moveto(ser, 0)
    time.sleep(5)  # wait for motor to move

    ser.close()
    print("Test complete, port closed.")

if __name__ == "__main__":
    test_motor('COM5')  # Change 'COM5' to your motor port
