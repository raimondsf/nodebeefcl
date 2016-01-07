double run_rng(uint2 *state) {
	uint r0 = (18030 * ((*state).x & 0xFFFF)) + ((*state).x >> 16);
	uint r1 = (36969 * ((*state).y & 0xFFFF)) + ((*state).y >> 16);
	(*state).x = r0; (*state).y = r1;
	uint x_uint = (r0 << 16) + (r1 & 0xFFFF);
	double x = (double)x_uint;
	if (x < 0.0) { 
		x = x + 4294967296.0;
	}
	return x * 2.3283064365386962890625e-10;

}

__kernel void node_newer_rng(
			     const uint2 state_base,
			     const uint search_len,
			     const uint successful_guesses_max,

			     __global const double *outputs,
			     const uint outputs_len,
			     __global uint *successful_guesses_count,
			     __global uint *successful_guesses
			     ) {
uint gid = get_global_id(0);
uint guess = gid; 

uint2 state;
state.x = state_base.x | ((guess & 0xFFFF)<<16);
state.y = state_base.y | (guess & 0xFFFF0000);


uint cur_output = 0;
for (uint i = 0; i < search_len && cur_output < outputs_len; i++) {
	  double s = run_rng(&state);
	  if (s == outputs[cur_output]) {
	  cur_output += 1;
	  i = 0;
	  }
	  }
	  if (cur_output == outputs_len) {
	  uint guess_idx = atomic_inc(successful_guesses_count);
	  if (guess_idx < successful_guesses_max) {
	  successful_guesses[guess_idx] = gid;
	  }
	  }
	  }