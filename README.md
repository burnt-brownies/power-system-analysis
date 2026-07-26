# Power System Analysis (MATLAB)

MATLAB implementations of core power system analysis techniques, covering transmission line modeling, Y-bus formation, load flow methods, and economic dispatch. 

## Contents

| Experiment | Description |
|---|---|
| [`exp1_transmission_line_models`](./exp1_transmission_line_models) | Short, medium (nominal-π), and long (rigorous/hyperbolic) transmission line models, computes sending-end voltage/current, voltage regulation, and transmission efficiency. |
| [`exp2_ybus_step_by_step`](./exp2_ybus_step_by_step) | Y-bus matrix formation using the direct/inspection (step-by-step) method. |
| [`exp3_ybus_singular_transformation`](./exp3_ybus_singular_transformation) | Y-bus matrix formation using the singular transformation method (bus incidence matrix). |
| [`exp4_gauss_seidel_load_flow`](./exp4_gauss_seidel_lf) | Load flow analysis using the Gauss-Seidel method for PV and PQ buses. |
| [`exp5_newton_raphson_jacobian`](./exp5_newton_raphson_jacobian) | Newton-Raphson load flow, Jacobian matrix (H, N, J, L sub-matrices) construction. |
| [`exp6_fast_decoupled_load_flow`](./exp6_fast_decoupled_lf) | Fast Decoupled Load Flow (FDLF) using B' and B'' matrices. |
| [`exp7_dc_load_flow`](./exp7_dc_load_flow) | DC load flow approximation, line flows and slack bus generation from the B' matrix. |
| [`exp8_economic_dispatch`](./exp8_economic_dispatch) | Economic dispatch using the gradient (lambda-iteration) method, with and without generator limits. |
| [`common`](./common) | Shared helper function `y_bus_formulation.m`, used by experiments 4-7. |
