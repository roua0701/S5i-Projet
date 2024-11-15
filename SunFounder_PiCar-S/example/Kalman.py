import numpy as np

def kalman_single_measurement(z, Q=1e-3, R=0.05**2, x_estimate_init=10.0, P_init=1.0):
    x_estimate = x_estimate_init
    P = P_init

    x_pred = x_estimate
    P_pred = P + Q

    K = P_pred / (P_pred + R)
    x_estimate = x_pred + K * (z - x_pred) 
    P = (1 - K) * P_pred  

    return x_estimate

