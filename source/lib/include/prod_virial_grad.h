// SPDX-License-Identifier: LGPL-3.0-or-later
#pragma once

namespace deepmd {

template <typename FPTYPE>
void prod_virial_grad_a_cpu(FPTYPE* grad_net,
                            const FPTYPE* grad,
                            const FPTYPE* env_deriv,
                            const FPTYPE* rij,
                            const int* nlist,
                            const int nloc,
                            const int nnei);

template <typename FPTYPE>
void prod_virial_grad_r_cpu(FPTYPE* grad_net,
                            const FPTYPE* grad,
                            const FPTYPE* env_deriv,
                            const FPTYPE* rij,
                            const int* nlist,
                            const int nloc,
                            const int nnei);

#if GOOGLE_CUDA
template <typename FPTYPE>
void prod_virial_grad_a_gpu_cuda(FPTYPE* grad_net,
                                 const FPTYPE* grad,
                                 const FPTYPE* env_deriv,
                                 const FPTYPE* rij,
                                 const int* nlist,
                                 const int nloc,
                                 const int nnei);

template <typename FPTYPE>
void prod_virial_grad_r_gpu_cuda(FPTYPE* grad_net,
                                 const FPTYPE* grad,
                                 const FPTYPE* env_deriv,
                                 const FPTYPE* rij,
                                 const int* nlist,
                                 const int nloc,
                                 const int nnei);
#endif  // GOOGLE_CUDA

#if TENSORFLOW_USE_ROCM
template <typename FPTYPE>
void prod_virial_grad_a_gpu_rocm(FPTYPE* grad_net,
                                 const FPTYPE* grad,
                                 const FPTYPE* env_deriv,
                                 const FPTYPE* rij,
                                 const int* nlist,
                                 const int nloc,
                                 const int nnei);

template <typename FPTYPE>
void prod_virial_grad_r_gpu_rocm(FPTYPE* grad_net,
                                 const FPTYPE* grad,
                                 const FPTYPE* env_deriv,
                                 const FPTYPE* rij,
                                 const int* nlist,
                                 const int nloc,
                                 const int nnei);
#endif  // TENSORFLOW_USE_ROCM

}  // namespace deepmd
