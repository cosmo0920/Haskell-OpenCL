#ifdef cl_khr_fp64
  #pragma OPENCL EXTENSION cl_khr_fp64 : enable
  typedef double tfloat; 
#elif defined(cl_amd_fp64)
  #pragma OPENCL EXTENSION cl_amd_fp64 : enable
  typedef double tfloat;
#else
  typedef float  tfloat;
#endif
__kernel void arrayft_1d(__global const tfloat in[], __global tfloat out[])
{
  //int id = get_global_id(0);
  int id = get_local_size(0) * get_group_id(0) + get_local_id(0);
  int size = get_global_size(0);
  tfloat pi = 4.0*atan(1.0), tmpRe=0.0, tmpIm=0.0;
  tfloat d = 2.0*pi/size,phase;

  for(int i = 0; i < size; i++) {
    phase = d * i * id;
    tmpRe += in[i]*cos(phase);
    tmpIm -= in[i]*sin(phase);
    //power spectrum
    out[id] = sqrt(tmpRe * tmpRe + tmpIm * tmpIm);
  }
}
