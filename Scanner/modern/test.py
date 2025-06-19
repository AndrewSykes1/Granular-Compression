import serial
import time

def identify_device(port):
    try:
        with serial.Serial(port, baudrate=9600, timeout=1) as ser:
            # Wait a bit for the device to settle
            time.sleep(0.5)
            # Some devices respond to "*IDN?" (identity query)
            ser.write(b'*IDN?\r\n')
            time.sleep(0.5)
            response = ser.read(ser.in_waiting or 100).decode('utf-8', errors='ignore').strip()
            if response:
                print(f"{port}: Response -> {response}")
            else:
                print(f"{port}: No response or unknown device")
    except Exception as e:
        print(f"{port}: Could not open or communicate: {e}")

ports = ['COM2', 'COM3', 'COM4', 'COM5']
for p in ports:
    identify_device(p)
