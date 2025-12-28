import time

def montgomery_reduction(a):
    # This models exactly what your FPGA hardware logic does
    m = (a * 3327) & 0xFFFF
    t = (a + m * 3329) >> 16
    return t - 3329 if t >= 3329 else t

def run_m1_bench(iterations):
    val = 0x42  # Same seed as used on the FPGA
    t0 = time.perf_counter()
    
    for _ in range(iterations):
        # Mirroring the FPGA logic: reduction + increment
        val = (montgomery_reduction(val) + 1) & 0xFFFFFFFF
        
    t1 = time.perf_counter()
    return (t1 - t0) * 1000, val & 0xFF

if __name__ == "__main__":
    iters = 5_000_000
    print(f"🚀 Running software benchmark (Apple M1) - {iters} iterations...")
    
    m1_time, m1_res = run_m1_bench(iters)
    
    print(f"🎯 M1 RESULT: {hex(m1_res)}")
    print(f"⏱️ M1 TIME: {m1_time:.2f} ms")
    
    # Comparison with FPGA baseline
    fpga_time = 200.20
    ratio = fpga_time / m1_time
    print(f"\n📊 Apple M1 is {ratio:.2f}x faster than the FPGA baseline (27MHz)")