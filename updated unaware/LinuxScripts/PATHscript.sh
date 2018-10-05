#!/bin/bash
#BSUB -n 1                   # Number of cores
#BSUB -J Bowtie_job          # Job Name
#BSUB -q short               # Which queue to use {short, long, parallel, GPU, interactive}
#BSUB -W 10:15                # How much time does your job need (HH:MM)
module load jdk/1.8.0_77
~/NetLogo6.0.4/netlogo-headless.sh \
--model ~/BaseModel-HETMSM.nlogo \
--experiment experiment2 \
--table ~/MyNewOutputData.csv  
 	 	
 	 	