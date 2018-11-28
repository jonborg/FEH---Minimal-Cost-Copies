# FEH---Minimal-Cost-Copies
MATLAB script that I created to see how probable I could pull multiple copies of a unit depending of the numbers I use.

I am not sure if the script is correctly made. I try to generate a rank/stars to every summon in the summoning section. Afterwards a color. Then, for each summon with the same color I check the probability of that summon being the target unit of the rank/star of the summon. I end up using 3 random number generators. I also assume that MATLAB's rng is unbiased and that, for each pool, any unit is equiprobable to pull.

MATLAB Instructions:
fehCopiesCost(copies,unitColor,unitStarPool,legendary)
%      READ ME PLEASE.
%      Computes a cumulative density function that tells the frequent orb
%      cost of pulling multiple copies of an unit.
%
%      copies: how many copies you want;
%      unitColor: the color of the unit you want:
%                   'r'-red;
%                   'b'-blue;
%                   'g'-green;
%                   'c'-colorless.
%      unitStarPool: The pools that the target unit belongs to:
%                   ex.: [1 0 0 1] represents a unit that is in the focus
%                   pool and in the 3* pool;
%                   ex.: [0 1 1 0] represents a unit that is in the 5* pool
%                   and in the 4* pool.
%       legendary:  optional flag variable. Makes the function use a legendary banners'
%                   probabilities when assigned to true. DO NOT DECLARE IT IF IT IS A
%                   NORMAL BANNER. NOTHING WILL HAPPEN.
