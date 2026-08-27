import matplotlib.pyplot as plt
import numpy as np
import serial
import sys
import time

ser = serial.Serial("COM3", 115200)

def signed4(x):
    if x >= 8:
        return x - 16
    return x

try:
    ser = serial.Serial(PORT, BAUD, timeout=0.1)
    time.sleep = 0.5
    ser.reset_input_buffer()
except Excetion as e:
    sys.exit(1)

plt.ion()
fig = plt.figure(figsize(7, 6))

try:
    while True:
    
        if ser.in_waiting >= 2:
    
            packet = ser.read(2)
    
            value = int.from_bytes(packet, byteorder='big')
    
            coord = (value >> 12) & 0b1
    
            A = (value >> 8) & 0b1111
            B = (value >> 4) & 0b1111
            C = value & 0b1111
    
            A = signed4(A)
            B = signed4(B)
            C = signed4(C)

            plt.clf()
    
            if coord == 0:
    
                x = np.linspace(-100, 100, 400)
                y = A * x**2 + B * x + C
    
                ax = fig.add_subplot(111)
                ax.plot(x, y, "b-", linewidth=2, label=f"${A}x^2 + {B}x + {C}$")
                ax.set_xlabel("x")
                ax.set_ylabel("y")
                ax.set_title(f"Cartesian: $y = {A}x^2 + {B}x + {C}$")
                ax.grid(True)
                ax.legend()
    
            else:
    
                theta = np.linspace(0, 2 * np.pi, 400)
                r = A * (theta**2) + B * theta + C

                ax = fig.add_subplot(111, projection="polar")
                ax.plot(
                    theta,
                    r,
                    "r-",
                    linewidth=2,
                    label=f"$r = {A}\\theta^2 + {B}\\theta + {C}$",
                )
                ax.set_title(
                    f"Polar: $r = {A}\\theta^2 + {B}\\theta + {C}$", va="bottom"
                )
                ax.grid(True)
                ax.legend()

            fig.canvas.draw()

    plt.pause(0.05)

    except KeyboardInterrupt:
        print("\nExiting plotter...")
    finally:
        ser.close()
        plt.close("all")

