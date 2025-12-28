import serial
import time

# Update the PORT to match your system (e.g., '/dev/cu.usbserial-20250303171' for Mac)
PORT = '/dev/cu.usbserial-20250303171' 
BAUD = 115200

try:
    ser = serial.Serial(PORT, BAUD, timeout=3)
    print(f"✅ Connected to Tang Nano on port: {PORT}")
except Exception as e:
    print(f"❌ Failed to open port: {e}")
    exit()

def run_benchmark():
    seed = 0x42
    print(f"🚀 Sending test seed: {hex(seed)}...")
    
    # Clear the input buffer before starting the test
    ser.reset_input_buffer()
    
    # Send 1 byte trigger/seed to the FPGA
    ser.write(bytes([seed]))
    
    t0 = time.perf_counter()
    # Wait for 1 byte of the result back from FPGA
    response = ser.read(1)
    t1 = time.perf_counter()
    
    if response:
        result = response[0]
        duration_ms = (t1 - t0) * 1000
        print(f"🎯 FPGA RESULT: {hex(result)}")
        print(f"⏱️ ROUND-TRIP TIME: {duration_ms:.2f} ms")
        
        # Validation based on 5 million iterations @ 27MHz (~185ms processing + I/O)
        if duration_ms > 180: 
            print("📊 Result credible: FPGA processed 5M operations.")
        else:
            print("⚠️ Response time suspiciously low - verify Verilog loop logic.")
    else:
        print("⌛ Waiting... FPGA did not respond. Check if the port ending in '0' is required.")

if __name__ == "__main__":
    run_benchmark()
    ser.close()