import serial
import time

def send_command(ser, cmd):
    full_cmd = cmd.encode() + b'\r'
    ser.write(full_cmd)
    time.sleep(0.1) 
    response = ser.read_all()
    print(f"Sent: {cmd} | Received: {response.strip()}")
    # e 3 means faulty cable connection

port = 'COM5'
ser = serial.Serial(port, baudrate=9600, timeout=1)

# Reset port just in case
ser.reset_input_buffer()
ser.reset_output_buffer()

# Hard reset everything
send_command(ser, 'AR')
time.sleep(1)  # give the amp time to reset

# Check for errors? If the amp has a query command like 'DR' or 'TS', try it

send_command(ser,'TS')

send_command(ser, 'ME')
time.sleep(0.5)


send_command(ser, 'HR')  # start communication
send_command(ser, 'AR')  # reset alarms
time.sleep(1)
send_command(ser, 'ME')  # enable motor

# Move commands
send_command(ser, 's r0xcb 4166500')  # rpm param example
send_command(ser, 's r0xca 1000')     # move 1000 microsteps
send_command(ser, 't 1')              # trigger move

time.sleep(5)

send_command(ser, 's r0xca 0')        # move back to zero
send_command(ser, 't 1')

time.sleep(5)

ser.close()
